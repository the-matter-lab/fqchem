module

public import FormalQChem.Multiscale.StitchingSolutions.ErrorPropagation.Theorems
public import Mathlib.Tactic.Ring
public import Mathlib.Tactic.Linarith

@[expose] public section

namespace FormalQChem.Multiscale

open scoped BigOperators

theorem barrierRateError : BarrierRateError := by
  intro A β exact approx ε hA hβ bound
  dsimp only
  obtain ⟨hl, hu⟩ := abs_le.mp bound
  have ratio : A * Real.exp (-β * approx) / (A * Real.exp (-β * exact)) =
      Real.exp (-β * (approx - exact)) := by
    rw [mul_div_mul_left _ _ hA.ne', ← Real.exp_sub]
    congr 1
    ring
  rw [ratio]
  constructor <;> apply Real.exp_le_exp.mpr <;> nlinarith [mul_le_mul_of_nonneg_left hu hβ,
    mul_le_mul_of_nonneg_left hl hβ]

end FormalQChem.Multiscale
