module

public import FormalQChem.Properties.PhaseEstimation.Theorems
import Mathlib.Tactic

public section
namespace FormalQChem.Algorithms

theorem exactGridQPE (N : ℕ) [NeZero N] : ExactGridQPE N := by
  intro m k
  rw [AddChar.sum_mulShift _ (ZMod.isPrimitive_stdAddChar N)]
  by_cases h : m = k
  · simp [h, ZMod.card, NeZero.ne (N : ℂ)]
  · simp [h, sub_ne_zero.mpr h]

end FormalQChem.Algorithms
