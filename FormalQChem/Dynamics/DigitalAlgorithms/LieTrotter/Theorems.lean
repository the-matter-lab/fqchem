module

public import Mathlib.Analysis.SpecialFunctions.Exponential

/-! # Noncommuting Hamiltonian splitting -/

@[expose] public section

namespace FormalQChem.Dynamics

open Filter NormedSpace
open scoped Topology

/-- The global error of a repeated contraction step is at most the step
count times its local defect. Unitary propagators in operator norm qualify. -/
def GlobalStepError {R : Type*} [NormedRing R] (step exactStep : R) : Prop :=
  ‖step‖ ≤ 1 → ‖exactStep‖ ≤ 1 →
    ∀ n : ℕ, ‖step ^ n - exactStep ^ n‖ ≤ n * ‖step - exactStep‖

/-- The two-generator Lie–Trotter product converges in norm in a unital
real Banach algebra with normalized identity. The generators may be
noncommuting bounded operators; a fixed propagation time is absorbed in
`X` and `Y`. -/
def LieTrotter {R : Type*} [NormedRing R] [NormedAlgebra ℝ R] [CompleteSpace R]
    (X Y : R) : Prop :=
  Tendsto (fun n : ℕ => (exp ((n : ℝ)⁻¹ • X) * exp ((n : ℝ)⁻¹ • Y)) ^ n)
    atTop (𝓝 (exp (X + Y)))

end FormalQChem.Dynamics
