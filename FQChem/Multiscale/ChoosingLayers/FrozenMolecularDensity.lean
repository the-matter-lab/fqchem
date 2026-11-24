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
  let E := fun ρ : Measure Position => levy N ρ + ((∫ r, nuclearPotential Z R r ∂ρ : ℝ) : EReal)
  have bound := frozenSearch E Set.univ active b (by simp)
  dsimp only
  rw [coulombConstrainedSearch N K Z R]
  simpa [E, iInf_subtype] using bound

end FQChem.Multiscale
