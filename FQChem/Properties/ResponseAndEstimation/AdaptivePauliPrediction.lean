module

public import FQChem.Properties.ResponseAndEstimation.PauliPrediction
public import Mathlib.MeasureTheory.Integral.Average
import Mathlib.Tactic

/-! # Adaptive single-copy lower bound for a partially revealed Pauli observable

Huang et al., Supplementary Theorem 6. Every node may choose a different finite-outcome
POVM based on the complete previous transcript. Only after the last measurement does the
predictor learn which Pauli word will be scored. The proof bounds the sign-averaged leaf
likelihood by its sum of squared Pauli correlations.
[Original paper, Appendix D](https://doi.org/10.1126/science.abn7293)
-/

@[expose] public section
noncomputable section

namespace FQChem.Properties.AdaptivePauliPrediction

open FQChem.Complexity.ElectronicStructure FQChem.Dynamics.OTOC
open FQChem.Properties.PauliPrediction Matrix MeasureTheory
open scoped Classical BigOperators ComplexOrder

variable {α : Type*} [Fintype α] {n T : ℕ}

/-- A single-copy measurement with any finite family of positive effects. -/
structure Measurement (α : Type*) [Fintype α] (n : ℕ) where
  effect : α → Operator n
  positive : ∀ a, (effect a).PosSemidef
  complete : ∑ a, effect a = 1

/-- A depth-T adaptive experiment. The next entire subtree may depend on this outcome. -/
inductive Experiment (α : Type*) [Fintype α] (n : ℕ) : ℕ → Type _
  | halt : Experiment α n 0
  | measure {t : ℕ} (povm : Measurement α n) (next : α → Experiment α n t) : Experiment α n (t+1)

def Experiment.path : {t : ℕ} → Experiment α n t → (Fin t → α) → Fin t → Operator n
  | _, .halt, _ => Fin.elim0
  | _, .measure m next, leaf => Fin.cases (m.effect (leaf 0)) ((next (leaf 0)).path (Fin.tail leaf))

private theorem pathPositive (Q : Experiment α n T) (leaf : Fin T → α) (i : Fin T) :
    (Q.path leaf i).PosSemidef := by
  induction Q with
  | halt => exact Fin.elim0 i
  | measure m next ih => refine Fin.cases (m.positive (leaf 0)) (fun j => ih _ _ j) i

def born (ρ E : Operator n) : ℝ := (E * ρ).trace.re

/-- Each adaptive leaf has the product of its successive Born probabilities. -/
def leafMass (Q : Experiment α n T) (ρ : Operator n) (leaf : Fin T → α) : ℝ :=
  ∏ i, born ρ (Q.path leaf i)

private theorem bornSum (m : Measurement α n) (ρ : Operator n) (hρ : ρ.trace=1) :
    ∑ a, born ρ (m.effect a) = 1 := by
  simp only [born, ← Complex.re_sum, ← Matrix.trace_sum, ← Matrix.sum_mul, m.complete,
    Matrix.one_mul, hρ, Complex.one_re]

theorem leafNormalization (Q : Experiment α n T) (ρ : Operator n) (hρ : ρ.trace=1) :
    ∑ l, leafMass Q ρ l = 1 := by
  induction Q with
  | halt => simp [leafMass]
  | @measure t m next ih =>
    rw [← Equiv.sum_comp (Fin.consEquiv (fun _ => α)) (fun l => leafMass (.measure m next) ρ l),
      Fintype.sum_prod_type]
    have reduce (a : α) (l : Fin t → α) :
        leafMass (.measure m next) ρ (Fin.cons a l) = born ρ (m.effect a) * leafMass (next a) ρ l := by
      simp [leafMass, Experiment.path, Fin.prod_univ_succ]
    change ∑ a, ∑ l, leafMass (.measure m next) ρ (Fin.cons a l) = _
    simp_rw [reduce, ← Finset.mul_sum, ih, mul_one]
    exact bornSum m ρ hρ

private theorem bornHard (E : Operator n) (h : E.PosSemidef) (p : Word n) (a : ℝ) :
    born (hardState p a) E = E.trace.re / dimension n * (1 + a * response E p) := by
  have hc : (E * hardState p a).trace = ((dimension n : ℝ):ℂ)⁻¹ *
      (E.trace + (a:ℂ) * (E * wordMatrix p).trace) := by
    simp [hardState, Matrix.trace_add, Matrix.trace_smul, mul_add]
  have hr := congrArg Complex.re hc
  rw [← Complex.ofReal_inv] at hr
  simp only [Complex.mul_re, Complex.ofReal_re, Complex.ofReal_im, zero_mul, sub_zero, Complex.add_re] at hr
  change (E * hardState p a).trace.re = _
  rw [hr]
  by_cases hz : E.trace.re = 0
  · have htr := (Complex.nonneg_iff.mp h.trace_nonneg).2
    have h0 : E = 0 := h.trace_eq_zero_iff.mp (Complex.ext hz htr.symm)
    simp [h0, response, correlation]
  · unfold response correlation
    field_simp

private theorem massRatio (Q : Experiment α n T) (l : Fin T → α) (p : Word n) (a : ℝ) :
    leafMass Q (hardState p a) l =
      leafMass Q (hardState p 0) l * ∏ i, (1 + a * response (Q.path l i) p) := by
  simp only [leafMass, bornHard _ (pathPositive Q l _) p, zero_mul, add_zero, mul_one,
    Finset.prod_mul_distrib]

private theorem nullNonnegative (Q : Experiment α n T) (l : Fin T → α) (p : Word n) :
    0 ≤ leafMass Q (hardState p 0) l := by
  apply Finset.prod_nonneg
  intro i _
  rw [bornHard _ (pathPositive Q l _) p]
  simp only [zero_mul, add_zero, mul_one]
  exact div_nonneg (Complex.nonneg_iff.mp (pathPositive Q l i).trace_nonneg).1 (by unfold dimension; positivity)

private theorem nullIndependent (Q : Experiment α n T) (l : Fin T → α) (p : Word n) :
    leafMass Q (hardState p 0) l = leafMass Q (hardState (identityWord n) 0) l := by
  simp [hardState]

private theorem productLoss {ι : Type*} (J : Finset ι) (x : ι → ℝ)
    (hx : ∀ i ∈ J, 0 ≤ x i ∧ x i ≤ 1) :
    1 - ∑ i ∈ J, x i ≤ ∏ i ∈ J, (1 - x i) := by
  induction J using Finset.induction_on with
  | empty => simp
  | @insert a J ha ih =>
    have hJ : ∀ i ∈ J, 0 ≤ x i ∧ x i ≤ 1 := fun i hi => hx i (Finset.mem_insert_of_mem hi)
    have h := ih hJ
    have hsum := Finset.sum_nonneg fun i hi => (hJ i hi).1
    have hab := hx a (Finset.mem_insert_self a J)
    rw [Finset.prod_insert ha, Finset.sum_insert ha]
    nlinarith [mul_nonneg (sub_nonneg.mpr hab.2) (sub_nonneg.mpr h), mul_nonneg hab.1 hsum]

/-- A shared hidden sign is chosen only once for the entire experiment. -/
private theorem signMixture (x : Fin T → ℝ) (hx : ∀ i, |x i| ≤ 1) :
    1 - ∑ i, x i ^ 2 ≤ ((∏ i, (1+x i)) + (∏ i, (1-x i)))/2 := by
  let s := ∏ i, (1-x i ^ 2)
  let a := ∏ i, (1+x i)
  let b := ∏ i, (1-x i)
  have sq (i) : x i^2 ≤ 1 := by
    simpa only [sq_abs, one_pow] using pow_le_pow_left₀ (abs_nonneg (x i)) (hx i) 2
  have ab : a*b = s := by
    unfold a b s; rw [← Finset.prod_mul_distrib]; congr 1; ext i; ring
  have hs : 0 ≤ s := Finset.prod_nonneg fun i _ => sub_nonneg.mpr (sq i)
  have hs1 : s ≤ 1 := Finset.prod_le_one₀ (fun i _ => sub_nonneg.mpr (sq i))
    (fun i _ => sub_le_self _ (sq_nonneg _))
  have ha : 0 ≤ a := Finset.prod_nonneg fun i _ => by linarith [(abs_le.mp (hx i)).1]
  have hb : 0 ≤ b := Finset.prod_nonneg fun i _ => sub_nonneg.mpr (abs_le.mp (hx i)).2
  refine (productLoss Finset.univ (fun i => x i ^ 2) (fun i _ => ⟨sq_nonneg _,sq i⟩)).trans ?_
  change s ≤ (a+b)/2
  by_contra! hf
  nlinarith [sq_nonneg (a-b), mul_nonneg hs (sub_nonneg.mpr hs1),
    mul_pos (by linarith : 0 < s - (a+b)/2) (by linarith : 0 < s + (a+b)/2)]

def bias : ℝ := 9/10

/-- The mass of the two alternatives after averaging the unknown sign. -/
def alternative (Q : Experiment α n T) (l : Fin T → α) (p : Word n) :=
  (leafMass Q (hardState p bias) l + leafMass Q (hardState p (-bias)) l) / 2

private theorem mixtureLower (Q : Experiment α n T) (l : Fin T → α) (p : Word n) :
    leafMass Q (hardState p 0) l * (1 - bias ^ 2 * ∑ i, response (Q.path l i) p ^ 2) ≤
      alternative Q l p := by
  let c := fun i => response (Q.path l i) p
  have hc (i) : |bias * c i| ≤ 1 := by
    rw [abs_mul, abs_of_nonneg (by norm_num [bias] : 0 ≤ bias)]
    exact (mul_le_of_le_one_right (by norm_num [bias]) (responseAbs _ (pathPositive Q l i) p)).trans (by norm_num [bias])
  have h := signMixture (fun i => bias * c i) hc
  simp only [mul_pow, ← Finset.mul_sum] at h
  have g := mul_le_mul_of_nonneg_left h (nullNonnegative Q l p)
  rw [alternative, massRatio Q l p bias, massRatio Q l p (-bias)]
  simp_rw [neg_mul, ← sub_eq_add_neg]
  unfold c at g
  linarith only [g]

/-- The error probability for the equiprobable hypotheses, uniform nonidentity Pauli,
fair hidden sign and 1/4 additive tolerance, with the Pauli revealed only at prediction. -/
def failure (Q : Experiment α n T) (predict : (Fin T → α) → Word n → ℝ) :=
  (∑ p ∈ nonidentity n, ∑ l : Fin T → α,
    ((if 1/4 < |predict l p| then leafMass Q (hardState p 0) l else 0) +
     (if 1/4 < |predict l p - bias| then alternative Q l p else 0))) /
    (2 * ((nonidentity n).card : ℝ))

private theorem alternativeNonneg (Q : Experiment α n T) (l : Fin T → α) (p : Word n) :
    0 ≤ alternative Q l p := by
  have h (a : ℝ) (ha : |a| ≤ 1) : 0 ≤ leafMass Q (hardState p a) l := by
    rw [massRatio]; apply mul_nonneg (nullNonnegative ..)
    apply Finset.prod_nonneg; intro i _
    have hle : |a * response (Q.path l i) p| ≤ 1 := by
      rw [abs_mul]; exact (mul_le_of_le_one_right (abs_nonneg a) (responseAbs _ (pathPositive ..) _)).trans ha
    linarith [(abs_le.mp hle).1]
  exact div_nonneg (add_nonneg (h bias (by norm_num [bias])) (h (-bias) (by norm_num [bias]))) (by norm_num)

private theorem leafError (Q : Experiment α n T) (l : Fin T → α) (p : Word n) (z : ℝ) :
    leafMass Q (hardState (identityWord n) 0) l * (1 - bias ^ 2 * ∑ i, response (Q.path l i) p ^ 2) ≤
    (if 1/4 < |z| then leafMass Q (hardState p 0) l else 0) +
    (if 1/4 < |z-bias| then alternative Q l p else 0) := by
  rw [← nullIndependent Q l p]
  by_cases hz : 1/4 < |z|
  · rw [ite_eq_left hz]
    have hn : 0 ≤ (if 1/4 < |z-bias| then alternative Q l p else 0) := by
      split_ifs <;> first | exact alternativeNonneg .. | rfl
    have hb : 0 ≤ bias^2 * ∑ i, response (Q.path l i) p ^ 2 :=
      mul_nonneg (sq_nonneg _) (Finset.sum_nonneg fun i _ => sq_nonneg _)
    nlinarith [mul_nonneg (nullNonnegative Q l p) hb]
  · have hza : 1/4 < |z-bias| := by
      have bound := (abs_le.mp (le_of_not_gt hz)).2
      exact lt_of_lt_of_le (by unfold bias; linarith : 1/4 < -(z-bias)) (neg_le_abs _)
    rw [ite_eq_right hz, ite_eq_left hza, zero_add]
    exact mixtureLower ..

/-- Supplementary Theorem 6, conventional lower bound. Achieving failure probability at most
1/5 forces at least (20/27)(2ⁿ+1) single-copy measurements. -/
theorem copyLowerBound (hn : 0 < n) (Q : Experiment α n T)
    (predict : (Fin T → α) → Word n → ℝ) (success : failure Q predict ≤ 1/5) :
    (20/27:ℝ) * (dimension n + 1) ≤ T := by
  let w := fun l => leafMass Q (hardState (identityWord n) 0) l
  let M : ℝ := (nonidentity n).card
  have dpos : 1 < dimension n := by unfold dimension; exact one_lt_pow₀ (by norm_num) (by omega)
  have hm : M = (dimension n - 1) * (dimension n + 1) := nonidentityCount n
  have hM : 0 < M := by rw [hm]; positivity
  have norm : ∑ l, w l = 1 := by
    apply leafNormalization
    simp [hardState, dimension, Matrix.trace_smul, Matrix.trace_one, Spin]
  have atLeaf (l : Fin T → α) :
      w l * (M - bias^2 * (T : ℝ) * (dimension n-1)) ≤
      ∑ p ∈ nonidentity n,
        ((if 1/4 < |predict l p| then leafMass Q (hardState p 0) l else 0) +
         (if 1/4 < |predict l p - bias| then alternative Q l p else 0)) := by
    have total : ∑ p ∈ nonidentity n, ∑ i, response (Q.path l i) p ^ 2 ≤ (T:ℝ)*(dimension n-1) := by
      rw [Finset.sum_comm]
      simpa only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] using Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) =>
        nonidentitySecondMoment (Q.path l i) (pathPositive Q l i))
    have many := Finset.sum_le_sum (fun p (_ : p ∈ nonidentity n) => leafError Q l p (predict l p))
    simp only [← Finset.mul_sum, Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul, mul_one] at many
    apply le_trans _ many
    apply mul_le_mul_of_nonneg_left _ (nullNonnegative Q l _)
    change M - bias^2 * T * (dimension n-1) ≤ M - bias^2 * _
    nlinarith [mul_le_mul_of_nonneg_left total (sq_nonneg bias)]
  have sm := Finset.sum_le_sum (fun l (_ : l ∈ Finset.univ) => atLeaf l)
  rw [← Finset.sum_mul, norm, one_mul, Finset.sum_comm] at sm
  have risk := (div_le_iff₀ (show 0 < 2*M by positivity)).mp success
  have factor : (dimension n - 1) * ((3/5:ℝ) * (dimension n+1)) ≤
      (dimension n - 1) * (bias^2 * T) := by
    rw [hm] at sm risk
    nlinarith
  have hh := le_of_mul_le_mul_left factor (sub_pos.mpr dpos)
  unfold bias at hh
  linarith

/-- Classical randomization may select both the adaptive experiment and its post-reveal
prediction rule. The seed may follow any probability measure with an integrable failure rate. -/
theorem randomizedCopyLowerBound {R : Type*} [MeasurableSpace R] (ν : Measure R) [IsProbabilityMeasure ν]
    (hn : 0 < n) (Q : R → Experiment α n T) (predict : R → (Fin T → α) → Word n → ℝ)
    (hf : Integrable (fun s => failure (Q s) (predict s)) ν)
    (success : (∫ s, failure (Q s) (predict s) ∂ν) ≤ 1/5) :
    (20/27 : ℝ) * (dimension n + 1) ≤ T := by
  obtain ⟨s,hs⟩ := exists_le_integral hf
  exact copyLowerBound hn (Q s) (predict s) (hs.trans success)

end FQChem.Properties.AdaptivePauliPrediction
