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

/-- Two-layer subtractive ONIOM energy along a nuclear coordinate. -/
def layered (fullLow modelHigh modelLow : ℝ → ℝ) (x : ℝ) :=
  fullLow x + modelHigh x - modelLow x

/-- Forces are negative derivatives of the three energy surfaces. -/
def LayeredForce : Prop :=
  ∀ (full high low : ℝ → ℝ) (x f h l : ℝ),
    HasDerivAt full (-f) x → HasDerivAt high (-h) x → HasDerivAt low (-l) x →
    HasDerivAt (layered full high low) (-(f + h - l)) x

theorem layeredForce : LayeredForce := by
  intro full high low x f h l hf hh hl
  have d := (hf.add hh).sub hl
  convert d using 1
  · rfl
  · ring

end FQChem.Multiscale
