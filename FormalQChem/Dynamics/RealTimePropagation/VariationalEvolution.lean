module

public import Mathlib.Analysis.InnerProductSpace.Calculus
public import Mathlib.Analysis.InnerProductSpace.Symmetric
public import Mathlib.LinearAlgebra.Matrix.Hermitian
public import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add

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

theorem sampledTangentMetric {s p : Type*} [Fintype s] [Fintype p]
    (weight : s → ℝ) (O : s → p → ℝ) (direction : p → ℝ) :
    SampledTangentMetric weight O direction := by
  intro hw centered covariance
  have expand (j k : p) : direction j * covariance j k * direction k =
      ∑ i, weight i * ((direction j * centered i j) * (direction k * centered i k)) := by
    dsimp [covariance]
    rw [Finset.mul_sum, Finset.sum_mul]
    exact Finset.sum_congr rfl fun i _ => by ring
  simp_rw [expand]
  simp_rw [Finset.sum_comm (f := fun k i => weight i * _)]
  rw [Finset.sum_comm]
  apply Finset.sum_nonneg
  intro i _
  simp_rw [← Finset.mul_sum]
  rw [← Finset.sum_mul]
  exact mul_nonneg (hw _) (mul_self_nonneg _)

theorem mcLachlanProjection {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (T : Submodule ℝ V) (exactVelocity trialVelocity : V) :
    McLachlanProjection T exactVelocity trialVelocity := by
  intro htrial horth v hv
  rw [show exactVelocity - v = (exactVelocity - trialVelocity) + (trialVelocity - v) by abel,
    norm_add_sq_real, horth _ (T.sub_mem htrial hv)]
  linarith [sq_nonneg ‖trialVelocity - v‖]

end FormalQChem.Dynamics
