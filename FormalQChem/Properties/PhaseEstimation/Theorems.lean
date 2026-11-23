module

public import Mathlib.Analysis.Fourier.ZMod

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- In ideal phase estimation with an exactly representable eigenphase m/N, the
normalized amplitude at output k is the Fourier sum of (m-k) and equals a Kronecker delta. -/
def ExactGridQPE (N : ℕ) [NeZero N] : Prop :=
  ∀ m k : ZMod N,
    (∑ j : ZMod N, ZMod.stdAddChar (j * (m - k))) / (N : ℂ) = if m = k then 1 else 0

end FormalQChem.Algorithms
