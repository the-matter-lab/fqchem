module

public import FQChem.StatePrep.ImaginaryTimeProjection.SignDecisionEstimator
import Mathlib.Tactic

/-! # The sign-free comparison at the decision query

[Troyer and Wiese, Eqs. (8)–(11)](https://doi.org/10.1103/PhysRevLett.94.170201).
At the particular low temperature and inverse-linear relative precision of the
decision reduction, simply returning the aligned ferromagnetic energy suffices.
This statement concerns the decision query; generic-temperature mixing has its
own algorithms and guarantees.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
variable {n : ℕ}

def aligned (n : ℕ) : Spin n := fun _ => false

theorem aligned_energy (g : Glass n) : g.ferro.energy (aligned n) = -(g.bonds.card : ℤ) := by
  have unit (e : Spin n) : character (aligned n) e = 1 := by simp [character, aligned, bitCharacter]
  simp [Glass.energy, unit, Glass.ferro, Glass.coupling]

theorem ferromagneticGround (g : Glass n) (x : Spin n) :
    g.ferro.energy (aligned n) ≤ g.ferro.energy x := by
  rw [aligned_energy]
  exact (abs_le.mp (energy_bound g.ferro x)).1

private theorem exponentBudget (n : ℕ) (hn : 0<n) :
    (2:ℝ)^n*(96*n) ≤ Real.exp (13*n) := by
  have nr : 1 ≤ (n:ℝ) := by exact_mod_cast hn
  have hr : 0 < (n:ℝ) := by positivity
  have log2 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
  have logN := Real.log_le_sub_one_of_pos hr
  have log96 : Real.log 96 ≤ 7 := by
    rw [Real.log_le_iff_le_exp (by norm_num : (0:ℝ)<96)]
    calc (96:ℝ) ≤ 2^7 := by norm_num
         _ ≤ (Real.exp 1)^7 := by gcongr; linarith [Real.add_one_le_exp (1:ℝ)]
         _ = Real.exp 7 := by rw [← Real.exp_nat_mul]; norm_num
  calc (2:ℝ)^n*(96*n) = Real.exp (n*Real.log 2 + (Real.log 96 + Real.log n)) := by
         rw [Real.exp_add, Real.exp_add, Real.exp_nat_mul, Real.exp_log (by norm_num : (0:ℝ)<2),
           Real.exp_log (by norm_num : (0:ℝ)<96), Real.exp_log hr]
       _ ≤ _ := Real.exp_le_exp.mpr (by nlinarith [mul_le_mul_of_nonneg_left log2 hr.le])

/-- The bosonic energy estimate at β=13N is the negative number of nonzero bonds.
Its relative error is at most 1/(24N), exactly the tolerance of statisticalDecision.
A zero-bond instance returns its exact zero energy. -/
theorem bosonicDecisionEstimate (g : Glass n) (hn : 0<n) :
    |-(g.bonds.card : ℝ)-g.ferro.quantumThermal (13*n)| ≤
      |g.ferro.quantumThermal (13*n)| / (24*n) := by
  let m : ℝ := g.bonds.card
  let Q := g.ferro.quantumThermal (13*n)
  have nn : 1 ≤ (n:ℝ) := by exact_mod_cast hn
  have nr : 0 < (n:ℝ) := by positivity
  by_cases hm : g.bonds.card=0
  · have b := thermalBound g.ferro (13*n)
    rw [show g.ferro.bonds.card = 0 from hm, Nat.cast_zero] at b
    have z := abs_nonpos_iff.mp b
    simp [hm,z]
  have mp : 0 < m := by change 0 < (g.bonds.card : ℝ); exact_mod_cast Nat.pos_of_ne_zero hm
  obtain ⟨lo,hi⟩ := excitationEstimate g.ferro (β := 13*n) (by positivity) (D := 2*m) (by positivity)
    (aligned n) (ferromagneticGround g) (fun x => energyRange g.ferro (aligned n) x)
  rw [aligned_energy, Int.cast_neg, Int.cast_natCast] at lo hi
  change -m ≤ Q at lo
  change Q < -m + (2:ℝ)^n*(2*m)*Real.exp (-(13*n)) at hi
  have cap : ((2:ℝ)^n*(2*m)*Real.exp (-(13*n)))*(48*n) ≤ m := by
    rw [Real.exp_neg]
    have hp := Real.exp_pos (13*(n:ℝ))
    field_simp
    nlinarith only [exponentBudget n hn]
  have small : (Q+m)*(48*n) ≤ m := by
    nlinarith only [cap, mul_lt_mul_of_pos_right hi (by positivity : 0 < (48:ℝ)*n)]
  have half : Q+m ≤ m/2 := by nlinarith [mul_nonneg (by linarith : 0 ≤ Q+m) (by linarith : 0 ≤ 48*(n:ℝ)-2)]
  change |-m-Q| ≤ |Q|/(24*n)
  rw [abs_of_nonpos (by linarith : -m-Q ≤ 0), abs_of_neg (by linarith : Q<0),
    le_div_iff₀ (by positivity)]
  linarith

end FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
