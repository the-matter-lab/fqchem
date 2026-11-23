module

public import Mathlib.Data.Finset.Card
public import Mathlib.Basic.Real.Basic
import Mathlib.Tactic

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- Number of occupied conflicting pairs in a classical configuration at zero drive. -/
def blockadeViolations {n : ℕ} (edges : Finset (Fin n × Fin n)) (s : Finset (Fin n)) :=
  (edges.filter (fun e => e.1 ∈ s ∧ e.2 ∈ s)).card

/-- Unit-detuning, uniform-penalty energy of an ideal zero-drive Rydberg blockade model. -/
def blockadeEnergy {n : ℕ} (edges : Finset (Fin n × Fin n)) (penalty : ℝ)
    (s : Finset (Fin n)) := penalty * blockadeViolations edges s - s.card

/-- For a penalty exceeding the number of sites, the ground configurations of the
blockade energy are exactly the maximum independent sets of the interaction graph. -/
def RydbergBlockade (n : ℕ) : Prop :=
  ∀ (edges : Finset (Fin n × Fin n)) (penalty : ℝ), (n : ℝ) < penalty →
    ∀ s, (∀ t, blockadeEnergy edges penalty s ≤ blockadeEnergy edges penalty t) ↔
      blockadeViolations edges s = 0 ∧
        ∀ t, blockadeViolations edges t = 0 → t.card ≤ s.card

theorem rydbergBlockade (n : ℕ) : RydbergBlockade n := by
  intro edges penalty hp s
  have pos {t} (ht : blockadeViolations edges t ≠ 0) : 0 < blockadeEnergy edges penalty t := by
    have hw : (1 : ℝ) ≤ blockadeViolations edges t := by exact_mod_cast Nat.one_le_iff_ne_zero.mpr ht
    have hc : (t.card : ℝ) ≤ n := by exact_mod_cast (Finset.card_le_univ t).trans_eq (Fintype.card_fin n)
    have hp' : 0 ≤ penalty := le_trans (Nat.cast_nonneg n) hp.le
    unfold blockadeEnergy
    nlinarith [mul_le_mul_of_nonneg_left hw hp']
  constructor
  · intro h
    have hempty := h ∅
    have h0 : blockadeViolations edges ∅ = 0 := by simp [blockadeViolations]
    simp only [blockadeEnergy, h0, Nat.cast_zero, mul_zero, Finset.card_empty, sub_zero] at hempty
    have hs : blockadeViolations edges s = 0 := by
      by_contra hne
      exact (pos hne).not_ge hempty
    refine ⟨hs, fun t ht => ?_⟩
    simpa [blockadeEnergy, hs, ht] using h t
  · rintro ⟨hs, hmax⟩ t
    by_cases ht : blockadeViolations edges t = 0
    · simpa [blockadeEnergy, hs, ht] using hmax t ht
    · exact le_trans (by simp [blockadeEnergy, hs]) (pos ht).le

end FormalQChem.Algorithms
