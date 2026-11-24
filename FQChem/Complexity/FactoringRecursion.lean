module

public import FQChem.Complexity.FactoringPreprocessing
public import Mathlib.MeasureTheory.Constructions.Pi
public import Mathlib.MeasureTheory.Measure.Real
import Mathlib.Tactic

/-!
# Factoring all the way to primes with bounded-error splitting

A shot proposes an optional divisor. The recursion checks every proposal before
splitting; if all attempts at a node fail it returns that node as a leaf. No
primality oracle is needed. Independent shots at each modulus are represented
by a random tape; only the rows reached by the actual recursion are read.
-/

@[expose] public section

namespace FQChem.Complexity.FactoringRecursion

open MeasureTheory

local instance : MeasurableSpace (Option ℕ) := ⊤
local instance : DiscreteMeasurableSpace (Option ℕ) := ⟨fun _ => trivial⟩

structure Divisor (m : ℕ) where
  val : ℕ
  nontrivial : 1 < val
  smaller : val < m
  divides : val ∣ m

def certify (m : ℕ) : Option ℕ → Option (Divisor m)
  | none => none
  | some d => if h : 1 < d ∧ d < m ∧ d ∣ m then some ⟨d,h.1,h.2.1,h.2.2⟩ else none

theorem certify_some {m d : ℕ} (hd : 1 < d ∧ d < m ∧ d ∣ m) :
    (certify m (some d)).isSome := by simp [certify,hd]

def Divisor.other {m : ℕ} (d : Divisor m) := m / d.val

theorem Divisor.pair {m : ℕ} (d : Divisor m) :
    d.val*d.other=m ∧ 1<d.other ∧ d.other<m := by
  have hp : d.val*d.other = m := Nat.mul_div_cancel' d.divides
  have hl := d.smaller
  have hd := d.nontrivial
  refine ⟨hp, ?_, Nat.div_lt_self (by omega) hd⟩
  by_contra! he
  have x := Nat.mul_le_mul_left d.val he
  omega

/-- First checked proper divisor in a row of at most t shots. -/
def first (m : ℕ) : (t : ℕ) → (Fin t → Option ℕ) → Option (Divisor m)
  | 0, _ => none
  | t+1, row => match certify m (row 0) with
    | some d => some d
    | none => first m t (Fin.tail row)

theorem first_none (m t : ℕ) (row : Fin t → Option ℕ) :
    first m t row = none ↔ ∀ i, certify m (row i) = none := by
  induction t with
  | zero => simp [first]
  | succ t ih =>
    cases h : certify m (row 0) with
    | none =>
      simp only [first,h, ih]
      exact ⟨fun h' => Fin.cases h (fun i => h' i), fun h' i => h' i.succ⟩
    | some d => simp only [first,h, Option.some_ne_none, false_iff]; exact fun hh => by simpa [h] using hh 0

structure Report where
  factors : List ℕ
  visits : ℕ

/-- Split into both proper factors recursively. Each visited node reads at most one
batch; accepting a leaf requires only that its batch returned no checked factor. -/
def factor (split : (m : ℕ) → Option (Divisor m)) (m : ℕ) : Report :=
  if m < 2 then ⟨[],0⟩ else match split m with
  | none => ⟨[m],1⟩
  | some d =>
    let L := factor split d.val
    let R := factor split d.other
    ⟨L.factors ++ R.factors, L.visits + R.visits + 1⟩
termination_by m
decreasing_by
  · exact d.smaller
  · exact d.pair.2.2

/-- A prime always terminates as a singleton leaf after its bounded batch. No
trial can return a certified proper divisor of a prime. -/
theorem prime_stops (split : (m : ℕ) → Option (Divisor m)) (m : ℕ) (hp : m.Prime) :
    (factor split m).factors = [m] ∧ (factor split m).visits = 1 := by
  have hn : split m = none := by
    cases split m with
    | none => rfl
    | some d =>
      have h := (Nat.dvd_prime hp).mp d.divides
      have h₁ := d.nontrivial
      have h₂ := d.smaller
      omega
  rw [factor,ite_eq_right (Nat.not_lt_of_ge hp.two_le),hn]
  exact ⟨rfl,rfl⟩

/-- Every run preserves the factorization product. For m ≥ 2 every leaf is at
least two and the number of visited nodes is twice the leaf count minus one. -/
theorem factor_tree (split : (m : ℕ) → Option (Divisor m)) (m : ℕ) (hm : 2 ≤ m) :
    let out := factor split m
    out.factors.prod = m ∧ (∀ d ∈ out.factors, 2 ≤ d) ∧ out.visits+1=2*out.factors.length := by
  induction m using Nat.strong_induction_on with
  | h m ih =>
    rw [factor, ite_eq_right (by omega : ¬m<2)]
    cases hs : split m with
    | none => simp [hm]
    | some d =>
      obtain ⟨hl,sl,nl⟩ := ih _ d.smaller d.nontrivial
      obtain ⟨hr,sr,nr⟩ := ih _ d.pair.2.2 d.pair.2.1
      refine ⟨?_, ?_, ?_⟩
      · simpa only [List.prod_append,hl,hr] using d.pair.1
      · intro z hz
        rcases List.mem_append.mp hz with h | h
        · exact sl _ h
        · exact sr _ h
      · simp only [List.length_append]; omega

theorem product_always (split : (m : ℕ) → Option (Divisor m)) (m : ℕ) (hm : 1 ≤ m) :
    (factor split m).factors.prod = m := by
  rcases eq_or_lt_of_le hm with rfl | h
  · simp [factor]
  · exact (factor_tree _ _ h).1

private theorem two_pow_length (l : List ℕ) (h : ∀ d ∈ l, 2 ≤ d) : 2^l.length ≤ l.prod := by
  induction l with
  | nil => simp
  | cons a l ih =>
    have z := ih (fun d hd => h d (List.mem_cons_of_mem _ hd))
    simpa only [List.length_cons, List.prod_cons, pow_succ'] using Nat.mul_le_mul (h a (by simp)) z

theorem visit_bound (split : (m : ℕ) → Option (Divisor m)) (m : ℕ) :
    (factor split m).visits ≤ 2*m.log2 := by
  by_cases hm : 2 ≤ m
  · obtain ⟨hp,hl,hn⟩ := factor_tree split m hm
    have hpow := two_pow_length _ hl
    rw [hp] at hpow
    have := (Nat.le_log2 (by omega : m ≠ 0)).mpr hpow
    omega
  · rw [factor,ite_eq_left (by omega : m<2)]; simp

/-- If every composite up to the input has a successful row, every leaf is prime.
The algorithm can revisit equal factors or choose later moduli using earlier results. -/
theorem prime_leaves (split : (m : ℕ) → Option (Divisor m)) (N : ℕ)
    (good : ∀ m, 2 ≤ m → m ≤ N → ¬m.Prime → split m ≠ none) (m : ℕ) (hm : m ≤ N) :
    ∀ d ∈ (factor split m).factors, Nat.Prime d := by
  induction m using Nat.strong_induction_on with
  | h m ih =>
    rw [factor]
    split
    · simp
    · next big =>
      cases hs : split m with
      | none =>
        have prime : m.Prime := by by_contra hn; exact good m (by omega) hm hn hs
        simpa using prime
      | some d =>
        intro z hz
        rcases List.mem_append.mp hz with h | h
        · exact ih _ d.smaller (d.smaller.le.trans hm) _ h
        · exact ih _ d.pair.2.2 (d.pair.2.2.le.trans hm) _ h

/-- The split count and success proof use the multiplicity of the resulting leaves,
and never evaluate a prime factorization to choose the next split. -/
def denominator (N : ℕ) := 128*(N.log2+1)

def shots (N : ℕ) := denominator N * (N.log2+3)

abbrev Tape (N : ℕ) := Fin (N+1) → Fin (shots N) → Option ℕ

def readTape (N : ℕ) (ω : Tape N) (m : ℕ) : Option (Divisor m) :=
  if h : m ≤ N then first m (shots N) (ω ⟨m,by omega⟩) else none

def run (N : ℕ) (ω : Tape N) : Report := factor (readTape N ω) N

/-- A tape coordinate is inspected only at a modulus visited by the adaptive
algorithm. Counting even the unused suffix of each such row gives this bound. -/
theorem trial_budget (N : ℕ) (ω : Tape N) :
    (run N ω).visits * shots N ≤ 2*N.log2 * (128*(N.log2+1)*(N.log2+3)) :=
  Nat.mul_le_mul_right _ (visit_bound _ _)

/-- The accepted event can be read directly in a concrete law of proposed divisors. -/
theorem certify_isSome_iff (m : ℕ) (r : Option ℕ) : (certify m r).isSome ↔
    ∃ d, r = some d ∧ 1 < d ∧ d < m ∧ d ∣ m := by
  cases r with
  | none => simp [certify]
  | some d =>
    by_cases h : 1 < d ∧ d < m ∧ d ∣ m <;> simp [certify,h]

/-- A mathematical random tape. Disjoint rows supply fresh physical shots at
each new modulus. A repeated modulus may reuse its previously sampled row. -/
noncomputable def tapeLaw (N : ℕ) (ν : ℕ → Measure (Option ℕ)) : Measure (Tape N) :=
  Measure.pi fun m : Fin (N+1) => Measure.pi fun _ : Fin (shots N) => ν m

instance (N : ℕ) (ν : ℕ → Measure (Option ℕ)) [∀ m, IsProbabilityMeasure (ν m)] :
    IsProbabilityMeasure (tapeLaw N ν) := by unfold tapeLaw; infer_instance

/-- The chance of missing a composite on all t independent trials is the t-th
power of its single-shot miss probability, on the actual product tape law. -/
theorem row_failure (N : ℕ) (ν : ℕ → Measure (Option ℕ)) [∀ m, IsProbabilityMeasure (ν m)]
    (m : Fin (N+1)) :
    (tapeLaw N ν).real {ω | first m (shots N) (ω m) = none} =
      ((ν m).real {r | certify m r = none})^(shots N) := by
  let S := Set.univ.pi (fun _ : Fin (shots N) => {r | certify m r = none})
  have eq : {ω : Tape N | first m (shots N) (ω m) = none} = Function.eval m ⁻¹' S := by
    ext ω; simp [S,first_none]
  have measurable : MeasurableSet S := S.to_countable.measurableSet
  rw [eq, Measure.real, tapeLaw, (measurePreserving_eval _ m).measure_preimage measurable.nullMeasurableSet]
  simp [S,Measure.pi_pi,Measure.real]

/-- D calls cut the miss probability at least in half when success per shot is ≥1/D. -/
theorem block_failure (D : ℕ) (hD : 0 < D) (p : ℝ) (hp : 0 ≤ p) (hs : p ≤ 1-1/(D:ℝ)) :
    p^D ≤ 1/2 := by
  have hd : 0 < (D:ℝ) := by exact_mod_cast hD
  have pos : 0 ≤ 1+1/(D:ℝ) := by positivity
  have bound : p*(1+1/(D:ℝ)) ≤ 1 := by
    have := mul_le_mul_of_nonneg_right hs pos
    nlinarith [sq_nonneg (1/(D:ℝ))]
  have z := pow_le_pow_left₀ (mul_nonneg hp pos) bound D
  rw [mul_pow,one_pow] at z
  have b : (2:ℝ) ≤ (1+1/(D:ℝ))^D := by
    convert one_add_mul_le_pow (by linarith [one_div_pos.mpr hd] : (-2:ℝ) ≤ 1/(D:ℝ)) D using 1
    field_simp
    norm_num
  nlinarith [mul_le_mul_of_nonneg_left b (pow_nonneg hp D)]

private theorem aggregate_failure (N : ℕ) :
    ((N+1 : ℕ):ℝ)*(1/2:ℝ)^(N.log2+3) ≤ 1/4 := by
  have hl : N+1 ≤ 2^(N.log2+1) := Nat.lt_log2_self
  have hl' : ((N+1:ℕ):ℝ) ≤ (2:ℝ)^(N.log2+1) := by exact_mod_cast hl
  rw [one_div,inv_pow,← div_eq_mul_inv]
  apply (div_le_iff₀ (by positivity)).mpr
  rw [show N.log2+3 = (N.log2+1)+2 by omega, pow_add]
  linarith

/-- A complete bounded-error prime factorization. At every composite m ≤ N,
a single proposed-divisor law must find a checked proper factor with probability
at least 1/[128(log₂ N+1)]. The return value always multiplies to N; simultaneous
amplification ensures every returned leaf is prime with probability at least 2/3.
There is no primality-test instruction. The number of shots used on every tape
is polynomial in the input bit length, including non-splitting leaves. -/
theorem recursiveFactorization (N : ℕ) (hN : 1 ≤ N) (ν : ℕ → Measure (Option ℕ))
    [∀ m, IsProbabilityMeasure (ν m)]
    (shot : ∀ m, 2 ≤ m → m ≤ N → ¬m.Prime →
      1 / ((denominator N : ℕ) : ℝ) ≤ (ν m).real {r | (certify m r).isSome}) :
    (∀ ω : Tape N, (run N ω).factors.prod = N ∧ (run N ω).visits * shots N ≤
        2*N.log2 * (128*(N.log2+1)*(N.log2+3))) ∧
    (2/3 : ℝ) ≤ (tapeLaw N ν).real {ω | (run N ω).factors.prod = N ∧
      ∀ d ∈ (run N ω).factors, Nat.Prime d} := by
  classical
  refine ⟨fun ω => ⟨product_always _ _ hN, trial_budget _ _⟩, ?_⟩
  let bad (m : Fin (N+1)) : Set (Tape N) :=
    if 2 ≤ m.val ∧ ¬ m.val.Prime then {ω | first m (shots N) (ω m) = none} else ∅
  let U := ⋃ m, bad m
  have one (m : Fin (N+1)) : (tapeLaw N ν).real (bad m) ≤ (1/2:ℝ)^(N.log2+3) := by
    by_cases hh : 2 ≤ m.val ∧ ¬ m.val.Prime
    · rw [show bad m = _ from ite_eq_left hh, row_failure]
      let A : Set (Option ℕ) := {r | (certify m r).isSome}
      have ec : {r | certify m r = none} = Aᶜ := by
        ext r
        change certify m r = none ↔ ¬ (certify m r).isSome = true
        cases certify m r <;> simp
      have miss : (ν m).real {r | certify m r = none} ≤ 1-1/(denominator N : ℝ) := by
        rw [ec,measureReal_compl A.to_countable.measurableSet,probReal_univ]
        exact sub_le_sub_left (shot _ hh.1 (by have := m.isLt; omega) hh.2) _
      rw [shots, pow_mul]
      exact pow_le_pow_left₀ (by positivity) (block_failure _ (by simp [denominator]) _
        (measureReal_nonneg) miss) _
    · simp [bad,hh]
  have allBad : (tapeLaw N ν).real U ≤ 1/4 := by
    calc
      _ ≤ ∑ m, (tapeLaw N ν).real (bad m) := measureReal_iUnion_fintype_le _
      _ ≤ ∑ _ : Fin (N+1), (1/2:ℝ)^(N.log2+3) := Finset.sum_le_sum fun m _ => one m
      _ ≤ _ := by simpa using aggregate_failure N
  have good : Uᶜ ⊆ {ω | (run N ω).factors.prod = N ∧ ∀ d ∈ (run N ω).factors, Nat.Prime d} := by
    intro ω hω
    refine ⟨product_always _ _ hN, prime_leaves (readTape N ω) N ?_ N le_rfl⟩
    intro m hm ml np
    let i : Fin (N+1) := ⟨m,by omega⟩
    have hw : ω ∉ bad i := by intro x; exact hω (Set.mem_iUnion.mpr ⟨i,x⟩)
    have hi : 2 ≤ i.val ∧ ¬i.val.Prime := ⟨hm,np⟩
    simpa [bad,hi,readTape,ml,i] using hw
  have prob := measureReal_mono (μ:=tapeLaw N ν) good
  rw [measureReal_compl U.to_countable.measurableSet,probReal_univ] at prob
  linarith

end FQChem.Complexity.FactoringRecursion
