module

public import FQChem.StatePrep.VariationalOptimization.VQE
public import Mathlib.Probability.Moments.Variance

/-!
# Energy measurement in the variational quantum eigensolver

A Pauli string is a Hermitian involution. The statements use only those two properties,
so they apply to any dichotomic observable used in the same measurement protocol.
The shot model allocates a positive, equal number of independent shots to every term.

The measurement calculation uses mathlib's variance additivity for independent
random variables, and the identity Var(X) = E[X²] − E[X]².
-/

@[expose] public section

namespace FQChem.VQEMeasurement

open MeasureTheory ProbabilityTheory
open scoped BigOperators

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
variable {ι : Type*} [Fintype ι]

/-- Terms in a Pauli expansion of an encoded Hamiltonian. -/
structure PauliTerm (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℂ E] where
  op : E →L[ℂ] E
  hermitian : op.toLinearMap.IsSymmetric
  involution : op * op = 1

/-- The coefficient-weighted sum of Pauli expectations is the exact Hamiltonian expectation. -/
def EnergyReconstruction (H : E →L[ℂ] E) (term : ι → PauliTerm E) (coeff : ι → ℝ) : Prop :=
  H = ∑ i, (coeff i : ℂ) • (term i).op →
    ∀ ψ, H.reApplyInnerSelf ψ = ∑ i, coeff i * (term i).op.reApplyInnerSelf ψ

/-- Each shot contributes its coefficient divided by the number of shots per term. -/
noncomputable def estimate {Ω : Type*} {n : ℕ} (coeff : ι → ℝ)
    (outcome : ι × Fin n → Ω → ℝ) : Ω → ℝ :=
  ∑ p, fun ω ↦ (coeff p.1 / n) * outcome p ω

/-- Under calibrated Pauli measurement, the energy estimator is unbiased. Independent
±1 outcomes give an exact variance and the state-independent bound Σ cᵢ² / n. -/
def ShotStatistics {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    {n : ℕ} (coeff mean : ι → ℝ) (outcome : ι × Fin n → Ω → ℝ) : Prop :=
  0 < n → (∀ p, Measurable (outcome p)) →
    (∀ p, ∀ᵐ ω ∂μ, |outcome p ω| = 1) →
    (∀ p, (∫ ω, outcome p ω ∂μ) = mean p.1) →
    Pairwise (fun i j ↦ IndepFun (outcome i) (outcome j) μ) →
    (∫ ω, estimate coeff outcome ω ∂μ) = ∑ i, coeff i * mean i ∧
    variance (estimate coeff outcome) μ = (∑ i, coeff i ^ 2 * (1 - mean i ^ 2)) / n ∧
    variance (estimate coeff outcome) μ ≤ (∑ i, coeff i ^ 2) / n

/-- Finite-shot VQE at a normalized circuit output, with the shot means calibrated to
the ideal observable expectations. The estimator has the Hamiltonian energy as its mean. -/
def FiniteShotVQE {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    {n : ℕ} (H : E →L[ℂ] E) (term : ι → PauliTerm E) (coeff : ι → ℝ)
    (ψ : E) (outcome : ι × Fin n → Ω → ℝ) : Prop :=
  ‖ψ‖ = 1 → H = ∑ i, (coeff i : ℂ) • (term i).op → 0 < n →
    (∀ p, Measurable (outcome p)) → (∀ p, ∀ᵐ ω ∂μ, |outcome p ω| = 1) →
    (∀ p, (∫ ω, outcome p ω ∂μ) = (term p.1).op.reApplyInnerSelf ψ) →
    Pairwise (fun i j ↦ IndepFun (outcome i) (outcome j) μ) →
    (∫ ω, estimate coeff outcome ω ∂μ) = H.rayleighQuotient ψ ∧
    variance (estimate coeff outcome) μ ≤ (∑ i, coeff i ^ 2) / n

theorem energyReconstruction (H : E →L[ℂ] E) (term : ι → PauliTerm E) (coeff : ι → ℝ) :
    EnergyReconstruction H term coeff := by
  rintro rfl ψ
  simp only [ContinuousLinearMap.reApplyInnerSelf_apply, sum_apply,
    smul_apply, sum_inner, map_sum, inner_smul_left]
  simp [RCLike.re_to_complex]

theorem shotStatistics {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    {n : ℕ} (coeff mean : ι → ℝ) (outcome : ι × Fin n → Ω → ℝ) :
    ShotStatistics μ coeff mean outcome := by
  intro hn measurable signs calibrated independent
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  have lp (p) : MemLp (outcome p) 2 μ :=
    MemLp.of_bound (measurable p).aestronglyMeasurable 1 ((signs p).mono fun _ h ↦ h.le)
  have weighted (p) : MemLp (fun ω => (coeff p.1 / n) * outcome p ω) 2 μ :=
    (lp p).const_mul _
  have single (p) : variance (outcome p) μ = 1 - mean p.1 ^ 2 := by
    rw [variance_eq_sub (lp p), calibrated]
    have square : outcome p ^ 2 =ᵐ[μ] fun _ => (1 : ℝ) := (signs p).mono fun ω h => by
      change outcome p ω ^ 2 = 1
      rw [← sq_abs, h, one_pow]
    simp only [integral_congr_ae square, integral_const, probReal_univ, one_smul]
  have sumShots (f : ι → ℝ) : (∑ p : ι × Fin n, f p.1) = n * ∑ i, f i := by
    simp only [Fintype.sum_prod_type, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul, Finset.mul_sum]
  have varianceFormula : variance (estimate coeff outcome) μ =
      (∑ i, coeff i ^ 2 * (1 - mean i ^ 2)) / n := by
    unfold estimate
    rw [IndepFun.variance_sum]
    · simp_rw [variance_const_mul, single, div_pow, div_mul_eq_mul_div]
      rw [← Finset.sum_div, sumShots (fun i => coeff i ^ 2 * (1 - mean i ^ 2))]
      rw [sq (n : ℝ), mul_div_mul_left _ _ hn']
    · exact fun p _ => weighted p
    · intro i _ j _ hij
      exact (independent hij).comp (measurable_const.mul measurable_id)
        (measurable_const.mul measurable_id)
  refine ⟨?_, varianceFormula, ?_⟩
  · simp only [estimate, Finset.sum_apply]
    rw [integral_finsetSum]
    · simp_rw [integral_const_mul, calibrated, div_mul_eq_mul_div]
      rw [← Finset.sum_div, sumShots (fun i => coeff i * mean i), mul_div_cancel_left₀ _ hn']
    · intro p _
      exact (weighted p).integrable (by norm_num)
  · rw [varianceFormula]
    apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg n)
    exact Finset.sum_le_sum fun i _ =>
      mul_le_of_le_one_right (sq_nonneg _) (sub_le_self _ (sq_nonneg _))

theorem finiteShotVQE {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    {n : ℕ} (H : E →L[ℂ] E) (term : ι → PauliTerm E) (coeff : ι → ℝ)
    (ψ : E) (outcome : ι × Fin n → Ω → ℝ) : FiniteShotVQE μ H term coeff ψ outcome := by
  intro hψ decomposition hn measurable signs calibrated independent
  obtain ⟨unbiased, _, bounded⟩ :=
    shotStatistics μ coeff (fun i ↦ (term i).op.reApplyInnerSelf ψ) outcome hn measurable signs
      calibrated independent
  refine ⟨?_, bounded⟩
  rw [unbiased, ← energyReconstruction H term coeff decomposition, ContinuousLinearMap.rayleighQuotient,
    hψ, one_pow, div_one]

end FQChem.VQEMeasurement
