module

public import FormalQChem.StatePrep.VariationalOptimization.RayleighRitz
public import Mathlib.Analysis.InnerProductSpace.PiL2

@[expose] public section

namespace FormalQChem.VariationalMethods

open FormalQChem.RayleighRitz
open scoped BigOperators Matrix

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- Slater trial amplitudes on a finite one-particle grid, before normalization. -/
noncomputable def slaterState {m n : ℕ} (orbital : Fin n → Fin m → ℂ) :
    EuclideanSpace ℂ (Fin n → Fin m) :=
  WithLp.toLp 2 fun x ↦ (Matrix.of fun i j ↦ orbital j (x i)).det

/-- Antisymmetric wavefunctions on the finite coordinate grid for identical fermions. -/
def fermionSector (m n : ℕ) : Submodule ℂ (EuclideanSpace ℂ (Fin n → Fin m)) where
  carrier := {ψ | ∀ x (σ : Equiv.Perm (Fin n)), ψ (x ∘ σ) = (Equiv.Perm.sign σ : ℂ) * ψ x}
  zero_mem' := by simp
  add_mem' := by
    intro ψ φ hψ hφ x σ
    simpa only [PiLp.add_apply, mul_add] using congrArg₂ (· + ·) (hψ x σ) (hφ x σ)
  smul_mem' := by
    intro z ψ hψ x σ
    simp only [PiLp.smul_apply, smul_eq_mul, hψ x σ]
    ring

/-- A single-determinant Hartree–Fock trial bounds the lowest energy in the
antisymmetric sector, for any finite grid of one-particle spin orbitals. -/
def SlaterTrialBound {m n : ℕ} (orbital : Fin n → Fin m → ℂ)
    (H : EuclideanSpace ℂ (Fin n → Fin m) →L[ℂ] EuclideanSpace ℂ (Fin n → Fin m)) : Prop :=
  slaterState orbital ≠ 0 →
    ritzEnergy H (fermionSector m n) ≤ H.rayleighQuotient (slaterState orbital)

/-- A weighted sum of determinants built from particle-permutation equivariant
orbital matrices is a fermionic ansatz, as used by FermiNet. -/
def NeuralAntisymmetry {X : Type*} {n k : ℕ}
    (orb : Fin k → (Fin n → X) → Matrix (Fin n) (Fin n) ℂ) (w : Fin k → ℂ) : Prop :=
  (∀ a x (σ : Equiv.Perm (Fin n)), orb a (x ∘ σ) = (orb a x).submatrix σ id) →
    ∀ x (σ : Equiv.Perm (Fin n)), (∑ a, w a * (orb a (x ∘ σ)).det) =
      (Equiv.Perm.sign σ : ℂ) * ∑ a, w a * (orb a x).det

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
