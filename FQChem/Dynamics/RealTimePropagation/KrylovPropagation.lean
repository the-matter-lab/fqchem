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

/-- If a Krylov basis spans an invariant subspace, the reduced Hamiltonian
reproduces every monomial action on that basis, at any order. -/
def KrylovExact (H : Matrix n n ℂ) (Q : Matrix n m ℂ) (K : Matrix m m ℂ) : Prop :=
  H * Q = Q * K → ∀ k : ℕ, H ^ k * Q = Q * K ^ k

/-- If the first `d + 1` Krylov vectors lie in an orthonormal trial basis,
Galerkin propagation in that basis reproduces the degree-`d` Hamiltonian
monomial on the seed vector. Membership is expressed by the projector `Q Q†`
fixing each vector. -/
def KrylovMoment (H : Matrix n n ℂ) (Q : Matrix n m ℂ) (v : Matrix n (Fin 1) ℂ)
    (d : ℕ) : Prop :=
  (∀ j ≤ d, (Q * Qᴴ) * (H ^ j * v) = H ^ j * v) →
    Q * ((Qᴴ * H * Q) ^ d * (Qᴴ * v)) = H ^ d * v

theorem krylovExact (H : Matrix n n ℂ) (Q : Matrix n m ℂ) (K : Matrix m m ℂ) :
    KrylovExact H Q K := by
  intro h k
  induction k with
  | zero => simp
  | succ k ih => rw [pow_succ, pow_succ, Matrix.mul_assoc, h, ← Matrix.mul_assoc, ih,
      Matrix.mul_assoc]

theorem krylovMoment (H : Matrix n n ℂ) (Q : Matrix n m ℂ) (v : Matrix n (Fin 1) ℂ)
    (d : ℕ) : KrylovMoment H Q v d := by
  intro h
  induction d with
  | zero => simpa [Matrix.mul_assoc] using h 0 (by omega)
  | succ d ih =>
    have prev := ih (fun j hj => h j (by omega))
    calc
      _ = (Q * Qᴴ) * (H * (Q * ((Qᴴ * H * Q) ^ d * (Qᴴ * v)))) := by
        rw [pow_succ']
        simp only [Matrix.mul_assoc]
      _ = (Q * Qᴴ) * (H ^ (d + 1) * v) := by rw [prev, pow_succ' H, Matrix.mul_assoc H]
      _ = _ := h _ le_rfl

end FQChem.Dynamics
