module

public import Mathlib.Analysis.InnerProductSpace.Calculus
public import Mathlib.Analysis.InnerProductSpace.Symmetric
public import Mathlib.LinearAlgebra.Matrix.Hermitian
public import Mathlib.LinearAlgebra.Matrix.Trace

@[expose] public section

namespace FormalQChem.Dynamics

open Matrix
open scoped InnerProductSpace ComplexConjugate

variable {n m : Type*} [Fintype n] [DecidableEq n] [Fintype m] [DecidableEq m]

/-- The empirical tangent covariance of real logarithmic derivatives in
time-dependent VMC is positive semidefinite. Its quadratic form is the
weighted sum of squared directional fluctuations. -/
def SampledTangentMetric {s p : Type*} [Fintype s] [Fintype p]
    (weight : s → ℝ) (O : s → p → ℝ) (direction : p → ℝ) : Prop :=
  (∀ i, 0 ≤ weight i) →
  let centered := fun i j => O i j - ∑ k, weight k * O k j
  let covariance := fun j k => ∑ i, weight i * centered i j * centered i k
  0 ≤ ∑ j, ∑ k, direction j * covariance j k * direction k

/-- McLachlan's projected velocity minimizes the instantaneous residual
over the tangent space of a variational ansatz. -/
def McLachlanProjection {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (T : Submodule ℝ V) (exactVelocity trialVelocity : V) : Prop :=
  trialVelocity ∈ T →
  (∀ w ∈ T, ⟪exactVelocity - trialVelocity, w⟫_ℝ = 0) →
  ∀ v ∈ T, ‖exactVelocity - trialVelocity‖ ^ 2 ≤ ‖exactVelocity - v‖ ^ 2

end FormalQChem.Dynamics
