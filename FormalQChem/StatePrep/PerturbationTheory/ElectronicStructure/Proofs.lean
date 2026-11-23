module

public import FormalQChem.StatePrep.PerturbationTheory.ElectronicStructure.Theorems

@[expose] public section

namespace FormalQChem.VariationalMethods

open scoped BigOperators Matrix
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

theorem mrpt2Shift {ι : Type*} [Fintype ι] (coupling : ι → ℂ) (gap : ι → ℝ) :
    MRPT2Shift coupling gap := by
  intro hg
  exact Finset.sum_nonpos fun i _ ↦ neg_nonpos.mpr
    (div_nonneg (Complex.normSq_nonneg _) (hg i).le)

end FormalQChem.VariationalMethods
