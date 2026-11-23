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

theorem frozenDensityDerivative : FrozenDensityDerivative := by
  intro total active frozen t vt va ht ha
  exact ((ht.sub ha).sub_const frozen)

theorem frozenSearch {D : Type*} [Add D] (E : D → EReal) (valid active : Set D) (b : D) :
    FrozenSearch E valid active b := by
  intro feasible
  dsimp only
  have bound : (⨅ ρ : valid, E ρ.val) ≤ ⨅ a : active, E (a.val + b) :=
    le_iInf fun a => iInf_le (fun ρ : valid => E ρ.val) ⟨a.val + b, feasible a.val a.property⟩
  refine ⟨bound, fun a ha eq => le_antisymm ?_ bound⟩
  exact (iInf_le (fun r : active => E (r.val + b)) ⟨a, ha⟩).trans_eq eq

end FormalQChem.Multiscale
