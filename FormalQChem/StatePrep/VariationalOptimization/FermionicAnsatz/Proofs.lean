module

public import FormalQChem.StatePrep.VariationalOptimization.RayleighRitz.Proofs
public import FormalQChem.StatePrep.VariationalOptimization.FermionicAnsatz.Theorems

@[expose] public section

namespace FormalQChem.VariationalMethods

open FormalQChem.RayleighRitz
open scoped BigOperators Matrix
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

theorem slaterTrialBound {m n : ℕ} (orbital : Fin n → Fin m → ℂ)
    (H : EuclideanSpace ℂ (Fin n → Fin m) →L[ℂ] EuclideanSpace ℂ (Fin n → Fin m)) :
    SlaterTrialBound orbital H :=
  fun hψ ↦ ritzEnergy_le H (by
    intro x σ
    exact Matrix.det_permute σ (Matrix.of fun i j ↦ orbital j (x i))) hψ

theorem neuralAntisymmetry {X : Type*} {n k : ℕ}
    (orb : Fin k → (Fin n → X) → Matrix (Fin n) (Fin n) ℂ) (w : Fin k → ℂ) :
    NeuralAntisymmetry orb w := by
  intro equivariant x σ
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  rw [equivariant, Matrix.det_permute]
  ring

end FormalQChem.VariationalMethods
