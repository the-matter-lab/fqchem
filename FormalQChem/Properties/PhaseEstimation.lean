module

public import Mathlib.Analysis.Fourier.ZMod
import Mathlib.Tactic

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- In ideal phase estimation with an exactly representable eigenphase m/N, the
normalized amplitude at output k is the Fourier sum of (m-k) and equals a Kronecker delta. -/
def ExactGridQPE (N : ℕ) [NeZero N] : Prop :=
  ∀ m k : ZMod N,
    (∑ j : ZMod N, ZMod.stdAddChar (j * (m - k))) / (N : ℂ) = if m = k then 1 else 0

theorem exactGridQPE (N : ℕ) [NeZero N] : ExactGridQPE N := by
  intro m k
  rw [AddChar.sum_mulShift _ (ZMod.isPrimitive_stdAddChar N)]
  by_cases h : m = k
  · simp [h, ZMod.card, NeZero.ne (N : ℂ)]
  · simp [h, sub_ne_zero.mpr h]

end FormalQChem.Algorithms
