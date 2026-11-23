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

/-- The symmetric split propagator (potential half step, kinetic step,
potential half step) is isometric when its substeps are isometric. -/
def SplitOperator (V T : Matrix n n ℂ) : Prop :=
  Vᴴ * V = 1 → Tᴴ * T = 1 →
  (V * T * V)ᴴ * (V * T * V) = 1

theorem splitOperator (V T : Matrix n n ℂ) : SplitOperator V T := by
  intro hV hT
  have product (A B : Matrix n n ℂ) (ha : Aᴴ * A = 1) (hb : Bᴴ * B = 1) :
      (A * B)ᴴ * (A * B) = 1 := by
    rw [conjTranspose_mul, Matrix.mul_assoc, ← Matrix.mul_assoc Aᴴ A, ha, one_mul, hb]
  exact product _ _ (product _ _ hV hT) hV

end FormalQChem.Dynamics
