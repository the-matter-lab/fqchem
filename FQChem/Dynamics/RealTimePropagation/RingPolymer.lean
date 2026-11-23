module

public import Mathlib.Analysis.InnerProductSpace.Calculus
public import Mathlib.Analysis.InnerProductSpace.Symmetric
public import Mathlib.LinearAlgebra.Matrix.Hermitian
public import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add

@[expose] public section

namespace FQChem.Dynamics

open Matrix
open scoped InnerProductSpace ComplexConjugate

variable {n m : Type*} [Fintype n] [DecidableEq n] [Fintype m] [DecidableEq m]

/-- Harmonic spring forces cancel in the sum over beads of a ring polymer.
For a cycle, the neighbor permutation and its inverse pick the two neighbors. -/
def RingPolymerSpringForce {b : Type*} [Fintype b] (next : Equiv.Perm b)
    (q : b → ℝ) (spring : ℝ) : Prop :=
  ∑ i, spring * (q (next i) + q (next.symm i) - 2 * q i) = 0

theorem ringPolymerSpringForce {b : Type*} [Fintype b] (next : Equiv.Perm b)
    (q : b → ℝ) (spring : ℝ) : RingPolymerSpringForce next q spring := by
  unfold RingPolymerSpringForce
  rw [← Finset.mul_sum, Finset.sum_sub_distrib, Finset.sum_add_distrib,
    Equiv.sum_comp next q, Equiv.sum_comp next.symm q, ← Finset.mul_sum]
  ring

end FQChem.Dynamics
