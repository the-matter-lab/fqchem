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

/-- Along a one-coordinate Born–Oppenheimer Newton trajectory on a
differentiable adiabatic energy surface, total mechanical energy is stationary. -/
def BornOppenheimerEnergy (mass : ℝ) (q v U : ℝ → ℝ) (t force : ℝ) : Prop :=
  0 < mass → HasDerivAt q (v t) t → HasDerivAt v (force / mass) t →
  HasDerivAt U (-force) (q t) →
  HasDerivAt (fun s => mass * (v s) ^ 2 / 2 + U (q s)) 0 t

/-- Harmonic spring forces cancel in the sum over beads of a ring polymer.
For a cycle, the neighbor permutation and its inverse pick the two neighbors. -/
def RingPolymerSpringForce {b : Type*} [Fintype b] (next : Equiv.Perm b)
    (q : b → ℝ) (spring : ℝ) : Prop :=
  ∑ i, spring * (q (next i) + q (next.symm i) - 2 * q i) = 0

/-- In fixed-basis time-dependent CI with a real symmetric Hamiltonian,
the coupled real and imaginary coefficient equations preserve norm squared
to first order. The Hamiltonian may vary in time. -/
def TDConfigurationInteraction {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (H : V →ₗ[ℝ] V) (a b : ℝ → V) (t : ℝ) : Prop :=
  H.IsSymmetric → HasDerivAt a (H (b t)) t → HasDerivAt b (-H (a t)) t →
    HasDerivAt (fun s => ⟪a s, a s⟫_ℝ + ⟪b s, b s⟫_ℝ) 0 t

end FormalQChem.Dynamics
