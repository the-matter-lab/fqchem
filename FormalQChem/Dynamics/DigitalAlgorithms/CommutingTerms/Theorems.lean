module

public import Mathlib.Analysis.Normed.Algebra.MatrixExponential
public import Mathlib.Analysis.Complex.Basic

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- For commuting local generators, n product-formula steps exactly implement the
matrix exponential of the sum for the full duration. Time-step factors are absorbed into A, B. -/
def CommutingProductFormula (d : ℕ) : Prop :=
  ∀ (A B : Matrix (Fin d) (Fin d) ℂ), Commute A B → ∀ n : ℕ,
    (NormedSpace.exp A * NormedSpace.exp B) ^ n = NormedSpace.exp (n • (A + B))

end FormalQChem.Algorithms
