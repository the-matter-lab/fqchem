module

public import FormalQChem.StatePrep.VariationalOptimization.RayleighRitz

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

theorem selectedCI {ι : Type*} (H : E →L[ℂ] E) (determinant : ι → E) :
    SelectedCI H determinant := by
  rintro A B hAB ⟨i, hi, hi0⟩
  exact (basisEnlargement H _ _ (Submodule.span_mono (Set.image_mono hAB))
    ⟨determinant i, Submodule.subset_span ⟨i, hi, rfl⟩, hi0⟩).2

theorem sampledDiagonalization {ι : Type*} (H : E →L[ℂ] E) (config : ι → E) (samples : Set ι) :
    SampledDiagonalization H config samples := by
  intro ψ hψ hne hmin
  apply le_antisymm
  · rw [← hmin]
    exact ritzEnergy_le H hψ hne
  · exact (basisEnlargement H _ _ le_rfl ⟨ψ, hψ, hne⟩).1

end FormalQChem.VariationalMethods
