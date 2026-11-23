module

public import FormalQChem.StatePrep.AdiabaticPreparation.RydbergBlockade.Theorems
import Mathlib.Tactic

public section
namespace FormalQChem.Algorithms

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
