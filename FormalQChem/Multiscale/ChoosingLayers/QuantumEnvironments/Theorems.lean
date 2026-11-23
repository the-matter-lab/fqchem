module

public import Mathlib.Analysis.Calculus.Deriv.Add
public import Mathlib.Analysis.SpecialFunctions.Log.Basic
public import Mathlib.Algebra.BigOperators.Field
public import Mathlib.Data.EReal.Basic

@[expose] public section

namespace FormalQChem.Multiscale

open scoped BigOperators

/-- The subsystem's nonadditive energy at active density a and frozen density b.
The functions below parameterize a directional variation of the active density. -/
def nonadditive (total active : ℝ → ℝ) (frozen t : ℝ) := total t - active t - frozen

/-- Along an admissible density variation, the nonadditive embedding potential contributes
the difference between the total and active functional derivatives. -/
def FrozenDensityDerivative : Prop :=
  ∀ (total active : ℝ → ℝ) (frozen t vt va : ℝ),
    HasDerivAt total vt t → HasDerivAt active va t →
    HasDerivAt (nonadditive total active frozen) (vt - va) t

/-- An additive split of the total density into active and frozen parts restricts
the feasible search. A representable minimizing split makes the bound exact. -/
def FrozenSearch {D : Type*} [Add D] (E : D → EReal) (valid active : Set D) (b : D) : Prop :=
  (∀ a ∈ active, a + b ∈ valid) →
  let full := ⨅ ρ : valid, E ρ.val
  let restricted := ⨅ a : active, E (a.val + b)
  full ≤ restricted ∧ (∀ a ∈ active, E (a + b) = full → restricted = full)

open scoped BigOperators

end FormalQChem.Multiscale
