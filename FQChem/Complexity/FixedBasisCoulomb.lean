module

public import FQChem.Complexity.FixedBasisGaussians
public import Mathlib.MeasureTheory.Integral.Gamma
public import Mathlib.MeasureTheory.Measure.Lebesgue.VolumeOfBalls
public import Mathlib.MeasureTheory.Constructions.HaarToSphere
import Mathlib.Tactic

/-! # Onsite Coulomb energy of a normalized three-dimensional Gaussian

O'Gorman et al., Eqs. (C14), (C62), and (F6)–(F7). The singularity is
integrable in relative coordinates; the two-particle integral is finite.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.FixedBasisCoulomb
open MeasureTheory Real FixedBasisGaussians Set

/-- Integrating the radial Gaussian against 1/r includes the three-dimensional
volume element and yields 2π/a. -/
theorem radialKernel (a : ℝ) (ha : 0<a) :
    (∫ y : Space, exp (-a*‖y‖^2)/‖y‖) = 2*π/a := by
  rw [integral_fun_norm_addHaar (volume : Measure Space) (fun t => exp (-a*t^2)/t)]
  simp only [finrank_euclideanSpace_fin, Nat.reduceSub, nsmul_eq_mul, smul_eq_mul,
    Measure.real, EuclideanSpace.volume_ball_fin_three, ENNReal.ofReal_one, one_pow, one_mul,
    ENNReal.toReal_ofReal (show 0 ≤ π*4/3 by positivity)]
  have h := integral_rpow_mul_exp_neg_mul_rpow (p:=2) (q:=1) (by norm_num) (by norm_num) ha
  norm_num at h
  have hr : (∫ t in Ioi (0:ℝ), t^2*(exp (-a*t^2)/t)) = ∫ t in Ioi (0:ℝ), t*exp (-a*t^2) := by
    apply setIntegral_congr_fun measurableSet_Ioi
    intro t ht
    field_simp [ne_of_gt ht]
  rw [hr]
  simp only [neg_mul]
  rw [h,Real.rpow_neg_one]
  norm_num
  ring

private theorem fourthMoment (a : ℝ) (ha : 0<a) (A : Space) :
    (∫ r, orbital a A r ^ 4) = (a/π)^(3/2:ℝ) := by
  simp only [orbital, mul_pow, ← Real.exp_nat_mul, Nat.cast_ofNat]
  simp_rw [show ∀ r : Space, 4*(-a*‖r-A‖^2) = -(4*a)*‖r-A‖^2 from fun _ => by ring]
  rw [integral_const_mul,integral_sub_right_eq_self (fun r : Space => exp (-(4*a)*‖r‖^2)),
    GaussianFourier.integral_rexp_neg_mul_sq_norm (by positivity),finrank_euclideanSpace_fin]
  push_cast
  have h : (amplitude a)^4 = ((2*a/π)^2)^(3/2 : ℝ) := by
    rw [amplitude, ← Real.rpow_mul_natCast (by positivity), ← Real.rpow_natCast_mul (by positivity)]
    norm_num
  rw [h, ← Real.mul_rpow (by positivity) (by positivity)]
  congr 1
  field_simp
  ring

/-- Direct evaluation of the six-dimensional physical onsite integral. -/
theorem onsite (a : ℝ) (ha : 0<a) (A : Space) :
    coulomb a A A = √(4*a/π) := by
  let c := (a/π)^(3/2:ℝ)
  let K := fun y : Space => exp (-a*‖y‖^2)/‖y‖
  let f := fun r y : Space => orbital a (FixedBasisGaussians.midpoint A (A+y)) r ^ 4 * K y
  have hK : Integrable K := Integrable.of_integral_ne_zero (by
    change (∫ y : Space, exp (-a*‖y‖^2)/‖y‖) ≠ 0; rw [radialKernel a ha]; positivity)
  have density (r y : Space) :
      (orbital a A r * orbital a A r) * (orbital a A (r-y)*orbital a A (r-y)) / ‖r-(r-y)‖ =
        f r y := by
    have shifted : orbital a A (r-y) = orbital a (A+y) r := by
      unfold orbital; rw [show r-y-A = r-(A+y) by abel]
    rw [shifted,sub_sub_cancel,show orbital a A r * orbital a A r *
      (orbital a (A+y) r * orbital a (A+y) r) = (orbital a A r * orbital a (A+y) r)^2 by ring,
      pairDensity a ha,mul_pow,← Real.exp_nat_mul]
    simp only [sub_add_cancel_left, norm_neg, Nat.cast_ofNat]
    dsimp [f,K]
    rw [show 2*(-(a/2)*‖y‖^2) = -a*‖y‖^2 by ring]; ring
  have finite : Integrable (Function.uncurry f) (volume.prod volume) := by
    apply (integrable_prod_iff' (show AEStronglyMeasurable (Function.uncurry f) (volume.prod volume) by
      dsimp [Function.uncurry,f,K,orbital,FixedBasisGaussians.midpoint]; fun_prop)).mpr
    constructor
    · apply Filter.Eventually.of_forall
      intro y
      change Integrable (fun r : Space => orbital a (FixedBasisGaussians.midpoint A (A+y)) r ^ 4 * K y)
      exact (Integrable.of_integral_ne_zero (by rw [fourthMoment a ha]; positivity)).mul_const (K y)
    · have hn (r y : Space) : ‖f r y‖ = f r y := by dsimp only [f,K]; apply abs_of_nonneg; positivity
      change Integrable (fun y => ∫ r, ‖f r y‖)
      simp_rw [hn,show ∀ y, (∫ r, f r y) = c*K y from fun y => by dsimp [f]; rw [integral_mul_const,fourthMoment a ha]]
      exact hK.const_mul c
  have actual : coulomb a A A = ∫ r, ∫ y, f r y := by
    unfold coulomb repulsion
    apply integral_congr_ae
    filter_upwards with r
    rw [← integral_sub_left_eq_self (fun s : Space => _ / ‖r-s‖) volume r]
    simp_rw [density]
  rw [actual, integral_integral_swap finite]
  simp only [f,integral_mul_const,fourthMoment a ha,integral_const_mul,K,radialKernel a ha]
  rw [show (3/2:ℝ)=1+1/2 by norm_num, Real.rpow_add (by positivity),Real.rpow_one,
    ← Real.sqrt_eq_rpow, show 4*a/π = 4*(a/π) by ring,Real.sqrt_mul (by norm_num)]
  norm_num
  field_simp

end FQChem.Complexity.FixedBasisCoulomb
