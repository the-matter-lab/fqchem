module

public import FormalQChem.StatePrep.VariationalOptimization.RayleighRitz.Proofs
public import FormalQChem.StatePrep.SubspaceDiagonalization.ConfigurationInteraction.Theorems

@[expose] public section

namespace FormalQChem.VariationalMethods

open FormalQChem.RayleighRitz
open scoped BigOperators Matrix
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

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
