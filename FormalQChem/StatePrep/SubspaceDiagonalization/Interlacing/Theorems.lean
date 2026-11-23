module

public import FormalQChem.StatePrep.SubspaceDiagonalization.Theorems
public import Mathlib.Analysis.InnerProductSpace.Spectrum

/-! # Ritz eigenvalue interlacing

Mathlib numbers Hermitian eigenvalues in decreasing order, counting multiplicities.
For a trial subspace of codimension d the kth Ritz value lies between the kth
and (k+d)th full eigenvalues. In increasing order this gives an upper bound for
every energy level accessible in the trial calculation.
[MacDonald (1933)](https://doi.org/10.1103/PhysRev.43.830). -/

@[expose] public section

namespace FormalQChem.StatePrep.SubspaceDiagonalization.Interlacing

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [FiniteDimensional ℂ E]

/-- Embed kth index with the codimension offset. -/
def shiftedIndex {m n : ℕ} (hmn : m ≤ n) (k : Fin m) : Fin n :=
  ⟨k.val + (n - m), by omega⟩

/-- Two-sided Poincaré separation for the actual sorted spectra of a finite
Hermitian operator and its orthogonal compression to any trial subspace. -/
def RitzInterlacing (H : E →L[ℂ] E) (V : Submodule ℂ E) (hermitian : H.toLinearMap.IsSymmetric) :
    Prop :=
  ∃ hV : (projected H V).toLinearMap.IsSymmetric, ∀ k : Fin (Module.finrank ℂ V),
    hermitian.eigenvalues rfl (shiftedIndex V.finrank_le k) ≤ hV.eigenvalues rfl k ∧
    hV.eigenvalues rfl k ≤ hermitian.eigenvalues rfl (k.castLE V.finrank_le)

end FormalQChem.StatePrep.SubspaceDiagonalization.Interlacing
