module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticImportance
import Mathlib.Tactic

/-! # Finite independent batches for the subgraph mean-energy estimator

The calculation below uses the actual product probability mass function of the
draws. Its bias term explicitly allows each independent chain run to produce a
distribution close to the desired stationary subgraph law.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
variable {α : Type*} [Fintype α]

def expected (p f : α → ℝ) := ∑ a, p a*f a

def batches (p : α → ℝ) {k : ℕ} (ω : Fin k → α) := ∏ i, p (ω i)

def empirical {k} (f : α → ℝ) (ω : Fin k → α) := (∑ i, f (ω i))/(k:ℝ)

private theorem batchSucc (p : α → ℝ) (k : ℕ) (F : (Fin (k+1) → α) → ℝ) :
    expected (batches p) F = ∑ a, p a * expected (batches p) (fun ω => F (Fin.cons a ω)) := by
  unfold expected
  rw [← Equiv.sum_comp (Fin.consEquiv (fun _ : Fin (k+1) => α)),Fintype.sum_prod_type]
  simp [batches,Fin.prod_univ_succ,Fin.consEquiv,Finset.mul_sum,mul_assoc]

private theorem batchNormalized (p : α → ℝ) (hp : ∑ a, p a = 1) (k : ℕ) :
    ∑ ω : Fin k → α, batches p ω = 1 := by
  change (∑ ω : Fin k → α, ∏ i, p (ω i)) = 1
  rw [← Fintype.prod_sum (fun (_ : Fin k) (a : α) => p a)]
  simp [hp]

theorem expectationLinear (p f g : α → ℝ) (a b : ℝ) :
    expected p (fun x => a*f x+b*g x) = a*expected p f+b*expected p g := by
  simp [expected, mul_add,Finset.mul_sum,Finset.sum_add_distrib, mul_left_comm]

private theorem secondMoment (p f : α → ℝ) (hp : ∑ a, p a = 1) (hf : expected p f = 0)
    (k : ℕ) (d : ℝ) :
    expected (batches p) (fun ω : Fin k → α => (d + ∑ i, f (ω i))^2) =
      d^2 + k * expected p (fun a => (f a)^2) := by
  induction k generalizing d with
  | zero => simp [expected,batches]
  | succ k ih =>
    rw [batchSucc]
    simp only [Fin.sum_univ_succ,Fin.cons_zero,Fin.cons_succ,← add_assoc,ih]
    let v := expected p (fun a => f a^2)
    change (∑ a, p a*((d+f a)^2+k*v)) = d^2 + ↑(k+1)*v
    calc (∑ a, p a*((d+f a)^2+k*v)) =
           ∑ a, (p a*(d^2+k*v) + (2*d)*(p a*f a) + p a*f a^2) :=
           Finset.sum_congr rfl fun _ _ => by ring
         _ = _ := by
           simp only [Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.mul_sum, hp,one_mul]
           change _ + 2*d*expected p f + v = _
           rw [hf]; push_cast; ring

theorem expectedBounds (p f : α → ℝ) (hp : ∀ a, 0 ≤ p a) (one : ∑ a, p a = 1)
    {L : ℝ} (bound : ∀ a, 0 ≤ f a ∧ f a ≤ L) : 0 ≤ expected p f ∧ expected p f ≤ L := by
  constructor
  · exact Finset.sum_nonneg fun a _ => mul_nonneg (hp a) (bound a).1
  · calc expected p f ≤ ∑ a, p a*L := Finset.sum_le_sum fun a _ => mul_le_mul_of_nonneg_left (bound a).2 (hp a)
         _ = L := by rw [← Finset.sum_mul,one,one_mul]

theorem expectedDrift (p q f : α → ℝ) {L : ℝ} (bound : ∀ a, 0 ≤ f a ∧ f a ≤ L) :
    |expected q f-expected p f| ≤ (∑ a, |q a-p a|)*L := by
  unfold expected
  rw [← Finset.sum_sub_distrib,Finset.sum_mul]
  refine (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum fun a _ => ?_)
  rw [← sub_mul,abs_mul,abs_of_nonneg (bound a).1]
  exact mul_le_mul_of_nonneg_left (bound a).2 (abs_nonneg _)

private theorem empiricalVariance (p f : α → ℝ) (hp : ∀ a, 0≤p a) (one : ∑ a, p a=1)
    {L : ℝ} (bounds : ∀ a, 0≤f a ∧ f a≤L) {k : ℕ} (hk : 0<k) :
    expected (batches p) (fun ω : Fin k → α => (empirical f ω - expected p f)^2) ≤ L^2/k := by
  let m := expected p f
  let centered := fun a => f a-m
  have avg : expected p centered = 0 := by
    simp [expected,centered,m,mul_sub,Finset.sum_sub_distrib,← Finset.sum_mul,one]
  have h := secondMoment p centered one avg k 0
  simp only [zero_add,zero_pow (by decide : 2 ≠ 0)] at h
  have kr : (0:ℝ)<k := by exact_mod_cast hk
  have eq (ω : Fin k → α) : empirical f ω-m = (∑ i, centered (ω i))/(k:ℝ) := by
    simp [empirical,centered,Finset.sum_sub_distrib]
    field_simp
  have vb : expected p (fun a => centered a^2) ≤ L^2 := by
    apply (expectedBounds p _ hp one _).2
    intro a
    have b := expectedBounds p f hp one bounds
    change 0 ≤ (f a-m)^2 ∧ (f a-m)^2 ≤ L^2
    refine ⟨sq_nonneg _,?_⟩
    apply sq_le_sq' <;> dsimp only [m] <;> linarith [(bounds a).1,(bounds a).2]
  calc expected (batches p) (fun ω : Fin k → α => (empirical f ω-m)^2) =
         expected (batches p) (fun ω : Fin k → α => (∑ i, centered (ω i))^2)/(k:ℝ)^2 := by
         unfold expected
         rw [Finset.sum_div]
         apply Finset.sum_congr rfl
         intro ω _
         dsimp only; rw [eq ω,div_pow,mul_div_assoc]
       _ = expected p (fun a => centered a^2)/k := by rw [h]; field_simp
       _ ≤ _ := div_le_div_of_nonneg_right vb kr.le

/-- Mean-square error about the true expectation from k independent draws of an
approximate distribution, in terms of its unhalved L¹ distance and readout range. -/
theorem batchError (p q f : α → ℝ) (hq : ∀ a, 0≤q a) (one : ∑ a, q a=1)
    {L η : ℝ} (hL : 0≤L) (bounds : ∀ a, 0≤f a ∧ f a≤L)
    (distance : (∑ a, |q a-p a|) ≤ η) {k : ℕ} (hk : 0 < k) :
    expected (batches q) (fun ω : Fin k → α => (empirical f ω-expected p f)^2) ≤
      2*L^2*((k:ℝ)⁻¹+η^2) := by
  let d := expected q f-expected p f
  have drift : |d| ≤ η*L := (expectedDrift p q f bounds).trans (mul_le_mul_of_nonneg_right distance hL)
  have ds : d^2 ≤ (η*L)^2 := by simpa using pow_le_pow_left₀ (abs_nonneg d) drift 2
  have mono : expected (batches q) (fun ω : Fin k → α => (empirical f ω-expected p f)^2) ≤
      expected (batches q) (fun ω : Fin k → α => 2*(empirical f ω-expected q f)^2+2*d^2) := by
    apply Finset.sum_le_sum
    intro ω _
    apply mul_le_mul_of_nonneg_left _ (Finset.prod_nonneg fun i _ => hq (ω i))
    dsimp [d]; nlinarith [sq_nonneg (empirical f ω-expected q f-(expected q f-expected p f))]
  apply mono.trans
  rw [expectationLinear]
  have c : expected (batches q) (fun _ : Fin k → α => d^2) = d^2 := by
    simp [expected,← Finset.sum_mul,batchNormalized q one]
  rw [c]
  have var := empiricalVariance q f hq one bounds hk
  rw [div_eq_mul_inv] at var
  nlinarith

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
