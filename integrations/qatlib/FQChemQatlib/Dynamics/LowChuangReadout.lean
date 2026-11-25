module

public import FQChemQatlib.Dynamics.LowChuangPadding

/-! # Computational-basis initialization and readout for qubitized simulation -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang

open Matrix Query Physical Padding Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.QsvtCore.LinearSystems Qatlib.Concepts.QspSimulation.Achievability
open Qatlib.Concepts.BlockEncoding.EncodingCore Qatlib.Concepts.BlockEncoding
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.BlockEncoding.Postselection.Encoding
open Qatlib.Concepts.GateVocabulary.LocalReflectionGates Qatlib.Papers.Qubitization19.MainResults
open scoped Matrix.Norms.L2Operator

variable {J I : Type} [Fintype J] [Fintype I] [DecidableEq J] [DecidableEq I]

private theorem coordinate_iso (z : J) : IsIsometry (flagsZero (I:=I) z) :=
  coordinatePhaseFrame_isometry (coordinatePhaseFrame_isometry (encodingFiber_isIsometry z))

/-- Hadamards on both flags turn average-frame compression and postselection
into computational-coordinate initialization and readout. -/
theorem coordinate_acts (z : J) (M : Matrix (Signals J I) (Signals J I) ℂ) :
    let R := hamiltonianFrame (encodingFiber (I:=I) z)
    let F := flagsZero (I:=I) z
    let U := flagsHadamardᴴ * M * flagsHadamard
    compress F U F = compress R M R ∧
    ∀ ψ : QState I, postselectionProbability U F F ψ = postselectionProbability M R R ψ := by
  let R := hamiltonianFrame (encodingFiber (I:=I) z)
  let F := flagsZero (I:=I) z
  let U := flagsHadamardᴴ * M * flagsHadamard
  have phase : (inverseLabelPhase*inverseLabelPhase) * star (inverseLabelPhase*inverseLabelPhase) = 1 := by
    rw [star_mul]; calc
      _ = (star inverseLabelPhase*inverseLabelPhase)^2 := by ring
      _ = 1 := by rw [inverseLabelPhase_unit]; norm_num
  have eq : compress F U F = compress R M R := by
    simp only [R,hamiltonianFrame_coordinates,compress,Matrix.conjTranspose_smul,Matrix.conjTranspose_mul,
      Matrix.mul_smul,Matrix.smul_mul,smul_smul,phase,one_smul,Matrix.mul_assoc,U,F]
  refine ⟨eq,fun ψ => ?_⟩
  have hr : IsIsometry R := averageFrame_isIsometry (averageFrame_isIsometry (encodingFiber_isIsometry z))
  rw [postselectionProbability_eq_norm_sq (coordinate_iso z),postselectionProbability_eq_norm_sq hr]
  change ‖(Qatlib.Concepts.BlockEncoding.Postselection.stateVector (compress F U F *ᵥ ψ))‖^2 = _
  rw [eq]; rfl

private theorem coordinate_program {a r : ℕ} (zero : Reg a)
    (program : List (Step (Basis a r) StandardOracle))
    (legal : ∀ M, .fixed M ∈ program → Elementary a r M) :
    ∃ wrapped : List (Step (Basis a r) StandardOracle),
      (∀ k, cost k wrapped = cost k program) ∧ fixedCount wrapped = fixedCount program + 2 ∧
      (∀ M, .fixed M ∈ wrapped → Elementary a r M) ∧
      ∀ data : StandardOracle → Operator a r,
        let F := flagsZero (I := Reg r) zero
        let R := hamiltonianFrame (encodingFiber (I := Reg r) zero)
        compress F (run data wrapped) F = compress R (run data program) R ∧
        ∀ ψ : QState (Reg r), postselectionProbability (run data wrapped) F F ψ =
          postselectionProbability (run data program) R R ψ := by
  let T := flagsHadamard (J := Reg a) (I := Reg r)
  let wrapped := .fixed Tᴴ :: (program ++ [.fixed T])
  have gate : Elementary a r T := by
    rw [show T = onFlags (J := Reg a) (I := Reg r) (TensorGate Hadamard Hadamard) from localHadamards]
    exact Elementary.flags _ (tensorGate_unitary hadamard_unitary hadamard_unitary)
  refine ⟨wrapped, ?_, ?_, ?_, ?_⟩
  · intro k
    simp [wrapped, cost, cost_append]
  · simp [wrapped, fixedCount, fixed_append, Nat.add_assoc]
  · intro M mem
    rcases List.mem_cons.mp mem with eq | tail
    · cases eq; exact .adj gate
    rcases List.mem_append.mp tail with hp | last
    · exact legal _ hp
    · cases List.mem_singleton.mp last; exact gate
  · intro data
    have eval : run data wrapped = Tᴴ * run data program * T := by
      simp [wrapped, run, matrix, run_append, Matrix.mul_assoc]
    dsimp only
    rw [eval]
    exact coordinate_acts zero (run data program)

/-- The explicit, ordinary coordinate-input version of the standard-form
simulation, including the gates to prepare and unprepare both signal flags.
The physical oracle is identity on unused computational coordinates. -/
theorem finiteCoordinateSimulation (z : J) (two : 1 < Fintype.card I) (t ε : ℝ) (positive : 0<ε) (small : ε<1) :
    let a := Nat.clog 2 (Fintype.card J)
    let r := Nat.clog 2 (Fintype.card I)
    let j := physicalBasis J
    let s := physicalBasis I
    let E := coord s
    ∃ q : ℕ, IsPaperCutoffQ t ε q ∧ ∃ program : List (Query.Step (Basis a r) StandardOracle),
      cost StandardOracle.prepare program = 54*(64*q+1) ∧
      cost StandardOracle.block program = 27*(64*q+1) ∧
      fixedCount program ≤ 250*(a+4)*(27*(64*q+8)-2)+2 ∧
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
  obtain ⟨q, hq, program, prep, block, bound, legal, work⟩ := finiteSimulation z two t ε positive small
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

end FQChemQatlib.Dynamics.LowChuang
