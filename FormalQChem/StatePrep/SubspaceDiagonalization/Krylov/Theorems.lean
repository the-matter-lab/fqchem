module

public import FormalQChem.StatePrep.VariationalOptimization.RayleighRitz.Theorems

@[expose] public section

namespace FormalQChem.VariationalMethods
open FormalQChem.RayleighRitz
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

end FormalQChem.VariationalMethods
