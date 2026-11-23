module

public import Mathlib.Analysis.Complex.Basic
public import Mathlib.Analysis.Normed.Group.InfiniteSum

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- Complex phase of a trajectory weight. A zero-weight path contributes zero. -/
def pathPhase (z : ℂ) : ℂ := z / (‖z‖ : ℂ)

/-- Phase reweighting in real-time Monte Carlo. The ratio under magnitude sampling
recovers the complex-weight estimator. The mean phase has modulus at most one. -/
def RealTimeReweighting (n : ℕ) : Prop :=
  ∀ (w O : Fin n → ℂ), (∑ i, w i) ≠ 0 →
    (∑ i, (‖w i‖ : ℂ) * pathPhase (w i) * O i) / (∑ i, (‖w i‖ : ℂ) * pathPhase (w i)) =
      (∑ i, w i * O i) / (∑ i, w i) ∧ ‖∑ i, w i‖ / (∑ i, ‖w i‖) ≤ 1

end FormalQChem.Algorithms
