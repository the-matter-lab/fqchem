module

public import Mathlib.Analysis.Complex.Basic
public import Mathlib.Analysis.Normed.Algebra.MatrixExponential

@[expose] public section

namespace FQChem.VariationalMethods

open scoped BigOperators Matrix

/-- Similarity transform by the coupled-cluster exponential. -/
noncomputable def transformed {ι : Type*} [Fintype ι] [DecidableEq ι] (H T : Matrix ι ι ℂ) :=
  NormedSpace.exp (-T) * H * NormedSpace.exp T

/-- The negative cluster exponential inverts the positive exponential. -/
theorem expClusterInverse {ι : Type*} [Fintype ι] [DecidableEq ι] (T : Matrix ι ι ℂ) :
    NormedSpace.exp (-T) * NormedSpace.exp T = 1 := by
  rw [← Matrix.exp_add_of_commute _ _ ((Commute.refl T).neg_left), neg_add_cancel, NormedSpace.exp_zero]

/-- For the full coupled-cluster similarity transform the reference eigen-equation
is equivalent to the Schrödinger equation for the exponential ansatz. -/
def CoupledCluster {n : ℕ} (H T : Matrix (Fin n) (Fin n) ℂ) (ref : Fin n → ℂ) (energy : ℂ) : Prop :=
  (transformed H T *ᵥ ref = energy • ref) ↔
    H *ᵥ (NormedSpace.exp T *ᵥ ref) = energy • (NormedSpace.exp T *ᵥ ref)

theorem coupledCluster {n : ℕ} (H T : Matrix (Fin n) (Fin n) ℂ) (ref : Fin n → ℂ) (energy : ℂ) :
    CoupledCluster H T ref energy := by
  have cancel : NormedSpace.exp T * NormedSpace.exp (-T) = 1 := by
    simpa only [neg_neg] using expClusterInverse (-T)
  unfold CoupledCluster transformed
  simp only [← Matrix.mulVec_mulVec]
  constructor
  · intro h
    have heq := congrArg ((NormedSpace.exp T).mulVec) h
    simpa only [Matrix.mulVec_mulVec _ (NormedSpace.exp T) (NormedSpace.exp (-T)),
      cancel, Matrix.one_mulVec, Matrix.mulVec_smul] using heq
  · intro h
    rw [h, Matrix.mulVec_smul, Matrix.mulVec_mulVec, expClusterInverse, Matrix.one_mulVec]

end FQChem.VariationalMethods
