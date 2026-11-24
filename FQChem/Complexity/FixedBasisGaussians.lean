module

public import Mathlib.Analysis.SpecialFunctions.Gaussian.FourierTransform
public import Mathlib.MeasureTheory.Group.Integral
import Mathlib.Tactic

/-! # Primitive Gaussian integrals in the fixed-basis reduction

The orbitals are normalized s-type Gaussians on Euclidean three-space.
Completing the square gives their overlap and the exchange and three-center
reductions for the physical Coulomb kernel, as used by O'Gorman et al.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.FixedBasisGaussians
open MeasureTheory Real
open scoped InnerProductSpace

abbrev Space := EuclideanSpace ℝ (Fin 3)

def amplitude (a : ℝ) := (2*a/π) ^ (3/4 : ℝ)
def orbital (a : ℝ) (A r : Space) := amplitude a * exp (-a * ‖r-A‖^2)
def center (a b : ℝ) (A B : Space) := (a/(a+b)) • A + (b/(a+b)) • B

private theorem completeSquare (a b : ℝ) (hab : a+b ≠ 0) (A B r : Space) :
    a*‖r-A‖^2 + b*‖r-B‖^2 =
      (a+b)*‖r-center a b A B‖^2 + a*b/(a+b)*‖A-B‖^2 := by
  simp only [center, ← real_inner_self_eq_norm_sq, inner_sub_left, inner_sub_right,
    inner_add_left, inner_add_right, real_inner_smul_left, real_inner_smul_right]
  simp only [real_inner_comm A r, real_inner_comm B r, real_inner_comm B A]
  field_simp
  ring

theorem overlap (a b : ℝ) (ha : 0<a) (hb : 0<b) (A B : Space) :
    (∫ r, orbital a A r * orbital b B r) =
      amplitude a * amplitude b * (π/(a+b))^(3/2 : ℝ) *
      exp (-(a*b/(a+b))*‖A-B‖^2) := by
  let c := amplitude a * amplitude b * exp (-(a*b/(a+b))*‖A-B‖^2)
  have product (r : Space) : orbital a A r * orbital b B r =
      c * exp (-(a+b)*‖r-center a b A B‖^2) := by
    unfold orbital c
    rw [show amplitude a * exp (-a*‖r-A‖^2) * (amplitude b * exp (-b*‖r-B‖^2)) =
      amplitude a * amplitude b * (exp (-a*‖r-A‖^2)*exp (-b*‖r-B‖^2)) by ring,
      ← Real.exp_add, mul_assoc (amplitude a * amplitude b), ← Real.exp_add]
    congr 2
    linarith [completeSquare a b (by positivity) A B r]
  simp_rw [product]
  rw [integral_const_mul, integral_sub_right_eq_self (fun r : Space => exp (-(a+b)*‖r‖^2)),
    GaussianFourier.integral_rexp_neg_mul_sq_norm (by positivity)]
  dsimp [c]
  simp only [finrank_euclideanSpace_fin]
  push_cast
  ring

private theorem normalization (a : ℝ) (ha : 0<a) :
    amplitude a * amplitude a * (π/(a+a))^(3/2:ℝ) = 1 := by
  rw [amplitude, ← Real.rpow_add (by positivity)]
  norm_num
  rw [← Real.mul_rpow (by positivity) (by positivity)]
  rw [show 2*a/π*(π/(a+a)) = 1 by field_simp; ring, Real.one_rpow]

/-- Equal exponents give the pure exponential overlap in Eqs. (C8) and (C9). -/
theorem overlap_same (a : ℝ) (ha : 0<a) (A B : Space) :
    (∫ r, orbital a A r * orbital a B r) = exp (-(a/2)*‖A-B‖^2) := by
  rw [overlap a a ha ha, normalization a ha, one_mul]
  rw [show a*a/(a+a) = a/2 by field_simp; ring]

theorem orbital_normalized (a : ℝ) (ha : 0<a) (A : Space) :
    (∫ r, orbital a A r ^ 2) = 1 := by
  simpa [sq] using overlap_same a ha A A

def midpoint (A B : Space) := (1/2 : ℝ) • A + (1/2 : ℝ) • B

theorem pairDensity (a : ℝ) (ha : 0<a) (A B r : Space) :
    orbital a A r * orbital a B r = exp (-(a/2)*‖A-B‖^2) * orbital a (midpoint A B) r ^ 2 := by
  have hav : a/(a+a) = 1/2 := by field_simp; ring
  have hav' : a*a/(a+a) = a/2 := by field_simp; ring
  have complete := completeSquare a a (by positivity) A B r
  simp only [center,hav,hav'] at complete
  change a*‖r-A‖^2 + a*‖r-B‖^2 = (a+a)*‖r-midpoint A B‖^2 + a/2*‖A-B‖^2 at complete
  unfold orbital
  simp only [mul_pow, ← Real.exp_nat_mul, Nat.cast_ofNat]
  rw [show amplitude a * exp (-a*‖r-A‖^2) * (amplitude a * exp (-a*‖r-B‖^2)) =
    (amplitude a)^2 * (exp (-a*‖r-A‖^2)*exp (-a*‖r-B‖^2)) by ring,
    ← Real.exp_add, mul_left_comm (exp _) ((amplitude a)^2), ← Real.exp_add]
  congr 2
  linarith

/-- The unregularized six-dimensional Coulomb integral for four primitives,
with a density product at each of its two integration points. -/
def repulsion (a : ℝ) (A B C D : Space) : ℝ :=
  ∫ r : Space, ∫ s : Space,
    (orbital a A r * orbital a B r) * (orbital a C s * orbital a D s) / ‖r-s‖

def coulomb (a : ℝ) (A B : Space) := repulsion a A A B B

/-- Equations (C15) and (C16) both follow from the product of two Gaussian
density factors. The centers of the remaining Coulomb integral are midpoints. -/
theorem repulsion_reduction (a : ℝ) (ha : 0<a) (A B C D : Space) :
    repulsion a A B C D = exp (-(a/2)*‖A-B‖^2) * exp (-(a/2)*‖C-D‖^2) *
      coulomb a (midpoint A B) (midpoint C D) := by
  unfold coulomb repulsion
  simp_rw [pairDensity a ha A B, pairDensity a ha C D]
  let x := exp (-(a/2)*‖A-B‖^2)
  let y := exp (-(a/2)*‖C-D‖^2)
  let f := fun r => orbital a (midpoint A B) r
  let g := fun s => orbital a (midpoint C D) s
  change (∫ r, ∫ s, (x*f r^2)*(y*g s^2)/‖r-s‖) =
    x*y * ∫ r, ∫ s, (f r*f r)*(g s*g s)/‖r-s‖
  simp_rw [show ∀ r s : Space, (x*f r^2)*(y*g s^2)/‖r-s‖ = (x*y)*((f r*f r)*(g s*g s)/‖r-s‖)
    from fun r s => by ring,integral_const_mul]

end FQChem.Complexity.FixedBasisGaussians
