module

public import Mathlib.Analysis.Complex.Basic

/-! # Feshbach elimination of the environment block
The full Hamiltonian has diagonal blocks A and D and coupling blocks B and C. At an
energy z outside the environment spectrum, eliminating its amplitudes yields an
energy-dependent Hamiltonian on the active space. -/

@[expose] public section
namespace FormalQChem.Multiscale.Embedding

variable {X Y : Type*} [AddCommGroup X] [Module ℂ X] [AddCommGroup Y] [Module ℂ Y]

/-- R represents zI − D as an invertible linear map. Its inverse is the environment
resolvent at z. The active solution reconstructs the complete nonzero eigenvector. -/
def FeshbachReduction (A : X →ₗ[ℂ] X) (B : Y →ₗ[ℂ] X) (C : X →ₗ[ℂ] Y)
    (D : Y →ₗ[ℂ] Y) (z : ℂ) (R : Y ≃ₗ[ℂ] Y) : Prop :=
  (∀ y, R y = z • y - D y) → ∀ x y,
    ((x ≠ 0 ∨ y ≠ 0) ∧ A x + B y = z • x ∧ C x + D y = z • y) ↔
      (x ≠ 0 ∧ A x + B (R.symm (C x)) = z • x ∧ y = R.symm (C x))

end FormalQChem.Multiscale.Embedding
