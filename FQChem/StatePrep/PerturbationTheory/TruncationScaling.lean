module

public import Mathlib.Data.Nat.Basic
import Mathlib.Tactic

/-! # Dependence on system size and truncation accuracy

Lee et al. motivate a uniform polynomial cost in system size and inverse
accuracy on a single-reference class. A cost that is polynomial in size at
each fixed rank, even with geometric convergence in rank, need not obey
that joint bound. This abstract example concerns scaling assumptions alone.
[Lee et al. (2023)](https://doi.org/10.1038/s41467-023-37587-6). -/

@[expose] public section
namespace FQChem.StatePrep.TruncationScaling

/-- An abstract hierarchy has inverse error `2^k` and work `L^k` at rank `k`.
For any proposed polynomial prefactor and exponents there is a system size
and inverse accuracy for which every sufficiently accurate rank costs more.
Both parameters can be made arbitrarily large. -/
theorem fixedRankBoundsDoNotGiveJointPolynomial (C a b threshold : ℕ) :
    ∃ L E : ℕ, threshold ≤ L ∧ threshold ≤ E ∧
      ∀ k : ℕ, E ≤ 2^k → C * L^a * E^b < L^k := by
  let m := C + a + b + threshold + 1
  have big : C < 2^m := (show C ≤ m by dsimp [m]; omega).trans_lt Nat.lt_two_pow_self
  have scale : threshold ≤ 2^m := (show threshold ≤ m by dsimp [m]; omega).trans Nat.lt_two_pow_self.le
  refine ⟨2^m, 2^m, scale, scale, ?_⟩
  intro k hk
  have mk : m ≤ k := (Nat.pow_le_pow_iff_right (by decide : 1 < 2)).mp hk
  have deg : 1+a+b ≤ k := by dsimp [m] at mk; omega
  calc
    C * (2^m)^a * (2^m)^b < (2^m) * (2^m)^a * (2^m)^b := by gcongr
    _ = (2^m)^(1+a+b) := by rw [pow_add (2^m) (1+a) b, pow_add (2^m) 1 a, pow_one]
    _ ≤ (2^m)^k := Nat.pow_le_pow_right (by positivity) deg

end FQChem.StatePrep.TruncationScaling
