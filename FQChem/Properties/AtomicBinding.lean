module

public import FQChem.Unproven.AtomicEnergy

@[expose] public section

namespace FQChem.Properties.AtomicBinding

open FQChem.Unproven.AtomicEnergy

/-- Atomic energy convexity implies consecutive strict binding, as observed by
[Nam after Conjecture 3](https://arxiv.org/abs/2206.15393). An admissible trial spinor
ensures that the intermediate variational energy is below positive infinity. -/
theorem consecutiveBinding_of_convexity
    (trials : ∀ Z : ℕ, 0 < Z → ∀ n : ℕ, Nonempty (TrialSpinor Z (n + 1)))
    (convex : ElectronNumberConvexity) : ConsecutiveBinding := by
  intro Z hZ n binds
  obtain ⟨trial⟩ := trials Z hZ n
  have belowTop : groundEnergy Z (n + 1) < ⊤ :=
    (iInf_le _ trial).trans_lt (EReal.coe_lt_top _)
  by_contra! skipped
  have strictlyLess := EReal.add_lt_add_of_lt_of_le' binds skipped binds.ne_bot
    (fun atTop _ => (belowTop.ne atTop).elim)
  rw [add_comm (groundEnergy Z (n + 2))] at strictlyLess
  exact (not_lt_of_ge (convex Z hZ n)) strictlyLess

end FQChem.Properties.AtomicBinding
