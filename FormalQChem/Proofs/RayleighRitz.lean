module

public import FormalQChem.Theorems.RayleighRitz

/-!
The spectral attainment step reuses mathlib's
`LinearMap.IsSymmetric.hasEigenvalue_iInf_of_finiteDimensional`.
The comparison with trial spaces only uses boundedness of the Rayleigh quotient.
-/

@[expose] public section

namespace FormalQChem.RayleighRitz

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

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
