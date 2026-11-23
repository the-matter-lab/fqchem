module

public import Mathlib.Analysis.InnerProductSpace.Rayleigh

/-!
# Rayleigh–Ritz variational principle

A finite electronic basis gives a complex inner-product space and a Hermitian Hamiltonian.
The Rayleigh quotient is the expectation value divided by the squared norm, so trial
vectors need not be normalized. The statements below require nonzero trial vectors.

The spectral attainment step reuses mathlib's
`LinearMap.IsSymmetric.hasEigenvalue_iInf_of_finiteDimensional`.
The comparison with trial spaces only uses boundedness of the Rayleigh quotient.
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

private theorem rayleigh_bddBelow (H : E →L[ℂ] E) {ι : Type*} (state : ι → E) :
    BddBelow (Set.range fun i ↦ H.rayleighQuotient (state i)) := by
  refine ⟨-‖H‖, ?_⟩
  rintro _ ⟨i, rfl⟩
  exact (abs_le.mp (H.rayleighQuotient_le_norm (state i))).1

/-- Every trial energy bounds the ground energy from above. -/
theorem groundEnergy_le (H : E →L[ℂ] E) {ψ : E} (hψ : ψ ≠ 0) :
    groundEnergy H ≤ H.rayleighQuotient ψ :=
  ciInf_le (rayleigh_bddBelow H Subtype.val) ⟨ψ, hψ⟩

/-- Every nonzero state in a trial subspace bounds its Ritz energy. -/
theorem ritzEnergy_le (H : E →L[ℂ] E) {V : Submodule ℂ E} {ψ : E} (hV : ψ ∈ V) (hψ : ψ ≠ 0) :
    ritzEnergy H V ≤ H.rayleighQuotient ψ :=
  ciInf_le (rayleigh_bddBelow H Subtype.val) ⟨ψ, hV, hψ⟩

/-- Rayleigh–Ritz for a Hermitian Hamiltonian represented in a finite basis. -/
theorem groundEnergyPrinciple [FiniteDimensional ℂ E] [Nontrivial E]
    (H : E →L[ℂ] E) (hH : H.toLinearMap.IsSymmetric) : GroundEnergyPrinciple H :=
  ⟨hH.hasEigenvalue_iInf_of_finiteDimensional, fun _ hψ ↦ groundEnergy_le H hψ⟩

/-- Variational upper bounds improve monotonically over nested trial spaces.
This comparison also holds for bounded operators on infinite-dimensional spaces. -/
theorem basisEnlargement (H : E →L[ℂ] E) : BasisEnlargement H := by
  intro V W hVW hV
  obtain ⟨ψ, hψV, hψ0⟩ := hV
  have : Nonempty {x : E // x ∈ V ∧ x ≠ 0} := ⟨⟨ψ, hψV, hψ0⟩⟩
  have : Nonempty {x : E // x ∈ W ∧ x ≠ 0} := ⟨⟨ψ, hVW hψV, hψ0⟩⟩
  constructor
  · apply le_ciInf
    intro x
    exact groundEnergy_le H x.property.2
  · apply le_ciInf
    intro x
    exact ciInf_le (rayleigh_bddBelow H Subtype.val) ⟨x.val, hVW x.property.1, x.property.2⟩

end FormalQChem.RayleighRitz
