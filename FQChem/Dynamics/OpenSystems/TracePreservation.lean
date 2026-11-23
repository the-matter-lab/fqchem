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

/-- Each Lindblad dissipator has zero trace. The anticommutator term is
written with a scalar one-half. -/
def LindbladTrace (L ρ : Matrix n n ℂ) : Prop :=
  (L * ρ * Lᴴ - (1 / 2 : ℂ) • (Lᴴ * L * ρ + ρ * (Lᴴ * L))).trace = 0

/-- A finite Kraus channel obeying the completeness relation preserves trace. -/
def KrausTrace {a : Type*} [Fintype a] (K : a → Matrix n n ℂ) (ρ : Matrix n n ℂ) : Prop :=
  (∑ i, (K i)ᴴ * K i) = 1 → (∑ i, K i * ρ * (K i)ᴴ).trace = ρ.trace

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

end FQChem.Dynamics
