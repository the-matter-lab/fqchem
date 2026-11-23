module

public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic

@[expose] public section
noncomputable section

namespace FQChem.Algorithms

/-- Exact sine eigenmode of the one-dimensional Dirichlet finite-difference Poisson
stencil used in quantum linear-system discretizations. The interior contains N sites. -/
def DirichletPoissonMode (N m : ℕ) : Prop :=
  0 < m → m ≤ N → ∀ h : ℝ, 0 < h →
    let θ := (m : ℝ) * Real.pi / (N + 1)
    let u := fun j : ℤ => Real.sin (j * θ)
    0 < u 1 ∧ u 0 = 0 ∧ u (N + 1) = 0 ∧ ∀ j : ℤ,
      (2 * u j - u (j-1) - u (j+1)) / h^2 = ((2-2*Real.cos θ) / h^2) * u j

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

end FQChem.Algorithms
