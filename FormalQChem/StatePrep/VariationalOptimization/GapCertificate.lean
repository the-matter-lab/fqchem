module

public import Mathlib.Analysis.InnerProductSpace.PiL2
public import Mathlib.Analysis.InnerProductSpace.Rayleigh

/-!
# Energy certification with a spectral gap

In an orthonormal eigenbasis, the sum of the Born weights at the lowest energy is
the squared overlap with the entire ground eigenspace. The gap bounds the loss of
this overlap, including when the ground level is degenerate.
[Hangleiter et al. (2017)](https://doi.org/10.1088/2058-9565/2/1/015004).
-/

@[expose] public section

namespace FormalQChem.StatePrep.VariationalOptimization

variable {ι E : Type*} [Fintype ι] [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- Ground-space population, summed over all indices at the ground energy. -/
noncomputable def groundPopulation (b : OrthonormalBasis ι ℂ E) (energy : ι → ℝ)
    (E₀ : ℝ) (ψ : E) : ℝ := by
  classical
  exact ∑ i, if energy i = E₀ then ‖inner ℂ (b i) ψ‖ ^ 2 else 0

/-- For a normalized state, the excess energy is at least the gap times the
population outside the ground eigenspace. A state within ε of the best energy has
at least 1 − ε / Δ ground-space population. -/
def GapCertificate (H : E →L[ℂ] E) (b : OrthonormalBasis ι ℂ E) (energy : ι → ℝ)
    (E₀ Δ : ℝ) : Prop :=
  H.toLinearMap.IsSymmetric → (∀ i, H (b i) = (energy i : ℂ) • b i) →
    (∃ i, energy i = E₀) → 0 < Δ → (∀ i, energy i ≠ E₀ → E₀ + Δ ≤ energy i) →
    ∀ ψ, ‖ψ‖ = 1 →
      Δ * (1 - groundPopulation b energy E₀ ψ) ≤ H.reApplyInnerSelf ψ - E₀ ∧
      ∀ ε, H.reApplyInnerSelf ψ ≤ E₀ + ε → 1 - ε / Δ ≤ groundPopulation b energy E₀ ψ

theorem spectralExpectation (H : E →L[ℂ] E) (b : OrthonormalBasis ι ℂ E) (energy : ι → ℝ)
    (hH : H.toLinearMap.IsSymmetric) (eigen : ∀ i, H (b i) = (energy i : ℂ) • b i) (ψ : E) :
    H.reApplyInnerSelf ψ = ∑ i, energy i * ‖inner ℂ (b i) ψ‖ ^ 2 := by
  rw [ContinuousLinearMap.reApplyInnerSelf_apply, ← b.sum_inner_mul_inner (H ψ) ψ, map_sum]
  apply Finset.sum_congr rfl
  intro i _
  rw [show inner ℂ (H ψ) (b i) = inner ℂ ψ (H (b i)) from hH ψ (b i),
    eigen, inner_smul_right, mul_assoc, ← inner_conj_symm ψ (b i), Complex.conj_mul']
  simp [RCLike.re_to_complex, ← Complex.ofReal_pow]

theorem gapCertificate (H : E →L[ℂ] E) (b : OrthonormalBasis ι ℂ E) (energy : ι → ℝ)
    (E₀ Δ : ℝ) : GapCertificate H b energy E₀ Δ := by
  classical
  intro hH eigen _ gap separated ψ unit
  let w (i : ι) := ‖inner ℂ (b i) ψ‖ ^ 2
  have total : ∑ i, w i = 1 := by simpa [w, unit] using b.sum_sq_norm_inner_right ψ
  have bound : ∑ i, (E₀ * w i + Δ * (w i - if energy i = E₀ then w i else 0)) ≤
      ∑ i, energy i * w i := by
    apply Finset.sum_le_sum
    intro i _
    by_cases hi : energy i = E₀
    · simp [hi]
    · simpa [hi, add_mul] using mul_le_mul_of_nonneg_right (separated i hi) (sq_nonneg _)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_sub_distrib, total, mul_one] at bound
  change E₀ + Δ * (1 - groundPopulation b energy E₀ ψ) ≤ ∑ i, energy i * ‖inner ℂ (b i) ψ‖ ^ 2 at bound
  rw [spectralExpectation H b energy hH eigen]
  constructor
  · linarith
  · intro ε upper
    have low : (1 - groundPopulation b energy E₀ ψ) ≤ ε / Δ := by
      apply (le_div_iff₀ gap).mpr
      rw [mul_comm]
      linarith
    linarith

end FormalQChem.StatePrep.VariationalOptimization
