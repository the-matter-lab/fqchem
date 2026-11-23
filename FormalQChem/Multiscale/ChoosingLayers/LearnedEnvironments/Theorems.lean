module

public import Mathlib.Analysis.Calculus.Deriv.Add
public import Mathlib.Analysis.SpecialFunctions.Log.Basic
public import Mathlib.Algebra.BigOperators.Field
public import Mathlib.Data.EReal.Basic

@[expose] public section

namespace FormalQChem.Multiscale

open scoped BigOperators

/-- Adding a learned high-minus-low correction to the low-level surface bounds the
error in an energy difference by the sum of its endpoint correction errors. -/
def DeltaLearningGap : Prop :=
  ∀ {X : Type} (hi lo predict : X → ℝ) (x y : X) (ex ey : ℝ),
    |predict x - (hi x - lo x)| ≤ ex → |predict y - (hi y - lo y)| ≤ ey →
    |((lo y + predict y) - (lo x + predict x)) - (hi y - hi x)| ≤ ex + ey

end FormalQChem.Multiscale
