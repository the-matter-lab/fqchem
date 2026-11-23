module

public import FormalQChem.Multiscale.ChoosingLayers.Partitions.Theorems
import Mathlib.Algebra.BigOperators.Group.Finset.Lemmas

public section
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
