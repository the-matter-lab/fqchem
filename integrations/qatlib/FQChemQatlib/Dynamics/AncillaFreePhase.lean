module

public import FQChemQatlib.Dynamics.HalvedIncrement
public import FQChemQatlib.Dynamics.SingletonPhaseGradient
public import Qatlib.Concepts.QmaCompleteness.HistoryHam.QmaCompletenessDefs
import Mathlib.Tactic

/-! # An exact linear-size ancilla-free multi-controlled phase

Use the target itself as the one borrowed wire for addition on the controls.
The phase gradients use individually addressed one- and two-qubit phase gates.
No gate word assumes the target is in a particular state.

See [Gidney, §2.10 and Fig. 21](https://arxiv.org/abs/1706.07884) and [Using Quantum Gates instead of Ancilla Bits](https://algassert.com/circuits/2015/06/22/Using-Quantum-Gates-instead-of-Ancilla-Bits.html) for increment-based phase synthesis, and [Huang and Palsberg, §4](https://doi.org/10.1145/3656436) for an alternative construction with explicit primitive counts.
-/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.AncillaFreePhase

open Matrix BorrowedControls BorrowedRipple DirtyIncrement HalvedIncrement
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Foundations.PureStateMath (ApplyGate)
open SingletonPhaseGradient (phase)
variable {n : ℕ}
abbrev M (n : ℕ) := Matrix (Reg n) (Reg n) ℂ

/-- Computational-basis action with a possibly input-dependent phase angle. -/
def mono (f : Reg n → Reg n) (a : Reg n → ℝ) : M n :=
  fun i j => if i=f j then phase (a j) else 0

theorem chain (f g : Reg n → Reg n) (a b : Reg n → ℝ) :
    mono g b * mono f a = mono (g ∘ f) (fun s => a s+b (f s)) := by
  ext i j
  rw [Matrix.mul_apply,Finset.sum_eq_single (f j)]
  · by_cases e : i=g (f j) <;> simp [mono,e,SingletonPhaseGradient.phase_add,mul_comm]
  · intro x _ ne; simp [mono,ne]
  · simp

theorem monoIdentity : mono (id : Reg n → Reg n) (fun _ => 0)=1 := by
  ext i j
  by_cases e : i=j <;> simp [mono,Matrix.one_apply,e,SingletonPhaseGradient.phase]

def phaseGate (t : W n) (c : Option (W n)) (θ : ℝ) : M n :=
  mono id (fun s => if s t && enabled c s then θ else 0)

/-- Every allowed primitive is a legal finite one- or two-wire instruction,
or an addressed one- or two-wire diagonal phase on the target. -/
inductive Local (t : W n) (cs : List (W n)) : M n → Prop
  | code (g : FiniteGateCode) (hg : finiteCodeLegal n g=true) : Local t cs (finiteCodeMatrix n g)
  | angle (c : Option (W n)) (inside : ∀i∈c,i∈cs) (θ : ℝ) : Local t cs (phaseGate t c θ)

def Emits (t : W n) (cs : List (W n)) (A : M n) (k : ℕ) :=
  ∃ gs : List (M n), gs.length≤k ∧ (∀g∈gs, Local t cs g) ∧ gs.prod=A

private theorem single {t : W n} {cs} {A} (ok : Local t cs A) : Emits t cs A 1 :=
  ⟨[A],by simp,by simpa using ok,by simp⟩

private theorem compose {t : W n} {cs} {A B} {k l} (a : Emits t cs A k) (b : Emits t cs B l) :
    Emits t cs (B*A) (k+l) := by
  obtain ⟨u,hu,lu,rfl⟩ := a; obtain ⟨v,hv,lv,rfl⟩ := b
  exact ⟨v++u,by simp; omega,fun g h => (List.mem_append.mp h).elim (lv g) (lu g),by simp⟩

private theorem followed {t : W n} {cs} {f g : Reg n → Reg n} {a b : Reg n → ℝ} {k l}
    (u : Emits t cs (mono f a) k) (v : Emits t cs (mono g b) l) :
    Emits t cs (mono (g ∘ f) (fun s => a s+b (f s))) (k+l) :=
  chain f g a b ▸ compose u v

theorem finiteCertificate {f : Reg n → Reg n} {k} (impl : Implements f k) :
    ∃ word, word.length≤k ∧ finiteWordLegal n word=true ∧ finiteWordMatrix n word=mono f (fun _ => 0) := by
  obtain ⟨word,l,ok,act⟩ := impl
  have decode : finiteWordMatrix n word = mono f (fun _ => 0) := by
    ext s v
    have col := congrFun (act v) s
    rw [run_finiteCodeCircuit] at col
    simp [Matrix.mulVec,dotProduct,Qatlib.Foundations.PureStateMath.Ket] at col
    simpa [mono,SingletonPhaseGradient.phase] using col
  exact ⟨word,l,ok,decode⟩

theorem reverseProduct (word : List FiniteGateCode) :
    (word.map (finiteCodeMatrix n)).reverse.prod=finiteWordMatrix n word := by
  induction word with
  | nil => simp [finiteWordMatrix]
  | cons j js ih => simp [finiteWordMatrix,ih]

private theorem classicalWord (t : W n) (cs : List (W n)) {f : Reg n → Reg n} {k}
    (impl : Implements f k) : Emits t cs (mono f (fun _ => 0)) k := by
  obtain ⟨word,l,ok,decode⟩ := finiteCertificate impl
  rw [← decode]
  refine ⟨(word.map (finiteCodeMatrix n)).reverse,by simpa using l,?_,?_⟩
  · intro g mem
    obtain ⟨j,hj,rfl⟩ := List.mem_map.mp (List.mem_reverse.mp mem)
    exact Local.code _ ((List.all_eq_true.mp ok) _ hj)
  · exact reverseProduct word

private theorem grad (t : W n) (cs ds : List (W n)) (inside : ∀i∈ds, i∈cs) (step : ℝ) :
    Emits t cs (mono id (fun s => if s t then BorrowedRipple.read s ds*step else 0)) ds.length := by
  induction ds generalizing step with
  | nil => refine ⟨[],by simp,by simp,?_⟩; simpa [BorrowedRipple.read] using (monoIdentity (n:=n)).symm
  | cons i ds ih =>
    have gate := single (Local.angle (t:=t) (cs:=cs) (some i)
      (fun a e => inside a (by have := Option.mem_some_iff.mp e; simp_all)) step)
    have rest := ih (fun a h => inside a (by simp [h])) (2*step)
    have together := followed (a:=fun (s : Reg n) => if s t && enabled (some i) s then step else 0) gate rest
    have eq (s : Reg n) :
        (if s t && enabled (some i) s then step else 0)+(if s t then BorrowedRipple.read s ds*(2*step) else 0) =
        (if s t then (BorrowedRipple.read s (i::ds):ℝ)*step else 0) := by
      cases hb : s t <;> cases hi : s i <;> simp [enabled,hi,BorrowedRipple.read] <;> ring
    simpa only [Function.comp_id,id_eq,eq,List.length_cons,Nat.add_comm 1 ds.length] using together

set_option maxRecDepth 8192 in
/-- On n physical wires, a k-controlled phase of any real angle uses at most
2·720(k+3)+2k+1 local gates, even when the k controls and target exhaust n.
The circuit matrix is exact on every basis column and hence on superpositions. -/
theorem multiControlledPhase (t : W n) (cs : List (W n)) (nd : (t::cs).Nodup) (θ : ℝ) :
    Emits t cs (Matrix.diagonal (fun s => if s t && cs.all s then phase θ else 1))
      (2*(720*(cs.length+3))+2*cs.length+1) := by
  let k := cs.length
  let step := θ/(2:ℝ)^k
  obtain ⟨f,imp,stay,add⟩ := oneDirty cs t nd
  obtain ⟨inv,back,L,_⟩ := inverseWord imp
  have first := single (Local.angle (t:=t) (cs:=cs) none (by simp) step)
  have grads := grad t cs cs (by simp) step
  have neg := grad t cs cs (by simp) (-step)
  have I := classicalWord t cs imp
  have D := classicalWord t cs back
  have word := followed (followed (followed (followed
    (a:=fun (s : Reg n) => if s t && enabled none s then step else 0) first grads) I) neg) D
  have bound : 1+k+720*(k+3)+k+720*(k+3)=2*(720*(k+3))+2*k+1 := by omega
  clear I D
  convert word using 1
  · ext i j
    have same := stay j t (List.nodup_cons.mp nd).1
    have inc := modular_read (add j)
    simp only [enabled,Option.elim_none,ite_true] at inc
    have wrap := all_max j cs
    have angle : (if j t then step else 0)+(if j t then (BorrowedRipple.read j cs:ℝ)*step else 0)+
        (if j t then (BorrowedRipple.read (f j) cs:ℝ)*(-step) else 0) =
        (if j t && cs.all j then θ else 0) := by
      cases h : j t with
      | false => simp
      | true =>
        simp only [ite_true,Bool.true_and]
        by_cases c : cs.all j=true
        · have endword := wrap.mp c
          rw [ite_eq_left c]
          rw [ite_eq_left endword] at inc
          have er : (BorrowedRipple.read j cs:ℝ)+1=(2:ℝ)^k := by exact_mod_cast endword
          rw [inc]; simp only [Nat.cast_zero,zero_mul,add_zero]; dsimp [step]; field_simp; nlinarith only [congrArg (·*θ) er]
        · rw [ite_eq_right c]
          rw [ite_eq_right (mt wrap.mpr c)] at inc
          rw [inc]; push_cast; ring
    simp only [mono,Function.comp_apply,id_eq,L j,Matrix.diagonal_apply,enabled,Option.elim_none,
      Bool.and_true,add_zero,same,angle]
    by_cases eq : i=j
    · subst i
      simp only [ite_true]
      split <;> simp_all [SingletonPhaseGradient.phase]
    · simp [eq]
  · omega

end FQChemQatlib.Dynamics.AncillaFreePhase
