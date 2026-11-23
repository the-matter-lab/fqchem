module

public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- The exact spectral-inversion step in HHL. On input supported on nonzero
eigenvalues, applying their reciprocals to the input coefficients solves the linear system. -/
def HHLSpectralInversion (d k : ℕ) : Prop :=
  ∀ (A : (Fin d → ℂ) →ₗ[ℂ] (Fin d → ℂ)) (u : Fin k → Fin d → ℂ)
    (eigenvalue b : Fin k → ℂ), (∀ j, A (u j) = eigenvalue j • u j) → (∀ j, eigenvalue j ≠ 0) →
      A (∑ j, (b j / eigenvalue j) • u j) = ∑ j, b j • u j

/-- Exact sine eigenmode of the one-dimensional Dirichlet finite-difference Poisson
stencil used in quantum linear-system discretizations. The interior contains N sites. -/
def DirichletPoissonMode (N m : ℕ) : Prop :=
  0 < m → m ≤ N → ∀ h : ℝ, 0 < h →
    let θ := (m : ℝ) * Real.pi / (N + 1)
    let u := fun j : ℤ => Real.sin (j * θ)
    0 < u 1 ∧ u 0 = 0 ∧ u (N + 1) = 0 ∧ ∀ j : ℤ,
      (2 * u j - u (j-1) - u (j+1)) / h^2 = ((2-2*Real.cos θ) / h^2) * u j

end FormalQChem.Algorithms
