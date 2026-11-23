module

public import Mathlib.Analysis.Matrix.PosDef
public import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.Tactic

/-!
# Operator-sum quantum channels

The ancilla extension acts on every system block of the joint matrix, including
off-diagonal ancilla coherences. References are [Kraus (1971)](https://doi.org/10.1016/0003-4916(71)90108-4)
and [Choi (1975)](https://doi.org/10.1016/0024-3795(75)90075-0).
-/

@[expose] public section
noncomputable section

namespace FQChem.Dynamics.OpenSystems.Kraus

open scoped Matrix ComplexOrder

variable {d k : ℕ}

def operation (K : Fin k → Matrix (Fin d) (Fin d) ℂ) (ρ : Matrix (Fin d) (Fin d) ℂ) :=
  ∑ i, K i * ρ * (K i)ᴴ

/-- Matrix amplification idₐ ⊗ Φ, expressed by applying Φ to each system block. -/
def amplify (a : ℕ) (Φ : Matrix (Fin d) (Fin d) ℂ → Matrix (Fin d) (Fin d) ℂ)
    (ρ : Matrix (Fin a × Fin d) (Fin a × Fin d) ℂ) : Matrix (Fin a × Fin d) (Fin a × Fin d) ℂ :=
  Matrix.of fun r c => Φ (ρ.submatrix (Prod.mk r.1) (Prod.mk c.1)) r.2 c.2

def ComplexLinearity (K : Fin k → Matrix (Fin d) (Fin d) ℂ) : Prop :=
  ∀ (c : ℂ) ρ σ, operation K (c • ρ + σ) = c • operation K ρ + operation K σ

def CompletePositivity (K : Fin k → Matrix (Fin d) (Fin d) ℂ) : Prop :=
  ∀ a ρ, Matrix.PosSemidef ρ → Matrix.PosSemidef (amplify a (operation K) ρ)

def TracePreservation (K : Fin k → Matrix (Fin d) (Fin d) ℂ) : Prop :=
  (∑ i, (K i)ᴴ * K i) = 1 → ∀ ρ, Matrix.trace (operation K ρ) = Matrix.trace ρ

/-- A trace-one positive matrix remains a density matrix under the local operation,
even for entangled inputs and an arbitrary finite ancilla. -/
def JointDensityPreservation (K : Fin k → Matrix (Fin d) (Fin d) ℂ) : Prop :=
  (∑ i, (K i)ᴴ * K i) = 1 → ∀ a ρ, Matrix.PosSemidef ρ → Matrix.trace ρ = 1 →
    Matrix.PosSemidef (amplify a (operation K) ρ) ∧ Matrix.trace (amplify a (operation K) ρ) = 1

end FQChem.Dynamics.OpenSystems.Kraus

namespace FQChem.Dynamics.OpenSystems.Kraus

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

end FQChem.Dynamics.OpenSystems.Kraus
