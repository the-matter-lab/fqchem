module

public import FormalQChem.StatePrep.VariationalOptimization.ExcitedStates.Theorems

@[expose] public section

namespace FormalQChem.VariationalMethods

open scoped BigOperators Matrix

private theorem weighted_bound {ι : Type*} [Fintype ι] {w e : ι → ℝ} {target : ℝ}
    (hw : ∑ i, w i = 1) (h : ∀ i, target * w i ≤ e i * w i) : target ≤ ∑ i, e i * w i :=
  calc target = ∑ i, target * w i := by rw [← Finset.mul_sum, hw, mul_one]
       _ ≤ _ := Finset.sum_le_sum fun i _ ↦ h i

theorem excitedStateBound {ι : Type*} [Fintype ι] (energy : ι → ℝ) (c : ι → ℂ) (target : ℝ) :
    ExcitedStateBound energy c target := by
  intro normed excluded
  refine weighted_bound normed fun i ↦ ?_
  by_cases h : energy i < target
  · simp [excluded i h]
  · exact mul_le_mul_of_nonneg_right (le_of_not_gt h) (Complex.normSq_nonneg _)

theorem quantumDeflation {ι : Type*} [Fintype ι] [DecidableEq ι]
    (energy penalty : ι → ℝ) (k : ι) : QuantumDeflation energy penalty k := by
  intro lifted zeroPenalty
  constructor
  · intro c hc
    exact weighted_bound hc fun i ↦
      mul_le_mul_of_nonneg_right (lifted i) (Complex.normSq_nonneg _)
  · simp [apply_ite, Finset.sum_ite_eq', zeroPenalty]

end FormalQChem.VariationalMethods
