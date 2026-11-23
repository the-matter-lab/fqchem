module

public import FormalQChem.StatePrep.VariationalOptimization.RayleighRitz.Proofs
public import FormalQChem.StatePrep.VariationalOptimization.VQE.Theorems

@[expose] public section

namespace FormalQChem.VariationalMethods

open FormalQChem.RayleighRitz
open scoped BigOperators Matrix
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

theorem vqe {Θ : Type*} (H : E →L[ℂ] E) (U : Θ → E ≃ₗᵢ[ℂ] E) (ref : E) : VQE H U ref := by
  intro href θ
  have hn : ‖U θ ref‖ = 1 := (LinearIsometryEquiv.norm_map _ _).trans href
  have hne : U θ ref ≠ 0 := fun h ↦ by simp [h] at hn
  constructor
  · simpa [ContinuousLinearMap.rayleighQuotient, hn] using groundEnergy_le H hne
  · intro heig
    rw [ContinuousLinearMap.reApplyInnerSelf_apply, heig, inner_smul_left]
    simp [inner_self_eq_norm_sq_to_K, hn]

theorem reachableVQEMinimum {Θ : Type*} (H : E →L[ℂ] E) (U : Θ → E ≃ₗᵢ[ℂ] E) (ref : E) :
    ReachableVQEMinimum H U ref := by
  rintro href ⟨θ₀, hground⟩
  refine ⟨⟨θ₀, (vqe H U ref href θ₀).2 hground⟩, ?_⟩
  rintro _ ⟨θ, rfl⟩
  exact (vqe H U ref href θ).1

end FormalQChem.VariationalMethods
