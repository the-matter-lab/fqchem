module

public import FQChem.Complexity.FixedBasisGeometry
public import FQChem.StatePrep.VariationalOptimization.DensityFunctionals.CoulombIntegrability
public import FQChem.Complexity.FixedBasisRadial
public import Mathlib.MeasureTheory.Group.Prod
public import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.Tactic

/-! # Direct Coulomb energies of compactly supported orbital components

The interaction between two unit-ball densities is bounded from below by the
inverse of their centers' distance plus two. Separated supports also yield
the inverse-distance upper bound. These are actual three-dimensional
two-electron integrals, including when both centers coincide.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SlaterEnergyCoulomb
open MeasureTheory Metric Set FixedBasisGaussians
open scoped ENNReal

/-- The explicit radial compact C² profile (1−r²)^(5/2) on the unit ball. -/
def bump := FixedBasisRadial.shape

private theorem bump_smooth : ContDiff ℝ 2 bump := FixedBasisRadial.smooth

private theorem bump_bounds (r : Space) : 0≤bump r ∧ bump r≤1 := FixedBasisRadial.bounds r

private theorem bump_zero {r : Space} (h : 1≤‖r‖) : bump r=0 := FixedBasisRadial.zero h

private theorem bump_compact : HasCompactSupport bump := by
  apply (isCompact_closedBall (0:Space) 1).of_isClosed_subset isClosed_closure
  apply closure_minimal _ isClosed_closedBall
  intro r hr
  by_contra h
  exact hr (bump_zero (by simpa [mem_closedBall] using (le_of_lt (lt_of_not_ge h) : (1:ℝ) ≤ dist r 0)))

def weight := ∫ r : Space, bump r ^ 2

theorem weight_pos : 0<weight := by
  have one : bump (0:Space) = 1 := by simp [bump,FixedBasisRadial.shape]
  exact integral_pos_of_integrable_nonneg_ne_zero (x:= (0:Space)) (bump_smooth.continuous.pow 2)
    ((bump_smooth.continuous.pow 2).integrable_of_hasCompactSupport (by
      simpa [sq] using bump_compact.mul_right (f':=bump)))
    (fun _ => sq_nonneg _) (by simp [one])

def wave (A r : Space) := bump (r-A)/Real.sqrt weight
def density (A r : Space) := wave A r ^ 2

private theorem density_value (A r : Space) : density A r = bump (r-A)^2 / weight := by
  rw [density,wave,div_pow,Real.sq_sqrt weight_pos.le]

theorem density_normalized (A : Space) : (∫ r, density A r)=1 := by
  simp_rw [density_value]
  rw [integral_div,integral_sub_right_eq_self (fun r : Space => bump r ^ 2)]
  exact div_self weight_pos.ne'

theorem wave_zero {A r : Space} (h : 1 ≤ dist r A) : wave A r = 0 := by
  have eq := bump_zero (r:=r-A) (by simpa [dist_eq_norm] using h)
  simp [wave,eq]

theorem wave_smooth (A : Space) : ContDiff ℝ 2 (wave A) := by
  unfold wave
  exact ((bump_smooth.comp (contDiff_id.sub contDiff_const)).div_const _)

private theorem density_le (A r : Space) : density A r ≤ weight⁻¹ := by
  rw [density_value, ← one_div]
  have h0 := (bump_bounds (r-A)).1
  have h1 : bump (r-A) ≤ 1 := (bump_bounds _).2
  exact div_le_div_of_nonneg_right (by nlinarith [mul_nonneg (sub_nonneg.mpr h1) (by linarith : 0≤1+bump (r-A))]) weight_pos.le

def interaction (A B : Space) := ∫ p : Space × Space,
  density A p.1 * density B p.2 / dist p.1 p.2 ∂volume.prod volume

theorem kernel_integrable (A B : Space) :
    Integrable (fun p : Space × Space => density A p.1 * density B p.2 / dist p.1 p.2)
      (volume.prod volume) := by
  classical
  let radius := ‖A‖+‖B‖+2
  let box := closedBall (0:Space) radius
  have comp : IsCompact box := isCompact_closedBall _ _
  let one := box.indicator (fun _ : Space => (1:ℝ))
  let radial := box.indicator (fun z : Space => (dist z 0)⁻¹)
  have i1 : Integrable one := (integrable_indicator_iff comp.measurableSet).mpr
    (integrableOn_const comp.measure_ne_top)
  have i2 : Integrable radial := (integrable_indicator_iff comp.measurableSet).mpr
    ((FQChem.MolecularDFT.coulombLocallyIntegrable 0).integrableOn_isCompact comp)
  have major := ((measurePreserving_prod_sub (volume : Measure Space) volume).integrable_comp_of_integrable
    (i1.mul_prod i2)).const_mul (weight⁻¹*weight⁻¹)
  have positive := weight_pos
  apply major.mono'
  · exact (((((wave_smooth A).continuous.comp continuous_fst).pow 2).measurable.mul
      ((((wave_smooth B).continuous.comp continuous_snd).pow 2).measurable)).div
      (continuous_fst.dist continuous_snd).measurable).aestronglyMeasurable
  · filter_upwards with p
    change ‖density A p.1 * density B p.2 / dist p.1 p.2‖ ≤
      weight⁻¹*weight⁻¹*(one p.1 * radial (p.2-p.1))
    have hada : 0≤density A p.1 := sq_nonneg _
    have hbda : 0≤density B p.2 := sq_nonneg _
    rw [Real.norm_eq_abs,abs_of_nonneg (by positivity)]
    by_cases ar : dist p.1 A < 1 <;> by_cases bs : dist p.2 B < 1
    · have first : p.1 ∈ box := by
        rw [mem_closedBall,dist_zero_right]; dsimp [radius]
        linarith [show ‖p.1‖ ≤ dist p.1 A + ‖A‖ by simpa only [dist_zero_right] using dist_triangle p.1 A 0,norm_nonneg B]
      have diff : p.2-p.1 ∈ box := by
        rw [mem_closedBall,dist_zero_right]; dsimp [radius]
        linarith [norm_sub_le p.2 p.1,show ‖p.1‖ ≤ dist p.1 A + ‖A‖ by simpa only [dist_zero_right] using dist_triangle p.1 A 0,show ‖p.2‖ ≤ dist p.2 B + ‖B‖ by simpa only [dist_zero_right] using dist_triangle p.2 B 0]
      simp only [one,radial,indicator_of_mem first,indicator_of_mem diff,one_mul,dist_zero_right]
      rw [div_eq_mul_inv,← dist_eq_norm,dist_comm p.2 p.1]
      exact mul_le_mul_of_nonneg_right (mul_le_mul (density_le A _) (density_le B _) hbda (inv_nonneg.mpr weight_pos.le)) (by positivity)
    all_goals
      have pos : 0 ≤ weight⁻¹*weight⁻¹*(one p.1 * radial (p.2-p.1)) := by
        dsimp only [one,radial]; simp only [Set.indicator_apply]; split_ifs <;> positivity
      first | simpa [density,wave_zero (le_of_not_gt bs)] using pos
            | simpa [density,wave_zero (le_of_not_gt ar)] using pos

private theorem joint_normalized (A B : Space) :
    (∫ p : Space×Space, density A p.1 * density B p.2 ∂volume.prod volume)=1 := by
  rw [integral_prod_mul,density_normalized,density_normalized,one_mul]

private theorem joint_integrable (A B : Space) :
    Integrable (fun p : Space×Space => density A p.1 * density B p.2) (volume.prod volume) :=
  Integrable.of_integral_ne_zero ((joint_normalized A B) ▸ one_ne_zero)

/-- Coincident centers are included. The Coulomb diagonal r=s has zero
six-dimensional volume, so the onsite integral retains the lower bound. -/
theorem lower (A B : Space) : 1/(dist A B+2) ≤ interaction A B := by
  have off : ∀ᵐ p : Space × Space ∂volume.prod volume, p.1 ≠ p.2 := by
    apply (Measure.ae_prod_iff_ae_ae (measurableSet_eq_fun measurable_fst measurable_snd).compl).mpr
    filter_upwards with r
    exact (volume.ae_ne r).mono fun s h => h.symm
  let v := 1/(dist A B+2)
  have h := integral_mono_ae ((joint_integrable A B).mul_const v) (kernel_integrable A B)
    (by
      filter_upwards [off] with p hp
      by_cases ar : dist p.1 A < 1 <;> by_cases bs : dist p.2 B < 1
      · have bound : dist p.1 p.2 ≤ dist A B+2 := by
          linarith [dist_triangle p.1 A p.2,dist_triangle A B p.2,dist_comm B p.2]
        rw [div_eq_mul_inv]
        exact mul_le_mul_of_nonneg_left ((one_div_le_one_div_of_le (dist_pos.mpr hp) bound).trans_eq (one_div _)) (by dsimp [density]; positivity)
      all_goals first | simp [density,wave_zero (le_of_not_gt bs)] | simp [density,wave_zero (le_of_not_gt ar)])
  simpa [interaction,integral_mul_const,joint_normalized,v] using h

theorem upper {D : ℝ} (A B : Space) (hD : 2<D) (hd : D ≤ dist A B) :
    interaction A B ≤ 1/(D-2) := by
  let v := 1/(D-2)
  have h := integral_mono_ae (kernel_integrable A B) ((joint_integrable A B).mul_const v)
    (by
      filter_upwards with p
      by_cases ar : dist p.1 A < 1 <;> by_cases bs : dist p.2 B < 1
      · have bound : D-2 ≤ dist p.1 p.2 := by
          linarith [dist_triangle A p.1 B,dist_triangle p.1 p.2 B,dist_comm A p.1]
        rw [div_eq_mul_inv]
        have h_inv : (dist p.1 p.2)⁻¹ ≤ v := by
          simpa only [v,one_div] using one_div_le_one_div_of_le (by linarith : 0<D-2) bound
        exact mul_le_mul_of_nonneg_left h_inv (by dsimp [density]; positivity)
      all_goals first | simp [density,wave_zero (le_of_not_gt bs)] | simp [density,wave_zero (le_of_not_gt ar)])
  simpa [interaction,integral_mul_const,joint_normalized,v] using h

theorem nonnegative (A B : Space) : 0 ≤ interaction A B := (by positivity : 0 ≤ 1/(dist A B+2)).trans (lower A B)

end FQChem.Complexity.SlaterEnergyCoulomb
