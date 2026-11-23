module

public import Mathlib.Analysis.Matrix.Spectrum
public import Mathlib.Analysis.Matrix.Normed
public import Mathlib.Analysis.Normed.Algebra.MatrixExponential
public import Mathlib.Probability.Distributions.Gaussian.Real
public import Mathlib.MeasureTheory.SpecificCodomains.Pi
import Mathlib.Tactic

/-!
# Continuous Gaussian Hubbard–Stratonovich transformation

For a single Hermitian channel `V` and a nonnegative imaginary-time step `τ`,
the standard-normal expectation of the one-body field propagator
`exp(i x √τ V)` equals the matrix exponential `exp(-τ V² / 2)`.
The proof uses the characteristic function of the standard Gaussian and the
finite-dimensional Hermitian spectral theorem. Applying a product of such
single-channel propagators to a sum of noncommuting squares requires an
additional operator splitting.

* [Hubbard, Calculation of Partition Functions (1959)](https://doi.org/10.1103/PhysRevLett.3.77)
* [Zhang & Krakauer, Quantum Monte Carlo Method Using Phase-Free Random Walks with Slater Determinants (2003)](https://doi.org/10.1103/PhysRevLett.90.136401)
-/

@[expose] public section
noncomputable section

open MeasureTheory ProbabilityTheory
open scoped Matrix.Norms.Operator

namespace FormalQChem.StatePrep.ImaginaryTimeProjection.GaussianAuxiliaryField

/-- The standard Gaussian field average on an eigenstate of channel eigenvalue `v`. -/
theorem gaussianPhaseAverage {τ : ℝ} (hτ : 0 ≤ τ) (v : ℝ) :
    (∫ x : ℝ, Complex.exp (((Real.sqrt τ * v : ℝ) : ℂ) * x * Complex.I)
      ∂gaussianReal 0 1) = Complex.exp (((-τ / 2 : ℝ) : ℂ) * (v : ℂ)^2) := by
  rw [← charFun_apply_real, charFun_gaussianReal]
  congr 1
  push_cast
  rw [mul_pow, ← Complex.ofReal_pow, Real.sq_sqrt hτ]
  ring

set_option backward.isDefEq.respectTransparency false in
/-- The single-channel Hubbard–Stratonovich transformation as a Bochner integral of
matrix exponentials, including integrability of the stochastic propagator. -/
theorem gaussianHubbardStratonovich {n : Type*} [Fintype n] [DecidableEq n]
    {V : Matrix n n ℂ} (hV : V.IsHermitian) {τ : ℝ} (hτ : 0 ≤ τ) :
    Integrable (fun x : ℝ ↦ NormedSpace.exp ((Complex.I * (x : ℂ) * (Real.sqrt τ : ℂ)) • V))
      (gaussianReal 0 1) ∧
    (∫ x : ℝ, NormedSpace.exp ((Complex.I * (x : ℂ) * (Real.sqrt τ : ℂ)) • V)
      ∂gaussianReal 0 1) = NormedSpace.exp (((-τ / 2 : ℝ) : ℂ) • V ^ 2) := by
  let D : (n → ℂ) →ₐ[ℂ] Matrix n n ℂ :=
    (Unitary.conjStarAlgAut ℂ _ hV.eigenvectorUnitary).toAlgEquiv.toAlgHom.comp
      (Matrix.diagonalAlgHom (n := n) (α := ℂ) ℂ)
  let d : n → ℂ := fun j ↦ (hV.eigenvalues j : ℂ)
  have hd : D d = V := hV.spectral_theorem.symm
  let L := D.toLinearMap.toContinuousLinearMap
  have hexp (a : n → ℂ) :
      NormedSpace.exp (D a) = D (fun j ↦ Complex.exp (a j)) := by
    rw [← NormedSpace.map_exp D (show Continuous D from L.continuous) a]
    congr 1
    funext j
    rw [Pi.coe_exp, Complex.exp_eq_exp_ℂ]
  let field (x : ℝ) (j : n) :=
    Complex.exp (((Real.sqrt τ * hV.eigenvalues j : ℝ) : ℂ) * x * Complex.I)
  have hfield (x : ℝ) :
      NormedSpace.exp ((Complex.I * (x : ℂ) * (Real.sqrt τ : ℂ)) • V) = L (field x) := by
    rw [← hd, ← map_smul, hexp]
    change D _ = D _
    congr 1
    funext j
    dsimp [field, d]
    push_cast
    congr 1
    ring
  have hi (j : n) : Integrable (fun x ↦ field x j) (gaussianReal 0 1) := by
    apply (integrable_const (1 : ℝ)).mono'
    · dsimp [field]
      fun_prop
    · filter_upwards with x
      simp [field, ← Complex.ofReal_mul, Complex.norm_exp_ofReal_mul_I]
  have hvec : Integrable field (gaussianReal 0 1) := Integrable.of_eval hi
  constructor
  · simpa only [hfield] using L.integrable_comp hvec
  · simp_rw [hfield]
    rw [L.integral_comp_comm hvec, ← hd, ← map_pow, ← map_smul, hexp]
    change D _ = D _
    congr 1
    funext j
    rw [eval_integral hi]
    exact gaussianPhaseAverage hτ (hV.eigenvalues j)

end FormalQChem.StatePrep.ImaginaryTimeProjection.GaussianAuxiliaryField
