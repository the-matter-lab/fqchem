module

public import FormalQChem.StatePrep.VariationalOptimization.RayleighRitz.Theorems

@[expose] public section

namespace FormalQChem.VariationalMethods
open FormalQChem.RayleighRitz
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

end FormalQChem.VariationalMethods
