module

public import FQChem.Properties.MeasurementTheory
public import FQChem.StatePrep.VariationalOptimization.RayleighRitz
public import Mathlib.Analysis.CStarAlgebra.ContinuousLinearMap
public import Mathlib.Analysis.InnerProductSpace.StarOrder
public import Mathlib.Analysis.SpecialFunctions.ContinuousFunctionalCalculus.Rpow.Basic

/-! # Random-term verification of a local Hamiltonian

Kitaev, Shen and Vyalyi test a uniformly selected summand of the Hamiltonian using
the two-outcome measurement with effects Hⱼ and I−Hⱼ. The probability of accepting
a normalized witness equals one minus its energy divided by the number of terms.
The following results establish the measurement and its optimal success probability
on a finite Hilbert space.

* [Kitaev, Shen and Vyalyi, Proposition 14.2, pp. 142–143](https://doi.org/10.1090/gsm/047)
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.LocalHamiltonianVerification

open FQChem.Properties.MeasurementTheory FQChem.RayleighRitz
open scoped InnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E]
variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- The outcome operators of the binary measurement have squared amplitudes H and I−H. -/
theorem termEffects (H : E →L[ℂ] E) (h₀ : 0 ≤ H) (h₁ : H ≤ 1) :
    (CFC.sqrt H).adjoint * CFC.sqrt H = H ∧
    (CFC.sqrt (1-H)).adjoint * CFC.sqrt (1-H) = 1-H := by
  have gram (A : E →L[ℂ] E) (hA : 0 ≤ A) : (CFC.sqrt A).adjoint * CFC.sqrt A = A := by
    rw [← ContinuousLinearMap.star_eq_adjoint, (CFC.sqrt_nonneg A).star_eq, CFC.sqrt_mul_sqrt_self A hA]
  exact ⟨gram H h₀, gram _ (sub_nonneg.mpr h₁)⟩

/-- The Born probability of acceptance, averaged over the uniformly chosen term. -/
def acceptance (H : ι → E →L[ℂ] E) (ψ : E) : ℝ :=
  (∑ j, probability (CFC.sqrt (1-H j)) ψ) / Fintype.card ι

/-- The acceptance probability on each normalized witness is 1−⟨H⟩/r for r terms. -/
theorem acceptance_eq (H : ι → E →L[ℂ] E) (h₀ : ∀ i, 0 ≤ H i) (h₁ : ∀ i, H i ≤ 1)
    (ψ : E) (hn : ‖ψ‖ = 1) :
    acceptance H ψ = 1 - (∑ i, H i).rayleighQuotient ψ / Fintype.card ι := by
  have oneTerm (i : ι) : probability (CFC.sqrt (1-H i)) ψ =
      1 - (inner ℂ (H i ψ) ψ).re := by
    rw [probability, ContinuousLinearMap.apply_norm_sq_eq_inner_adjoint_right]
    have gram := congrArg (fun A : E →L[ℂ] E => A ψ) (termEffects (H i) (h₀ i) (h₁ i)).2
    change (inner ℂ ψ ((CFC.sqrt (1 - H i)).adjoint ((CFC.sqrt (1 - H i)) ψ))).re = _
    rw [show (CFC.sqrt (1-H i)).adjoint (CFC.sqrt (1-H i) ψ) = ψ - H i ψ from gram]
    rw [inner_sub_right, Complex.sub_re]
    change RCLike.re (inner ℂ ψ ψ) - RCLike.re (inner ℂ ψ (H i ψ)) = _
    rw [inner_self_eq_norm_sq, hn, one_pow, inner_re_symm ψ (H i ψ)]
    rfl
  have nr : (Fintype.card ι : ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  simp only [acceptance, oneTerm, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
    nsmul_eq_mul, mul_one, ContinuousLinearMap.rayleighQuotient,
    ContinuousLinearMap.reApplyInnerSelf_apply, hn, one_pow, div_one,
    sum_apply, sum_inner, map_sum]
  field_simp
  rfl

/-- The verifier attains success 1−λmin(H)/r, and every witness satisfies this upper bound.
In particular, energy thresholds a and b yield the acceptance gap (b−a)/r. -/
theorem maximumAcceptance [FiniteDimensional ℂ E] [Nontrivial E]
    (H : ι → E →L[ℂ] E) (h₀ : ∀ i, 0 ≤ H i) (h₁ : ∀ i, H i ≤ 1) :
    IsGreatest {p : ℝ | ∃ ψ : E, ‖ψ‖ = 1 ∧ p = acceptance H ψ}
      (1 - groundEnergy (∑ i, H i) / Fintype.card ι) := by
  let A := ∑ i, H i
  have hA : 0 ≤ A := Finset.sum_nonneg (fun i _ => h₀ i)
  have hsym := (ContinuousLinearMap.nonneg_iff_isPositive.mp hA).isSymmetric
  obtain ⟨heig, hlower⟩ := groundEnergyPrinciple A hsym
  obtain ⟨v, hv⟩ := heig.exists_hasEigenvector
  have hvn : ‖v‖ ≠ 0 := norm_ne_zero_iff.mpr hv.2
  let c : ℂ := (‖v‖ : ℂ)⁻¹
  have hc : c ≠ 0 := by simpa [c] using hvn
  have hnorm : ‖c • v‖ = 1 := by simp [c, norm_smul, hvn]
  have henergy : A.rayleighQuotient v = groundEnergy A := by
    have heq : A v = (groundEnergy A : ℂ) • v := hv.apply_eq_smul
    rw [ContinuousLinearMap.rayleighQuotient, ContinuousLinearMap.reApplyInnerSelf_apply, heq,
      inner_smul_left, inner_self_eq_norm_sq_to_K]
    simp only [Complex.conj_ofReal]
    field_simp
    change (((groundEnergy A : ℝ) : ℂ) * ((‖v‖ : ℝ) : ℂ)^2).re = _
    rw [← Complex.ofReal_pow, ← Complex.ofReal_mul, Complex.ofReal_re, mul_comm]
  constructor
  · refine ⟨c • v, hnorm, ?_⟩
    rw [acceptance_eq H h₀ h₁ _ hnorm, show (∑ i, H i) = A by rfl, A.rayleigh_smul v hc, henergy]
  · rintro p ⟨ψ, hn, rfl⟩
    have hn₀ : ψ ≠ 0 := by intro hz; simp [hz] at hn
    rw [acceptance_eq H h₀ h₁ _ hn]
    exact sub_le_sub_left (div_le_div_of_nonneg_right (hlower ψ hn₀) (by positivity)) _

end FQChem.Complexity.LocalHamiltonianVerification
