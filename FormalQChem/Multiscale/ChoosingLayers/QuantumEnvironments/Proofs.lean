module

public import FormalQChem.Multiscale.ChoosingLayers.QuantumEnvironments.Theorems
public import Mathlib.Tactic.Ring
public import Mathlib.Tactic.Linarith

@[expose] public section

namespace FormalQChem.Multiscale

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
