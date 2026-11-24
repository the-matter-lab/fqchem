module

public import FQChem.Complexity.SlaterEnergyCoulomb
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.MeasureTheory.Measure.Lebesgue.VolumeOfBalls
import Mathlib.Tactic

/-! # Newton's spherical-shell integral in three dimensions

In cylindrical coordinates about the line joining two centers, the squared
radius has constant transverse area density. Slicing at this radius leaves
a height integral with an elementary square-root antiderivative.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.FixedBasisShell
open MeasureTheory Real Set FixedBasisGaussians
open scoped ENNReal Interval

/-- Angular integral of the Coulomb kernel for a spherical shell of radius
`r` about a point at radial distance `d>r`, in the height coordinate `z`. -/
theorem shellHeight {d r : ℝ} (hr : 0≤r) (hd : r<d) :
    (∫ z in -r..r, 1/sqrt (r^2+d^2-2*d*z)) = 2*r/d := by
  have dpos : 0<d := lt_of_le_of_lt hr hd
  let f := fun z : ℝ => -(sqrt (r^2+d^2-2*d*z))/d
  have der (z : ℝ) (hz : z ∈ uIcc (-r) r) : HasDerivAt f (1/sqrt (r^2+d^2-2*d*z)) z := by
    rw [uIcc_of_le (by linarith)] at hz
    have pos : 0<r^2+d^2-2*d*z := by
      nlinarith [sq_pos_of_pos (sub_pos.mpr hd),mul_nonneg dpos.le (sub_nonneg.mpr hz.2)]
    have h := (((hasDerivAt_const z (r^2+d^2)).sub ((hasDerivAt_id z).const_mul (2*d))).sqrt (ne_of_gt pos)).neg.div_const d
    change HasDerivAt f (-((0 - 2*d*1)/(2*sqrt (r^2+d^2-2*d*z)))/d) z at h
    convert h using 1
    field_simp [dpos.ne', (sqrt_pos.mpr pos).ne']
    ring
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt der (by
    apply ContinuousOn.intervalIntegrable
    apply ContinuousOn.div continuousOn_const
    · fun_prop
    · intro z hz
      rw [uIcc_of_le (by linarith)] at hz
      apply ne_of_gt
      apply sqrt_pos.mpr
      nlinarith [sq_pos_of_pos (sub_pos.mpr hd),mul_nonneg dpos.le (sub_nonneg.mpr hz.2)])]
  dsimp [f]
  rw [show r^2+d^2-2*d*r=(d-r)^2 by ring,show r^2+d^2-2*d*(-r)=(d+r)^2 by ring,
      sqrt_sq (by linarith), sqrt_sq (by linarith)]
  ring

abbrev Plane := EuclideanSpace ℝ (Fin 2)

/-- Transverse squared radius carries planar Lebesgue measure to π times
Lebesgue measure on the positive half-line. -/
theorem transverseArea :
    Measure.map (fun y : Plane => ‖y‖^2) volume =
      ENNReal.ofReal π • (volume.restrict (Ioi (0:ℝ))) := by
  let μ := Measure.map (fun y : Plane => ‖y‖^2) volume
  let ν := ENNReal.ofReal π • (volume.restrict (Ioi (0:ℝ)))
  have disk (t : ℝ) : μ (Iic t) = ENNReal.ofReal t * ENNReal.ofReal π := by
    rw [show μ (Iic t) = volume ((fun y : Plane => ‖y‖^2) ⁻¹' Iic t) from
      Measure.map_apply (by fun_prop) measurableSet_Iic]
    by_cases ht : 0≤t
    · have h : (fun y : Plane => ‖y‖^2) ⁻¹' Iic t = Metric.closedBall 0 (sqrt t) := by
        ext y
        simp [Metric.mem_closedBall, Real.le_sqrt (norm_nonneg y) ht]
      rw [h,EuclideanSpace.volume_closedBall_fin_two,←ENNReal.ofReal_pow (sqrt_nonneg _) _,sq_sqrt ht]
    · have h : (fun y : Plane => ‖y‖^2) ⁻¹' Iic t = ∅ := by
        ext y; simpa using (not_le_of_gt (lt_of_lt_of_le (lt_of_not_ge ht) (sq_nonneg ‖y‖)))
      simp [h,ENNReal.ofReal_eq_zero.mpr (le_of_not_ge ht)]
  have cdf (t : ℝ) : ν (Iic t) = μ (Iic t) := by
    rw [disk,show ν (Iic t) = ENNReal.ofReal π * volume (Iic t ∩ Ioi 0) by
      simp [ν,Measure.restrict_apply measurableSet_Iic] ]
    rw [inter_comm, Ioi_inter_Iic, Real.volume_Ioc,sub_zero,mul_comm]
  change μ = ν
  symm
  apply Measure.ext_of_Ioc'
  · intro a b _
    exact ne_top_of_le_ne_top (by rw [cdf,disk]; finiteness) (measure_mono Ioc_subset_Iic_self)
  · intro a b hab
    rw [show Ioc a b = Iic b \ Iic a by ext z; simp [and_comm] ]
    rw [measure_sdiff (Iic_subset_Iic.mpr hab.le) measurableSet_Iic.nullMeasurableSet,
      measure_sdiff (Iic_subset_Iic.mpr hab.le) measurableSet_Iic.nullMeasurableSet,
      cdf,cdf] <;> first | (rw [cdf,disk]; finiteness) | (rw [disk]; finiteness)

/-- At fixed height `z`, the squared distance to the origin runs over
`(z²,∞)` with constant transverse area density π. -/
private theorem sliceArea (z : ℝ) :
    Measure.map (fun y : Plane => ‖y‖^2+z^2) volume =
      ENNReal.ofReal π • volume.restrict (Ioi (z^2)) := by
  let addz := fun t : ℝ => t+z^2
  have ha : Measurable addz := by dsimp [addz]; fun_prop
  rw [show (fun y : Plane => ‖y‖^2+z^2) = addz ∘ (fun y => ‖y‖^2) by rfl,
    ← Measure.map_map ha (by fun_prop),transverseArea,Measure.map_smul _ ha.aemeasurable]
  congr 1
  have pre : addz ⁻¹' Ioi (z^2) = Ioi 0 := by ext t; simp [addz]
  rw [←pre, ←Measure.restrict_map ha measurableSet_Ioi]
  rw [(measurePreserving_add_right volume (z^2)).map_eq]

/-- Split off the coordinate on the line of centers. -/
private def split : Space ≃ᵐ ℝ × Plane :=
  (MeasurableEquiv.toLp 2 (Fin 3 → ℝ)).symm |>.trans
    ((MeasurableEquiv.piFinSuccAbove (fun _ : Fin 3 => ℝ) 0).trans
      ((MeasurableEquiv.refl ℝ).prodCongr (MeasurableEquiv.toLp 2 (Fin 2 → ℝ))))

private theorem split_volume : MeasurePreserving split := by
  exact (PiLp.volume_preserving_ofLp _).trans <|
    (volume_preserving_piFinSuccAbove (fun _ : Fin 3 => ℝ) 0).trans <|
    (MeasurePreserving.id (μ:=volume)).prod (PiLp.volume_preserving_toLp _)

private theorem split_sq (x : Space) : ‖x‖^2 = ‖(split x).2‖^2 + (split x).1^2 := by
  simp [EuclideanSpace.real_norm_sq_eq,Fin.sum_univ_succ,split,MeasurableEquiv.piFinSuccAbove,
    MeasurableEquiv.prodCongr,Fin.tail]
  ring

/-- Lebesgue volume in terms of squared radius and axial height. The Jacobian
in these two coordinates is the constant π. -/
theorem radialHeight (F : ℝ × ℝ → ℝ≥0∞) (hF : Measurable F) :
    (∫⁻ x : Space, F (‖x‖^2, x 0)) =
      ENNReal.ofReal π * ∫⁻ t : ℝ, ∫⁻ z in Ioo (-sqrt t) (sqrt t), F (t,z) := by
  let H (p : ℝ × Plane) := F (‖p.2‖^2+p.1^2,p.1)
  have hH : Measurable H := hF.comp (by fun_prop)
  let A (p : ℝ × ℝ) := if p.1^2<p.2 then F (p.2,p.1) else 0
  have hA : Measurable A := by
    exact (hF.comp (measurable_snd.prodMk measurable_fst)).ite
      (measurableSet_lt (measurable_fst.pow_const 2) measurable_snd) measurable_const
  calc
    _ = ∫⁻ p : ℝ × Plane, H p := by
      rw [← split_volume.lintegral_comp hH]
      apply lintegral_congr
      intro x; rw [split_sq]; rfl
    _ = ∫⁻ z : ℝ, ∫⁻ y : Plane, F (‖y‖^2+z^2,z) := lintegral_prod _ hH.aemeasurable
    _ = ∫⁻ z : ℝ, ENNReal.ofReal π * ∫⁻ t in Ioi (z^2), F (t,z) := by
      apply lintegral_congr; intro z
      have hm : Measurable (fun t : ℝ => F (t,z)) := hF.comp (measurable_id.prodMk measurable_const)
      rw [←lintegral_map hm (by fun_prop : Measurable (fun y : Plane => ‖y‖^2+z^2)),sliceArea,lintegral_smul_measure]
      rfl
    _ = ENNReal.ofReal π * ∫⁻ z : ℝ, ∫⁻ t : ℝ, A (z,t) := by
      rw [←lintegral_const_mul _ hA.lintegral_prod_right']
      apply lintegral_congr; intro z
      congr 1
      rw [←lintegral_indicator measurableSet_Ioi]
      rfl
    _ = ENNReal.ofReal π * ∫⁻ t : ℝ, ∫⁻ z : ℝ, A (z,t) := by
      rw [lintegral_lintegral_swap (f:=fun z t => A (z,t)) hA.aemeasurable]
    _ = _ := by
      congr 1
      apply lintegral_congr; intro t
      rw [←lintegral_indicator measurableSet_Ioo]
      apply lintegral_congr; intro z
      have equiv : z^2<t ↔ z ∈ Ioo (-sqrt t) (sqrt t) := by
        by_cases ht : 0≤t
        · rw [← sq_sqrt ht]
          rw [sq_lt_sq,abs_of_nonneg (sqrt_nonneg _),abs_lt]
          simp [sq_sqrt ht]
        · have h := sqrt_eq_zero_of_nonpos (le_of_not_ge ht)
          simp [h,show ¬z^2<t from not_lt.mpr (le_trans (le_of_not_ge ht) (sq_nonneg z))]
      simp only [A,Set.indicator,← equiv]

def axis (d : ℝ) : Space := EuclideanSpace.single 0 d

private theorem axisDist (x : Space) (d : ℝ) :
    dist x (axis d) = sqrt (‖x‖^2+d^2-2*d*x 0) := by
  rw [dist_eq_norm, ← sqrt_sq (norm_nonneg (x-axis d))]
  congr 1
  simp [EuclideanSpace.real_norm_sq_eq, Fin.sum_univ_succ, axis]
  ring

private theorem shellHeight_lintegral {d r : ℝ} (hr : 0≤r) (hd : r<d) :
    (∫⁻ z in Ioo (-r) r, ENNReal.ofReal (1/sqrt (r^2+d^2-2*d*z))) =
      ENNReal.ofReal (2*r/d) := by
  have le : -r≤r := by linarith
  have cont : ContinuousOn (fun z : ℝ => 1/sqrt (r^2+d^2-2*d*z)) (Icc (-r) r) := by
    apply ContinuousOn.div continuousOn_const (by fun_prop)
    intro z hz; apply ne_of_gt; apply sqrt_pos.mpr
    nlinarith [sq_pos_of_pos (sub_pos.mpr hd),mul_nonneg (le_trans hr hd.le) (sub_nonneg.mpr hz.2)]
  rw [← ofReal_integral_eq_lintegral_ofReal
    (cont.integrableOn_Icc.mono_set Ioo_subset_Icc_self) (Filter.Eventually.of_forall (fun z => by positivity)),
    ←integral_Ioc_eq_integral_Ioo,←intervalIntegral.integral_of_le le,shellHeight hr hd]

/-- Outside the radial support, a radial charge has exactly the Coulomb
potential of its whole charge placed at its center. -/
theorem exteriorAxis (f : ℝ → ℝ≥0∞) (hf : Measurable f)
    {d : ℝ} (hd : 0<d) (hcut : ∀ t, d^2≤t → f t=0) :
    (∫⁻ x : Space, f (‖x‖^2) * ENNReal.ofReal (1/dist x (axis d))) =
    (∫⁻ x : Space, f (‖x‖^2) * ENNReal.ofReal (1/d)) := by
  let F (p : ℝ × ℝ) := f p.1 * ENNReal.ofReal (1/sqrt (p.1+d^2-2*d*p.2))
  let G (p : ℝ × ℝ) := f p.1 * ENNReal.ofReal (1/d)
  have hF : Measurable F := (hf.comp measurable_fst).mul (by fun_prop)
  have hG : Measurable G := (hf.comp measurable_fst).mul measurable_const
  simp_rw [axisDist]
  change (∫⁻ x : Space, F (‖x‖^2,x 0)) = (∫⁻ x : Space, G (‖x‖^2,x 0))
  rw [radialHeight F hF,radialHeight G hG]
  congr 1
  apply lintegral_congr; intro t
  by_cases ht : 0≤t
  · by_cases hs : d^2≤t
    · simp [F,G,hcut _ hs]
    · let r := sqrt t
      have hr : 0≤r := sqrt_nonneg _
      have sqr : r^2=t := sq_sqrt ht
      have rd : r<d := by have := lt_of_not_ge hs; nlinarith
      dsimp only [F,G]
      rw [lintegral_const_mul _ (by fun_prop),lintegral_const,Measure.restrict_apply_univ,
        Real.volume_Ioo,sub_neg_eq_add]
      rw [←sqr,sqrt_sq hr,shellHeight_lintegral hr rd,mul_assoc,
        ←ENNReal.ofReal_mul (by positivity : 0≤1/d)]
      congr 2
      ring
  · simp [sqrt_eq_zero_of_nonpos (le_of_not_ge ht)]

/-- Orthogonal invariance takes the axial shell theorem to any point with positive radius carrying no charge on or beyond its shell. -/
theorem exteriorPoint (f : ℝ → ℝ≥0∞) (hf : Measurable f)
    {a : Space} (ha : 0<‖a‖) (hcut : ∀ t, ‖a‖^2≤t → f t=0) :
    (∫⁻ x : Space, f (‖x‖^2) * ENNReal.ofReal (1/dist x a)) =
    (∫⁻ x : Space, f (‖x‖^2) * ENNReal.ofReal (1/‖a‖)) := by
  let L := (ℝ ∙ (a-axis ‖a‖))ᗮ.reflection
  have eq : L a=axis ‖a‖ := Submodule.reflection_sub (by simp [axis])
  rw [←exteriorAxis f hf ha hcut,←eq]
  have hm : Measurable (fun x : Space => f (‖x‖^2)*ENNReal.ofReal (1/dist x (L a))) :=
    (hf.comp (by fun_prop)).mul (by fun_prop)
  rw [←L.measurePreserving.lintegral_comp hm]
  simp

/-- Real-integral version for nonnegative radial densities, including truncated
densities used in the self-interaction integral. -/
theorem exteriorReal (f : ℝ → ℝ) (hf : Measurable f) (hn : ∀ t, 0≤f t)
    {a : Space} (ha : 0<‖a‖) (hc : ∀ t, ‖a‖^2≤t → f t=0) :
    (∫ x : Space, f (‖x‖^2)/dist x a) = (∫ x : Space, f (‖x‖^2))/‖a‖ := by
  rw [←integral_div]
  have hme : Measurable (fun x : Space => f (‖x‖^2)) := hf.comp (by fun_prop)
  rw [integral_eq_lintegral_of_nonneg_ae
    (Filter.Eventually.of_forall (fun x : Space => div_nonneg (hn _) dist_nonneg))
    (hme.div (by fun_prop : Measurable (fun x : Space => dist x a))).aestronglyMeasurable,
    integral_eq_lintegral_of_nonneg_ae
    (Filter.Eventually.of_forall (fun x : Space => div_nonneg (hn _) (norm_nonneg a)))
    (hme.div measurable_const).aestronglyMeasurable]
  simp_rw [div_eq_mul_inv, ENNReal.ofReal_mul (hn _)]
  simpa [one_div] using congrArg ENNReal.toReal (exteriorPoint (fun t => ENNReal.ofReal (f t))
    hf.ennreal_ofReal ha (fun t ht => by simp [hc t ht]))

open SlaterEnergyCoulomb

private def profile (t : ℝ) := ENNReal.ofReal (density 0 (axis (sqrt t)))

private theorem profile_density (x : Space) :
    profile (‖x‖^2) = ENNReal.ofReal (density 0 x) := by
  simp [profile,density,wave,bump,FixedBasisRadial.shape,axis]

private theorem mass_one (A : Space) : (∫⁻ x, ENNReal.ofReal (density A x))=1 := by
  have h : Integrable (density A) := by
    by_contra hn
    simpa [integral_undef hn] using density_normalized A
  rw [← ofReal_integral_eq_lintegral_ofReal h (Filter.Eventually.of_forall (fun _ => sq_nonneg _)),
    density_normalized,ENNReal.ofReal_one]

/-- The actual normalized component contributes exactly 1/d at any exterior point. -/
theorem potential (A B : Space) (hd : 1<dist A B) :
    (∫⁻ x : Space, ENNReal.ofReal (density A x)*ENNReal.ofReal (1/dist x B)) =
      ENNReal.ofReal (1/dist A B) := by
  have hm : Measurable (fun x : Space => ENNReal.ofReal (density A x)*ENNReal.ofReal (1/dist x B)) :=
    (((wave_smooth A).continuous.pow 2).measurable.ennreal_ofReal).mul (by fun_prop)
  rw [←(measurePreserving_add_right volume A).lintegral_comp hm]
  have tt (x : Space) : density A (x+A) = density 0 x := by simp [density,wave]
  have dd (x : Space) : dist (x+A) B = dist x (B-A) := by
    rw [dist_eq_norm,dist_eq_norm]; congr 1; abel
  simp only [tt,dd]
  simp_rw [←profile_density]
  have hf : Measurable profile := by
    unfold profile
    simp only [density,wave,sub_zero,bump,FixedBasisRadial.shape,axis,PiLp.norm_single]
    fun_prop
  have hc t (ht : 1≤t) : profile t=0 := by
    unfold profile density
    rw [wave_zero (by simp [axis,Real.norm_eq_abs,abs_of_nonneg (sqrt_nonneg t)]; exact ht)]
    simp
  have norm : ‖B-A‖=dist A B := by rw [←dist_eq_norm,dist_comm]
  rw [exteriorPoint profile hf (a:=B-A) (by linarith) (fun t ht => hc t (by rw [norm] at ht; nlinarith)),norm]
  simp_rw [profile_density]
  rw [lintegral_mul_const _ (by exact ((wave_smooth 0).continuous.pow 2).measurable.ennreal_ofReal),mass_one,one_mul]

/-- Exact six-dimensional Coulomb energy of any two disjoint unit-ball
components whose centers are more than two units apart. -/
theorem separatedInteraction (A B : Space) (hd : 2<dist A B) :
    interaction A B = 1/dist A B := by
  let k (p : Space × Space) := density A p.1 * density B p.2 / dist p.1 p.2
  have hk : Integrable k (volume.prod volume) := kernel_integrable A B
  have pos (p) : 0≤k p := div_nonneg (mul_nonneg (sq_nonneg _) (sq_nonneg _)) dist_nonneg
  have eq : ENNReal.ofReal (interaction A B) =
      ∫⁻ x : Space, ENNReal.ofReal (density A x) * ENNReal.ofReal (1/dist x B) := by
    rw [show interaction A B = ∫ p, k p ∂volume.prod volume by rfl,
      ofReal_integral_eq_lintegral_ofReal hk (Filter.Eventually.of_forall pos),
      lintegral_prod _ hk.aestronglyMeasurable.aemeasurable.ennreal_ofReal]
    apply lintegral_congr; intro x
    have fac (y : Space) : ENNReal.ofReal (k (x,y)) =
        ENNReal.ofReal (density A x) * (ENNReal.ofReal (density B y) * ENNReal.ofReal (1/dist y x)) := by
      dsimp [k]
      rw [← ENNReal.ofReal_mul (show 0≤density B y from sq_nonneg _),← ENNReal.ofReal_mul (show 0≤density A x from sq_nonneg _),dist_comm y x]
      ring_nf
    simp_rw [fac]
    have hm : Measurable (fun y => ENNReal.ofReal (density B y)*ENNReal.ofReal (1/dist y x)) :=
      ((wave_smooth B).continuous.pow 2).measurable.ennreal_ofReal.mul (by fun_prop)
    rw [lintegral_const_mul _ hm]
    by_cases hx : dist x A<1
    · rw [potential B x (by linarith [dist_triangle A x B,dist_comm B x,dist_comm A x]),dist_comm B x]
    · simp [density,wave_zero (le_of_not_gt hx)]
  rw [potential A B (by linarith)] at eq
  exact (ENNReal.ofReal_eq_ofReal_iff (nonnegative _ _) (by positivity)).mp eq

end FQChem.Complexity.FixedBasisShell
