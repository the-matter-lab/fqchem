module

public import FormalQChem.Multiscale.ChoosingLayers.ClassicalEnvironments.Theorems
public import Mathlib.Tactic.Ring
public import Mathlib.Tactic.Linarith

@[expose] public section

namespace FormalQChem.Multiscale

open scoped BigOperators

theorem layeredForce : LayeredForce := by
  intro full high low x f h l hf hh hl
  have d := (hf.add hh).sub hl
  convert d using 1
  · rfl
  · ring

end FormalQChem.Multiscale
