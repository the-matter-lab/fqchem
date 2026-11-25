module

public import Mathlib.Analysis.InnerProductSpace.Adjoint
public import Mathlib.Analysis.SpecialFunctions.Exponential
import Mathlib.Analysis.CStarAlgebra.Exponential
import Mathlib.Data.Nat.Choose.Basic

/-!
# Truncated Taylor simulation of a bounded Hamiltonian

The segment polynomial retains powers of order zero through `k - 1`.
A Banach algebra estimate controls its truncation remainder, and the operator
norm of exact unitary evolution controls accumulation across segments.
These are estimates on the full space of input states.

[Berry, Childs, Cleve, Kothari & Somma (2015)](https://doi.org/10.1103/PhysRevLett.114.090502).
For circuit resource estimates and coherent amplification in Lean, see the
[Qatlib Taylor development](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/CoherentSim/TaylorBounds.lean).
-/

@[expose] public section

namespace FQChem.Dynamics.DigitalAlgorithms.TruncatedTaylor

open Filter NormedSpace
open scoped Topology

variable {A : Type*} [NormedRing A] [NormedAlgebra ℝ A]

/-- Taylor approximation to the operator exponential with `k` terms. -/
noncomputable def segment (x : A) (k : ℕ) : A :=
  ∑ m ∈ Finset.range k, (m.factorial : ℝ)⁻¹ • x ^ m

/-- Explicit error budget in terms of the norm of the scaled generator. -/
noncomputable def tailBudget (s : ℝ) (k : ℕ) : ℝ := s ^ k / k.factorial * Real.exp s

variable [NormOneClass A] [CompleteSpace A]

/-- All-generator Taylor bound, obtained by dominating each omitted
operator coefficient by a scalar exponential coefficient. -/
theorem segment_error (x : A) (k : ℕ) : ‖segment x k - exp x‖ ≤ tailBudget ‖x‖ k := by
  have tail := (hasSum_nat_add_iff' k).mpr (exp_series_hasSum_exp' (𝕂 := ℝ) x)
  rw [norm_sub_rev, tailBudget, Real.exp_eq_exp_ℝ, mul_comm (‖x‖ ^ k / _)]
  refine tail.norm_le_of_bounded ((expSeries_div_hasSum_exp ‖x‖).mul_right _) ?_
  intro j
  simp only [norm_smul, Real.norm_eq_abs, abs_inv, Nat.abs_cast, inv_mul_eq_div,
    div_mul_div_comm, ← pow_add]
  apply div_le_div₀ (by positivity) (norm_pow_le ..) (by positivity)
  exact_mod_cast Nat.le_of_dvd (Nat.factorial_pos _)
    (Nat.factorial_mul_factorial_dvd_factorial_add j k)

omit [NormOneClass A] in
/-- Taylor polynomials of a bounded generator converge in norm with no
step-size restriction. -/
theorem segment_tendsto (x : A) : Tendsto (segment x) atTop (𝓝 (exp x)) :=
  (exp_series_hasSum_exp' (𝕂 := ℝ) x).tendsto_sum_nat

omit [NormedAlgebra ℝ A] [CompleteSpace A] in
private theorem power_error (p u : A) {δ : ℝ} (hδ : 0 ≤ δ)
    (h : ‖p - u‖ ≤ δ) (hu : ‖u‖ ≤ 1) (r : ℕ) :
    ‖p ^ r - u ^ r‖ ≤ (1 + δ) ^ r - 1 := by
  have hp : ‖p‖ ≤ 1 + δ := by
    have htri := norm_add_le (p-u) u
    rw [sub_add_cancel] at htri
    linarith
  induction r with
  | zero => simp
  | succ r ih =>
    calc
      _ = ‖p ^ r * (p - u) + (p ^ r - u ^ r) * u‖ := by
        rw [pow_succ, pow_succ, mul_sub, sub_mul]; abel_nf
      _ ≤ ‖p ^ r‖ * ‖p - u‖ + ‖p ^ r - u ^ r‖ * ‖u‖ :=
        (norm_add_le ..).trans (add_le_add (norm_mul_le ..) (norm_mul_le ..))
      _ ≤ (1 + δ) ^ r * δ + ((1 + δ) ^ r - 1) * 1 := by
        have hpow := (norm_pow_le p r).trans (pow_le_pow_left₀ (norm_nonneg p) hp r)
        have hn := (norm_nonneg _).trans ih
        gcongr
      _ = _ := by rw [pow_succ]; ring

section Quantum

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E] [Nontrivial E]

/-- The real-time segment generator `-i h H`. -/
noncomputable def generator (H : E →L[ℂ] E) (h : ℝ) : E →L[ℂ] E :=
  (-(h : ℂ) * Complex.I) • H

omit [CompleteSpace E] [Nontrivial E] in
private theorem generator_norm (H : E →L[ℂ] E) (h : ℝ) : ‖generator H h‖ = |h| * ‖H‖ := by
  simp [generator, norm_smul, Real.norm_eq_abs]

/-- A single real-time segment approximates the exact propagator uniformly
on the unit ball with a factorial error bound. -/
theorem realTime_segment (H : E →L[ℂ] E) (h : ℝ) (k : ℕ) :
    ‖segment (generator H h) k - exp (generator H h)‖ ≤ tailBudget (|h| * ‖H‖) k := by
  simpa only [generator_norm] using segment_error (generator H h) k

/-- After `r > 0` equal segments the operator error is bounded by
`(1 + δ)^r - 1`, where `δ` is the explicit factorial budget evaluated at
`|t/r| ‖H‖`. No eigenstate input assumption is required. -/
theorem realTime_segmented (H : E →L[ℂ] E) (selfAdjoint : IsSelfAdjoint H)
    (t : ℝ) {r : ℕ} (hr : 0 < r) (k : ℕ) :
    ‖segment (generator H (t / r)) k ^ r - exp (generator H t)‖ ≤
      (1 + tailBudget (|t / r| * ‖H‖) k) ^ r - 1 := by
  let +nondep : NormedAlgebra ℚ (E →L[ℂ] E) := .restrictScalars ℚ ℂ _
  let x := generator H (t / r)
  have hskew : x ∈ skewAdjoint (E →L[ℂ] E) := by
    apply selfAdjoint.smul_mem_skewAdjoint
    change star (-(↑(t / r) : ℂ) * Complex.I) = -(-(↑(t / r) : ℂ) * Complex.I)
    simp [mul_comm]
  have hnorm : ‖exp x‖ = 1 :=
    CStarRing.norm_of_mem_unitary (exp_mem_unitary_of_mem_skewAdjoint hskew)
  have exactTime : exp x ^ r = exp (generator H t) := by
    simp only [← exp_nsmul, ← Nat.cast_smul_eq_nsmul ℂ, x, generator, smul_smul]
    congr 2
    push_cast
    field_simp [show (r : ℂ) ≠ 0 by exact_mod_cast (Nat.ne_of_gt hr)]
  rw [← exactTime]
  apply power_error _ _ _ (realTime_segment H (t/r) k) hnorm.le r
  unfold tailBudget
  positivity

/-- Applied to any input vector, the total state-vector error is bounded
by the accumulated operator error times the initial norm. -/
theorem realTime_state_error (H : E →L[ℂ] E) (selfAdjoint : IsSelfAdjoint H)
    (ψ : E) (t : ℝ) {r : ℕ} (hr : 0 < r) (k : ℕ) :
    ‖(segment (generator H (t / r)) k ^ r) ψ - exp (generator H t) ψ‖ ≤
      ((1 + tailBudget (|t / r| * ‖H‖) k) ^ r - 1) * ‖ψ‖ := by
  let error := segment (generator H (t / r)) k ^ r - exp (generator H t)
  exact (error.le_opNorm ψ).trans
    (mul_le_mul_of_nonneg_right (realTime_segmented H selfAdjoint t hr k) (norm_nonneg _))

end Quantum
end FQChem.Dynamics.DigitalAlgorithms.TruncatedTaylor
