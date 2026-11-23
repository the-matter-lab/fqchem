module

public import FormalQChem.StatePrep.VariationalOptimization.MonteCarlo.Theorems
import Mathlib.Tactic

public section
namespace FormalQChem.Algorithms

theorem variationalMonteCarlo (n : ℕ) : VariationalMonteCarlo n := by
  intro H ψ _ _
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  by_cases h : ψ i = 0
  · simp [h]
  · field_simp

end FormalQChem.Algorithms
