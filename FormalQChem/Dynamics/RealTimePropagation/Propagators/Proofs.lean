module

public import FormalQChem.Dynamics.RealTimePropagation.Propagators.Theorems
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add

public section

namespace FormalQChem.Dynamics

open Matrix
open scoped InnerProductSpace ComplexConjugate

variable {n m : Type*} [Fintype n] [DecidableEq n] [Fintype m] [DecidableEq m]

theorem splitOperator (V T : Matrix n n ℂ) : SplitOperator V T := by
  intro hV hT
  have product (A B : Matrix n n ℂ) (ha : Aᴴ * A = 1) (hb : Bᴴ * B = 1) :
      (A * B)ᴴ * (A * B) = 1 := by
    rw [conjTranspose_mul, Matrix.mul_assoc, ← Matrix.mul_assoc Aᴴ A, ha, one_mul, hb]
  exact product _ _ (product _ _ hV hT) hV

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

omit [DecidableEq n] in
theorem pictureDuality (U ρ O : Matrix n n ℂ) : PictureDuality U ρ O := by
  unfold PictureDuality
  simp only [Matrix.mul_assoc]
  rw [trace_mul_comm U, Matrix.mul_assoc, Matrix.mul_assoc]

theorem pauliRotation (P Q : Matrix n n ℂ) (a b : ℂ) : PauliRotation P Q a b := by
  intro hP hcomm
  have hPQP : (P * Q) * P = -Q := by
    rw [Matrix.mul_assoc, hcomm, Matrix.mul_neg, ← Matrix.mul_assoc, hP, one_mul]
  simp only [add_mul, mul_sub, smul_mul_assoc, mul_smul_comm, one_mul, mul_one,
    hcomm, hPQP, smul_neg, add_smul]
  module

end FormalQChem.Dynamics
