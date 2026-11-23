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

/-- In fixed-basis time-dependent CI with a real symmetric Hamiltonian,
the coupled real and imaginary coefficient equations preserve norm squared
to first order. The Hamiltonian may vary in time. -/
def TDConfigurationInteraction {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (H : V →ₗ[ℝ] V) (a b : ℝ → V) (t : ℝ) : Prop :=
  H.IsSymmetric → HasDerivAt a (H (b t)) t → HasDerivAt b (-H (a t)) t →
    HasDerivAt (fun s => ⟪a s, a s⟫_ℝ + ⟪b s, b s⟫_ℝ) 0 t

theorem tdConfigurationInteraction {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (H : V →ₗ[ℝ] V) (a b : ℝ → V) (t : ℝ) : TDConfigurationInteraction H a b t := by
  intro hH ha hb
  have h := HasDerivAt.add (ha.inner ℝ ha) (hb.inner ℝ hb)
  convert h using 1
  rw [inner_neg_left, inner_neg_right, hH (b t) (a t), ← hH (a t) (b t)]
  ring

end FormalQChem.Dynamics
