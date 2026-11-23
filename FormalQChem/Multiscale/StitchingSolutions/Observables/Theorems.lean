module

public import Mathlib.Analysis.Calculus.Deriv.Add
public import Mathlib.Analysis.SpecialFunctions.Log.Basic
public import Mathlib.Algebra.BigOperators.Field
public import Mathlib.Data.EReal.Basic

@[expose] public section

namespace FormalQChem.Multiscale

open scoped BigOperators

noncomputable def partition {ι : Type*} [Fintype ι] (β : ℝ) (U : ι → ℝ) :=
  ∑ i, Real.exp (-β * U i)

noncomputable def freeEnergy {ι : Type*} [Fintype ι] (β : ℝ) (U : ι → ℝ) :=
  -Real.log (partition β U) / β

/-- Zwanzig's exact finite-ensemble free-energy perturbation identity. -/
def Zwanzig (ι : Type*) [Fintype ι] [Nonempty ι] : Prop :=
  ∀ (β : ℝ) (_ : 0 < β) (U V : ι → ℝ), freeEnergy β V - freeEnergy β U =
    -Real.log (∑ i, (Real.exp (-β * U i) / partition β U) * Real.exp (-β * (V i - U i))) / β

end FormalQChem.Multiscale
