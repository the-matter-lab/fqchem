module

public import Mathlib.NumberTheory.DiophantineApproximation.ContinuedFractions
public import Mathlib.Algebra.ContinuedFractions.Computation.TerminatesIffRat
import Mathlib.Tactic

/-! # Bounded continued-fraction search in Shor's order-finding algorithm

The ordinary Euclidean algorithm on the measured numerator and clock
denominator terminates in at most twice the bit length of the clock.
The very same number of steps suffices for Mathlib's continued fraction.
[Shor (1997), Section 5](https://doi.org/10.1137/S0097539795293172). -/

@[expose] public section
namespace FQChem.Complexity.OrderFindingPostprocessing

/-- Number of quotient/remainder divisions of the Euclidean algorithm. -/
def divisions (a b : ℕ) : ℕ :=
  if hb : b = 0 then 0 else divisions b (a % b) + 1
termination_by b
decreasing_by exact Nat.mod_lt _ (Nat.pos_of_ne_zero hb)

private theorem two_steps_halve {r b : ℕ} (hr : 0 < r) (hrb : r < b) :
    2 * (b % r) ≤ b := by
  by_cases small : 2 * r ≤ b
  · have := Nat.mod_lt b hr; omega
  · have eq : b = (b-r) + r := by omega
    have mod : b % r = b - r := by
      conv_lhs => rw [eq, Nat.add_mod_right, Nat.mod_eq_of_lt (by omega : b-r < r)]
    omega

theorem divisions_bound (k : ℕ) : ∀ a b : ℕ, b < 2 ^ k → divisions a b ≤ 2 * k := by
  induction k with
  | zero =>
    intro a b hb
    have bz : b = 0 := by simpa using hb
    simp [bz, divisions]
  | succ k ih =>
    intro a b hb
    by_cases hzero : b = 0
    · simp [hzero, divisions]
    rw [divisions, dite_eq_right hzero]
    by_cases hr : a % b = 0
    · simp [hr, divisions]
      omega
    have recurse_eq : divisions b (a % b) = divisions (a % b) (b % (a % b)) + 1 := by
      rw [divisions, dite_eq_right hr]
    rw [recurse_eq]
    have small := two_steps_halve (Nat.pos_of_ne_zero hr) (Nat.mod_lt a (Nat.pos_of_ne_zero hzero))
    rw [pow_succ] at hb
    have := ih (a%b) (b%(a%b)) (by omega)
    omega

open GenContFract

private theorem stream_terminates (a b : ℕ) (hb : 0 < b) :
    IntFractPair.stream ((a : ℝ)/b) (divisions a b) = none := by
  rw [divisions, dite_eq_right hb.ne']
  have frac := Int.fract_div_natCast_eq_div_natCast_mod (k := ℝ) (m := a) (n := b)
  by_cases hr : a % b = 0
  · rw [hr, divisions, dite_eq_left rfl, zero_add]
    exact IntFractPair.stream_eq_none_of_fr_eq_zero (IntFractPair.stream_zero _) (by
      change Int.fract ((a:ℝ)/b) = 0; simp [frac, hr])
  · have hfrac : Int.fract ((a : ℝ)/b) ≠ 0 := by rw [frac]; positivity
    rw [IntFractPair.stream_succ hfrac, frac, inv_div]
    exact stream_terminates b (a%b) (Nat.pos_of_ne_zero hr)
termination_by b
decreasing_by exact Nat.mod_lt a hb

/-- A finite, logarithmic scan is complete for the continued fraction of every
measured clock outcome. Each counted Euclidean step acts on integers no
larger than the preceding denominator after its first division. -/
theorem logarithmic_scan (Q o : ℕ) (ho : o < Q) :
    ∃ n < 2 * (Q.log2 + 1) + 1, (GenContFract.of ((o:ℝ)/Q)).TerminatedAt n := by
  have hQ : 0 < Q := by omega
  have width : Q < 2 ^ (Q.log2+1) := Nat.lt_log2_self
  refine ⟨divisions o Q, by have := divisions_bound (Q.log2+1) o Q width; omega, ?_⟩
  apply of_terminatedAt_n_iff_succ_nth_intFractPair_stream_eq_none.mpr
  exact IntFractPair.stream_isSeq _ (stream_terminates o Q hQ)

end FQChem.Complexity.OrderFindingPostprocessing
