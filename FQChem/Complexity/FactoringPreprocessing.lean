module

public import Mathlib.Data.Nat.Log
public import Mathlib.Data.Nat.Factorization.PrimePow
public import Mathlib.Algebra.Ring.Parity
import Mathlib.Tactic

/-!
# Classical preprocessing for Shor's factoring algorithm

An even composite has the divisor 2. For perfect powers, examine exponents
between 2 and the bit length and construct each possible integer root by binary
search. The return value tracks power tests, including the final equality test
for each candidate exponent.
-/

@[expose] public section
namespace FQChem.Complexity.FactoringReduction

/-- Fill the next `b` binary digits of a root candidate, starting from `lo`.
The second component counts power comparisons. -/
def rootBits (N e : ℕ) : ℕ → ℕ → ℕ × ℕ
  | 0, lo => (lo, 0)
  | b + 1, lo =>
    let mid := lo + 2 ^ b
    let next := rootBits N e b (if mid ^ e ≤ N then mid else lo)
    (next.1, next.2 + 1)

theorem rootBits_tests (N e b lo : ℕ) : (rootBits N e b lo).2 = b := by
  induction b generalizing lo with
  | zero => rfl
  | succ b ih => simp [rootBits, ih]

private theorem rootBits_exact {a e : ℕ} (he : 0 < e) (b lo : ℕ)
    (hl : lo ≤ a) (hu : a < lo + 2 ^ b) : (rootBits (a ^ e) e b lo).1 = a := by
  induction b generalizing lo with
  | zero => simp [rootBits]; simp at hu; omega
  | succ b ih =>
    simp only [rootBits, Nat.pow_le_pow_iff_left he.ne', pow_succ] at *
    split
    next h => apply ih <;> omega
    next h => apply ih <;> omega

/-- Search exponents `j+1, ..., 2`, stopping at the first exact power.
Each candidate root uses `bits` comparisons, followed by its equality test. -/
def scanPowers (N bits : ℕ) : ℕ → Option ℕ × ℕ
  | 0 => (none, 0)
  | j + 1 =>
    let root := rootBits N (j + 2) bits 0
    if 1 < root.1 ∧ root.1 < N ∧ root.1 ^ (j+2) = N then
      (some root.1, root.2 + 1)
    else
      let next := scanPowers N bits j
      (next.1, next.2 + root.2 + 1)

private theorem scanPowers_sound {N bits j d : ℕ} (hd : (scanPowers N bits j).1 = some d) :
    1 < d ∧ d < N ∧ d ∣ N := by
  induction j with
  | zero => simp [scanPowers] at hd
  | succ j ih =>
    simp only [scanPowers] at hd
    split at hd
    next ht =>
      cases hd
      refine ⟨ht.1, ht.2.1, ?_⟩
      exact (dvd_pow_self (rootBits N (j + 2) bits 0).1 (by omega : j + 2 ≠ 0)).trans
        (dvd_of_eq ht.2.2)
    next => exact ih hd

private theorem scanPowers_complete {a e : ℕ} (ha : 1 < a) (he : 2 ≤ e)
    (bits j : ℕ) (hb : a < 2 ^ bits) (hj : e ≤ j + 1) :
    (scanPowers (a ^ e) bits j).1 ≠ none := by
  induction j with
  | zero => omega
  | succ j ih =>
    simp only [scanPowers]
    split
    next => simp
    next ht =>
      apply ih
      by_contra! h
      obtain rfl : e = j + 2 := by omega
      have hr := rootBits_exact (a := a) (e := j + 2) (by omega) bits 0 (by omega) (by simpa using hb)
      apply ht
      rw [hr]
      exact ⟨ha, lt_self_pow₀ ha (by omega), rfl⟩

private theorem scanPowers_tests (N bits j : ℕ) :
    (scanPowers N bits j).2 ≤ j * (bits + 1) := by
  induction j with
  | zero => simp [scanPowers]
  | succ j ih =>
    simp only [scanPowers]
    split <;> simp [rootBits_tests, Nat.succ_mul]
    omega

/-- Handle even inputs and perfect powers before calling order finding. The
second component records the number of power comparisons. -/
def preprocess (N : ℕ) : Option ℕ × ℕ :=
  if N % 2 = 0 ∧ 2 < N then (some 2, 0)
  else scanPowers N (N.log2 + 1) (N.log2 - 1)

theorem preprocess_sound {N d : ℕ} (hd : (preprocess N).1 = some d) :
    1 < d ∧ d < N ∧ d ∣ N := by
  unfold preprocess at hd
  split at hd
  next h =>
    cases hd
    exact ⟨by decide, h.2, Nat.dvd_of_mod_eq_zero h.1⟩
  next => exact scanPowers_sound hd

theorem preprocess_even {N : ℕ} (h : Even N) (hN : 2 < N) : (preprocess N).1 = some 2 := by
  simp [preprocess, Nat.mod_eq_zero_of_dvd h.two_dvd, hN]

theorem preprocess_power {a e : ℕ} (ha : 1 < a) (he : 2 ≤ e) :
    (preprocess (a ^ e)).1 ≠ none := by
  unfold preprocess
  split
  next => simp
  next =>
    have hn := pow_pos (by omega : 0 < a) e
    have he' : e ≤ (a ^ e).log2 :=
      (Nat.le_log2 hn.ne').mpr (Nat.pow_le_pow_left (by omega) e)
    apply scanPowers_complete ha he
    · have haN := Nat.le_self_pow (by omega : e ≠ 0) a
      exact haN.trans_lt ((Nat.log2_lt hn.ne').mp (Nat.lt_succ_self _))
    · omega

/-- At most (b−2)(b+1) power comparisons at input bit width b = 1+floor(log₂ N). -/
theorem preprocess_tests (N : ℕ) :
    (preprocess N).2 ≤ (N.log2 - 1) * (N.log2 + 2) := by
  unfold preprocess
  split
  next => simp
  next => exact scanPowers_tests _ _ _

/-- Any composite input left by preprocessing is odd and has at least two
distinct prime factors, as required for Shor's random-base reduction. -/
theorem preprocess_miss {N : ℕ} (hN : 1 < N) (hcomp : ¬N.Prime)
    (hm : (preprocess N).1 = none) : Odd N ∧ 2 ≤ N.primeFactors.card := by
  have h2 : 2 < N := by
    have hn : N ≠ 2 := fun h => hcomp (h ▸ Nat.prime_two)
    omega
  constructor
  · rw [← Nat.not_even_iff_odd]
    intro he
    rw [preprocess_even he h2] at hm
    contradiction
  · apply Finset.one_lt_card_iff_nontrivial.mpr
    apply (Nat.not_isPrimePow_iff_nontrivial_of_two_le hN).mp
    intro h
    obtain ⟨p, e, hp, he, hpN⟩ := (isPrimePow_nat_iff _).mp h
    have he2 : 2 ≤ e := by
      by_contra! hh
      have : e = 1 := by omega
      simp [this] at hpN
      exact hcomp (hpN ▸ hp)
    exact preprocess_power hp.one_lt he2 (hpN ▸ hm)

/-- Every power tested along the binary root search fits in a fixed
binary width. Both recursive branches preserve the interval invariant. -/
def rootTestsFit (N e width : ℕ) : ℕ → ℕ → Prop
  | 0, _ => True
  | b + 1, lo =>
    let mid := lo + 2 ^ b
    mid ^ e < 2 ^ width ∧ rootTestsFit N e width b (if mid ^ e ≤ N then mid else lo)

private theorem rootTestsFit_width (N e bits b lo : ℕ) (he : 0 < e)
    (h : lo + 2 ^ b ≤ 2 ^ bits) : rootTestsFit N e (bits * e) b lo := by
  induction b generalizing lo with
  | zero => trivial
  | succ b ih =>
    rw [pow_succ] at h
    have hpow := Nat.two_pow_pos b
    constructor
    · rw [pow_mul]
      exact (Nat.pow_lt_pow_iff_left he.ne').mpr (by omega)
    · apply ih
      split <;> omega

/-- At bit width L the intermediate powers in every candidate root search
use at most L² bits for every tested exponent e ≤ floor(log₂ N). -/
theorem preprocessingPowerWidth {N e : ℕ} (he : 0 < e) (hmax : e ≤ N.log2) :
    rootTestsFit N e ((N.log2 + 1) * e) (N.log2 + 1) 0 ∧
    (N.log2 + 1) * e ≤ (N.log2 + 1) ^ 2 := by
  refine ⟨rootTestsFit_width _ _ _ _ _ he (by simp), ?_⟩
  rw [pow_two]
  exact Nat.mul_le_mul_left _ (by omega)

end FQChem.Complexity.FactoringReduction
