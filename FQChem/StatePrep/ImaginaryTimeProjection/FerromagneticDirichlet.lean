module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticPathComparison
public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticEnergySampling
import Mathlib.Tactic

/-! # Polynomial Poincaré bound for the boosted edge-toggle chain

Every proposal changes the occupied edge count by one and toggles exactly two
odd sites. For 0<x,u≤1 its acceptance is therefore at least x u²/2. Combining
this with the trail congestion bound compares variance to the kernel Dirichlet form.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
open scoped symmDiff
variable {n : ℕ}

private theorem edgePower (g : Glass n) {x : ℝ} (hx : 0≤x) (x₁ : x≤1) (e : ↥g.bonds) (A : Config g.bonds) :
    x*x^A.val.card ≤ x^(flip e A).val.card := by
  rw [← pow_succ']
  apply pow_le_pow_of_le_one hx x₁
  by_cases he : e.val∈A.val
  · simp [flip,he]; omega
  · simp [flip,he]

private theorem oddTransition (g : Glass n) {u : ℝ} (hu : 0<u) (u₁ : u≤1) (e : ↥g.bonds) (A : Config g.bonds) :
    u^2*oddFactor u (boundary A.val) ≤ oddFactor u (boundary (flip e A).val) := by
  obtain ⟨a,b,ab,edge⟩ := g.twoSite e.val e.property
  have toggled : boundary (flip e A).val = exchange e.val (boundary A.val) := by
    rw [flipSet,boundaryDifference]
    have single : boundary ({e.val} : Finset (Spin n)) = e.val := by funext i; simp [boundary]
    rw [single]; funext i; exact Bool.xor_comm ..
  have factor : (∏ i : Fin n, if e.val i then u else 1) = u^2 := by
    rw [Finset.prod_ite,Finset.prod_const_one, mul_one,Finset.prod_const]
    have eq : Finset.univ.filter (fun i => e.val i = true) = {a,b} := by ext i; simp [edge,pairMask]
    simp [eq,ab]
  rw [← factor,oddFactor,oddFactor,← Finset.prod_mul_distrib,toggled]
  apply Finset.prod_le_prod₀
  · intro i _; split_ifs <;> positivity
  · intro i _
    cases he : e.val i <;> cases ha : boundary A.val i <;> simp [exchange,he,ha]
    nlinarith [mul_nonneg hu.le (sub_nonneg.mpr u₁)]

theorem moveFloor (g : Glass n) {x u : ℝ} (hx : 0<x) (x₁ : x≤1) (hu : 0<u) (u₁ : u≤1)
    (e : ↥g.bonds) (A : Config g.bonds) :
    x*u^2/2 ≤ acceptance (fun a => boostedWeight x u a.val) e A := by
  let w := boostedWeight x u A.val
  have wp : 0 < w := boostedWeightPositive hx hu A.val
  have odd : 0 ≤ oddFactor u (boundary A.val) := Finset.prod_nonneg fun i _ => by split <;> positivity
  have actual : (x*u^2)*w ≤ boostedWeight x u (flip e A).val := by
    calc _ = (x*x^A.val.card)*(u^2*oddFactor u (boundary A.val)) := by dsimp [w,boostedWeight]; ring
         _ ≤ _ := mul_le_mul (edgePower g hx.le x₁ e A) (oddTransition g hu u₁ e A) (mul_nonneg (sq_nonneg _) odd) (pow_nonneg hx.le _)
  have r₁ : x*u^2 ≤ 1 := by simpa using mul_le_mul x₁ (pow_le_one₀ hu.le u₁ (n := 2)) (sq_nonneg _) zero_le_one
  apply (le_div_iff₀ (by positivity : 0 < 2*w)).mpr
  apply le_min <;> nlinarith [mul_le_mul_of_nonneg_right r₁ wp.le]

private theorem edgeGradient (g : Glass n) (w : Config g.bonds → ℝ) (f : Config g.bonds → ℝ)
    (T : Config g.bonds) (e : ↥g.bonds) :
    ∑ U, edgeStep w e T U * (f U - f T)^2 = acceptance w e T * grad f T e := by
  simp [edgeStep,add_mul,ite_mul,grad,Finset.sum_add_distrib]

private theorem toggleComparison (g : Glass n) (hm : 0<g.bonds.card) {x u : ℝ}
    (hx : 0<x) (x₁ : x≤1) (hu : 0<u) (u₁ : u≤1) (T : Config g.bonds) (f : Config g.bonds → ℝ) :
    (x*u^2/2)*(∑ e, grad f T e) ≤
      g.bonds.card * ∑ U, kernel g x u T U * (f U-f T)^2 := by
  let w := fun A : Config g.bonds => boostedWeight x u A.val
  have m : (g.bonds.card:ℝ)≠0 := by exact_mod_cast hm.ne'
  calc _ ≤ ∑ e, acceptance w e T*grad f T e := by
         rw [Finset.mul_sum]
         exact Finset.sum_le_sum fun e _ => mul_le_mul_of_nonneg_right (moveFloor g hx x₁ hu u₁ e T) (sq_nonneg _)
       _ = ∑ U, (∑ e, edgeStep w e T U) * (f U-f T)^2 := by
         simp_rw [← edgeGradient g w f T]
         rw [Finset.sum_comm]
         simp only [Finset.sum_mul]
       _ = _ := by
         rw [Finset.mul_sum]
         apply Finset.sum_congr rfl
         intro U _
         simp only [kernel,hm.ne',ite_false]
         change _ = (g.bonds.card:ℝ)*((∑ e, edgeStep w e T U)/g.bonds.card * _)
         field_simp

/-- Polynomial path comparison directly against the lazy chain kernel, with
normalized stationary probabilities. The relaxation coefficient is explicit. -/
theorem poincare (g : Glass n) (hm : 0<g.bonds.card) {x u : ℝ}
    (hx : 0<x) (x₁ : x≤1) (hu : 0<u) (u₁ : u≤1) (f : Config g.bonds → ℝ) :
    let p := law g x u
    (x*u^6) * (∑ I, ∑ F, p I*p F*(f F-f I)^2) ≤
      2*(g.bonds.card:ℝ)^2 * (∑ T, p T*∑ U, kernel g x u T U*(f U-f T)^2) := by
  intro p
  let w := fun A : Config g.bonds => boostedWeight x u A.val
  let Z := boostedMass g.bonds x u
  have Zp : 0<Z := Finset.sum_pos (fun A _ => boostedWeightPositive hx hu A) ⟨∅,Finset.empty_mem_powerset _⟩
  let J := ∑ a : Config g.bonds × Config g.bonds, (w a.1*w a.2)*(f a.2-f a.1)^2
  let G := ∑ T, w T*∑ e, grad f T e
  let H := ∑ T, w T*∑ U, kernel g x u T U*(f U-f T)^2
  have P : u^4 * J ≤ g.bonds.card*Z*G := pathComparison g hx hu u₁ f
  have Q : (x*u^2/2)*G ≤ g.bonds.card*H := by
    dsimp only [G,H]
    rw [Finset.mul_sum,Finset.mul_sum (a := (g.bonds.card:ℝ))]
    apply Finset.sum_le_sum
    intro T _
    have h := mul_le_mul_of_nonneg_left (toggleComparison g hm hx x₁ hu u₁ T f) (boostedWeightPositive hx hu T.val).le
    simpa only [w, mul_left_comm (x*u^2/2), mul_left_comm (g.bonds.card:ℝ)] using h
  have jp : ∑ I, ∑ F, p I*p F*(f F-f I)^2 = J/Z^2 := by
    dsimp only [J]; rw [Fintype.sum_prod_type,Finset.sum_div]
    apply Finset.sum_congr rfl
    intro I _
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun F _ => by dsimp [p,law,w,Z]; ring
  have hp : ∑ T, p T*∑ U, kernel g x u T U*(f U-f T)^2 = H/Z := by
    dsimp only [H]; rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun T _ => by dsimp [p,law,w,Z]; ring
  rw [jp,hp]
  apply (mul_le_mul_iff_left₀ (sq_pos_of_pos Zp)).mp
  have A := mul_le_mul_of_nonneg_left P (mul_nonneg hx.le (sq_nonneg u))
  have B := mul_le_mul_of_nonneg_left Q (by positivity : 0≤2*(g.bonds.card:ℝ)*Z)
  field_simp
  nlinarith only [A,B]

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
