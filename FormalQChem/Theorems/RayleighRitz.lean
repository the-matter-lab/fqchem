module

public import Mathlib.Analysis.InnerProductSpace.Rayleigh

/-!
# Rayleigh–Ritz variational principle

A finite electronic basis gives a complex inner-product space and a Hermitian Hamiltonian.
The Rayleigh quotient is the expectation value divided by the squared norm, so trial
vectors need not be normalized. The statements below require nonzero trial vectors.
-/

@[expose] public section

namespace FormalQChem.RayleighRitz

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- Infimum of the energy over all nonzero states. -/
noncomputable def groundEnergy (H : E →L[ℂ] E) : ℝ :=
  ⨅ ψ : {x : E // x ≠ 0}, H.rayleighQuotient ψ.val

/-- Ritz energy in a trial subspace. Used only for subspaces containing a nonzero state. -/
noncomputable def ritzEnergy (H : E →L[ℂ] E) (V : Submodule ℂ E) : ℝ :=
  ⨅ ψ : {x : E // x ∈ V ∧ x ≠ 0}, H.rayleighQuotient ψ.val

/-- The minimum energy is an eigenvalue and bounds the energy of every nonzero trial state. -/
def GroundEnergyPrinciple (H : E →L[ℂ] E) : Prop :=
  Module.End.HasEigenvalue H.toLinearMap (groundEnergy H : ℂ) ∧
    ∀ ψ : E, ψ ≠ 0 → groundEnergy H ≤ H.rayleighQuotient ψ

/-- Enlarging a trial subspace can only lower the Ritz energy. Both estimates bound the
ground energy from above. -/
def BasisEnlargement (H : E →L[ℂ] E) : Prop :=
  ∀ (V W : Submodule ℂ E), V ≤ W → (∃ ψ ∈ V, ψ ≠ (0 : E)) →
    groundEnergy H ≤ ritzEnergy H W ∧ ritzEnergy H W ≤ ritzEnergy H V

end FormalQChem.RayleighRitz
