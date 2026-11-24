module

public import FQChemQatlib.Dynamics.LowChuangSparsePlacement

/-! # Controlled binary gates and their elementary cost in the sparse circuit -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseControl

open Matrix Qatlib.Foundations.PureStateMath Qatlib.Concepts.GateVocabulary.LocalReflectionGates
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Concepts.LocalMachine.LocalTransport Qatlib.Concepts.CopyEvolution.Discriminate
open Qatlib.Concepts.BlockEncoding.LCU
open SparseWires SparseBlock Query
open scoped Classical

variable {n m : ℕ}

abbrev R (n m : ℕ) := Addr n m → Bool
abbrev Op (n m : ℕ) := Matrix (R n m) (R n m) ℂ

def ctrl (A : Matrix (Reg m) (Reg m) ℂ) : Op n m := raw (lifted (decoderGate (I:=Reg n) A))

/-- The instruction vocabulary consists of addressed one- and two-qubit
operations. The distinguished cases record their obvious product-register
layouts (a control and one data bit, two diagonal bits, or a spectator-lift
of a legal gate on the slot register). -/
inductive Elementary (n m : ℕ) : Op n m → Prop where
  | placed {A : Op n m} : SparseWires.Elementary (Addr n m) A → Elementary n m A
  | controlledWire (i : Fin m) (U : Matrix Bool Bool ℂ) (hu : U ∈ Matrix.unitaryGroup _ ℂ) :
      Elementary n m (ctrl (wireGate m i U))
  | diagonalPair (i j : Addr n m) (f : Bool→Bool→ℂ) (unit : ∀ b c,star (f b c)*f b c=1) :
      Elementary n m (Matrix.diagonal (fun x => f (x i) (x j)))
  | slots (g : FiniteGateCode) (leg : finiteCodeLegal n g=true) :
      Elementary n m (raw (broadcast (slotGate (B:=Reg m) (finiteCodeMatrix n g))))
  | adj {A : Op n m} : Elementary n m A → Elementary n m Aᴴ

def Emits (A : Op n m) (q : ℕ) :=
  ∃ gs : List (Op n m), gs.length ≤ q ∧ (∀ g∈gs, Elementary n m g) ∧ gs.prod=A

theorem single {A : Op n m} (h : Elementary n m A) : Emits A 1 :=
  ⟨[A],by simp,by simpa using h,by simp⟩

theorem empty : Emits (1 : Op n m) 0 := ⟨[],by simp,by simp,by simp⟩

theorem concat {A B : Op n m} {k l} (ha : Emits A k) (hb : Emits B l) : Emits (A*B) (k+l) := by
  obtain ⟨a,la,ga,pa⟩ := ha
  obtain ⟨b,lb,gb,pb⟩ := hb
  exact ⟨a++b,by simp;omega,fun g h=>(List.mem_append.mp h).elim (ga _) (gb _),by simp [pa,pb]⟩

theorem weaken {A : Op n m} {k l} (h : Emits A k) (le : k≤l) : Emits A l := by
  obtain ⟨xs,len,h⟩ := h; exact ⟨xs,len.trans le,h⟩

theorem adj {A : Op n m} {q} (h : Emits A q) : Emits Aᴴ q := by
  obtain ⟨gs,len,all,rfl⟩ := h
  refine ⟨(gs.map Matrix.conjTranspose).reverse,by simpa using len,?_,?_⟩
  · intro G hg
    obtain ⟨g,mem,rfl⟩ := List.mem_map.mp (List.mem_reverse.mp hg)
    exact .adj (all _ mem)
  · clear len all; induction gs <;> simp [*]

theorem placed {A : Op n m} {q} (h : SparseWires.Built A q) : Emits A q := by
  obtain ⟨xs,len,all,val⟩ := h; exact ⟨xs,len,fun g hg => .placed (all g hg),val⟩

theorem ctrl_mul (A B : Matrix (Reg m) (Reg m) ℂ) : ctrl (n:=n) (A*B) = ctrl A * ctrl B := by
  have h {I J : Type} [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J] (X Y : Matrix I I ℂ) :
      parallelOracle (J:=J) (X*Y) = parallelOracle X * parallelOracle Y :=
    (parallel_select_mul _ _).symm
  simp only [ctrl,decoderGate,h,lift_mul,raw_mul]

theorem ctrl_star (A : Matrix (Reg m) (Reg m) ℂ) : ctrl (n:=n) Aᴴ = (ctrl A)ᴴ := by
  simp only [ctrl,decoderGate,←parallelOracle_adjoint,lift_adjoint,raw_star]

theorem ctrl_one : ctrl (n:=n) (1 : Matrix (Reg m) (Reg m) ℂ) = 1 := by
  simp [ctrl,decoderGate,parallelOracle,parallel_select_one,lifted,raw]

private theorem phase_unit {J:Type} [Fintype J] [DecidableEq J] (f:J→ℂ) (h:∀ x,star (f x)*f x=1) :
    Matrix.diagonal f ∈ Matrix.unitaryGroup _ ℂ := by
  rw [Matrix.mem_unitaryGroup_iff',Matrix.star_eq_conjTranspose,Matrix.diagonal_conjTranspose,Matrix.diagonal_mul_diagonal]
  conv_rhs => rw [← Matrix.diagonal_one]
  congr 1; exact funext h

theorem phase (a b : Fin m) (f : Bool→Bool→ℂ) (hu : ∀ x y,star (f x y)*f x y=1) :
    Emits (ctrl (n:=n) (Matrix.diagonal (fun z => f (z a) (z b)))) 415440 := by
  rw [ctrl,raw_control_diag]
  by_cases eq : a=b
  · subst b
    exact weaken (single (.diagonalPair outer (dat a) (fun c x => if c then f x x else 1)
      (by
        intro c x
        cases c
        · simp
        · exact hu x x))) (by decide)
  have sep : dat (n:=n) a ≠ dat b := by simpa [dat] using eq
  let w := triple (outer : Addr n m) (dat a) (dat b) (by intro h; cases h) (by intro h; cases h) sep
  let d := fun v : Reg 3 => if v 0 then f (v 1) (v 2) else 1
  have unit := phase_unit d (fun x => by
    change star (if x 0 then f (x 1) (x 2) else 1)*(if x 0 then f (x 1) (x 2) else 1)=1
    split
    · exact hu _ _
    · simp)
  have hw := placed (three w (Matrix.diagonal d) unit)
  rw [place_diag] at hw
  exact hw

private def toff (u : Reg 3) : Reg 3 := Function.update u 2 (u 2 ^^ (u 0 && u 1))

private theorem toff_invol : Function.Involutive toff := by
  intro x; funext i; fin_cases i <;> simp [toff]

/-- A controlled CNOT inside the data register is a three-wire Toffoli. -/
theorem controlledCnot (a b : Fin m) (ne : a≠b) :
    Emits (ctrl (n:=n) (cnotGate m a b)) 415440 := by
  rw [ctrl,cnotGate,raw_control_perm]
  have sep : dat (n:=n) a ≠ dat b := by simpa [dat] using ne
  let w := triple (outer : Addr n m) (dat a) (dat b) (by intro h; cases h) (by intro h; cases h) sep
  let g := fun x : R n m => unpack.symm
    (x outer,x inner,x ∘ row,x ∘ col,if x outer then Function.update (x ∘ dat) b ((x ∘ dat) b ^^ (x ∘ dat) a) else x ∘ dat)
  have hw := placed (three w (permMatrix toff) (permMatrix_unitary toff_invol))
  have out (x : R n m) (i : Addr n m) (h : i∉Set.range w) : g x i=x i := by
    rcases i with (c | i); · cases c <;> rfl
    rcases i with (j | i); · rfl
    rcases i with (j | j); · rfl
    have prop : j≠b := by rintro rfl; exact h ⟨2,rfl⟩
    change (if x outer then Function.update (x ∘ dat) b ((x ∘ dat) b ^^ (x ∘ dat) a) else x ∘ dat) j=_
    cases flag : x outer
    · rfl
    · exact Function.update_of_ne prop _ _
  have sel (x : R n m) : g x ∘ w = toff (x ∘ w) := by
    funext i; fin_cases i
    · rfl
    · change (if x outer then Function.update (x ∘ dat) b ((x ∘ dat) b ^^ (x ∘ dat) a) else x ∘ dat) a=
        Function.update (x ∘ w) 2 ((x ∘ w) 2 ^^ ((x ∘ w) 0 && (x ∘ w) 1)) 1
      rw [Function.update_of_ne (by decide : (1:Fin 3)≠2)]
      split
      · exact Function.update_of_ne ne _ _
      · rfl
    · change (if x outer then Function.update (x ∘ dat) b ((x ∘ dat) b ^^ (x ∘ dat) a) else x ∘ dat) b=
        Function.update (x ∘ w) 2 ((x ∘ w) 2 ^^ ((x ∘ w) 0 && (x ∘ w) 1)) 2
      rw [Function.update_self]
      change _=(x (dat b) ^^ (x outer && x (dat a)))
      cases flag : x outer <;> simp [Function.comp_apply]
  rw [place_perm w toff g out sel] at hw
  exact hw


theorem code (g : FiniteGateCode) (leg : finiteCodeLegal m g=true) :
    Emits (ctrl (n:=n) (finiteCodeMatrix m g)) 415440 := by
  cases g with
  | h w =>
    have hw : w < m := by simpa [finiteCodeLegal] using leg
    rw [finiteCodeMatrix,dite_eq_left hw]
    exact weaken (single (.controlledWire _ _ hadamard_unitary)) (by decide)
  | x w =>
    have hw : w < m := by simpa [finiteCodeLegal] using leg
    rw [finiteCodeMatrix,dite_eq_left hw]
    exact weaken (single (.controlledWire _ _ pauliX_unitary)) (by decide)
  | t w =>
    have hw : w < m := by simpa [finiteCodeLegal] using leg
    rw [finiteCodeMatrix,dite_eq_left hw]
    exact weaken (single (.controlledWire _ _ tGate_mem_unitary)) (by decide)
  | tdg w =>
    have hw : w < m := by simpa [finiteCodeLegal] using leg
    rw [finiteCodeMatrix,dite_eq_left hw]
    exact weaken (single (.controlledWire _ _ tGateAdj_mem_unitary)) (by decide)
  | cx a b =>
    have hw : a<m ∧ b<m ∧ a≠b := by simpa [finiteCodeLegal] using leg
    rw [finiteCodeMatrix,dite_eq_left hw]
    exact controlledCnot _ _ (fun h => hw.2.2 (congrArg Fin.val h))

theorem localGate {V : Matrix (Reg m) (Reg m) ℂ} (h : Binary.Local m V) :
    Emits (ctrl (n:=n) V) 415440 := by
  induction h with
  | code g leg => exact code g leg
  | phase a b f hu => exact phase a b f hu
  | adj h ih => rw [ctrl_star]; exact adj ih

/-- An outer control, both address registers, and the second flag have been
included in the physical placement and gate count. -/
theorem decoder {V : Matrix (Reg m) (Reg m) ℂ} {q : ℕ} (h : Binary.Built V q) :
    Emits (ctrl (n:=n) V) (415440*q) := by
  obtain ⟨xs,len,elems,rfl⟩ := h
  apply weaken (k:=415440*xs.length) _ (Nat.mul_le_mul_left _ len)
  clear len
  induction xs with
  | nil => simpa only [List.prod_nil,ctrl_one,List.length_nil,Nat.mul_zero] using (empty (n:=n) (m:=m))
  | cons x xs ih =>
    have head := localGate (n:=n) (elems _ List.mem_cons_self)
    have tail := ih (fun a ha => elems _ (List.mem_cons_of_mem _ ha))
    rw [List.prod_cons,ctrl_mul]
    rw [List.length_cons,Nat.mul_succ,Nat.add_comm]
    exact concat head tail

end FQChemQatlib.Dynamics.LowChuang.SparseControl
