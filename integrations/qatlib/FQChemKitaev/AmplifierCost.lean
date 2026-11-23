module

public import FQChemKitaev.Compiler
import all FQChemKitaev.Compiler
public import FQChemKitaev.Amplify
public import FQChemKitaev.AmplificationBounds

/-! # Cost of emitting the coherent majority amplifier

The counters below count unary successor/predecessor and list-cell operations in
the same recursive transducer model as `Compiler`. Wire routing uses explicit
unary addition. The 45-gate suffix consists of three fixed 15-gate literals.
-/

@[expose] public section
namespace FQChem.Complexity.Kitaev.AmplifierCost

open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermalCircuits
open Compiler AmplificationBounds

structure Registers where
  width : ℕ
  out : ℕ
  gates : List FiniteGateCode

def registers (C : QmaHistoryCircuit) : Registers := ⟨C.qubits,C.outputWire.val,C.gates⟩

def addUnary : ℕ → ℕ → Run ℕ
  | 0, b => ⟨b,1⟩
  | a+1, b => let r := addUnary a b; ⟨r.val+1,r.steps+2⟩

private theorem add_spec (a b : ℕ) :
    (addUnary a b).val = a+b ∧ (addUnary a b).steps = 2*a+1 := by
  induction a with
  | zero => simp [addUnary]
  | succ a ih => simp [addUnary,ih.1,ih.2]; omega

def shift (d : ℕ) : FiniteGateCode → Run FiniteGateCode
  | .h i => let a := addUnary d i; ⟨.h a.val,a.steps+2⟩
  | .x i => let a := addUnary d i; ⟨.x a.val,a.steps+2⟩
  | .t i => let a := addUnary d i; ⟨.t a.val,a.steps+2⟩
  | .tdg i => let a := addUnary d i; ⟨.tdg a.val,a.steps+2⟩
  | .cx i j => let a := addUnary d i; let b := addUnary d j; ⟨.cx a.val b.val,a.steps+b.steps+2⟩

private theorem shift_cost (d : ℕ) (g : FiniteGateCode) : (shift d g).steps ≤ 4*d+4 := by
  cases g <;> simp [shift,(add_spec _ _).2] <;> omega

private theorem shift_wire (n : ℕ) (j : Fin 3) (g : FiniteGateCode)
    (legal : finiteCodeLegal n g = true) :
    (shift (n*j.val+1) g).val = Wiring.renameGate (Wiring.address (Amplify.copyWire n j)) g := by
  have eq (i : ℕ) (h : i < n) :
      Wiring.address (Amplify.copyWire n j) i = (n*j.val+1)+i := by
    simp [Wiring.address,h,Amplify.copyWire,finProdFinEquiv]; omega
  cases g with
  | h i | x i | t i | tdg i =>
    have hi : i < n := of_decide_eq_true legal
    simp [shift,Wiring.renameGate,eq _ hi,(add_spec _ _).1]
  | cx i l =>
    obtain ⟨hi,hl,_⟩ : i < n ∧ l < n ∧ i ≠ l := of_decide_eq_true legal
    simp [shift,Wiring.renameGate,eq _ hi,eq _ hl,(add_spec _ _).1]

/-- Prepend a shifted gate word directly onto a previously computed tail. -/
def prepend (d : ℕ) : List FiniteGateCode → Run (List FiniteGateCode) → Run (List FiniteGateCode)
  | [], r => r.charge
  | g::gs, r => let a := shift d g; let b := prepend d gs r; ⟨a.val::b.val,a.steps+b.steps+2⟩

private theorem prepend_cost (d : ℕ) (gs : List FiniteGateCode) (r : Run (List FiniteGateCode)) :
    (prepend d gs r).steps ≤ r.steps+1+gs.length*(4*d+6) := by
  induction gs with
  | nil => simp [prepend, Run.charge]
  | cons g gs ih =>
    have := shift_cost d g
    simp only [prepend,List.length_cons]
    rw [Nat.succ_mul]; omega

private theorem prepend_wire (C : QmaHistoryCircuit) (j : Fin 3) (r : Run (List FiniteGateCode)) :
    (prepend (C.qubits*j.val+1) C.gates r).val =
      Wiring.onWires (Amplify.copyWire C.qubits j) C.gates ++ r.val := by
  have legal := C.legal
  generalize C.gates = gs at legal ⊢
  induction gs with
  | nil => rfl
  | cons g gs ih =>
    obtain ⟨hg,hgs⟩ := Bool.and_eq_true_iff.mp legal
    simp [prepend,Wiring.onWires] at ih ⊢
    exact ⟨shift_wire _ _ _ hg,ih hgs⟩

def layer (c : Registers) : Run Registers :=
  let n := c.width
  let twice := addUnary n n
  let thrice := addUnary n twice.val
  let a := c.out+1
  let b := addUnary (n+1) c.out
  let e := addUnary (twice.val+1) c.out
  let suffix := thermalToffoliWord a b.val 0 ++ thermalToffoliWord a e.val 0 ++
    thermalToffoliWord b.val e.val 0
  let gates := prepend 1 c.gates (prepend (n+1) c.gates (prepend (twice.val+1) c.gates ⟨suffix,200⟩))
  ⟨⟨thrice.val+1,0,gates.val⟩, gates.steps+twice.steps+thrice.steps+b.steps+e.steps+15⟩

theorem layer_correct (C : QmaHistoryCircuit) : (layer (registers C)).val = registers (Amplify.step C) := by
  have zero := prepend_wire C 0
  have one := prepend_wire C 1
  have two := prepend_wire C 2
  simp only [Fin.val_zero,Nat.mul_zero,Nat.zero_add] at zero
  norm_num at one two
  simp only [registers,layer,(add_spec _ _).1,Amplify.step]
  congr 1
  · omega
  · rw [zero,one,show C.qubits+C.qubits= C.qubits*2 by omega,two]
    simp [Amplify.word, Majority.word, Amplify.readoutWires,Amplify.copyWire,finProdFinEquiv,
      List.append_assoc,Nat.add_comm,Nat.add_left_comm,Nat.add_assoc]

private theorem copies_time (n : ℕ) (gs : List FiniteGateCode) (tail : Run (List FiniteGateCode)) :
    (prepend 1 gs (prepend (n+1) gs (prepend (n+n+1) gs tail))).steps ≤
      tail.steps+3+gs.length*(12*n+30) := by
  have a := prepend_cost 1 gs (prepend (n+1) gs (prepend (n+n+1) gs tail))
  have b := prepend_cost (n+1) gs (prepend (n+n+1) gs tail)
  have e := prepend_cost (n+n+1) gs tail
  nlinarith only [a,b,e]

private theorem layer_time (c : Registers) :
    (layer c).steps ≤ 100*(c.gates.length+c.width+65)^2 := by
  unfold layer
  simp only [(add_spec _ _).1,(add_spec _ _).2]
  apply le_trans (Nat.add_le_add_right (Nat.add_le_add_right (Nat.add_le_add_right
    (Nat.add_le_add_right (Nat.add_le_add_right (copies_time _ _ _) _) _) _) _) _)
  dsimp only
  nlinarith


def layers (c : Registers) : ℕ → Run Registers
  | 0 => ⟨c,1⟩
  | k+1 => let a := layers c k; (layer a.val).charge (a.steps+2)

theorem layers_correct (C : QmaHistoryCircuit) (k : ℕ) :
    (layers (registers C) k).val = registers (Amplify.repeatCircuit C k) := by
  induction k with
  | zero => rfl
  | succ k ih => simp [layers,Run.charge,ih,layer_correct,Amplify.repeatCircuit]

private theorem growth (C : QmaHistoryCircuit) (k : ℕ) :
    size (Amplify.repeatCircuit C k) ≤ 3^k*size C :=
  size_after (fun j => (Amplify.repeatCircuit C j).gates.length)
    (fun j => (Amplify.repeatCircuit C j).qubits) (Amplify.repeat_gate_count C) (Amplify.repeat_width C) k

private theorem layers_time (C : QmaHistoryCircuit) (k : ℕ) :
    (layers (registers C) k).steps ≤ 1+k*(100*(3^k*size C)^2+2) := by
  induction k with
  | zero => simp [layers]
  | succ k ih =>
    have e := layer_time (registers (Amplify.repeatCircuit C k))
    change _ ≤ 100*(size (Amplify.repeatCircuit C k))^2 at e
    have e' : (layer (registers (Amplify.repeatCircuit C k))).steps ≤ 100*(3^k*size C)^2 := by
      exact e.trans (by gcongr; exact growth C k)
    simp only [layers,Run.charge,layers_correct]
    calc
      _ ≤ 1+(k+1)*(100*(3^k*size C)^2+2) := by rw [Nat.succ_mul]; omega
      _ ≤ _ := by gcongr; omega

/-- Halve a unary counter by consuming two successors per step. -/
def half : ℕ → Run ℕ
  | 0 | 1 => ⟨0,1⟩
  | n+2 => let r := half n; ⟨r.val+1,r.steps+3⟩

private theorem half_spec (n : ℕ) :
    (half n).val = n/2 ∧ (half n).steps ≤ 2*n+1 := by
  induction n using half.induct with
  | case1 => decide
  | case2 => decide
  | case3 n ih => simp only [half]; omega

def logarithm : ℕ → ℕ → Run ℕ
  | 0, _ => ⟨0,1⟩
  | _+1, 0 | _+1, 1 => ⟨0,2⟩
  | fuel+1, n+2 => let h := half (n+2); let r := logarithm fuel h.val
                    ⟨r.val+1,r.steps+h.steps+4⟩

private theorem logarithm_spec (fuel n : ℕ) (h : n ≤ fuel) :
    (logarithm fuel n).val = n.log2 ∧ (logarithm fuel n).steps ≤ (fuel+1)*(2*n+6) := by
  induction fuel generalizing n with
  | zero =>
    obtain rfl : n = 0 := by omega
    decide
  | succ f ih =>
    match n with
    | 0 => simp [logarithm,Nat.log2_def,Nat.succ_mul]
    | 1 => simp [logarithm,Nat.log2_def,Nat.succ_mul]
    | n+2 =>
      have a := half_spec (n+2)
      have b := ih (half (n+2)).val (by omega)
      have cap : (f+1)*(2*(half (n+2)).val+6) ≤ (f+1)*(2*(n+2)+6) :=
        Nat.mul_le_mul_left _ (by omega)
      constructor
      · change (logarithm f (half (n+2)).val).val+1 = _
        rw [b.1,a.1,Nat.log2_def (n+2)]
        simp
      · simp only [logarithm]
        rw [Nat.succ_mul]
        omega

/-- Compute the problem size and the logarithmic number of levels from the input. -/
def depth (c : Registers) : Run ℕ :=
  let T := count c.gates
  let u := addUnary c.width T.val
  let s := u.val+65
  let r := logarithm s s
  ⟨r.val+9,r.steps+u.steps+T.steps+80⟩

private theorem depth_spec (C : QmaHistoryCircuit) :
    (depth (registers C)).val = rounds (size C) ∧
    (depth (registers C)).steps ≤ 10*(size C+1)^2 := by
  let s := size C
  have eq : C.qubits+C.gates.length+65=s := by dsimp [s,size]; omega
  have h := logarithm_spec s s le_rfl
  simp only [depth,registers,(count_spec _).1,(count_spec _).2,(add_spec _ _).1,
    (add_spec _ _).2,eq,h.1]
  constructor
  · unfold rounds; dsimp [s]; omega
  · change _ ≤ 10*(s+1)^2
    have hs : C.qubits+C.gates.length+65=s := eq
    have := h.2
    nlinarith only [this,hs]

def indices (start : ℕ) : ℕ → Run Row
  | 0 => ⟨[],1⟩
  | n+1 => let r := indices (start+1) n; ⟨start::r.val,r.steps+3⟩

private theorem indices_spec (s n : ℕ) :
    (indices s n).val = List.range' s n ∧ (indices s n).steps = 3*n+1 := by
  induction n generalizing s with
  | zero => simp [indices]
  | succ n ih => simp [indices,List.range'_succ,(ih _).1,(ih _).2]; omega

def gateRows : List FiniteGateCode → Run (List Row)
  | [] => ⟨[],1⟩
  | g::gs => let r := gateRows gs; ⟨gateRow g::r.val,r.steps+6⟩

private theorem gateRows_spec (gs : List FiniteGateCode) :
    (gateRows gs).val = gs.map gateRow ∧ (gateRows gs).steps = 6*gs.length+1 := by
  induction gs with
  | nil => simp [gateRows]
  | cons g gs ih => simp [gateRows,ih.1,ih.2]; omega

def output (c : Registers) : Run (List Bool) :=
  let aux := indices 0 c.width
  let gs := gateRows c.gates
  let tape := emit ([c.width,c.out]::aux.val::gs.val) ⟨[],0⟩
  (binary tape.val).charge (tape.steps+aux.steps+gs.steps+8)

private theorem output_correct (C : QmaHistoryCircuit) (allZero : C.initZeroWires = Finset.univ) :
    (output (registers C)).val = (binary (source C)).val := by
  have eq : (List.finRange C.qubits).map Fin.val = List.range C.qubits := by
    apply List.ext_getElem <;> simp
  simp [output,registers,Run.charge,(indices_spec _ _).1,(gateRows_spec _).1,
    source,Compiler.serialize,allZero,Fin.sort_univ,eq,List.range_eq_range']

private theorem emit_paid (rs : List Row) (t : Run Tape) (paid : funded t) : funded (emit rs t) := by
  induction rs with
  | nil => exact charge_funded _ _ paid
  | cons r rs ih => exact cell_funded _ _ (fields_funded _ _ ih)

private theorem emit_time (rs : List Row) (t : Run Tape) :
    (emit rs t).steps ≤ t.steps + 2*rowsWeight rs + 1 := by
  induction rs with
  | nil => simp [emit,Run.charge,rowsWeight]
  | cons r rs ih =>
    have h := fields_steps r (emit rs t)
    simp only [emit,writeCell,rowsWeight]
    omega

private theorem row_weight (r : Row) (n : ℕ) (bound : ∀ i ∈ r, i ≤ n) :
    rowWeight r ≤ r.length*(n+1) := by
  induction r with
  | nil => simp [rowWeight]
  | cons i r ih =>
    have a := bound i (by simp)
    have b := ih (fun j hj => bound j (by simp [hj]))
    simp only [rowWeight,List.length_cons]; rw [Nat.succ_mul]; omega

private theorem gates_weight {n : ℕ} (gs : List FiniteGateCode) (h : finiteWordLegal n gs = true) :
    rowsWeight (gs.map gateRow) ≤ gs.length*(2*n+10) := by
  induction gs with
  | nil => simp [rowsWeight]
  | cons g gs ih =>
    obtain ⟨head,tail⟩ := Bool.and_eq_true_iff.mp h
    have r : rowWeight (gateRow g) ≤ 2*n+9 := by
      cases g with
      | h i | x i | t i | tdg i =>
        have := of_decide_eq_true head
        simp [gateRow,rowWeight]; change i < n at this; omega
      | cx i j =>
        obtain ⟨hi,hj,_⟩ : i < n ∧ j < n ∧ i ≠ j := of_decide_eq_true head
        simp [gateRow,rowWeight]; omega
    specialize ih tail
    simp only [List.map_cons,rowsWeight,List.length_cons]
    rw [Nat.succ_mul]; omega

private theorem output_time (C : QmaHistoryCircuit) :
    (output (registers C)).steps ≤ 100*(size C)^2 := by
  let rs := [C.qubits,C.outputWire.val] :: List.range C.qubits :: C.gates.map gateRow
  let t := emit rs ⟨[],0⟩
  have paid : t.val.length ≤ t.steps := emit_paid rs _ (show 0 ≤ 0 from le_rfl)
  have e := emit_time rs ⟨[],0⟩
  change t.steps ≤ 0+2*rowsWeight rs+1 at e
  have g := gates_weight _ C.legal
  have a := row_weight (List.range C.qubits) C.qubits
    (fun j hj => (List.mem_range.mp hj).le)
  simp only [List.length_range] at a
  have o := C.outputWire.isLt
  have w : rowsWeight rs ≤ C.qubits+C.outputWire.val+4+
      C.qubits*(C.qubits+1)+C.gates.length*(2*C.qubits+10) := by
    dsimp only [rs,rowsWeight,rowWeight]
    omega
  simp only [output,registers,(indices_spec _ _).1,← List.range_eq_range',
    (indices_spec _ _).2,(gateRows_spec _).1,(gateRows_spec _).2,Run.charge,binary_cost]
  change 3*t.val.length+1+(t.steps+(3*C.qubits+1)+(6*C.gates.length+1)+8) ≤ _
  unfold size
  nlinarith only [paid,e,w,o]

def amplify (c : Registers) : Run (List Bool) :=
  let d := depth c
  let a := layers c d.val
  (output a.val).charge (a.steps+d.steps+3)

/-- The binary source emitted by the transducer is exactly the one specified by the
semantic coherent-amplifier construction. Input initializers are superseded by
the all-zero initializer on every wire at the first level. -/
theorem amplify_correct (C : QmaHistoryCircuit) :
    (amplify (registers C)).val =
      (binary (source (Amplify.repeatCircuit C (rounds (size C))))).val := by
  simp only [amplify,Run.charge,(depth_spec C).1,layers_correct]
  apply output_correct
  obtain ⟨k,h⟩ := Nat.exists_eq_succ_of_ne_zero (show rounds (size C) ≠ 0 by unfold rounds; omega)
  rw [h,Amplify.repeat_all_zero]

/-- A monotone polynomial bound for every syntactically valid binary circuit. -/
def budget (s : ℕ) := (s+12)*(200*(4^9*s^3)^2+20*(s+1)^2+20)

theorem amplify_time (C : QmaHistoryCircuit) : (amplify (registers C)).steps ≤ budget (size C) := by
  let s := size C
  let k := rounds s
  let A := Amplify.repeatCircuit C k
  have hs : 0 < s := by dsimp [s,size]; omega
  have p := polynomial_size hs
  have g := (growth C k).trans p
  have ot := output_time A
  have out : (output (registers A)).steps ≤ 100*(4^9*s^3)^2 := ot.trans (by gcongr)
  have lt := layers_time C k
  have l : (layers (registers C) k).steps ≤ 1+k*(100*(4^9*s^3)^2+2) := lt.trans (by gcongr)
  have d := (depth_spec C).2
  have rk : k ≤ s+9 := by dsimp [k,rounds]; have := Nat.log2_le_self s; omega
  have lt' := l.trans (Nat.add_le_add_left (Nat.mul_le_mul_right _ rk) 1)
  simp only [amplify,Run.charge,(depth_spec C).1,layers_correct]
  change (output (registers A)).steps + ((layers (registers C) k).steps + (depth (registers C)).steps+3) ≤ budget s
  change (depth (registers C)).steps ≤ 10*(s+1)^2 at d
  unfold budget
  nlinarith only [lt',d,out]

/-- Unary comparison, terminating as soon as either counter is zero. -/
def less : ℕ → ℕ → Run Bool
  | 0, 0 | _+1, 0 => ⟨false,2⟩
  | 0, _+1 => ⟨true,2⟩
  | i+1, j+1 => (less i j).charge 2

private theorem less_spec (i j : ℕ) :
    (less i j).val = decide (i<j) ∧ (less i j).steps ≤ 2*j+2 ∧ (less i j).steps ≤ 2*i+2 := by
  induction i generalizing j with
  | zero => cases j <;> simp [less]
  | succ i ih => cases j with
    | zero => simp [less]
    | succ j => simp [less,Run.charge,(ih j).1]; have := (ih j).2; omega

/-- A CNOT's distinctness is tested only after both operands pass the width check. -/
def valid (n : ℕ) : FiniteGateCode → Run Bool
  | .h i | .t i | .x i | .tdg i => (less i n).charge 2
  | .cx i j =>
    let a := less i n
    let b := less j n
    if a.val && b.val then
      let c := less i j
      let d := less j i
      ⟨c.val || d.val, a.steps+b.steps+c.steps+d.steps+6⟩
    else ⟨false,a.steps+b.steps+3⟩

private theorem valid_spec (n : ℕ) (g : FiniteGateCode) :
    (valid n g).val = finiteCodeLegal n g ∧ (valid n g).steps ≤ 8*n+14 := by
  cases g with
  | h i | x i | t i | tdg i =>
    simp [valid,finiteCodeLegal,Run.charge,(less_spec _ _).1]
    have := (less_spec i n).2.1; omega
  | cx i j =>
    simp only [valid,finiteCodeLegal,(less_spec _ _).1]
    split
    · rename_i h
      simp only [Bool.and_eq_true,decide_eq_true_eq] at h
      constructor
      · by_cases e : i = j <;> simp [h.1,h.2,e]
      · have := (less_spec i n).2.1
        have := (less_spec j n).2.1
        have := (less_spec i j).2.1
        have := (less_spec j i).2.1
        dsimp only; omega
    · rename_i h
      simp only [Bool.and_eq_true,decide_eq_true_eq] at h
      constructor
      · simp; omega
      · have := (less_spec i n).2.1; have := (less_spec j n).2.1; dsimp only; omega

/-- Decode each fixed-arity gate. Malformed rows and illegal operations are
discarded. The output is therefore legal even for arbitrary input bits. -/
def readWord (n : ℕ) : List Row → Run (List FiniteGateCode)
  | [] => ⟨[],1⟩
  | row::rs =>
    let r := readWord n rs
    match readGate row with
    | none => r.charge 12
    | some g => let h := valid n g
                if h.val then ⟨g::r.val,r.steps+h.steps+13⟩ else r.charge (h.steps+12)

private theorem readWord_legal (n : ℕ) (rs : List Row) :
    finiteWordLegal n (readWord n rs).val = true := by
  induction rs with
  | nil => rfl
  | cons row rs ih =>
    unfold readWord; split
    · exact ih
    · rename_i g _
      dsimp only
      split
      · rename_i h; exact Bool.and_eq_true_iff.mpr ⟨(valid_spec n g).1 ▸ h,ih⟩
      · exact ih

private theorem readWord_correct (C : QmaHistoryCircuit) :
    (readWord C.qubits (C.gates.map gateRow)).val = C.gates := by
  have h := C.legal
  generalize C.gates = gs at h ⊢
  induction gs with
  | nil => rfl
  | cons g gs ih =>
    obtain ⟨hg,hs⟩ := Bool.and_eq_true_iff.mp h
    simp [readWord,read_gateRow,(valid_spec _ _).1,hg,ih hs]

private theorem readWord_time (n : ℕ) (rs : List Row) :
    (readWord n rs).steps ≤ 1+rs.length*(8*n+27) ∧ (readWord n rs).val.length ≤ rs.length := by
  induction rs with
  | nil => simp [readWord]
  | cons row rs ih =>
    simp only [List.length_cons,Nat.succ_mul rs.length]
    unfold readWord; split
    · simp [Run.charge]; omega
    · rename_i g _
      have h := (valid_spec n g).2
      dsimp only
      split <;> simp [Run.charge] <;> omega

def fromRows : List Row → Run (List Bool)
  | [n,o]::_::rs =>
    let ok := less o n
    if ok.val then
      let gs := readWord n rs
      (amplify ⟨n,o,gs.val⟩).charge (ok.steps+gs.steps+6)
    else ⟨[],ok.steps+5⟩
  | _ => ⟨[],6⟩

/-- The binary-to-binary amplifier. Both input alphabet conversions are charged. -/
def compile (bits : List Bool) : Run (List Bool) :=
  let w := unbinary bits
  let parsed := scan w.val
  (fromRows parsed.val.rows).charge (w.steps+parsed.steps+2)

theorem compile_correct (C : QmaHistoryCircuit) :
    (compile (binary (source C)).val).val =
      (binary (source (Amplify.repeatCircuit C (rounds (size C))))).val := by
  change (fromRows (scan (unbinary (binary (source C)).val).val).val.rows).val = _
  rw [binary_roundtrip]
  simp only [source,scan_serialize,fromRows,(less_spec _ _).1,
    decide_eq_true C.outputWire.isLt,ite_true,readWord_correct,Run.charge]
  exact amplify_correct C

private theorem budget_mono {a b : ℕ} (h : a ≤ b) : budget a ≤ budget b := by unfold budget; gcongr

private theorem fromRows_time (rs : List Row) (L : ℕ) (h : rowsWeight rs ≤ L) :
    (fromRows rs).steps ≤ budget (2*L+65)+L*(8*L+27)+2*L+15 := by
  unfold fromRows
  split
  · rename_i n o aux gs
    have hn : n ≤ L := by
      dsimp only [rowsWeight,rowWeight] at h
      omega
    have hgs := rowsLength_le gs
    have len : gs.length ≤ L := by
      dsimp only [rowsWeight] at h
      omega
    have cost := (less_spec o n).2.1
    dsimp only
    split
    · rename_i ok
      have ho : o < n := by simpa [(less_spec _ _).1] using ok
      let C : QmaHistoryCircuit := ⟨n,(readWord n gs).val,readWord_legal n gs,∅,⟨o,ho⟩⟩
      have b := readWord_time n gs
      have sz : size C ≤ 2*L+65 := by dsimp [size,C]; omega
      have a := (amplify_time C).trans (budget_mono sz)
      change (amplify ⟨n,o,(readWord n gs).val⟩).steps ≤ _ at a
      have r : (readWord n gs).steps ≤ 1+L*(8*L+27) := b.1.trans (by gcongr)
      simp only [Run.charge]
      omega
    · simp only
      omega
  · simp only; omega

/-- Total polynomial running time in the number of input bits, including invalid
inputs. The result uses the recursive unary-register/list-cell cost model. -/
theorem compile_time (bits : List Bool) :
    (compile bits).steps ≤ budget (2*bits.length+65)+bits.length*(8*bits.length+27)+4*bits.length+20 := by
  let w := unbinary bits
  have u := unbinary_cost bits
  change w.steps ≤ _ ∧ w.val.length ≤ _ at u
  have sc := scan_budget w.val
  have cap : rowsWeight (scan w.val).val.rows ≤ bits.length := by omega
  have r := fromRows_time _ _ cap
  change (fromRows (scan w.val).val.rows).steps+(w.steps+(scan w.val).steps+2) ≤ _
  rw [scan_cost]
  omega

private theorem binary_paid (w : Tape) : (binary w).val.length ≤ (binary w).steps := by
  induction w with
  | nil => decide
  | cons c cs ih => cases c <;> simp [binary] <;> omega

private theorem output_paid (c : Registers) : (output c).val.length ≤ (output c).steps := by
  unfold output
  exact (binary_paid _).trans (Nat.le_add_right ..)

private theorem amplify_paid (c : Registers) : (amplify c).val.length ≤ (amplify c).steps := by
  simp only [amplify,Run.charge]
  exact (output_paid (layers c (depth c).val).val).trans (Nat.le_add_right ..)

private theorem fromRows_paid (rows : List Row) : (fromRows rows).val.length ≤ (fromRows rows).steps := by
  unfold fromRows
  split
  · rename_i n o _ rs
    dsimp only
    split
    · simp only [Run.charge]
      exact (amplify_paid ⟨n,o,(readWord n rs).val⟩).trans (Nat.le_add_right ..)
    · exact Nat.zero_le _
  · decide

/-- Every bit returned by the amplifier is funded by an actual write. -/
theorem length_le_steps (bits : List Bool) : (compile bits).val.length ≤ (compile bits).steps := by
  simp only [compile,Run.charge]
  exact (fromRows_paid (scan (unbinary bits).val).val.rows).trans (Nat.le_add_right ..)

end FQChem.Complexity.Kitaev.AmplifierCost
