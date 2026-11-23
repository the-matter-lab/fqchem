module

public import Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermal.FiniteThermalToffoli
public import Qatlib.Concepts.QmaCompleteness.HistoryHam.QmaCompletenessDefs
import Mathlib.Tactic

/-!
# Coherent majority readout for three copies

A circuit over Qatlib's finite Clifford+T gate vocabulary writes the majority of
three designated bits into a clean output wire. All three input wires and arbitrary
other work registers are preserved on basis states. The probability formula uses
independence of the three measured bits and allows an arbitrary joint work state
consistent with that distribution.

The compiled fifteen-gate Toffoli word and its basis theorem are from
[Qatlib Contributors](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/FiniteThermal/FiniteThermalToffoli.lean).
-/

@[expose] public section
noncomputable section

namespace FQChem.Complexity.Kitaev.Majority

open Qatlib.Foundations.QueryWordCore.Circuit Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermalCircuits
open Qatlib.Concepts.QmaCompleteness.HistoryHam
open scoped Classical

abbrev Pattern := Bool × Bool × Bool

def vote (p : Pattern) : Bool :=
  (p.1 && p.2.1) || (p.1 && p.2.2) || (p.2.1 && p.2.2)

/-- Four pairwise distinct wires. Indices 0, 1 and 2 hold the votes, and 3 the readout. -/
abbrev Wires (n : ℕ) := Fin 4 ↪ Fin n

def readVotes {n : ℕ} (w : Wires n) (x : Reg n) : Pattern := (x (w 0), x (w 1), x (w 2))

def toggle {n : ℕ} (w : Wires n) (x : Reg n) : Reg n :=
  Function.update x (w 3) (x (w 3) ^^ vote (readVotes w x))

private theorem distinct {n : ℕ} (w : Wires n) {a b : Fin 4} (h : a ≠ b) : w a ≠ w b :=
  w.injective.ne h

private theorem read_toggle {n : ℕ} (w : Wires n) (x : Reg n) :
    readVotes w (toggle w x) = readVotes w x := by
  simp [readVotes, toggle, Function.update_of_ne, distinct w (show (0 : Fin 4) ≠ 3 by decide),
    distinct w (show (1 : Fin 4) ≠ 3 by decide), distinct w (show (2 : Fin 4) ≠ 3 by decide)]

private theorem involution {n : ℕ} (w : Wires n) : Function.Involutive (toggle w) := by
  intro x
  rw [toggle, read_toggle]
  simp [toggle, Function.update_idem]

def word {n : ℕ} (w : Wires n) : List FiniteGateCode :=
  thermalToffoliWord (w 0) (w 1) (w 3) ++ thermalToffoliWord (w 0) (w 2) (w 3) ++
    thermalToffoliWord (w 1) (w 2) (w 3)

theorem word_length {n : ℕ} (w : Wires n) : (word w).length = 45 := rfl

private theorem toffoli_legal {n : ℕ} (a b t : Fin n) (hab : a ≠ b) (hat : a ≠ t) (hbt : b ≠ t) :
    finiteWordLegal n (thermalToffoliWord a b t) = true := by
  have ab : a.val ≠ b.val := fun h => hab (Fin.ext h)
  have at' : a.val ≠ t.val := fun h => hat (Fin.ext h)
  have bt : b.val ≠ t.val := fun h => hbt (Fin.ext h)
  simp [thermalToffoliWord, finiteWordLegal, finiteCodeLegal, ab, at', bt]

theorem word_legal {n : ℕ} (w : Wires n) : finiteWordLegal n (word w) = true := by
  unfold word finiteWordLegal
  simp only [List.all_append]
  change (finiteWordLegal _ _ && finiteWordLegal _ _ && finiteWordLegal _ _) = true
  simp only [Bool.and_eq_true]
  exact ⟨⟨toffoli_legal _ _ _ (distinct w (by decide)) (distinct w (by decide)) (distinct w (by decide)),
    toffoli_legal _ _ _ (distinct w (by decide)) (distinct w (by decide)) (distinct w (by decide))⟩,
    toffoli_legal _ _ _ (distinct w (by decide)) (distinct w (by decide)) (distinct w (by decide))⟩

private theorem toffoli_run {n : ℕ} (a b t : Fin n) (hab : a ≠ b) (hat : a ≠ t) (hbt : b ≠ t)
    (x : Reg n) :
    Run 1 (finiteCodeCircuit n (thermalToffoliWord a b t)) (Ket x) =
      Ket (Function.update x t (x t ^^ (x a && x b))) := by
  have h := (thermalToffoliWord_exact n a b t hab hat hbt x).1
  simpa [finiteWordRun, toffoli_legal a b t hab hat hbt] using h

theorem word_ket {n : ℕ} (w : Wires n) (x : Reg n) :
    Run 1 (finiteCodeCircuit n (word w)) (Ket x) = Ket (toggle w x) := by
  simp only [word, finiteCodeCircuit, List.map_append, run_append]
  change Run 1 (finiteCodeCircuit n (thermalToffoliWord _ _ _))
    (Run 1 (finiteCodeCircuit n (thermalToffoliWord _ _ _))
      (Run 1 (finiteCodeCircuit n (thermalToffoliWord _ _ _)) (Ket x))) = _
  rw [toffoli_run _ _ _ (distinct w (by decide)) (distinct w (by decide)) (distinct w (by decide)),
    toffoli_run _ _ _ (distinct w (by decide)) (distinct w (by decide)) (distinct w (by decide)),
    toffoli_run _ _ _ (distinct w (by decide)) (distinct w (by decide)) (distinct w (by decide))]
  simp only [Function.update_self, Function.update_idem,
    Function.update_of_ne (distinct w (show (0 : Fin 4) ≠ 3 by decide)),
    Function.update_of_ne (distinct w (show (1 : Fin 4) ≠ 3 by decide)),
    Function.update_of_ne (distinct w (show (2 : Fin 4) ≠ 3 by decide))]
  unfold toggle readVotes vote
  cases x (w 0) <;> cases x (w 1) <;> cases x (w 2) <;> cases x (w 3) <;> rfl

/-- On an arbitrary superposition, the word permutes the amplitudes coherently. -/
theorem word_amplitude {n : ℕ} (w : Wires n) (ψ : QState (Reg n)) (y : Reg n) :
    Run 1 (finiteCodeCircuit n (word w)) ψ y = ψ (toggle w y) := by
  have basis (x : Reg n) := word_ket w x
  simp only [run_finiteCodeCircuit] at basis ⊢
  have expansion : ψ = ∑ x, ψ x • Ket x := by
    funext i
    simp [Qatlib.Foundations.PureStateMath.Ket, Finset.sum_apply]
  conv_lhs => rw [expansion, Matrix.mulVec_sum]
  simp only [Matrix.mulVec_smul, basis, Finset.sum_apply, Pi.smul_apply, smul_eq_mul]
  rw [Finset.sum_eq_single (toggle w y)]
  · simp [involution w y, Qatlib.Foundations.PureStateMath.Ket]
  · intro x _ hx
    have h : toggle w x ≠ y := fun he => hx ((involution w x).symm.trans (congrArg (toggle w) he))
    simp [Qatlib.Foundations.PureStateMath.Ket, Ne.symm h]
  · simp

def patternMass {n : ℕ} (w : Wires n) (ψ : QState (Reg n)) (p : Pattern) : ℝ :=
  ∑ x, if readVotes w x = p then BornProb ψ x else 0

/-- An input with clean readout has the same majority-event probability as the
probability of reading one after the compiled word. -/
theorem readout_probability {n : ℕ} (w : Wires n) (ψ : QState (Reg n))
    (clean : ∀ x : Reg n, x (w 3) = true → ψ x = 0) :
    MeasureProb (Run 1 (finiteCodeCircuit n (word w)) ψ) (Finset.univ.filter fun x => x (w 3)) =
      ∑ p : Pattern, if vote p then patternMass w ψ p else 0 := by
  let e := (involution w).toPerm (toggle w)
  rw [MeasureProb, Finset.sum_filter]
  simp only [BornProb, word_amplitude]
  rw [← e.sum_comp]
  case hs => intro _ _; exact Finset.mem_univ _
  change (∑ x : Reg n, if toggle w x (w 3) = true then ‖ψ (toggle w (toggle w x))‖^2 else 0) = _
  simp_rw [show ∀ x, toggle w (toggle w x) = x from involution w]
  calc
    _ = ∑ x : Reg n, if vote (readVotes w x) then BornProb ψ x else 0 := by
      apply Finset.sum_congr rfl
      intro x _
      cases hx : x (w 3) <;> simp [toggle, hx, BornProb, clean x]
    _ = _ := by
      have distribute (p : Pattern) :
          (if vote p then patternMass w ψ p else 0) =
          ∑ x, if readVotes w x = p then (if vote p then BornProb ψ x else 0) else 0 := by
        cases vote p <;> simp [patternMass]
      simp_rw [distribute]
      rw [Finset.sum_comm (s := (Finset.univ : Finset Pattern))]
      apply Finset.sum_congr rfl
      intro x _
      rw [Finset.sum_eq_single (readVotes w x)]
      · simp
      · intro y _ hy
        simp [Ne.symm hy]
      · simp

def bitMass (p : ℝ) (b : Bool) : ℝ := if b then p else 1-p

/-- With independent votes having common probability `p` of being one, a clean
readout returns one with probability `3p²−2p³`. Work qubits may be present. -/
theorem independent_votes {n : ℕ} (w : Wires n) (ψ : QState (Reg n)) (p : ℝ)
    (clean : ∀ x : Reg n, x (w 3) = true → ψ x = 0)
    (independent : ∀ q : Pattern, patternMass w ψ q =
      bitMass p q.1 * bitMass p q.2.1 * bitMass p q.2.2) :
    MeasureProb (Run 1 (finiteCodeCircuit n (word w)) ψ) (Finset.univ.filter fun x => x (w 3)) =
      3*p^2 - 2*p^3 := by
  rw [readout_probability w ψ clean]
  simp [Fintype.sum_prod_type, vote, bitMass, independent]
  ring

/-- Coordinate layout for three measured bits, their respective workspaces and one readout bit. -/
abbrev Blocks (I : Type) := Pattern × (I × I × I) × Bool

/-- Three independent copies of the same bit-and-workspace state, with a zero readout. -/
def productAmplitude {I : Type} (v : Bool → I → ℂ) (z : Blocks I) : ℂ :=
  if z.2.2 then 0 else
    v z.1.1 z.2.1.1 * v z.1.2.1 z.2.1.2.1 * v z.1.2.2 z.2.1.2.2

private theorem productMass {I : Type} [Fintype I] (v : Bool → I → ℂ) (q : Pattern) :
    (∑ z : Blocks I, if z.1 = q then ‖productAmplitude v z‖^2 else 0) =
    (∑ i, ‖v q.1 i‖^2) * (∑ i, ‖v q.2.1 i‖^2) * (∑ i, ‖v q.2.2 i‖^2) := by
  simp only [Fintype.sum_prod_type (α₁ := Pattern), Finset.sum_ite_irrel,
    Finset.sum_const_zero, Finset.sum_ite_eq', Finset.mem_univ, ite_true]
  simp [Fintype.sum_prod_type, productAmplitude, mul_pow, ← Finset.mul_sum, ← Finset.sum_mul]

/-- Starting with three independent copies of an arbitrary normalized bit-and-workspace
state, the compiled majority readout gives the cubic amplification law. The equivalence
only specifies where the bits and work registers are stored on the physical wires. -/
theorem three_copy_readout {n : ℕ} {I : Type} [Fintype I] (w : Wires n)
    (layout : Reg n ≃ Blocks I) (votes : ∀ x, readVotes w x = (layout x).1)
    (out : ∀ x, x (w 3) = (layout x).2.2) (v : Bool → I → ℂ)
    (unit : (∑ b : Bool, ∑ i, ‖v b i‖^2) = 1) :
    let p := ∑ i, ‖v true i‖^2
    MeasureProb (Run 1 (finiteCodeCircuit n (word w)) (fun x => productAmplitude v (layout x)))
      (Finset.univ.filter fun x => x (w 3)) = 3*p^2 - 2*p^3 := by
  dsimp only
  apply independent_votes
  · intro x h
    simp [productAmplitude, ← out, h]
  · intro q
    have marg (b : Bool) : (∑ i, ‖v b i‖^2) = bitMass (∑ i, ‖v true i‖^2) b := by
      cases b
      · rw [Fintype.sum_bool] at unit
        simp only [bitMass, Bool.false_eq_true, ite_false]
        linarith
      · simp [bitMass]
    unfold patternMass
    simp only [votes, BornProb]
    exact (layout.sum_comp (fun z => if z.1 = q then ‖productAmplitude v z‖^2 else 0)).trans
      ((productMass v q).trans (by rw [marg q.1, marg q.2.1, marg q.2.2]))

/-- Majority treats the two answers symmetrically. -/
theorem failure_probability (p : ℝ) : 1 - (3*(1-p)^2 - 2*(1-p)^3) = 3*p^2 - 2*p^3 := by ring

/-- Independent-majority error recurrence, for either value of the correct answer. -/
def repeatedError (p : ℝ) : ℕ → ℝ
  | 0 => p
  | k+1 => 3*(repeatedError p k)^2 - 2*(repeatedError p k)^3

/-- With bounded-error input, each majority level contracts the error by at least
a factor of 7/9. Three levels therefore reduce it by more than a factor of two. -/
theorem error_bound (p : ℝ) (lo : 0 ≤ p) (hi : p ≤ 1/3) (k : ℕ) :
    0 ≤ repeatedError p k ∧ repeatedError p k ≤ p * (7/9)^k := by
  induction k with
  | zero => simpa [repeatedError] using lo
  | succ k ih =>
    let x := repeatedError p k
    have hx : 0 ≤ x := ih.1
    have bound : x ≤ 1/3 := ih.2.trans ((mul_le_of_le_one_right lo
      (pow_le_one₀ (by norm_num : (0:ℝ) ≤ 7/9) (by norm_num))).trans hi)
    have hfac : 0 ≤ (1/3-x)*(7/3-2*x) := mul_nonneg (by linarith) (by linarith)
    have linear : 3*x^2-2*x^3 ≤ x*(7/9) := by nlinarith [mul_nonneg hx hfac]
    change 0 ≤ 3*x^2-2*x^3 ∧ 3*x^2-2*x^3 ≤ _
    constructor
    · nlinarith [mul_nonneg (sq_nonneg x) (show 0 ≤ 3-2*x by linarith)]
    · rw [pow_succ (7/9 : ℝ) k, ← mul_assoc p]
      exact linear.trans (mul_le_mul_of_nonneg_right ih.2 (by norm_num))

theorem three_level_halving (p : ℝ) (lo : 0 ≤ p) (hi : p ≤ 1/3) (j : ℕ) :
    repeatedError p (3*j) ≤ p * (1/2)^j := by
  apply (error_bound p lo hi _).2.trans
  rw [pow_mul]
  gcongr
  norm_num

/-- After three initial levels, each additional level squares an upper bound for
three times the failure probability. The bound accounts for the circuit growth
when a compiler recursively makes independent copies. -/
theorem squared_error_decay (p : ℝ) (lo : 0 ≤ p) (hi : p ≤ 1/3) (k : ℕ) :
    3 * repeatedError p (3+k) ≤ (1/2 : ℝ)^(2^k) := by
  induction k with
  | zero =>
    have bound := (error_bound p lo hi 3).2
    norm_num at bound ⊢
    linarith
  | succ k ih =>
    let x := repeatedError p (3+k)
    have hx : 0 ≤ x := (error_bound p lo hi _).1
    have sq : (3*x)^2 ≤ ((1/2 : ℝ)^(2^k))^2 := by
      exact pow_le_pow_left₀ (by positivity) ih 2
    rw [pow_succ 2 k, pow_mul]
    change 3*(3*x^2-2*x^3) ≤ _
    nlinarith [pow_nonneg hx 3]

end FQChem.Complexity.Kitaev.Majority
