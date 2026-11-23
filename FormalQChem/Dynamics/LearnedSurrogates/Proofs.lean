module

public import FormalQChem.Dynamics.LearnedSurrogates.Theorems
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add

public section

namespace FormalQChem.Dynamics

open Matrix
open scoped InnerProductSpace ComplexConjugate

variable {n m : Type*} [Fintype n] [DecidableEq n] [Fintype m] [DecidableEq m]

theorem invariantDirectionalForce {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
    (E : V → ℝ) (R : V ≃ₗᵢ[ℝ] V) (q : V) : InvariantDirectionalForce E R q := by
  intro hinv hdiff δ
  let r := R.toContinuousLinearEquiv.toContinuousLinearMap
  have h := hdiff.hasFDerivAt.comp q r.hasFDerivAt
  have eq : E ∘ R = E := funext hinv
  rw [eq] at h
  rw [h.fderiv]
  rfl

end FormalQChem.Dynamics
