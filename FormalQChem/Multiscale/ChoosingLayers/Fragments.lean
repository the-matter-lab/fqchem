module

public import Mathlib.Analysis.Calculus.Deriv.Add
public import Mathlib.Analysis.SpecialFunctions.Log.Basic
public import Mathlib.Algebra.BigOperators.Field
public import Mathlib.Data.EReal.Basic
public import Mathlib.Tactic.Ring
public import Mathlib.Tactic.Linarith

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

theorem pairReconstruction : PairReconstruction := by
  intro n mono dimer interaction pair
  unfold fragmentEnergy
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j hj
  rw [pair i j (Finset.mem_filter.mp hj).2]
  ring

end FormalQChem.Multiscale
