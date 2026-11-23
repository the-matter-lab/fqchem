module

public import FQChemKitaev.ElectronicStructure
public import Qatlib.Concepts.LocalMachine.LocalTransport.UniformBqpDefs
import Qatlib.Concepts.GateVocabulary.LocalReflectionGates

/-! # From a clocked uniform circuit generator to an electronic energy promise

Qatlib's generator runs a time-bounded classical tape machine on the unary
input length. Its output circuit acts on a classical basis input. Loading the
bits with X gates makes it a witness-free history circuit initialized at zero.
The energy promise below uses the acceptance probability of that original
generated circuit, and bounds the construction size in the input length. -/

@[expose] public section
noncomputable section

namespace FQChem.Complexity.Kitaev.UniformCircuits

open Qatlib.Foundations.QueryWordCore.Circuit Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Concepts.GateVocabulary.LocalReflectionGates
open Qatlib.Concepts.LocalMachine.LocalTransport.UniformBqpDefs
open Qatlib.Concepts.QmaCompleteness.HistoryHam
open scoped Classical

variable {q : ℕ}

/-- X gates on the specified wires, in reverse list order. -/
def xWord (ws : List (Fin q)) : List FiniteGateCode :=
  ws.reverse.map fun i => .x i.val

private theorem load_subset (ws : List (Fin q)) (once : ws.Nodup) :
    Run 1 (finiteCodeCircuit q (xWord ws)) (Ket (ZeroStr q)) =
      Ket (fun i => decide (i ∈ ws)) := by
  induction ws with
  | nil =>
    simp [xWord, finiteCodeCircuit]
    rfl
  | cons j rest ih =>
    rw [List.nodup_cons] at once
    rw [show finiteCodeCircuit q (xWord (j :: rest)) =
      finiteCodeCircuit q (xWord rest) ++ [.gate (finiteCodeMatrix q (.x j))] by
        simp [finiteCodeCircuit, xWord], run_append, ih once.2]
    simp only [run_gate, run_nil, finiteCodeMatrix, dite_eq_left j.isLt]
    rw [applyGate_wireGate_ket]
    simp [once.1, PauliX, permMatrix, Matrix.of_apply]
    congr 1
    funext i
    by_cases h : i = j
    · subst i; simp
    · simp [h]

/-- One X instruction for each occupied input wire. -/
def inputWord (x : Reg q) : List FiniteGateCode := xWord ((List.finRange q).filter x)

theorem inputWord_length (x : Reg q) : (inputWord x).length ≤ q := by
  simpa [inputWord, xWord] using List.length_filter_le x (List.finRange q)

theorem inputWord_legal (x : Reg q) : finiteWordLegal q (inputWord x) = true := by
  simp [finiteWordLegal, inputWord, xWord, List.all_eq_true, finiteCodeLegal]

theorem inputWord_prepares (x : Reg q) :
    Run 1 (finiteCodeCircuit q (inputWord x)) (Ket (ZeroStr q)) = Ket x := by
  rw [inputWord, load_subset _ ((List.nodup_finRange q).filter _)]
  congr 1
  funext i
  simp

/-- Compile the generated circuit on classical input x into an all-zero-input circuit. -/
def initialized (hq : 0 < q) (gates : List FiniteGateCode)
    (legal : finiteWordLegal q gates = true) (x : Reg q) : QmaHistoryCircuit where
  qubits := q
  gates := inputWord x ++ gates
  legal := by simpa [finiteWordLegal] using (show
    finiteWordLegal q (inputWord x) && finiteWordLegal q gates = true by simp [legal, inputWord_legal])
  initZeroWires := Finset.univ
  outputWire := ⟨q-1, by omega⟩

set_option backward.isDefEq.respectTransparency false in
/-- Running the initialized history circuit preserves the original Born probability. -/
theorem initialized_acceptance (hq : 0 < q) (gates : List FiniteGateCode)
    (legal : finiteWordLegal q gates = true) (x : Reg q) :
    qmaHistoryAcceptProb (initialized hq gates legal x) (Ket (ZeroStr q)) =
      uniformBqpAcceptProb q gates x := by
  have concat : finiteCodeCircuit q (inputWord x ++ gates) =
      finiteCodeCircuit q (inputWord x) ++ finiteCodeCircuit q gates := by simp [finiteCodeCircuit]
  have runEq := run_append (1 : Matrix (Reg q) (Reg q) ℂ)
    (finiteCodeCircuit q (inputWord x)) (finiteCodeCircuit q gates) (Ket (ZeroStr q))
  rw [inputWord_prepares] at runEq
  simp only [qmaHistoryAcceptProb, initialized, concat, uniformBqpAcceptProb, uniformBqpRun,
    uniformBqpOutputEvent, dite_eq_left hq]
  congr 1


/-- A one-wire circuit returning false on its all-zero input. -/
def reject : QmaHistoryCircuit where
  qubits := 1
  gates := []
  legal := rfl
  initZeroWires := Finset.univ
  outputWire := 0

/-- A zero-width uniform circuit has an empty accepting event. Give it one initialized
output wire so that rejection has a legal history-Hamiltonian encoding. -/
def history (gates : List FiniteGateCode) (legal : finiteWordLegal q gates = true)
    (x : Reg q) : QmaHistoryCircuit :=
  if h : 0 < q then initialized h gates legal x else reject

private theorem reject_probability : qmaHistoryAcceptProb reject (Ket (ZeroStr 1)) = 0 := by
  change MeasureProb (Ket (ZeroStr 1)) (Finset.univ.filter fun z : Reg 1 => z 0) = 0
  unfold MeasureProb
  apply Finset.sum_eq_zero
  intro z hz
  have hz' := (Finset.mem_filter.mp hz).2
  have ne : z ≠ ZeroStr 1 := by
    intro eq
    subst z
    contradiction
  simp [BornProb, Qatlib.Foundations.PureStateMath.Ket, ne]

set_option backward.isDefEq.respectTransparency false in
theorem history_acceptance (gates : List FiniteGateCode) (legal : finiteWordLegal q gates = true)
    (x : Reg q) : let C := history gates legal x
      qmaHistoryAcceptProb C (Ket (ZeroStr C.qubits)) = uniformBqpAcceptProb q gates x := by
  unfold history
  split
  · exact initialized_acceptance _ gates legal x
  · rename_i h
    change qmaHistoryAcceptProb reject (Ket (ZeroStr 1)) = _
    rw [reject_probability]
    unfold uniformBqpAcceptProb uniformBqpOutputEvent
    split
    · contradiction
    · simp [MeasureProb]

/-- Resource and energy consequences for each outcome of a valid clocked generator.
The YES promise uses the amplified completeness target of the constructed circuit. -/
theorem generated_electronic_promise (g : UniformBqpGenerator) (valid : uniformBqpGeneratorValid g)
    (n : ℕ) : ∃ q gates, uniformBqpGeneratedAt g n = some (q, gates) ∧
      ∃ legal : finiteWordLegal q gates = true, ∀ (x : Reg q),
        let C := history gates legal x
        size C ≤ uniformBqpWordBound g n + 2 * uniformBqpSpaceBound g n + 66 ∧
        (completenessTarget C ≤ uniformBqpAcceptProb q gates x →
          ∃ φ, FQChem.Complexity.ElectronicStructure.mass φ = 1 ∧
            ElectronicStructure.electronicEnergy C φ ≤ yesCutoff C) ∧
        (uniformBqpAcceptProb q gates x ≤ 1/4 →
          ∀ φ, FQChem.Complexity.ElectronicStructure.mass φ = 1 →
            noCutoff C ≤ ElectronicStructure.electronicEnergy C φ) := by
  obtain ⟨q, gates, generated, _, legal, gateBound, qubitBound, _⟩ := valid n
  refine ⟨q, gates, generated, legal, ?_⟩
  intro x
  let C := history gates legal x
  have same := history_acceptance gates legal x
  refine ⟨?_, ?_, ?_⟩
  · unfold history
    split
    · simp only [size, initialized, List.length_append]
      have := inputWord_length x
      omega
    · simp [size, reject]
  · intro yes
    apply (ElectronicStructure.circuit_to_fixedParticle C).1
    exact ⟨_, zero_input_legal C, normalized_ket _, same.trans_ge yes⟩
  · intro no
    apply (ElectronicStructure.circuit_to_fixedParticle C).2
    intro ψ legalState normalized
    have allZero : C.initZeroWires = Finset.univ := by
      by_cases h : 0 < q
      · have e : C = initialized h gates legal x := by unfold C history; exact dite_eq_left h
        rw [e]; rfl
      · have e : C = reject := by unfold C history; exact dite_eq_right h
        rw [e]; rfl
    exact (witnessFree_acceptance C allZero ψ legalState normalized).le.trans (same.le.trans no)

end FQChem.Complexity.Kitaev.UniformCircuits
