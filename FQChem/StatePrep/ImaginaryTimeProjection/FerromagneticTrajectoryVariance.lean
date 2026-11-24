module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticTrajectory
import Mathlib.Tactic

/-! # Finite-time variance of one stationary or warm-started trajectory

The squared L² contraction controls the conditional expected sum of future
readouts. The second-moment recursion then bounds all lag correlations at once.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
variable {α : Type*} [Fintype α] {n : ℕ}

private theorem expectedScale (p f : α → ℝ) (c : ℝ) :
    expected p (fun a => c*f a) = c*expected p f := by
  unfold expected
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun _ _ => by ring

private theorem expectedMono (p : α → ℝ) (hp : ∀a, 0≤p a) {f h : α → ℝ} (le : ∀a, f a≤h a) :
    expected p f ≤ expected p h := Finset.sum_le_sum fun a _ => mul_le_mul_of_nonneg_left (le a) (hp a)

private theorem futureCentered (g : Glass n) {x u : ℝ} (hx : 0<x) (hu : 0<u)
    (f : Config g.bonds → ℝ) (h : expected (law g x u) f=0) (k : ℕ) :
    expected (law g x u) (futureSum (kernel g x u) f k)=0 := by
  induction k with
  | zero => simp [expected,futureSum]
  | succ k ih =>
    change expected _ (fun a => f a + expected _ (futureSum _ f k))=0
    have eq := stationaryMean g hx hu (futureSum (kernel g x u) f k)
    simp only [expected,mul_add,Finset.sum_add_distrib] at h eq ih ⊢
    linarith

/-- The inverse relaxation rate controls the conditional mean of the cumulative
centered observable uniformly in trajectory length. -/
theorem futureSumBound (g : Glass n) (hm : 0<g.bonds.card) {x u : ℝ} (hx : 0<x) (x₁ : x≤1)
    (hu : 0<u) (u₁ : u≤1) (f : Config g.bonds → ℝ) (hf : expected (law g x u) f=0)
    (r₁ : rate g.bonds.card x u ≤ 1) (k : ℕ) :
    let p := law g x u
    let K := kernel g x u
    let r := rate g.bonds.card x u
    r^2*expected p (fun a => (futureSum K f k a)^2) ≤ 4*expected p (fun a => f a^2) := by
  intro p K r
  let V := expected p (fun a => f a^2)
  have rp : 0≤r := by dsimp [r,rate]; positivity
  have pp a : 0≤p a := ((lawProbability g hx hu).1 a).le
  have vp : 0≤V := Finset.sum_nonneg fun a _ => mul_nonneg (pp a) (sq_nonneg _)
  induction k with
  | zero => change r^2*expected p (fun _ => (0:ℝ)^2) ≤ 4*V
            simpa [expected] using (show 0≤4*V by positivity)
  | succ k ih =>
    let b a := expected (K a) (futureSum K f k)
    have contract := contraction g hm hx x₁ hu u₁ _ (futureCentered g hx hu f hf k)
    have cb : r^2*expected p (fun a => b a^2) ≤ (1-r)*(4*V) := calc
      _ ≤ r^2*((1-r)*expected p (fun a => (futureSum K f k a)^2)) :=
        mul_le_mul_of_nonneg_left contract (sq_nonneg r)
      _ = (1-r)*(r^2*expected p (fun a => (futureSum K f k a)^2)) := by ring
      _ ≤ _ := mul_le_mul_of_nonneg_left ih (sub_nonneg.mpr r₁)
    calc _ = expected p (fun a => r^2 * (f a + b a)^2) := (expectedScale ..).symm
         _ ≤ expected p (fun a => (r^2+2*r)*(f a)^2 + (1+r/2)*(r^2*(b a)^2)) := by
           apply expectedMono p pp
           intro a
           nlinarith only [mul_nonneg rp (sq_nonneg (2*f a-r*b a))]
         _ = (r^2+2*r)*V+(1+r/2)*(r^2*expected p (fun a => b a^2)) := by
           rw [expectationLinear,expectedScale]
         _ ≤ _ := by
           have := mul_le_mul_of_nonneg_left cb (by linarith : 0≤1+r/2)
           nlinarith only [this,mul_nonneg (sq_nonneg r) vp]

/-- The second moment of a stationary length-k sum grows at most linearly in
k, with factor six times the inverse relaxation rate. -/
theorem futureVariance (g : Glass n) (hm : 0<g.bonds.card) {x u : ℝ} (hx : 0<x) (x₁ : x≤1)
    (hu : 0<u) (u₁ : u≤1) (f : Config g.bonds → ℝ) (hf : expected (law g x u) f=0)
    (r₁ : rate g.bonds.card x u ≤ 1) (k : ℕ) :
    let p := law g x u
    let K := kernel g x u
    let r := rate g.bonds.card x u
    r * expected p (futureSquare K f k) ≤ 6*k*expected p (fun a => f a^2) := by
  intro p K r
  let V := expected p (fun a => f a^2)
  have rp : 0≤r := by dsimp [r,rate]; positivity
  have pp a : 0≤p a := ((lawProbability g hx hu).1 a).le
  have vp : 0≤V := Finset.sum_nonneg fun a _ => mul_nonneg (pp a) (sq_nonneg _)
  induction k with
  | zero => simp [futureSquare,expected]
  | succ k ih =>
    let b a := expected (K a) (futureSum K f k)
    let h a := expected (K a) (futureSquare K f k)
    have co := contraction g hm hx x₁ hu u₁ _ (futureCentered g hx hu f hf k)
    have sq : 0 ≤ expected p (fun a => (futureSum K f k a)^2) :=
      Finset.sum_nonneg fun a _ => mul_nonneg (pp a) (sq_nonneg _)
    have cb : r^2 * expected p (fun a => b a^2) ≤ 4*V :=
      (mul_le_mul_of_nonneg_left (co.trans (by nlinarith only [mul_nonneg rp sq])) (sq_nonneg r)).trans
        (futureSumBound g hm hx x₁ hu u₁ f hf r₁ k)
    have sh : expected p h = expected p (futureSquare K f k) := stationaryMean g hx hu _
    calc _ = expected p (fun a => r*(f a^2+2*f a*b a+h a)) := (expectedScale ..).symm
         _ ≤ expected p (fun a => 1*((r+1)*f a^2+r^2*b a^2)+r*h a) := by
           apply expectedMono p pp
           intro a
           nlinarith only [sq_nonneg (f a-r*b a)]
         _ = (r+1)*V+r^2*expected p (fun a => b a^2)+r*expected p (futureSquare K f k) := by
           rw [expectationLinear,expectationLinear,one_mul,sh]
         _ ≤ _ := by
           push_cast
           nlinarith only [ih,cb,mul_nonneg (sub_nonneg.mpr r₁) vp]

/-- Mean-square error of one bounded readout averaged on consecutive steps after
a warm start at unhalved L¹ distance at most η from the stationary law. -/
theorem trajectoryError (g : Glass n) (hm : 0<g.bonds.card) {x u : ℝ} (hx : 0<x) (x₁ : x≤1)
    (hu : 0<u) (u₁ : u≤1) (q f : Config g.bonds → ℝ)
    {L η : ℝ} (bounds : ∀a, 0≤f a ∧ f a≤L)
    (dist : (∑ a, |q a-law g x u a|) ≤ η)
    (r₁ : rate g.bonds.card x u ≤ 1) {k : ℕ} (hk : 0<k) :
    let p := law g x u
    let K := kernel g x u
    let r := rate g.bonds.card x u
    expected (trajectory K k q) (fun ω => (empirical f ω - expected p f)^2) ≤
      L^2*(6/(k*r)+η) := by
  intro p K r
  let μ := expected p f
  let c a := f a-μ
  let F := fun ω : Fin k → Config g.bonds => (empirical f ω-μ)^2
  have lawP := lawProbability g hx hu
  have hp (a) : 0≤p a := (lawP.1 a).le
  have one : ∑ a, p a = 1 := lawP.2
  have avg : expected p c=0 := by
    simp only [expected,c,μ,mul_sub,Finset.sum_sub_distrib,← Finset.sum_mul,one,one_mul,sub_self]
  have mb := expectedBounds p f hp lawP.2 bounds
  have center {z : ℝ} (hz : 0≤z ∧ z≤L) : (z-μ)^2 ≤ L^2 := by
    apply sq_le_sq' <;> dsimp only [μ] <;> linarith [hz.1,hz.2]
  have vb : expected p (fun a => c a^2) ≤ L^2 :=
    (expectedBounds p _ hp lawP.2 (fun a => ⟨sq_nonneg _,center (bounds a)⟩)).2
  have kr : (0:ℝ)<k := by exact_mod_cast hk
  have mr : (0:ℝ)<g.bonds.card := by exact_mod_cast hm
  have rp : 0<r := by dsimp [r,rate]; positivity
  have eq (ω : Fin k → Config g.bonds) : empirical f ω-μ = (∑ i, c (ω i))/(k:ℝ) := by
    simp [empirical,c,Finset.sum_sub_distrib]
    field_simp
  have range (ω : Fin k → Config g.bonds) : 0≤F ω ∧ F ω≤L^2 := by
    refine ⟨sq_nonneg _,center ⟨div_nonneg (Finset.sum_nonneg fun i _ => (bounds (ω i)).1) kr.le,?_⟩⟩
    apply (div_le_iff₀ kr).mpr
    calc _ ≤ ∑ _ : Fin k, L := Finset.sum_le_sum fun i _ => (bounds (ω i)).2
         _ = _ := by simp [mul_comm]
  have mom := trajectoryMoment K (fun a => (kernelProbability g hx hu a).2) p c lawP.2 k 0
  simp only [zero_add,zero_pow (by decide : 2 ≠ 0),mul_zero,zero_mul] at mom
  have moment : expected (trajectory K k p) F = expected p (futureSquare K c k)/(k:ℝ)^2 := calc
    _ = expected (trajectory K k p) (fun ω => (∑ i, c (ω i))^2)/(k:ℝ)^2 := by
      unfold expected
      rw [Finset.sum_div]
      apply Finset.sum_congr rfl
      intro ω _
      dsimp only [F]
      rw [eq ω,div_pow,mul_div_assoc]
    _ = _ := by rw [mom]
  have var := futureVariance g hm hx x₁ hu u₁ c avg r₁ k
  have stat : expected (trajectory K k p) F ≤ L^2*(6/(k*r)) := by
    rw [moment]
    apply (div_le_iff₀ (sq_pos_of_pos kr)).mpr
    have a : r * expected p (futureSquare K c k) ≤ 6*k*L^2 :=
      var.trans (mul_le_mul_of_nonneg_left vb (by positivity))
    field_simp
    nlinarith only [a]
  have drift := (initialDrift K (kernelProbability g hx hu) q p hk F range).trans
    (mul_le_mul_of_nonneg_right dist (sq_nonneg L))
  change expected (trajectory K k q) F ≤ _
  linarith [le_abs_self (expected (trajectory K k q) F-expected (trajectory K k p) F)]

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
