module

public import FQChemKitaev.HistoryHamiltonian
import Mathlib.Tactic

/-!
# A costed compiler for serialized five-local Hamiltonian templates

The alphabet has three symbols. Row and field markers frame unary natural
numbers. The source gives the register width and output wire, a sorted list of
zero-initialized wires, and gate instruction rows. The target gives width, padded
time, and initializer count, followed by a separate local template for every term.
The output decoder obtains the normalized integer-table Hamiltonian and its two
rational cutoffs solely from this tape.

The operational cost model uses unary natural registers and immutable linked
lists. Reading a cell, branching on its tag, successor, and cons each require
bounded work. The counters count iterations of explicitly recursive routines,
including parsing, allocation, nested clock loops and serialization. The binary
codec charges both bit conversions. The decoder defines the meaning of each
symbolic table and its scale; expansion to dense coefficient bitstrings is a
separate computation.

* [Qatlib, finite integer local tables at the pinned revision](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QueryComplexity/DegreeMethod/QmaCompletenessNativeOutput.lean)
* [Kempe, Kitaev & Regev (2006)](https://doi.org/10.1137/S0097539704445226)
-/

@[expose] public section
namespace FQChem.Complexity.Kitaev.Compiler

open Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Concepts.QueryComplexity.DegreeMethod
open Qatlib.Papers.LocalHam06.MainResults

inductive Cell where | row | field | tally deriving DecidableEq, Repr
abbrev Row := List ℕ
abbrev Tape := List Cell

/-- Value and number of elementary recursive transitions. -/
structure Run (α : Type*) where
  val : α
  steps : ℕ

def Run.charge {α : Type*} (a : Run α) (k : ℕ := 1) : Run α := ⟨a.val,a.steps+k⟩

def writeCell (c : Cell) (tail : Run Tape) : Run Tape := ⟨c :: tail.val,tail.steps+1⟩

def tallies : ℕ → Run Tape → Run Tape
  | 0, tail => tail.charge
  | k+1, tail => writeCell .tally (tallies k tail)

def fields : Row → Run Tape → Run Tape
  | [], tail => tail.charge
  | k::ks, tail => writeCell .field (tallies k (fields ks tail))

def emit : List Row → Run Tape → Run Tape
  | [], tail => tail.charge
  | r::rs, tail => writeCell .row (fields r (emit rs tail))

def serialize (rows : List Row) : Tape := (emit rows ⟨[],0⟩).val

structure ParseState where
  unary : ℕ := 0
  fields : Row := []
  rows : List Row := []

def parseCell (c : Cell) (s : ParseState) : ParseState :=
  match c with
  | .tally => {s with unary := s.unary + 1}
  | .field => {s with unary := 0, fields := s.unary :: s.fields}
  | .row => ⟨0, [], s.fields :: s.rows⟩

def scan : Tape → Run ParseState
  | [] => ⟨{},1⟩
  | c::cs => let rest := scan cs; ⟨parseCell c rest.val,rest.steps+1⟩

def scanLoop (w : Tape) : Run ParseState :=
  w.reverse.foldl (fun rest c ↦ ⟨parseCell c rest.val, rest.steps+1⟩) ⟨{},1⟩

@[csimp] theorem scan_eq_scanLoop : scan = scanLoop := by
  funext w
  induction w with
  | nil => rfl
  | cons c cs ih => simp [scan,scanLoop,List.foldl_append,ih]

@[simp] theorem scan_cost (w : Tape) : (scan w).steps = w.length + 1 := by
  induction w with | nil => rfl | cons x xs ih => simp [scan, ih]

private theorem scan_tallies (k : ℕ) (tail : Run Tape) :
    (scan (tallies k tail).val).val =
    {(scan tail.val).val with unary := (scan tail.val).val.unary + k} := by
  induction k with
  | zero => simp [tallies, Run.charge]
  | succ k ih => simp [tallies, writeCell, scan, parseCell, ih, Nat.add_assoc]

private theorem scan_fields (xs : Row) (tail : Run Tape) (h : (scan tail.val).val.unary = 0) :
    (scan (fields xs tail).val).val =
      {(scan tail.val).val with fields := xs ++ (scan tail.val).val.fields} := by
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [fields, writeCell, scan, parseCell, scan_tallies, ih, h]

private theorem scan_emit (xs : List Row) (tail : Run Tape)
    (h : (scan tail.val).val.unary = 0) (hf : (scan tail.val).val.fields = []) :
    (scan (emit xs tail).val).val = ⟨0, [], xs ++ (scan tail.val).val.rows⟩ := by
  induction xs with
  | nil => cases h₁ : (scan tail.val).val; simp_all [emit, Run.charge]
  | cons x xs ih =>
    have hz : (scan (emit xs tail).val).val.unary = 0 := by rw [ih]
    simp [emit, writeCell, scan, parseCell, scan_fields x (emit xs tail) hz, ih]

@[simp] theorem scan_serialize (xs : List Row) : (scan (serialize xs)).val.rows = xs := by
  unfold serialize
  rw [scan_emit xs _ rfl rfl]
  simp [scan]

def gateRow : FiniteGateCode → Row
  | .h j => [0,j]
  | .x j => [1,j]
  | .t j => [2,j]
  | .tdg j => [3,j]
  | .cx i j => [4,i,j]

def readGate : Row → Option FiniteGateCode
  | [0,j] => some (.h j)
  | [1,j] => some (.x j)
  | [2,j] => some (.t j)
  | [3,j] => some (.tdg j)
  | [4,i,j] => some (.cx i j)
  | _ => none

@[simp] theorem read_gateRow (g : FiniteGateCode) : readGate (gateRow g) = some g := by
  cases g <;> rfl

def descriptorRow {m n : ℕ} : TermDescriptor m n → Row
  | .propagation i g => 0 :: i.val :: gateRow g
  | .boundary false j => [1,j.val]
  | .boundary true j => [2,j.val]
  | .clock i j => [3,i.val,j.val]

def readDescriptor (m n : ℕ) : Row → Option (TermDescriptor m n)
  | 0::i::g => if hi : i < m then (readGate g).map (.propagation ⟨i,hi⟩) else none
  | [1,j] => if hj : j < n then some (.boundary false ⟨j,hj⟩) else none
  | [2,j] => if hj : j < n then some (.boundary true ⟨j,hj⟩) else none
  | [3,i,j] => if hi : i < m then
      if hj : j < m then some (.clock ⟨i,hi⟩ ⟨j,hj⟩) else none else none
  | _ => none

@[simp] theorem read_descriptorRow {m n : ℕ} (d : TermDescriptor m n) :
    readDescriptor m n (descriptorRow d) = some d := by
  cases d with
  | propagation i g => simp [readDescriptor, descriptorRow, i.isLt]
  | clock i j => simp [readDescriptor, descriptorRow, i.isLt, j.isLt]
  | boundary t j => cases t <;> simp [readDescriptor, descriptorRow, j.isLt]

/-- The common header fixes the clock penalty, rounding precision, normalization,
and both rational promise thresholds. Descriptors refer only to their own operands. -/
noncomputable def decode (w : Tape) : Option (LhEncoding × ℚ × ℚ) := do
  let [n,m,a]::rows := (scan w).val.rows | none
  let records ← rows.mapM (readDescriptor m n)
  let b := 3*(n+m)+64
  let J := 32*(m+a+1)+1
  let D : ℕ := 2^13*(m+1)^3*scaleDen J
  return (toLhEncoding (b+1+scaleBits J) (records.map (TermDescriptor.localTable b J)),
    1/(D : ℚ), 2/(D : ℚ))

def source (C : QmaHistoryCircuit) : Tape :=
  serialize ([C.qubits,C.outputWire.val] :: (C.initZeroWires.sort.map Fin.val) ::
    C.gates.map gateRow)

def count {α : Type*} : List α → Run ℕ
  | [] => ⟨0,1⟩
  | _::xs => let rest := count xs; ⟨rest.val+1,rest.steps+1⟩

@[simp] theorem count_spec {α : Type*} (xs : List α) :
    (count xs).val = xs.length ∧ (count xs).steps = xs.length+1 := by
  induction xs with | nil => simp [count] | cons x xs ih => simp [count,ih.1,ih.2]

/-- Appending the 64 fixed padding gates copies each input list cell. -/
def pad (out : ℕ) : List Row → Run (List Row)
  | [] => ⟨List.replicate 64 [0,out],65⟩
  | g::gs => let rest := pad out gs; ⟨g::rest.val, rest.steps+1⟩

@[simp] theorem pad_spec (o : ℕ) (gs : List Row) :
    (pad o gs).val = gs ++ List.replicate 64 [0,o] ∧ (pad o gs).steps = gs.length+65 := by
  induction gs with | nil => simp [pad] | cons x xs ih => simp [pad,ih.1,ih.2]

/-- Emit each propagation record, writing the local gate operands and the current unary time. -/
def propagation (i : ℕ) : List Row → Run Tape → Run Tape
  | [], tail => tail.charge
  | g::gs, tail => (writeCell .row (fields (0::i::g) (propagation (i+1) gs tail))).charge

def initializers : List ℕ → Run Tape → Run Tape
  | [], tail => tail.charge
  | j::js, tail => (writeCell .row (fields [1,j] (initializers js tail))).charge

def clockColumns {α : Type*} (i j : ℕ) : List α → Run Tape → Run Tape
  | [], tail => tail.charge
  | _::gs, tail => (writeCell .row (fields [3,i,j] (clockColumns i (j+1) gs tail))).charge

def clockRows {α : Type*} (i : ℕ) (columns : List α) : List α → Run Tape → Run Tape
  | [], tail => tail.charge
  | _::gs, tail => (clockColumns i 0 columns (clockRows (i+1) columns gs tail)).charge

/-- A pass counts the padded word and the initialized wires before emission. -/
def compileRows (n out : ℕ) (aux : List ℕ) (input : List Row) : Run Tape :=
  let padded := pad out input
  let m := count padded.val
  let a := count aux
  let clocks := clockRows 0 padded.val padded.val ⟨[],0⟩
  let bounds := initializers aux (writeCell .row (fields [2,out] clocks))
  (writeCell .row (fields [n,m.val,a.val] (propagation 0 padded.val bounds))).charge
    (padded.steps+m.steps+a.steps+1)

/-- The compiler accepts a serialized source tape. An invalid header emits the empty tape. -/
def compile (w : Tape) : Run Tape :=
  let input := scan w
  match input.val.rows with
  | [n,out]::aux::gs => (compileRows n out aux gs).charge (input.steps+1)
  | _ => ⟨[],input.steps+1⟩


private def rowData (r : Row) : Tape :=
  .row :: r.flatMap (fun k ↦ .field :: List.replicate k .tally)

private theorem tallies_val (k : ℕ) (tail : Run Tape) :
    (tallies k tail).val = List.replicate k .tally ++ tail.val := by
  induction k with | zero => rfl | succ k ih => simp [tallies, writeCell,ih,List.replicate_succ]

private theorem fields_val (xs : Row) (tail : Run Tape) :
    (fields xs tail).val = xs.flatMap (fun k ↦ .field :: List.replicate k .tally) ++ tail.val := by
  induction xs with | nil => rfl | cons k xs ih => simp [fields,writeCell,tallies_val,ih]

private theorem emit_val (xs : List Row) (tail : Run Tape) :
    (emit xs tail).val = xs.flatMap rowData ++ tail.val := by
  induction xs with | nil => rfl | cons k xs ih => simp [emit,writeCell,fields_val,ih,rowData]

private theorem prop_val (start : ℕ) (gs : List FiniteGateCode) (tail : Run Tape) :
    (propagation start (gs.map gateRow) tail).val =
    (List.finRange gs.length).flatMap (fun i ↦ rowData (0::(start+i.val)::gateRow (gs.get i))) ++ tail.val := by
  induction gs generalizing start with
  | nil => rfl
  | cons g gs ih =>
    simp [propagation, Run.charge,writeCell,fields_val,ih, List.finRange_succ, List.flatMap_map,
      rowData, Nat.add_assoc, Nat.add_comm 1]

private theorem init_val (aux : List ℕ) (tail : Run Tape) :
    (initializers aux tail).val = aux.flatMap (fun j ↦ rowData [1,j]) ++ tail.val := by
  induction aux with | nil => rfl | cons j js ih => simp [initializers, Run.charge,writeCell,fields_val,ih,rowData]

private theorem cols_val {α : Type*} (i j : ℕ) (gs : List α) (tail : Run Tape) :
    (clockColumns i j gs tail).val =
    (List.finRange gs.length).flatMap (fun k ↦ rowData [3,i,j+k.val]) ++ tail.val := by
  induction gs generalizing j with
  | nil => rfl
  | cons g gs ih =>
    simp [clockColumns, Run.charge,writeCell,fields_val,ih,List.finRange_succ, List.flatMap_map,
      rowData,Nat.add_assoc,Nat.add_comm 1]

private theorem clocks_val {α : Type*} (i : ℕ) (cs gs : List α) (tail : Run Tape) :
    (clockRows i cs gs tail).val =
    (List.finRange gs.length).flatMap (fun j ↦ (List.finRange cs.length).flatMap
      (fun k ↦ rowData [3,i+j.val,k.val])) ++ tail.val := by
  induction gs generalizing i with
  | nil => rfl
  | cons g gs ih =>
    simp [clockRows, Run.charge,cols_val,ih,List.finRange_succ,List.flatMap_map,
      Nat.add_assoc,Nat.add_comm 1]

private theorem paddedWord (C : QmaHistoryCircuit) :
    (pad C.outputWire.val (C.gates.map gateRow)).val = (paid64 C).gates.map gateRow := by
  rw [(pad_spec ..).1]
  simp [paid64, padWord, padHalf, finiteWordAdjoint, finiteCodeAdjoint, gateRow]

/-- The exact target word is self-contained, with one record for each verified local term. -/
theorem compile_tape (C : QmaHistoryCircuit) :
    (compile (source C)).val = serialize
      ([C.qubits,(paid64 C).gates.length,C.initZeroWires.card] ::
       (termDescriptors C.qubits (paid64 C).gates C.initZeroWires C.outputWire).map descriptorRow) := by
  simp only [compile, source, scan_serialize]
  simp only [compileRows, Run.charge, (count_spec _).1, paddedWord,
    List.length_map, Finset.length_sort, writeCell, fields_val, prop_val, init_val, clocks_val,
    serialize, emit_val, termDescriptors]
  simp [rowData, descriptorRow, List.flatMap_map, List.map_flatMap, List.flatMap_assoc, Function.comp_def, List.map_map]
  simpa [rowData] using congrArg (fun m ↦ (List.finRange m).flatMap (fun i ↦ (List.finRange m).flatMap
    (fun j ↦ rowData [3,i.val,j.val]))) (List.length_map (as := (paid64 C).gates) gateRow)

private theorem read_records {m n : ℕ} (ds : List (TermDescriptor m n)) :
    (ds.map descriptorRow).mapM (readDescriptor m n) = some ds := by
  induction ds with | nil => rfl | cons d ds ih => simp [List.mapM_cons, ih]

/-- Decoding the emitted word reconstructs exactly Qatlib's normalized five-local
Hamiltonian and both rational thresholds for the padded verifier. -/
theorem compile_correct (C : QmaHistoryCircuit) :
    decode (compile (source C)).val =
      some (encode C, 1/(cutoffDen C : ℚ), 2/(cutoffDen C : ℚ)) := by
  rw [compile_tape]
  simp only [decode, scan_serialize, read_records]
  simp only [bind, Option.bind, pure]
  rw [termDescriptors_correct]
  rfl

private def rowWeight : Row → ℕ
  | [] => 0
  | k::r => k + 1 + rowWeight r

private def rowsWeight : List Row → ℕ
  | [] => 0
  | r::rs => rowWeight r + 1 + rowsWeight rs

private theorem rowLength_le (r : Row) : r.length ≤ rowWeight r := by
  induction r with | nil => rfl | cons k r ih => simp [rowWeight]; omega

private theorem rowMember_le {r : Row} {k : ℕ} (h : k ∈ r) : k ≤ rowWeight r := by
  induction r with
  | nil => simp at h
  | cons a r ih =>
    rcases List.mem_cons.mp h with rfl|hr
    · simp only [rowWeight]; omega
    · have := ih hr
      simp [rowWeight]
      omega

private theorem rowsLength_le (rs : List Row) : rs.length ≤ rowsWeight rs := by
  induction rs with | nil => rfl | cons k r ih => simp [rowsWeight]; omega

private theorem rowsMember_le {r : Row} {rs : List Row} (h : r ∈ rs) : rowWeight r ≤ rowsWeight rs := by
  induction rs with
  | nil => simp at h
  | cons a rs ih =>
    rcases List.mem_cons.mp h with rfl|hr
    · simp only [rowsWeight]; omega
    · have := ih hr
      simp [rowsWeight]
      omega

/-- Each source tape cell contributes at most one unit of decoded data. -/
private theorem scan_budget (w : Tape) :
    (scan w).val.unary + rowWeight (scan w).val.fields + rowsWeight (scan w).val.rows ≤ w.length := by
  induction w with
  | nil => rfl
  | cons c w ih => cases c <;> simp [scan,parseCell,rowWeight,rowsWeight] <;> omega

private theorem tallies_steps (k : ℕ) (tail : Run Tape) :
    (tallies k tail).steps = tail.steps+k+1 := by
  induction k with | zero => rfl | succ k ih => simp [tallies,writeCell,ih,Nat.add_assoc]

private theorem fields_steps (r : Row) (tail : Run Tape) :
    (fields r tail).steps ≤ tail.steps+1+2*rowWeight r := by
  induction r with
  | nil => simp [fields,Run.charge,rowWeight]
  | cons k r ih => simp only [fields,writeCell,tallies_steps,rowWeight]; omega

private theorem prop_steps (gs : List Row) (i K : ℕ) (tail : Run Tape)
    (hi : i+gs.length ≤ K) (hg : ∀ g ∈ gs, rowWeight g ≤ K) :
    (propagation i gs tail).steps ≤ tail.steps+1 + 12*(K+1)*gs.length := by
  induction gs generalizing i with
  | nil => simp [propagation, Run.charge]
  | cons g gs ih =>
    have hr := ih (i+1) (by simp at hi; omega) (fun k hk ↦ hg k (by simp [hk]))
    have hw := fields_steps (0::i::g) (propagation (i+1) gs tail)
    have h₀ := hg g (by simp)
    simp only [propagation,Run.charge,writeCell,List.length_cons,Nat.mul_succ] at ⊢
    simp only [rowWeight] at hw
    nlinarith

private theorem init_steps (aux : List ℕ) (K : ℕ) (tail : Run Tape) (h : ∀ j ∈ aux, j ≤ K) :
    (initializers aux tail).steps ≤ tail.steps+1+12*(K+1)*aux.length := by
  induction aux with
  | nil => simp [initializers, Run.charge]
  | cons j js ih =>
    have hr := ih (fun k hk ↦ h k (by simp [hk]))
    have hw := fields_steps [1,j] (initializers js tail)
    have hj := h j (by simp)
    simp only [initializers,Run.charge,writeCell,List.length_cons,Nat.mul_succ]
    simp only [rowWeight] at hw
    nlinarith

private theorem cols_steps {α : Type*} (gs : List α) (i j K : ℕ) (tail : Run Tape)
    (hi : i ≤ K) (hj : j+gs.length ≤ K) :
    (clockColumns i j gs tail).steps ≤ tail.steps+1+16*(K+1)*gs.length := by
  induction gs generalizing j with
  | nil => simp [clockColumns,Run.charge]
  | cons a gs ih =>
    have hr := ih (j+1) (by simp at hj; omega)
    have hw := fields_steps [3,i,j] (clockColumns i (j+1) gs tail)
    simp only [clockColumns,Run.charge,writeCell,List.length_cons,Nat.mul_succ]
    simp only [rowWeight] at hw
    nlinarith

private theorem clock_steps {α : Type*} (cs gs : List α) (i K : ℕ) (tail : Run Tape)
    (hc : cs.length ≤ K) (hi : i+gs.length ≤ K) :
    (clockRows i cs gs tail).steps ≤ tail.steps+1+(2+16*(K+1)*cs.length)*gs.length := by
  induction gs generalizing i with
  | nil => simp [clockRows,Run.charge]
  | cons a gs ih =>
    have hr := ih (i+1) (by simp at hi; omega)
    have hw := cols_steps cs i 0 K (clockRows (i+1) cs gs tail) (by omega) (by simpa using hc)
    simp only [clockRows, Run.charge,List.length_cons,Nat.mul_succ]
    nlinarith

private theorem compileRows_steps (n o : ℕ) (aux : List ℕ) (gs : List Row) (L : ℕ)
    (h : n+o+rowWeight aux+rowsWeight gs ≤ L) :
    (compileRows n o aux gs).steps ≤ 90*(L+70)^3 := by
  let K := L+69
  let ps := (pad o gs).val
  have hps : ps = gs ++ List.replicate 64 [0,o] := (pad_spec ..).1
  have hm : ps.length ≤ K := by simp [hps,K]; have := rowsLength_le gs; omega
  have ha : aux.length ≤ K := by have := rowLength_le aux; dsimp [K]; omega
  have hg : ∀ g ∈ ps, rowWeight g ≤ K := by
    intro g hg
    rw [hps, List.mem_append] at hg
    rcases hg with hg|hg
    · have := rowsMember_le hg
      dsimp [K]
      omega
    · have e : g = [0,o] := List.eq_of_mem_replicate hg
      subst g
      simp [rowWeight,K]
      omega
  let clocks := clockRows 0 ps ps ⟨[],0⟩
  let out := writeCell .row (fields [2,o] clocks)
  let ini := initializers aux out
  let prop := propagation 0 ps ini
  have hc : clocks.steps ≤ 1+(2+16*(K+1)*K)*K := calc
    _ ≤ 0+1+(2+16*(K+1)*ps.length)*ps.length := clock_steps ps ps 0 K _ hm (by simpa using hm)
    _ ≤ _ := by gcongr
  have ho : out.steps ≤ clocks.steps+2+2*rowWeight [2,o] := by
    have := fields_steps [2,o] clocks
    dsimp [out,writeCell]
    omega
  have hi : ini.steps ≤ out.steps+1+12*(K+1)*K := calc
    _ ≤ _ := init_steps aux K out (fun j hj ↦ (rowMember_le hj).trans (by dsimp [K]; omega))
    _ ≤ _ := by gcongr
  have hp : prop.steps ≤ ini.steps+1+12*(K+1)*K := calc
    _ ≤ _ := prop_steps ps 0 K ini (by simpa using hm) hg
    _ ≤ _ := by gcongr
  have head := fields_steps [n,ps.length,aux.length] prop
  change (fields [n,(count ps).val,(count aux).val] prop).steps + 1 +
    ((pad o gs).steps+(count ps).steps+(count aux).steps+1) ≤ _
  simp only [(count_spec _).1, (count_spec _).2, (pad_spec _ _).2]
  have hgs := rowsLength_le gs
  simp only [rowWeight] at head ho
  dsimp [K] at hc hi hp hm ha
  nlinarith only [hc,ho,hi,hp,head,hgs,h,hm,ha,Nat.zero_le (rowWeight aux),
    Nat.zero_le (rowsWeight gs),Nat.zero_le (L^2),Nat.zero_le (L^3),Nat.zero_le L]

/-- Cubic transition bound on all input tapes, including malformed inputs. Each
counted transition uses boundedly many unary list-cell primitives. -/
theorem compile_time (w : Tape) : (compile w).steps ≤ 100*(w.length+70)^3 := by
  simp only [compile]
  split
  next n o aux gs h =>
    have hb := scan_budget w
    rw [h] at hb
    simp only [rowsWeight,rowWeight] at hb
    have hc := compileRows_steps n o aux gs w.length (by omega)
    simp only [Run.charge,scan_cost]
    nlinarith only [hc,Nat.zero_le (w.length^2),Nat.zero_le (w.length^3),Nat.zero_le w.length]
  next =>
    simp only [scan_cost]
    nlinarith only [Nat.zero_le (w.length^2),Nat.zero_le (w.length^3),Nat.zero_le w.length]

/-- The promise is defined solely by the serialized local instance. -/
def EnergyPromise (w : Tape) (answer : Bool) : Prop :=
  ∃ (E : LhEncoding) (a b : ℚ), decode w = some (E,a,b) ∧
    0 < a ∧ a < b ∧ lhLocal 5 E ∧ lhHermitian E ∧
    (∀ t ∈ E.terms, ‖Matrix.toEuclideanCLM (𝕜 := ℂ) (lhEmbedTerm E.width t)‖ ≤ 1) ∧
    (if answer then groundEnergy (lhHamiltonian E) ≤ (a : ℝ)
     else (b : ℝ) ≤ groundEnergy (lhHamiltonian E))

theorem energyPromise_disjoint (w : Tape) : ¬ (EnergyPromise w true ∧ EnergyPromise w false) := by
  rintro ⟨⟨E,a,b,he,_,hab,_,_,_,hy⟩,⟨E',a',b',he',_,_,_,_,_,hn⟩⟩
  rw [he] at he'
  cases he'
  simp only [ite_true, Bool.false_eq_true, ite_false] at hy hn
  exact (show (a : ℝ) < (b : ℝ) by exact_mod_cast hab).not_ge (hn.trans hy)

theorem compile_energyPromise (C : QmaHistoryCircuit) :
    (Yes C → EnergyPromise (compile (source C)).val true) ∧
    (No C → EnergyPromise (compile (source C)).val false) := by
  have hd : 0 < (cutoffDen C : ℚ) := by exact_mod_cast cutoffDen_pos C
  have ha : 0 < 1/(cutoffDen C : ℚ) := by positivity
  have hab : 1/(cutoffDen C : ℚ) < 2/(cutoffDen C : ℚ) := by apply (div_lt_div_iff_of_pos_right hd).mpr; norm_num
  have facts := resources C
  constructor
  · intro hy
    refine ⟨_,_,_, compile_correct C, ha, hab, facts.1, facts.2.1,facts.2.2.1, ?_⟩
    simpa [(rationalCutoffs C).1] using (groundEnergy_promise C).1 hy
  · intro hn
    refine ⟨_,_,_, compile_correct C, ha, hab, facts.1, facts.2.1,facts.2.2.1, ?_⟩
    simpa [(rationalCutoffs C).2] using (groundEnergy_promise C).2 hn

/-- Execute a source generator, then pass its actual output cells to the compiler. -/
def after (generator : Tape → Run Tape) (x : Tape) : Run Tape :=
  let src := generator x
  (compile src.val).charge (src.steps+1)

/-- Composition with a costed uniform generator, paying one transition to hand over its tape.
The length premise holds for a transducer writing at most one output symbol per step. -/
theorem after_time (generator : Tape → Run Tape) (x : Tape) (budget : ℕ)
    (ht : (generator x).steps ≤ budget) (hl : (generator x).val.length ≤ budget) :
    (after generator x).steps ≤ 100*(budget+70)^3+budget+1 := by
  have h := compile_time (generator x).val
  have hz : 100*((generator x).val.length+70)^3 ≤ 100*(budget+70)^3 := by gcongr
  dsimp [after,Run.charge]
  omega

/-- Any family of amplified verifiers with a generator producing the specified serialized
gate words gives the two sides of the self-contained local-energy promise. -/
theorem after_energyPromise (generator : Tape → Run Tape) (C : Tape → QmaHistoryCircuit)
    (word : ∀ x, (generator x).val = source (C x)) (x : Tape) :
    (Yes (C x) → EnergyPromise (after generator x).val true) ∧
    (No (C x) → EnergyPromise (after generator x).val false) := by
  simpa [after, Run.charge, word] using compile_energyPromise (C x)

private def funded (r : Run Tape) : Prop := r.val.length ≤ r.steps

private theorem charge_funded (r : Run Tape) (k : ℕ) (h : funded r) : funded (r.charge k) :=
  h.trans (Nat.le_add_right ..)

private theorem cell_funded (c : Cell) (r : Run Tape) (h : funded r) : funded (writeCell c r) :=
  Nat.succ_le_succ h

private theorem tallies_funded (n : ℕ) (r : Run Tape) (h : funded r) : funded (tallies n r) := by
  induction n with | zero => exact charge_funded _ _ h | succ n ih => exact cell_funded _ _ ih

private theorem fields_funded (xs : Row) (r : Run Tape) (h : funded r) : funded (fields xs r) := by
  induction xs with
  | nil => exact charge_funded _ _ h
  | cons n xs ih => exact cell_funded _ _ (tallies_funded _ _ ih)

private theorem prop_funded (i : ℕ) (gs : List Row) (r : Run Tape) (h : funded r) :
    funded (propagation i gs r) := by
  induction gs generalizing i with
  | nil => exact charge_funded _ _ h
  | cons g gs ih => exact charge_funded _ _ (cell_funded _ _ (fields_funded _ _ (ih _)))

private theorem init_funded (xs : List ℕ) (r : Run Tape) (h : funded r) :
    funded (initializers xs r) := by
  induction xs with
  | nil => exact charge_funded _ _ h
  | cons j xs ih => exact charge_funded _ _ (cell_funded _ _ (fields_funded _ _ ih))

private theorem cols_funded {α : Type*} (i j : ℕ) (xs : List α) (r : Run Tape) (h : funded r) :
    funded (clockColumns i j xs r) := by
  induction xs generalizing j with
  | nil => exact charge_funded _ _ h
  | cons g gs ih => exact charge_funded _ _ (cell_funded _ _ (fields_funded _ _ (ih _)))

private theorem clocks_funded {α : Type*} (i : ℕ) (cs xs : List α) (r : Run Tape) (h : funded r) :
    funded (clockRows i cs xs r) := by
  induction xs generalizing i with
  | nil => exact charge_funded _ _ h
  | cons g gs ih => exact charge_funded _ _ (cols_funded _ _ _ _ (ih _))

private theorem compileRows_funded (n o : ℕ) (aux : List ℕ) (gs : List Row) :
    funded (compileRows n o aux gs) := by
  let ps := (pad o gs).val
  let clocks := clockRows 0 ps ps ⟨[],0⟩
  have hc : funded clocks := clocks_funded _ _ _ _ (Nat.le_refl 0)
  let out := writeCell .row (fields [2,o] clocks)
  have ho : funded out := cell_funded _ _ (fields_funded _ _ hc)
  have hi := init_funded aux out ho
  have hp := prop_funded 0 ps _ hi
  exact charge_funded _ _ (cell_funded _ _ (fields_funded _ _ hp))

/-- Every output symbol has been paid for in the operational clock. -/
theorem length_compile_le_steps (w : Tape) : (compile w).val.length ≤ (compile w).steps := by
  change funded (compile w)
  simp only [compile]
  split
  · exact charge_funded _ _ (compileRows_funded ..)
  · exact Nat.zero_le _

/-- Fixed two-bit code for the three symbols. -/
def binary : Tape → Run (List Bool)
  | [] => ⟨[],1⟩
  | c::cs => let rest := binary cs
             let pair := match c with
               | .row => (false,false)
               | .field => (false,true)
               | .tally => (true,false)
             ⟨pair.1 :: pair.2 :: rest.val,rest.steps+3⟩

/-- Read a pair of bits per symbol. The fourth pair also denotes a tally, and an
unpaired trailing bit is ignored. The canonical serializer uses three pairs. -/
def unbinary : List Bool → Run Tape
  | a::b::bs => let rest := unbinary bs
                let c := if a then Cell.tally else if b then Cell.field else Cell.row
                ⟨c :: rest.val,rest.steps+2⟩
  | _ => ⟨[],1⟩

def binaryLoop (w : Tape) : Run (List Bool) :=
  w.reverse.foldl (fun rest c ↦
    let ab := match c with
      | .row => (false,false)
      | .field => (false,true)
      | .tally => (true,false)
    ⟨ab.1 :: ab.2 :: rest.val, rest.steps+3⟩) ⟨[],1⟩

@[csimp] theorem binary_eq_binaryLoop : binary = binaryLoop := by
  funext w
  induction w with
  | nil => rfl
  | cons c cs ih => simp [binary,binaryLoop,List.foldl_append,ih]

def readBitPairs (rev : Tape) (paid : ℕ) : List Bool → Run Tape
  | a::b::bs =>
    let c := if a then Cell.tally else if b then Cell.field else Cell.row
    readBitPairs (c::rev) (paid+2) bs
  | _ => ⟨rev.reverse,paid+1⟩

private theorem readBitPairs_spec (x : List Bool) (rev : Tape) (paid : ℕ) :
    readBitPairs rev paid x = ⟨rev.reverse ++ (unbinary x).val, paid+(unbinary x).steps⟩ := by
  induction x using unbinary.induct generalizing rev paid with
  | case1 a b bs ih => simp [readBitPairs,unbinary,ih,Nat.add_assoc,Nat.add_comm 2]
  | case2 =>
    rename_i x hx
    cases x with
    | nil => simp [readBitPairs,unbinary]
    | cons a xs => cases xs with
                    | nil => simp [readBitPairs,unbinary]
                    | cons b bs => exact (hx a b bs rfl).elim

def unbinaryLoop := readBitPairs [] 0

@[csimp] theorem unbinary_eq_unbinaryLoop : unbinary = unbinaryLoop := by
  funext x
  simp [unbinaryLoop,readBitPairs_spec]

@[simp] theorem binary_roundtrip (w : Tape) : (unbinary (binary w).val).val = w := by
  induction w with | nil => rfl | cons c cs ih => cases c <;> simp [binary,unbinary,ih]

private theorem binary_cost (w : Tape) : (binary w).steps = 3*w.length+1 := by
  induction w with | nil => rfl | cons c cs ih => simp [binary,ih]; omega

private theorem unbinary_cost (x : List Bool) :
    (unbinary x).steps ≤ x.length+1 ∧ (unbinary x).val.length ≤ x.length := by
  induction x using unbinary.induct with
  | case1 a b bs ih => simp [unbinary]; omega
  | case2 => rename_i x hx; cases x with
            | nil => decide
            | cons a xs => cases xs with | nil => simp [unbinary] | cons b bs => exact (hx a b bs rfl).elim

/-- The ordinary binary transducer includes both alphabet conversions in its cost. -/
def compileBits (x : List Bool) : Run (List Bool) :=
  let input := unbinary x
  let output := compile input.val
  (binary output.val).charge (input.steps+output.steps+1)

noncomputable def decodeBits (x : List Bool) := decode (unbinary x).val

/-- Reading the binary output recovers precisely the compiled term tape. -/
theorem unbinary_compileBits (w : Tape) :
    (unbinary (compileBits (binary w).val).val).val = (compile w).val := by
  simp only [compileBits, Run.charge, binary_roundtrip]

/-- The complete binary output determines the normalized Hamiltonian and both rational cutoffs. -/
theorem compileBits_correct (C : QmaHistoryCircuit) :
    decodeBits (compileBits (binary (source C)).val).val =
      some (encode C, 1/(cutoffDen C : ℚ), 2/(cutoffDen C : ℚ)) := by
  simpa [decodeBits, compileBits, Run.charge] using compile_correct C

/-- Polynomial execution bound as a function of the number of input bits. -/
theorem compileBits_time (x : List Bool) :
    (compileBits x).steps ≤ 400*(x.length+70)^3+x.length+3 := by
  have hi := unbinary_cost x
  have hc := compile_time (unbinary x).val
  have ho := length_compile_le_steps (unbinary x).val
  have hp : 100*((unbinary x).val.length+70)^3 ≤ 100*(x.length+70)^3 := by gcongr; exact hi.2
  simp only [compileBits,Run.charge,binary_cost]
  omega

/-- Run a binary-tape source generator followed by the binary history compiler. -/
def afterBits (generator : List Bool → Run (List Bool)) (x : List Bool) : Run (List Bool) :=
  let input := generator x
  (compileBits input.val).charge (input.steps+1)

/-- Compositional reduction for a uniformly generated family of amplified verifiers.
A polynomial generator budget yields a polynomial budget for the composed computation. -/
theorem afterBits_reduction (generator : List Bool → Run (List Bool))
    (C : List Bool → QmaHistoryCircuit) (p : ℕ → ℕ)
    (word : ∀ x, (generator x).val = (binary (source (C x))).val)
    (time : ∀ x, (generator x).steps ≤ p x.length)
    (writes : ∀ x, (generator x).val.length ≤ (generator x).steps) (x : List Bool) :
    (afterBits generator x).steps ≤ 400*(p x.length+70)^3+2*p x.length+4 ∧
    (Yes (C x) → EnergyPromise (unbinary (afterBits generator x).val).val true) ∧
    (No (C x) → EnergyPromise (unbinary (afterBits generator x).val).val false) := by
  constructor
  · have ht := time x
    have hl := (writes x).trans ht
    have h := compileBits_time (generator x).val
    have hp : 400*((generator x).val.length+70)^3 ≤ 400*(p x.length+70)^3 := by gcongr
    simp only [afterBits,Run.charge]
    omega
  · simpa [afterBits,compileBits,Run.charge,word] using compile_energyPromise (C x)

end FQChem.Complexity.Kitaev.Compiler
