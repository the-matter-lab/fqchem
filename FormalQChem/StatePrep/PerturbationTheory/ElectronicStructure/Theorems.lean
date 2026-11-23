module

public import Mathlib.Analysis.Complex.Basic
public import Mathlib.Analysis.Normed.Algebra.MatrixExponential

@[expose] public section

namespace FormalQChem.VariationalMethods
open scoped BigOperators Matrix

/-- For the full coupled-cluster similarity transform the reference eigen-equation
is equivalent to the Schrödinger equation for the exponential ansatz. -/
def CoupledCluster {n : ℕ} (H T : Matrix (Fin n) (Fin n) ℂ) (ref : Fin n → ℂ) (energy : ℂ) : Prop :=
  ((NormedSpace.exp (-T) * H * NormedSpace.exp T) *ᵥ ref = energy • ref) ↔
    H *ᵥ (NormedSpace.exp T *ᵥ ref) = energy • (NormedSpace.exp T *ᵥ ref)

/-- The second-order external-space shift for a multiconfigurational reference is
nonpositive if every external class has a strictly positive energy gap. -/
def MRPT2Shift {ι : Type*} [Fintype ι] (coupling : ι → ℂ) (gap : ι → ℝ) : Prop :=
  (∀ i, 0 < gap i) → (∑ i, -(Complex.normSq (coupling i) / gap i)) ≤ 0

end FormalQChem.VariationalMethods
