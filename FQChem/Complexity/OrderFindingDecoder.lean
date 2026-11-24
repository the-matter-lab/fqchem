module

public import FQChem.Complexity.FactoringReduction
public import Mathlib.NumberTheory.DiophantineApproximation.ContinuedFractions
import Mathlib.Tactic

/-!
# Executable continued-fraction decoding of a measured Fourier register

For outcome o and clock size Q, compute each convergent of o/Q with natural
quotients and remainders, test its denominator by binary modular powering, and
retain the least passing denominator. See Shor (1997), §5 after Eq. (5.13).
-/

@[expose] public section
namespace FQChem.Complexity.OrderFindingDecoder
open FactoringReduction

/-- Numerator, denominator, and number of visited Euclidean quotient levels. -/
structure Approx where
  num : ℕ
  den : ℕ
  levels : ℕ
  deriving Repr

/-- The t-th convergent computed by Euclidean division. At a zero remainder
all subsequent convergents coincide with the current integer. -/
def convergent (a b : ℕ) : ℕ → Approx
  | 0 => ⟨a / b, 1, 1⟩
  | t+1 =>
    if a % b = 0 then ⟨a / b, 1, 1⟩
    else
      let c := convergent b (a % b) t
      ⟨a / b * c.num + c.den, c.num, c.levels + 1⟩

private theorem convergent_invariants (a b t : ℕ) (hb : 0 < b) :
    let c := convergent a b t
    0 < c.den ∧ c.num.Coprime c.den ∧ c.num ≤ a ∧ c.den ≤ b ∧
      (b ≤ a → 0 < c.num) ∧ c.levels ≤ t + 1 := by
  have base (a b t : ℕ) (hb : 0 < b) : 0 < (1 : ℕ) ∧ (a/b).Coprime 1 ∧ a/b ≤ a ∧ 1 ≤ b ∧
      (b ≤ a → 0 < a/b) ∧ 1 ≤ t+1 :=
    ⟨by decide, Nat.coprime_one_right _, Nat.div_le_self .., hb, fun h => Nat.div_pos h hb, by omega⟩
  induction t generalizing a b with
  | zero => exact base _ _ _ hb
  | succ t ih =>
    rw [convergent]
    split
    next => exact base _ _ _ hb
    next hr =>
      have hlt := Nat.mod_lt a hb
      have ⟨hd, hcop, hn, hden, hpos, hc⟩ := ih b (a%b) (Nat.pos_of_ne_zero hr)
      have hu := hpos hlt.le
      have hnum := Nat.add_le_add (Nat.mul_le_mul_left (a / b) hn) hden
      rw [Nat.div_add_mod'] at hnum
      refine ⟨hu, ?_, hnum, hn, fun _ => ?_, Nat.succ_le_succ hc⟩
      · simpa [Nat.add_comm, Nat.coprime_add_mul_right_left] using hcop.symm
      · exact Nat.add_pos_right _ hd

/-- A computed numerator and denominator fit within the supplied integers,
the denominator is positive, and the cost is at most t+1
Euclidean levels. -/
theorem convergent_bounds (a b t : ℕ) (hb : 0 < b) :
    let c := convergent a b t
    c.num ≤ a ∧ c.den ≤ b ∧ 0 < c.den ∧ c.levels ≤ t + 1 := by
  exact ⟨(convergent_invariants a b t hb).2.2.1, (convergent_invariants a b t hb).2.2.2.1,
    (convergent_invariants a b t hb).1, (convergent_invariants a b t hb).2.2.2.2.2⟩

/-- Exact equality with the rational value of Mathlib's real continued-fraction
convergent at every scan depth, including depths past termination. -/
theorem convergent_eq_real (a b t : ℕ) (hb : 0 < b) :
    Real.convergent ((a : ℝ)/b) t = ((convergent a b t).num : ℚ) / (convergent a b t).den := by
  induction t generalizing a b with
  | zero => simp [convergent, Int.floor_div_natCast, ← Int.natCast_ediv]
  | succ t ih =>
    rw [Real.convergent_succ, Int.floor_div_natCast, Int.floor_natCast,
      Int.fract_div_natCast_eq_div_natCast_mod, inv_div]
    rw [convergent]
    split
    next hr => simp [hr, ← Int.natCast_ediv]
    next hr =>
      rw [ih b (a % b) (Nat.pos_of_ne_zero hr)]
      have hu := (convergent_invariants b (a%b) t (Nat.pos_of_ne_zero hr)).2.2.2.2.1 (Nat.mod_lt a hb).le
      have hn : ((convergent b (a % b) t).num : ℚ) ≠ 0 := by exact_mod_cast hu.ne'
      push_cast [← Int.natCast_ediv]
      rw [inv_div]
      field_simp

/-- The computed natural denominator is precisely the normalized denominator
used by the reference order-finding probability statement. -/
theorem denominator_eq_real (a b t : ℕ) (hb : 0 < b) :
    (convergent a b t).den = (Real.convergent ((a : ℝ)/b) t).den := by
  rw [convergent_eq_real a b t hb]
  have hc := convergent_invariants a b t hb
  symm
  apply Int.ofNat_inj.mp
  simpa only [Int.cast_natCast] using Rat.den_div_eq_of_coprime (a := ((convergent a b t).num : ℤ))
    (b := ((convergent a b t).den : ℤ)) (by exact_mod_cast hc.1) (by simpa using hc.2.1)

/-- Decoder output and the work performed by its two arithmetic routines. -/
structure Run where
  order : ℕ
  euclideanLevels : ℕ
  modularMultiplications : ℕ
  deriving Repr

/-- Scan t candidates and return the least denominator that passes the
modular power check. Zero is the sentinel for an empty candidate set. -/
def scan (N a o Q : ℕ) : ℕ → Run
  | 0 => ⟨0, 0, 0⟩
  | t+1 =>
    let prev := scan N a o Q t
    let c := convergent o Q t
    let m := modPowerRun N a c.den
    let best := if m.1 = 1 ∧ 0 < c.den then
      if prev.order = 0 then c.den else min c.den prev.order
      else prev.order
    ⟨best, prev.euclideanLevels + c.levels,
      prev.modularMultiplications + m.2⟩

/-- Mathematical scan used to compare the executable decoder with the
reference probability definition. -/
noncomputable def candidates (N a o Q t : ℕ) : Finset ℕ :=
  ((Finset.range t).image fun i => (Real.convergent ((o : ℝ) / Q) i).den).filter
    fun d => 0 < d ∧ decide (a ^ d % N = 1) = true

def leastOrZero (s : Finset ℕ) := if h : s.Nonempty then s.min' h else 0

theorem least_insert (s : Finset ℕ) (d : ℕ) (hs : ∀ i ∈ s, 0 < i) :
    leastOrZero (insert d s) =
      if leastOrZero s = 0 then d else min d (leastOrZero s) := by
  classical
  by_cases h : s.Nonempty
  · have hm := hs _ (s.min'_mem h)
    simp [leastOrZero, h, hm.ne', Finset.min'_insert]
  · obtain rfl := Finset.not_nonempty_iff_eq_empty.mp h
    simp [leastOrZero]

/-- The executable result equals the least passing denominator among all
the reference real convergents at indices below t, with zero for no match. -/
theorem scan_eq_reference (N a o Q t : ℕ) (hQ : 0 < Q) :
    (scan N a o Q t).order = leastOrZero (candidates N a o Q t) := by
  induction t with
  | zero => simp [scan, candidates, leastOrZero]
  | succ t ih =>
    let d := (convergent o Q t).den
    have heq := denominator_eq_real o Q t hQ
    have hp : (modPowerRun N a d).1 = a ^ d % N := modPower_spec N a d
    have hs : ∀ j ∈ candidates N a o Q t, 0 < j := fun _ hj => (Finset.mem_filter.mp hj).2.1
    rw [scan]
    change (if (modPowerRun N a d).1 = 1 ∧ 0 < d then
      if (scan N a o Q t).order = 0 then d else min d (scan N a o Q t).order
      else (scan N a o Q t).order) = _
    rw [hp, ih]
    have hinsert : candidates N a o Q (t+1) =
        if 0 < d ∧ a ^ d % N = 1 then insert d (candidates N a o Q t) else candidates N a o Q t := by
      simp [candidates, Finset.range_add_one, Finset.image_insert, Finset.filter_insert, ← heq, d]
    rw [hinsert]
    have hd : 0 < d := (convergent_bounds o Q t hQ).2.2.1
    by_cases h : a ^ d % N = 1 <;> simp [hd, h, least_insert _ _ hs]

/-- Arithmetic work for a general scan. Each Euclidean level uses a
bounded number of natural divisions, multiplications and additions. -/
theorem scan_work (N a o Q t L : ℕ) (hQ : 0 < Q) (hL : Q < 2 ^ L) :
    (scan N a o Q t).euclideanLevels ≤ t * (t+1) ∧
    (scan N a o Q t).modularMultiplications ≤ t * (2 * L) := by
  induction t with
  | zero => simp [scan]
  | succ t ih =>
    have bounds := convergent_bounds o Q t hQ
    have hm := modPower_multiplications N a L (convergent o Q t).den (lt_of_le_of_lt bounds.2.1 hL)
    simp only [scan]
    constructor
    · nlinarith [ih.1, bounds.2.2.2]
    · rw [Nat.succ_mul]
      exact Nat.add_le_add ih.2 hm

/-- Run the decoder with the scan budget used in the Fourier recovery proof. -/
def decode (N a o Q : ℕ) : Run := scan N a o Q (2 * (Q.log2 + 1) + 1)

theorem decode_work (N a o Q : ℕ) (hQ : 0 < Q) :
    let L := Q.log2 + 1
    (decode N a o Q).euclideanLevels ≤ (2*L+1)*(2*L+2) ∧
      (decode N a o Q).modularMultiplications ≤ (2*L+1)*(2*L) :=
  scan_work _ _ _ _ _ _ hQ Nat.lt_log2_self

/-- Inspect the integer arithmetic at each visited Euclidean frame. The
predicate follows the exact quotient/remainder branches of `convergent`. -/
def euclideanFits (bound a b : ℕ) : ℕ → Prop
  | 0 => a ≤ bound ∧ b ≤ bound ∧ a / b ≤ bound
  | t+1 =>
    a ≤ bound ∧ b ≤ bound ∧ a / b ≤ bound ∧ a % b ≤ bound ∧
      (a % b ≠ 0 →
        let c := convergent b (a % b) t
        a / b * c.num ≤ bound ∧ a / b * c.num + c.den ≤ bound ∧
          euclideanFits bound b (a % b) t)

/-- Every Euclidean operand and intermediate fits in the clock register's
bit width, even when an index past termination is requested. -/
theorem euclidean_width (o Q t : ℕ) (ho : o < Q) : euclideanFits Q o Q t := by
  suffices aux : ∀ a b : ℕ, a ≤ Q → b ≤ Q → 0 < b → euclideanFits Q a b t by
    exact aux o Q ho.le le_rfl (by omega)
  induction t with
  | zero => intro a b ha hb _; exact ⟨ha, hb, (Nat.div_le_self ..).trans ha⟩
  | succ t ih =>
    intro a b ha hb hb0
    have hmod := Nat.mod_lt a hb0
    refine ⟨ha, hb, (Nat.div_le_self ..).trans ha, hmod.le.trans hb, fun hr => ?_⟩
    have hc := convergent_bounds b (a % b) t (Nat.pos_of_ne_zero hr)
    have hsum := Nat.add_le_add (Nat.mul_le_mul_left (a/b) hc.1) hc.2.1
    rw [Nat.div_add_mod'] at hsum
    exact ⟨(Nat.le_add_right _ _).trans (hsum.trans ha), hsum.trans ha,
      ih b (a % b) hb (hmod.le.trans hb) (Nat.pos_of_ne_zero hr)⟩

/-- Both unreduced products of a binary modular-power frame are below N²,
at every exponent. This bounds the width of the verifier's arithmetic. -/
theorem modular_product_width (N a r : ℕ) (hN : 0 < N) :
    let b := modPower N a (r / 2)
    b * b < N ^ 2 ∧ (b * b % N) * (a % N) < N ^ 2 := by
  let b := modPower N a (r / 2)
  have hb : b < N := by simpa [b, modPower_spec] using Nat.mod_lt (a ^ (r/2)) hN
  rw [pow_two]
  exact ⟨Nat.mul_lt_mul_of_lt_of_le hb hb.le hN,
    Nat.mul_lt_mul_of_lt_of_le (Nat.mod_lt _ hN) (Nat.mod_lt _ hN).le hN⟩

end FQChem.Complexity.OrderFindingDecoder
