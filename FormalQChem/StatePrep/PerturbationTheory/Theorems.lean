module

public import Mathlib.LinearAlgebra.Matrix.Hermitian
public import Mathlib.Analysis.Complex.Basic

/-! # Nondegenerate Rayleigh–Schrödinger coefficients

Use an orthonormal eigenbasis of H₀, with real unperturbed energies `e`. The target
basis vector is indexed by `k` and the perturbation is a Hermitian matrix `V`.
The coefficients refer to powers of the parameter, so the quadratic energy
coefficient is half the second derivative when a twice-differentiable branch exists.
Convergence or differentiability of the branch is a separate analytic question.
[Schrödinger (1926), third communication](https://doi.org/10.1002/andp.19263851302). -/

@[expose] public section

namespace FormalQChem.StatePrep.PerturbationTheory

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The linear and quadratic coefficients of `(H₀ + tV) ψ(t) = E(t) ψ(t)`,
with intermediate normalization `ψ(t)ₖ = 1` through second order. -/
structure CoefficientEquations (e : ι → ℝ) (V : Matrix ι ι ℂ) (k : ι)
    (a b : ι → ℂ) (E₁ E₂ : ℂ) : Prop where
  first_reference : a k = 0
  second_reference : b k = 0
  linear (i) : e i * a i + V i k = e k * a i + E₁ * (if i = k then 1 else 0)
  quadratic (i) : e i * b i + ∑ j, V i j * a j =
    e k * b i + E₁ * a i + E₂ * (if i = k then 1 else 0)

/-- Energy gaps are nonzero at the target. In finite dimension a simple target
eigenvalue is separated from the other levels by a positive distance. -/
def Nondegenerate (e : ι → ℝ) (k : ι) : Prop := ∀ i, i ≠ k → e i ≠ e k

/-- Explicit first-order state response in intermediate normalization. -/
noncomputable def firstResponse (e : ι → ℝ) (V : Matrix ι ι ℂ) (k i : ι) : ℂ :=
  if i = k then 0 else V i k / ((e k - e i : ℝ) : ℂ)

/-- Hermitian second-order energy correction, a real sum over other eigenstates. -/
noncomputable def quadraticShift (e : ι → ℝ) (V : Matrix ι ι ℂ) (k : ι) : ℝ :=
  ∑ i ∈ Finset.univ.erase k, Complex.normSq (V i k) / (e k - e i)

/-- A solution of the two formal coefficient equations exists, and all solutions
have the stated first-order response, diagonal energy derivative and quadratic shift. -/
def NondegenerateExpansion (e : ι → ℝ) (V : Matrix ι ι ℂ) (k : ι) : Prop :=
  Nondegenerate e k → V.IsHermitian →
    (∃ b, CoefficientEquations e V k (firstResponse e V k) b (V k k) (quadraticShift e V k)) ∧
    ∀ a b E₁ E₂, CoefficientEquations e V k a b E₁ E₂ →
      E₁ = V k k ∧ a = firstResponse e V k ∧ E₂ = (quadraticShift e V k : ℂ)

/-- The perturbed matrix in the orthonormal eigenbasis of the reference Hamiltonian. -/
noncomputable def perturbedHamiltonian (e : ι → ℝ) (V : Matrix ι ι ℂ) (t : ℂ) : Matrix ι ι ℂ :=
  Matrix.diagonal (fun i ↦ (e i : ℂ)) + t • V

/-- The intermediate-normalized state truncated after the quadratic coefficient. -/
noncomputable def truncatedState (k : ι) (a b : ι → ℂ) (t : ℂ) : ι → ℂ :=
  Pi.single k 1 + t • a + t ^ 2 • b

/-- The energy polynomial of the same order. -/
noncomputable def truncatedEnergy (E₀ E₁ E₂ t : ℂ) : ℂ := E₀ + t * E₁ + t ^ 2 * E₂

/-- The exact Schrödinger residual has no terms below cubic order. The reference
component of the approximation is identically one, so the trial state is nonzero.
The identity is polynomial and in particular holds on the physical real parameter axis. -/
def ResidualIdentity (e : ι → ℝ) (V : Matrix ι ι ℂ) (k : ι)
    (a b : ι → ℂ) (E₁ E₂ : ℂ) : Prop :=
  ∀ t : ℂ, truncatedState k a b t k = 1 ∧ ∀ i,
    (perturbedHamiltonian e V t).mulVec (truncatedState k a b t) i -
      truncatedEnergy (e k) E₁ E₂ t * truncatedState k a b t i =
      t ^ 3 * (V.mulVec b i - E₁ * b i - E₂ * a i - t * E₂ * b i)

/-- The computed nondegenerate response and shifts give a genuine approximate
eigenpair of the perturbed matrix through quadratic order. -/
def SecondOrderQuasimode (e : ι → ℝ) (V : Matrix ι ι ℂ) (k : ι) : Prop :=
  Nondegenerate e k → V.IsHermitian → ∃ b,
    ResidualIdentity e V k (firstResponse e V k) b (V k k) (quadraticShift e V k)

end FormalQChem.StatePrep.PerturbationTheory
