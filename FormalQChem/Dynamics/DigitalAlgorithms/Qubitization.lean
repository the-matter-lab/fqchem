module

public import Mathlib.Analysis.InnerProductSpace.Symmetric
public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Chebyshev.Basic
public import Mathlib.LinearAlgebra.Eigenspace.Minpoly
public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Inverse
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Module

/-!
# Hamiltonian simulation by qubitization

A Hermitian involutory signal oracle `S` and orthogonal signal projection `P`
encode the normalized Hamiltonian `H = P S P` on the signal subspace. One
query and a reflection implement `W = (2P - I) S`. The operator identity
`P Wⁿ P = Tₙ(H) P` gives the exact polynomial action on arbitrary encoded
states. The simulation corollary identifies the vector error of a finite
Chebyshev sum on an encoded energy eigenstate with its scalar phase error.

[Low and Chuang, Hamiltonian Simulation by Qubitization
(2019)](https://doi.org/10.22331/q-2019-07-12-163), Theorem 2 and Corollary 9.
For an existing finite-matrix development of this eigenbranch, see
[Qatlib's walk-spectrum formalization](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/Qubitization19/MainResults/WalkSpectrum.lean).
The proof here works directly with compressed operators via their recurrence.
-/

@[expose] public section

namespace FormalQChem.Dynamics.DigitalAlgorithms.Qubitization

open Polynomial Polynomial.Chebyshev
open scoped InnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- `P` selects the prepared ancilla subspace, and `S` is a Hermitian
unitary SELECT oracle. Its two defining relations imply it preserves
inner products and is its own inverse. -/
structure Encoding (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℂ E] where
  P : Module.End ℂ E
  S : Module.End ℂ E
  proj : P * P = P
  symmetricProjection : P.IsSymmetric
  involution : S * S = 1
  symmetricOracle : S.IsSymmetric

namespace Encoding

variable (e : Encoding E)

noncomputable def signal : Module.End ℂ E := e.P * e.S * e.P
noncomputable def reflection : Module.End ℂ E := e.P + e.P - 1
noncomputable def walk : Module.End ℂ E := e.reflection * e.S

private theorem reflection_sq : e.reflection * e.reflection = 1 := by
  simp only [reflection, sub_mul, add_mul, mul_sub, mul_add, one_mul, mul_one, e.proj]
  abel

private theorem proj_reflection : e.P * e.reflection = e.P := by
  simp [reflection, mul_sub, mul_add, e.proj]

private theorem involution_inner (Q : Module.End ℂ E) (symm : Q.IsSymmetric)
    (sq : Q * Q = 1) (x y : E) : ⟪Q x, Q y⟫_ℂ = ⟪x, y⟫_ℂ := by
  rw [symm, ← Module.End.mul_apply, sq, Module.End.one_apply]

/-- The resulting walk preserves inner products and hence state norms. -/
theorem walk_preserves_inner (x y : E) : ⟪e.walk x, e.walk y⟫_ℂ = ⟪x, y⟫_ℂ := by
  change ⟪e.reflection (e.S x), e.reflection (e.S y)⟫_ℂ = _
  exact (involution_inner e.reflection ((e.symmetricProjection.add e.symmetricProjection).sub .one)
    e.reflection_sq _ _).trans (involution_inner e.S e.symmetricOracle e.involution _ _)

/-- The block moment recurrence is obtained by cancelling the inverse walk
and using the projector identity, without choosing an eigenbasis. -/
private theorem block_recurrence (n : ℕ) :
    e.P * e.walk ^ (n + 2) * e.P =
      2 * e.signal * (e.P * e.walk ^ (n + 1) * e.P) - e.P * e.walk ^ n * e.P := by
  let V := e.S * e.reflection
  have inverse : V * e.walk = 1 := by
    simp only [V, walk, mul_assoc, ← mul_assoc e.reflection e.reflection, e.reflection_sq,
      one_mul, e.involution]
  have plus : e.P * e.walk + e.P * V = 2 * e.signal := by
    simp only [walk, V, ← mul_assoc, e.proj_reflection]
    simp only [reflection, signal, mul_sub, mul_add, mul_one, two_mul]
    abel
  have projH : e.signal * e.P = e.signal := by
    simp only [signal, mul_assoc, e.proj]
  have invPow : V * e.walk ^ (n + 1) = e.walk ^ n := by
    rw [pow_succ', ← mul_assoc, inverse, one_mul]
  have total := congrArg (fun Z : Module.End ℂ E => Z * e.walk ^ (n + 1) * e.P) plus
  simp only [add_mul, mul_assoc, invPow, ← pow_succ'] at total
  apply eq_sub_of_add_eq
  calc
    _ = (2 : Module.End ℂ E) * e.signal * e.walk ^ (n + 1) * e.P := by
      simpa only [mul_assoc, pow_succ' e.walk (n + 1), pow_succ' e.walk n] using total
    _ = _ := by
      simp only [← mul_assoc, mul_assoc (2 : Module.End ℂ E) e.signal e.P, projH]

/-- Exact operator form of the qubitization identity for every walk length.
Evaluating a scalar polynomial at `e.signal` uses the operator product. -/
theorem chebyshev_block (n : ℕ) :
    e.P * e.walk ^ n * e.P = aeval e.signal (T ℂ n) * e.P := by
  induction n using Nat.twoStepInduction with
  | zero => simp [e.proj]
  | one =>
    simp [walk, ← mul_assoc, e.proj_reflection, signal]
    rw [mul_assoc (e.P * e.S), e.proj]
  | more n hn hn1 =>
    rw [e.block_recurrence, hn, hn1]
    push_cast
    rw [T_add_two, map_sub, map_mul, map_mul, aeval_X, sub_mul]
    simp [mul_assoc, map_ofNat]

/-- On an encoded eigenvector the signal component after `n` walks is
exactly the scalar Chebyshev amplitude, including the endpoint eigenvalues. -/
theorem eigenvector_amplitude {ψ : E} {energy : ℝ} (encoded : e.P ψ = ψ)
    (eigen : e.signal ψ = (energy : ℂ) • ψ) (n : ℕ) :
    e.P ((e.walk ^ n) ψ) = (T ℂ n).eval (energy : ℂ) • ψ := by
  have h := congrArg (fun A : Module.End ℂ E => A ψ) (e.chebyshev_block n)
  simpa only [Module.End.mul_apply, encoded, Module.End.aeval_apply_of_mem_apply_eq_smul eigen]
    using h

/-- For a normalized encoded eigenstate of energy `energy`, a finite weighted
sum of walk powers has precisely its scalar Chebyshev approximation error
to the dynamical phase at time `t` (units with ℏ = 1). -/
theorem simulation_error {ψ : E} {energy : ℝ} (encoded : e.P ψ = ψ)
    (eigen : e.signal ψ = (energy : ℂ) • ψ) (normalized : ‖ψ‖ = 1)
    (degrees : Finset ℕ) (c : ℕ → ℂ) (t : ℝ) :
    ‖e.P (∑ n ∈ degrees, c n • (e.walk ^ n) ψ) - Complex.exp (-(t * energy : ℝ) * Complex.I) • ψ‖ =
      ‖(∑ n ∈ degrees, c n * (T ℂ n).eval (energy : ℂ)) - Complex.exp (-(t * energy : ℝ) * Complex.I)‖ := by
  simp only [map_sum, map_smul, e.eigenvector_amplitude encoded eigen, smul_smul,
    ← Finset.sum_smul, ← sub_smul, norm_smul, normalized, mul_one]

/-- The spectrum seen by normalized encoded eigenvectors lies in `[-1, 1]`,
a consequence of the Hermitian involution and orthogonal projection. -/
theorem eigenvalue_abs_le_one {ψ : E} {energy : ℝ} (encoded : e.P ψ = ψ)
    (eigen : e.signal ψ = (energy : ℂ) • ψ) (normalized : ‖ψ‖ = 1) : |energy| ≤ 1 := by
  have oracleNorm : ‖e.S ψ‖ = 1 := by
    rw [norm_eq_sqrt_re_inner (𝕜 := ℂ), involution_inner _ e.symmetricOracle e.involution,
      ← norm_eq_sqrt_re_inner, normalized]
  have compress : ⟪ψ, e.S ψ⟫_ℂ = energy := calc
    _ = ⟪e.P ψ, e.S ψ⟫_ℂ := by rw [encoded]
    _ = ⟪ψ, e.P (e.S ψ)⟫_ℂ := e.symmetricProjection _ _
    _ = ⟪ψ, e.signal ψ⟫_ℂ := by simp [signal, Module.End.mul_apply, encoded]
    _ = _ := by rw [eigen, inner_smul_right, inner_self_eq_norm_sq_to_K, normalized]; simp
  have bound := norm_inner_le_norm (𝕜 := ℂ) ψ (e.S ψ)
  simpa [compress, oracleNorm, normalized, Real.norm_eq_abs] using bound

/-- The signal amplitude is a cosine oscillation with eigenphase
`arccos energy`, including the endpoint eigenvalues. -/
theorem eigenphase_cosine {ψ : E} {energy : ℝ} (encoded : e.P ψ = ψ)
    (eigen : e.signal ψ = (energy : ℂ) • ψ) (normalized : ‖ψ‖ = 1) (n : ℕ) :
    e.P ((e.walk ^ n) ψ) = (Real.cos (n * Real.arccos energy) : ℂ) • ψ := by
  have bounds := abs_le.mp (e.eigenvalue_abs_le_one encoded eigen normalized)
  rw [e.eigenvector_amplitude encoded eigen, ← complex_ofReal_eval_T]
  have h := T_real_cos (Real.arccos energy) (n : ℤ)
  rw [Real.cos_arccos bounds.1 bounds.2] at h
  simp only [h, Int.cast_natCast]

/-- Signal projection of a linear combination of zero, one and two walk steps.
The coefficients are the degree-two Chebyshev expansion of the second-order
Taylor polynomial of the Schrödinger phase. -/
noncomputable def quadraticStep (t : ℝ) (ψ : E) : E :=
  let τ := -(t : ℂ) * Complex.I
  e.P ((1 + τ ^ 2 / 4) • ψ + τ • e.walk ψ + (τ ^ 2 / 4) • (e.walk ^ 2) ψ)

/-- A concrete two-step polynomial simulator. For a normalized encoded
eigenstate and `|t| ≤ 1`, its unnormalized signal output approximates
physical time evolution with vector error at most `2 |t λ|³ / 9`. -/
theorem quadratic_simulation_bound {ψ : E} {energy : ℝ} (encoded : e.P ψ = ψ)
    (eigen : e.signal ψ = (energy : ℂ) • ψ) (normalized : ‖ψ‖ = 1)
    (t : ℝ) (ht : |t| ≤ 1) :
    ‖e.quadraticStep t ψ - Complex.exp (-(t * energy : ℝ) * Complex.I) • ψ‖ ≤
      2 * |t * energy| ^ 3 / 9 := by
  let τ := -(t : ℂ) * Complex.I
  let z := τ * (energy : ℂ)
  have phase : -(t * energy : ℝ) * Complex.I = z := by simp [z, τ]; ring
  have hz : ‖z‖ = |t * energy| := by simp [z, τ, abs_mul, Real.norm_eq_abs]
  have hz1 : ‖z‖ ≤ 1 := by
    rw [hz, abs_mul]
    simpa using mul_le_mul ht (e.eigenvalue_abs_le_one encoded eigen normalized)
      (abs_nonneg energy) zero_le_one
  have step1 : e.P (e.walk ψ) = (energy : ℂ) • ψ := by
    simpa using e.eigenvector_amplitude encoded eigen 1
  have step2 : e.P ((e.walk ^ 2) ψ) = (2 * (energy : ℂ) ^ 2 - 1) • ψ := by
    simpa [T_two] using e.eigenvector_amplitude encoded eigen 2
  have poly : e.quadraticStep t ψ = (1 + z + z ^ 2 / 2) • ψ := by
    change e.P ((1 + τ ^ 2 / 4) • ψ + τ • e.walk ψ + (τ ^ 2 / 4) • (e.walk ^ 2) ψ) = _
    simp only [map_add, map_smul, encoded, step1, step2, smul_smul, ← add_smul]
    congr 1
    dsimp [z]
    ring
  rw [poly, phase, ← sub_smul, norm_smul, normalized, mul_one, norm_sub_rev]
  have error := Complex.exp_bound hz1 (n := 3) (by decide)
  norm_num [Finset.sum_range_succ, Nat.factorial] at error
  rw [← hz]
  convert error using 1
  ring_nf

end Encoding

end FormalQChem.Dynamics.DigitalAlgorithms.Qubitization
