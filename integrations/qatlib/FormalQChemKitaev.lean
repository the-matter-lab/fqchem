module

public import Qatlib.Papers.LocalHam06.MainResults.QmaCompleteness

/-!
# Five-local ground-energy promise for amplified verification circuits

The circuit, unary clock, finite gate alphabet, integer local tables, rounding analysis,
and history-state completeness and soundness proofs are those of Qatlib Contributors
(Apache 2.0). This module turns those proved bounds into an implication about a
ground-energy estimator. It measures the size of the serialized Hamiltonian, the
individual term norms and the inverse promise gap explicitly.

* [Qatlib five-local construction, pinned source](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompleteness.lean)
* [Kitaev, Shen & Vyalyi, Classical and Quantum Computation, 2002](https://doi.org/10.1090/gsm/047)
* [Kempe, Kitaev & Regev, The Complexity of the Local Hamiltonian Problem, 2006](https://doi.org/10.1137/S0097539704445226)
-/

@[expose] public section
noncomputable section

namespace FormalQChem.Complexity.Kitaev

open Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.UniformBqp.FiniteGateWord
open Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Papers.LocalHam06.MainResults
open scoped Classical

/-- The variational ground energy is the infimum over normalized states. -/
def groundEnergy {n : ℕ} (H : Matrix (Reg n) (Reg n) ℂ) : ℝ :=
  sInf (energy H '' {ψ | Normalized ψ})

private theorem energy_range_nonempty {n : ℕ} (H : Matrix (Reg n) (Reg n) ℂ) :
    (energy H '' {ψ | Normalized ψ}).Nonempty :=
  ⟨_, _, normalized_ket (fun _ => false), rfl⟩

private theorem energy_range_bddBelow {n : ℕ} (H : Matrix (Reg n) (Reg n) ℂ) :
    BddBelow (energy H '' {ψ | Normalized ψ}) := by
  let A := Matrix.toEuclideanCLM (𝕜 := ℂ) H
  refine ⟨-‖A‖, ?_⟩
  rintro _ ⟨ψ, hψ, rfl⟩
  let x : EuclideanSpace ℂ (Reg n) := WithLp.toLp 2 ψ
  have hnorm : ‖x‖ ^ 2 = 1 := (EuclideanSpace.norm_sq_eq x).trans hψ
  have agree : A.reApplyInnerSelf x = energy H ψ := by
    rw [ContinuousLinearMap.reApplyInnerSelf_apply, inner_re_symm]
    simp only [PiLp.inner_apply, RCLike.inner_apply', energy, inner_apply]
    congr 1
  have bound := A.rayleighQuotient_le_norm x
  change |A.reApplyInnerSelf x / ‖x‖ ^ 2| ≤ _ at bound
  rw [hnorm, div_one, agree] at bound
  exact (abs_le.mp bound).1

/-- The circuit encoding, including identity padding and dyadic normalization. -/
abbrev encode (C : QmaHistoryCircuit) : LhEncoding := normalizedEncoding (paid64 C)

def yesCutoff (C : QmaHistoryCircuit) := yesThreshold (paid64 C)
def noCutoff (C : QmaHistoryCircuit) := noThreshold (paid64 C)

/-- Number of gates and work wires plus the constant unary-clock padding and endpoint. -/
def size (C : QmaHistoryCircuit) : ℕ := C.gates.length + C.qubits + 65

/-- Error targets for the verifier's amplified circuit, expressed in the original
gate count. Soundness permits acceptance probability at most one quarter. -/
def completenessTarget (C : QmaHistoryCircuit) : ℝ :=
  1 - 1 / ((2 : ℝ)^14 * ((C.gates.length : ℝ) + 65)^2)

def Yes (C : QmaHistoryCircuit) : Prop :=
  ∃ ψ : QState (Reg C.qubits), QmaInitLegal C ψ ∧ Normalized ψ ∧
    completenessTarget C ≤ qmaHistoryAcceptProb C ψ

def No (C : QmaHistoryCircuit) : Prop :=
  ∀ ψ : QState (Reg C.qubits), QmaInitLegal C ψ → Normalized ψ →
    qmaHistoryAcceptProb C ψ ≤ 1 / 4

/-- Five-local Hermitian terms all have operator norm at most one. The number of
terms is explicit and the binary encoding of their dyadic tables has polynomial length. -/
theorem resources (C : QmaHistoryCircuit) :
    lhLocal 5 (encode C) ∧ lhHermitian (encode C) ∧
    (∀ t ∈ (encode C).terms,
      ‖Matrix.toEuclideanCLM (𝕜 := ℂ) (lhEmbedTerm (encode C).width t)‖ ≤ 1) ∧
    (encode C).terms.length = (C.gates.length + 64) + C.initZeroWires.card + 1 +
      (C.gates.length + 64)^2 ∧
    (qmaClause3ToBits (encode C)).length ≤ 2000000 * (size C)^3 := by
  have h := qma_history_locality_description_and_energy_bounds (paid64 C)
  refine ⟨h.1, h.2.1, h.2.2.1, ?_, ?_⟩
  · have aux : (paid64 C).initZeroWires.card = C.initZeroWires.card := rfl
    simpa only [paid64_length, aux] using h.2.2.2.1
  · have e : (paid64 C).gates.length + (paid64 C).qubits + 1 = size C := by
      rw [paid64_length]
      change C.gates.length + 64 + C.qubits + 1 = C.gates.length + C.qubits + 65
      omega
    simpa only [e] using h.2.2.2.2.1

/-- An inverse quartic in the total circuit size lower-bounds the promise gap. -/
theorem promiseGap (C : QmaHistoryCircuit) :
    1 / ((2 : ℝ)^13 * 130 * (size C : ℝ)^4) ≤ noCutoff C - yesCutoff C := by
  have gap := (gap_positive (paid64 C)).2
  change _ ≤ noThreshold (paid64 C) - yesThreshold (paid64 C)
  rw [gap]
  apply le_trans _ (gap_inverse_poly (paid64 C))
  apply one_div_le_one_div_of_le
  · have hp : 0 < restLength (paid64 C) := by unfold restLength; omega
    positivity
  · have ha : C.initZeroWires.card ≤ C.qubits := by simpa using C.initZeroWires.card_le_univ
    have hr : restLength (paid64 C) ≤ size C := by
      unfold restLength size
      rw [paid64_length]
      change C.gates.length + 64 + C.initZeroWires.card + 1 ≤ _
      omega
    have hg : ((paid64 C).gates.length : ℝ) + 1 ≤ (size C : ℝ) := by
      exact_mod_cast (show (paid64 C).gates.length + 1 ≤ size C by
        rw [paid64_length, size]; omega)
    have hs : 0 ≤ (size C : ℝ) := by positivity
    have hr' : (restLength (paid64 C) : ℝ) ≤ (size C : ℝ) := by exact_mod_cast hr
    calc
      _ ≤ (2 : ℝ)^13 * 130 * (size C : ℝ) * (size C : ℝ)^3 := by gcongr
      _ = _ := by ring

/-- An accepting verifier supplies an actual normalized witness state of the encoded
Hamiltonian. Every normalized state obeys the lower bound for a rejecting verifier. -/
theorem witnessEnergy_promise (C : QmaHistoryCircuit) :
    (Yes C → ∃ ψ : QState (Reg (encode C).qubitCount), Normalized ψ ∧
      energy (lhHamiltonian (encode C)) ψ ≤ yesCutoff C) ∧
    (No C → ∀ ψ : QState (Reg (encode C).qubitCount), Normalized ψ →
      noCutoff C ≤ energy (lhHamiltonian (encode C)) ψ) := by
  have ha : 1 - completenessTarget C ≤ 1 / ((2 : ℝ)^14 *
      (((paid64 C).gates.length : ℝ) + 1)^2) := by
    rw [completenessTarget, paid64_length, Nat.cast_add]
    norm_num
    ring_nf
    rfl
  have h := padded_normalized_contract C (completenessTarget C) (1 / 4) le_rfl ha
  exact ⟨h.1, h.2.1⟩

/-- Acceptance in the circuit promise bounds the actual variational ground energy.
The lower bound applies to arbitrary trial states, including illegal unary clocks. -/
theorem groundEnergy_promise (C : QmaHistoryCircuit) :
    (Yes C → groundEnergy (lhHamiltonian (encode C)) ≤ yesCutoff C) ∧
    (No C → noCutoff C ≤ groundEnergy (lhHamiltonian (encode C))) := by
  have h := witnessEnergy_promise C
  constructor
  · intro yes
    obtain ⟨ψ, hψ, hE⟩ := h.1 yes
    exact (csInf_le (energy_range_bddBelow _) ⟨ψ, hψ, rfl⟩).trans hE
  · intro no
    refine le_csInf (energy_range_nonempty _) ?_
    rintro _ ⟨ψ, hψ, rfl⟩
    exact h.2 no ψ hψ

/-- Comparing an additive ground-energy estimate with the midpoint decides
the amplified verifier promise. The tolerance is an explicit inverse polynomial. -/
theorem estimate_decides (C : QmaHistoryCircuit) (estimate : ℝ)
    (accuracy : |estimate - groundEnergy (lhHamiltonian (encode C))| ≤
      1 / ((2 : ℝ)^13 * 130 * (size C : ℝ)^4) / 3) :
    (Yes C → estimate < (yesCutoff C + noCutoff C)/2) ∧
    (No C → (yesCutoff C + noCutoff C)/2 < estimate) := by
  have positiveSize : 0 < size C := by unfold size; omega
  have positiveGap : 0 < 1 / ((2 : ℝ)^13 * 130 * (size C : ℝ)^4) := by positivity
  have separation := promiseGap C
  have bounds := abs_le.mp accuracy
  constructor
  · intro h
    linarith [(groundEnergy_promise C).1 h, bounds.2]
  · intro h
    linarith [(groundEnergy_promise C).2 h, bounds.1]

open Qatlib.Foundations.QueryWordCore.Circuit
open Qatlib.Foundations.BornMetrics.EventProbability

private theorem run_scalar {I : Type} [Fintype I] (O : Matrix I I ℂ) (gates : Circuit I)
    (c : ℂ) (ψ : QState I) : Run O gates (c • ψ) = c • Run O gates ψ := by
  induction gates generalizing ψ with
  | nil => rfl
  | cons gate gs ih => cases gate <;> simp only [Run, ApplyGate, Matrix.mulVec_smul, ih]

private theorem zero_input_legal (C : QmaHistoryCircuit) :
    QmaInitLegal C (Ket (ZeroStr C.qubits)) := by
  intro x hx j _
  by_cases h : x = ZeroStr C.qubits
  · simp [h, ZeroStr]
  · simp [Qatlib.Foundations.PureStateMath.Ket, h] at hx

/-- With every work qubit initialized to zero, every normalized legal input is
the zero ket up to a global phase and gives the same circuit acceptance. -/
theorem witnessFree_acceptance (C : QmaHistoryCircuit) (allZero : C.initZeroWires = Finset.univ)
    (ψ : QState (Reg C.qubits)) (legal : QmaInitLegal C ψ) (unit : Normalized ψ) :
    qmaHistoryAcceptProb C ψ = qmaHistoryAcceptProb C (Ket (ZeroStr C.qubits)) := by
  let z := ZeroStr C.qubits
  have support (x : Reg C.qubits) (hx : x ≠ z) : ψ x = 0 := by
    by_contra h
    exact hx (funext fun j => legal x h j (by simp [allZero]))
  have state : ψ = ψ z • Ket z := by
    funext x
    by_cases hx : x = z <;> simp [Qatlib.Foundations.PureStateMath.Ket, hx, support, Pi.smul_apply]
  have phase : ‖ψ z‖^2 = 1 := by
    change (∑ x, ‖ψ x‖^2) = 1 at unit
    rw [Finset.sum_eq_single z (fun x _ hx => by simp [support x hx]) (by simp)] at unit
    exact unit
  unfold qmaHistoryAcceptProb
  conv_lhs => rw [state, run_scalar, measureProb_smul, phase, one_mul]

/-- A witness-free amplified decision circuit satisfies the same energy promise based
solely on the acceptance probability of its all-zero input. -/
theorem witnessFree_groundEnergy (C : QmaHistoryCircuit) (allZero : C.initZeroWires = Finset.univ) :
    (completenessTarget C ≤ qmaHistoryAcceptProb C (Ket (ZeroStr C.qubits)) →
      groundEnergy (lhHamiltonian (encode C)) ≤ yesCutoff C) ∧
    (qmaHistoryAcceptProb C (Ket (ZeroStr C.qubits)) ≤ 1 / 4 →
      noCutoff C ≤ groundEnergy (lhHamiltonian (encode C))) := by
  constructor
  · intro h
    exact (groundEnergy_promise C).1 ⟨_, zero_input_legal C, normalized_ket _, h⟩
  · intro h
    apply (groundEnergy_promise C).2
    intro ψ legal unit
    exact (witnessFree_acceptance C allZero ψ legal unit).le.trans h

end FormalQChem.Complexity.Kitaev

namespace FormalQChem.Complexity.Kitaev

open Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.UniformBqp.FiniteGateWord
open Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Papers.LocalHam06.MainResults
open scoped Classical

/-- The two rational cutoffs are `1/D` and `2/D`. -/
def cutoffDen (C : QmaHistoryCircuit) : ℕ :=
  2^13 * ((paid64 C).gates.length + 1)^3 * denominator (paid64 C)

theorem cutoffDen_pos (C : QmaHistoryCircuit) : 0 < cutoffDen C := by
  have := denominator_pos (paid64 C)
  unfold cutoffDen
  positivity

theorem rationalCutoffs (C : QmaHistoryCircuit) :
    yesCutoff C = 1 / (cutoffDen C : ℝ) ∧ noCutoff C = 2 / (cutoffDen C : ℝ) := by
  have h₁ : (denominator (paid64 C) : ℝ) ≠ 0 := by exact_mod_cast (denominator_pos _).ne'
  have h₂ : ((paid64 C).gates.length : ℝ) + 1 ≠ 0 := by positivity
  unfold yesCutoff noCutoff yesThreshold noThreshold yesCut noCut cutoffDen
  push_cast
  constructor <;> field_simp <;> ring

theorem cutoffDen_le (C : QmaHistoryCircuit) :
    cutoffDen C ≤ 2^13 * 130 * (size C)^4 := by
  have haux : C.initZeroWires.card ≤ C.qubits := by simpa using C.initZeroWires.card_le_univ
  have hr : restLength (paid64 C) ≤ size C := by
    unfold restLength size
    rw [paid64_length]
    change C.gates.length + 64 + C.initZeroWires.card + 1 ≤ _
    omega
  have hg : (paid64 C).gates.length + 1 ≤ size C := by rw [paid64_length, size]; omega
  unfold cutoffDen
  calc
    _ ≤ 2^13 * (size C)^3 * (130 * size C) := by
      gcongr
      exact (denominator_le_poly _).trans (Nat.mul_le_mul_left _ hr)
    _ = _ := by ring

/-- Include the rational decision thresholds in the serialized reduction output. -/
def serialize (E : LhEncoding) (D : ℕ) : List Bool :=
  qmaClause3EncNat D ++ qmaClause3ToBits E

def reduction (C : QmaHistoryCircuit) : List Bool := serialize (encode C) (cutoffDen C)

theorem serialize_injective {E F : LhEncoding} {D d : ℕ}
    (h : serialize E D = serialize F d) : E = F ∧ D = d := by
  have pair := clause3Aux_encNat_selfDelimiting D d _ _ h
  exact ⟨clause3Aux_toBits_injective pair.2, pair.1⟩

/-- A polynomial bound on the complete output string, including the threshold. -/
theorem reduction_length (C : QmaHistoryCircuit) :
    (reduction C).length ≤ 2 * (2^13 * 130 * (size C)^4) + 3 + 2000000 * (size C)^3 := by
  rw [reduction, serialize, List.length_append]
  have bound := encNat_length_le_self (cutoffDen C)
  have den := cutoffDen_le C
  have body := (resources C).2.2.2.2
  omega

/-- Both sides of the promise require a Hermitian five-local encoding with unit-bounded
terms and thresholds given by its serialized positive denominator. -/
def LocalEnergyPromise (bits : List Bool) (low : Bool) : Prop :=
  ∃ (E : LhEncoding) (D : ℕ), bits = serialize E D ∧ 0 < D ∧
    lhLocal 5 E ∧ lhHermitian E ∧
    (∀ t ∈ E.terms, ‖Matrix.toEuclideanCLM (𝕜 := ℂ) (lhEmbedTerm E.width t)‖ ≤ 1) ∧
    (if low then groundEnergy (lhHamiltonian E) ≤ 1/(D : ℝ)
     else 2/(D : ℝ) ≤ groundEnergy (lhHamiltonian E))

theorem localEnergy_disjoint (bits : List Bool) :
    ¬ (LocalEnergyPromise bits true ∧ LocalEnergyPromise bits false) := by
  rintro ⟨⟨E, D, h₁, hD, _, _, _, yes⟩, ⟨F, d, h₂, _, _, _, _, no⟩⟩
  obtain ⟨rfl, rfl⟩ := serialize_injective (h₁.symm.trans h₂)
  have hs : 1/(D : ℝ) < 2/(D : ℝ) := (div_lt_div_iff_of_pos_right (by exact_mod_cast hD)).2 (by norm_num)
  exact (not_lt_of_ge (le_trans no yes)) hs

/-- The construction is a promise-preserving map into bit strings describing actual
five-local Hamiltonians, with separated thresholds and polynomial output length. -/
theorem verifier_reduction (C : QmaHistoryCircuit) :
    (Yes C → LocalEnergyPromise (reduction C) true) ∧
    (No C → LocalEnergyPromise (reduction C) false) := by
  have facts := resources C
  constructor
  · intro yes
    refine ⟨_, _, rfl, cutoffDen_pos C, facts.1, facts.2.1, facts.2.2.1, ?_⟩
    exact ((groundEnergy_promise C).1 yes).trans_eq (rationalCutoffs C).1
  · intro no
    refine ⟨_, _, rfl, cutoffDen_pos C, facts.1, facts.2.1, facts.2.2.1, ?_⟩
    exact (rationalCutoffs C).2.symm.trans_le ((groundEnergy_promise C).2 no)

end FormalQChem.Complexity.Kitaev

namespace FormalQChem.Complexity.Kitaev

open Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Concepts.QueryComplexity.DegreeMethod
open Qatlib.Papers.LocalHam06.MainResults

/-- The term-emitting part of the compiler carries a gate and its time, one wire,
or one pair of clock positions. -/
inductive TermDescriptor (m n : ℕ) where
  | propagation (time : Fin m) (gate : FiniteGateCode)
  | boundary (output : Bool) (wire : Fin n)
  | clock (i j : Fin m)

def termDescriptors (n : ℕ) (gs : List FiniteGateCode) (aux : Finset (Fin n)) (out : Fin n) :
    List (TermDescriptor gs.length n) :=
  (List.finRange gs.length).map (fun i => .propagation i (gs.get i)) ++
    aux.sort.map (.boundary false) ++ [.boundary true out] ++
    (List.finRange gs.length).flatMap (fun i => (List.finRange gs.length).map (.clock i))

def TermDescriptor.localTable {m n : ℕ} (b J : ℕ) :
    TermDescriptor m n → IntegerLocalTerm (m + n)
  | .propagation i gate => propagationTerm n b i gate
  | .boundary isOut wire => boundaryTerm m n b isOut wire
  | .clock i j => clockPairTerm m n b J i j

/-- Materializing the descriptors gives exactly the local tables used by the
checked circuit-to-Hamiltonian map, including the illegal-clock penalties. -/
theorem termDescriptors_correct (n b : ℕ) (gs : List FiniteGateCode)
    (aux : Finset (Fin n)) (out : Fin n) :
    (termDescriptors n gs aux out).map (TermDescriptor.localTable b
      (32 * (gs.length + aux.card + 1) + 1)) = outputTerms n b gs aux out := by
  simp [termDescriptors, outputTerms, List.map_flatMap, Function.comp_def, TermDescriptor.localTable]

/-- The generator emits one record per gate and input wire, one output record
and an ordered pair of clock positions for every potential clock penalty. -/
theorem termDescriptors_count (n : ℕ) (gs : List FiniteGateCode)
    (aux : Finset (Fin n)) (out : Fin n) :
    (termDescriptors n gs aux out).length = gs.length + aux.card + 1 + gs.length^2 := by
  simpa only [← termDescriptors_correct, List.length_map] using
    outputTerms_length n 0 gs aux out

/-- A serializer that requests the real and imaginary integer entries of every
emitted local matrix requests at most 2048 entries per record. -/
theorem scalarEntries_bound (C : QmaHistoryCircuit) :
    ((encode C).terms.flatMap qmaClause3TermEntries).length ≤ 2048 *
      ((C.gates.length + 64) + C.initZeroWires.card + 1 + (C.gates.length + 64)^2) := by
  have h (terms : List (LhTerm (encode C).qubitCount))
      (locality : ∀ t ∈ terms, t.wires.length ≤ 5) :
      (terms.flatMap qmaClause3TermEntries).length ≤ 2048 * terms.length := by
    induction terms with
    | nil => simp
    | cons t ts ih =>
      have hl := locality t (by simp)
      have entries : (qmaClause3TermEntries t).length ≤ 2048 := by
        rw [termEntries_length]
        calc
          _ ≤ 2 * (2^5)^2 := by gcongr
          _ = _ := by norm_num
      have rest := ih (fun s hs => locality s (by simp [hs]))
      simp only [List.flatMap_cons, List.length_append, List.length_cons]
      omega
  simpa only [(resources C).2.2.2.1] using h _ (resources C).1

end FormalQChem.Complexity.Kitaev

namespace FormalQChem.Complexity.Kitaev

open Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.UniformBqp.FiniteGateWord
open Qatlib.Concepts.QmaCompleteness.HistoryHam

/-- A preparation procedure attaining ground energy to inverse-polynomial additive
error, followed by an energy measurement of the same accuracy, decides the promise
by midpoint comparison. The two error budgets are separate. -/
theorem preparation_and_measurement_decide (C : QmaHistoryCircuit)
    (ψ : QState (Reg (encode C).qubitCount)) (unit : Normalized ψ) (measured : ℝ)
    (δ : ℝ) (budget : δ ≤ 1 / ((2 : ℝ)^13 * 130 * (size C : ℝ)^4) / 5)
    (prepared : energy (lhHamiltonian (encode C)) ψ ≤ groundEnergy (lhHamiltonian (encode C)) + δ)
    (measurement : |measured - energy (lhHamiltonian (encode C)) ψ| ≤ δ) :
    (Yes C → measured < (yesCutoff C + noCutoff C)/2) ∧
    (No C → (yesCutoff C + noCutoff C)/2 < measured) := by
  have positiveSize : 0 < size C := by unfold size; omega
  have hpos : 0 < 1 / ((2 : ℝ)^13 * 130 * (size C : ℝ)^4) := by positivity
  have e₀ : groundEnergy (lhHamiltonian (encode C)) ≤ energy (lhHamiltonian (encode C)) ψ :=
    csInf_le (energy_range_bddBelow _) ⟨ψ, unit, rfl⟩
  have hgap := promiseGap C
  have hmeas := abs_le.mp measurement
  constructor
  · intro hyes
    linarith [(groundEnergy_promise C).1 hyes, hmeas.2]
  · intro hno
    linarith [(groundEnergy_promise C).2 hno, hmeas.1]

end FormalQChem.Complexity.Kitaev
