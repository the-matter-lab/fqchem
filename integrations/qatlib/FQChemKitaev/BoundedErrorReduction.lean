module

public import FQChemKitaev.AmplifierCost
public import FQChemKitaev.UniformCircuits

/-! # Bounded-error decision circuits as ground-energy instances

Starting from the ordinary 2/3 versus 1/3 decision promise, the explicit
gate-word amplifier attains the history Hamiltonian's asymmetric precision
target. The resulting five-local Hamiltonian and the fixed-number occupation
Hamiltonian preserve the answer. The last theorem starts with the actual gate
word emitted by Qatlib's clocked classical generator and its classical basis input. -/

@[expose] public section
noncomputable section

namespace FQChem.Complexity.Kitaev.BoundedErrorReduction

open Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Concepts.LocalMachine.LocalTransport.UniformBqpDefs
open Amplify AmplificationBounds

def amplified (C : QmaHistoryCircuit) := repeatCircuit C (rounds (size C))

private theorem size_positive (C : QmaHistoryCircuit) : 0 < size C := by unfold size; omega

private theorem growth (C : QmaHistoryCircuit) :
    size (amplified C) ≤ 3^(rounds (size C)) * size C :=
  size_after (fun j => (repeatCircuit C j).gates.length) (fun j => (repeatCircuit C j).qubits)
    (repeat_gate_count C) (repeat_width C) _

/-- Polynomial-size amplification, including gate count and electron register size. -/
theorem amplified_size (C : QmaHistoryCircuit) : size (amplified C) ≤ 4^9*(size C)^3 :=
  (growth C).trans (polynomial_size (size_positive C))

private theorem initialized_after {k : ℕ} (C : QmaHistoryCircuit) (h : 0 < k) :
    (repeatCircuit C k).initZeroWires = Finset.univ := by
  cases k with
  | zero => omega
  | succ j => exact repeat_all_zero C j

private theorem denominator_ge_four (t : ℕ) : (4 : ℝ) ≤ 2^14 * ((t : ℝ) + 65)^2 := by
  nlinarith only [Nat.cast_nonneg (α := ℝ) t, sq_nonneg (t : ℝ)]

/-- Actual circuit acceptance at the conventional thresholds supplies the YES and
NO premises for the five-local reduction after the explicitly chosen majority levels. -/
theorem amplified_promise (C : QmaHistoryCircuit) :
    (2/3 ≤ zeroAcceptance C → Yes (amplified C)) ∧
    (zeroAcceptance C ≤ 1/3 → No (amplified C)) := by
  let A := amplified C
  have prob := zeroAcceptance_mem C
  have bound : A.gates.length + 65 ≤ 3^(rounds (size C)) * size C := by
    apply le_trans _ (growth C)
    change A.gates.length + 65 ≤ A.gates.length + A.qubits + 65
    omega
  have precision {p : ℝ} (lo : 0 ≤ p) (hi : p ≤ 1/3) :
      Majority.repeatedError p (rounds (size C)) ≤ 1 / (2^14 * ((A.gates.length : ℝ) + 65)^2) := by
    simpa only [Nat.cast_add, Nat.cast_ofNat] using reaches_precision lo hi (size_positive C)
      (show 0 < A.gates.length + 65 by omega) bound
  have clean : A.initZeroWires = Finset.univ :=
    initialized_after C (by unfold rounds; omega)
  constructor
  · intro yes
    have err := precision (p := 1-zeroAcceptance C) (sub_nonneg.mpr prob.2) (by linarith)
    rw [← repeat_reject] at err
    refine ⟨_, zero_input_legal A, normalized_ket _, ?_⟩
    change 1 - _ ≤ zeroAcceptance A
    change 1 - zeroAcceptance A ≤ _ at err
    linarith
  · intro no ψ legal normalized
    have err := precision prob.1 no
    rw [← repeat_accept] at err
    exact (witnessFree_acceptance A clean ψ legal normalized).le.trans
      (err.trans (one_div_le_one_div_of_le (by norm_num) (denominator_ge_four _)))

/-- One deterministic compiler output separates the two ordinary BQP circuit answers. -/
theorem circuit_to_local_energy (C : QmaHistoryCircuit) :
    let out := (Compiler.compile (Compiler.source (amplified C))).val
    (2/3 ≤ zeroAcceptance C → Compiler.EnergyPromise out true) ∧
    (zeroAcceptance C ≤ 1/3 → Compiler.EnergyPromise out false) := by
  have promise := amplified_promise C
  have compiled := Compiler.compile_energyPromise (amplified C)
  exact ⟨compiled.1 ∘ promise.1, compiled.2 ∘ promise.2⟩

/-- Bit-string reduction from a decision circuit to five-local term templates.
The clock includes parsing the input, compiling majority layers, and emitting the output. -/
def transducer := Compiler.afterBits AmplifierCost.compile

private theorem transducer_value (bits : List Bool) :
    (transducer bits).val = (Compiler.compileBits (AmplifierCost.compile bits).val).val := rfl

private theorem transducer_output (C : QmaHistoryCircuit) :
    (transducer (Compiler.binary (Compiler.source C)).val).val =
      (Compiler.compileBits (Compiler.binary (Compiler.source (amplified C))).val).val := by
  rw [transducer_value]
  exact congrArg (fun bits => (Compiler.compileBits bits).val) (AmplifierCost.compile_correct C)

/-- Polynomial in the input bit length on every input to the reduction. -/
theorem transducer_time (bits : List Bool) :
    let L := bits.length
    let p := AmplifierCost.budget (2*L+65) + L*(8*L+27) + 4*L+20
    (transducer bits).steps ≤ 400*(p+70)^3+2*p+4 := by
  dsimp only
  have amp := AmplifierCost.compile_time bits
  have len := (AmplifierCost.length_le_steps bits).trans amp
  have clock := Compiler.compileBits_time (AmplifierCost.compile bits).val
  have poly := Nat.mul_le_mul_left 400 (Nat.pow_le_pow_left (Nat.add_le_add_right len 70) 3)
  unfold transducer Compiler.afterBits Compiler.Run.charge
  dsimp only
  omega

/-- The very bits emitted by the costed reduction decode to the amplified circuit's
Hermitian Hamiltonian and rational cutoffs, with the correct answer on promised inputs. -/
theorem transducer_correct (C : QmaHistoryCircuit) :
    let out := (transducer (Compiler.binary (Compiler.source C)).val).val
    let A := amplified C
    Compiler.decodeBits out = some (encode A, 1/(cutoffDen A : ℚ), 2/(cutoffDen A : ℚ)) ∧
    (2/3 ≤ zeroAcceptance C → Compiler.EnergyPromise (Compiler.unbinary out).val true) ∧
    (zeroAcceptance C ≤ 1/3 → Compiler.EnergyPromise (Compiler.unbinary out).val false) := by
  dsimp only
  rw [transducer_output]
  refine ⟨Compiler.compileBits_correct (amplified C), ?_⟩
  rw [Compiler.unbinary_compileBits]
  exact circuit_to_local_energy C

/-- The separation between the two decoded energies is inverse polynomial in
the size of the original circuit, before the compiler adds any gates. -/
theorem transducer_promise_gap (C : QmaHistoryCircuit) :
    1 / ((2 : ℝ)^13 * 130 * ((4^9*(size C)^3 : ℕ) : ℝ)^4) ≤
      noCutoff (amplified C) - yesCutoff (amplified C) := by
  apply le_trans _ (promiseGap (amplified C))
  have h : (size (amplified C) : ℝ) ≤ ((4^9*(size C)^3 : ℕ) : ℝ) := by
    exact_mod_cast amplified_size C
  apply one_div_le_one_div_of_le
  · have : 0 < (size (amplified C) : ℝ) := by exact_mod_cast size_positive (amplified C)
    positivity
  · gcongr

/-- Fixed-particle energy thresholds decide the original bounded-error circuit.
In the rejecting case the bound holds for every normalized fixed-number state. -/
theorem circuit_to_electronic_energy (C : QmaHistoryCircuit) :
    let A := amplified C
    (2/3 ≤ zeroAcceptance C → ∃ φ, FQChem.Complexity.ElectronicStructure.mass φ = 1 ∧
      ElectronicStructure.electronicEnergy A φ ≤ yesCutoff A) ∧
    (zeroAcceptance C ≤ 1/3 → ∀ φ, FQChem.Complexity.ElectronicStructure.mass φ = 1 →
      noCutoff A ≤ ElectronicStructure.electronicEnergy A φ) := by
  have promise := amplified_promise C
  have electronic := ElectronicStructure.circuit_to_fixedParticle (amplified C)
  exact ⟨electronic.1 ∘ promise.1, electronic.2 ∘ promise.2⟩

/-- Start with a clocked uniform finite-gate generator. The energy promise uses
the generated circuit's 2/3 or 1/3 Born acceptance on its actual basis input,
and the amplified instance size is polynomial in the generator bounds. -/
theorem uniform_circuit_to_electronic_energy (g : UniformBqpGenerator)
    (valid : uniformBqpGeneratorValid g) (n : ℕ) :
    ∃ q gates, uniformBqpGeneratedAt g n = some (q, gates) ∧
      ∃ legal : finiteWordLegal q gates = true, ∀ x : Reg q,
        let A := amplified (UniformCircuits.history gates legal x)
        size A ≤ 4^9*(uniformBqpWordBound g n + 2*uniformBqpSpaceBound g n + 66)^3 ∧
        (2/3 ≤ uniformBqpAcceptProb q gates x → ∃ φ,
          FQChem.Complexity.ElectronicStructure.mass φ = 1 ∧
          ElectronicStructure.electronicEnergy A φ ≤ yesCutoff A) ∧
        (uniformBqpAcceptProb q gates x ≤ 1/3 → ∀ φ,
          FQChem.Complexity.ElectronicStructure.mass φ = 1 →
          noCutoff A ≤ ElectronicStructure.electronicEnergy A φ) := by
  obtain ⟨q, gates, generator, legal, inputs⟩ := UniformCircuits.generated_electronic_promise g valid n
  refine ⟨q, gates, generator, legal, fun x => ?_⟩
  let C := UniformCircuits.history gates legal x
  have same : zeroAcceptance C = uniformBqpAcceptProb q gates x :=
    UniformCircuits.history_acceptance gates legal x
  refine ⟨(amplified_size C).trans (Nat.mul_le_mul_left _ (Nat.pow_le_pow_left (inputs x).1 3)), ?_⟩
  simpa only [same] using circuit_to_electronic_energy C

end FQChem.Complexity.Kitaev.BoundedErrorReduction
