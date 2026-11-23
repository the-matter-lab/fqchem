module

public import FormalQChem.Multiscale.ChoosingLayers.LearnedEnvironments.Theorems
public import Mathlib.Tactic.Ring
public import Mathlib.Tactic.Linarith

@[expose] public section

namespace FormalQChem.Multiscale

open scoped BigOperators

theorem deltaLearningGap : DeltaLearningGap := by
  intro X hi lo predict x y ex ey hx hy
  have h := abs_sub (predict y - (hi y - lo y)) (predict x - (hi x - lo x))
  rw [show (lo y + predict y - (lo x + predict x) - (hi y - hi x)) =
    (predict y - (hi y - lo y)) - (predict x - (hi x - lo x)) by ring]
  exact h.trans ((add_le_add hy hx).trans_eq (add_comm ey ex))

end FormalQChem.Multiscale
