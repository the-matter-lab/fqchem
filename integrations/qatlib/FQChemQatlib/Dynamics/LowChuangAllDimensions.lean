module

public import FQChemQatlib.Dynamics.LowChuangSingleton
public import FQChemQatlib.Dynamics.LowChuangReadout
import all FQChemQatlib.Dynamics.LowChuangElementary
import all FQChemQatlib.Dynamics.LowChuangPadding
import all FQChemQatlib.Dynamics.LowChuangReadout
import Mathlib.Tactic

/-! # Standard-form Hamiltonian simulation including a one-dimensional system

The universal program and its oracle schedule are unchanged. The cubic frame
reflection uses the ancilla-free phase-gradient circuit on the original wires.

The source result is [Low and Chuang, Theorem 1](https://doi.org/10.22331/q-2019-07-12-163). The ancilla-free primitive used for the dimension-one case comes from [Gidney, §2.10 and Fig. 21](https://arxiv.org/abs/1706.07884).
-/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.Singleton

open Physical Matrix Query Padding
open Qatlib.Concepts.GateVocabulary.LocalReflectionGates Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Concepts.QmaCompleteness.HistoryHam Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.BlockEncoding Qatlib.Concepts.BlockEncoding.Encoding Qatlib.Concepts.BlockEncoding.EncodingCore
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.QspSimulation.Achievability Qatlib.Concepts.PhaseGeometry.Phase
open Qatlib.Concepts.BlockEncoding.Postselection.Encoding Qatlib.Papers.Qubitization19.MainResults
open Qatlib.Concepts.QsvtCore.LinearSystems
open scoped Matrix.Norms.L2Operator Kronecker

variable {a r : ℕ} {J I : Type} [Fintype J] [Fintype I] [DecidableEq J] [DecidableEq I]

/-- A single constant applies to each gate of the original signal-processing
word on any qubit register. -/
theorem allFrameGates (zero : Reg a) {M : Operator a r}
    (gate : FrameGate (encodingFiber (I:=Reg r) zero) M) : Emits M (11000*(a+4)) := by
  apply frameGate_emits_of_cubic zero (by omega) _ gate
  intro z hz
  rw [cubic_coordinate zero hz,localHadamards]
  have had := Physical.single (Elementary.flags (a:=a) (r:=r) _ (tensorGate_unitary hadamard_unitary hadamard_unitary))
  have scalar := Physical.single (Elementary.flags (a:=a) (r:=r) _ (scalar_pair (-z) (by
    rcases hz with rfl|rfl <;> simp [IsPhase])))
  rw [scalar_flags] at scalar
  have mark := coordinateMark (r:=r) zero
  have used := mul_emits (mul_emits had (mul_emits scalar mark)) (adj_emits had)
  apply weaken _ (by omega : 1+(1+(7*(2*(720*(a+4))+2*(a+1)+1)+4))+1 ≤ 11000*(a+4))
  rw [Matrix.smul_mul,Matrix.one_mul,neg_smul,← smul_neg,neg_sub] at used
  exact used


/-- The circuit precedes both inputs and uses the same oracle counts on every width. -/
theorem allQubitRegisters (zero : Reg a) (t ε : ℝ) (positive : 0<ε) (small : ε<1) :
    ∃ q : ℕ, IsPaperCutoffQ t ε q ∧ ∃ program : List (Step (Basis a r) StandardOracle),
      cost StandardOracle.prepare program = 54*(64*q+1) ∧
      cost StandardOracle.block program = 27*(64*q+1) ∧
      fixedCount program ≤ 11000*(a+4)*(27*(64*q+8)-2) ∧
      (∀ M, .fixed M ∈ program → Elementary a r M) ∧
      ∀ (G : Matrix (Reg a) (Reg a) ℂ) (U : Matrix (Reg a × Reg r) _ ℂ) (H : Matrix (Reg r) (Reg r) ℂ),
        G ∈ Matrix.unitaryGroup _ ℂ → U ∈ Matrix.unitaryGroup _ ℂ → H.IsHermitian →
        let F := encodingFiber (I:=Reg r) zero
        let prepared := TensorGate G (1 : Matrix (Reg r) _ ℂ) * F
        compress prepared U prepared = H →
        let M := run (standardInput G U) program
        let R := hamiltonianFrame F
        ‖compress R M R - hamiltonianEvolution H t‖ ≤ ε^2/2 ∧
        ∀ ψ : QState (Reg r), Normalized ψ → 1-ε^2 ≤ postselectionProbability M R R ψ := by
  obtain ⟨q,hq,word,prep,block,hsize,covered,_,acc⟩ :=
    standardFormProgram (I:=Reg r) zero t ε positive small
  obtain ⟨out,eval,cost,size,actual⟩ := expand word
    (fun M h => allFrameGates zero (covered M h))
  refine ⟨q,hq,out,(cost _).trans prep,(cost _).trans block,hsize ▸ size,actual,?_⟩
  intro G U H hG hU hH
  dsimp only
  intro hin
  rw [eval]
  exact acc G U H hG hU hH hin

/-- Binary embedding of arbitrarily sized finite inputs, including dimension one. -/
theorem allFiniteRegisters (z : J) (t ε : ℝ) (positive : 0<ε) (small : ε<1) :
    let a := Nat.clog 2 (Fintype.card J)
    let r := Nat.clog 2 (Fintype.card I)
    let j := physicalBasis J
    let s := physicalBasis I
    let E := coord s
    ∃ q : ℕ, IsPaperCutoffQ t ε q ∧ ∃ program : List (Query.Step (Basis a r) StandardOracle),
      Query.cost StandardOracle.prepare program = 54*(64*q+1) ∧
      Query.cost StandardOracle.block program = 27*(64*q+1) ∧
      Query.fixedCount program ≤ 11000*(a+4)*(27*(64*q+8)-2) ∧
      (∀ M, .fixed M ∈ program → Elementary a r M) ∧
      ∀ (G : Matrix J J ℂ) (U : Matrix (J×I) (J×I) ℂ) (H : Matrix I I ℂ),
        G ∈ Matrix.unitaryGroup J ℂ → U ∈ Matrix.unitaryGroup _ ℂ → H.IsHermitian →
        let f := preparation (I:=I) z G
        compress f U f = H →
        let M := Query.run (standardInput (pad (coord j) G) (pad (coord (j.prodMap s)) U)) program
        let R := hamiltonianFrame (encodingFiber (I:=Reg r) (j z))
        ‖compress E (compress R M R) E - hamiltonianEvolution H t‖ ≤ ε^2/2 ∧
        ∀ ψ : QState I, Normalized ψ → 1-ε^2 ≤ postselectionProbability M R R (E *ᵥ ψ) := by
  let j := physicalBasis J
  let s := physicalBasis I
  let E := coord s
  let Z := coord (j.prodMap s)
  let R := hamiltonianFrame (encodingFiber (I:=Reg (Nat.clog 2 (Fintype.card I))) (j z))
  obtain ⟨q,hq,p,cg,cu,gates,loc,corr⟩ := allQubitRegisters (r:=Nat.clog 2 (Fintype.card I)) (j z) t ε positive small
  refine ⟨q,hq,p,cg,cu,gates,loc,?_⟩
  intro G U H hG hU hH
  dsimp only
  intro signal
  let M := Query.run (standardInput (pad (coord j) G) (pad Z U)) p
  have out := corr (pad (coord j) G) (pad Z U) (pad E H)
    (pad_unit _ (coord_iso j) hG) (pad_unit _ (coord_iso _) hU) (pad_hermitian _ hH)
    ((padded_signal j s z G U hG).trans (congrArg (pad E) signal))
  exact ⟨(unpad_error s (compress R M R) H t).trans out.1,
    fun ψ hψ => out.2 _ (Qatlib.Concepts.BlockEncoding.Postselection.Encoding.IsIsometry.normalized_mulVec (coord_iso s) hψ)⟩

/-- Ordinary coordinate initialization, unitary simulation, readout and primitive gate counts on the same allocated registers. -/
theorem allFiniteCoordinateSimulation (z : J) (t ε : ℝ) (positive : 0<ε) (small : ε<1) :
    let a := Nat.clog 2 (Fintype.card J)
    let r := Nat.clog 2 (Fintype.card I)
    let j := physicalBasis J
    let s := physicalBasis I
    let E := coord s
    ∃ q : ℕ, IsPaperCutoffQ t ε q ∧ ∃ program : List (Query.Step (Basis a r) StandardOracle),
      cost StandardOracle.prepare program = 54*(64*q+1) ∧
      cost StandardOracle.block program = 27*(64*q+1) ∧
      fixedCount program ≤ 11000*(a+4)*(27*(64*q+8)-2)+2 ∧
      (∀ M, .fixed M ∈ program → Elementary a r M) ∧
      ∀ (G : Matrix J J ℂ) (U : Matrix (J×I) (J×I) ℂ) (H : Matrix I I ℂ),
        G ∈ Matrix.unitaryGroup J ℂ → U ∈ Matrix.unitaryGroup _ ℂ → H.IsHermitian →
        let f := preparation (I:=I) z G
        compress f U f = H →
        let M := run (standardInput (pad (coord j) G) (pad (coord (j.prodMap s)) U)) program
        let F := flagsZero (I:=Reg r) (j z)
        ‖compress E (compress F M F) E - hamiltonianEvolution H t‖ ≤ ε^2/2 ∧
        ∀ ψ : QState I, Normalized ψ → 1-ε^2 ≤ postselectionProbability M F F (E *ᵥ ψ) := by
  let j := physicalBasis J
  let s := physicalBasis I
  obtain ⟨q, hq, program, prep, block, bound, legal, work⟩ := allFiniteRegisters (I:=I) z t ε positive small
  obtain ⟨wrapped, count, size, fixed, acts⟩ := coordinate_program (j z) program legal
  refine ⟨q, hq, wrapped, (count _).trans prep, (count _).trans block,
    size.le.trans (Nat.add_le_add_right bound 2), fixed, ?_⟩
  intro G U H hG hU hH
  dsimp only
  intro signal
  let data := standardInput (pad (coord j) G) (pad (coord (j.prodMap s)) U)
  obtain ⟨op, mass⟩ := acts data
  obtain ⟨err, prob⟩ := work G U H hG hU hH signal
  exact ⟨op.symm ▸ err, fun ψ hψ => (mass _).symm ▸ prob ψ hψ⟩

end FQChemQatlib.Dynamics.LowChuang.Singleton
