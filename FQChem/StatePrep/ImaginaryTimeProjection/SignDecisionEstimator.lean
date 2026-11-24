module

public import FQChem.StatePrep.ImaginaryTimeProjection.SpinGlassDecision
public import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.Tactic

/-! # From a signed thermal-energy oracle to a bounded-error spin-glass decision

[Troyer and Wiese, Eq. (9) and note 9](https://doi.org/10.1103/PhysRevLett.94.170201).
Only one call to the thermal estimate is required. Its relative RMS error need
only be inverse linear in the spin count. The reduction does not evaluate the
partition function or search for the ground configuration.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
open MeasureTheory
variable {n : ℕ}

theorem thermalBound (g : Glass n) (β : ℝ) : |g.quantumThermal β| ≤ g.bonds.card := by
  rw [thermal_identity, Glass.classicalThermal]
  let w := fun s => Real.exp (-β * g.energy s)
  let m : ℝ := g.bonds.card
  have z : 0 < ∑ x, w x := Finset.sum_pos (fun s _ => Real.exp_pos _) Finset.univ_nonempty
  rw [abs_div, abs_of_pos z, div_le_iff₀ z]
  refine (Finset.abs_sum_le_sum_abs _ _).trans ?_
  change (∑ s, |(g.energy s : ℝ) * w s|) ≤ m * ∑ s, w s
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro s _
  rw [abs_mul, abs_of_pos (Real.exp_pos _)]
  exact mul_le_mul_of_nonneg_right (by dsimp [m]; exact_mod_cast energy_bound g s) (Real.exp_pos _).le

/-- One inverse-linear relative RMS target decides the threshold with failure probability
at most 1/4. This is the bounded-error reduction in note 9, over an arbitrary probability
space. The requested inverse temperature and reciprocal accuracy are both linear in n. -/
theorem statisticalDecision {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (g : Glass n) (hn : 0<n) (hedges : g.bonds.card ≤ 3*n) (t : ℤ) (estimate : Ω → ℝ)
    (integrable : Integrable (fun x => (estimate x - g.quantumThermal (13*n))^2) μ)
    (rms : (∫ x, (estimate x - g.quantumThermal (13*n))^2 ∂μ) ≤
      (|g.quantumThermal (13*n)| / (24*n))^2) :
    μ.real {x | ¬ ((estimate x < (t:ℝ)+3/4) ↔ feasible g t)} ≤ 1/4 := by
  let e := g.quantumThermal (13*n)
  obtain ⟨yes,no⟩ := thermalSeparation g hn hedges (13*n) (polynomialTemperature n hn) t
  have inc : {x | ¬ ((estimate x < (t:ℝ)+3/4) ↔ feasible g t)} ⊆
      {x | 1/16 ≤ (estimate x-e)^2} := by
    intro x hx
    change ¬ ((estimate x < (t:ℝ)+3/4) ↔ feasible g t) at hx
    change 1/16 ≤ (estimate x-e)^2
    by_cases h : feasible g t
    · have hh : (t:ℝ)+3/4 ≤ estimate x := le_of_not_gt (fun q => hx ⟨fun _ => h, fun _ => q⟩)
      have hy : e < t+1/2 := yes h
      nlinarith [sq_nonneg (estimate x-e-1/4)]
    · have hh : estimate x < (t:ℝ)+3/4 := by by_contra hn'; exact hx ⟨fun q => (hn' q).elim, fun q => (h q).elim⟩
      have hy : (t:ℝ)+1 ≤ e := no h
      nlinarith [sq_nonneg (e-estimate x-1/4)]
  have markov := mul_meas_ge_le_integral_of_nonneg
    (Filter.Eventually.of_forall fun x => sq_nonneg (estimate x-e)) integrable (1/16)
  have nr : (0:ℝ)<n := by exact_mod_cast hn
  have cap : |e|/(24*n) ≤ 1/8 := by
    apply (div_le_iff₀ (by positivity)).mpr
    have he : |e| ≤ 3*n := (thermalBound g _).trans (by exact_mod_cast hedges)
    linarith
  have hs := pow_le_pow_left₀ (by positivity : 0 ≤ |e|/(24*n)) cap 2
  exact (measureReal_mono inc).trans (by change _ ≤ (|e|/(24*n))^2 at rms; linarith)

end FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
