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

/-- An invariant differentiable energy model gives the same directional
force at symmetry-related configurations and correspondingly transformed
displacements. Orthogonal transforms include rotations and atom relabelings. -/
def InvariantDirectionalForce {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
    (E : V → ℝ) (R : V ≃ₗᵢ[ℝ] V) (q : V) : Prop :=
  (∀ p, E (R p) = E p) → DifferentiableAt ℝ E (R q) →
  ∀ δ, -(fderiv ℝ E (R q) (R δ)) = -(fderiv ℝ E q δ)

end FormalQChem.Dynamics
