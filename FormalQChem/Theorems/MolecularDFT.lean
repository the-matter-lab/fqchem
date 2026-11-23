module

public import Mathlib.MeasureTheory.Measure.Haar.InnerProductSpace
public import Mathlib.MeasureTheory.Constructions.Pi
public import Mathlib.MeasureTheory.Integral.Bochner.Basic
public import Mathlib.MeasureTheory.Measure.WithDensity
public import Mathlib.Analysis.Calculus.ContDiff.Defs
public import Mathlib.Data.EReal.Operations

/-! # A molecular constrained search in three dimensions
Atomic units, fixed point nuclei, and real spin-polarized wavefunctions. The search
is over normalized smooth compactly supported antisymmetric trial states of finite
internal energy. All energies below are electronic. The electron density is a measure
on physical space, obtained by summing the one-electron marginals of the Born measure. -/

@[expose] public section

namespace FormalQChem.MolecularDFT

open MeasureTheory
open scoped BigOperators ContDiff

abbrev Position := EuclideanSpace ℝ (Fin 3)
abbrev Configuration (N : ℕ) := Fin N → Position

noncomputable def kineticDensity {N : ℕ} (ψ : Configuration N → ℝ) (q : Configuration N) : ℝ :=
  (∑ i : Fin N, ∑ a : Fin 3, ((fderiv ℝ ψ q) (Pi.single i (EuclideanSpace.single a 1))) ^ 2) / 2

noncomputable def repulsion {N : ℕ} (q : Configuration N) : ℝ :=
  ∑ i, ∑ j ∈ Finset.univ.filter (i < ·), (dist (q i) (q j))⁻¹

/-- The convention for reciprocals at collisions only affects a set of volume zero. -/
noncomputable def nuclearPotential {K : ℕ} (Z : Fin K → ℝ) (R : Fin K → Position) (r : Position) :=
  -(∑ k, Z k / dist r (R k))

structure Trial (N : ℕ) where
  wave : Configuration N → ℝ
  smooth : ContDiff ℝ ∞ wave
  compact_support : HasCompactSupport wave
  antisymmetric : ∀ (i j : Fin N), i ≠ j → ∀ q, wave (q ∘ Equiv.swap i j) = -wave q
  normalized : (∫ q, (wave q) ^ 2) = 1
  finiteKinetic : Integrable (kineticDensity wave)
  finiteRepulsion : Integrable (fun q => repulsion q * (wave q) ^ 2)

variable {N : ℕ}

noncomputable def born (s : Trial N) : Measure (Configuration N) :=
  volume.withDensity (fun q => ENNReal.ofReal ((s.wave q) ^ 2))

noncomputable def marginal (s : Trial N) (i : Fin N) : Measure Position :=
  (born s).map (fun q => q i)

noncomputable def density (s : Trial N) : Measure Position := ∑ i, marginal s i

noncomputable def internalEnergy (s : Trial N) :=
  (∫ q, kineticDensity s.wave q) + ∫ q, repulsion q * (s.wave q) ^ 2

/-- The constrained search over a density fiber. An empty fiber has value +∞. -/
noncomputable def levy (N : ℕ) (ρ : Measure Position) : EReal :=
  ⨅ s : {s : Trial N // density s = ρ}, (internalEnergy s.val : EReal)

noncomputable def electronicEnergy (N : ℕ) (v : Position → ℝ) : EReal :=
  ⨅ s : Trial N, ((internalEnergy s + ∑ i, ∫ q, v (q i) ∂born s : ℝ) : EReal)

/-- Nuclear attraction is a one-body operator. The integrability condition precisely
identifies when its expectations are defined for all trial states. -/
def MolecularConstrainedSearch (N K : ℕ) : Prop :=
  ∀ (Z : Fin K → ℝ) (R : Fin K → Position),
    (∀ (s : Trial N) i, Integrable (nuclearPotential Z R) (marginal s i)) →
    electronicEnergy N (nuclearPotential Z R) =
      ⨅ ρ : Measure Position, levy N ρ + (((∫ r, nuclearPotential Z R r ∂ρ) : ℝ) : EReal)

end FormalQChem.MolecularDFT
