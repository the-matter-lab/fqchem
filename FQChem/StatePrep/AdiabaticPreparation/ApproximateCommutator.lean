module

public import FQChem.StatePrep.AdiabaticPreparation.AdiabaticTheorem
public import Mathlib.Topology.UnitInterval
public import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Tactic

/-! # Adiabatic transport by local approximate commutators

A constant commutator solution on a short interval incurs a residual times the
interval length and a boundary error of order 1/T. Compactness permits a finite
partition before the runtime is chosen. This form of the argument needs no
differentiable choice of approximate solutions.
-/

@[expose] public section
namespace FQChem.StatePrep.AdiabaticPreparation

open Set
variable {R : Type*} [NormedRing R] [NormedAlgebra ℝ R]

private theorem interval_defect {A P P' U V : ℝ → R} {T : ℝ}
    (ev : SlowEvolution A T U V) (hc : ∀ s ∈ Icc (0:ℝ) 1, Commute (A s) (P s))
    (hP : ∀ s ∈ Icc (0:ℝ) 1, HasDerivAt P (P' s) s)
    {a b δ : ℝ} (ha : 0 ≤ a) (hab : a ≤ b) (hb : b ≤ 1) (X : R)
    (small : ∀ s ∈ Icc a b, ‖P' s - (A s * X - X * A s)‖ ≤ δ) :
    ‖V b * P b * U b - V a * P a * U a‖ ≤ δ * (b-a) + 2 * ‖X‖ / T := by
  let moved (F : ℝ → R) (s : ℝ) := V s * F s * U s
  let Y (s : ℝ) := T • moved P s + V s * X * U s
  have hI : Icc a b ⊆ Icc 0 1 := Icc_subset_Icc ha hb
  have deriv (s : ℝ) (hs : s ∈ Icc a b) : HasDerivAt Y
      (T • (V s * (P' s - (A s * X - X * A s)) * U s)) s := by
    have dp := transportedDerivative ev (hI hs) (hP s (hI hs))
    have dx := transportedDerivative ev (hI hs) (hasDerivAt_const s X)
    rw [(hc s (hI hs)).eq, sub_self, smul_zero, sub_zero] at dp
    convert (dp.const_smul T).fun_add dx using 1
    simp only [sub_mul, mul_sub, mul_smul_comm, smul_mul_assoc, zero_sub, mul_neg, neg_mul]
    module
  have change_bound := norm_image_sub_le_of_norm_deriv_le_segment'
    (fun s hs => (deriv s hs).hasDerivWithinAt)
    (C := T * δ) (fun s hs => by
      have hi := hI (Ico_subset_Icc_self hs)
      rw [norm_smul, Real.norm_of_nonneg ev.positive.le]
      exact mul_le_mul_of_nonneg_left ((sandwichBound (ev.backward_norm s hi)
        (ev.forward_norm s hi)).trans (small s (Ico_subset_Icc_self hs))) ev.positive.le)
    b (right_mem_Icc.mpr hab)
  have hsa := hI (left_mem_Icc.mpr hab)
  have hsb := hI (right_mem_Icc.mpr hab)
  have estimate : T * ‖moved P b - moved P a‖ ≤ T * δ * (b-a) + 2 * ‖X‖ := calc
    _ = ‖(Y b - Y a) - (V b * X * U b) + (V a * X * U a)‖ := by
      rw [← Real.norm_of_nonneg ev.positive.le, ← norm_smul, smul_sub]
      congr 1; dsimp [Y]; abel
    _ ≤ ‖Y b - Y a‖ + ‖V b * X * U b‖ + ‖V a * X * U a‖ :=
      (norm_add_le ..).trans (add_le_add (norm_sub_le ..) le_rfl)
    _ ≤ _ := by linarith [sandwichBound (x := X) (ev.backward_norm a hsa) (ev.forward_norm a hsa),
                           sandwichBound (x := X) (ev.backward_norm b hsb) (ev.forward_norm b hsb)]
  change ‖moved P b - moved P a‖ ≤ _
  rw [← sub_le_iff_le_add', le_div_iff₀ ev.positive]
  linarith only [estimate]

/-- Uniform small leakage follows from pointwise norm approximation of the
projection derivative by commutators and continuity on the time interval. -/
theorem approximateCommutatorTransport (A P P' : ℝ → R)
    (hA : ContinuousOn A (Icc 0 1)) (hd : ContinuousOn P' (Icc 0 1))
    (hc : ∀ s ∈ Icc (0:ℝ) 1, Commute (A s) (P s))
    (hP : ∀ s ∈ Icc (0:ℝ) 1, HasDerivAt P (P' s) s)
    (approx : ∀ s ∈ Icc (0:ℝ) 1, ∀ δ > 0, ∃ X, ‖P' s - (A s * X - X * A s)‖ < δ) :
    ∀ ε > 0, ∃ T₀ : ℝ, ∀ T ≥ T₀, ∀ U V, SlowEvolution A T U V →
      ∀ s ∈ Icc (0:ℝ) 1, ‖P s * U s - U s * P 0‖ < ε := by
  intro ε hε
  let δ := ε / 2
  let cover (X : R) := {t : unitInterval | ‖P' t - (A t * X - X * A t)‖ < δ}
  have opened (X : R) : IsOpen (cover X) :=
    isOpen_lt ((hd.comp_continuous continuous_subtype_val Subtype.property).sub
      (((hA.comp_continuous continuous_subtype_val Subtype.property).mul continuous_const).sub
       (continuous_const.mul (hA.comp_continuous continuous_subtype_val Subtype.property)))).norm
      continuous_const
  have allCovered : univ ⊆ ⋃ X, cover X := by
    intro s _; obtain ⟨X, hX⟩ := approx s s.property δ (half_pos hε)
    exact mem_iUnion.mpr ⟨X, hX⟩
  obtain ⟨t, start, mono, ⟨M, stop⟩, pieces⟩ :=
    exists_monotone_Icc_subset_open_cover_unitInterval opened allCovered
  choose X good using pieces
  let cost := ∑ j ∈ Finset.range M, 2 * ‖X j‖
  refine ⟨(cost + 1) / δ, ?_⟩
  intro T hT U V ev s hs
  let point (j : ℕ) := min (t j : ℝ) s
  let moved (r : ℝ) := V r * P r * U r
  have hm (j : ℕ) : point j ≤ point (j+1) := min_le_min_right s (mono (Nat.le_succ j))
  have localBound (j : ℕ) : ‖moved (point (j+1)) - moved (point j)‖ ≤
      δ * (point (j+1) - point j) + 2 * ‖X j‖ / T := by
    by_cases left : s ≤ (t j : ℝ)
    · have right : s ≤ (t (j+1) : ℝ) := left.trans (mono (Nat.le_succ j))
      simp only [point, min_eq_right left, min_eq_right right, sub_self, norm_zero, mul_zero, zero_add]
      exact div_nonneg (by positivity) ev.positive.le
    · apply interval_defect ev hc hP (le_min (t j).property.1 hs.1) (hm j)
        ((min_le_right _ _).trans hs.2) (X j)
      intro v hv
      have lo : (t j : ℝ) ≤ v := by simpa [point, min_eq_left (le_of_not_ge left)] using hv.1
      have hi : v ≤ (t (j+1) : ℝ) := hv.2.trans (min_le_left _ _)
      exact (good j (show (⟨v, (t j).property.1.trans lo, hi.trans (t (j+1)).property.2⟩ : unitInterval) ∈
          Icc (t j) (t (j+1)) from ⟨lo, hi⟩)).le
  have sumBound (k : ℕ) : ‖moved (point k) - moved 0‖ ≤
      δ * point k + (∑ j ∈ Finset.range k, 2 * ‖X j‖) / T := by
    induction k with
    | zero => simp [point, start, min_eq_left hs.1]
    | succ k ih =>
      calc _ ≤ ‖moved (point (k+1)) - moved (point k)‖ + ‖moved (point k) - moved 0‖ :=
                norm_sub_le_norm_sub_add_norm_sub ..
           _ ≤ _ := by rw [Finset.sum_range_succ, add_div]; linarith [localBound k]
  have endpt : point M = s := by simp [point, stop M le_rfl, min_eq_right hs.2]
  have bound := sumBound M
  rw [endpt] at bound
  have h0 : moved 0 = P 0 := by simp [moved, ev.forward_initial, ev.backward_initial]
  rw [h0] at bound
  have factor : P s * U s - U s * P 0 = U s * (moved s - P 0) := by
    simp only [moved, mul_sub, ← mul_assoc, ev.inverse_right s hs, one_mul]
  have leak : ‖P s * U s - U s * P 0‖ ≤ ‖moved s - P 0‖ := by
    rw [factor]
    apply (norm_mul_le ..).trans
    simpa using mul_le_mul_of_nonneg_right (ev.forward_norm s hs) (norm_nonneg (moved s - P 0))
  have cost_lt : cost / T < δ := (div_lt_iff₀ ev.positive).mpr (by
    have : cost + 1 ≤ T * δ := (div_le_iff₀ (half_pos hε)).mp hT
    linarith only [this])
  change ‖moved s - P 0‖ ≤ δ * s + cost / T at bound
  have small : δ * s ≤ δ := mul_le_of_le_one_right (half_pos hε).le hs.2
  linarith only [small, bound, cost_lt, leak, show 2 * δ = ε by dsimp [δ]; ring]

end FQChem.StatePrep.AdiabaticPreparation
