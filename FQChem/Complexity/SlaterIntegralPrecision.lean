module

public import FQChem.Complexity.SlaterIntegerVerifier
import Mathlib.Tactic

/-! # Robustness to finite-precision one- and two-electron integrals

This compares the physical determinant expectation with its finite rational
description. A quarter-gap error allowance on either side preserves the
decision promise. -/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SlaterIntegralPrecision
open SlaterContraction SlaterCertificate SlaterIntegerVerifier
open scoped ComplexConjugate
variable {d k : ℕ}

private theorem sumBound (n : ℕ) (f : Fin n → ℂ) (M : ℝ) (h : ∀ i, ‖f i‖≤M) :
    ‖∑ i, f i‖≤n*M := by
  simpa using norm_sum_le_of_le Finset.univ fun i _ => h i

/-- On a normalized determinant, errors on each one- or two-body coefficient
are multiplied by a polynomial independent of the many-particle dimension. -/
def coefficientConstant (d k : ℕ) : ℕ := d^2*k+2*d^4*k^2

theorem integralError (f : Frame (Fin d) k) (hf : Orthonormal ℂ f)
    (h h' : Fin d → Fin d → ℂ) (u u' : Fin d → Fin d → Fin d → Fin d → ℂ)
    (e : ℝ) (hh : ∀ p q, ‖h p q-h' p q‖≤e) (hu : ∀ p q r s, ‖u p q r s-u' p q r s‖≤e) :
    ‖bra f (hamiltonian k h u (ket f))-bra f (hamiltonian k h' u' (ket f))‖≤
      coefficientConstant d k*e := by
  have entry j i : ‖f j i‖≤1 := (PiLp.norm_apply_le _ i).trans (hf.norm_eq_one j).le
  have dens p q : ‖density f p q‖≤k := by
    calc
      _ ≤ (k:ℝ)*1 := sumBound _ _ _ fun j => by
        rw [norm_mul, Complex.norm_conj]
        exact (mul_le_of_le_one_left (norm_nonneg _) (entry j p)).trans (entry j q)
      _ = _ := mul_one _
  have prod p q r s : ‖density f p q*density f r s‖≤(k:ℝ)^2 := by
    rw [norm_mul,sq]; exact mul_le_mul (dens p q) (dens r s) (norm_nonneg _) (Nat.cast_nonneg k)
  have one p q : ‖h p q*density f q p-h' p q*density f q p‖≤e*k := by
    rw [←sub_mul,norm_mul]; exact mul_le_mul (hh _ _) (dens _ _) (norm_nonneg _) ((norm_nonneg _).trans (hh p q))
  have two p q r s : ‖u p q r s*(density f q p*density f s r-density f s p*density f q r)-
      u' p q r s*(density f q p*density f s r-density f s p*density f q r)‖≤e*(2*(k:ℝ)^2) := by
    rw [←sub_mul,norm_mul]; apply mul_le_mul (hu _ _ _ _) _ (norm_nonneg _) ((norm_nonneg _).trans (hu p q r s))
    exact (norm_sub_le _ _).trans (by
      rw [two_mul]
      exact add_le_add (prod q p s r) (prod s p q r))
  rw [energy f hf,energy f hf]
  unfold score
  rw [add_sub_add_comm]
  simp_rw [←Finset.sum_sub_distrib]
  calc
    _ ≤ _ := norm_add_le _ _
    _ ≤ (d:ℝ)*(d*(e*k))+d*(d*(d*(d*(e*(2*(k:ℝ)^2)))) ) :=
      add_le_add (sumBound _ _ _ fun p => sumBound _ _ _ fun q => one p q)
        (sumBound _ _ _ fun p => sumBound _ _ _ fun q => sumBound _ _ _ fun r => sumBound _ _ _ fun s => two p q r s)
    _ = _ := by unfold coefficientConstant; push_cast; ring

/-- The integer verifier still decides the promise on the true physical
integrals when its supplied coefficients have certified quarter-gap accuracy. -/
theorem verifiesApproximations (h : Fin d → Fin d → ℂ) (u : Fin d → Fin d → Fin d → Fin d → ℂ)
    (I : Integrals d) (M t : ℕ) (ht : 0<t) (lo hi : ℚ) (gap : 1/(t:ℚ)≤hi-lo)
    (e : ℝ) (hh : ∀ p q, ‖h p q-I.oneBody p q‖≤e)
    (hu : ∀ p q r s, ‖u p q r s-I.twoBody p q r s‖≤e)
    (small : coefficientConstant d k*e≤1/(4*(t:ℝ)))
    (hM : ∀ p q, ‖I.oneBody p q‖≤M) (uM : ∀ p q r s, ‖I.twoBody p q r s‖≤M) :
    ((∃ f : Frame (Fin d) k, Orthonormal ℂ f ∧
       (bra f (hamiltonian k h u (ket f))).re≤(lo:ℝ)) →
      ∃ w : Witness d k (denominator d k M (2*t)), verify I M (2*t) (lo+1/(4*t)) w=true) ∧
    ((∀ f : Frame (Fin d) k, Orthonormal ℂ f →
       (hi:ℝ)≤(bra f (hamiltonian k h u (ket f))).re) →
      ∀ w : Witness d k (denominator d k M (2*t)), verify I M (2*t) (lo+1/(4*t)) w=false) := by
  have pos : 0<(t:ℚ) := by exact_mod_cast ht
  have eps : 1/(t:ℚ)-2*(1/(4*(t:ℚ)))=1/(2*t) := by field_simp; ring
  have gap' : 1/((2*t:ℕ):ℚ)≤(hi-1/(4*t))-(lo+1/(4*t)) := by push_cast; linarith
  have alg := @verifies d k I M (2*t) (by omega) (lo+1/(4*t)) (hi-1/(4*t)) gap' hM uM
  have err (f : Frame (Fin d) k) (hf : Orthonormal ℂ f) := (Complex.abs_re_le_norm _).trans
    ((integralError f hf h I.oneBody u I.twoBody e hh hu).trans small)
  simp only [Complex.sub_re, abs_le] at err
  constructor
  · rintro ⟨f,hf,low⟩
    apply alg.1; refine ⟨f,hf,?_⟩
    push_cast; linarith [(err f hf).1]
  · intro no
    apply alg.2; intro f hf
    push_cast; linarith [(err f hf).2, no f hf]

end FQChem.Complexity.SlaterIntegralPrecision
