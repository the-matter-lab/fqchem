module

public import Mathlib.Analysis.Calculus.Deriv.Add
public import Mathlib.Analysis.SpecialFunctions.Log.Basic
public import Mathlib.Algebra.BigOperators.Field
public import Mathlib.Data.EReal.Basic
public import Mathlib.Tactic.Ring
public import Mathlib.Tactic.Linarith

@[expose] public section

namespace FQChem.Multiscale

open scoped BigOperators

/-- Adding a learned high-minus-low correction to the low-level surface bounds the
error in an energy difference by the sum of its endpoint correction errors. -/
def DeltaLearningGap : Prop :=
  ∀ {X : Type} (hi lo predict : X → ℝ) (x y : X) (ex ey : ℝ),
    |predict x - (hi x - lo x)| ≤ ex → |predict y - (hi y - lo y)| ≤ ey →
    |((lo y + predict y) - (lo x + predict x)) - (hi y - hi x)| ≤ ex + ey

theorem deltaLearningGap : DeltaLearningGap := by
  intro X hi lo predict x y ex ey hx hy
  have h := abs_sub (predict y - (hi y - lo y)) (predict x - (hi x - lo x))
  rw [show (lo y + predict y - (lo x + predict x) - (hi y - hi x)) =
    (predict y - (hi y - lo y)) - (predict x - (hi x - lo x)) by ring]
  exact h.trans ((add_le_add hy hx).trans_eq (add_comm ey ex))

end FQChem.Multiscale
