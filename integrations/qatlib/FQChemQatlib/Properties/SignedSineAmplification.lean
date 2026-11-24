module

public import FQChemQatlib.Properties.SignedSineUncompute
public import Qatlib.Concepts.HhlAlgorithms.Postselection.RationalHHLNoiseConsumers
import Mathlib.Tactic

/-! # Unknown-success amplification for the signed inverse state

The unitary acts on an input basis label, a sine clock, and a three-level flag.
In spectral coordinates its preparations, rotations and uncomputations form
one unitary matrix. Randomized Grover depth depends only on the promised
spectral gap. Every successful depth preserves the solution ray. -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Properties.SignedSineClock
open Matrix
open Qatlib.Foundations.PureStateMath Qatlib.Foundations.PureStateMath.BornBridge
open Qatlib.Foundations.QueryWordCore.Circuit
open Qatlib.Foundations.InstrumentCore.Measurement
open Qatlib.Concepts.HhlAlgorithms.SinEnvProgram
open Qatlib.Concepts.HhlAlgorithms.SinEnvProgram.SinEnvelopeHHLConsumers
open Qatlib.Concepts.HhlAlgorithms.SinEnvFilter.SinEnvelopeHHL
open Qatlib.Concepts.HhlAlgorithms.Postselection
open Qatlib.Concepts.HhlAlgorithms.Postselection.HHLUnknown
open Qatlib.Concepts.QueryComplexity.DegreeMethod
open Qatlib.Concepts.LchsSimulation.StaticLchs
variable {I : Type} [Fintype I] [DecidableEq I]
abbrev Work (I : Type) (M : ℕ) := (I × Fin M) × Fin 3

def spectralClock (M : ℕ) (hM : 2≤M) (eig : I → ℝ) :=
  BlockDiag fun i => forwardClock M hM (eig i)

def inverseClock (M : ℕ) (hM : 2≤M) (eig : I → ℝ) :=
  BlockDiag fun i => (forwardClock M hM (eig i))ᴴ

def flagRotations (M : ℕ) (d : ℝ) : Matrix (Work I M) (Work I M) ℂ :=
  BlockDiag fun p => canonicalSignedProgram.rotation d (sinEnvelopeDecode M p.2)

def solver (M : ℕ) (hM : 2≤M) (eig : I → ℝ) (d : ℝ) (B : Matrix I I ℂ) :
    Matrix (Work I M) (Work I M) ℂ :=
  TensorGate (inverseClock M hM eig) 1 * flagRotations M d *
    TensorGate (spectralClock M hM eig) 1 * TensorGate (TensorGate B (1 : Matrix (Fin M) _ ℂ)) 1

def start (M : ℕ) (hM : 2≤M) (j : I) : Work I M := ((j,⟨0,by omega⟩),0)

def selected (I : Type) [Fintype I] (M : ℕ) : Finset (Work I M) :=
  Finset.univ.map ⟨fun p : I × Fin M => (p,1),fun _ _ eq => congrArg Prod.fst eq⟩

theorem solverUnitary (M : ℕ) (hM : 2≤M) (eig : I → ℝ) (d : ℝ) (hd : 0<d)
    (B : Matrix I I ℂ) (hB : B ∈ unitaryGroup _ ℂ) :
    solver M hM eig d B ∈ unitaryGroup _ ℂ := by
  have unit := clockUnitary M hM
  exact (unitaryGroup _ ℂ).mul_mem ((unitaryGroup _ ℂ).mul_mem ((unitaryGroup _ ℂ).mul_mem
    (tensorGate_unitary (blockDiag_unitary _ (fun i => Unitary.star_mem (unit (eig i)))) (Submonoid.one_mem _))
    (blockDiag_unitary _ fun p => (canonicalSignedProgram_rotation d (sinEnvelopeDecode M p.2) hd).1))
    (tensorGate_unitary (blockDiag_unitary _ (fun i => unit (eig i))) (Submonoid.one_mem _)))
    (tensorGate_unitary (tensorGate_unitary hB (Submonoid.one_mem _)) (Submonoid.one_mem _))

theorem blockSlice {J K : Type} [Fintype J] [DecidableEq J] [Fintype K] [DecidableEq K]
    (U : J → Matrix K K ℂ) (ψ : J × K → ℂ) (i : J) (j : K) :
    (BlockDiag U *ᵥ ψ) (i,j) = (U i *ᵥ fun k => ψ (i,k)) j := by
  simp only [mulVec,dotProduct,Fintype.sum_prod_type,BlockDiag,of_apply,ite_mul,zero_mul,
    Finset.sum_ite_irrel,Finset.sum_const_zero,Finset.sum_ite_eq,Finset.mem_univ,ite_true]

theorem tensorSlice {J K : Type} [Fintype J] [DecidableEq J] [Fintype K] [DecidableEq K]
    (U : Matrix J J ℂ) (ψ : J × K → ℂ) (i : J) (j : K) :
    (TensorGate U 1 *ᵥ ψ) (i,j) = (U *ᵥ fun k => ψ (k,j)) i := by
  simp [mulVec,dotProduct,Fintype.sum_prod_type,tensorGate_apply,one_apply,mul_ite,ite_mul]

/-- The success amplitudes of the unitary, including the input preparation,
equal those of the uncomputed signed sine-clock solution. -/
theorem solverOutput (M : ℕ) (hM : 2≤M) (eig : I → ℝ) (d : ℝ) (B : Matrix I I ℂ) (j : I) :
    (fun p => preparedAAState (solver M hM eig d B) (start M hM j) (p,1)) =
    WithLp.ofLp (undoClock M hM eig (successBranch M d eig (B *ᵥ Ket j))) := by
  let z₀ : Fin M := ⟨0,by omega⟩
  let b := B *ᵥ Ket j
  let init := TensorGate (TensorGate B (1 : Matrix (Fin M) _ ℂ)) (1 : Matrix (Fin 3) _ ℂ)
  have first (p : Work I M) : (init *ᵥ Ket (start M hM j)) p = b p.1.1 * Ket z₀ p.1.2 * Ket 0 p.2 := by
    rcases p with ⟨⟨i,z⟩,g⟩
    have ketColumn {L : Type} [Fintype L] [DecidableEq L] (C : Matrix L L ℂ) (x y : L) :
        (C *ᵥ Qatlib.Foundations.PureStateMath.Ket x) y = C y x := by
      simp [Matrix.mulVec, dotProduct, Qatlib.Foundations.PureStateMath.Ket, mul_ite]
    simp only [init, start, b, ketColumn, tensorGate_apply, Matrix.one_apply,
      Qatlib.Foundations.PureStateMath.Ket, z₀]
  let phase := TensorGate (spectralClock M hM eig) (1 : Matrix (Fin 3) _ ℂ)
  have mid (p : Work I M) : (phase *ᵥ (init *ᵥ Ket (start M hM j))) p =
      b p.1.1 * sinEnvelopeKernel M (eig p.1.1) p.1.2 * Ket 0 p.2 := by
    rcases p with ⟨⟨i,z⟩,g⟩
    rw [tensorSlice, spectralClock, blockSlice]
    have col : (fun k => (init *ᵥ Ket (start M hM j)) ((i,k),g)) = (b i * Ket 0 g) • Ket z₀ := by
      funext k; rw [first]; dsimp; ring
    rw [col,mulVec_smul,forwardKernel]; dsimp; ring
  have flag (p : I × Fin M) :
      (flagRotations M d *ᵥ (phase *ᵥ (init *ᵥ Ket (start M hM j)))) (p,1) =
        successBranch M d eig b p := by
    rw [flagRotations,blockSlice]
    have col : (fun g => (phase *ᵥ (init *ᵥ Ket (start M hM j))) (p,g)) =
        (b p.1 * sinEnvelopeKernel M (eig p.1) p.2) • Ket (0:Fin 3) := by funext g; exact mid _
    rw [col,mulVec_smul]
    rfl
  funext p
  change ((TensorGate (inverseClock M hM eig) 1 * flagRotations M d * phase * init) *ᵥ _) (p,1) = _
  simp only [← mulVec_mulVec, tensorSlice, flag]
  rfl

theorem solverMass (M : ℕ) (hM : 2≤M) (eig : I → ℝ) (d : ℝ) (B : Matrix I I ℂ) (j : I) :
    MeasureProb (preparedAAState (solver M hM eig d B) (start M hM j)) (selected I M) =
      ‖undoClock M hM eig (successBranch M d eig (B *ᵥ Ket j))‖^2 := by
  rw [EuclideanSpace.norm_sq_eq, MeasureProb, selected, Finset.sum_map]
  apply Finset.sum_congr rfl
  intro p _
  exact congrArg (fun c : ℂ => ‖c‖^2) (congrFun (solverOutput M hM eig d B j) p)

/-- Sample a Grover depth from the doubled window of size ceil(1/(2d)).
One attempt succeeds with probability at least 1/8. Its exact word makes at
most twice the window size calls to the solver or its inverse, and every
successful depth has the same conditional output up to global phase. -/
theorem amplifiedSignedSolution (M : ℕ) (hM : 2≤M) (eig : I → ℝ) (d : ℝ) (hd : 0<d)
    (B : Matrix I I ℂ) (hB : B ∈ unitaryGroup _ ℂ) (j : I)
    (spectrum : ∀ i, 4*d ≤ |eig i| ∧ |eig i| ≤ 1/4) (budget : 160≤d*M) :
    let m := ⌈1/(2*d)⌉₊
    let A := solver M hM eig d B
    let j₀ := start M hM j
    let S := selected I M
    let run := fun s : Fin (2*m) => Run (preparedMark S) (preparedAACircuit A j₀ (depth m s)) (Ket j₀)
    (1/8 : ℝ) ≤ (∑ s, MeasureProb (run s) S)/(2*m) ∧
      ∀ s, preparedInputQueries (preparedAAWord j₀ (depth m s)) ≤ 2*m ∧
        (0 < MeasureProb (run s) S → ∃ z : ℂ, ‖z‖=1 ∧
          PostMeasure (run s) S = z • PostMeasure (preparedAAState A j₀) S) := by
  let m := ⌈1/(2*d)⌉₊
  have hp : 0 < 2*d := by positivity
  have hm : 0<m := Nat.ceil_pos.mpr (one_div_pos.mpr hp)
  have win : 1 ≤ (m:ℝ)*(2*d) := (div_le_iff₀ hp).mp (Nat.le_ceil _)
  have Aunit := solverUnitary M hM eig d hd B hB
  have prob : (2*d)^2 ≤ MeasureProb (preparedAAState (solver M hM eig d B) (start M hM j)) (selected I M) := by
    rw [solverMass]
    have hb := normalized_applyGate hB (normalized_ket j)
    have lo := (signedSolution M hM d eig (B *ᵥ Ket j) hd hb spectrum budget).1
    nlinarith
  refine ⟨Probe.mixed_window_avg _ _ _ m _ Aunit hm hp prob win,fun s => ⟨?_,?_⟩⟩
  · rw [(prepared_aa_separate_access_word (solver M hM eig d B) (start M hM j) (selected I M)
      (depth m s) Aunit).2.2.1]
    have lt := s.isLt
    unfold depth
    split <;> omega
  · exact Probe.amplified_postMeasure_phase _ _ _ _ Aunit

end FQChemQatlib.Properties.SignedSineClock
