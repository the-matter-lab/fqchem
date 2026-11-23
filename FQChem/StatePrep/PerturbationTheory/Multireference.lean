module

public import Mathlib.Analysis.Complex.Basic
public import Mathlib.Analysis.Normed.Algebra.MatrixExponential

@[expose] public section

namespace FQChem.VariationalMethods

open scoped BigOperators Matrix

/-- The second-order external-space shift for a multiconfigurational reference is
nonpositive if every external class has a strictly positive energy gap. -/
def MRPT2Shift {ι : Type*} [Fintype ι] (coupling : ι → ℂ) (gap : ι → ℝ) : Prop :=
  (∀ i, 0 < gap i) → (∑ i, -(Complex.normSq (coupling i) / gap i)) ≤ 0

theorem mrpt2Shift {ι : Type*} [Fintype ι] (coupling : ι → ℂ) (gap : ι → ℝ) :
    MRPT2Shift coupling gap := by
  intro hg
  exact Finset.sum_nonpos fun i _ ↦ neg_nonpos.mpr
    (div_nonneg (Complex.normSq_nonneg _) (hg i).le)

end FQChem.VariationalMethods
