module

public import Mathlib.Analysis.Calculus.Deriv.Add
public import Mathlib.Analysis.SpecialFunctions.Log.Basic
public import Mathlib.Algebra.BigOperators.Field
public import Mathlib.Data.EReal.Basic

@[expose] public section

namespace FormalQChem.Multiscale

open scoped BigOperators

/-- FMO2 monomer plus dimer-increment reconstruction. -/
def fragmentEnergy {n : ℕ} (mono : Fin n → ℝ) (dimer : Fin n → Fin n → ℝ) :=
  (∑ i, mono i) + ∑ i, ∑ j ∈ Finset.univ.filter (i < ·), (dimer i j - mono i - mono j)

/-- Reconstruction is exact in a pair-additive model with consistent dimer energies. -/
def PairReconstruction : Prop :=
  ∀ {n : ℕ} (mono : Fin n → ℝ) (dimer interaction : Fin n → Fin n → ℝ),
    (∀ i j, i < j → dimer i j = mono i + mono j + interaction i j) →
    fragmentEnergy mono dimer =
      (∑ i, mono i) + ∑ i, ∑ j ∈ Finset.univ.filter (i < ·), interaction i j

end FormalQChem.Multiscale
