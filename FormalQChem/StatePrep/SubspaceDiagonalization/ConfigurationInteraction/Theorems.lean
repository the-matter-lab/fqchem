module

public import FormalQChem.StatePrep.VariationalOptimization.RayleighRitz.Theorems

@[expose] public section

namespace FormalQChem.VariationalMethods
open FormalQChem.RayleighRitz
open scoped BigOperators Matrix

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- Enlarge a selected CI space by including more determinant configurations. -/
def SelectedCI {ι : Type*} (H : E →L[ℂ] E) (determinant : ι → E) : Prop :=
  ∀ (A B : Set ι), A ⊆ B → (∃ i ∈ A, determinant i ≠ 0) →
    ritzEnergy H (Submodule.span ℂ (determinant '' B)) ≤
      ritzEnergy H (Submodule.span ℂ (determinant '' A))

/-- Diagonalization in a sampled configuration span is exact whenever the recovered
span contains a minimizing state (even if most configurations were never sampled). -/
def SampledDiagonalization {ι : Type*} (H : E →L[ℂ] E) (config : ι → E) (samples : Set ι) : Prop :=
  ∀ ψ ∈ Submodule.span ℂ (config '' samples), ψ ≠ (0 : E) →
    H.rayleighQuotient ψ = groundEnergy H →
    ritzEnergy H (Submodule.span ℂ (config '' samples)) = groundEnergy H

end FormalQChem.VariationalMethods
