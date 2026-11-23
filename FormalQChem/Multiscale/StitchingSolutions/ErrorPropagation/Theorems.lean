module

public import Mathlib.Analysis.Calculus.Deriv.Add
public import Mathlib.Analysis.SpecialFunctions.Log.Basic
public import Mathlib.Algebra.BigOperators.Field
public import Mathlib.Data.EReal.Basic

@[expose] public section

namespace FormalQChem.Multiscale

open scoped BigOperators

/-- At the same prefactor and temperature, a barrier error of at most ε gives
a multiplicative interval for the transition-state rate ratio. -/
def BarrierRateError : Prop :=
  ∀ (A β exact approx ε : ℝ), 0 < A → 0 ≤ β → |approx - exact| ≤ ε →
    let ratio := A * Real.exp (-β * approx) / (A * Real.exp (-β * exact))
    Real.exp (-β * ε) ≤ ratio ∧ ratio ≤ Real.exp (β * ε)

end FormalQChem.Multiscale
