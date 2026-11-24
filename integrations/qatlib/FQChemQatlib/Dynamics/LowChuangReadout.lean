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

private theorem coordinate_iso (z : J) : IsIsometry (flagsZero (I:=I) z) := by
  have lift {X : Type} [Fintype X] [DecidableEq X] {M : Matrix X I ℂ} (h : IsIsometry M) :
      IsIsometry (coordinatePhaseFrame M) := by
    have l : (encodingFiber (I:=X) false)ᴴ * encodingFiber (I:=X) false = 1 := encodingFiber_isIsometry (I:=X) false
    unfold coordinatePhaseFrame IsIsometry
    rw [Matrix.conjTranspose_mul,Matrix.mul_assoc,← Matrix.mul_assoc (encodingFiber _)ᴴ,l,Matrix.one_mul]
    exact h
  exact lift (lift (encodingFiber_isIsometry z))

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
  let a := Nat.clog 2 (Fintype.card J)
  let r := Nat.clog 2 (Fintype.card I)
  let j := physicalBasis J
  let s := physicalBasis I
  let T := flagsHadamard (J:=Reg a) (I:=Reg r)
  obtain ⟨q,hq,program,prep,block,bound,fixed,work⟩ := finiteSimulation z two t ε positive small
  let wrapped := .fixed Tᴴ :: (program ++ [.fixed T])
  have gate : Elementary a r T := by
    rw [show T=onFlags (J:=Reg a) (I:=Reg r) (TensorGate Hadamard Hadamard) from localHadamards]
    exact Elementary.flags _ (tensorGate_unitary hadamard_unitary hadamard_unitary)
  have count (k : StandardOracle) : cost k wrapped = cost k program := by
    simp [wrapped,cost,cost_append]
  have eval (data : StandardOracle → Operator a r) : run data wrapped = Tᴴ * run data program * T := by
    simp [wrapped,run,matrix,run_append,Matrix.mul_assoc]
  refine ⟨q,hq,wrapped,(count _).trans prep,(count _).trans block,?_,?_,?_⟩
  · simp only [wrapped,fixedCount,fixed_append] at *
    omega
  · intro M mem
    rcases List.mem_cons.mp mem with e|h
    · cases e; exact .adj gate
    rcases List.mem_append.mp h with h|e
    · exact fixed _ h
    · cases List.mem_singleton.mp e; exact gate
  intro G U H hG hU hH
  dsimp only
  intro signal
  have ⟨err,prob⟩ := work G U H hG hU hH signal
  let data := standardInput (pad (coord j) G) (pad (coord (j.prodMap s)) U)
  have ⟨op,mass⟩ := coordinate_acts (j z) (run data program)
  change ‖compress _ (compress _ (run data wrapped) _) _ - _‖ ≤ _ ∧ _
  rw [eval,op]
  exact ⟨err,fun ψ hψ => by rw [mass]; exact prob ψ hψ⟩

end FQChemQatlib.Dynamics.LowChuang
