module

public import FormalQChemKitaev
public import FormalQChem.Complexity.ElectronicStructurePauli
import Mathlib.Tactic

/-!
# A compiled verifier circuit to a fixed-particle-number Hamiltonian

The dyadic five-local tables of Qatlib's Feynman–Kitaev construction are
decoded into Hermitian spin tables and passed directly to the number-conserving
dual-rail encoding. Repeated wire labels in the input format are handled by
retaining a single local coordinate and reading it at each listed occurrence.

The output is an occupation-basis Hamiltonian with Pauli words represented by
products of pair-local fermionic operators and on-site number penalties.
The supplied-orbital electronic Coulomb reduction of O'Gorman et al. is a
different realization of the source spin problem.

* [Kitaev, Shen & Vyalyi (2002)](https://doi.org/10.1090/gsm/047)
* [Liu, Christandl & Verstraete (2007)](https://doi.org/10.1103/PhysRevLett.98.110503)
* [O'Gorman et al. (2022)](https://doi.org/10.1103/PRXQuantum.3.020322)
-/

@[expose] public section
noncomputable section
namespace FormalQChem.Complexity.Kitaev.ElectronicStructure

open Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.UniformBqp.FiniteGateWord
open Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Papers.LocalHam06.MainResults
open FormalQChem.Complexity.ElectronicStructure
open scoped ComplexConjugate
variable {N : ℕ}

def distinctWire (l : List (Fin N)) : Fin l.toFinset.card ↪ Fin N :=
  (l.toFinset.orderIsoOfFin rfl).toEquiv.toEmbedding.trans (Function.Embedding.subtype _)

def readWire (l : List (Fin N)) (i : Fin l.length) : Fin l.toFinset.card :=
  (l.toFinset.orderIsoOfFin rfl).symm ⟨l.get i, by simp⟩

theorem distinctWire_readWire (l : List (Fin N)) (i : Fin l.length) :
    distinctWire l (readWire l i) = l.get i := by
  change ((l.toFinset.orderIsoOfFin rfl) ((l.toFinset.orderIsoOfFin rfl).symm _) : l.toFinset).val = _
  simp

theorem distinctWire_range (l : List (Fin N)) : Finset.univ.map (distinctWire l) = l.toFinset := by
  ext i
  constructor
  · rintro hi
    obtain ⟨j, _, rfl⟩ := Finset.mem_map.mp hi
    exact ((l.toFinset.orderIsoOfFin rfl) j).property
  · intro hi
    obtain ⟨j, hj⟩ := (l.toFinset.orderIsoOfFin rfl).surjective ⟨i, hi⟩
    exact Finset.mem_map.mpr ⟨j, Finset.mem_univ _, congrArg Subtype.val hj⟩

def tableIndex (l : List (Fin N)) (s : Spin l.toFinset.card) : Fin (2 ^ l.length) :=
  bitVecEquiv l.length (s ∘ readWire l)

theorem tableIndex_restrict (l : List (Fin N)) (x : Spin N) :
    tableIndex l (x ∘ distinctWire l) = lhBitIndex l x := by
  unfold tableIndex lhBitIndex
  congr 1
  funext i
  simp [distinctWire_readWire]

def decodeTerm (width : ℕ) (t : LhTerm N)
    (h : ∀ p q, t.re p q = t.re q p ∧ t.im p q = -t.im q p) : LocalTerm N where
  arity := t.wires.toFinset.card
  wire := distinctWire t.wires
  table := fun x y =>
    lhValueMatrix width t.re t.im (tableIndex t.wires x) (tableIndex t.wires y)
  hermitian := by
    ext x y
    let p := tableIndex t.wires x
    let q := tableIndex t.wires y
    change conj (((t.re q p : ℤ) + Complex.I * (t.im q p : ℤ)) / (2^width : ℂ)) =
      ((t.re p q : ℤ) + Complex.I * (t.im p q : ℤ)) / (2^width : ℂ)
    simp only [map_div₀, map_add, map_mul, map_intCast, Complex.conj_I, map_pow, map_ofNat]
    rw [(h q p).1, (h q p).2, Int.cast_neg, neg_mul_neg]

private theorem outside_iff (l : List (Fin N)) (x y : Reg N) :
    lhAgreeOutside l x y = true ↔ ∀ i ∉ l.toFinset, y i = x i := by
  simp only [lhAgreeOutside, List.all_eq_true, List.mem_finRange, forall_const,
    Bool.or_eq_true, List.contains_iff_mem, beq_iff_eq, List.mem_toFinset]
  constructor
  · intro h i hi
    exact ((h i).resolve_left hi).symm
  · intro h i
    by_cases hi : i ∈ l
    · exact Or.inl hi
    · exact Or.inr (h i hi).symm

/-- Equality holds entry by entry for each local term, including arbitrary
wire reordering and repeated labels. -/
theorem decodeTerm_kernel (width : ℕ) (t : LhTerm N) (h) :
    (decodeTerm width t h).kernel = lhEmbedTerm width t := by
  ext x y
  change lhValueMatrix width t.re t.im (tableIndex t.wires (x ∘ distinctWire t.wires))
    (tableIndex t.wires (y ∘ distinctWire t.wires)) * untouched (distinctWire t.wires) x y = _
  rw [tableIndex_restrict, tableIndex_restrict, untouched_eq, distinctWire_range]
  change _ = if lhAgreeOutside t.wires x y then _ else 0
  by_cases outside : ∀ i ∉ t.wires.toFinset, y i = x i
  · rw [ite_eq_left outside, ite_eq_left ((outside_iff _ _ _).mpr outside), mul_one]
  · rw [ite_eq_right outside, ite_eq_right (fun h => outside ((outside_iff _ _ _).mp h)), mul_zero]

def decodeTerms (E : LhEncoding) (h : lhHermitian E) (j : Fin E.terms.length) : LocalTerm E.qubitCount :=
  decodeTerm E.width (E.terms.get j) (h _ (E.terms.get_mem j))

/-- The two finite many-body matrices are equal before any energy comparison. -/
theorem decodeHamiltonian (E : LhEncoding) (h : lhHermitian E) :
    ∑ j, (decodeTerms E h j).kernel = lhHamiltonian E := by
  simp only [decodeTerms, decodeTerm_kernel]
  rw [← List.sum_ofFn]
  change (List.ofFn ((lhEmbedTerm E.width) ∘ E.terms.get)).sum = _
  rw [← List.map_ofFn, List.ofFn_get]
  rfl

def circuitTerms (C : QmaHistoryCircuit) := decodeTerms (encode C) (resources C).2.1

def circuitPenalty (C : QmaHistoryCircuit) : ℝ :=
  2 + ((encode C).terms.length : ℝ) * 1048576

def electronicEnergy (C : QmaHistoryCircuit) :=
  fermionEnergy (localCoefficients (circuitTerms C)) (localWords (circuitTerms C)) (circuitPenalty C)

private theorem table_is_global_entry (t : LocalTerm N) (r c : Spin t.arity) :
    ∃ x y, t.table r c = t.kernel x y := by
  let extBits (s : Spin t.arity) := Function.extend t.wire s (fun _ => false)
  refine ⟨extBits r, extBits c, ?_⟩
  have onWire (s : Spin t.arity) : extBits s ∘ t.wire = s := Function.extend_comp t.wire.injective _ _
  have offWire (i : Fin N) (hi : i ∉ Finset.univ.map t.wire) : extBits c i = extBits r i := by
    have hi' : ¬∃ j, t.wire j = i := by simpa using hi
    simp only [extBits, Function.extend_apply' _ _ _ hi']
  rw [LocalTerm.kernel, onWire, onWire, untouched_eq, ite_eq_left offWire, mul_one]

private theorem entry_norm_bound {α : Type*} [Fintype α] [DecidableEq α] (A : Matrix α α ℂ) (x y : α) :
    ‖A x y‖ ≤ ‖Matrix.toEuclideanCLM (𝕜 := ℂ) A‖ := by
  let e : EuclideanSpace ℂ α := EuclideanSpace.single y 1
  let H := Matrix.toEuclideanCLM (𝕜 := ℂ) A
  have h : H e x = A x y := by
    change A.mulVec (Pi.single y 1) x = A x y
    rw [Matrix.mulVec_single_one]; rfl
  rw [← h]
  exact (PiLp.norm_apply_le _ _).trans ((H.le_opNorm e).trans_eq (by simp [e, H]))

/-- The actual local tables extracted from the normalized circuit have entries
of modulus at most one, with at most five distinct wires per term. -/
theorem circuitTables (C : QmaHistoryCircuit) :
    (∀ j, (circuitTerms C j).arity ≤ 5) ∧
    ∀ j x y, ‖(circuitTerms C j).table x y‖ ≤ 1 := by
  constructor
  · intro j
    exact (List.toFinset_card_le ((encode C).terms.get j).wires).trans ((resources C).1 _ ((encode C).terms.get_mem j))
  · intro j x y
    obtain ⟨u,v,h⟩ := table_is_global_entry (circuitTerms C j) x y
    rw [h, circuitTerms, decodeTerms, decodeTerm_kernel]
    exact (entry_norm_bound _ _ _).trans ((resources C).2.2.1 _ ((encode C).terms.get_mem j))

private theorem circuitPenalty_sufficient (C : QmaHistoryCircuit) :
    noCutoff C + strength (localCoefficients (circuitTerms C)) ≤ circuitPenalty C := by
  have ht := circuitTables C
  have hs := localExpansion_strength (circuitTerms C) 5 1 ht.1 zero_le_one ht.2
  have hcut : noCutoff C ≤ 2 := by
    rw [(rationalCutoffs C).2, div_le_iff₀ (by exact_mod_cast cutoffDen_pos C)]
    have hd : (1:ℝ) ≤ cutoffDen C := by exact_mod_cast cutoffDen_pos C
    linarith
  push_cast at hs
  norm_num at hs
  unfold circuitPenalty
  linarith

/-- The number of particles is fixed to the padded clock-plus-work-register
size, with two fermionic modes per source qubit. -/
theorem electronCount (C : QmaHistoryCircuit) :
    (encode C).qubitCount = C.gates.length + 64 + C.qubits ∧
    Fintype.card (Fin (encode C).qubitCount × Bool) = 2 * (C.gates.length + 64 + C.qubits) := by
  have h : (encode C).qubitCount = C.gates.length + 64 + C.qubits := by
    change (paid64 C).gates.length + (paid64 C).qubits = _
    rw [paid64_length]; rfl
  exact ⟨h, by simp [h, Nat.mul_comm]⟩

/-- For m source terms the encoded interaction uses at most 1024m Pauli
words, each touching at most ten physical modes. The integer penalty is
2 + 1048576m. One two-mode number penalty is added per source qubit. -/
theorem circuitFermionResources (C : QmaHistoryCircuit) :
    Fintype.card (ExpansionIndex (circuitTerms C)) ≤ (encode C).terms.length * 1024 ∧
    (∀ u, (activeModes (localWords (circuitTerms C) u)).card ≤ 10) ∧
    circuitPenalty C = 2 + ((encode C).terms.length : ℝ) * 1048576 := by
  have hs := localExpansion_size (circuitTerms C) 5 (circuitTables C).1
  refine ⟨by simpa only [show 4^5 = 1024 by decide] using hs.1, ?_, rfl⟩
  intro u
  simpa [activeModes, Nat.mul_comm] using Nat.mul_le_mul_left 2 (hs.2 u)

/-- Direct Feynman–Kitaev-to-fermion promise transfer for the supplied
amplified verifier, covering every fixed-number trial state in the NO case. -/
theorem circuit_to_fixedParticle (C : QmaHistoryCircuit) :
    (Yes C → ∃ φ, FormalQChem.Complexity.ElectronicStructure.mass φ = 1 ∧ electronicEnergy C φ ≤ yesCutoff C) ∧
    (No C → ∀ φ, FormalQChem.Complexity.ElectronicStructure.mass φ = 1 → noCutoff C ≤ electronicEnergy C φ) := by
  have h := localHamiltonian_to_fixedParticle (circuitTerms C) (circuitPenalty C)
    (yesCutoff C) (noCutoff C) (by unfold circuitPenalty; positivity) (circuitPenalty_sufficient C)
  have eqH : ∑ j, (circuitTerms C j).kernel = lhHamiltonian (encode C) := decodeHamiltonian _ _
  rw [eqH] at h
  exact ⟨fun yes => h.1 ((witnessEnergy_promise C).1 yes),
    fun no => h.2 ((witnessEnergy_promise C).2 no)⟩

def electronicOperator (C : QmaHistoryCircuit) :=
  fermionOperator (localCoefficients (circuitTerms C)) (localWords (circuitTerms C)) (circuitPenalty C)

private theorem ground_le_trial (C : QmaHistoryCircuit) (φ : Occupation (encode C).qubitCount → ℂ)
    (unit : FormalQChem.Complexity.ElectronicStructure.mass φ = 1) :
    FormalQChem.RayleighRitz.groundEnergy (electronicOperator C) ≤ electronicEnergy C φ := by
  let ψ : EuclideanSpace ℂ (Occupation (encode C).qubitCount) := WithLp.toLp 2 φ
  have hm : ‖ψ‖ ^ 2 = 1 := (EuclideanSpace.norm_sq_eq ψ).trans unit
  have hn : ψ ≠ 0 := fun h => by simp [h] at hm
  have h := FormalQChem.RayleighRitz.groundEnergy_le (electronicOperator C) hn
  rw [ContinuousLinearMap.rayleighQuotient, hm, div_one] at h
  exact h.trans_eq (fermionExpectation _ _ _ ψ)

/-- Preparing a fixed-number trial within δ of the ground energy and measuring
its energy within δ suffices to decide the source verification promise, with an
explicit inverse-quartic δ. The prepared state may have support outside the code. -/
theorem electronicPreparation_decides (C : QmaHistoryCircuit)
    (φ : Occupation (encode C).qubitCount → ℂ) (unit : FormalQChem.Complexity.ElectronicStructure.mass φ = 1)
    (δ measured : ℝ) (budget : δ ≤ 1 / ((2 : ℝ)^13 * 130 * (size C : ℝ)^4) / 5)
    (prepared : electronicEnergy C φ ≤ FormalQChem.RayleighRitz.groundEnergy (electronicOperator C) + δ)
    (readout : |measured - electronicEnergy C φ| ≤ δ) :
    (Yes C → measured < (yesCutoff C + noCutoff C)/2) ∧
    (No C → (yesCutoff C + noCutoff C)/2 < measured) := by
  have hs : 0 < size C := by unfold size; omega
  have hpos : 0 < 1 / ((2 : ℝ)^13 * 130 * (size C : ℝ)^4) := by positivity
  have gap := promiseGap C
  have hr := abs_le.mp readout
  constructor
  · intro yes
    obtain ⟨v,hv,he⟩ := (circuit_to_fixedParticle C).1 yes
    linarith [ground_le_trial C v hv, hr.2]
  · intro no
    linarith [(circuit_to_fixedParticle C).2 no φ unit, hr.1]

end FormalQChem.Complexity.Kitaev.ElectronicStructure
