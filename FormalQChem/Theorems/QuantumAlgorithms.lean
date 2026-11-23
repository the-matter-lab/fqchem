module

public import Mathlib.Analysis.Fourier.ZMod
public import Mathlib.Analysis.Normed.Algebra.MatrixExponential
public import Mathlib.Combinatorics.Enumerative.IncidenceAlgebra
public import Mathlib.Data.Finset.Interval
public import Mathlib.LinearAlgebra.Matrix.Rank
public import Mathlib.LinearAlgebra.Vandermonde

/-! # Finite models for simulation, sampling and reconstruction -/

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- Finite-configuration variational Monte Carlo. Born-probability averaging of the
local energy gives the Rayleigh quotient, including configurations where the trial state vanishes. -/
def VariationalMonteCarlo (n : ℕ) : Prop :=
  ∀ (H : Matrix (Fin n) (Fin n) ℝ) (ψ : Fin n → ℝ), H.IsSymm → ψ ≠ 0 →
    (∑ i, ψ i ^ 2 * ((H.mulVec ψ) i / ψ i)) / (∑ i, ψ i ^ 2) =
      (∑ i, ψ i * (H.mulVec ψ) i) / (∑ i, ψ i ^ 2)

/-- One local matrix is selected by the physical label at each site in an MPS. -/
def siteMatrices {k d χ : ℕ} (A : Fin k → Fin d → Matrix (Fin χ) (Fin χ) ℂ)
    (x : Fin k → Fin d) := List.ofFn (fun i => A i (x i))

/-- Open-boundary cut matrix. Flattening physical configurations on either side of
a bond of dimension χ gives a coefficient matrix of rank at most χ. -/
def MPSCutBound (l r d χ : ℕ) : Prop :=
  ∀ (A : Fin l → Fin d → Matrix (Fin χ) (Fin χ) ℂ)
    (B : Fin r → Fin d → Matrix (Fin χ) (Fin χ) ℂ) (a b : Fin χ),
    (Matrix.of fun (x : Fin l → Fin d) (y : Fin r → Fin d) =>
      ((siteMatrices A x ++ siteMatrices B y).prod) a b).rank ≤ χ

/-- A single bipartition admits a bond-D factorization exactly when the coefficient
matrix has rank at most D. Both factors may have rectangular physical dimensions. -/
def ExactCutFactorization (rows cols D : ℕ) : Prop :=
  ∀ C : Matrix (Fin rows) (Fin cols) ℂ, C.rank ≤ D ↔
    ∃ (L : Matrix (Fin rows) (Fin D) ℂ) (R : Matrix (Fin D) (Fin cols) ℂ), C = L * R

/-- Samples at times k Δτ of a discrete imaginary-time spectrum at known energies. -/
def laplaceSample {n : ℕ} (Δτ : ℝ) (energy weight : Fin n → ℝ) (k : ℕ) :=
  ∑ j, weight j * Real.exp (-Δτ * energy j) ^ k

/-- At n distinct known energies, n exact equally spaced samples determine all spectral weights. -/
def SpectralIdentification (n : ℕ) : Prop :=
  ∀ (Δτ : ℝ) (energy a b : Fin n → ℝ), 0 < Δτ → Function.Injective energy →
    (∀ k : Fin n, laplaceSample Δτ energy a k = laplaceSample Δτ energy b k) → a = b

/-- Complex phase of a trajectory weight. A zero-weight path contributes zero. -/
def pathPhase (z : ℂ) : ℂ := z / (‖z‖ : ℂ)

/-- Phase reweighting in real-time Monte Carlo. The ratio under magnitude sampling
recovers the complex-weight estimator. The mean phase has modulus at most one. -/
def RealTimeReweighting (n : ℕ) : Prop :=
  ∀ (w O : Fin n → ℂ), (∑ i, w i) ≠ 0 →
    (∑ i, (‖w i‖ : ℂ) * pathPhase (w i) * O i) / (∑ i, (‖w i‖ : ℂ) * pathPhase (w i)) =
      (∑ i, w i * O i) / (∑ i, w i) ∧ ‖∑ i, w i‖ / (∑ i, ‖w i‖) ≤ 1

/-- Linked-cluster subtraction on labeled finite subsets. The recursive subtraction
of proper subcluster weights uniquely recovers the Möbius coefficients of the observable. -/
def LinkedClusterInversion (n : ℕ) : Prop :=
  ∀ (obs weight : Finset (Fin n) → ℝ),
    (∀ S, weight S = obs S - ∑ T ∈ S.powerset.erase S, weight T) →
      ∀ S, weight S = ∑ T ∈ S.powerset, IncidenceAlgebra.mu ℝ T S * obs T

/-- In ideal phase estimation with an exactly representable eigenphase m/N, the
normalized amplitude at output k is the Fourier sum of (m-k) and equals a Kronecker delta. -/
def ExactGridQPE (N : ℕ) [NeZero N] : Prop :=
  ∀ m k : ZMod N,
    (∑ j : ZMod N, ZMod.stdAddChar (j * (m - k))) / (N : ℂ) = if m = k then 1 else 0

/-- Number of occupied conflicting pairs in a classical configuration at zero drive. -/
def blockadeViolations {n : ℕ} (edges : Finset (Fin n × Fin n)) (s : Finset (Fin n)) :=
  (edges.filter (fun e => e.1 ∈ s ∧ e.2 ∈ s)).card

/-- Unit-detuning, uniform-penalty energy of an ideal zero-drive Rydberg blockade model. -/
def blockadeEnergy {n : ℕ} (edges : Finset (Fin n × Fin n)) (penalty : ℝ)
    (s : Finset (Fin n)) := penalty * blockadeViolations edges s - s.card

/-- For a penalty exceeding the number of sites, the ground configurations of the
blockade energy are exactly the maximum independent sets of the interaction graph. -/
def RydbergBlockade (n : ℕ) : Prop :=
  ∀ (edges : Finset (Fin n × Fin n)) (penalty : ℝ), (n : ℝ) < penalty →
    ∀ s, (∀ t, blockadeEnergy edges penalty s ≤ blockadeEnergy edges penalty t) ↔
      blockadeViolations edges s = 0 ∧
        ∀ t, blockadeViolations edges t = 0 → t.card ≤ s.card

/-- For commuting local generators, n product-formula steps exactly implement the
matrix exponential of the sum for the full duration. Time-step factors are absorbed into A, B. -/
def CommutingProductFormula (d : ℕ) : Prop :=
  ∀ (A B : Matrix (Fin d) (Fin d) ℂ), Commute A B → ∀ n : ℕ,
    (NormedSpace.exp A * NormedSpace.exp B) ^ n = NormedSpace.exp (n • (A + B))

/-- The exact spectral-inversion step in HHL. On input supported on nonzero
eigenvalues, applying their reciprocals to the input coefficients solves the linear system. -/
def HHLSpectralInversion (d k : ℕ) : Prop :=
  ∀ (A : (Fin d → ℂ) →ₗ[ℂ] (Fin d → ℂ)) (u : Fin k → Fin d → ℂ)
    (eigenvalue b : Fin k → ℂ), (∀ j, A (u j) = eigenvalue j • u j) → (∀ j, eigenvalue j ≠ 0) →
      A (∑ j, (b j / eigenvalue j) • u j) = ∑ j, b j • u j

/-- Exact sine eigenmode of the one-dimensional Dirichlet finite-difference Poisson
stencil used in quantum linear-system discretizations. The interior contains N sites. -/
def DirichletPoissonMode (N m : ℕ) : Prop :=
  0 < m → m ≤ N → ∀ h : ℝ, 0 < h →
    let θ := (m : ℝ) * Real.pi / (N + 1)
    let u := fun j : ℤ => Real.sin (j * θ)
    0 < u 1 ∧ u 0 = 0 ∧ u (N + 1) = 0 ∧ ∀ j : ℤ,
      (2 * u j - u (j-1) - u (j+1)) / h^2 = ((2-2*Real.cos θ) / h^2) * u j

end FormalQChem.Algorithms
