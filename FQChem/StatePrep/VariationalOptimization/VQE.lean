module

public import FQChem.StatePrep.VariationalOptimization.RayleighRitz

@[expose] public section

namespace FQChem.VariationalMethods

open FQChem.RayleighRitz
open scoped BigOperators Matrix

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- The ideal VQE objective is the real expectation value of H on the circuit output.
A normalized reference stays normalized; a reachable ground eigenstate attains the bound. -/
def VQE {Θ : Type*} (H : E →L[ℂ] E) (U : Θ → E ≃ₗᵢ[ℂ] E) (ref : E) : Prop :=
  ‖ref‖ = 1 → ∀ θ,
    groundEnergy H ≤ H.reApplyInnerSelf (U θ ref) ∧
    (H (U θ ref) = (groundEnergy H : ℂ) • U θ ref →
      H.reApplyInnerSelf (U θ ref) = groundEnergy H)

/-- If one parameter prepares a ground eigenstate, the ideal VQE energy minimum
over the entire parameter space exists and is exactly the ground energy. -/
def ReachableVQEMinimum {Θ : Type*} (H : E →L[ℂ] E) (U : Θ → E ≃ₗᵢ[ℂ] E) (ref : E) : Prop :=
  ‖ref‖ = 1 → (∃ θ, H (U θ ref) = (groundEnergy H : ℂ) • U θ ref) →
    IsLeast (Set.range fun θ ↦ H.reApplyInnerSelf (U θ ref)) (groundEnergy H)

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

end FQChem.VariationalMethods
