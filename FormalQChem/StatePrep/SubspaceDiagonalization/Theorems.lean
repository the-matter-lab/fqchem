module

public import Mathlib.Analysis.InnerProductSpace.Rayleigh
public import Mathlib.Analysis.InnerProductSpace.Projection.Basic

/-! # Ritz–Galerkin orthogonality

The trial space may have arbitrary dimension as long as its orthogonal projection
exists. A finite-dimensional trial space in a Hilbert space meets this condition.

References: [Ritz (1909)](https://doi.org/10.1515/crll.1909.135.1) and
[Galerkin (1915)](https://www.mathnet.ru/PresentFiles/29594/galerkin_150_bubnov_galerkin_method.pdf). -/

@[expose] public section

namespace FormalQChem.StatePrep.SubspaceDiagonalization

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- Compression of the Hamiltonian to the trial space, `Pᵥ H|ᵥ`. -/
noncomputable def projected (H : E →L[ℂ] E) (V : Submodule ℂ E) [V.HasOrthogonalProjection] :
    V →L[ℂ] V := V.orthogonalProjectionOnto.comp (H.comp V.subtypeL)

/-- A nonzero trial vector gives a Ritz pair exactly when the unreduced Schrödinger
residual is perpendicular to every vector in the trial space. -/
def ResidualCriterion (H : E →L[ℂ] E) (V : Submodule ℂ E) [V.HasOrthogonalProjection] : Prop :=
  ∀ (x : V) (energy : ℂ), Module.End.HasEigenvector (projected H V).toLinearMap energy x ↔
    x ≠ 0 ∧ H (x : E) - energy • (x : E) ∈ Vᗮ

end FormalQChem.StatePrep.SubspaceDiagonalization
