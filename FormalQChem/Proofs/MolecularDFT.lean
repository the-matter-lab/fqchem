module

public import FormalQChem.Theorems.MolecularDFT

@[expose] public section

namespace FormalQChem.MolecularDFT

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

end FormalQChem.MolecularDFT
