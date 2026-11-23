module

public import FQChem.StatePrep.VariationalOptimization.DensityFunctionals.MolecularConstrainedSearch
public import Mathlib.MeasureTheory.Function.LocallyIntegrable
import Mathlib.Analysis.SpecialFunctions.Pow.Integral
import Mathlib.MeasureTheory.Integral.Pi

/-!
# Nuclear Coulomb attraction on the molecular trial class
-/

@[expose] public section

namespace FQChem.MolecularDFT

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

open Set

theorem coulombLocallyIntegrable (center : Position) : CoulombLocallyIntegrable center := by
  have origin : LocallyIntegrable (fun r : Position => ‖r‖⁻¹) volume := by
    apply locallyIntegrable_of_norm_le_rpow (C := 1) (α := 1)
      (by norm_num [Position, finrank_euclideanSpace_fin])
      (by norm_num [Position, finrank_euclideanSpace_fin])
    · filter_upwards with r
      simp [Real.rpow_neg_one]
    · fun_prop
  apply locallyIntegrable_iff.mpr
  intro K hK
  have translated := origin.integrableOn_isCompact
    (hK.image (show Continuous (fun x : Position => x - center) by fun_prop))
  have shifted := (measurePreserving_sub_right volume center).integrableOn_image
    (measurableEmbedding_subRight center) |>.mp translated
  simpa only [dist_eq_norm, Function.comp_def] using shifted

private theorem locallyIntegrable_coordinate {N : ℕ} {f : Position → ℝ}
    (hf : LocallyIntegrable f volume) (i : Fin N) :
    LocallyIntegrable (fun q : Configuration N => f (q i)) volume := by
  rw [locallyIntegrable_iff]
  intro K hK
  let side (j : Fin N) := (fun q : Configuration N => q j) '' K
  have compactSide (j : Fin N) : IsCompact (side j) := hK.image (continuous_apply j)
  let μ (j : Fin N) := (volume : Measure Position).restrict (side j)
  have (j : Fin N) : IsFiniteMeasure (μ j) :=
    isFiniteMeasure_restrict.mpr (compactSide j).measure_ne_top
  have hi : Integrable f (μ i) := hf.integrableOn_isCompact (compactSide i)
  have hbox : IntegrableOn (fun q : Configuration N => f (q i)) (univ.pi side) := by
    rw [IntegrableOn, volume_pi, Measure.restrict_pi_pi]
    exact integrable_comp_eval hi
  exact hbox.mono_set (fun q hq j _ => ⟨q, hq, rfl⟩)

theorem nuclearAttractionIntegrable (N K : ℕ) : NuclearAttractionIntegrable N K := by
  intro Z R s i
  have hattract : LocallyIntegrable (nuclearPotential Z R) volume := by
    have hi (k : Fin K) : LocallyIntegrable (fun r => Z k / dist r (R k)) volume := by
      simpa only [div_eq_mul_inv, Pi.smul_def, smul_eq_mul] using (coulombLocallyIntegrable (R k)).smul (Z k)
    exact (locallyIntegrable_finsetSum Finset.univ (fun k _ => hi k)).neg
  have h := locallyIntegrable_coordinate hattract i
  have hcompact : HasCompactSupport (fun q => s.wave q ^ 2) := by
    simpa only [pow_two, Pi.mul_def] using (s.compact_support.mul_right (f' := s.wave))
  have weighted := h.integrable_smul_left_of_hasCompactSupport
    (s.smooth.continuous.pow 2) hcompact
  have hm : Measurable (nuclearPotential Z R) := by unfold nuclearPotential; fun_prop
  apply (integrable_map_measure hm.aestronglyMeasurable (measurable_pi_apply i).aemeasurable).mpr
  have hmeas : Measurable s.wave := s.smooth.continuous.measurable
  unfold born
  rw [integrable_withDensity_iff_integrable_smul' (by fun_prop) (by simp)]
  simpa [Function.comp_def, ENNReal.toReal_ofReal (sq_nonneg _)] using weighted

theorem coulombConstrainedSearch (N K : ℕ) : CoulombConstrainedSearch N K :=
  fun Z R => constrainedSearch (nuclearAttractionIntegrable N K Z R)

end FQChem.MolecularDFT
