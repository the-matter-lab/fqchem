module

public import FormalQChem.StatePrep.VariationalOptimization.DensityFunctionals.MolecularDFT.Theorems
public import Mathlib.MeasureTheory.Function.LocallyIntegrable

/-! # Nuclear Coulomb attraction on the molecular trial class -/

@[expose] public section

namespace FormalQChem.MolecularDFT

open MeasureTheory

/-- The three-dimensional point-charge Coulomb kernel is locally integrable,
including on sets containing the nucleus. -/
def CoulombLocallyIntegrable (center : Position) : Prop :=
  LocallyIntegrable (fun r : Position => (dist r center)⁻¹) volume

/-- All electron marginals of the smooth compactly supported molecular trial
states have finite nuclear-attraction integrals for finite collections of point nuclei. -/
def NuclearAttractionIntegrable (N K : ℕ) : Prop :=
  ∀ (Z : Fin K → ℝ) (R : Fin K → Position) (s : Trial N) (i : Fin N),
    Integrable (nuclearPotential Z R) (marginal s i)

/-- Molecular constrained search with the nuclear-attraction integrability
condition discharged throughout the trial class. -/
def CoulombConstrainedSearch (N K : ℕ) : Prop :=
  ∀ (Z : Fin K → ℝ) (R : Fin K → Position),
    electronicEnergy N (nuclearPotential Z R) =
      ⨅ ρ : Measure Position, levy N ρ + (((∫ r, nuclearPotential Z R r ∂ρ) : ℝ) : EReal)

end FormalQChem.MolecularDFT
