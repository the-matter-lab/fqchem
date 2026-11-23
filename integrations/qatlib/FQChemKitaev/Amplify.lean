module

public import FQChemKitaev.Wiring
public import FQChemKitaev.HistoryHamiltonian
import Mathlib.Tactic

/-!
# Three-copy amplification of a finite decision circuit

The compiler places three copies of any legal finite gate word on disjoint quantum
registers and adds the verified majority readout. Physical wire zero is the clean
answer wire. All gate addresses in the output are ordinary finite gate-code indices.
-/

@[expose] public section
noncomputable section

namespace FQChem.Complexity.Kitaev.Amplify

open Qatlib.Foundations.PureStateMath Qatlib.Foundations.QueryWordCore.Circuit
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open FQChem.Complexity.Kitaev.Wiring
open scoped Classical

variable {n : ℕ}

def copyWire (n : ℕ) (j : Fin 3) : Fin n ↪ Fin (3*n+1) where
  toFun i := (finProdFinEquiv (j,i)).succ
  inj' _ _ h := (Prod.mk.inj (finProdFinEquiv.injective (Fin.succ_injective _ h))).2

private theorem copy_ne {j k : Fin 3} (h : j ≠ k) (i l : Fin n) :
    copyWire n j i ≠ copyWire n k l :=
  fun eq => h (Prod.mk.inj (finProdFinEquiv.injective (Fin.succ_injective _ eq))).1

def readoutWires (o : Fin n) : Majority.Wires (3*n+1) where
  toFun := ![copyWire n 0 o, copyWire n 1 o, copyWire n 2 o, 0]
  inj' a b h := by
    fin_cases a <;> fin_cases b <;> first
      | rfl
      | exact False.elim (copy_ne (by decide) o o h)
      | exact False.elim ((Fin.succ_ne_zero _) h)
      | exact False.elim ((Fin.succ_ne_zero _) h.symm)

private def registers (n : ℕ) : Reg (3*n+1) ≃ (Fin 3 → Reg n) × Bool where
  toFun x := (fun j => x ∘ copyWire n j, x 0)
  invFun z := Fin.cases z.2 (fun i => z.1 (finProdFinEquiv.symm i).1 (finProdFinEquiv.symm i).2)
  left_inv x := by
    funext i
    refine Fin.cases ?_ (fun i => ?_) i
    · rfl
    · change x (finProdFinEquiv (finProdFinEquiv.symm i)).succ = x i.succ
      rw [Equiv.apply_symm_apply]
  right_inv x := by
    obtain ⟨v,b⟩ := x
    ext j i
    · change v (finProdFinEquiv.symm (finProdFinEquiv (j,i))).1
        (finProdFinEquiv.symm (finProdFinEquiv (j,i))).2 = v j i
      rw [Equiv.symm_apply_apply]
    · rfl

private def regroup (I : Type) : ((Fin 3 → Bool × I) × Bool) ≃ Majority.Blocks I where
  toFun x := (((x.1 0).1, (x.1 1).1, (x.1 2).1), ((x.1 0).2, (x.1 1).2, (x.1 2).2), x.2)
  invFun x := (![(x.1.1,x.2.1.1), (x.1.2.1,x.2.1.2.1), (x.1.2.2,x.2.1.2.2)], x.2.2)
  left_inv x := by
    rcases x with ⟨v,b⟩
    refine Prod.ext ?_ rfl
    funext j
    fin_cases j <;> rfl
  right_inv _ := rfl

abbrev Work (o : Fin n) := {j : Fin n // j ≠ o} → Bool

private def layout (o : Fin n) : Reg (3*n+1) ≃ Majority.Blocks (Work o) :=
  (registers n).trans (((Equiv.piCongrRight fun _ : Fin 3 => Equiv.funSplitAt o Bool).prodCongr
    (Equiv.refl Bool)).trans (regroup (Work o)))

private def joint (v₀ v₁ v₂ : QState (Reg n)) : QState (Reg (3*n+1)) := fun x =>
  v₀ (x ∘ copyWire n 0) * v₁ (x ∘ copyWire n 1) * v₂ (x ∘ copyWire n 2) *
    (Qatlib.Foundations.PureStateMath.Ket false (x 0))

private theorem joint_run (gs : List FiniteGateCode) (legal : finiteWordLegal n gs = true)
    (v₀ v₁ v₂ : QState (Reg n)) :
    let A := fun j => finiteCodeCircuit (3*n+1) (onWires (copyWire n j) gs)
    let U := Run 1 (finiteCodeCircuit n gs)
    Run 1 (A 2) (Run 1 (A 1) (Run 1 (A 0) (joint v₀ v₁ v₂))) =
      joint (U v₀) (U v₁) (U v₂) := by
  let out : QState (Reg (3*n+1)) := fun x => Ket false (x 0)
  have clean (j : Fin 3) : OffWires (copyWire n j) out := by
    intro x i b
    have h : (0 : Fin (3*n+1)) ≠ copyWire n j i := Fin.ne_of_lt (Fin.succ_pos _)
    simp [out, Function.update_of_ne h]
  have other (v : QState (Reg n)) (j k : Fin 3) (h : j ≠ k) :
      OffWires (copyWire n j) (fun x => v (x ∘ copyWire n k)) := by
    intro x i b
    dsimp only
    rw [Function.update_comp_eq_of_forall_ne x b (fun l => (copy_ne h i l).symm)]
  have mult (j : Fin 3) {f g : QState (Reg (3*n+1))}
      (hf : OffWires (copyWire n j) f) (hg : OffWires (copyWire n j) g) :
      OffWires (copyWire n j) (fun x => f x * g x) := fun x i b => by dsimp only; rw [hf x i b, hg x i b]
  let U := Run 1 (finiteCodeCircuit n gs)
  have repr₀ (a b c : QState (Reg n)) : joint a b c = extendState (copyWire n 0) a
      (fun x => (b (x ∘ copyWire n 1) * c (x ∘ copyWire n 2)) * out x) := by
    funext x
    unfold joint extendState out
    ring
  have repr₁ (a b c : QState (Reg n)) : joint a b c = extendState (copyWire n 1) b
      (fun x => (a (x ∘ copyWire n 0) * c (x ∘ copyWire n 2)) * out x) := by
    funext x
    unfold joint extendState out
    ring
  have repr₂ (a b c : QState (Reg n)) : joint a b c = extendState (copyWire n 2) c
      (fun x => (a (x ∘ copyWire n 0) * b (x ∘ copyWire n 1)) * out x) := by
    funext x
    unfold joint extendState out
    ring
  have step₀ (a b c : QState (Reg n)) :
      Run 1 (finiteCodeCircuit _ (onWires (copyWire n 0) gs)) (joint a b c) = joint (U a) b c := by
    rw [repr₀, onWires_run _ _ legal _ _ (mult _ (mult _ (other b 0 1 (by decide))
      (other c 0 2 (by decide))) (clean 0)), repr₀]
  have step₁ (a b c : QState (Reg n)) :
      Run 1 (finiteCodeCircuit _ (onWires (copyWire n 1) gs)) (joint a b c) = joint a (U b) c := by
    rw [repr₁, onWires_run _ _ legal _ _ (mult _ (mult _ (other a 1 0 (by decide))
      (other c 1 2 (by decide))) (clean 1)), repr₁]
  have step₂ (a b c : QState (Reg n)) :
      Run 1 (finiteCodeCircuit _ (onWires (copyWire n 2) gs)) (joint a b c) = joint a b (U c) := by
    rw [repr₂, onWires_run _ _ legal _ _ (mult _ (mult _ (other a 2 0 (by decide))
      (other b 2 1 (by decide))) (clean 2)), repr₂]
  dsimp only
  rw [step₀, step₁, step₂]

/-- Three disjoint address-rewritten copies followed by the 45-gate majority readout. -/
def word (o : Fin n) (gs : List FiniteGateCode) : List FiniteGateCode :=
  onWires (copyWire n 0) gs ++ onWires (copyWire n 1) gs ++ onWires (copyWire n 2) gs ++
    Majority.word (readoutWires o)

theorem word_length (o : Fin n) (gs : List FiniteGateCode) :
    (word o gs).length = 3*gs.length + 45 := by simp [word, Majority.word_length, onWires_length]; omega

theorem word_legal (o : Fin n) (gs : List FiniteGateCode) (legal : finiteWordLegal n gs = true) :
    finiteWordLegal (3*n+1) (word o gs) = true := by
  unfold word finiteWordLegal
  simp only [List.all_append]
  change (finiteWordLegal _ _ && finiteWordLegal _ _ && finiteWordLegal _ _ && finiteWordLegal _ _) = true
  simp [onWires_legal _ _ legal, Majority.word_legal]

private theorem joint_zero :
    joint (Ket (ZeroStr n)) (Ket (ZeroStr n)) (Ket (ZeroStr n)) = Ket (ZeroStr (3*n+1)) := by
  funext x
  have criterion : x = ZeroStr (3*n+1) ↔
      x ∘ copyWire n 0 = ZeroStr n ∧ x ∘ copyWire n 1 = ZeroStr n ∧
      x ∘ copyWire n 2 = ZeroStr n ∧ x 0 = false := by
    constructor
    · rintro rfl
      exact ⟨rfl,rfl,rfl,rfl⟩
    · rintro ⟨a,b,c,t⟩
      apply (registers n).injective
      refine Prod.ext ?_ t
      funext j
      fin_cases j
      · exact a
      · exact b
      · exact c
  simp only [joint, Qatlib.Foundations.PureStateMath.Ket, criterion]
  split_ifs <;> simp_all

private theorem joint_product (o : Fin n) (v : QState (Reg n)) :
    joint v v v = fun x => Majority.productAmplitude
      (fun b i => v ((Equiv.funSplitAt o Bool).symm (b,i))) (layout o x) := by
  funext x
  let split := Equiv.funSplitAt o Bool
  change v (x ∘ copyWire n 0) * v (x ∘ copyWire n 1) * v (x ∘ copyWire n 2) * Ket false (x 0) =
    if x 0 then 0 else
      v (split.symm (split (x ∘ copyWire n 0))) *
      v (split.symm (split (x ∘ copyWire n 1))) *
      v (split.symm (split (x ∘ copyWire n 2)))
  cases h : x 0 <;> simp [Qatlib.Foundations.PureStateMath.Ket]

def accept (o : Fin n) (gs : List FiniteGateCode) : ℝ :=
  MeasureProb (Run 1 (finiteCodeCircuit n gs) (Ket (ZeroStr n))) (Finset.univ.filter fun x => x o)

/-- Starting from all-zero wires, the actual compiled circuit accepts with exactly
the classical cubic-majority probability computed from the source circuit. -/
theorem word_accept (o : Fin n) (gs : List FiniteGateCode) (legal : finiteWordLegal n gs = true) :
    accept (0 : Fin (3*n+1)) (word o gs) = 3 * (accept o gs)^2 - 2 * (accept o gs)^3 := by
  let v := Run 1 (finiteCodeCircuit n gs) (Ket (ZeroStr n))
  let split := Equiv.funSplitAt o Bool
  let u := fun (b : Bool) (i : Work o) => v (split.symm (b,i))
  have hv : Normalized v := ((finite_gate_description_rejection_unitarity_and_counts n gs).2 legal).1.normalized_run
    (Matrix.unitaryGroup _ ℂ).one_mem (normalized_ket _)
  have hu : (∑ b : Bool, ∑ i, ‖u b i‖^2) = 1 := by
    exact (Fintype.sum_prod_type (fun y : Bool × Work o => ‖v (split.symm y)‖^2)).symm.trans
      ((split.symm.sum_comp (fun x => ‖v x‖^2)).trans hv)
  have hp : (∑ i, ‖u true i‖^2) = accept o gs := by
    unfold accept
    change _ = MeasureProb v _
    rw [MeasureProb, Finset.sum_filter]
    change _ = ∑ i, if i o then ‖v i‖^2 else 0
    have h := split.symm.sum_comp (fun x => if x o then ‖v x‖^2 else 0)
    calc
      _ = ∑ y : Bool × Work o, if y.1 then ‖v (split.symm y)‖^2 else 0 := by
        simp [Fintype.sum_prod_type, u]
      _ = _ := by
        convert h using 1
        apply Finset.sum_congr rfl
        intro y _
        have hy : (split.symm y) o = y.1 := congrArg Prod.fst (split.apply_symm_apply y)
        rw [hy]
  have amplified := Majority.three_copy_readout (readoutWires o) (layout o)
    (fun _ => rfl) (fun _ => rfl) u hu
  dsimp only at amplified
  rw [hp] at amplified
  unfold accept
  simp only [word, finiteCodeCircuit, List.map_append, run_append]
  change MeasureProb (Run 1 (finiteCodeCircuit _ (Majority.word (readoutWires o)))
    (Run 1 (finiteCodeCircuit _ (onWires (copyWire n 2) gs))
      (Run 1 (finiteCodeCircuit _ (onWires (copyWire n 1) gs))
        (Run 1 (finiteCodeCircuit _ (onWires (copyWire n 0) gs)) (Ket (ZeroStr (3*n+1))))))) _ = _
  rw [← joint_zero, joint_run gs legal, joint_product o]
  exact amplified

open Qatlib.Concepts.QmaCompleteness.HistoryHam

/-- One amplification level of a witness-free history circuit, overwriting the
initialization mask with the all-zero mask and selecting the new majority output. -/
def step (C : QmaHistoryCircuit) : QmaHistoryCircuit where
  qubits := 3*C.qubits + 1
  gates := word C.outputWire C.gates
  legal := word_legal C.outputWire C.gates C.legal
  initZeroWires := Finset.univ
  outputWire := 0

def repeatCircuit (C : QmaHistoryCircuit) : ℕ → QmaHistoryCircuit
  | 0 => C
  | k+1 => step (repeatCircuit C k)

theorem repeat_gate_count (C : QmaHistoryCircuit) (k : ℕ) :
    (repeatCircuit C (k+1)).gates.length = 3*(repeatCircuit C k).gates.length + 45 :=
  word_length _ _

theorem repeat_width (C : QmaHistoryCircuit) (k : ℕ) :
    (repeatCircuit C (k+1)).qubits = 3*(repeatCircuit C k).qubits + 1 := rfl

theorem repeat_all_zero (C : QmaHistoryCircuit) (k : ℕ) :
    (repeatCircuit C (k+1)).initZeroWires = Finset.univ := rfl

def zeroAcceptance (C : QmaHistoryCircuit) : ℝ := qmaHistoryAcceptProb C (Ket (ZeroStr C.qubits))

theorem zeroAcceptance_mem (C : QmaHistoryCircuit) :
    zeroAcceptance C ∈ Set.Icc (0 : ℝ) 1 := by
  refine ⟨measureProb_nonneg _ _, ?_⟩
  exact Qatlib.Foundations.BornMetrics.EventProbability.measureProb_le_one
    (((finite_gate_description_rejection_unitarity_and_counts _ _).2 C.legal).1.normalized_run
      (Matrix.unitaryGroup _ ℂ).one_mem (normalized_ket _)) _

theorem step_accept (C : QmaHistoryCircuit) :
    zeroAcceptance (step C) = 3*(zeroAcceptance C)^2 - 2*(zeroAcceptance C)^3 :=
  word_accept C.outputWire C.gates C.legal

theorem repeat_accept (C : QmaHistoryCircuit) (k : ℕ) :
    zeroAcceptance (repeatCircuit C k) = Majority.repeatedError (zeroAcceptance C) k := by
  induction k with
  | zero => rfl
  | succ k ih => rw [repeatCircuit, step_accept, ih, Majority.repeatedError]

theorem repeat_reject (C : QmaHistoryCircuit) (k : ℕ) :
    1 - zeroAcceptance (repeatCircuit C k) = Majority.repeatedError (1 - zeroAcceptance C) k := by
  induction k with
  | zero => rfl
  | succ k ih =>
    rw [repeatCircuit, step_accept, Majority.repeatedError, ← ih]
    ring

end FQChem.Complexity.Kitaev.Amplify
