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

theorem coupledCluster {n : ℕ} (H T : Matrix (Fin n) (Fin n) ℂ) (ref : Fin n → ℂ) (energy : ℂ) :
    CoupledCluster H T ref energy := by
  have cancel (A : Matrix (Fin n) (Fin n) ℂ) :
      NormedSpace.exp A * NormedSpace.exp (-A) = 1 := by
    rw [← Matrix.exp_add_of_commute _ _ (Commute.refl A).neg_right, add_neg_cancel,
      NormedSpace.exp_zero]
  have cancel' : NormedSpace.exp (-T) * NormedSpace.exp T = 1 := by simpa using cancel (-T)
  unfold CoupledCluster
  simp only [← Matrix.mulVec_mulVec]
  constructor
  · intro h
    have heq := congrArg ((NormedSpace.exp T).mulVec) h
    simpa only [Matrix.mulVec_mulVec _ (NormedSpace.exp T) (NormedSpace.exp (-T)),
      cancel, Matrix.one_mulVec, Matrix.mulVec_smul] using heq
  · intro h
    rw [h, Matrix.mulVec_smul, Matrix.mulVec_mulVec, cancel', Matrix.one_mulVec]

end FormalQChem.VariationalMethods
