module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticDirichlet
import Mathlib.Tactic

/-! # From path congestion to mixing from the empty subgraph

The lazy edge-toggle kernel contracts the squared centered density in the stationary
L² norm. Starting from the empty edge set costs at most 2^m in squared norm; the
resulting burn-in depends polynomially on the system size and logarithmically on
the desired distance to stationarity.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
variable {n : ℕ}

private theorem weightSum (g : Glass n) (x u : ℝ) :
    (∑ A : Config g.bonds, boostedWeight x u A.val) = boostedMass g.bonds x u :=
  Finset.sum_attach _ _

private theorem totalPositive (g : Glass n) {x u : ℝ} (hx : 0<x) (hu : 0<u) : 0<boostedMass g.bonds x u :=
  Finset.sum_pos (fun A _ => boostedWeightPositive hx hu A) ⟨∅,Finset.empty_mem_powerset _⟩

theorem lawProbability (g : Glass n) {x u : ℝ} (hx : 0<x) (hu : 0<u) :
    (∀ A, 0 < law g x u A) ∧ ∑ A, law g x u A=1 := by
  have Z := totalPositive g hx hu
  refine ⟨fun A => div_pos (boostedWeightPositive hx hu A.val) Z,?_⟩
  change (∑ A : Config g.bonds, boostedWeight x u A.val/boostedMass g.bonds x u)=1
  rw [← Finset.sum_div,weightSum,div_self Z.ne']

private theorem pairMoment {α : Type*} [Fintype α] (p f : α → ℝ) (one : ∑ a, p a=1) :
    ∑ a, ∑ b, p a*p b*(f b-f a)^2 =
      2*(expected p (fun a => f a^2) - (expected p f)^2) := by
  have term (a b) : p a*p b*(f b-f a)^2 =
      p a*(p b*f b^2) + (p a*f a^2)*p b - (2*(p a*f a))*(p b*f b) := by ring
  simp only [term,Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
    ← Finset.sum_mul,one,mul_one,one_mul,expected]
  ring

def rate (m : ℕ) (x u : ℝ) := x*u^6/(4*(m:ℝ)^2)

theorem contraction (g : Glass n) (hm : 0<g.bonds.card) {x u : ℝ} (hx : 0<x) (x₁ : x≤1)
    (hu : 0<u) (u₁ : u≤1) (f : Config g.bonds → ℝ) (hf : expected (law g x u) f=0) :
    let p := law g x u
    let K := kernel g x u
    expected p (fun A => (expected (K A) f)^2) ≤
      (1-rate g.bonds.card x u)*expected p (fun A => f A^2) := by
  intro p K
  have ⟨pp,one⟩ := lawProbability g hx hu
  let V := expected p (fun A => f A^2)
  let V' := expected p (fun A => (expected (K A) f)^2)
  let H := ∑ a, p a * ∑ b, K a b*(f b-f a)^2
  have oneRow (a) : ∑ b, K a b=1 := (kernelProbability g hx hu a).2
  have nn (a b) : 0 ≤ K a b := (kernelProbability g hx hu a).1 b
  have per (a) : 1/2*(∑ b, K a b*(f b-f a)^2) ≤
      2*(expected (K a) (fun b => f b^2) - (expected (K a) f)^2) := by
    rw [← pairMoment _ _ (oneRow a)]
    calc _ ≤ K a a*(∑ b, K a b*(f b-f a)^2) :=
           mul_le_mul_of_nonneg_right (kernelLazy g hx hu a)
             (Finset.sum_nonneg fun b _ => mul_nonneg (nn a b) (sq_nonneg _))
         _ ≤ _ := by
           have s := Finset.single_le_sum (s := Finset.univ) (f := fun c =>
             ∑ b, K a c*K a b*(f b-f c)^2) (fun c _ => Finset.sum_nonneg fun b _ =>
             mul_nonneg (mul_nonneg (nn a c) (nn a b)) (sq_nonneg _)) (Finset.mem_univ a)
           rw [Finset.mul_sum]; simpa only [mul_assoc] using s
  have stationaryMoment : (∑ a, p a*expected (K a) (fun b => f b^2)) = V := by
    unfold expected
    simp only [Finset.mul_sum]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro b _
    change (∑ a, p a*(K a b*f b^2)) = p b*f b^2
    simp_rw [← mul_assoc]; rw [← Finset.sum_mul]; exact congrArg (· * f b^2) (stationary g hx hu b)
  have averaged : 1/2*H ≤ 2*(V-V') := by
    calc _ = ∑ a, p a*(1/2*(∑ b, K a b*(f b-f a)^2)) := by
           dsimp only [H]; rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun _ _ => by ring
         _ ≤ ∑ a, p a*(2*(expected (K a) (fun b => f b^2) - (expected (K a) f)^2)) :=
           Finset.sum_le_sum (fun a _ => mul_le_mul_of_nonneg_left (per a) (pp a).le)
         _ = _ := by
           rw [← stationaryMoment]
           change (∑ a, p a * (2 * (expected (K a) (fun b => f b^2) - (expected (K a) f)^2))) =
             2*((∑ a, p a*expected (K a) (fun b => f b^2)) - ∑ a, p a*(expected (K a) f)^2)
           rw [mul_sub,Finset.mul_sum,Finset.mul_sum,← Finset.sum_sub_distrib]
           exact Finset.sum_congr rfl fun _ _ => by ring
  have comparison := poincare g hm hx x₁ hu u₁ f
  change x*u^6*(∑ a, ∑ b, p a*p b*(f b-f a)^2) ≤ 2*(g.bonds.card:ℝ)^2*H at comparison
  rw [pairMoment _ _ one,hf, zero_pow (by decide : 2≠0),sub_zero] at comparison
  have m : 0<(g.bonds.card:ℝ) := by exact_mod_cast hm
  change V' ≤ (1-(x*u^6/(4*(g.bonds.card:ℝ)^2)))*V
  rw [sub_mul,one_mul,div_mul_eq_mul_div,le_sub_iff_add_le]
  field_simp
  change x*u^6*(2*V) ≤ _ at comparison
  nlinarith [mul_le_mul_of_nonneg_left averaged (sq_nonneg (g.bonds.card:ℝ))]

def density (g : Glass n) (x u : ℝ) (t : ℕ) (A : Config g.bonds) :=
  fromEmpty g x u t A / law g x u A - 1

private theorem centered (g : Glass n) {x u : ℝ} (hx : 0<x) (hu : 0<u) (t : ℕ) :
    expected (law g x u) (density g x u t)=0 := by
  have prob := lawProbability g hx hu
  have eq (a) : law g x u a*density g x u t a=fromEmpty g x u t a-law g x u a := by
    dsimp [density]; field_simp [(prob.1 a).ne']
  simp only [expected,eq,Finset.sum_sub_distrib,(fromEmptyProbability g hx hu t).2,prob.2,sub_self]

private theorem densityStep (g : Glass n) {x u : ℝ} (hx : 0<x) (hu : 0<u) (t : ℕ) (A : Config g.bonds) :
    density g x u (t+1) A = expected (kernel g x u A) (density g x u t) := by
  let p := law g x u
  let K := kernel g x u
  let q := fromEmpty g x u t
  have pp := (lawProbability g hx hu).1
  have balance (a b) : p a*K a b=p b*K b a := by
    simp only [p,K,law,div_mul_eq_mul_div]
    rw [detailedBalance g hx hu a b]
  have each (b) : q b*K b A/p A = K A b*(q b/p b) := by
    have h := balance b A
    have pa : p A ≠ 0 := (pp A).ne'
    have pb : p b ≠ 0 := (pp b).ne'
    field_simp [pa,pb]
    nlinarith only [congrArg (· * q b) h]
  change (∑ b, q b*K b A)/p A - 1 = ∑ b, K A b*(q b/p b-1)
  simp only [Finset.sum_div,each,mul_sub,mul_one,Finset.sum_sub_distrib,show (∑ b, K A b)=1 from (kernelProbability g hx hu A).2]

private theorem initialSquare (g : Glass n) {x u : ℝ} (hx : 0<x) (x₁ : x≤1) (hu : 0<u) (u₁ : u≤1) :
    expected (law g x u) (fun A => (density g x u 0 A)^2) ≤ (2:ℝ)^g.bonds.card := by
  let p := law g x u
  let empty : Config g.bonds := ⟨∅,Finset.empty_mem_powerset _⟩
  have prob := lawProbability g hx hu
  have z : 0<boostedMass g.bonds x u := totalPositive g hx hu
  have p0 : p empty = (boostedMass g.bonds x u)⁻¹ := by simp [p,law,empty,boostedWeight,boundary_empty,aligned,oddFactor]
  have zero (A : Config g.bonds) : A.val=∅ ↔ A=empty := ⟨fun h => Subtype.ext h,fun h => congrArg Subtype.val h⟩
  have point (A : Config g.bonds) : p A*(density g x u 0 A)^2 =
      p A + if A=empty then (p empty)⁻¹-2 else 0 := by
    by_cases h : A=empty
    · subst A
      simp only [density,fromEmpty,zero,ite_true,p]
      field_simp [(prob.1 empty).ne']; ring
    · simp [density,fromEmpty,zero,h,p]
  have eq : expected p (fun A => (density g x u 0 A)^2) = boostedMass g.bonds x u - 1 := by
    change (∑ A, p A*(density g x u 0 A)^2) = _
    simp_rw [point]
    rw [Finset.sum_add_distrib,prob.2]
    simp [p0]; ring
  have bound : boostedMass g.bonds x u ≤ (2:ℝ)^g.bonds.card := by
    calc _ ≤ ∑ _A ∈ g.bonds.powerset, (1:ℝ) := Finset.sum_le_sum (fun A _ => by
           have nn : 0 ≤ oddFactor u (boundary A) := Finset.prod_nonneg fun i _ => by split <;> positivity
           have ub : oddFactor u (boundary A) ≤ 1 := by apply Finset.prod_le_one₀ <;> intro i _ <;> split <;> linarith
           exact (mul_le_mul_of_nonneg_right (pow_le_one₀ hx.le x₁) nn).trans (by simpa using ub))
         _ = _ := by simp
  linarith [eq]

theorem mixingDistance (g : Glass n) (hm : 0<g.bonds.card) {x u : ℝ} (hx : 0<x) (x₁ : x≤1)
    (hu : 0<u) (u₁ : u≤1) (t : ℕ) :
    (∑ A, |fromEmpty g x u t A - law g x u A|)^2 ≤
      (1-rate g.bonds.card x u)^t * (2:ℝ)^g.bonds.card := by
  let p := law g x u
  let r := rate g.bonds.card x u
  have pp := lawProbability g hx hu
  have m : 1 ≤ (g.bonds.card:ℝ) := by exact_mod_cast hm
  have non : 0 ≤ 1-r := by
    apply sub_nonneg.mpr; apply (div_le_one (by positivity : 0<4*(g.bonds.card:ℝ)^2)).mpr
    have h := mul_le_mul x₁ (pow_le_one₀ hu.le u₁ (n := 6)) (pow_nonneg hu.le _) zero_le_one
    nlinarith [sq_nonneg ((g.bonds.card:ℝ)-1)]
  have sq (k : ℕ) : expected p (fun A => (density g x u k A)^2) ≤ (1-r)^k * (2:ℝ)^g.bonds.card := by
    induction k with
    | zero => simpa [p] using initialSquare g hx x₁ hu u₁
    | succ k ih =>
      simp_rw [densityStep g hx hu k]
      have C := contraction g hm hx x₁ hu u₁ _ (centered g hx hu k)
      exact C.trans (by rw [pow_succ',mul_assoc]; exact mul_le_mul_of_nonneg_left ih non)
  let z := fun A => |density g x u t A|
  have id (A : Config g.bonds) : |fromEmpty g x u t A - p A| = p A*z A := by
    change _ = p A*|fromEmpty g x u t A/p A-1|
    have pos : 0 < p A := pp.1 A
    calc _ = |p A*(fromEmpty g x u t A/p A-1)| := congrArg abs (by field_simp [pos.ne'])
         _ = _ := by rw [abs_mul,abs_of_pos pos]
  change (∑ A, |fromEmpty g x u t A - p A|)^2 ≤ _
  simp_rw [id]
  change (expected p z)^2 ≤ _
  have pair : 0 ≤ ∑ a, ∑ b, p a * p b * (z b-z a)^2 := Finset.sum_nonneg fun a _ =>
    Finset.sum_nonneg fun b _ => mul_nonneg (mul_nonneg (pp.1 a).le (pp.1 b).le) (sq_nonneg _)
  rw [pairMoment _ _ pp.2] at pair
  have s : expected p (fun A => z A^2) = expected p (fun A => density g x u t A^2) := by simp [z]
  rw [s] at pair
  linarith [sq t]

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
