module

public import FormalQChem.Properties.ResponseAndEstimation.SpectralReconstruction.Theorems
import Mathlib.Tactic

public section
namespace FormalQChem.Algorithms

theorem spectralIdentification (n : ℕ) : SpectralIdentification n := by
  intro dt energy a b hdt he hsample
  let z := fun j => Real.exp (-dt * energy j)
  have hz : Function.Injective z := by
    intro i j hij
    apply he
    exact mul_left_cancel₀ (neg_ne_zero.mpr hdt.ne') (Real.exp_injective hij)
  apply sub_eq_zero.mp
  apply Matrix.eq_zero_of_forall_pow_sum_mul_pow_eq_zero hz
  intro k
  simpa only [Pi.sub_apply, sub_mul, Finset.sum_sub_distrib, sub_eq_zero, z, laplaceSample]
    using sub_eq_zero.mpr (hsample k)

end FormalQChem.Algorithms
