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
  have ratio : A * Real.exp (-β * approx) / (A * Real.exp (-β * exact)) =
      Real.exp (-β * (approx - exact)) := by
    rw [mul_div_mul_left _ _ hA.ne', ← Real.exp_sub]
    congr 1
    ring
  rw [ratio]
  constructor <;> apply Real.exp_le_exp.mpr <;> nlinarith [mul_le_mul_of_nonneg_left hu hβ,
    mul_le_mul_of_nonneg_left hl hβ]

end FQChem.Multiscale
