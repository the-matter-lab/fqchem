module

public import FQChemKitaev.Majority

/-! # Amplification to the history-Hamiltonian energy precision

Each level triples the verification circuit and appends a 45-gate coherent
majority. The completeness target depends on the length of the *amplified*
circuit. A logarithmic number of majority levels suffices while keeping the
total gate and register count polynomial in the original size. -/

@[expose] public section

namespace FQChem.Complexity.Kitaev.AmplificationBounds

/-- Number of majority levels for original size s = gates + wires + 65. -/
def rounds (s : ℕ) : ℕ := 3 + (s.log2 + 6)

/-- Gate and wire recurrences bound the entire padded size after k levels. -/
theorem size_after (T n : ℕ → ℕ) (gates : ∀ j, T (j+1) = 3*T j + 45)
    (wires : ∀ j, n (j+1) = 3*n j + 1) (k : ℕ) :
    T k + n k + 65 ≤ 3^k * (T 0 + n 0 + 65) := by
  induction k with
  | zero => simp
  | succ j ih =>
    rw [gates j, wires j, pow_succ]
    nlinarith only [ih]

/-- At the selected depth, the padded amplified instance has size at most
4⁹ times the cube of the original padded size. -/
theorem polynomial_size {s : ℕ} (hs : 0 < s) : 3^(rounds s)*s ≤ 4^9*s^3 := by
  have base : 2^s.log2 ≤ s := (Nat.le_log2 hs.ne').mp le_rfl
  calc
    3^(rounds s)*s ≤ 4^(rounds s)*s := Nat.mul_le_mul_right _ (Nat.pow_le_pow_left (by decide) _)
    _ = 4^9 * (2^s.log2)^2 * s := by
      rw [show rounds s = 9 + s.log2 by unfold rounds; omega, pow_add]
      have hpow : (4 : ℕ)^s.log2 = (2^s.log2)^2 := by
        rw [show (4 : ℕ) = 2^2 by decide, ← pow_mul, ← pow_mul, Nat.mul_comm]
      rw [hpow]
    _ ≤ 4^9 * s^2 * s := by gcongr
    _ = 4^9 * s^3 := by ring

private theorem budget {s : ℕ} (hs : 0 < s) :
    2^14 * (3^(rounds s) * s)^2 ≤ 2^(2^(s.log2+6)) := by
  let l := s.log2
  have up : s ≤ 2^(l+1) := ((Nat.log2_lt hs.ne').mp (Nat.lt_succ_self l)).le
  have size_le : 3^(rounds s) * s ≤ 2^(3*l+19) := calc
    _ ≤ 4^(rounds s) * 2^(l+1) := Nat.mul_le_mul (Nat.pow_le_pow_left (by decide) _) up
    _ = _ := by
      rw [show (4 : ℕ) = 2^2 by decide, ← pow_mul, ← pow_add]
      congr 1
      unfold rounds l
      omega
  have doubling (j : ℕ) : j+1 ≤ 2^j := by
    induction j with
    | zero => decide
    | succ j ih => rw [pow_succ]; omega
  calc
    2^14 * (3^(rounds s) * s)^2 ≤ 2^14 * (2^(3*l+19))^2 := by gcongr
    _ = 2^(14+(3*l+19)*2) := by rw [← pow_mul, ← pow_add]
    _ ≤ 2^(2^(s.log2+6)) := by
      apply Nat.pow_le_pow_right (by decide : 0 < 2)
      change 14 + (3*l+19)*2 ≤ 2^(l+6)
      rw [pow_add]
      norm_num
      have := doubling l
      omega

/-- Starting at error ≤1/3, the recursively amplified error reaches the
Kitaev completeness tolerance even at the final, larger gate count. Here u
can be taken to be the final gate count plus 65. -/
theorem reaches_precision {p : ℝ} (lo : 0 ≤ p) (hi : p ≤ 1/3) {s u : ℕ}
    (hs : 0 < s) (hu : 0 < u) (growth : u ≤ 3^(rounds s)*s) :
    Majority.repeatedError p (rounds s) ≤ 1/((2 : ℝ)^14 * (u : ℝ)^2) := by
  have sizeBound : 2^14 * u^2 ≤ 2^(2^(s.log2+6)) :=
    (Nat.mul_le_mul_left _ (Nat.pow_le_pow_left growth 2)).trans (budget hs)
  have sizeReal : (2 : ℝ)^14 * (u : ℝ)^2 ≤ 2^(2^(s.log2+6)) := by exact_mod_cast sizeBound
  have estimate := Majority.squared_error_decay p lo hi (s.log2+6)
  rw [one_div_pow] at estimate
  have errorPos := (Majority.error_bound p lo hi (rounds s)).1
  apply le_trans _ (one_div_le_one_div_of_le (by positivity) sizeReal)
  change 3 * Majority.repeatedError p (rounds s) ≤ _ at estimate
  linarith

end FQChem.Complexity.Kitaev.AmplificationBounds
