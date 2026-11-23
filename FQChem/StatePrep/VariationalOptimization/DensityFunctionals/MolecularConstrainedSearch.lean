module

public import Mathlib.MeasureTheory.Measure.Haar.InnerProductSpace
public import Mathlib.MeasureTheory.Constructions.Pi
public import Mathlib.MeasureTheory.Integral.Bochner.Basic
public import Mathlib.MeasureTheory.Measure.WithDensity
public import Mathlib.Analysis.Calculus.ContDiff.Defs
public import Mathlib.Data.EReal.Operations

/-!
# A molecular constrained search in three dimensions
Atomic units, fixed point nuclei, and real spin-polarized wavefunctions. The search
is over normalized smooth compactly supported antisymmetric trial states of finite
internal energy. All energies below are electronic. The electron density is a measure
on physical space, obtained by summing the one-electron marginals of the Born measure.
-/

@[expose] public section

namespace FQChem.MolecularDFT

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

end FQChem.MolecularDFT

namespace FQChem.MolecularDFT

open MeasureTheory

theorem born_mass {N : ℕ} (s : Trial N) : born s Set.univ = 1 := by
  have finite : Integrable (fun q => s.wave q ^ 2) :=
    Integrable.of_integral_ne_zero (s.normalized.trans_ne one_ne_zero)
  rw [born, withDensity_apply _ MeasurableSet.univ, Measure.restrict_univ,
    ← ofReal_integral_eq_lintegral_ofReal finite (Filter.Eventually.of_forall (fun q => sq_nonneg _)),
    s.normalized, ENNReal.ofReal_one]

/-- Summing the single-electron marginals gives total electron number. -/
theorem density_mass {N : ℕ} (s : Trial N) : density s Set.univ = N := by
  unfold density
  rw [Measure.finsetSum_apply]
  simp [marginal, Measure.map_apply (measurable_pi_apply _), born_mass]

theorem density_pairing {N : ℕ} (s : Trial N) {v : Position → ℝ}
    (hv : ∀ i, Integrable v (marginal s i)) :
    (∫ r, v r ∂density s) = ∑ i, ∫ q, v (q i) ∂born s := by
  unfold density
  rw [integral_finsetSum_measure (fun i _ => hv i)]
  apply Finset.sum_congr rfl
  intro i _
  exact integral_map (measurable_pi_apply i).aemeasurable (hv i).aestronglyMeasurable

/-- The same internal functional works for every admissible one-body potential. -/
theorem constrainedSearch {N : ℕ} {v : Position → ℝ}
    (hv : ∀ (s : Trial N) i, Integrable v (marginal s i)) :
    electronicEnergy N v = ⨅ ρ : Measure Position, levy N ρ + (((∫ r, v r ∂ρ) : ℝ) : EReal) := by
  let pair (ρ : Measure Position) : ℝ := ∫ r, v r ∂ρ
  have stateEnergy (s : Trial N) : ((internalEnergy s + ∑ i, ∫ q, v (q i) ∂born s : ℝ) : EReal) =
      (internalEnergy s : EReal) + (pair (density s) : EReal) := by
    rw [← density_pairing s (hv s), EReal.coe_add]
  apply le_antisymm
  · refine le_iInf fun ρ => ?_
    have shift (x y : EReal) : x - (pair ρ : EReal) ≤ y ↔ x ≤ y + (pair ρ : EReal) :=
      EReal.sub_le_iff_le_add (.inl (EReal.coe_ne_bot _)) (.inl (EReal.coe_ne_top _))
    apply (shift _ _).mp
    apply le_iInf
    rintro ⟨s, rfl⟩
    apply (shift _ _).mpr
    rw [← stateEnergy]
    exact iInf_le _ s
  · refine le_iInf fun s => ?_
    rw [stateEnergy]
    have h : levy N (density s) ≤ (internalEnergy s : EReal) :=
      iInf_le (fun t : {t : Trial N // density t = density s} => (internalEnergy t.val : EReal)) ⟨s, rfl⟩
    exact (iInf_le _ (density s)).trans (add_le_add h le_rfl)

theorem molecularConstrainedSearch (N K : ℕ) : MolecularConstrainedSearch N K :=
  fun _ _ hv => constrainedSearch hv

end FQChem.MolecularDFT
