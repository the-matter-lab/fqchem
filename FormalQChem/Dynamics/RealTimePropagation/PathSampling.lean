module

public import Mathlib.Analysis.Complex.Basic
public import Mathlib.Analysis.Normed.Group.InfiniteSum
import Mathlib.Tactic

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

theorem realTimeReweighting (n : ℕ) : RealTimeReweighting n := by
  intro w O hw
  have restore (z : ℂ) : (‖z‖ : ℂ) * pathPhase z = z := by
    by_cases hz : z = 0
    · simp [hz, pathPhase]
    · have h : (‖z‖ : ℂ) ≠ 0 := by exact_mod_cast norm_ne_zero_iff.mpr hz
      unfold pathPhase
      field_simp
  simp_rw [restore]
  refine ⟨trivial, ?_⟩
  have bound := norm_sum_le (s := Finset.univ) (f := w)
  exact (div_le_one (lt_of_lt_of_le (norm_pos_iff.mpr hw) bound)).mpr bound

end FormalQChem.Algorithms
