module

public import FormalQChem.Theorems.RayleighRitz
public import Mathlib.Analysis.InnerProductSpace.PiL2
public import Mathlib.Analysis.Normed.Algebra.MatrixExponential

/-! # Finite-basis wavefunction methods

Each statement specifies one exact property of the method. Sampling and optimization errors
are outside these idealized statements. -/

@[expose] public section

namespace FormalQChem.VariationalMethods
open FormalQChem.RayleighRitz
open scoped BigOperators Matrix

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- Slater trial amplitudes on a finite one-particle grid, before normalization. -/
noncomputable def slaterState {m n : ℕ} (orbital : Fin n → Fin m → ℂ) :
    EuclideanSpace ℂ (Fin n → Fin m) :=
  WithLp.toLp 2 fun x ↦ (Matrix.of fun i j ↦ orbital j (x i)).det

/-- Antisymmetric wavefunctions on the finite coordinate grid for identical fermions. -/
def fermionSector (m n : ℕ) : Submodule ℂ (EuclideanSpace ℂ (Fin n → Fin m)) where
  carrier := {ψ | ∀ x (σ : Equiv.Perm (Fin n)), ψ (x ∘ σ) = (Equiv.Perm.sign σ : ℂ) * ψ x}
  zero_mem' := by simp
  add_mem' := by
    intro ψ φ hψ hφ x σ
    simpa only [PiLp.add_apply, mul_add] using congrArg₂ (· + ·) (hψ x σ) (hφ x σ)
  smul_mem' := by
    intro z ψ hψ x σ
    simp only [PiLp.smul_apply, smul_eq_mul, hψ x σ]
    ring

/-- A single-determinant Hartree–Fock trial bounds the lowest energy in the
antisymmetric sector, for any finite grid of one-particle spin orbitals. -/
def SlaterTrialBound {m n : ℕ} (orbital : Fin n → Fin m → ℂ)
    (H : EuclideanSpace ℂ (Fin n → Fin m) →L[ℂ] EuclideanSpace ℂ (Fin n → Fin m)) : Prop :=
  slaterState orbital ≠ 0 →
    ritzEnergy H (fermionSector m n) ≤ H.rayleighQuotient (slaterState orbital)

/-- Enlarge a selected CI space by including more determinant configurations. -/
def SelectedCI {ι : Type*} (H : E →L[ℂ] E) (determinant : ι → E) : Prop :=
  ∀ (A B : Set ι), A ⊆ B → (∃ i ∈ A, determinant i ≠ 0) →
    ritzEnergy H (Submodule.span ℂ (determinant '' B)) ≤
      ritzEnergy H (Submodule.span ℂ (determinant '' A))

/-- Span of the iterates numbered 0 through n (including the reference). -/
def orbitSpace (step : E → E) (ψ : E) (n : ℕ) : Submodule ℂ E :=
  Submodule.span ℂ ((fun j : ℕ ↦ step^[j] ψ) '' Set.Iic n)

/-- H-generated Lanczos spaces give monotonically improving lowest Ritz energies. -/
def ClassicalKrylov (H : E →L[ℂ] E) (ψ : E) : Prop :=
  ψ ≠ 0 → ∀ n, ritzEnergy H (orbitSpace H ψ (n + 1)) ≤ ritzEnergy H (orbitSpace H ψ n)

/-- Time steps via a unitary evolution U generate nested quantum Krylov spaces. -/
def QuantumKrylov (H : E →L[ℂ] E) (U : E ≃ₗᵢ[ℂ] E) (ψ : E) : Prop :=
  ψ ≠ 0 → ∀ n, ritzEnergy H (orbitSpace U ψ (n + 1)) ≤ ritzEnergy H (orbitSpace U ψ n)

/-- For the full coupled-cluster similarity transform the reference eigen-equation
is equivalent to the Schrödinger equation for the exponential ansatz. -/
def CoupledCluster {n : ℕ} (H T : Matrix (Fin n) (Fin n) ℂ) (ref : Fin n → ℂ) (energy : ℂ) : Prop :=
  ((NormedSpace.exp (-T) * H * NormedSpace.exp T) *ᵥ ref = energy • ref) ↔
    H *ᵥ (NormedSpace.exp T *ᵥ ref) = energy • (NormedSpace.exp T *ᵥ ref)

/-- The second-order external-space shift for a multiconfigurational reference is
nonpositive if every external class has a strictly positive energy gap. -/
def MRPT2Shift {ι : Type*} [Fintype ι] (coupling : ι → ℂ) (gap : ι → ℝ) : Prop :=
  (∀ i, 0 < gap i) → (∑ i, -(Complex.normSq (coupling i) / gap i)) ≤ 0

/-- A weighted sum of determinants built from particle-permutation equivariant
orbital matrices is a fermionic ansatz, as used by FermiNet. -/
def NeuralAntisymmetry {X : Type*} {n k : ℕ}
    (orb : Fin k → (Fin n → X) → Matrix (Fin n) (Fin n) ℂ) (w : Fin k → ℂ) : Prop :=
  (∀ a x (σ : Equiv.Perm (Fin n)), orb a (x ∘ σ) = (orb a x).submatrix σ id) →
    ∀ x (σ : Equiv.Perm (Fin n)), (∑ a, w a * (orb a (x ∘ σ)).det) =
      (Equiv.Perm.sign σ : ℂ) * ∑ a, w a * (orb a x).det

/-- With amplitudes in an orthonormal eigenbasis, excluding every eigenstate below
the target energy bounds the trial expectation by the target. -/
def ExcitedStateBound {ι : Type*} [Fintype ι] (energy : ι → ℝ) (c : ι → ℂ) (target : ℝ) : Prop :=
  (∑ i, Complex.normSq (c i)) = 1 → (∀ i, energy i < target → c i = 0) →
    target ≤ ∑ i, energy i * Complex.normSq (c i)

/-- The ideal VQE objective is the real expectation value of H on the circuit output.
A normalized reference stays normalized; a reachable ground eigenstate attains the bound. -/
def VQE {Θ : Type*} (H : E →L[ℂ] E) (U : Θ → E ≃ₗᵢ[ℂ] E) (ref : E) : Prop :=
  ‖ref‖ = 1 → ∀ θ,
    groundEnergy H ≤ H.reApplyInnerSelf (U θ ref) ∧
    (H (U θ ref) = (groundEnergy H : ℂ) • U θ ref →
      H.reApplyInnerSelf (U θ ref) = groundEnergy H)

/-- If one parameter prepares a ground eigenstate, the ideal VQE energy minimum
over the entire parameter space exists and is exactly the ground energy. -/
def ReachableVQEMinimum {Θ : Type*} (H : E →L[ℂ] E) (U : Θ → E ≃ₗᵢ[ℂ] E) (ref : E) : Prop :=
  ‖ref‖ = 1 → (∃ θ, H (U θ ref) = (groundEnergy H : ℂ) • U θ ref) →
    IsLeast (Set.range fun θ ↦ H.reApplyInnerSelf (U θ ref)) (groundEnergy H)

/-- Diagonalization in a sampled configuration span is exact whenever the recovered
span contains a minimizing state (even if most configurations were never sampled). -/
def SampledDiagonalization {ι : Type*} (H : E →L[ℂ] E) (config : ι → E) (samples : Set ι) : Prop :=
  ∀ ψ ∈ Submodule.span ℂ (config '' samples), ψ ≠ (0 : E) →
    H.rayleighQuotient ψ = groundEnergy H →
    ritzEnergy H (Submodule.span ℂ (config '' samples)) = groundEnergy H

/-- Variational quantum deflation in an exact orthonormal eigenbasis. The penalty on
each lower eigenstate must lift its energy to at least the target. The target eigenstate
itself achieves equality when it has zero penalty. -/
def QuantumDeflation {ι : Type*} [Fintype ι] [DecidableEq ι] (energy penalty : ι → ℝ) (k : ι) : Prop :=
  (∀ i, energy k ≤ energy i + penalty i) → penalty k = 0 →
    (∀ c : ι → ℂ, (∑ i, Complex.normSq (c i)) = 1 →
      energy k ≤ ∑ i, (energy i + penalty i) * Complex.normSq (c i)) ∧
    (∑ i, (energy i + penalty i) * Complex.normSq (if i = k then (1 : ℂ) else 0)) = energy k

end FormalQChem.VariationalMethods
