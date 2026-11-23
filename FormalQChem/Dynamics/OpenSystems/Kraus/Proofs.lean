module

public import FormalQChem.Dynamics.OpenSystems.Kraus.Theorems
import Mathlib.Tactic

public section
namespace FormalQChem.Dynamics.OpenSystems.Kraus

open scoped Matrix ComplexOrder
variable {d k : ℕ} (K : Fin k → Matrix (Fin d) (Fin d) ℂ)

/-- Matrix of the lifted Kraus operator Iₐ ⊗ K. -/
private def withAncilla (a : ℕ) (L : Matrix (Fin d) (Fin d) ℂ) :
    Matrix (Fin a × Fin d) (Fin a × Fin d) ℂ :=
  Matrix.of fun r c => if r.1 = c.1 then L r.2 c.2 else 0

private theorem lifted_operation (a : ℕ) (ρ : Matrix (Fin a × Fin d) (Fin a × Fin d) ℂ) :
    amplify a (operation K) ρ =
      ∑ i, withAncilla a (K i) * ρ * (withAncilla a (K i))ᴴ := by
  ext ⟨b, r⟩ ⟨c, s⟩
  simp only [amplify, operation, Matrix.of_apply, Matrix.sum_apply]
  apply Finset.sum_congr rfl
  intro i _
  simp [Matrix.mul_apply, Matrix.conjTranspose_apply, withAncilla, Fintype.sum_prod_type,
    apply_ite, ite_mul, Finset.sum_ite_irrel]

theorem complexLinearity : ComplexLinearity K := by
  intro c ρ σ
  simp [operation, Matrix.mul_add, Matrix.add_mul,
    Finset.sum_add_distrib, Finset.smul_sum]

theorem completePositivity : CompletePositivity K := by
  intro a ρ hρ
  rw [lifted_operation]
  exact Matrix.posSemidef_sum Finset.univ fun i _ => hρ.mul_mul_conjTranspose_same _

theorem tracePreservation : TracePreservation K := by
  intro complete ρ
  unfold operation
  rw [Matrix.trace_sum]
  simp_rw [Matrix.trace_mul_cycle (K _) ρ _]
  rw [← Matrix.trace_sum, ← Matrix.sum_mul, complete, Matrix.one_mul]

theorem jointDensityPreservation : JointDensityPreservation K := by
  intro complete a ρ hρ htrace
  refine ⟨completePositivity K a ρ hρ, ?_⟩
  calc
    Matrix.trace (amplify a (operation K) ρ) =
      ∑ i : Fin a, Matrix.trace (operation K (ρ.submatrix (Prod.mk i) (Prod.mk i))) := by
        simp [Matrix.trace, Matrix.diag, amplify, Fintype.sum_prod_type]
    _ = ∑ i : Fin a, Matrix.trace (ρ.submatrix (Prod.mk i) (Prod.mk i)) := by
        simp only [tracePreservation K complete]
    _ = Matrix.trace ρ := by simp [Matrix.trace, Matrix.diag, Fintype.sum_prod_type]
    _ = 1 := htrace

end FormalQChem.Dynamics.OpenSystems.Kraus
