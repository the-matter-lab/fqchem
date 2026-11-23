module

public import Mathlib.Algebra.BigOperators.Group.Finset.Basic
public import Mathlib.Basic.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Lemmas

/-!
# Energy accounting at an overlapping subsystem boundary
-/

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

namespace FormalQChem.Multiscale.Partitions

theorem overlapAccounting {α ι : Type*} [DecidableEq α] [Fintype ι]
    (support : ι → Finset α) (weight : ι → ℝ) (A B : Finset α) :
    OverlapAccounting support weight A B := by
  unfold OverlapAccounting regionEnergy boundaryEnergy
  rw [← Finset.sum_add_distrib, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  by_cases ha : support i ⊆ A
  · have hu := ha.trans (Finset.subset_union_left (s₂ := B))
    by_cases hb : support i ⊆ B <;> simp [ha, hb, hu, Finset.subset_inter_iff]
  · by_cases hb : support i ⊆ B
    · have hu := hb.trans (Finset.subset_union_right (s₁ := A))
      simp [ha, hb, hu, Finset.subset_inter_iff]
    · simp [ha, hb, Finset.subset_inter_iff]

end FormalQChem.Multiscale.Partitions
