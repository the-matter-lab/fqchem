module

public import Mathlib.Analysis.InnerProductSpace.PiL2
public import Mathlib.Analysis.InnerProductSpace.Rayleigh

/-! # Energy certification with a spectral gap

In an orthonormal eigenbasis, the sum of the Born weights at the lowest energy is
the squared overlap with the entire ground eigenspace. The gap bounds the loss of
this overlap, including when the ground level is degenerate.
[Hangleiter et al. (2017)](https://doi.org/10.1088/2058-9565/2/1/015004). -/

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

end FormalQChem.StatePrep.VariationalOptimization
