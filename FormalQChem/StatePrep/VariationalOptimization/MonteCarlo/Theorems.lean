module

public import Mathlib.LinearAlgebra.Matrix.Symmetric
public import Mathlib.Basic.Real.Basic

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- Finite-configuration variational Monte Carlo. Born-probability averaging of the
local energy gives the Rayleigh quotient, including configurations where the trial state vanishes. -/
def VariationalMonteCarlo (n : ℕ) : Prop :=
  ∀ (H : Matrix (Fin n) (Fin n) ℝ) (ψ : Fin n → ℝ), H.IsSymm → ψ ≠ 0 →
    (∑ i, ψ i ^ 2 * ((H.mulVec ψ) i / ψ i)) / (∑ i, ψ i ^ 2) =
      (∑ i, ψ i * (H.mulVec ψ) i) / (∑ i, ψ i ^ 2)

end FormalQChem.Algorithms
