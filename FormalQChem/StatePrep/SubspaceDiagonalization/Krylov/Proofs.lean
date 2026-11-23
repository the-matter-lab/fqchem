module

public import FormalQChem.StatePrep.VariationalOptimization.RayleighRitz.Proofs
public import FormalQChem.StatePrep.SubspaceDiagonalization.Krylov.Theorems

@[expose] public section

namespace FormalQChem.VariationalMethods

open FormalQChem.RayleighRitz
open scoped BigOperators Matrix
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

private theorem orbit_step (H : E →L[ℂ] E) (step : E → E) (ψ : E) (hψ : ψ ≠ 0) (n : ℕ) :
    ritzEnergy H (orbitSpace step ψ (n + 1)) ≤ ritzEnergy H (orbitSpace step ψ n) := by
  apply (basisEnlargement H _ _ (Submodule.span_mono (Set.image_mono (Set.Iic_subset_Iic.mpr
    (Nat.le_succ n)))) ?_).2
  exact ⟨ψ, Submodule.subset_span ⟨0, Nat.zero_le _, rfl⟩, hψ⟩

theorem classicalKrylov (H : E →L[ℂ] E) (ψ : E) : ClassicalKrylov H ψ :=
  orbit_step H H ψ

theorem quantumKrylov (H : E →L[ℂ] E) (U : E ≃ₗᵢ[ℂ] E) (ψ : E) : QuantumKrylov H U ψ :=
  orbit_step H U ψ

end FormalQChem.VariationalMethods
