module

public import FQChem.Complexity.FixedBasisGaussians
public import Mathlib.Topology.Order.IntermediateValue
import Mathlib.Tactic

/-! # Encoding negative Hubbard hopping coefficients with Gaussian separations

O'Gorman et al., Eqs. (C32), (C33), (C62), and (C63). The diagonal scale fixes β,
and each negative edge coefficient in range can be realized with a positive
distance between two primitive orbital centers.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.FixedBasisHopping
open Real Set Filter
open scoped Topology

def profile (ω : ℝ) := ω * exp (-ω/2)

def hopping (a d γ : ℝ) := -(a/(4*d))*profile (a*γ^2)

theorem profile_eq_sqrt (ω : ℝ) (hω : 0≤ω) :
    profile ω = √(ω^2*exp (-ω)) := by
  rw [Real.sqrt_mul (sq_nonneg _), Real.sqrt_sq hω]
  unfold profile
  congr 1
  calc
    exp (-ω/2) = √((exp (-ω/2))^2) := (Real.sqrt_sq (Real.exp_pos _).le).symm
    _ = _ := by rw [← Real.exp_nat_mul]; norm_num; ring_nf

private theorem profile_decay : Tendsto profile atTop (𝓝 0) := by
  have h := (Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 1).comp
    (tendsto_id.atTop_div_const (by norm_num : (0:ℝ)<2))
  have h' := h.const_mul 2
  convert h' using 1
  · funext ω
    simp [profile]
    ring_nf
  · simp

/-- Realize an individual strictly negative target. Absent graph edges supply
the zero coefficients without choosing an infinite separation. -/
theorem chooseDistance (a d ω₀ t : ℝ) (ha : 0<a) (hd : 0<d) (hω : 0<ω₀)
    (ht : t<0) (hrange : -(a/(4*d))*profile ω₀ ≤ t) :
    ∃ γ : ℝ, 0<γ ∧ ω₀ ≤ a*γ^2 ∧ hopping a d γ = t := by
  let scale := a/(4*d)
  have hs : 0 < scale := by dsimp [scale]; positivity
  let y := -t/scale
  have hy : 0<y := div_pos (neg_pos.mpr ht) hs
  have upper : y ≤ profile ω₀ := (div_le_iff₀ hs).mpr (by dsimp [scale] at *; nlinarith)
  obtain ⟨T,hT⟩ := eventually_atTop.1 (profile_decay.eventually_lt_const hy)
  have hI := intermediate_value_Icc' (le_max_left ω₀ T)
    (f:=profile) (show ContinuousOn profile _ from (show Continuous profile by unfold profile;fun_prop).continuousOn)
  obtain ⟨ω,hωI,hp⟩ := hI (show y ∈ Icc (profile (max ω₀ T)) (profile ω₀) from
    ⟨(hT _ (le_max_right ..)).le,upper⟩)
  have wpos := hω.trans_le hωI.1
  have square := Real.sq_sqrt (div_nonneg wpos.le ha.le)
  have eq : a * (√(ω/a))^2 = ω := by rw [square]; field_simp
  refine ⟨_,Real.sqrt_pos.2 (div_pos wpos ha),by rw [eq]; exact hωI.1,?_⟩
  rw [hopping,eq,hp]
  change -scale * (-t/scale) = t
  field_simp

/-- For a positive target onsite repulsion, select β and all edge separations
to realize a common positive multiple of the Hubbard coefficients exactly in
the main Hamiltonian. These real parameters precede finite-precision encoding
and the error bound from discarding the other physical terms. -/
theorem matchCoefficients {ι : Type*} (a d ω₀ ρ U : ℝ) (t : ι → ℝ)
    (ha : 0<a) (hd : 0<d) (hω : 0<ω₀) (hρ : 0<ρ) (hU : 0<U)
    (ht : ∀ e, t e<0) (hbound : ∀ e, -(a/(4*d))*profile ω₀ ≤ ρ*t e) :
    ∃ β : ℝ, 0<β ∧ √β/(2*√π)=ρ*U ∧ ∃ γ : ι → ℝ,
      ∀ e, 0<γ e ∧ ω₀≤a*(γ e)^2 ∧ hopping a d (γ e)=ρ*t e := by
  let b := 2*√π*(ρ*U)
  have hb : 0<b := by dsimp [b]; positivity
  refine ⟨b^2,sq_pos_of_pos hb,?_,?_⟩
  · rw [Real.sqrt_sq hb.le]
    dsimp [b]; field_simp
  · choose γ hγ using fun e => chooseDistance a d ω₀ (ρ*t e) ha hd hω (mul_neg_of_pos_of_neg hρ (ht e)) (hbound e)
    exact ⟨γ,hγ⟩

end FQChem.Complexity.FixedBasisHopping
