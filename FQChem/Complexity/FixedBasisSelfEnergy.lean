module

public import FQChem.Complexity.FixedBasisShell
import Mathlib.Analysis.Calculus.Deriv.Polynomial
import Mathlib.Tactic

/-! # Exact self Coulomb integral of the compact orbital

Exchange symmetry reduces the six-dimensional integral to the region where
the inner electron's radius is smaller. Newton's exterior shell identity then
replaces the inner density by its cumulative charge divided by the outer radius.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.FixedBasisSelfEnergy
open MeasureTheory Metric Set Real FixedBasisGaussians FixedBasisRadial FixedBasisShell SlaterEnergyCoulomb
open scoped ENNReal Interval

private theorem density_sq (x : Space) : density 0 x =
    (if ‖x‖<1 then (1-‖x‖^2)^5 else 0)/weight := by
  rw [density,wave,sub_zero,div_pow,sq_sqrt weight_pos.le,bump,squared]

private theorem truncated (x : Space) (hx : 0<‖x‖) (h1 : ‖x‖<1) :
    (∫ y : Space, (if ‖y‖<‖x‖ then density 0 y else 0)/dist y x) =
      (4*π*massPrimitive.eval ‖x‖)/(weight*‖x‖) := by
  let f (t : ℝ) := if t<‖x‖^2 then (1-t)^5/weight else 0
  have hf : Measurable f := Measurable.ite measurableSet_Iio (by fun_prop) measurable_const
  have hn t : 0≤f t := by
    dsimp [f]; split
    next ht => exact div_nonneg (pow_nonneg (by nlinarith) _) weight_pos.le
    next => rfl
  have hc t (ht : ‖x‖^2≤t) : f t=0 := by simp [f,not_lt.mpr ht]
  have value (y : Space) : (if ‖y‖<‖x‖ then density 0 y else 0) = f (‖y‖^2) := by
    have iff : ‖y‖^2<‖x‖^2 ↔ ‖y‖<‖x‖ := sq_lt_sq₀ (norm_nonneg _) hx.le
    by_cases h : ‖y‖<‖x‖
    · simp [f,density_sq,h,iff,h.trans h1]
    · simp [f,h,iff]
  simp_rw [value]
  rw [exteriorReal f hf hn hx hc]
  have form (y : Space) : f (‖y‖^2)=if ‖y‖<‖x‖ then (1-‖y‖^2)^5/weight else 0 := by
    simp [f,sq_lt_sq₀ (norm_nonneg _) hx.le]
  simp_rw [form]
  rw [radialBallOfRadius ‖x‖ hx.le (fun r => (1-r^2)^5/weight)]
  simp_rw [←mul_div_assoc]
  rw [intervalIntegral.integral_div,cumulative]
  ring

private def kernel (p : Space × Space) := density 0 p.1*density 0 p.2/dist p.1 p.2

private def half (p : Space × Space) := if ‖p.2‖<‖p.1‖ then kernel p else 0

private theorem half_integrable : Integrable half (volume.prod volume) :=
  (kernel_integrable 0 0).indicator (measurableSet_lt (measurable_norm.comp measurable_snd)
    (measurable_norm.comp measurable_fst))

private theorem swapHalves : interaction 0 0 = 2*∫ p, half p ∂volume.prod volume := by
  have neq : ∀ᵐ p : Space × Space ∂volume.prod volume, ‖p.1‖ ≠ ‖p.2‖ := by
    apply (Measure.ae_prod_iff_ae_ae (measurableSet_eq_fun
      (measurable_norm.comp measurable_fst) (measurable_norm.comp measurable_snd)).compl).mpr
    filter_upwards with x
    rw [ae_iff]
    change volume {y : Space | ¬¬ ‖x‖=‖y‖}=0
    have s : {y : Space | ¬¬ ‖x‖=‖y‖}=sphere (0:Space) ‖x‖ := by
      ext y; change (¬¬ ‖x‖=‖y‖) ↔ dist y 0=‖x‖; simp [eq_comm]
    rw [s]
    exact Measure.addHaar_sphere _ _ _
  have eq : kernel =ᵐ[volume.prod volume] fun p => half p+half p.swap := by
    filter_upwards [neq] with p hp
    rcases lt_or_gt_of_ne hp with h|h <;> simp [half,h,not_lt.mpr h.le,kernel,dist_comm,mul_comm]
  have intSwap : Integrable (fun p : Space × Space => half p.swap) (volume.prod volume) :=
    (Measure.measurePreserving_swap.integrable_comp_emb MeasurableEquiv.prodComm.measurableEmbedding).mpr half_integrable
  rw [show interaction 0 0 = ∫ p, kernel p ∂volume.prod volume by rfl,integral_congr_ae eq,
    integral_add half_integrable intSwap,
    Measure.measurePreserving_swap.integral_comp MeasurableEquiv.prodComm.measurableEmbedding half,
    two_mul]

private theorem halfValue (x : Space) :
    (∫ y, half (x,y)) = if ‖x‖<1 then
      density 0 x*(4*π*massPrimitive.eval ‖x‖)/(weight*‖x‖) else 0 := by
  have fac y : half (x,y) = density 0 x * ((if ‖y‖<‖x‖ then density 0 y else 0)/dist y x) := by
    by_cases h : ‖y‖<‖x‖ <;> simp [half,kernel,h,dist_comm x y,mul_div_assoc]
  simp_rw [fac]
  rw [integral_const_mul]
  by_cases h : ‖x‖<1
  · rw [ite_eq_left h]
    by_cases hx : x=0
    · simp [hx,not_lt.mpr (norm_nonneg _)]
    · rw [truncated x (norm_pos_iff.mpr hx) h]; ring
  · simp [h,density_sq]

private def selfPrimitive : Polynomial ℝ :=
  Polynomial.C (1/15)*Polynomial.X^5 + Polynomial.C (-8/21)*Polynomial.X^7 + Polynomial.C (205/189)*Polynomial.X^9 + Polynomial.C (-1360/693)*Polynomial.X^11 + Polynomial.C (22150/9009)*Polynomial.X^13 + Polynomial.C (-298016/135135)*Polynomial.X^15 + Polynomial.C (217874/153153)*Polynomial.X^17 + Polynomial.C (-110800/171171)*Polynomial.X^19 + Polynomial.C (5345/27027)*Polynomial.X^21 + Polynomial.C (-120/3289)*Polynomial.X^23 + Polynomial.C (1/325)*Polynomial.X^25

/-- The six-dimensional normalized onsite repulsion is the fixed rational
396396/185725 for the chosen C² compact-support orbital. -/
theorem self_value : interaction 0 0 = 396396/185725 := by
  rw [swapHalves,integral_prod _ half_integrable]
  simp_rw [halfValue]
  have num (x : Space) :
      (if ‖x‖<1 then density 0 x*(4*π*massPrimitive.eval ‖x‖)/(weight*‖x‖) else 0) =
      (4*π/weight^2)*(if ‖x‖<1 then (1-‖x‖^2)^5*massPrimitive.eval ‖x‖/‖x‖ else 0) := by
    by_cases h : ‖x‖<1 <;> simp [density_sq,h]
    ring
  simp_rw [num]
  rw [integral_const_mul, radialBall (fun r => (1-r^2)^5*massPrimitive.eval r/r)]
  have cancel (r : ℝ) :
      r^2*((1-r^2)^5*massPrimitive.eval r/r)= r*(1-r^2)^5*massPrimitive.eval r := by
    by_cases h : r=0
    · simp [h]
    · field_simp [h]
  simp_rw [cancel]
  have d r : HasDerivAt (fun x => selfPrimitive.eval x) (r*(1-r^2)^5*massPrimitive.eval r) r := by
    convert selfPrimitive.hasDerivAt r using 1
    simp [selfPrimitive,massPrimitive]
    ring
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt (fun u _ => d u)
    (by apply Continuous.intervalIntegrable; fun_prop),show weight=4*π*(256/9009) from volumeMass]
  norm_num [selfPrimitive]
  field_simp [pi_ne_zero]
  ring

end FQChem.Complexity.FixedBasisSelfEnergy
