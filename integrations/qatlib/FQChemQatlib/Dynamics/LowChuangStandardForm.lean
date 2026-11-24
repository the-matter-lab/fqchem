module

public import FQChemQatlib.Dynamics.LowChuangQueries

/-! # Simulation from the original preparation and block oracles -/

@[expose] public section

namespace FQChemQatlib.Dynamics.LowChuang

open Matrix Query Qatlib.Foundations.PureStateMath Qatlib.Concepts.Execution.WorkspaceCP
open Qatlib.Concepts.BlockEncoding Qatlib.Concepts.BlockEncoding.EncodingCore
open Qatlib.Concepts.QspSimulation.Achievability Qatlib.Concepts.LocalMachine.LocalTransport
open Qatlib.Concepts.BlockEncoding.Postselection.Encoding Qatlib.Papers.Qubitization19.MainResults

open scoped Matrix.Norms.L2Operator

inductive StandardOracle where | prepare | block deriving DecidableEq

variable {J I : Type} [Fintype J] [DecidableEq J] [Fintype I] [DecidableEq I]

/-- The two independent oracles. Only the block oracle needs a signal control.
The prepared-state basis change touches only the original ancilla register. -/
noncomputable def standardInput (G : Matrix J J ℂ) (U : Matrix (J × I) (J × I) ℂ) :
    StandardOracle → Matrix (Bool × (Bool × (J × I))) (Bool × (Bool × (J × I))) ℂ
  | .prepare => broadcast (TensorGate G (1 : Matrix I I ℂ))
  | .block => lifted U

/-- A single uniform word for arbitrary standard-form input oracles G and U
on the original Hilbert spaces. Q is the least factorial cutoff in Theorem 1.
The fixed-gate ledger counts matrix instructions. -/
theorem standardFormProgram (zero : J) (t ε : ℝ) (positive : 0<ε) (small : ε<1) :
    ∃ q : ℕ, IsPaperCutoffQ t ε q ∧
    ∃ program : List (Step (Bool × (Bool × (J × I))) StandardOracle),
      cost StandardOracle.prepare program = 54*(64*q+1) ∧
      cost StandardOracle.block program = 27*(64*q+1) ∧
      fixedCount program = 27*(64*q+8)-2 ∧
      (∀ M, .fixed M ∈ program → FrameGate (encodingFiber (I := I) zero) M) ∧
      Fintype.card (Bool × (Bool × (J × I))) = 4*Fintype.card J*Fintype.card I ∧
      ∀ (G : Matrix J J ℂ) (U : Matrix (J × I) (J × I) ℂ) (H : Matrix I I ℂ),
        G ∈ Matrix.unitaryGroup J ℂ → U ∈ Matrix.unitaryGroup _ ℂ → H.IsHermitian →
        let F := encodingFiber (I := I) zero
        let prepared := TensorGate G (1 : Matrix I I ℂ) * F
        compress prepared U prepared = H →
        let M := run (standardInput G U) program
        let R := hamiltonianFrame F
        ‖compress R M R - hamiltonianEvolution H t‖ ≤ ε^2/2 ∧
        ∀ ψ : QState I, Normalized ψ → 1-ε^2 ≤ postselectionProbability M R R ψ := by
  let F := encodingFiber (I := I) zero
  have hf := encodingFiber_isIsometry (I := I) zero
  obtain ⟨q,cut,word,_,cover,queries,gates,corr⟩ := uniformCutoffWord F hf t ε positive small
  let body : List (Step (Bool × (Bool × (J × I))) StandardOracle) :=
    [.query .prepare true,.query .block false,.query .prepare false]
  refine ⟨q,cut,substitute body word,?_,?_,?_,?_,?_,?_⟩
  · rw [cost_substitute,queries]; change 2*(27*(64*q+1))=_; omega
  · rw [cost_substitute,queries]; change 1*(27*(64*q+1))=_; simp
  · rw [fixed_substitute,gates]; change _+0*_= _; simp
  · apply covers_substitute cover
    · simp [body]
    · simp [body,inverse,adjoint]
  · simp [Fintype.card_prod]; ring
  intro G U H unitG unitU hermitian
  dsimp only
  intro signal
  let P := TensorGate G (1 : Matrix I I ℂ)
  have unitP := tensorGate_unitary unitG (Submonoid.one_mem (Matrix.unitaryGroup I ℂ))
  have core : ProjectedUnitaryEncoding H (Pᴴ*U*P) F F := by
    refine ⟨mul_mem (mul_mem (Unitary.star_mem unitP) unitU) unitP,hf,hf,?_⟩
    simpa only [compress,Matrix.conjTranspose_mul,Matrix.mul_assoc,F,P] using signal
  obtain ⟨err,_,born⟩ := corr H _ hermitian core
  have eq : run (standardInput G U) body = lifted (Pᴴ*U*P) := by
    rw [lift_conjugate P U unitP]
    simp [body,run,matrix,standardInput,P,Matrix.mul_assoc]
  simpa only [run_substitute,eq,F] using And.intro err born

end FQChemQatlib.Dynamics.LowChuang
