module

public import FQChem.Complexity.FixedBasisGaussians
public import Mathlib.Analysis.InnerProductSpace.Laplacian
public import Mathlib.MeasureTheory.Constructions.HaarToSphere
public import Mathlib.MeasureTheory.Measure.Lebesgue.VolumeOfBalls
import Mathlib.Analysis.Calculus.Deriv.Polynomial
import Mathlib.Analysis.InnerProductSpace.Calculus
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Tactic

/-! # A compact orbital with polynomial squared density

Inside the unit ball its unnormalized wave function is (1−r²)^(5/2).
It is zero outside and twice continuously differentiable on all of ℝ³.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.FixedBasisRadial
open FixedBasisGaussians Real MeasureTheory Set InnerProductSpace
open scoped Laplacian RealInnerProductSpace Interval

def shape (x : Space) := (1-‖x‖^2)^(5/2:ℝ)

theorem smooth : ContDiff ℝ 2 shape := by
  have h : ContDiff ℝ 2 (fun x : Space => 1-‖x‖^2) := contDiff_const.sub (contDiff_norm_sq ℝ)
  exact h.rpow_const_of_le (by norm_num)

theorem zero {x : Space} (h : 1≤‖x‖) : shape x=0 := by
  unfold shape
  rcases lt_or_eq_of_le h with h|h
  · rw [rpow_def_of_neg (sub_neg.mpr (one_lt_pow₀ h (by decide : 2 ≠ 0))),show (5/2:ℝ)*π=π/2+2*π by ring,
      cos_add_two_pi,cos_pi_div_two,mul_zero]
  · simp [←h,zero_rpow (by norm_num : (5/2:ℝ)≠0)]

theorem bounds (x : Space) : 0≤shape x ∧ shape x≤1 := by
  by_cases h : ‖x‖<1
  · have nonneg := sub_nonneg.mpr ((sq_le_one_iff₀ (norm_nonneg x)).2 h.le)
    exact ⟨rpow_nonneg nonneg _, rpow_le_one nonneg (sub_le_self _ (sq_nonneg _)) (by norm_num)⟩
  · simp [zero (le_of_not_gt h)]

theorem squared (x : Space) : shape x^2 = if ‖x‖<1 then (1-‖x‖^2)^5 else 0 := by
  split
  next h =>
    unfold shape
    rw [←rpow_mul_natCast (sub_nonneg.mpr ((sq_le_one_iff₀ (norm_nonneg x)).2 h.le))]
    norm_num
  next h => simp [zero (le_of_not_gt h)]

private theorem first (x : Space) :
    fderiv ℝ shape x = (-5*(1-‖x‖^2)^(3/2:ℝ)) • innerSL ℝ x := by
  have h := ((hasFDerivAt_const (1:ℝ) x).sub (hasStrictFDerivAt_norm_sq x).hasFDerivAt).rpow_const
    (p:=5/2) (Or.inr (by norm_num))
  rw [show fderiv ℝ shape x = _ from h.fderiv]
  ext v
  simp [smul_eq_mul]
  norm_num
  ring

private theorem second (x v : Space) :
    iteratedFDeriv ℝ 2 shape x ![v,v] =
      15*(1-‖x‖^2)^(1/2:ℝ)*⟪x,v⟫^2-5*(1-‖x‖^2)^(3/2:ℝ)*‖v‖^2 := by
  have h := ((hasFDerivAt_const (1:ℝ) x).sub (hasStrictFDerivAt_norm_sq x).hasFDerivAt).rpow_const
    (p:=3/2) (Or.inr (by norm_num))
  have D := (h.const_mul (-5)).smul ((innerSL ℝ (E:=Space)).hasFDerivAt (x:=x))
  rw [iteratedFDeriv_two_apply, show fderiv ℝ shape = _ from funext first,
    show fderiv ℝ (fun y : Space => (-5*(1-‖y‖^2)^(3/2:ℝ)) • innerSL ℝ y) x = _ from D.fderiv]
  simp [smul_eq_mul]
  norm_num
  change -(_ * ⟪v,v⟫) + _ * ⟪x,v⟫ = _
  rw [real_inner_self_eq_norm_sq]
  ring

/-- Pointwise numerator of the physical kinetic expectation. -/
theorem shape_laplacian (x : Space) :
    shape x * (Δ shape) x =
      if ‖x‖<1 then 15*‖x‖^2*(1-‖x‖^2)^3-15*(1-‖x‖^2)^4 else 0 := by
  split
  next h =>
    rw [laplacian_eq_iteratedFDeriv_orthonormalBasis shape (EuclideanSpace.basisFun (Fin 3) ℝ)]
    simp_rw [second]
    have pos := sub_pos.mpr ((sq_lt_one_iff₀ (norm_nonneg x)).2 h)
    have a : shape x * (1-‖x‖^2)^(1/2:ℝ) = (1-‖x‖^2)^3 := by
      rw [shape,←rpow_add pos]; norm_num
    have b : shape x * (1-‖x‖^2)^(3/2:ℝ) = (1-‖x‖^2)^4 := by
      rw [shape,←rpow_add pos]; norm_num
    simp [Finset.sum_sub_distrib,←Finset.mul_sum,EuclideanSpace.inner_single_right]
    rw [EuclideanSpace.real_norm_sq_eq x] at a b ⊢
    simp only [one_div] at a ⊢
    linear_combination 15*(∑ i, x i^2)*a-15*b
  next h => simp [zero (le_of_not_gt h)]

/-- Radial integration for functions truncated to the three-dimensional unit ball. -/
theorem radialBallOfRadius (R : ℝ) (hR : 0≤R) (P : ℝ → ℝ) :
    (∫ x : Space, if ‖x‖<R then P ‖x‖ else 0) = 4*π*∫ r in (0:ℝ)..R, r^2*P r := by
  rw [integral_fun_norm_addHaar (volume : Measure Space) (fun r => if r<R then P r else 0)]
  simp only [finrank_euclideanSpace_fin,Nat.reduceSub,nsmul_eq_mul,smul_eq_mul,Measure.real,
    EuclideanSpace.volume_ball_fin_three,ENNReal.ofReal_one,one_pow,one_mul,
    ENNReal.toReal_ofReal (show 0≤π*4/3 by positivity)]
  have eq (r : ℝ) : r^2*(if r<R then P r else 0)=(Iio R).indicator (fun r => r^2*P r) r := by
    by_cases h : r<R <;> simp [Set.indicator,h]
  simp_rw [eq]
  rw [integral_indicator measurableSet_Iio,Measure.restrict_restrict measurableSet_Iio,
    inter_comm,Ioi_inter_Iio,intervalIntegral.integral_of_le hR,integral_Ioc_eq_integral_Ioo]
  ring

theorem radialBall (P : ℝ → ℝ) :
    (∫ x : Space, if ‖x‖<1 then P ‖x‖ else 0) = 4*π*∫ r in (0:ℝ)..1, r^2*P r :=
  radialBallOfRadius 1 zero_le_one P

open Polynomial

def massPrimitive : ℝ[X] :=
  C (1/3)*X^3-X^5+C (10/7)*X^7-C (10/9)*X^9+C (5/11)*X^11-C (1/13)*X^13

private def kineticPrimitive : ℝ[X] :=
  C (5/2)*X^3-C (15/2)*X^5+C (135/14)*X^7-C (35/6)*X^9+C (15/11)*X^11

theorem cumulative (r : ℝ) :
    (∫ u in (0:ℝ)..r, u^2*(1-u^2)^5) = massPrimitive.eval r := by
  have d u : HasDerivAt (fun x => massPrimitive.eval x) (u^2*(1-u^2)^5) u := by
    convert massPrimitive.hasDerivAt u using 1
    simp [massPrimitive]
    ring
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun u _ => d u) (by apply Continuous.intervalIntegrable; fun_prop)]
  simp [massPrimitive]

theorem volumeMass : (∫ x : Space, shape x^2) = 4*π*(256/9009) := by
  simp_rw [squared]
  rw [radialBall (fun r => (1-r^2)^5),cumulative]
  norm_num [massPrimitive]

theorem kineticNumerator :
    (∫ x : Space, -(1/2:ℝ)*(shape x*(Δ shape) x)) = 4*π*(256/9009)*(195/32) := by
  simp_rw [shape_laplacian,mul_ite,mul_zero]
  rw [radialBall (fun r => -(1/2:ℝ)*(15*r^2*(1-r^2)^3-15*(1-r^2)^4))]
  have d u : HasDerivAt (fun x => kineticPrimitive.eval x)
      (u^2*(-(1/2:ℝ)*(15*u^2*(1-u^2)^3-15*(1-u^2)^4))) u := by
    convert kineticPrimitive.hasDerivAt u using 1
    simp [kineticPrimitive]; ring
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun u _ => d u) (by apply Continuous.intervalIntegrable; fun_prop)]
  norm_num [kineticPrimitive]
  ring

end FQChem.Complexity.FixedBasisRadial
