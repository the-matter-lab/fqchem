module

public import Mathlib.Analysis.InnerProductSpace.Adjoint
public import Mathlib.Analysis.SpecialFunctions.Exponential

/-!
# Time-independent Schrödinger propagation

In units ℏ = 1, a bounded self-adjoint Hamiltonian generates the norm-differentiable
unitary group exp(−itH). This is the bounded-generator direction of
[Stone (1932)](https://doi.org/10.2307/1968538).
-/

@[expose] public section

namespace FQChem.Dynamics.RealTimePropagation

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

end FQChem.Dynamics.RealTimePropagation

namespace FQChem.Dynamics.RealTimePropagation

open NormedSpace
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E]

theorem unitaryEvolution (H : E →L[ℂ] E) : UnitaryEvolution H := by
  let +nondep : NormedAlgebra ℚ (E →L[ℂ] E) := .restrictScalars ℚ ℂ _
  intro hH
  refine ⟨by simp [evolution], ?_, ?_, fun t ↦ hasDerivAt_exp_smul_const' (generator H) t⟩
  · intro s t
    rw [evolution, add_smul]
    exact exp_add_of_commute (((Commute.refl (generator H)).smul_left s).smul_right t)
  · intro t
    apply exp_mem_unitary_of_mem_skewAdjoint
    rw [skewAdjoint.mem_iff]
    simp [generator, star_smul, hH.star_eq]

end FQChem.Dynamics.RealTimePropagation
