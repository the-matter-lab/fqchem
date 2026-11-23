module

public import Mathlib.Analysis.Normed.Algebra.MatrixExponential
public import Mathlib.Analysis.Complex.Basic
import Mathlib.Tactic

@[expose] public section
noncomputable section

namespace FQChem.Algorithms

/-- For commuting local generators, n product-formula steps exactly implement the
matrix exponential of the sum for the full duration. Time-step factors are absorbed into A, B. -/
def CommutingProductFormula (d : ℕ) : Prop :=
  ∀ (A B : Matrix (Fin d) (Fin d) ℂ), Commute A B → ∀ n : ℕ,
    (NormedSpace.exp A * NormedSpace.exp B) ^ n = NormedSpace.exp (n • (A + B))

theorem commutingProductFormula (d : ℕ) : CommutingProductFormula d := by
  intro A B h n
  rw [← Matrix.exp_add_of_commute A B h, Matrix.exp_nsmul]

end FQChem.Algorithms
