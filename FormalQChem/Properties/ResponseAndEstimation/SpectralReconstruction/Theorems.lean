module

public import Mathlib.LinearAlgebra.Vandermonde
public import Mathlib.Analysis.SpecialFunctions.Exp

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- Samples at times k Δτ of a discrete imaginary-time spectrum at known energies. -/
def laplaceSample {n : ℕ} (Δτ : ℝ) (energy weight : Fin n → ℝ) (k : ℕ) :=
  ∑ j, weight j * Real.exp (-Δτ * energy j) ^ k

/-- At n distinct known energies, n exact equally spaced samples determine all spectral weights. -/
def SpectralIdentification (n : ℕ) : Prop :=
  ∀ (Δτ : ℝ) (energy a b : Fin n → ℝ), 0 < Δτ → Function.Injective energy →
    (∀ k : Fin n, laplaceSample Δτ energy a k = laplaceSample Δτ energy b k) → a = b

end FormalQChem.Algorithms
