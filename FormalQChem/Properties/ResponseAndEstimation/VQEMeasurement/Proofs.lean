module

public import FormalQChem.Properties.ResponseAndEstimation.VQEMeasurement.Theorems

/-! The measurement calculation uses mathlib's variance additivity for independent
random variables, and the identity Var(X) = E[X²] − E[X]². -/

@[expose] public section

namespace FormalQChem.VQEMeasurement

open MeasureTheory ProbabilityTheory
open scoped BigOperators
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
variable {ι : Type*} [Fintype ι]

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
  have single (p) : variance (outcome p) μ = 1 - mean p.1 ^ 2 := by
    rw [variance_eq_sub (lp p), calibrated]
    congr 1
    calc (∫ ω, (outcome p ^ 2) ω ∂μ) = ∫ _, (1 : ℝ) ∂μ := by
           apply integral_congr_ae
           filter_upwards [signs p] with ω hω
           change outcome p ω ^ 2 = 1
           rw [← sq_abs, hω, one_pow]
         _ = _ := by simp
  have varianceFormula : variance (estimate coeff outcome) μ =
      (∑ i, coeff i ^ 2 * (1 - mean i ^ 2)) / n := by
    unfold estimate
    rw [IndepFun.variance_sum]
    · simp_rw [variance_const_mul, single]
      rw [Fintype.sum_prod_type, Finset.sum_div]
      apply Finset.sum_congr rfl
      intro i _
      simp [field]
    · intro p _
      exact (lp p).const_mul _
    · intro i _ j _ hij
      exact (independent hij).comp (measurable_const.mul measurable_id)
        (measurable_const.mul measurable_id)
  refine ⟨?_, varianceFormula, ?_⟩
  · simp only [estimate, Finset.sum_apply]
    rw [integral_finsetSum]
    · simp_rw [integral_const_mul, calibrated]
      rw [Fintype.sum_prod_type]
      apply Finset.sum_congr rfl
      intro i _
      simp [field]
    · intro p _
      exact ((lp p).const_mul _).integrable (by norm_num)
  · rw [varianceFormula]
    gcongr with i
    nlinarith [sq_nonneg (coeff i * mean i)]

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

end FormalQChem.VQEMeasurement
