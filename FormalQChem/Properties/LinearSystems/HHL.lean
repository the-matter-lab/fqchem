module

public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- The exact spectral-inversion step in HHL. On input supported on nonzero
eigenvalues, applying their reciprocals to the input coefficients solves the linear system. -/
def HHLSpectralInversion (d k : ℕ) : Prop :=
  ∀ (A : (Fin d → ℂ) →ₗ[ℂ] (Fin d → ℂ)) (u : Fin k → Fin d → ℂ)
    (eigenvalue b : Fin k → ℂ), (∀ j, A (u j) = eigenvalue j • u j) → (∀ j, eigenvalue j ≠ 0) →
      A (∑ j, (b j / eigenvalue j) • u j) = ∑ j, b j • u j

theorem hhlSpectralInversion (d k : ℕ) : HHLSpectralInversion d k := by
  intro A u eigenvalue b he hn
  rw [map_sum]
  apply Finset.sum_congr rfl
  intro j _
  rw [map_smul, he, smul_smul, div_mul_cancel₀ _ (hn j)]

end FormalQChem.Algorithms
