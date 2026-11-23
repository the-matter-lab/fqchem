module

public import FormalQChem.Properties.LinearSystems.Theorems
import Mathlib.Tactic

public section
namespace FormalQChem.Algorithms

theorem hhlSpectralInversion (d k : ℕ) : HHLSpectralInversion d k := by
  intro A u eigenvalue b he hn
  rw [map_sum]
  apply Finset.sum_congr rfl
  intro j _
  rw [map_smul, he, smul_smul, div_mul_cancel₀ _ (hn j)]

theorem dirichletPoissonMode (N m : ℕ) : DirichletPoissonMode N m := by
  intro hm hmN h _
  dsimp only
  refine ⟨?_, by simp, ?_, ?_⟩
  · simp only [Int.cast_one, one_mul]
    apply Real.sin_pos_of_pos_of_lt_pi
    · positivity
    · apply (div_lt_iff₀ (by positivity : 0 < (N : ℝ) + 1)).mpr
      have hmn : (m : ℝ) < (N : ℝ) + 1 := by exact_mod_cast Nat.lt_succ_of_le hmN
      nlinarith [mul_lt_mul_of_pos_right hmn Real.pi_pos]
  · have hn : (N : ℝ) + 1 ≠ 0 := by positivity
    push_cast
    convert Real.sin_nat_mul_pi m using 2
    field_simp
  · intro j
    push_cast
    simp only [sub_mul, add_mul, one_mul, Real.sin_sub, Real.sin_add]
    ring

end FormalQChem.Algorithms
