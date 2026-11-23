module

public import FormalQChem.Dynamics.OpenSystems.Theorems
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add

public section

namespace FormalQChem.Dynamics

open Matrix
open scoped InnerProductSpace ComplexConjugate

variable {n m : Type*} [Fintype n] [DecidableEq n] [Fintype m] [DecidableEq m]

omit [DecidableEq n] in
theorem lindbladTrace (L ρ : Matrix n n ℂ) : LindbladTrace L ρ := by
  unfold LindbladTrace
  rw [trace_sub, trace_smul, trace_add, trace_mul_cycle L ρ Lᴴ,
    trace_mul_comm ρ (Lᴴ * L)]
  simp only [smul_eq_mul]
  ring

theorem krausTrace {a : Type*} [Fintype a] (K : a → Matrix n n ℂ) (ρ : Matrix n n ℂ) :
    KrausTrace K ρ := by
  intro h
  rw [trace_sum]
  simp_rw [trace_mul_cycle (K _) ρ]
  rw [← trace_sum, ← Matrix.sum_mul, h, one_mul]

end FormalQChem.Dynamics
