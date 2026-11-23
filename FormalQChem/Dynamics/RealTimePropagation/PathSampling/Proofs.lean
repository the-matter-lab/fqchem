module

public import FormalQChem.Dynamics.RealTimePropagation.PathSampling.Theorems
import Mathlib.Tactic

public section
namespace FormalQChem.Algorithms

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
