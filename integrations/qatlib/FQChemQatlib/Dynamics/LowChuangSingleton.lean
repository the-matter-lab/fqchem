module

public import FQChemQatlib.Dynamics.AncillaFreePhase
public import FQChemQatlib.Dynamics.LowChuangElementary
import Mathlib.Tactic

/-! # Ancilla-free synthesis on the two signal flags and the encoding register

The simulation uses the coordinate reflection from [Low and Chuang, Theorem 1](https://doi.org/10.22331/q-2019-07-12-163) and the ancilla-free gate construction from [Gidney, §2.10 and Fig. 21](https://arxiv.org/abs/1706.07884).
-/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.Singleton

open Physical Matrix BorrowedControls DirtyIncrement
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Foundations.PureStateMath
open SingletonPhaseGradient (phase)
variable {a r : ℕ}

abbrev transfer (mask : Reg a) := Matrix.reindexAlgEquiv ℂ ℂ (layout a r mask)

private theorem onlyGate {M : Operator a r} (h : Elementary a r M) : Physical.Emits M 1 :=
  ⟨[M],by simp,by simpa using h,by simp⟩

private theorem merge {A B : Operator a r} {i j : ℕ} (x : Physical.Emits A i) (y : Physical.Emits B j) :
    Physical.Emits (A*B) (i+j) := by
  obtain ⟨p,h,u,rfl⟩ := x; obtain ⟨q,k,v,rfl⟩ := y
  exact ⟨p++q,by simp; omega,fun m mem => (List.mem_append.mp mem).elim (u m) (v m),by simp⟩

private theorem relax {A : Operator a r} {i j : ℕ} (x : Physical.Emits A i) (le : i≤j) : Physical.Emits A j := by
  obtain ⟨p,h,u,v⟩ := x; exact ⟨p,h.trans le,u,v⟩

private theorem classicalEmits (mask : Reg a) {f : Reg (width a r) → Reg (width a r)} {k}
    (ok : Implements f k) : Physical.Emits (transfer (r:=r) mask (AncillaFreePhase.mono f (fun _ => 0))) k := by
  obtain ⟨gs,len,legal,eq⟩ := AncillaFreePhase.finiteCertificate ok
  rw [← eq,← AncillaFreePhase.reverseProduct]
  let q := (gs.map (finiteCodeMatrix (width a r))).reverse
  refine ⟨q.map (transfer mask),by simpa [q] using len,?_,?_⟩
  · intro M mem
    obtain ⟨m,hm,rfl⟩ := List.mem_map.mp mem
    obtain ⟨g,hg,rfl⟩ := List.mem_map.mp (List.mem_reverse.mp hm)
    exact .wire mask g ((List.all_eq_true.mp legal) g hg)
  · exact (map_list_prod ..).symm

private def swapBits {n : ℕ} (x y : Fin n) (s : Reg n) : Reg n :=
  fun i => if i=x then s y else if i=y then s x else s i

private theorem swapWord {n : ℕ} (x y : Fin n) (ne : x≠y) : Implements (swapBits x y) 3 := by
  have uv := controlledBit x y ne
  have vu := controlledBit y x ne.symm
  have h := BorrowedControls.compose (BorrowedControls.compose uv vu) uv
  have eq : (fun s : Reg n => BorrowedControls.flip y (s x) s) ∘
      ((fun s : Reg n => BorrowedControls.flip x (s y) s) ∘ (fun s : Reg n => BorrowedControls.flip y (s x) s)) =
        swapBits x y := by
    funext s i
    by_cases a : i=x <;> by_cases b : i=y <;>
      simp_all [Function.comp_apply,BorrowedControls.flip,swapBits,ne.symm]
    cases s x <;> cases s y <;> rfl
  exact eq ▸ h

private theorem diagonalFlags (v : Flags → ℂ) :
    onFlags (J:=Reg a) (I:=Reg r) (Matrix.diagonal v)=Matrix.diagonal (fun i => v (i.1,i.2.1)) := by
  ext ⟨b,c,s⟩ ⟨d,e,t⟩
  by_cases x : b=d <;> by_cases y : c=e <;> by_cases z : s=t <;>
    simp [onFlags,onBlocks_apply,x,y,z]

private theorem phaseUnit (θ : ℝ) : (starRingEnd ℂ) (phase θ)*phase θ=1 := by
  simp only [SingletonPhaseGradient.phase,← Complex.exp_conj,← Complex.exp_add,map_mul,Complex.conj_ofReal,Complex.conj_I]
  simp

private theorem flagsPhase (mask : Reg a) (has : Bool) (θ : ℝ) :
    Physical.Emits (transfer (r:=r) mask (AncillaFreePhase.phaseGate (outer a r)
      (if has then some (Physical.inner a r) else none) θ)) 1 := by
  let φ (b : Flags) := phase (if b.1 && (if has then b.2 else true) then θ else 0)
  have unit : Matrix.diagonal φ ∈ Matrix.unitaryGroup _ ℂ := by
    rw [Matrix.mem_unitaryGroup_iff',Matrix.star_eq_conjTranspose,Matrix.diagonal_conjTranspose,Matrix.diagonal_mul_diagonal]
    ext b c
    by_cases h : b=c <;> simp [Matrix.one_apply,h,φ,phaseUnit]
  have eq : transfer (r:=r) mask (AncillaFreePhase.phaseGate (outer a r) (if has then some (Physical.inner a r) else none) θ) =
      onFlags (J:=Reg a) (I:=Reg r) (Matrix.diagonal φ) := by
    rw [diagonalFlags]
    apply (Matrix.reindexAlgEquiv ℂ ℂ (layout a r mask)).symm.injective
    rw [AlgEquiv.symm_apply_apply]
    ext s v
    change AncillaFreePhase.phaseGate _ _ _ s v =
      Matrix.diagonal (fun i : Basis a r => φ (i.1,i.2.1)) (layout a r mask s) (layout a r mask v)
    by_cases same : s=v
    · subst s; cases has <;> simp [AncillaFreePhase.phaseGate,AncillaFreePhase.mono,enabled,φ,layout,outer,Physical.inner]
    · simp [AncillaFreePhase.phaseGate,AncillaFreePhase.mono,same]
  rw [eq]; exact onlyGate (.flags _ unit)

private theorem routedPhase (mask : Reg a) (c : Fin (width a r)) (notOuter : c≠outer a r) (θ : ℝ) :
    Physical.Emits (transfer (r:=r) mask (AncillaFreePhase.phaseGate (outer a r) (some c) θ)) 7 := by
  let o := outer a r
  let i := Physical.inner a r
  by_cases eq : i=c
  · subst c; exact relax (flagsPhase mask true θ) (by decide)
  have oi : o≠i := by simp [o,i,outer,Physical.inner]
  let f := swapBits i c
  have fwd := classicalEmits (r:=r) mask (swapWord i c eq)
  have shift := flagsPhase (r:=r) mask true θ
  change Physical.Emits (transfer mask (AncillaFreePhase.phaseGate o (some i) θ)) 1 at shift
  have whole := merge fwd (merge shift fwd)
  rw [← map_mul,← map_mul] at whole
  apply relax _ (by decide : 3+(1+3)≤7)
  convert whole using 1
  congr 1
  dsimp only [AncillaFreePhase.phaseGate]
  rw [AncillaFreePhase.chain,AncillaFreePhase.chain]
  ext s v
  have inv (u : Reg (width a r)) : swapBits i c (swapBits i c u)=u := by
    funext j
    by_cases ji : j=i <;> by_cases jc : j=c <;> simp_all [swapBits,Ne.symm eq]
  have oc : o≠c := notOuter.symm
  have rf : swapBits i c v o=v o := by simp [swapBits,oi,oc]
  have ri : swapBits i c v i=v c := by simp [swapBits]
  simp only [AncillaFreePhase.mono,Function.comp_apply,id_eq,inv,rf,ri,enabled,Option.elim_some,zero_add,add_zero]
  rfl

/-- Positive-coordinate multi-control mark converted to the existing
Low–Chuang elementary vocabulary. Routing an arbitrary diagonal phase never
uses any wire outside the two flags and the original registers. -/
theorem physicalPhase (mask : Reg a) (cs : List (Fin (width a r))) (nd : (outer a r::cs).Nodup) (θ : ℝ) :
    Physical.Emits (transfer (r:=r) mask (Matrix.diagonal (fun s =>
      if s (outer a r) && cs.all s then phase θ else 1))) (7*(2*(720*(cs.length+3))+2*cs.length+1)) := by
  obtain ⟨gs,len,allowed,prod⟩ := AncillaFreePhase.multiControlledPhase (outer a r) cs nd θ
  suffices go : Physical.Emits (transfer (r:=r) mask gs.prod) (7*gs.length) by
    rw [prod] at go; exact relax go (Nat.mul_le_mul_left _ len)
  clear prod len
  induction gs with
  | nil => exact ⟨[],by simp,by simp,by simp⟩
  | cons G gs ih =>
    have step : Physical.Emits (transfer (r:=r) mask G) 7 := by
      cases allowed G (by simp) with
      | code g hg => exact relax (onlyGate (.wire mask g hg)) (by decide)
      | angle c inside θ =>
        cases c with
        | none => exact relax (flagsPhase mask false θ) (by decide)
        | some c => exact routedPhase mask c (fun e => (List.nodup_cons.mp nd).1 (e ▸ inside c (by simp))) θ
    have tail := ih (fun m h => allowed m (by simp [h]))
    rw [List.prod_cons,map_mul,List.length_cons,Nat.mul_succ,Nat.add_comm]
    exact merge step tail

private theorem flagWires (a r : ℕ) : (outer a r::Physical.inner a r::ancList a r).Nodup := by
  have inj : Function.Injective (anc a r) := by
    intro i j eq
    apply Fin.ext
    simpa [anc] using congrArg Fin.val eq
  simp [ancList,outer,Physical.inner,anc,List.Nodup.map inj (List.nodup_finRange a)]
  intro i eq
  have h := congrArg Fin.val eq
  simp at h

private theorem phasePi : phase Real.pi = -1 := Complex.exp_pi_mul_I

/-- The negative of the cubic reflection on the zero-coordinate frame has a
linear physical word for every system width, including zero system wires. -/
theorem coordinateMark (zero : Reg a) :
    Physical.Emits (1-(2:ℕ) • Qatlib.Concepts.Execution.WorkspaceCP.rangeProjector
      (flagsZero (I:=Reg r) zero)) (7*(2*(720*(a+4))+2*(a+1)+1)+4) := by
  let o := outer a r
  let i := Physical.inner a r
  let cs := i::ancList a r
  let mask := fun j => !(zero j)
  let pred := fun s : Reg (width a r) => s o && cs.all s
  let value := fun s : Reg (width a r) => if pred s then Real.pi else 0
  let f := (fun s : Reg (width a r) => BorrowedControls.flip o true s) ∘ (fun s => BorrowedControls.flip i true s)
  have oi : o≠i := by simp [o,i,outer,Physical.inner]
  have z := physicalPhase mask cs (flagWires a r) Real.pi
  have F := classicalEmits (r:=r) mask (BorrowedControls.compose (bit i) (bit o))
  change Physical.Emits (transfer (r:=r) mask (AncillaFreePhase.mono f (fun _ => 0))) 2 at F
  have D : Matrix.diagonal (fun s => if pred s then phase Real.pi else 1) = AncillaFreePhase.mono id value := by
    ext s v
    by_cases e : s=v
    · subst v; cases h : pred s <;> simp [AncillaFreePhase.mono,value,h,SingletonPhaseGradient.phase]
    · simp [AncillaFreePhase.mono,e]
  change Physical.Emits (transfer mask (Matrix.diagonal (fun s => if pred s then phase Real.pi else 1))) _ at z
  rw [D] at z
  have whole := merge F (merge z F)
  rw [← map_mul,← map_mul,AncillaFreePhase.chain,AncillaFreePhase.chain] at whole
  have ff (s : Reg (width a r)) : f (f s)=s := by
    funext j
    by_cases jo : j=o <;> by_cases ji : j=i <;> simp_all [f,BorrowedControls.flip,oi.symm]
  have active (s : Reg (width a r)) : pred (f s)=true ↔
      s o=false ∧ s i=false ∧ (layout a r mask s).2.2.1=zero := by
    have ainv : (ancList a r).all (f s)=(ancList a r).all s := by
      have congr (ds : List (W (width a r))) (h : ∀j∈ds, f s j=s j) : ds.all (f s)=ds.all s := by
        induction ds with
        | nil => rfl
        | cons x ds ih => simp [h x (by simp),ih (fun j e => h j (by simp [e]))]
      apply congr
      intro j hj
      have hi : j≠i := by rintro rfl; exact (List.nodup_cons.mp (List.nodup_cons.mp (flagWires a r)).2).1 hj
      have ho : j≠o := by rintro rfl; exact (List.nodup_cons.mp (flagWires a r)).1 (List.mem_cons_of_mem _ hj)
      simp [f,BorrowedControls.flip,hi,ho]
    have fo : f s o= !s o := by simp [f,BorrowedControls.flip,oi]
    have fi : f s i= !s i := by simp [f,BorrowedControls.flip,oi.symm]
    have controls := positive_controls a r zero s
    change (ancList a r).all s = decide ((layout a r mask s).2.2.1=zero) at controls
    simp [pred,cs,ainv,fo,fi,controls]
  have eq : (1-(2:ℕ) • Qatlib.Concepts.Execution.WorkspaceCP.rangeProjector (flagsZero (I:=Reg r) zero)) =
      transfer (r:=r) mask (AncillaFreePhase.mono (f ∘ id ∘ f) (fun v => 0+value (f v)+0)) := by
    rw [zero_projector]
    apply (Matrix.reindexAlgEquiv ℂ ℂ (layout a r mask)).symm.injective
    rw [AlgEquiv.symm_apply_apply]
    ext s v
    let d := fun x : Basis a r => if x.1=false ∧ x.2.1=false ∧ x.2.2.1=zero then (1:ℂ) else 0
    change ((1-(2:ℕ) • Matrix.diagonal d : Operator a r) (layout a r mask s) (layout a r mask v)) = _
    rw [two_nsmul,Matrix.sub_apply,Matrix.add_apply,Matrix.one_apply,Matrix.diagonal_apply]

    by_cases e : s=v
    · subst v
      have active' := active s
      by_cases pos : pred (f s)=true
      · have all := active'.mp pos
        have yes : (layout a r mask s).1=false ∧ (layout a r mask s).2.1=false ∧ (layout a r mask s).2.2.1=zero := all
        simp [d,AncillaFreePhase.mono,ff,value,pos,phasePi,yes]
      · have off := mt active'.mpr pos
        have no : ¬((layout a r mask s).1=false ∧ (layout a r mask s).2.1=false ∧ (layout a r mask s).2.2.1=zero) := off
        simp [d,AncillaFreePhase.mono,ff,value,pos,no,SingletonPhaseGradient.phase]
    · simp [AncillaFreePhase.mono,ff,e]
  rw [eq]
  have len : cs.length=a+1 := by simp [cs,ancList]
  convert whole using 1
  simp [len]; omega

end FQChemQatlib.Dynamics.LowChuang.Singleton
