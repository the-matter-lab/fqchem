module

public import FQChem.StatePrep.VariationalOptimization.RayleighRitz

@[expose] public section

namespace FQChem.VariationalMethods

open FQChem.RayleighRitz
open scoped BigOperators Matrix

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- Span of the iterates numbered 0 through n (including the reference). -/
def orbitSpace (step : E → E) (ψ : E) (n : ℕ) : Submodule ℂ E :=
  Submodule.span ℂ ((fun j : ℕ ↦ step^[j] ψ) '' Set.Iic n)

/-- H-generated Lanczos spaces give monotonically improving lowest Ritz energies. -/
def ClassicalKrylov (H : E →L[ℂ] E) (ψ : E) : Prop :=
  ψ ≠ 0 → ∀ n, ritzEnergy H (orbitSpace H ψ (n + 1)) ≤ ritzEnergy H (orbitSpace H ψ n)

/-- Time steps via a unitary evolution U generate nested quantum Krylov spaces. -/
def QuantumKrylov (H : E →L[ℂ] E) (U : E ≃ₗᵢ[ℂ] E) (ψ : E) : Prop :=
  ψ ≠ 0 → ∀ n, ritzEnergy H (orbitSpace U ψ (n + 1)) ≤ ritzEnergy H (orbitSpace U ψ n)

private theorem orbit_step (H : E →L[ℂ] E) (step : E → E) (ψ : E) (hψ : ψ ≠ 0) (n : ℕ) :
    ritzEnergy H (orbitSpace step ψ (n + 1)) ≤ ritzEnergy H (orbitSpace step ψ n) := by
  apply (basisEnlargement H _ _ (Submodule.span_mono (Set.image_mono (Set.Iic_subset_Iic.mpr
    (Nat.le_succ n)))) ?_).2
  exact ⟨ψ, Submodule.subset_span ⟨0, Nat.zero_le _, rfl⟩, hψ⟩

theorem classicalKrylov (H : E →L[ℂ] E) (ψ : E) : ClassicalKrylov H ψ :=
  orbit_step H H ψ

theorem quantumKrylov (H : E →L[ℂ] E) (U : E ≃ₗᵢ[ℂ] E) (ψ : E) : QuantumKrylov H U ψ :=
  orbit_step H U ψ

end FQChem.VariationalMethods
