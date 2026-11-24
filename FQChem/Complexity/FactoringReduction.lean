module

public import Mathlib.Data.Rat.Cast.Order
public import Mathlib.Data.ZMod.QuotientRing
public import Mathlib.RingTheory.ZMod.UnitsCyclic
public import Mathlib.Algebra.Group.Pi.Units
public import Mathlib.Data.Nat.Totient
import Mathlib.Tactic

/-!
# The random-base reduction from factoring to order finding

Shor, *Polynomial-Time Algorithms for Prime Factorization and Discrete
Logarithms on a Quantum Computer*, §5. The classical circuit input is a base
and a proposed order. The Chinese remainder decomposition is used only in the
probability proof, and is never computed by the factor extraction algorithm.
-/

@[expose] public section

namespace FQChem.Complexity.FactoringReduction

/-- Binary modular exponentiation, with reduction at each multiplication. -/
def modPowerRun (N a : ℕ) (r : ℕ) : ℕ × ℕ :=
  if h : r = 0 then (1 % N, 0)
  else
    let next := modPowerRun N a (r / 2)
    let sq := next.1 * next.1 % N
    if r % 2 = 0 then (sq, next.2 + 1) else (sq * (a % N) % N, next.2 + 2)
termination_by r
decreasing_by omega

/-- The residue computed by the binary exponentiation run. -/
def modPower (N a r : ℕ) := (modPowerRun N a r).1

/-- At most two modular multiplications per bit of the supplied exponent. -/
theorem modPower_multiplications (N a b r : ℕ) (hr : r < 2 ^ b) :
    (modPowerRun N a r).2 ≤ 2 * b := by
  induction b generalizing r with
  | zero =>
    obtain rfl : r = 0 := by simpa using hr
    simp [modPowerRun]
  | succ b ih =>
    rw [modPowerRun]
    split
    next => simp
    next =>
      have hsmall : r / 2 < 2 ^ b := by rw [pow_succ] at hr; omega
      have h := ih (r / 2) hsmall
      split <;> simp only <;> omega

theorem modPower_spec (N a r : ℕ) : modPower N a r = a ^ r % N := by
  induction r using Nat.strong_induction_on with
  | h r ih =>
    change (modPowerRun N a r).1 = _
    rw [modPowerRun]
    split_ifs with hz he
    · simp [hz]
    all_goals simp only; rw [← modPower, ih (r / 2) (by omega)]
    · have hr : r = r / 2 + r / 2 := by omega
      conv_rhs => rw [hr, pow_add]
      simp
    · have hr : r = (r / 2 + r / 2) + 1 := by omega
      conv_rhs => rw [hr, pow_succ, pow_add]
      simp

/-- A nonunit is handled by a gcd before using an order. Even a spurious
order candidate can produce only a certified proper divisor or `none`. -/
def extractFactor (N a r : ℕ) : Option ℕ :=
  let g := a.gcd N
  let d := if g = 1 then (modPower N a (r / 2) - 1).gcd N else g
  if 1 < d ∧ d < N then some d else none

theorem extractFactor_sound {N a r d : ℕ} (h : extractFactor N a r = some d) :
    1 < d ∧ d < N ∧ d ∣ N := by
  by_cases hg : a.gcd N = 1 <;> simp only [extractFactor, hg, ite_true, ite_false] at h
  all_goals
    split at h
    next ht =>
      cases h
      exact ⟨ht.1, ht.2, Nat.gcd_dvd_right _ _⟩
    next => contradiction

/-- Shor's success criterion for the true multiplicative order of a unit. -/
def GoodOrder {N : ℕ} (a : (ZMod N)ˣ) : Prop :=
  Even (orderOf a) ∧ (a.val ^ (orderOf a / 2)) ≠ -1

private theorem odd_quotient {d n : ℕ} (hn : n ≠ 0) (hd : d ∣ n) :
    Odd (n / d) ↔ n.factorization 2 = d.factorization 2 := by
  have hd0 : d ≠ 0 := fun h => hn (Nat.eq_zero_of_zero_dvd (h ▸ hd))
  have hq : n / d ≠ 0 := (Nat.div_pos (Nat.le_of_dvd (Nat.pos_of_ne_zero hn) hd)
    (Nat.pos_of_ne_zero hd0)).ne'
  rw [← Nat.not_even_iff_odd, even_iff_two_dvd,
    Nat.prime_two.dvd_iff_one_le_factorization hq, Nat.factorization_div hd]
  have hle := (Nat.factorization_le_iff_dvd hd0 hn).2 hd 2
  change ¬1 ≤ n.factorization 2 - d.factorization 2 ↔ _
  omega

private theorem generator_shift {G : Type*} [Group G] [Finite G] [IsCyclic G]
    (he : Even (Nat.card G)) : ∃ g : G, ∀ x : G,
      (orderOf (x * g)).factorization 2 ≠ (orderOf x).factorization 2 := by
  obtain ⟨g, hg⟩ := IsCyclic.exists_ofOrder_eq_natCard (α := G)
  have hpos := orderOf_pos g
  have hgEven : Even (orderOf g) := hg ▸ he
  have label (k : ℕ) :
      (orderOf g).factorization 2 = (orderOf (g ^ k)).factorization 2 ↔ Odd k := by
    rw [← odd_quotient hpos.ne' (orderOf_pow_dvd k), orderOf_pow,
      Nat.div_div_self (Nat.gcd_dvd_left _ _) hpos.ne', ← Nat.not_even_iff_odd,
      even_iff_two_dvd, Nat.dvd_gcd_iff, and_iff_right hgEven.two_dvd,
      ← even_iff_two_dvd, Nat.not_even_iff_odd]
  have htop : Subgroup.zpowers g = ⊤ :=
    (Subgroup.card_eq_iff_eq_top (H := Subgroup.zpowers g)).mp (by rwa [Nat.card_zpowers])
  refine ⟨g, fun x => ?_⟩
  have hx : x ∈ Subgroup.zpowers g := by simp [htop]
  obtain ⟨k, rfl⟩ := (Submonoid.mem_powers_iff x g).mp (mem_powers_iff_mem_zpowers.mpr hx)
  intro h
  have hiff : Odd (k + 1) ↔ Odd k := by
    rw [← label (k + 1), ← label k, pow_succ, h]
  simp [Nat.odd_iff] at hiff
  omega

/-- A product counting argument. Once a distinguished coordinate is fixed,
each remaining coordinate supplies an independent bit that sends the common
label to a different one. This bounds the agreeing tuples by 2⁻⁽ᵏ⁻¹⁾. -/
private theorem constant_label_count {I : Type*} [Fintype I] (i₀ : I)
    (G : I → Type*) [∀ i, Group (G i)] [∀ i, Fintype (G i)]
    (label : (i : I) → G i → ℕ) (g : (i : I) → G i)
    (shift : ∀ i x, label i (x * g i) ≠ label i x) :
    2 ^ (Fintype.card I - 1) *
      Nat.card {x : ∀ i, G i // ∀ i, label i (x i) = label i₀ (x i₀)} ≤
        Nat.card (∀ i, G i) := by
  classical
  let B := {i : I // i ≠ i₀} → Bool
  let A := {x : ∀ i, G i // ∀ i, label i (x i) = label i₀ (x i₀)}
  let flag (b : B) (i : I) := if h : i ≠ i₀ then b ⟨i, h⟩ else false
  let f (v : B × A) (i : I) := if flag v.1 i then v.2.val i * g i else v.2.val i
  have hf : Function.Injective f := by
    rintro ⟨b,x⟩ ⟨c,y⟩ he
    have h0 : x.val i₀ = y.val i₀ := by simpa [f, flag] using congrFun he i₀
    have hl (i : I) : label i (x.val i) = label i (y.val i) := by
      rw [x.property i, y.property i, h0]
    have hb (i : I) : flag b i = flag c i := by
      have hi := congrFun he i
      by_cases hbi : flag b i <;> by_cases hci : flag c i <;> simp_all [f]
      · exact shift i (x.val i) ((congrArg (label i) hi).trans (hl i).symm)
      · exact shift i (y.val i) ((congrArg (label i) hi.symm).trans (hl i))
    have hbc : b = c := by
      funext i
      simpa [flag, i.property] using hb i
    subst c
    congr 1
    apply Subtype.ext
    funext i
    have hi := congrFun he i
    by_cases hbi : flag b i <;> simpa [f, hbi] using hi
  have hc := Nat.card_le_card_of_injective f hf
  simpa [Nat.card_prod, B, A, Nat.card_fun, Nat.card_eq_fintype_card,
    Fintype.card_subtype_compl] using hc

/-- Every unit that fails the extraction criterion has equal 2-parts of
its projected orders in all the prime-power CRT factors. -/
private theorem bad_projection {N m : ℕ} [NeZero N] [NeZero m] (hm : 2 < m)
    (f : ZMod N →+* ZMod m) (a : (ZMod N)ˣ) (hbad : ¬GoodOrder a) :
    (orderOf ((Units.map f.toMonoidHom) a)).factorization 2 =
        (orderOf a).factorization 2 := by
  let b := Units.map f.toMonoidHom a
  have hd : orderOf b ∣ orderOf a := orderOf_map_dvd _ _
  have ha := orderOf_pos a
  change (orderOf b).factorization 2 = _
  by_cases he : Even (orderOf a)
  · have hneg : a.val ^ (orderOf a / 2) = -1 := by
      by_contra h
      exact hbad ⟨he, h⟩
    have hne : b ^ (orderOf a / 2) ≠ 1 := by
      intro hb
      have hv := congrArg Units.val hb
      have hh := congrArg f hneg
      let : Fact (2 < m) := ⟨hm⟩
      apply ZMod.neg_one_ne_one (n := m)
      simpa [b, map_pow, map_neg] using hh.symm.trans (by simpa [b] using hv)
    apply ((odd_quotient ha.ne' hd).mp ?_).symm
    rw [← Nat.not_even_iff_odd]
    rintro ⟨c, hc⟩
    have heq := Nat.div_mul_cancel hd
    rw [hc, add_mul] at heq
    apply hne
    rw [show orderOf a / 2 = orderOf b * c by rw [Nat.mul_comm]; omega, pow_mul,
      pow_orderOf_eq_one, one_pow]
  · have v0 := Nat.factorization_eq_zero_of_not_dvd (n := orderOf a)
      (p := 2) (by simpa [← even_iff_two_dvd] using he)
    have hl := (Nat.factorization_le_iff_dvd (orderOf_pos b).ne' ha.ne').2 hd 2
    omega

/-- Shor §5. For an odd integer N > 1 with k distinct primes, at most
one in 2^(k−1) of its units fails the even-order/non-minus-one test.
The statement counts actual units modulo N, including the identity. -/
theorem badUnitCount (N : ℕ) (hN : 1 < N) (ho : Odd N) :
    2 ^ (N.primeFactors.card - 1) * Nat.card {a : (ZMod N)ˣ // ¬GoodOrder a}
      ≤ Nat.card (ZMod N)ˣ := by
  classical
  let : NeZero N := ⟨by omega⟩
  let m (p : N.primeFactors) := p.val ^ N.factorization p
  have big (p : N.primeFactors) : 2 < m p := by
    obtain ⟨hp, hd, hn⟩ := Nat.mem_primeFactors.mp p.2
    have hodd := ho.of_dvd_nat hd
    have hp2 := hp.two_le
    have hpgt : 2 < p.val := by rcases hodd with ⟨k, hk⟩; omega
    exact lt_of_lt_of_le hpgt (Nat.le_self_pow (hp.factorization_pos_of_dvd hn hd).ne' _)
  let G (p : N.primeFactors) := (ZMod (m p))ˣ
  let (p : N.primeFactors) : NeZero (m p) := ⟨by have := big p; omega⟩
  let (p : N.primeFactors) : Fintype (G p) := inferInstanceAs (Fintype (ZMod (m p))ˣ)
  have shifts (p : N.primeFactors) : ∃ g : G p, ∀ x : G p,
      (orderOf (x * g)).factorization 2 ≠ (orderOf x).factorization 2 := by
    have hp := Nat.prime_of_mem_primeFactors p.2
    have hodd := ho.of_dvd_nat (Nat.dvd_of_mem_primeFactors p.2)
    let : IsCyclic (G p) := ZMod.isCyclic_units_of_prime_pow p hp
      (by rintro h; rw [h] at hodd; exact (by decide : ¬Odd 2) hodd) _
    apply generator_shift
    simpa [G, Nat.card_eq_fintype_card, ZMod.card_units_eq_totient] using Nat.totient_even (big p)
  choose g hg using shifts
  obtain ⟨p₀, hp₀⟩ := Nat.nonempty_primeFactors.mpr hN
  let i₀ : N.primeFactors := ⟨p₀, hp₀⟩
  let e : (ZMod N)ˣ ≃* (∀ p, G p) :=
    (Units.mapEquiv (ZMod.equivPi N (NeZero.ne N)).toMulEquiv).trans .piUnits
  let L (i : N.primeFactors) (x : G i) := (orderOf x).factorization 2
  have hbad (a : (ZMod N)ˣ) (ha : ¬GoodOrder a) (p : N.primeFactors) :
      L p (e a p) = (orderOf a).factorization 2 :=
    bad_projection (big p)
      ((Pi.evalRingHom (fun p : N.primeFactors => ZMod (m p)) p).comp
        (ZMod.equivPi N (NeZero.ne N)).toRingHom) a ha
  let embed (a : {a : (ZMod N)ˣ // ¬GoodOrder a}) :
      {x : ∀ p, G p // ∀ p, L p (x p) = L i₀ (x i₀)} :=
    ⟨e a.val, fun p => (hbad a.val a.property p).trans (hbad a.val a.property i₀).symm⟩
  have hle := Nat.card_le_card_of_injective embed
    (fun x y h => Subtype.ext (e.injective (congrArg Subtype.val h)))
  calc
    _ ≤ _ := Nat.mul_le_mul_left _ hle
    _ ≤ Nat.card (∀ p, G p) := by
      simpa only [Fintype.card_coe] using constant_label_count i₀ G L g hg
    _ = _ := Nat.card_congr e.toEquiv.symm

/-- For a uniformly random unit, the probability of a good order is at
least 1 − 1/2^(k−1), where k is the number of distinct prime factors. -/
theorem goodUnitFraction (N : ℕ) (hN : 1 < N) (ho : Odd N) :
    1 - 1 / (2 : ℚ) ^ (N.primeFactors.card - 1) ≤
      (Nat.card {a : (ZMod N)ˣ // GoodOrder a} : ℚ) / Nat.card (ZMod N)ˣ := by
  classical
  let : NeZero N := ⟨by omega⟩
  let U := (ZMod N)ˣ
  let B := Nat.card {a : U // ¬GoodOrder a}
  let A := Nat.card {a : U // GoodOrder a}
  let T := Nat.card U
  let c := 2 ^ (N.primeFactors.card - 1)
  have hcount : c * B ≤ T := badUnitCount N hN ho
  have htotal : A + B = T := by
    simp only [A, B, T, U, Nat.card_eq_fintype_card, Fintype.card_subtype_compl]
    exact Nat.add_sub_of_le (Fintype.card_subtype_le _)
  have hT : 0 < T := Nat.card_pos
  have hc : 0 < c := pow_pos (by decide) _
  have bound : (c : ℚ) * B ≤ T := by exact_mod_cast hcount
  have total : (A : ℚ) + B = T := by exact_mod_cast htotal
  have ct : (c : ℚ) = (2 : ℚ) ^ (N.primeFactors.card - 1) := by simp [c]
  rw [← ct]
  change 1 - 1 / (c : ℚ) ≤ (A : ℚ) / T
  have hc' : 0 < (c : ℚ) := by exact_mod_cast hc
  have ht' : 0 < (T : ℚ) := by exact_mod_cast hT
  field_simp
  nlinarith [congrArg ((c : ℚ) * ·) total]

/-- On a good base, the single gcd with the minus sign recovers a proper
divisor. The executable routine only receives the integer representative and
the order, without access to the factors of N. -/
theorem extractFactor_of_good {N : ℕ} (hN : 1 < N) (a : (ZMod N)ˣ) (hg : GoodOrder a) :
    ∃ d, extractFactor N a.val.val (orderOf a) = some d ∧ 1 < d ∧ d < N ∧ d ∣ N := by
  let : NeZero N := ⟨by omega⟩
  let : Fact (1 < N) := ⟨hN⟩
  let r := orderOf a
  let x := modPower N a.val.val (r / 2)
  let d := (x - 1).gcd N
  have hc : a.val.val.gcd N = 1 := ZMod.val_coe_unit_coprime a
  have hx : (x : ZMod N) = a.val ^ (r / 2) := by simp [x, modPower_spec]
  have hx0 : 1 ≤ x := by
    by_contra! hh
    rw [show x = 0 by omega] at hx
    exact ((a ^ (r / 2)).ne_zero) (by simpa using hx.symm)
  have hr : 0 < r := orderOf_pos a
  have he : Even r := hg.1
  have h1 : (x : ZMod N) ≠ 1 := by
    intro h
    have hu : a ^ (r / 2) = 1 := Units.ext (hx.symm.trans h)
    have hle := Nat.le_of_dvd (show 0 < r / 2 by rcases he with ⟨k,h⟩; omega)
      (orderOf_dvd_iff_pow_eq_one.mpr hu)
    change r ≤ r / 2 at hle
    omega
  have hn1 : (x : ZMod N) ≠ -1 := fun h => hg.2 (hx.symm.trans h)
  have hs : (x : ZMod N) ^ 2 = 1 := by
    rw [hx, ← pow_mul, Nat.div_mul_cancel he.two_dvd]
    exact congrArg Units.val (pow_orderOf_eq_one a)
  have hprod : N ∣ (x - 1) * (x + 1) := by
    apply (ZMod.natCast_eq_zero_iff _ _).mp
    push_cast [Nat.cast_sub hx0]
    linear_combination hs
  have hminus : ¬ N ∣ x - 1 := by
    intro hd
    have h := (ZMod.natCast_eq_zero_iff _ _).mpr hd
    rw [Nat.cast_sub hx0, Nat.cast_one, sub_eq_zero] at h
    exact h1 h
  have hplus : ¬ N ∣ x + 1 := by
    intro hd
    have h := (ZMod.natCast_eq_zero_iff _ _).mpr hd
    push_cast at h
    exact hn1 (eq_neg_of_add_eq_zero_left h)
  have hdN : d ∣ N := Nat.gcd_dvd_right _ _
  have dsmall : d < N := (Nat.le_of_dvd (by omega) hdN).lt_of_ne fun h =>
    hminus (h ▸ Nat.gcd_dvd_left (x - 1) N)
  have dbig : 1 < d := by
    have hdpos : 0 < d := Nat.gcd_pos_of_pos_right _ (by omega)
    by_contra! hd
    have cop : (x - 1).Coprime N := show d = 1 by omega
    exact hplus (cop.symm.dvd_of_dvd_mul_left hprod)
  refine ⟨d, ?_, dbig, dsmall, hdN⟩
  simpa only [extractFactor, hc, ite_true] using
    (show (if 1 < d ∧ d < N then some d else none) = some d by simp [dbig, dsmall])

/-- At most 2^(-(k−1)t) of all length-t tuples of independently uniform
units return no factor when the order-finding calls return the true orders. -/
theorem failedRetryCount (N t : ℕ) (hN : 1 < N) (ho : Odd N) :
    (2 ^ (N.primeFactors.card - 1)) ^ t *
      Nat.card {v : Fin t → (ZMod N)ˣ //
        ∀ i, extractFactor N (v i).val.val (orderOf (v i)) = none}
      ≤ Nat.card (Fin t → (ZMod N)ˣ) := by
  classical
  let : NeZero N := ⟨by omega⟩
  let T := {v : Fin t → (ZMod N)ˣ //
    ∀ i, extractFactor N (v i).val.val (orderOf (v i)) = none}
  let f (v : T) (i : Fin t) : {a : (ZMod N)ˣ // ¬GoodOrder a} :=
    ⟨v.val i, fun hg => by
      obtain ⟨d, hd, -⟩ := extractFactor_of_good hN _ hg
      rw [v.property i] at hd
      contradiction⟩
  have hf : Function.Injective f := fun x y h =>
    Subtype.ext (funext fun i => congrArg Subtype.val (congrFun h i))
  calc
    _ ≤ _ := Nat.mul_le_mul_left _ (Nat.card_le_card_of_injective f hf)
    _ ≤ _ := by simpa [Nat.card_fun, ← mul_pow] using Nat.pow_le_pow_left (badUnitCount N hN ho) t

/-- Any positive nonunit below N immediately yields its gcd, regardless
of the order candidate. This branch requires no order-finding call. -/
theorem extractFactor_nonunit {N a : ℕ} (ha : 0 < a) (hb : a < N)
    (hc : ¬a.Coprime N) (r : ℕ) : extractFactor N a r = some (a.gcd N) := by
  have h1 : a.gcd N ≠ 1 := hc
  have hpos := Nat.gcd_pos_of_pos_left N ha
  have hle := Nat.gcd_le_left N ha
  simp [extractFactor, h1, show 1 < a.gcd N by omega, hle.trans_lt hb]

/-- A uniform base can be drawn from all positive residues 1,…,N−1.
For nonunits the candidate order is unrestricted. For units the exact order
gives the same 2^(1−k) upper bound on the failure fraction. -/
theorem randomBaseFailure (N : ℕ) (hN : 1 < N) (ho : Odd N) (candidate : ℕ → ℕ)
    (oracle : ∀ a : (ZMod N)ˣ, candidate a.val.val = orderOf a) :
    2 ^ (N.primeFactors.card - 1) * Nat.card
      {x : Fin (N - 1) // extractFactor N (x.val + 1) (candidate (x.val + 1)) = none} ≤ N - 1 := by
  classical
  let : NeZero N := ⟨by omega⟩
  let : Fact (1 < N) := ⟨hN⟩
  let F := {x : Fin (N - 1) // extractFactor N (x.val + 1) (candidate (x.val + 1)) = none}
  have less (x : Fin (N-1)) : x.val + 1 < N := by have := x.isLt; omega
  have cop (x : F) : (x.val.val+1).Coprime N := by
    by_contra h
    have he := extractFactor_nonunit (Nat.succ_pos _) (less x.val) h (candidate (x.val.val + 1))
    rw [x.property] at he
    contradiction
  let u (x : F) := ZMod.unitOfCoprime (x.val.val + 1) (cop x)
  have repr (x : F) : (u x).val.val = x.val.val + 1 := by
    exact ZMod.val_natCast_of_lt (less x.val)
  let f (x : F) : {a : (ZMod N)ˣ // ¬GoodOrder a} :=
    ⟨u x, fun hg => by
      obtain ⟨d, hd, -⟩ := extractFactor_of_good hN (u x) hg
      rw [← oracle (u x), repr, x.property] at hd
      contradiction⟩
  have hf : Function.Injective f := by
    intro x y h
    have hv := congrArg (fun z : {a : (ZMod N)ˣ // ¬GoodOrder a} => z.val.val.val) h
    change (u x).val.val = (u y).val.val at hv
    simp only [repr, Nat.add_right_cancel_iff] at hv
    exact Subtype.ext (Fin.ext hv)
  have hU : Nat.card (ZMod N)ˣ ≤ N - 1 := by
    rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient]
    have := Nat.totient_lt N hN
    omega
  exact ((Nat.mul_le_mul_left _ (Nat.card_le_card_of_injective f hf)).trans
    (badUnitCount N hN ho)).trans hU

/-- Read a uniform binary word as a positive base if its value is below
N−1. Rejected words can be retried using fresh fair bits. -/
def baseFromBits (N word : ℕ) : Option (Fin (N - 1)) :=
  if h : word < N - 1 then some ⟨word, h⟩ else none

/-- At bit width 1+floor(log₂(N−1)), every positive base has exactly one
accepted word. At least half of all words are accepted. -/
theorem fairBitBaseSampler (N : ℕ) (hN : 1 < N) :
    let Q := 2 ^ ((N - 1).log2 + 1)
    (∀ x : Fin (N-1), ∃! w : Fin Q, baseFromBits N w.val = some x) ∧
    Q ≤ 2 * Nat.card {w : Fin Q // (baseFromBits N w.val).isSome} := by
  classical
  let Q := 2 ^ ((N - 1).log2 + 1)
  have hQ : N-1 < Q := Nat.lt_log2_self
  have hb (i : Fin (N-1)) : baseFromBits N i.val = some i := by simp [baseFromBits, i.isLt]
  constructor
  · intro x
    refine ⟨⟨x.val, x.isLt.trans hQ⟩, hb x, ?_⟩
    intro w hw
    unfold baseFromBits at hw
    split at hw
    next _ =>
      have := congrArg Fin.val (Option.some.inj hw)
      exact Fin.ext this
    next => contradiction
  · let f (x : Fin (N-1)) : {w : Fin Q // (baseFromBits N w.val).isSome} :=
      ⟨⟨x.val, x.isLt.trans hQ⟩, by simp [hb]⟩
    have inj : Function.Injective f := fun _ _ h => Fin.ext (congrArg (fun x => x.val.val) h)
    have hc := Nat.card_le_card_of_injective f inj
    rw [Nat.card_fin] at hc
    have hp := Nat.log2_self_le (n := N-1) (by omega)
    have hsize : Q ≤ 2 * (N-1) := by unfold Q; rw [pow_succ]; omega
    exact hsize.trans (Nat.mul_le_mul_left 2 hc)

end FQChem.Complexity.FactoringReduction
