module

public import FormalQChem.Dynamics.DigitalAlgorithms.CommutingTerms.Theorems
import Mathlib.Tactic

public section
namespace FormalQChem.Algorithms

theorem commutingProductFormula (d : ℕ) : CommutingProductFormula d := by
  intro A B h n
  rw [← Matrix.exp_add_of_commute A B h, Matrix.exp_nsmul]

end FormalQChem.Algorithms
