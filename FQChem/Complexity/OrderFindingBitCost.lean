module

public import FQChem.Complexity.OrderFindingDecoder
import Mathlib.Tactic

/-! # Binary arithmetic costs of the Fourier order decoder

A fixed-width word is represented by its natural value. Reading an input bit,
shifting wires, concatenating wires and fan-out are free. Each binary XOR,
AND, OR and unary NOT costs one gate. A ripple cell implements either addition
or two's-complement subtraction, and a bitwise selector costs four gates per
bit. These cells give explicit shift-add and restoring-division implementations.
-/

@[expose] public section
namespace FQChem.Complexity.OrderFindingBitCost

def low (x : ℕ) := x.testBit 0

private theorem low_split (x : ℕ) : 2*(x/2) + (low x).toNat = x := by
  cases h : low x
  · have := Nat.mod_two_eq_zero_iff_testBit_zero.mpr h
    simp; omega
  · have := Nat.mod_two_eq_one_iff_testBit_zero.mpr h
    simp; omega

structure Ripple where
  word : ℕ
  carry : Bool
  gates : ℕ
  deriving Repr

/-- Six gates per bit: conditional complement, two XORs for the result, and
two ANDs and an OR for the carry. The output remains a fixed-width word. -/
def ripple (sub : Bool) : ℕ → ℕ → ℕ → Bool → Ripple
  | 0, _, _, c => ⟨0, c, 0⟩
  | w+1, x, y, c =>
    let xb := low x
    let yb := (low y).xor sub
    let p := xb.xor yb
    let h := ripple sub w (x/2) (y/2) ((xb && yb) || (c && p))
    ⟨2*h.word + (p.xor c).toNat, h.carry, h.gates + 6⟩

private theorem cell (x y c s : Bool) :
    let p := x.xor (y.xor s)
    let k := (x && y.xor s) || (c && p)
    (p.xor c).toNat + 2 * k.toNat = x.toNat + (y.xor s).toNat + c.toNat ∧
       ((y.xor s).toNat + (if s then y.toNat else 0) =
        if s then 1 else y.toNat) := by decide +revert

theorem ripple_spec (sub : Bool) (w x y : ℕ) (c : Bool) (hx : x < 2^w) (hy : y < 2^w) :
    let r := ripple sub w x y c
    r.word < 2^w ∧ r.gates = 6*w ∧
      (if sub then r.word + 2^w*r.carry.toNat + y + 1 = x + 2^w + c.toNat
       else r.word + 2^w*r.carry.toNat = x+y+c.toNat) := by
  induction w generalizing x y c with
  | zero =>
    simp only [pow_zero, Nat.lt_one_iff] at hx hy
    subst x; subst y; cases sub <;> simp [ripple]; omega
  | succ w ih =>
    rw [pow_succ] at hx hy
    let p := (low x).xor ((low y).xor sub)
    let cc := (low x && (low y).xor sub) || (c && p)
    let h := ripple sub w (x/2) (y/2) cc
    have ⟨hw, hg, hs⟩ := ih (x/2) (y/2) cc (by omega) (by omega)
    have hcell := cell (low x) (low y) c sub
    change (p.xor c).toNat + 2*cc.toNat = _ ∧ _ at hcell
    have hbit : (p.xor c).toNat ≤ 1 := by cases p.xor c <;> decide
    have hvx := low_split x
    have hvy := low_split y
    refine ⟨?_, ?_, ?_⟩
    · change 2*h.word + (p.xor c).toNat < _
      change h.word < 2^w at hw
      rw [pow_succ]; omega
    · change h.gates + 6 = _
      change h.gates = 6*w at hg
      omega
    · change (if sub then (2*h.word + (p.xor c).toNat) + 2^(w+1)*h.carry.toNat + y + 1 = _
             else (2*h.word + (p.xor c).toNat) + 2^(w+1)*h.carry.toNat = _)
      change (if sub then h.word + 2^w*h.carry.toNat + y/2 + 1 = _
              else h.word + 2^w*h.carry.toNat = _) at hs
      rcases hcell with ⟨hcell,hsub⟩
      cases sub <;> simp only [Bool.false_eq_true, ite_false, ite_true, add_zero, pow_succ] at *
      all_goals nlinarith only [hs,hcell,hsub,hvx,hvy]

/-- Four gates per output bit: NOT, two ANDs and OR. -/
def selectWord (s : Bool) : ℕ → ℕ → ℕ → ℕ × ℕ
  | 0, _, _ => (0,0)
  | w+1, x, y =>
    let h := selectWord s w (x/2) (y/2)
    (2*h.1 + ((s && low x) || (!s && low y)).toNat, h.2 + 4)

private theorem select_spec (s : Bool) (w x y : ℕ) (hx : x < 2^w) (hy : y < 2^w) :
    (selectWord s w x y).1 = (if s then x else y) ∧ (selectWord s w x y).2 = 4*w := by
  induction w generalizing x y with
  | zero => have hx' : x=0 := by simpa using hx
            have hy' : y=0 := by simpa using hy
            simp [selectWord, hx',hy']
  | succ w ih =>
    rw [pow_succ] at hx hy
    have hh := ih (x/2) (y/2) (by omega) (by omega)
    cases s <;> simp [selectWord, hh.1, hh.2, low_split, Nat.mul_succ]

/-- Fixed-width shift-add multiplication, with an explicit selector at
every multiplier bit. Intermediate discarded high carries implement wrapping. -/
def multiply (w : ℕ) : ℕ → ℕ → ℕ → ℕ × ℕ
  | 0, _, _ => (0,0)
  | n+1, x, y =>
    let h := multiply w n x (y/2)
    let twice := 2*h.1
    let sum := ripple false w twice x false
    let sel := selectWord (low y) w sum.word twice
    (sel.1, h.2 + sum.gates + sel.2)

theorem multiply_spec (w n x y : ℕ) (hx : x < 2^w) (hy : y < 2^n) (hxy : x*y < 2^w) :
    multiply w n x y = (x*y, n*(10*w)) := by
  induction n generalizing y with
  | zero => obtain rfl : y = 0 := by simpa using hy
            simp [multiply]
  | succ n ih =>
    rw [pow_succ] at hy
    have hd := low_split y
    have ha : 2*(x*(y/2)) + x*(low y).toNat = x*y := by nlinarith [congrArg (x*·) hd]
    have ht : 2*(x*(y/2)) < 2^w := by omega
    have prev := ih (y/2) (by omega) (by omega)
    let s := ripple false w (2*(x*(y/2))) x false
    have ⟨hs, hsg, hw⟩ := ripple_spec false w (2*(x*(y/2))) x false ht hx
    change s.word < _ at hs
    change s.gates = _ at hsg
    change s.word + 2^w*s.carry.toNat = 2*(x*(y/2))+x+0 at hw
    have sel := select_spec (low y) w s.word (2*(x*(y/2))) hs ht
    simp only [multiply, prev]
    change ((selectWord (low y) w s.word _).1, _+s.gates+(selectWord (low y) w s.word _).2) = _
    rw [sel.1, sel.2, hsg, Nat.succ_mul]
    congr 1
    · cases hbit : low y <;> simp [hbit] at ha ⊢
      · omega
      · cases hf : s.carry <;> simp [hf] at hw <;> omega
    · ring

structure Division where
  quot : ℕ
  rem : ℕ
  gates : ℕ
  deriving Repr

/-- Restoring division. At each dividend bit subtract the divisor from the
shifted remainder, then use the carry to keep the difference or restore the
old value. The carry also supplies the new quotient bit. -/
def divide (w : ℕ) : ℕ → ℕ → ℕ → Division
  | 0, _, _ => ⟨0, 0, 0⟩
  | n+1, x, y =>
    let h := divide w n (x/2) y
    let v := 2*h.rem + (low x).toNat
    let d := ripple true w v y true
    let sel := selectWord d.carry w d.word v
    ⟨2*h.quot + d.carry.toNat, sel.1, h.gates + d.gates + sel.2⟩

/-- Quotient and remainder are computed together with exactly 10wn gates
for n dividend bits and a w-bit padded remainder/subtractor. -/
theorem divide_spec (w n x y : ℕ) (hx : x < 2^n) (hy : 0 < y) (hwy : 2*y ≤ 2^w) :
    divide w n x y = ⟨x/y, x%y, n*(10*w)⟩ := by
  induction n generalizing x with
  | zero =>
    obtain rfl : x = 0 := by simpa using hx
    simp [divide]
  | succ n ih =>
    rw [pow_succ] at hx
    have prev := ih (x/2) (by omega)
    let r := (x/2)%y
    let q := (x/2)/y
    let v := 2*r + (low x).toNat
    have hr : r < y := Nat.mod_lt _ hy
    have hbit : (low x).toNat ≤ 1 := by cases low x <;> decide
    have hv : v < 2*y := by dsimp [v]; omega
    have hyw : y < 2^w := by omega
    let d := ripple true w v y true
    have ⟨hdw,hdg,hd⟩ := ripple_spec true w v y true (hv.trans_le hwy) hyw
    change d.word < 2^w at hdw
    change d.gates = 6*w at hdg
    change d.word + 2^w*d.carry.toNat + y + 1 = v + 2^w + 1 at hd
    have sel := select_spec d.carry w d.word v hdw (hv.trans_le hwy)
    have eqx : v + y*(2*q) = x := by
      have hh : r + y*q = x/2 := Nat.mod_add_div _ _
      dsimp [v]; nlinarith [low_split x,hh]
    simp only [divide, prev]
    change Division.mk (2*q+d.carry.toNat) (selectWord d.carry w d.word v).1
      (n*(10*w)+d.gates+(selectWord d.carry w d.word v).2) = _
    rw [sel.1, sel.2, hdg, Nat.succ_mul]
    cases h : d.carry <;> simp [h] at hd ⊢
    · have hQR := (Nat.div_mod_unique hy).mpr (And.intro eqx (by omega : v < y))
      rw [hQR.1,hQR.2]
      ring_nf
      trivial
    · have eq : d.word + y*(2*q+1) = x := by nlinarith [eqx, hd]
      have hQR := (Nat.div_mod_unique hy).mpr (And.intro eq (by omega : d.word < y))
      rw [hQR.1,hQR.2]
      ring_nf
      trivial

/-- Bitwise equality detector. Each input bit uses XOR, NOT and AND. -/
def equalWord : ℕ → ℕ → ℕ → Bool × ℕ
  | 0, _, _ => (true, 0)
  | w+1, x, y =>
    let hi := equalWord w (x/2) (y/2)
    (!(low x ^^ low y) && hi.1, hi.2 + 3)

theorem equal_spec (w x y : ℕ) (hx : x < 2^w) (hy : y < 2^w) :
    equalWord w x y = (decide (x=y), 3*w) := by
  induction w generalizing x y with
  | zero => have hx' : x=0 := by simpa using hx
            have hy' : y=0 := by simpa using hy
            simp [equalWord, hx',hy']
  | succ w ih =>
    rw [pow_succ] at hx hy
    have prev := ih (x/2) (y/2) (by omega) (by omega)
    simp only [equalWord, prev, Nat.mul_succ]
    congr 1
    by_cases h : x=y
    · subst y; simp
    · simp [h]
      intro hb
      by_contra hq
      rw [← low_split x, ← low_split y] at h
      simp_all

structure Fraction where
  num : ℕ
  den : ℕ
  gates : ℕ
  deriving Repr

/-- Bounded-width Euclidean convergent. Tests and arithmetic operate on
the verified bit routines. Recursive control follows the zero-remainder test. -/
def fraction (w a b : ℕ) : ℕ → Fraction
  | 0 =>
    let d := divide (w+1) w a b
    ⟨d.quot, 1, d.gates⟩
  | t+1 =>
    let d := divide (w+1) w a b
    let z := equalWord w d.rem 0
    if z.1 then ⟨d.quot, 1, d.gates + z.2⟩
    else
      let c := fraction w b d.rem t
      let m := multiply w w d.quot c.num
      let s := ripple false w m.1 c.den false
      ⟨s.word, c.num, d.gates + z.2 + c.gates + m.2 + s.gates⟩

private theorem add_word (w x y : ℕ) (hs : x+y < 2^w) :
    (ripple false w x y false).word = x+y ∧ (ripple false w x y false).gates = 6*w := by
  have ⟨_,hg,hc⟩ := ripple_spec false w x y false (by omega) (by omega)
  refine ⟨?_,hg⟩
  cases h : (ripple false w x y false).carry <;> simp [h] at hc <;> omega

theorem fraction_spec (w a b t : ℕ) (ha : a < 2^w) (hb : b < 2^w) (hb0 : 0 < b) :
    let f := fraction w a b t
    let c := OrderFindingDecoder.convergent a b t
    f.num = c.num ∧ f.den = c.den ∧ f.gates ≤ (t+1)*(30*(w+1)^2) := by
  have divOK (a b : ℕ) (ha : a < 2^w) (hb : b < 2^w) (hb0 : 0 < b) :=
    divide_spec (w+1) w a b ha hb0 (by rw [pow_succ]; omega)
  induction t generalizing a b with
  | zero =>
    simp [fraction, OrderFindingDecoder.convergent, divOK a b ha hb hb0]
    nlinarith
  | succ t ih =>
    have hr := Nat.mod_lt a hb0
    have hz := equal_spec w (a%b) 0 (hr.trans hb) (Nat.two_pow_pos w)
    simp only [fraction, OrderFindingDecoder.convergent, divOK a b ha hb hb0, hz,
      decide_eq_true_eq]
    by_cases h : a%b=0
    · simp [h]; nlinarith
    · simp only [ite_eq_right h]
      have hh := ih b (a%b) hb (hr.trans hb) (Nat.pos_of_ne_zero h)
      let c := OrderFindingDecoder.convergent b (a%b) t
      have bounds := OrderFindingDecoder.convergent_bounds b (a%b) t (Nat.pos_of_ne_zero h)
      have hsum : (a/b) * c.num + c.den < 2^w := by
        have ht := Nat.add_le_add (Nat.mul_le_mul_left (a/b) bounds.1) bounds.2.1
        rw [Nat.div_add_mod'] at ht
        exact ht.trans_lt ha
      have hm := multiply_spec w w (a/b) c.num ((Nat.div_le_self ..).trans_lt ha)
        (bounds.1.trans_lt hb) (by omega)
      have hs := add_word w ((a/b)*c.num) c.den hsum
      simp only [hh.1, hh.2.1, ← show c = OrderFindingDecoder.convergent b (a%b) t from rfl,
        hm, hs.1, hs.2, true_and]
      nlinarith [hh.2.2]

/-- Full double-width product, followed by binary long division. -/
def productMod (w N x y : ℕ) : ℕ × ℕ :=
  let m := multiply (2*w) w x y
  let d := divide (2*w+1) (2*w) m.1 N
  (d.rem, m.2+d.gates)

private theorem productMod_spec (w N x y : ℕ) (hx : x < 2^w) (hy : y < 2^w)
    (hN : 0 < N) (hw : N < 2^w) :
    (productMod w N x y).1 = x*y % N ∧ (productMod w N x y).2 ≤ 70*(w+1)^2 := by
  have hww : 2^w ≤ 2^(2*w) := Nat.pow_le_pow_right (by decide) (by omega)
  have hxy : x*y < 2^(2*w) := by
    rw [two_mul, pow_add]
    exact Nat.mul_lt_mul_of_lt_of_le hx hy.le (Nat.two_pow_pos _)
  have hm := multiply_spec (2*w) w x y (hx.trans_le hww) hy hxy
  have hd := divide_spec (2*w+1) (2*w) (x*y) N hxy hN (by rw [pow_succ]; omega)
  simp only [productMod, hm, hd, true_and]
  nlinarith

/-- Both possible products are evaluated, then one is selected by the
current exponent bit. The loop length is fixed by the exponent word width. -/
def power (w N a : ℕ) : ℕ → ℕ → ℕ × ℕ
  | 0, _ => (1,0)
  | n+1, r =>
    let h := power w N a n (r/2)
    let sq := productMod w N h.1 h.1
    let m := productMod w N sq.1 a
    let s := selectWord (low r) w m.1 sq.1
    (s.1,h.2+sq.2+m.2+s.2)

theorem power_spec (w N a n r : ℕ) (hN : 1 < N) (hw : N < 2^w) (ha : a < N)
    (hr : r < 2^n) : (power w N a n r).1 = a^r%N ∧
      (power w N a n r).2 ≤ n*(150*(w+1)^2) := by
  induction n generalizing r with
  | zero => obtain rfl : r = 0 := by simpa using hr
            simp [power, Nat.mod_eq_of_lt hN]
  | succ n ih =>
    rw [pow_succ] at hr
    have prev := ih (r/2) (by omega)
    let v := a^(r/2)%N
    let sq := v*v%N
    have hN0 : 0 < N := by omega
    have hv : v < 2^w := (Nat.mod_lt _ hN0).trans hw
    have hsq : sq < 2^w := (Nat.mod_lt _ hN0).trans hw
    have S := productMod_spec w N v v hv hv hN0 hw
    have M := productMod_spec w N sq a hsq (ha.trans hw) hN0 hw
    have sel := select_spec (low r) w (sq*a%N) sq ((Nat.mod_lt _ hN0).trans hw) hsq
    simp only [power, prev.1, ← show v = a^(r/2)%N from rfl, S.1, ← show sq = v*v%N from rfl,
      M.1, sel.1, sel.2]
    constructor
    · have hd := low_split r
      cases h : low r <;> simp [h] at hd ⊢
      · conv_rhs => rw [← hd, two_mul, pow_add]
        simp [sq,v]
      · conv_rhs => rw [← hd, pow_succ, two_mul, pow_add]
        simp [sq,v]
    · nlinarith [prev.2, S.2, M.2]

/-- Select the least passing denominator, keeping zero as the sentinel. -/
def update (w old d residue : ℕ) : ℕ × ℕ :=
  let ok := equalWord w residue 1
  let empty := equalWord w old 0
  let cmp := ripple true w d old true
  let smaller := selectWord cmp.carry w old d
  let candidate := selectWord empty.1 w d smaller.1
  let result := selectWord ok.1 w candidate.1 old
  (result.1, ok.2+empty.2+cmp.gates+smaller.2+candidate.2+result.2)

theorem update_spec (w old d residue : ℕ) (hw : 1 < 2^w)
    (ho : old < 2^w) (hd : d < 2^w) (hr : residue < 2^w) :
    update w old d residue =
      (if residue=1 then if old=0 then d else min d old else old, 24*w) := by
  have ok := equal_spec w residue 1 hr hw
  have em := equal_spec w old 0 ho (Nat.two_pow_pos _)
  let c := ripple true w d old true
  have ⟨hc,hg,he⟩ := ripple_spec true w d old true hd ho
  change c.word < 2^w at hc
  change c.gates = 6*w at hg
  change c.word + 2^w*c.carry.toNat + old + 1 = d + 2^w + 1 at he
  have flag : c.carry = true ↔ old ≤ d := by
    cases h : c.carry <;> simp [h] at he ⊢ <;> omega
  have s := select_spec c.carry w old d ho hd
  have sm : (selectWord c.carry w old d).1 = min d old := by
    rw [s.1]
    by_cases h : old ≤ d
    · simp [flag.mpr h, Nat.min_eq_right h]
    · simp [mt flag.mp h, Nat.min_eq_left (by omega : d ≤ old)]
  have v := select_spec (decide (old=0)) w d (min d old) hd ((Nat.min_le_right ..).trans_lt ho)
  let good := if old=0 then d else min d old
  have hgood : good < 2^w := by unfold good; split <;> omega
  have f := select_spec (decide (residue=1)) w good old hgood ho
  dsimp [good] at f
  simp only [decide_eq_true_eq] at f
  simp only [update, ok, em, ← show c = ripple true w d old true from rfl, sm, s.2, hg,
    v.1, v.2, decide_eq_true_eq, f.1, f.2, Prod.mk.injEq]
  constructor
  · simp
  · omega

/-- Binary refinement of the decoder. All operations on data values,
including comparisons and candidate selection, use the costed circuits. -/
def scan (w N a o Q : ℕ) : ℕ → ℕ × ℕ
  | 0 => (0,0)
  | t+1 =>
    let h := scan w N a o Q t
    let f := fraction w o Q t
    let m := power w N a w f.den
    let u := update w h.1 f.den m.1
    (u.1, h.2+f.gates+m.2+u.2)

private def scanLimit (w t : ℕ) :=
    t*(t+1)*(30*(w+1)^2) + t*w*(150*(w+1)^2) + t*(24*w)

private theorem scan_spec (w N a o Q t : ℕ) (hN : 1 < N) (ha : a < N) (ho : o < Q)
    (hnw : N < 2^w) (hqw : Q < 2^w) :
    (scan w N a o Q t).1 = (OrderFindingDecoder.scan N a o Q t).order ∧
    (scan w N a o Q t).1 < 2^w ∧ (scan w N a o Q t).2 ≤ scanLimit w t := by
  induction t with
  | zero => simp [scan, OrderFindingDecoder.scan, scanLimit]
  | succ t ih =>
    let c := OrderFindingDecoder.convergent o Q t
    let p := (OrderFindingDecoder.scan N a o Q t).order
    have hb : 0 < Q := by omega
    have hh := fraction_spec w o Q t (ho.trans hqw) hqw hb
    have hc := OrderFindingDecoder.convergent_bounds o Q t hb
    have hd : c.den < 2^w := hc.2.1.trans_lt hqw
    have hm := power_spec w N a w c.den hN hnw ha hd
    let res := a^c.den%N
    have hr : res < 2^w := (Nat.mod_lt _ (by omega : 0 < N)).trans hnw
    have hp : p < 2^w := by unfold p; rw [← ih.1]; exact ih.2.1
    have hu := update_spec w p c.den res (by omega) hp hd hr
    have hpower : (FactoringReduction.modPowerRun N a c.den).1 = res :=
      FactoringReduction.modPower_spec ..
    have expected : (OrderFindingDecoder.scan N a o Q (t+1)).order =
        (if res=1 then if p=0 then c.den else min c.den p else p) := by
      change (if (FactoringReduction.modPowerRun N a c.den).1 = 1 ∧ 0 < c.den then
        if p=0 then c.den else min c.den p else p) = _
      have hd0 : 0 < c.den := hc.2.2.1
      simp only [hpower, hd0, and_true]
    simp only [scan, ih.1, hh.2.1, ← show c = OrderFindingDecoder.convergent o Q t from rfl,
      ← show p = (OrderFindingDecoder.scan N a o Q t).order from rfl, hm.1,
      ← show res = a^c.den%N from rfl, hu, expected, true_and]
    constructor
    · split
      next => split <;> omega
      next => exact hp
    · apply (Nat.add_le_add_right (Nat.add_le_add (Nat.add_le_add ih.2.2 hh.2.2) hm.2) _).trans
      unfold scanLimit
      nlinarith [Nat.zero_le ((t+1)*(30*(w+1)^2))]

/-- At common input width w, the Boolean implementation returns the exact
natural-arithmetic decoder output with at most 1000(w+1)⁴ bit gates. This
counts data-path logic in a branching computation; fixed-width indexing,
shifts and wiring are free. -/
theorem decoder_bit_bound (w N a o Q : ℕ) (hN : 1 < N) (ha : a < N)
    (ho : o < Q) (hnw : N < 2^w) (hqw : Q < 2^w) :
    let t := 2*(Q.log2+1)+1
    (scan w N a o Q t).1 = (OrderFindingDecoder.decode N a o Q).order ∧
      (scan w N a o Q t).2 ≤ 1000*(w+1)^4 := by
  let t := 2*(Q.log2+1)+1
  have h := scan_spec w N a o Q t hN ha ho hnw hqw
  refine ⟨h.1, h.2.2.trans ?_⟩
  have hlog := (Nat.log2_lt (by omega : Q ≠ 0)).mpr hqw
  have ht : t ≤ 2*w+1 := by dsimp [t]; omega
  calc
    scanLimit w t ≤ scanLimit w (2*w+1) := by unfold scanLimit; gcongr
    _ ≤ _ := by unfold scanLimit; nlinarith

/-- The standalone bit decoder chooses its word width directly from the inputs. -/
def decode (N a o Q : ℕ) : ℕ × ℕ :=
  scan ((max N Q).log2 + 1) N a o Q (2 * (Q.log2 + 1) + 1)

theorem decode_input_bound (N a o Q : ℕ) (hN : 1 < N) (ha : a < N) (ho : o < Q) :
    (decode N a o Q).1 = (OrderFindingDecoder.decode N a o Q).order ∧
    (decode N a o Q).2 ≤ 1000 * ((max N Q).log2 + 2)^4 :=
  decoder_bit_bound _ _ _ _ _ hN ha ho ((Nat.le_max_left ..).trans_lt Nat.lt_log2_self)
    ((Nat.le_max_right ..).trans_lt Nat.lt_log2_self)

end FQChem.Complexity.OrderFindingBitCost
