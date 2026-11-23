module

public import FormalQChem.Properties.ResponseAndEstimation.VQEMeasurement
import Mathlib.Tactic

/-! # Sampling signed paths

Absolute-weight sampling reweights a signed field or path expansion by its
average sign. Independent samples of that sign have an exact relative variance.
A product of two signed weights gives an explicit exponential sample requirement.
See [Troyer and Wiese](https://doi.org/10.1103/PhysRevLett.94.170201) for the
statistical sign problem and a separate complexity-theoretic hardness result. -/

@[expose] public section
noncomputable section

namespace FormalQChem.StatePrep.ImaginaryTimeProjection.SignProblem

open MeasureTheory ProbabilityTheory
variable {ι : Type*} [Fintype ι]

def sign (a : ℝ) : ℝ := if a < 0 then -1 else 1

def absMean (w f : ι → ℝ) : ℝ := (∑ i, |w i| * f i) / ∑ i, |w i|

def meanSign (w : ι → ℝ) : ℝ := (∑ i, w i) / ∑ i, |w i|

private theorem abs_mul_sign (a : ℝ) : |a| * sign a = a := by
  by_cases h : a < 0
  · simp [sign, h, abs_of_neg h]
  · simp [sign, h, abs_of_nonneg (le_of_not_gt h)]

theorem absMean_sign (w : ι → ℝ) : absMean w (fun i => sign (w i)) = meanSign w := by
  simp [absMean, meanSign, abs_mul_sign]

/-- For nonzero signed partition sum this gives the physical expectation as a
ratio of two absolute-weight averages. The algebra uses Lean’s total division. -/
theorem reweighting (w f : ι → ℝ) :
    absMean w (fun i => sign (w i) * f i) / meanSign w = (∑ i, w i * f i) / ∑ i, w i := by
  by_cases h : (∑ i, |w i|) = 0
  · have each : ∀ i, w i = 0 := by
      have hh := (Finset.sum_eq_zero_iff_of_nonneg (fun i _ => abs_nonneg (w i))).mp h
      exact fun i => abs_eq_zero.mp (hh i (Finset.mem_univ _))
    simp [absMean, meanSign, each]
  · simp only [absMean, meanSign, ← mul_assoc, abs_mul_sign, div_div_div_cancel_right₀ h]

/-- The sign of a collection of independent signed factors multiplies in expectation. -/
theorem factorizedSign {κ : Type*} [Fintype κ] [DecidableEq κ] (w : κ → ι → ℝ) :
    meanSign (fun x : κ → ι => ∏ j, w j (x j)) = ∏ j, meanSign (w j) := by
  simp only [meanSign, Finset.prod_div_distrib, Finset.abs_prod, ← Fintype.prod_sum]
  rw [Fintype.prod_sum (fun j k => |w j k|)]

/-- Each factor has weights 3 and −1. A product of L factors has mean sign 2⁻ᴸ. -/
def productWeight (L : ℕ) (x : Fin L → Bool) : ℝ := ∏ j, if x j then (3 : ℝ) else -1

theorem productMeanSign (L : ℕ) : meanSign (productWeight L) = (1 / 2 : ℝ)^L := by
  unfold productWeight
  rw [factorizedSign (fun (_ : Fin L) (b : Bool) => if b then (3 : ℝ) else -1)]
  norm_num [meanSign, Fintype.sum_bool]
  simp [one_div, inv_pow]

variable {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
variable {n : ℕ}

/-- Conditions for independent draws from the absolute-weight path law. Only pairwise
independence of the signs is needed. The marginal law is specified by test functions. -/
structure Sampling (w : ι → ℝ) (path : Fin n → Ω → ι) : Prop where
  positive : 0 < n
  measurableSign : ∀ j, Measurable (fun ω => sign (w (path j ω)))
  law : ∀ j (f : ι → ℝ), (∫ ω, f (path j ω) ∂μ) = absMean w f
  independent : Pairwise fun j k => IndepFun (fun ω => sign (w (path j ω)))
    (fun ω => sign (w (path k ω))) μ

def signEstimate (w : ι → ℝ) (path : Fin n → Ω → ι) : Ω → ℝ :=
  fun ω => (∑ j, sign (w (path j ω))) / n

/-- The empirical mean sign is unbiased and its variance is (1−s²)/n. -/
theorem signStatistics (w : ι → ℝ) (path : Fin n → Ω → ι) (sample : Sampling μ w path) :
    (∫ ω, signEstimate w path ω ∂μ) = meanSign w ∧
      variance (signEstimate w path) μ = (1 - meanSign w ^ 2) / n := by
  let out := fun (p : Unit × Fin n) (ω : Ω) => sign (w (path p.2 ω))
  have stats := FormalQChem.VQEMeasurement.shotStatistics μ (fun _ : Unit => (1 : ℝ))
    (fun _ => meanSign w) out sample.positive (fun p => sample.measurableSign p.2)
    (fun p => Filter.Eventually.of_forall fun ω => by simp [out, sign]; split <;> norm_num)
    (fun p => (sample.law p.2 (fun i => sign (w i))).trans (absMean_sign w))
    (fun {i j} hij => sample.independent (show i.2 ≠ j.2 by
      intro eq; exact hij (Prod.ext (Subsingleton.elim _ _) eq)))
  have est : FormalQChem.VQEMeasurement.estimate (fun _ : Unit => (1 : ℝ)) out = signEstimate w path := by
    funext ω
    simp [FormalQChem.VQEMeasurement.estimate, signEstimate, out, Fintype.sum_prod_type,
      Finset.mul_sum, div_eq_inv_mul]
  simpa [est] using And.intro stats.1 stats.2.1

/-- To attain relative RMS error ≤ δ on the mean sign of this explicit product
family, the signed sampler must use at least (4ᴸ−1)/δ² independent shots (δ>0). -/
theorem productSampleCost (L : ℕ) (path : Fin n → Ω → (Fin L → Bool))
    (sample : Sampling μ (productWeight L) path) {δ : ℝ}
    (target : variance (signEstimate (productWeight L) path) μ ≤
      δ^2 * meanSign (productWeight L)^2) :
    (4 : ℝ)^L - 1 ≤ n * δ^2 := by
  rw [(signStatistics μ _ path sample).2, productMeanSign] at target
  have power : ((1 / 2 : ℝ)^L)^2 * (4 : ℝ)^L = 1 := by
    rw [← pow_mul, mul_comm L, pow_mul, ← mul_pow]
    norm_num
  have hpos : (0 : ℝ) < n := by exact_mod_cast sample.positive
  have h := mul_le_mul_of_nonneg_right ((div_le_iff₀ hpos).mp target) (show 0 ≤ (4 : ℝ)^L by positivity)
  rw [sub_mul, one_mul, power] at h
  calc (4 : ℝ)^L - 1 ≤ δ^2 * ((1 / 2 : ℝ)^L)^2 * n * 4^L := h
       _ = n * δ^2 * (((1 / 2 : ℝ)^L)^2 * 4^L) := by ring
       _ = _ := by rw [power, mul_one]

end FormalQChem.StatePrep.ImaginaryTimeProjection.SignProblem
