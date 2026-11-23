module

public import Mathlib.LinearAlgebra.Vandermonde
public import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic

@[expose] public section
noncomputable section

namespace FQChem.Algorithms

/-- Samples at times k Δτ of a discrete imaginary-time spectrum at known energies. -/
def laplaceSample {n : ℕ} (Δτ : ℝ) (energy weight : Fin n → ℝ) (k : ℕ) :=
  ∑ j, weight j * Real.exp (-Δτ * energy j) ^ k

/-- At n distinct known energies, n exact equally spaced samples determine all spectral weights. -/
def SpectralIdentification (n : ℕ) : Prop :=
  ∀ (Δτ : ℝ) (energy a b : Fin n → ℝ), 0 < Δτ → Function.Injective energy →
    (∀ k : Fin n, laplaceSample Δτ energy a k = laplaceSample Δτ energy b k) → a = b

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

end FQChem.Algorithms
