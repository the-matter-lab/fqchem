module

public import Mathlib.Algebra.BigOperators.Group.Finset.Basic
public import Mathlib.Basic.Real.Basic

/-! # Energy accounting at an overlapping subsystem boundary -/

@[expose] public section
namespace FormalQChem.Multiscale.Partitions

variable {α ι : Type*} [DecidableEq α] [Fintype ι]

/-- Energy of interaction terms whose entire support is contained in a region. -/
noncomputable def regionEnergy (support : ι → Finset α) (weight : ι → ℝ) (R : Finset α) : ℝ :=
  ∑ i, if support i ⊆ R then weight i else 0

/-- Terms supported in the union that neither subsystem contains on its own. -/
noncomputable def boundaryEnergy (support : ι → Finset α) (weight : ι → ℝ) (A B : Finset α) : ℝ :=
  ∑ i, if support i ⊆ A ∪ B ∧ ¬ support i ⊆ A ∧ ¬ support i ⊆ B then weight i else 0

/-- Subtracting terms counted in both layers and restoring cross-boundary interactions
recovers the union energy for any finite interaction expansion. -/
def OverlapAccounting (support : ι → Finset α) (weight : ι → ℝ) (A B : Finset α) : Prop :=
  regionEnergy support weight (A ∪ B) =
    regionEnergy support weight A + regionEnergy support weight B -
    regionEnergy support weight (A ∩ B) + boundaryEnergy support weight A B

end FormalQChem.Multiscale.Partitions
