module

public import FormalQChem.Theorems.ProductFormula
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Slope
import Mathlib.Analysis.SpecificLimits.Basic

public section

namespace FormalQChem.Dynamics

open Filter NormedSpace
open scoped Topology

variable {R : Type*} [NormedRing R] [NormOneClass R]

private theorem power_defect (a b : R) (C : ℝ) (hC : 1 ≤ C) (ha : ‖a‖ ≤ C)
    (hb : ‖b‖ ≤ C) (n : ℕ) : ‖a ^ n - b ^ n‖ ≤ n * C ^ n * ‖a - b‖ := by
  induction n with
  | zero => simp
  | succ n ih =>
    have hpos : 0 ≤ C := zero_le_one.trans hC
    have hpow : ‖a ^ n‖ ≤ C ^ n :=
      (norm_pow_le _ _).trans (pow_le_pow_left₀ (norm_nonneg a) ha _)
    calc
      _ = ‖a ^ n * (a - b) + (a ^ n - b ^ n) * b‖ := by
        rw [pow_succ, pow_succ, mul_sub, sub_mul]
        abel_nf
      _ ≤ ‖a ^ n‖ * ‖a - b‖ + ‖a ^ n - b ^ n‖ * ‖b‖ :=
        (norm_add_le ..).trans (add_le_add (norm_mul_le ..) (norm_mul_le ..))
      _ ≤ C ^ n * ‖a - b‖ + (n * C ^ n * ‖a - b‖) * C := by gcongr
      _ ≤ _ := by
        rw [pow_succ, Nat.cast_succ]
        nlinarith [mul_nonneg (sub_nonneg.mpr hC) (mul_nonneg (pow_nonneg hpos n) (norm_nonneg (a-b)))]

theorem globalStepError (step exactStep : R) : GlobalStepError step exactStep := by
  intro hs he n
  simpa using power_defect step exactStep 1 le_rfl hs he n

variable [NormedAlgebra ℝ R] [CompleteSpace R]

omit [CompleteSpace R] in
private theorem exp_norm_bound (a : R) : ‖exp a‖ ≤ Real.exp ‖a‖ := by
  rw [Real.exp_eq_exp_ℝ, exp_eq_tsum ℝ, exp_eq_tsum ℝ]
  refine (norm_tsum_le_tsum_norm (norm_expSeries_summable' (𝕂 := ℝ) a)).trans ?_
  apply Summable.tsum_le_tsum _ (norm_expSeries_summable' (𝕂 := ℝ) a) (expSeries_summable' (𝕂 := ℝ) ‖a‖)
  intro n
  simp only [norm_smul, Real.norm_eq_abs, abs_inv, Nat.abs_cast, smul_eq_mul]
  exact mul_le_mul_of_nonneg_left (norm_pow_le _ _) (by positivity)

/-- The exact and split exponentials have the same derivative at zero.
Their one-step defect is therefore `o(1/n)`. A uniform exponential stability
bound controls its amplification over the full `n` steps. -/
theorem lieTrotter (X Y : R) : LieTrotter X Y := by
  let +nondep : NormedAlgebra ℚ R := .restrictScalars ℚ ℝ R
  let S := fun h : ℝ => exp (h • X) * exp (h • Y)
  let U := fun h : ℝ => exp (h • (X + Y))
  have hder (Z : R) : HasDerivAt (fun h : ℝ => exp (h • Z)) Z 0 := by
    simpa using hasDerivAt_exp_smul_const Z (0 : ℝ)
  have hdiff : HasDerivAt (fun h => S h - U h) 0 0 := by
    simpa [S, U, add_comm] using ((hder X).fun_mul (hder Y)).fun_sub (hder (X + Y))
  have hinv : Tendsto (fun n : ℕ => (n : ℝ)⁻¹) atTop (𝓝[≠] 0) := by
    apply tendsto_nhdsWithin_iff.mpr
    refine ⟨?_, ?_⟩
    · simpa using (tendsto_one_div_atTop_nhds_zero_nat (𝕜 := ℝ))
    · filter_upwards [eventually_gt_atTop 0] with n hn
      simp [Nat.ne_of_gt hn]
  have hscale : Tendsto (fun n : ℕ => (n : ℝ) * ‖S (n : ℝ)⁻¹ - U (n : ℝ)⁻¹‖)
      atTop (𝓝 0) := by
    simpa [slope, S, U, norm_smul] using (hdiff.tendsto_slope.comp hinv).norm
  let M := ‖X‖ + ‖Y‖
  have hM : 0 ≤ M := add_nonneg (norm_nonneg _) (norm_nonneg _)
  have hstep (h : ℝ) (hh : 0 ≤ h) :
      ‖S h‖ ≤ Real.exp (h * M) ∧ ‖U h‖ ≤ Real.exp (h * M) := by
    constructor
    · calc
        ‖S h‖ ≤ ‖exp (h • X)‖ * ‖exp (h • Y)‖ := norm_mul_le ..
        _ ≤ Real.exp ‖h • X‖ * Real.exp ‖h • Y‖ := by
          gcongr <;> apply exp_norm_bound
        _ = _ := by rw [← Real.exp_add]; simp [M, norm_smul, abs_of_nonneg hh, mul_add]
    · refine (exp_norm_bound _).trans (Real.exp_le_exp.mpr ?_)
      simp only [norm_smul, Real.norm_eq_abs, abs_of_nonneg hh]
      exact mul_le_mul_of_nonneg_left (norm_add_le X Y) hh
  apply tendsto_iff_norm_sub_tendsto_zero.mpr
  apply squeeze_zero' (Eventually.of_forall fun _ => norm_nonneg _) _ (by
    simpa using (tendsto_const_nhds (x := Real.exp M)).mul hscale)
  filter_upwards [eventually_gt_atTop 0] with n hn
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hn)
  let h := (n : ℝ)⁻¹
  have hh : 0 ≤ h := by positivity
  have hU : U h ^ n = exp (X + Y) := by
    rw [show U h = exp (h • (X + Y)) by rfl, ← exp_nsmul, ← Nat.cast_smul_eq_nsmul ℝ,
      smul_smul, show (n : ℝ) * h = 1 from mul_inv_cancel₀ hn', one_smul]
  have hC : 1 ≤ Real.exp (h * M) := Real.one_le_exp (mul_nonneg hh hM)
  have hpow : Real.exp (h * M) ^ n = Real.exp M := by
    rw [← Real.exp_nat_mul, ← mul_assoc, show (n : ℝ) * h = 1 from mul_inv_cancel₀ hn', one_mul]
  have hb := power_defect (S h) (U h) _ hC (hstep h hh).1 (hstep h hh).2 n
  rw [hU, hpow] at hb
  simpa [mul_left_comm, mul_comm, mul_assoc, h, S] using hb

end FormalQChem.Dynamics
