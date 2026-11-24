module

public import FQChemQatlib.Complexity.SimonOracleMachines

/-!
# Simon's unary language against clocked probabilistic oracle Turing machines

The classical control is a finite transition table. It has a work tape, a query
tape, one fresh fair coin per transition, and unit-cost access to one fixed
length-preserving oracle. A query replaces the query word with its answer.
-/

@[expose] public section
noncomputable section

namespace FQChem.Complexity.SimonOracleMachines

open Qatlib.Concepts.PauliClifford.ExactRank
open Qatlib.Papers.QPowerSimon97.StandardDefs
open Qatlib.Papers.QPowerSimon97.Recovery
open Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.HspRecovery.ReductionCore
open Qatlib.Concepts.LinearLearning.ConcisePipeline.CostedLaw
open scoped ENNReal

inductive Motion | left | stay | right


instance : Countable Motion := by
  let code : Motion → ℕ
    | .left => 0
    | .stay => 1
    | .right => 2
  exact Function.Injective.countable (f := code) (by
    intro a b; cases a <;> cases b <;> simp [code])

abbrev Symbol := Option Bool

structure Tape where
  left : List Symbol
  right : List Symbol

namespace Tape

def cells (t : Tape) := t.left.length + t.right.length

def read (t : Tape) : Symbol := t.right.head?.join

/-- Two one-sided lists represent a right-infinite tape, initially blank
outside its stored prefix. A left move at cell zero stays there. -/
def step (t : Tape) (v : Symbol) : Motion → Tape
  | .right => ⟨v :: t.left, t.right.tail⟩
  | .stay => ⟨t.left, v :: t.right.tail⟩
  | .left => match t.left with
    | [] => ⟨[], v :: t.right.tail⟩
    | s :: ss => ⟨ss, s :: v :: t.right.tail⟩

theorem cellsStep (t : Tape) (v : Symbol) (m : Motion) :
    (t.step v m).cells ≤ t.cells + 1 := by
  obtain ⟨l,r⟩ := t
  cases m <;> cases l <;> cases r <;> simp [cells, step] <;> omega

/-- The query word starts at cell zero and ends at the first blank. -/
def word (t : Tape) : List Bool :=
  (((t.left.reverse ++ t.right).takeWhile Option.isSome).map (fun s => s.getD false))

theorem wordLength (t : Tape) : t.word.length ≤ t.cells := by
  simpa [word, cells] using (List.takeWhile_prefix (l := t.left.reverse ++ t.right) Option.isSome).length_le

def load (xs : List Bool) : Tape := ⟨[], xs.map some⟩

def bits (xs : List Bool) : BooleanVec xs.length := fun i => if xs.get i then 1 else 0

def reply {w : ℕ} (y : BooleanVec w) : Tape := load (List.ofFn fun i => decide (y i ≠ 0))

@[simp] theorem replyCells {w : ℕ} (y : BooleanVec w) : (reply y).cells = w := by
  simp [reply, load, cells]

end Tape

/-- A work-tape and query-tape write/move take one simultaneous transition.
A read-only fair coin and both scanned symbols index the transition table. -/
inductive Instruction where
  | halt (answer : Bool)
  | step (pc : ℕ) (work : Symbol) (workMove : Motion) (query : Symbol) (queryMove : Motion)
  | ask (pc : ℕ)

instance : Countable Instruction := by
  let code : Instruction → Bool ⊕ (ℕ × Symbol × Motion × Symbol × Motion) ⊕ ℕ
    | .halt b => .inl b
    | .step pc v m u h => .inr (.inl (pc,v,m,u,h))
    | .ask pc => .inr (.inr pc)
  exact Function.Injective.countable (f := code) (by
    intro a b; cases a <;> cases b <;> simp [code])

abbrev Machine := List Instruction

structure Configuration where
  pc : ℕ
  work : Tape
  query : Tape

namespace Configuration

def start (n : ℕ) : Configuration := ⟨0, Tape.load (List.replicate n true), Tape.load []⟩

def scanCode : Symbol → ℕ
  | none => 0
  | some false => 1
  | some true => 2

/-- Eighteen table entries per control state (3 × 3 scanned symbols × 2 coins).
A missing transition rejects. -/
def transition (c : Configuration) (M : Machine) (coin : Bool) : Instruction :=
  M[18 * c.pc + 6 * scanCode c.work.read + 2 * scanCode c.query.read + coin.toNat]?.getD (.halt false)

def advance (c : Configuration) (pc : ℕ) (v : Symbol) (m : Motion) (u : Symbol) (h : Motion) :
    Configuration := ⟨pc, c.work.step v m, c.query.step u h⟩

def answered (c : Configuration) (pc : ℕ) (y : BooleanVec c.query.word.length) : Configuration :=
  ⟨pc, c.work, Tape.reply y⟩

end Configuration

/-- Operational semantics. Exhausting the clock returns false. -/
def execute (M : Machine) (O : Oracle) : (t : ℕ) → (Fin t → Bool) → Configuration → Bool
  | 0, _, _ => false
  | t+1, coins, c => match c.transition M (coins 0) with
    | .halt b => b
    | .step pc v m u h => execute M O t (Fin.tail coins) (c.advance pc v m u h)
    | .ask pc => execute M O t (Fin.tail coins)
        (c.answered pc ((O c.query.word.length).2 (Tape.bits c.query.word)))

/-- A local classical transition consumes clock time and issues no oracle query. -/
def Tree.pad {W : ℕ} : {t : ℕ} → Tree W t → Tree W (t+1)
  | _, .halt b => .halt b
  | _, .ask w hw x next => .ask w hw x (fun y => (next y).pad)

theorem Tree.padOutput {W t : ℕ} (O : Oracle) (tree : Tree W t) :
    tree.pad.output O = tree.output O := by
  induction tree with
  | halt => rfl
  | ask w hw x next ih => exact ih ((O w).2 x)

/-- Expose the queries of a clocked execution. A blank initial query tape
can reach at most t cells in t clock steps, including after oracle answers. -/
def unroll (M : Machine) (W : ℕ) : (t : ℕ) → (Fin t → Bool) →
    (c : Configuration) → c.query.cells + t ≤ W → Tree W t
  | 0, _, _, _ => .halt false
  | t+1, coins, c, hw => match c.transition M (coins 0) with
    | .halt b => .halt b
    | .step pc v m u h =>
      (unroll M W t (Fin.tail coins) (c.advance pc v m u h) (by
        have := c.query.cellsStep u h
        change (c.query.step u h).cells + t ≤ W
        omega)).pad
    | .ask pc => .ask c.query.word.length (by have := c.query.wordLength; omega) (Tape.bits c.query.word)
        (fun y => unroll M W t (Fin.tail coins) (c.answered pc y) (by
          change (Tape.reply y).cells + t ≤ W
          rw [Tape.replyCells]
          have := c.query.wordLength
          omega))

/-- Transcript extraction preserves the output for every tape of coins and
every fixed oracle, including calls whose width differs from the input width. -/
theorem unrollOutput (M : Machine) (O : Oracle) (W t : ℕ) (coins : Fin t → Bool)
    (c : Configuration) (h : c.query.cells + t ≤ W) :
    (unroll M W t coins c h).output O = execute M O t coins c := by
  induction t generalizing c with
  | zero => rfl
  | succ t ih =>
    cases op : c.transition M (coins 0) with
    | halt b => simp [unroll, execute, op, Tree.output]
    | step pc v m u h =>
      simpa only [unroll, execute, op, Tree.padOutput] using
        ih (Fin.tail coins) (c.advance pc v m u h) _
    | ask pc =>
      simpa only [unroll, execute, op, Tree.output] using
        ih (Fin.tail coins) (c.answered pc ((O _).2 (Tape.bits c.query.word))) _

def success (M : Machine) (O : Oracle) (n t : ℕ) : ℝ≥0∞ :=
  expectation (PMF.uniformOfFintype' (Fin t → Bool))
    fun coins => if execute M O t coins (.start n) = (O n).1 then 1 else 0

/-- Floor of the 2^(n/4) transition budget. -/
def clock (n : ℕ) : ℕ := ⌊(2 : ℝ)^((n : ℝ)/4)⌋₊

/-- A single oracle defeats every finite probabilistic oracle machine at
arbitrarily large unary inputs under an exponential clock. The same oracle
admits the uniform Simon routine using 3n² calls and 6n³ local gates. -/
theorem turingSeparation :
    ∃ O : Oracle, (∀ n, simonGoodDraw n (O n)) ∧
      (∀ n ≥ 64, ENNReal.ofReal (7/8) ≤ simonQuantumSuccess n (2*n) n (O n)) ∧
      (∀ n, (simonExactLedger n (2*n) n).oracleQueries = 3*n^2 ∧
        (simonExactLedger n (2*n) n).localGates = 6*n^3) ∧
      ∀ M : Machine, ∀ N, ∃ n ≥ N, success M O n (clock n) < ENNReal.ofReal (2/3) := by
  obtain ⟨machine, enumerates⟩ := exists_surjective_nat Machine
  let tree (m n : ℕ) (coins : Fin (clock n) → Bool) :=
    unroll (machine m) (clock n) (clock n) coins (.start n) (by simp [Configuration.start, Tape.load, Tape.cells])
  let program (m n : ℕ) := (PMF.uniformOfFintype' (Fin (clock n) → Bool)).map (tree m n)
  obtain ⟨O, hg, hq, hc⟩ := oracleSeparation (fun _ => clock) (fun _ => clock) program
    (fun _ n => Nat.floor_le (by positivity))
  refine ⟨O, hg, hq, fun n => ⟨(simonPaperScheduleLedger n).1, (simonPaperScheduleLedger n).2.2.1⟩, ?_⟩
  intro M N
  obtain ⟨m, rfl⟩ := enumerates M
  obtain ⟨n, hn, h⟩ := hc m N
  refine ⟨n, hn, ?_⟩
  simpa only [program, Tree.success, expectation_map, tree, unrollOutput, success] using h

/-- The unary language is false on any input containing a zero bit. -/
def label (O : Oracle) (x : List Bool) : Bool := x.all id && (O x.length).1

theorem unaryLabel (O : Oracle) (n : ℕ) : label O (List.replicate n true) = (O n).1 := by
  simpa [label] using congrArg (fun w => (O w).1) (List.length_replicate (n := n) (a := true))

/-- The fixed finite control supplies the answers at the fewer than 64 small widths.
At larger unary inputs use Simon's amplified Fourier-sampling circuit and decoder. -/
def quantumLaw (small : Fin 64 → Bool) (O : Oracle) (x : List Bool) : PMF Bool :=
  if x.all id then
    if h : x.length < 64 then PMF.pure (small ⟨_, h⟩)
    else simonAmplifiedReject (O x.length).2 (x.length + 2*x.length) x.length
  else PMF.pure false

theorem amplifiedCorrect (n : ℕ) (e : Entry n) :
    simonAmplifiedReject e.2 (n + 2*n) n e.1 = simonQuantumSuccess n (2*n) n e := by
  obtain ⟨b, f⟩ := e
  cases b with
  | true => rfl
  | false =>
    let P := simonAmplifiedReject f (n + 2*n) n
    have ht : P true ≠ ⊤ := ne_top_of_le_ne_top ENNReal.one_ne_top (PMF.coe_le_one _ _)
    exact ENNReal.eq_sub_of_add_eq ht ((add_comm (P false) (P true)).trans (simonReject_total f _ _))

/-- Charged operations for the paper schedule, including the actual Boolean Gaussian
decoder on every block. The final scan has n candidates of at most n bits each. -/
def quantumWork (n : ℕ) (rows : Fin n → Fin (n+2*n) → Reg n) : ℕ :=
  let ledger := simonExactLedger n (2*n) n
  (simonLocalDecision n (n+2*n) n).length + ledger.oracleQueries + ledger.measurements +
    ledger.recordConversion + (∑ i, (decodeSimonWithCost (rows i)).2) + n*(n+1)

theorem polynomialWork (n : ℕ) (rows : Fin n → Fin (n+2*n) → Reg n) :
    quantumWork n rows ≤ 100*(n+1)^4 := by
  obtain ⟨hq, hm, hg, hr⟩ := simonPaperScheduleLedger n
  dsimp only [quantumWork]
  rw [(simonExactLedger_eq n (2*n) n).1, hq, hm, hg, hr]
  let b := 10*((n+2*n)*n^2+n^3+(n+2*n)*n+n^2+n+1)
  have bd : ∑ i, (decodeSimonWithCost (rows i)).2 ≤ ∑ _ : Fin n, b :=
    Finset.sum_le_sum (fun i _ => (boolean_gaussian_actual_operation_bound (rows i)).2.1)
  calc
    _ ≤ 6*n^3 + 3*n^2 + 3*n^2 + 3*n^3 + (∑ _ : Fin n, b) + n*(n+1) := by omega
    _ ≤ _ := by simp [b]; ring_nf; omega

/-- Any constant multiple of 2^(n/8) eventually fits in the integer clock. -/
theorem clockDominates (C : ℝ) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → ∀ t : ℕ, (t : ℝ) ≤ C * (2 : ℝ)^((n : ℝ)/8) → t ≤ clock n := by
  obtain ⟨k, hk⟩ := pow_unbounded_of_one_lt C (by norm_num : (1 : ℝ) < 2)
  refine ⟨8*k, ?_⟩
  intro n hn t ht
  have hk' : (k : ℝ) ≤ (n : ℝ)/8 := by
    have z : (8:ℝ)*(k:ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
    linarith
  have c : C ≤ (2 : ℝ)^((n : ℝ)/8) := by
    exact hk.le.trans (by simpa using Real.rpow_le_rpow_of_exponent_le (by norm_num : (1:ℝ) ≤ 2) hk')
  apply Nat.le_floor
  calc
    (t : ℝ) ≤ C * (2 : ℝ)^((n : ℝ)/8) := ht
    _ ≤ (2 : ℝ)^((n : ℝ)/8) * 2^((n : ℝ)/8) := by gcongr
    _ = (2 : ℝ)^((n : ℝ)/4) := by rw [← Real.rpow_add (by norm_num : (0:ℝ) < 2)]; congr 1; ring

/-- Simon's Theorem 3.4 in the function-oracle machine model. A single unary language
has bounded-error quantum predictions on every input, an explicit polynomial resource
bound and infinitely many hard unary lengths for each finite two-tape oracle PTM. -/
theorem unaryLanguageSeparation :
    ∃ (O : Oracle) (small : Fin 64 → Bool), (∀ n, simonGoodDraw n (O n)) ∧
      (∀ x, ENNReal.ofReal (7/8) ≤ quantumLaw small O x (label O x)) ∧
      (∀ n rows, quantumWork n rows ≤ 100*(n+1)^4) ∧
      ∀ M : Machine, ∀ N, ∃ n ≥ N, success M O n (clock n) < ENNReal.ofReal (2/3) := by
  obtain ⟨O, hg, hq, _, hc⟩ := turingSeparation
  refine ⟨O, fun i => (O i).1, hg, ?_, polynomialWork, hc⟩
  intro x
  by_cases hx : x.all id = true
  · by_cases hn : x.length < 64
    · simp [quantumLaw, label, hx, hn]; norm_num
    · simpa only [quantumLaw, hx, ite_true, dite_eq_right hn, label, Bool.true_and,
        amplifiedCorrect] using hq x.length (by omega)
  · simp [quantumLaw, label, Bool.eq_false_iff.mpr hx]; norm_num

end FQChem.Complexity.SimonOracleMachines
