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

/-- At the same prefactor and temperature, a barrier error of at most ε gives
a multiplicative interval for the transition-state rate ratio. -/
def BarrierRateError : Prop :=
  ∀ (A β exact approx ε : ℝ), 0 < A → 0 ≤ β → |approx - exact| ≤ ε →
    let ratio := A * Real.exp (-β * approx) / (A * Real.exp (-β * exact))
    Real.exp (-β * ε) ≤ ratio ∧ ratio ≤ Real.exp (β * ε)

theorem barrierRateError : BarrierRateError := by
  intro A β exact approx ε hA hβ bound
  dsimp only
  obtain ⟨hl, hu⟩ := abs_le.mp bound
  rw [mul_div_mul_left _ _ hA.ne', ← Real.exp_sub, ← mul_sub,
    Real.exp_le_exp, Real.exp_le_exp]
  constructor
  · exact mul_le_mul_of_nonpos_left hu (neg_nonpos.mpr hβ)
  · simpa only [neg_mul, mul_neg, neg_neg] using
      mul_le_mul_of_nonpos_left hl (neg_nonpos.mpr hβ)

end FQChem.Multiscale
