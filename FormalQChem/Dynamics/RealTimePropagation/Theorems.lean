module

public import Mathlib.Analysis.InnerProductSpace.Adjoint
public import Mathlib.Analysis.SpecialFunctions.Exponential

/-! # Time-independent Schrödinger propagation

In units ℏ = 1, a bounded self-adjoint Hamiltonian generates the norm-differentiable
unitary group exp(−itH). This is the bounded-generator direction of
[Stone (1932)](https://doi.org/10.2307/1968538). -/

@[expose] public section

namespace FormalQChem.Dynamics.RealTimePropagation

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E]

/-- The Schrödinger generator in atomic units. -/
noncomputable def generator (H : E →L[ℂ] E) := (-Complex.I) • H

/-- The time-independent propagator with initial time zero. -/
noncomputable def evolution (H : E →L[ℂ] E) (t : ℝ) := NormedSpace.exp (t • generator H)

/-- Identity at time zero, composition in time, unitarity and the Schrödinger
differential equation in operator norm. -/
def UnitaryEvolution (H : E →L[ℂ] E) : Prop :=
  IsSelfAdjoint H → evolution H 0 = 1 ∧
    (∀ s t, evolution H (s + t) = evolution H s * evolution H t) ∧
    (∀ t, evolution H t ∈ unitary (E →L[ℂ] E)) ∧
    ∀ t, HasDerivAt (evolution H) (generator H * evolution H t) t

end FormalQChem.Dynamics.RealTimePropagation
