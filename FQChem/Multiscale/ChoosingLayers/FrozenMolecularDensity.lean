module

public import FQChem.Multiscale.ChoosingLayers.QuantumEnvironments
public import FQChem.StatePrep.VariationalOptimization.DensityFunctionals.CoulombIntegrability

@[expose] public section

namespace FQChem.Multiscale

open MolecularDFT MeasureTheory

/-- Restrict the three-dimensional Coulomb constrained search to densities of the
form a + b with frozen environment b. A split attaining the molecular infimum is
sufficient for exactness on the library's molecular trial class. -/
theorem frozenMolecularEnergy (N K : ℕ) (Z : Fin K → ℝ) (R : Fin K → Position)
    (active : Set (Measure Position)) (b : Measure Position) :
    let E := fun ρ : Measure Position => levy N ρ + ((∫ r, nuclearPotential Z R r ∂ρ : ℝ) : EReal)
    let molecular := electronicEnergy N (nuclearPotential Z R)
    let frozen := ⨅ a : active, E (a.val + b)
    molecular ≤ frozen ∧ (∀ a ∈ active, E (a + b) = molecular → frozen = molecular) := by
  intro E molecular frozen
  have energy : molecular = ⨅ ρ : (Set.univ : Set (Measure Position)), E ρ.val :=
    (coulombConstrainedSearch N K Z R).trans (Equiv.Set.univ _).iInf_comp.symm
  rw [energy]
  exact frozenSearch E Set.univ active b (fun _ _ => Set.mem_univ _)

end FQChem.Multiscale
