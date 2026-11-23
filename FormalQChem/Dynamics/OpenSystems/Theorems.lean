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

/-- Each Lindblad dissipator has zero trace. The anticommutator term is
written with a scalar one-half. -/
def LindbladTrace (L ρ : Matrix n n ℂ) : Prop :=
  (L * ρ * Lᴴ - (1 / 2 : ℂ) • (Lᴴ * L * ρ + ρ * (Lᴴ * L))).trace = 0

/-- A finite Kraus channel obeying the completeness relation preserves trace. -/
def KrausTrace {a : Type*} [Fintype a] (K : a → Matrix n n ℂ) (ρ : Matrix n n ℂ) : Prop :=
  (∑ i, (K i)ᴴ * K i) = 1 → (∑ i, K i * ρ * (K i)ᴴ).trace = ρ.trace

end FormalQChem.Dynamics
