module

public import FormalQChem.StatePrep.SubspaceDiagonalization.Theorems

/-! # Proof of the Ritz–Galerkin residual criterion -/

@[expose] public section

namespace FormalQChem.StatePrep.SubspaceDiagonalization

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

theorem residualCriterion (H : E →L[ℂ] E) (V : Submodule ℂ E) [V.HasOrthogonalProjection] :
    ResidualCriterion H V := by
  intro x energy
  rw [Module.End.hasEigenvector_iff, Module.End.mem_eigenspace_iff,
    ← V.orthogonalProjectionOnto_eq_zero_iff, map_sub, map_smul,
    V.orthogonalProjectionOnto_mem_subspace_eq_self, sub_eq_zero]
  exact and_comm

end FormalQChem.StatePrep.SubspaceDiagonalization
