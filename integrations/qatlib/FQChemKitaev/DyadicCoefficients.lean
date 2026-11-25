module

public import Qatlib.Concepts.QueryComplexity.DegreeMethod.QmaCompletenessNativeOutput
public import Qatlib.Concepts.QmaCompleteness.HistoryHam.QmaCompletenessRefinedDefs
public import Mathlib.Data.Nat.Size
import Mathlib.Tactic

/-!
# Bit-serial materialization of the Hadamard and T numerators

Qatlib's `floor_root_pos` and `floor_root_neg` identify the required
rounding with a native integer square root. Here a restoring square-root
algorithm operates directly on lists of bits, least significant first.
At each precision digit it shifts by prepending bits and uses a single
ripple-borrow subtraction. The counter measures full-subtractor positions
visited and a constant number of register-list operations per digit.

* [Qatlib, exact rounding formulas and coefficient bounds](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/UniformBqp/FiniteGateWord/QmaCompletenessNumerics.lean#L114)
* [Qatlib, finite-gate coefficient tags](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QueryComplexity/DegreeMethod/QmaCompletenessGates.lean#L105)
-/

@[expose] public section
namespace FQChem.Complexity.Kitaev.DyadicCoefficients
open Qatlib.Concepts.UniformBqp.FiniteGateWord
open Qatlib.Concepts.QueryComplexity.DegreeMethod
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Foundations.PureStateMath

def digit (b : Bool) : ℕ := if b then 1 else 0

def value : List Bool → ℕ
  | [] => 0
  | b :: xs => digit b + 2 * value xs

theorem value_lt (xs : List Bool) : value xs < 2^xs.length := by
  induction xs with
  | nil => decide
  | cons b xs ih =>
    cases b <;> simp [value, digit, pow_succ] <;> omega

def borrowBit (a b c : Bool) := (!a && (b || c)) || (b && c)

private theorem bitSubtract (a b c : Bool) :
    digit (a ^^ b ^^ c) + digit b + digit c = digit a + 2*digit (borrowBit a b c) := by
  cases a <;> cases b <;> cases c <;> decide

structure Subtraction where
  bits : List Bool
  borrow : Bool
  positions : ℕ
  deriving Repr

/-- Fixed-width unsigned subtraction with zero extension of the subtrahend.
The recursive call consumes one bit from the minuend at a time. -/
def subtract (x y : List Bool) (c : Bool) : Subtraction :=
  match x with
  | [] => ⟨[], c, 0⟩
  | a :: xs =>
    let b := y.headD false
    let s := subtract xs y.tail (borrowBit a b c)
    ⟨(a ^^ b ^^ c) :: s.bits, s.borrow, 1+s.positions⟩

theorem subtract_shape (x y : List Bool) (c : Bool) :
    (subtract x y c).bits.length = x.length ∧ (subtract x y c).positions = x.length := by
  induction x generalizing y c with
  | nil => exact ⟨rfl,rfl⟩
  | cons a xs ih =>
    obtain ⟨h1,h2⟩ := ih y.tail (borrowBit a (y.headD false) c)
    simp only [subtract, List.length_cons, h1, h2, Nat.add_comm, and_self]

/-- The final borrow is the coefficient of 2^width in the subtraction identity. -/
theorem subtract_value (x y : List Bool) (c : Bool) (hlen : y.length ≤ x.length) :
    value (subtract x y c).bits + value y + digit c =
      value x + 2^x.length * digit (subtract x y c).borrow := by
  induction x generalizing y c with
  | nil =>
    have : y = [] := by simpa using hlen
    subst y; simp [subtract, value]
  | cons a xs ih =>
    have ht : y.tail.length ≤ xs.length := by simp at hlen ⊢; omega
    have he := ih y.tail (borrowBit a (y.headD false) c) ht
    have hd := bitSubtract a (y.headD false) c
    have hy : value y = digit (y.headD false) + 2*value y.tail := by cases y <;> rfl
    simp only [subtract, value, List.length_cons, pow_succ]
    rw [hy]
    linear_combination hd + 2 * he

theorem subtract_borrow (x y : List Bool) (c : Bool) (hlen : y.length ≤ x.length) :
    (subtract x y c).borrow = false ↔ value y + digit c ≤ value x := by
  have h := subtract_value x y c hlen
  have hs := value_lt (subtract x y c).bits
  rw [(subtract_shape x y c).1] at hs
  cases hbit : (subtract x y c).borrow <;> simp [hbit, digit] at h ⊢ <;> omega

structure RootRun where
  root : List Bool
  remainder : List Bool
  steps : ℕ
  deriving Repr

/-- The trial subtraction is 4r − (4q+1). A successful subtraction appends
a one to the root, and an underflow appends a zero. -/
def next (s : RootRun) : RootRun :=
  let high := false :: false :: s.remainder
  let trial := true :: false :: s.root
  let d := subtract high trial false
  ⟨(!d.borrow) :: s.root, if d.borrow then high else d.bits, s.steps + d.positions + 8⟩

def run : ℕ → RootRun
  | 0 => ⟨[true], [true], 1⟩
  | b+1 => next (run b)

/-- The root and remainder retain explicit binary widths. The step count is
the exact number charged by the digit program. -/
theorem run_shape (b : ℕ) : (run b).root.length = b+1 ∧
    (run b).remainder.length = 2*b+1 ∧ (run b).steps = b*b + 10*b + 1 := by
  induction b with
  | zero => decide
  | succ b ih =>
    obtain ⟨hq,hr,hc⟩ := ih
    simp only [run, next, List.length_cons, hq, (subtract_shape _ _ _).2, hr, hc]
    constructor
    · trivial
    constructor
    · split <;> simp only [List.length_cons, (subtract_shape _ _ _).1, hr] <;> omega
    · ring

private theorem next_value (s : RootRun) (hw : s.root.length ≤ s.remainder.length)
    (hr : value s.remainder ≤ 2*value s.root) (hp : 0 < value s.remainder) :
    (value (next s).root)^2 + value (next s).remainder =
        4*((value s.root)^2 + value s.remainder) ∧
    value (next s).remainder ≤ 2*value (next s).root ∧ 0 < value (next s).remainder := by
  let q := value s.root
  let r := value s.remainder
  let x := false :: false :: s.remainder
  let y := true :: false :: s.root
  have hx : value x = 4*r := by simp [x,r,value,digit]; omega
  have hy : value y = 4*q+1 := by simp [y,q,value,digit]; omega
  have hl : y.length ≤ x.length := by simpa [y,x] using hw
  have he := subtract_value x y false hl
  have hc := subtract_borrow x y false hl
  rw [hx,hy] at he hc
  change r ≤ 2*q at hr
  change 0 < r at hp
  have root : value (next s).root = digit (!(subtract x y false).borrow) + 2*q := rfl
  have rem : (next s).remainder = if (subtract x y false).borrow then x else (subtract x y false).bits := rfl
  rw [root, rem]
  change _ = 4*(q^2+r) ∧ _ ∧ _
  cases hb : (subtract x y false).borrow with
  | true =>
    have hlt : 4*r < 4*q+1 := by simpa [hb, digit] using hc
    simp only [Bool.not_true, digit, Bool.false_eq_true, ite_false, zero_add, ite_true, hx]
    exact ⟨by ring, by omega, by omega⟩
  | false =>
    have hval : value (subtract x y false).bits + (4*q+1) = 4*r := by simpa [hb, digit] using he
    simp only [Bool.not_false, digit, ite_true, Bool.false_eq_true, ite_false]
    exact ⟨by linear_combination hval, by omega, by omega⟩

/-- The computed remainder is strictly positive, so the native square-root
ceiling always exceeds the computed floor by one for these radicands. -/
theorem run_certificate (b : ℕ) :
    (value (run b).root)^2 + value (run b).remainder = 2^(2*b+1) ∧
    value (run b).remainder ≤ 2*value (run b).root ∧ 0 < value (run b).remainder := by
  induction b with
  | zero => decide
  | succ b ih =>
    have shape := run_shape b
    have hn := next_value (run b) (by omega) ih.2.1 ih.2.2
    refine ⟨?_,hn.2⟩
    rw [run, hn.1, ih.1, show 2*(b+1)+1 = 2*b+1+2 by omega, pow_add]
    ring

theorem run_isqrt (b : ℕ) : value (run b).root = Nat.sqrt (2^(2*b+1)) := by
  apply Nat.eq_sqrt'.mpr
  have h := run_certificate b
  constructor <;> nlinarith [h.1,h.2.1]


structure Increment where
  bits : List Bool
  positions : ℕ
  deriving Repr

/-- A ripple-carry increment, stopping as soon as a zero absorbs the carry. -/
def increment : List Bool → Increment
  | [] => ⟨[true],1⟩
  | false :: xs => ⟨true :: xs,1⟩
  | true :: xs =>
    let z := increment xs
    ⟨false :: z.bits,z.positions+1⟩

theorem increment_spec (xs : List Bool) : value (increment xs).bits = value xs + 1 ∧
    (increment xs).positions ≤ xs.length + 1 ∧ (increment xs).bits.length ≤ xs.length + 1 := by
  induction xs with
  | nil => decide
  | cons b xs ih =>
    cases b <;> simp [increment,value,digit,ih.1] <;> omega

private theorem value_tail (xs : List Bool) : value xs.tail = value xs / 2 := by
  cases xs with
  | nil => rfl
  | cons b xs => cases b <;> simp [value,digit]; omega

structure SignedOutput where
  negative : Bool
  magnitude : List Bool
  steps : ℕ
  deriving Repr

def SignedOutput.number (v : SignedOutput) : ℤ :=
  if v.negative then -(value v.magnitude : ℤ) else value v.magnitude

/-- Round the positive root by adding one and dropping the low bit. Negation
is a sign bit. All lists are little-endian. -/
def rootOutput (b : ℕ) (neg : Bool) : SignedOutput :=
  let s := run b
  let rounded := increment s.root
  ⟨neg, rounded.bits.tail, s.steps + rounded.positions + 2⟩

theorem rootOutput_correct (b : ℕ) :
    (rootOutput b false).number = rootPosNumerator b ∧
    (rootOutput b true).number = rootNegNumerator b := by
  let q := value (run b).root
  have mag : value (rootOutput b false).magnitude = (q+1)/2 :=
    (value_tail _).trans (congrArg (· / 2) (increment_spec _).1)
  have hns : Nat.sqrt (2^(2*b+1)) * Nat.sqrt (2^(2*b+1)) ≠ 2^(2*b+1) := by
    rw [← run_isqrt]
    obtain ⟨he,_,hp⟩ := run_certificate b
    nlinarith
  change (value (rootOutput b false).magnitude : ℤ) = _ ∧
    -(value (rootOutput b false).magnitude : ℤ) = _
  rw [mag, rootPosNumerator, rootNegNumerator, ceilSqrtNative, ite_eq_right hns, ← run_isqrt]
  change (((q+1)/2 : ℕ) : ℤ) = ((q : ℤ)+1)/2 ∧ -(((q+1)/2 : ℕ) : ℤ) = (1 - ((q+1 : ℕ) : ℤ))/2
  omega

theorem rootOutput_resources (b : ℕ) (neg : Bool) :
    (rootOutput b neg).steps ≤ b*b+11*b+5 ∧ (rootOutput b neg).magnitude.length ≤ b+1 := by
  have sh := run_shape b
  have si := increment_spec (run b).root
  simp only [rootOutput, List.length_tail]
  omega

/-- Materialize all five real atomic numerators, retaining a signed binary
value instead of converting the lists back to machine integers. -/
def materialize (b : ℕ) : Atom → SignedOutput
  | .zero => ⟨false,[],1⟩
  | .one => ⟨false,List.replicate b false ++ [true],2*b+2⟩
  | .negOne => ⟨true,List.replicate b false ++ [true],2*b+2⟩
  | .root => rootOutput b false
  | .negRoot => rootOutput b true

private theorem pow2bits (b : ℕ) : value (List.replicate b false ++ [true]) = 2^b := by
  induction b with
  | zero => rfl
  | succ b ih => simp [List.replicate_succ, value, digit, ih, pow_succ, Nat.mul_comm]

/-- Exact value, magnitude width and polynomial traversal cost for every atom. -/
theorem materialize_spec (b : ℕ) (a : Atom) :
    (materialize b a).number = atomNumerator b a ∧
    (materialize b a).magnitude.length ≤ b+1 ∧ (materialize b a).steps ≤ b*b+11*b+5 := by
  cases a with
  | root => exact ⟨(rootOutput_correct b).1,(rootOutput_resources _ _).2,(rootOutput_resources _ _).1⟩
  | negRoot => exact ⟨(rootOutput_correct b).2,(rootOutput_resources _ _).2,(rootOutput_resources _ _).1⟩
  | zero => simp [materialize, SignedOutput.number, atomNumerator,value]
  | one | negOne => simp [materialize, SignedOutput.number, atomNumerator, pow2bits]; omega

/-- The published nearest-rounding real floor is computed by the bit algorithm. -/
theorem materialize_floor (b : ℕ) (a : Atom) :
    (materialize b a).number = ⌊atomVal a * (2:ℝ)^b + 1/2⌋ :=
  (materialize_spec b a).1.trans (floor_atom b a).symm

def gateOutput (n b : ℕ) (g : FiniteGateCode) (x y : Reg n) : SignedOutput × SignedOutput :=
  let (r,i) := rawTag n g x y
  (materialize b r, materialize b i)

/-- The two emitted signed bitstrings are precisely Qatlib's raw gate
coefficients. The counter here covers numerical evaluation after tag selection. -/
theorem gateOutput_spec (n b : ℕ) (g : FiniteGateCode) (x y : Reg n) :
    let p := gateOutput n b g x y
    (p.1.number,p.2.number) = rawCoeff n b g x y ∧
    p.1.magnitude.length ≤ b+1 ∧ p.2.magnitude.length ≤ b+1 ∧
    p.1.steps + p.2.steps ≤ 2*(b*b+11*b+5) := by
  obtain ⟨hr,lr,cr⟩ := materialize_spec b (rawTag n g x y).1
  obtain ⟨hi,li,ci⟩ := materialize_spec b (rawTag n g x y).2
  exact ⟨Prod.ext hr hi,lr,li,by dsimp [gateOutput]; omega⟩


open Qatlib.Concepts.QmaCompleteness.HistoryHam

/-- The pinned history-state circuit precision is b=3(q+g)+64. For one
atomic numerator this gives a quadratic bound in gate count plus wire count. -/
theorem circuit_atom_cost (C : QmaHistoryCircuit) (a : Atom) :
    let s := C.qubits + C.gates.length
    (materialize (qmaClause2Bits C) a).steps ≤ 9*s^2 + 417*s + 4805 := by
  apply (materialize_spec _ _).2.2.trans_eq
  dsimp only [qmaClause2Bits]
  ring

/-- After the clock guards select their terms, the actual emitted integer
propagation table uses the signed bits of the forward and reverse gate entries.
This equality includes the diagonal clock contribution and both complex signs. -/
theorem propagation_from_bits {m : ℕ} (n b : ℕ) (i : Fin m) (g : FiniteGateCode)
    (p q : Clock m × Reg n) :
    let diag : ℤ := if regEq p.1 q.1 && regEq p.2 q.2 then
      (if postBool i p.1 then (2:ℤ)^b else 0) + (if preBool i p.1 then (2:ℤ)^b else 0) else 0
    let f := gateOutput n b g p.2 q.2
    let r := gateOutput n b g q.2 p.2
    let fwd := if hopBool i p.1 q.1 then (f.1.number,f.2.number) else (0,0)
    let rev := if hopBool i q.1 p.1 then (r.1.number,r.2.number) else (0,0)
    propagationCoeff n b i g p q = (diag - fwd.1 - rev.1,-fwd.2 + rev.2) := by
  dsimp only
  rw [(gateOutput_spec n b g p.2 q.2).1, (gateOutput_spec n b g q.2 p.2).1]
  rfl

end FQChem.Complexity.Kitaev.DyadicCoefficients
