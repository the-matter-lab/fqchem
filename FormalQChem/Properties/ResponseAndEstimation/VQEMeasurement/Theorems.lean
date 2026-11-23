module

public import FormalQChem.StatePrep.VariationalOptimization.VQE.Theorems
public import Mathlib.Probability.Moments.Variance

/-! # Energy measurement in the variational quantum eigensolver

A Pauli string is a Hermitian involution. The statements use only those two properties,
so they apply to any dichotomic observable used in the same measurement protocol.
The shot model allocates a positive, equal number of independent shots to every term. -/

@[expose] public section

namespace FormalQChem.VQEMeasurement

open MeasureTheory ProbabilityTheory
open scoped BigOperators

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
variable {ι : Type*} [Fintype ι]

/-- Terms in a Pauli expansion of an encoded Hamiltonian. -/
structure PauliTerm (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℂ E] where
  op : E →L[ℂ] E
  hermitian : op.toLinearMap.IsSymmetric
  involution : op * op = 1

/-- The coefficient-weighted sum of Pauli expectations is the exact Hamiltonian expectation. -/
def EnergyReconstruction (H : E →L[ℂ] E) (term : ι → PauliTerm E) (coeff : ι → ℝ) : Prop :=
  H = ∑ i, (coeff i : ℂ) • (term i).op →
    ∀ ψ, H.reApplyInnerSelf ψ = ∑ i, coeff i * (term i).op.reApplyInnerSelf ψ

/-- Each shot contributes its coefficient divided by the number of shots per term. -/
noncomputable def estimate {Ω : Type*} {n : ℕ} (coeff : ι → ℝ)
    (outcome : ι × Fin n → Ω → ℝ) : Ω → ℝ :=
  ∑ p, fun ω ↦ (coeff p.1 / n) * outcome p ω

/-- Under calibrated Pauli measurement, the energy estimator is unbiased. Independent
±1 outcomes give an exact variance and the state-independent bound Σ cᵢ² / n. -/
def ShotStatistics {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    {n : ℕ} (coeff mean : ι → ℝ) (outcome : ι × Fin n → Ω → ℝ) : Prop :=
  0 < n → (∀ p, Measurable (outcome p)) →
    (∀ p, ∀ᵐ ω ∂μ, |outcome p ω| = 1) →
    (∀ p, (∫ ω, outcome p ω ∂μ) = mean p.1) →
    Pairwise (fun i j ↦ IndepFun (outcome i) (outcome j) μ) →
    (∫ ω, estimate coeff outcome ω ∂μ) = ∑ i, coeff i * mean i ∧
    variance (estimate coeff outcome) μ = (∑ i, coeff i ^ 2 * (1 - mean i ^ 2)) / n ∧
    variance (estimate coeff outcome) μ ≤ (∑ i, coeff i ^ 2) / n

/-- Finite-shot VQE at a normalized circuit output, with the shot means calibrated to
the ideal observable expectations. The estimator has the Hamiltonian energy as its mean. -/
def FiniteShotVQE {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    {n : ℕ} (H : E →L[ℂ] E) (term : ι → PauliTerm E) (coeff : ι → ℝ)
    (ψ : E) (outcome : ι × Fin n → Ω → ℝ) : Prop :=
  ‖ψ‖ = 1 → H = ∑ i, (coeff i : ℂ) • (term i).op → 0 < n →
    (∀ p, Measurable (outcome p)) → (∀ p, ∀ᵐ ω ∂μ, |outcome p ω| = 1) →
    (∀ p, (∫ ω, outcome p ω ∂μ) = (term p.1).op.reApplyInnerSelf ψ) →
    Pairwise (fun i j ↦ IndepFun (outcome i) (outcome j) μ) →
    (∫ ω, estimate coeff outcome ω ∂μ) = H.rayleighQuotient ψ ∧
    variance (estimate coeff outcome) μ ≤ (∑ i, coeff i ^ 2) / n

end FormalQChem.VQEMeasurement
