module

public import Mathlib.LinearAlgebra.Matrix.Permutation
public import FQChemQatlib.Dynamics.LowChuangGateWord
public import Qatlib.Concepts.BlockEncoding.StateBlockEncoding.FiberBridge
public import Qatlib.Concepts.QsvtCore.LinearSystems.FiniteInversePhaseProgram

/-! # Coordinate controls for the fixed signal-processing gates -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang

open Matrix Qatlib.Foundations.PureStateMath Qatlib.Concepts.BlockEncoding
open Qatlib.Concepts.BlockEncoding.EncodingCore Qatlib.Concepts.BlockEncoding.StateBlockEncoding
open Qatlib.Concepts.BlockEncoding.LCU Qatlib.Concepts.LocalMachine.LocalTransport
open Qatlib.Concepts.QsvtCore.LinearSystems Qatlib.Concepts.QspSimulation.Achievability
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.PhaseGeometry.Phase
open Qatlib.Concepts.CopyEvolution.Discriminate

variable {J I : Type} [Fintype J] [DecidableEq J] [Fintype I] [DecidableEq I]

abbrev Signals (J I : Type) := Bool × (Bool × (J × I))

/-- Toggle the inner flag precisely when the original ancilla has the specified
coordinate. The outer flag and every system wire are available as borrowed wires. -/
def testAncilla (zero : J) : Equiv.Perm (Signals J I) where
  toFun x := (x.1, if x.2.2.1=zero then !x.2.1 else x.2.1,x.2.2)
  invFun x := (x.1, if x.2.2.1=zero then !x.2.1 else x.2.1,x.2.2)
  left_inv x := by rcases x with ⟨b,c,j,i⟩; by_cases h : j=zero <;> simp [h]
  right_inv x := by rcases x with ⟨b,c,j,i⟩; by_cases h : j=zero <;> simp [h]

/-- This diagonal unitary depends only on the two Boolean coordinates. -/
def flagsPhase (z : ℂ) : Matrix (Signals J I) (Signals J I) ℂ :=
  diagonal (fun x => if x.1 then if x.2.1 then star z else z else 1)

/-- A phase about the fiber costs two tests of the ancilla and a single
two-qubit diagonal gate, independently of the phase angle. -/
theorem fiberPhase_sandwich (zero : J) (z : ℂ) :
    controlOracle (select fun b : Bool => phaseRotation
      (rangeProjector (encodingFiber (I := I) zero)) (conjugateParallelPhase z b)) =
    (testAncilla (I:=I) zero).permMatrix ℂ * flagsPhase z * (testAncilla zero).permMatrix ℂ := by
  rw [rangeProjector_encodingFiber]
  ext x y
  simp only [Equiv.Perm.permMatrix,PEquiv.mul_toMatrix_toPEquiv,PEquiv.toMatrix_toPEquiv_mul,
    Matrix.submatrix_apply,id_eq, flagsPhase, Matrix.diagonal_apply]
  change _ = if testAncilla zero x = testAncilla zero y then _ else _
  simp only [Equiv.apply_eq_iff_eq]
  rcases x with ⟨a,b,j,i⟩
  rcases y with ⟨a',b',j',i'⟩
  by_cases outer : a = a'
  · subst a'
    cases a
    · simp [controlOracle, select, Matrix.one_apply, testAncilla]
    · by_cases inner : b = b'
      · subst b'
        by_cases same : (j, i) = (j', i')
        · obtain ⟨rfl, rfl⟩ := Prod.mk.inj same
          cases b <;> by_cases selected : j = zero <;>
            simp [controlOracle, select, phaseRotation, fiberProjector_apply,
              Matrix.one_apply, conjugateParallelPhase, testAncilla, selected]
        · have off : ¬(j = j' ∧ i = i') := fun h => same (Prod.ext h.1 h.2)
          simp [controlOracle, select, phaseRotation, fiberProjector_apply, Matrix.one_apply, off]
      · simp [controlOracle, select, inner]
  · simp [controlOracle, select, outer]

/-- The globally phased double average has a real Hadamard on each of the two
flags. This matrix acts only on those flags. -/
def flagsHadamard : Matrix (Signals J I) (Signals J I) ℂ :=
  inverseLabelH * parallelOracle (J:=Bool) (inverseLabelH (H:=J × I))

/-- The coordinate frame fixes both flags to zero and the ancilla to its
designated basis vector. -/
def flagsZero (zero : J) : Matrix (Signals J I) I ℂ :=
  coordinatePhaseFrame (coordinatePhaseFrame (encodingFiber zero))

private theorem coordinate_parallel {X Y : Type} [Fintype X] [DecidableEq X] [Fintype Y] [DecidableEq Y]
    (A : Matrix X X ℂ) (F : Matrix X Y ℂ) :
    coordinatePhaseFrame (A * F) = parallelOracle (J:=Bool) A * coordinatePhaseFrame F := by
  ext ⟨b,x⟩ y
  cases b <;> simp [coordinatePhaseFrame_apply,Matrix.mul_apply,Fintype.sum_prod_type,parallelOracle,select]

private theorem coordinate_smul {X Y : Type} [Fintype X] [DecidableEq X] [Fintype Y] [DecidableEq Y]
    (a : ℂ) (F : Matrix X Y ℂ) : coordinatePhaseFrame (a • F)= a • coordinatePhaseFrame F := by
  ext ⟨b,x⟩ y
  cases b <;> simp [coordinatePhaseFrame_apply]

theorem hamiltonianFrame_coordinates (zero : J) :
    hamiltonianFrame (encodingFiber (I := I) zero) =
    (inverseLabelPhase * inverseLabelPhase) • (flagsHadamard * flagsZero zero) := by
  rw [hamiltonianFrame,averageFrame_labelH,averageFrame_labelH,coordinate_smul,coordinate_parallel,
    Matrix.mul_smul,smul_smul]
  simp only [flagsHadamard,flagsZero,Matrix.mul_assoc]

private theorem H_unit : flagsHadamard (I:=I) (J:=J) ∈ Matrix.unitaryGroup _ ℂ := by
  have oneH (X : Type) [Fintype X] [DecidableEq X] :
      inverseLabelH (H:=X) ∈ Matrix.unitaryGroup _ ℂ :=
    tensorGate_unitary hadamard_unitary (Submonoid.one_mem _)
  exact mul_mem (oneH _) (parallelOracle_unitary (oneH _))

theorem zero_projector (zero : J) : rangeProjector (flagsZero (I:=I) zero) =
    Matrix.diagonal (fun x : Signals J I => if x.1=false ∧ x.2.1=false ∧ x.2.2.1=zero then 1 else 0) := by
  ext ⟨a,b,j,i⟩ ⟨a',b',j',i'⟩
  simp [rangeProjector, Matrix.mul_apply, flagsZero, coordinatePhaseFrame_apply,
    encodingFiber, Matrix.conjTranspose_apply, Matrix.diagonal_apply, ite_and]
  split_ifs <;> simp_all

/-- The cubic gates reduce to two Hadamards on either side of a basis
reflection and a register-independent scalar. The test fixes the two signal
flags and the original ancilla. The system is a spectator. -/
theorem cubic_coordinate (zero : J) {z : ℂ} (phase : z=Complex.I ∨ z= -Complex.I) :
    phaseRotation (rangeProjector (hamiltonianFrame (encodingFiber (I:=I) zero))) z =
    flagsHadamard * (z • (2 • rangeProjector (flagsZero zero) - 1)) * flagsHadamardᴴ := by
  let H := flagsHadamard (J:=J) (I:=I)
  let P := rangeProjector (flagsZero (I:=I) zero)
  have hum : H * Hᴴ=1 := (Matrix.mem_unitaryGroup_iff).mp H_unit
  have norm : (inverseLabelPhase * inverseLabelPhase) * star (inverseLabelPhase * inverseLabelPhase) = 1 := by
    rw [star_mul]; calc
      _ = (star inverseLabelPhase * inverseLabelPhase)^2 := by ring
      _ = 1 := by rw [inverseLabelPhase_unit]; norm_num
  have eq : rangeProjector (hamiltonianFrame (encodingFiber (I:=I) zero)) = H*P*Hᴴ := by
    rw [hamiltonianFrame_coordinates,rangeProjector,Matrix.conjTranspose_smul,Matrix.smul_mul,
      Matrix.mul_smul,smul_smul,norm,one_smul,Matrix.conjTranspose_mul]
    simp only [H,P,rangeProjector,Matrix.mul_assoc]
  have conj : star z = -z := by rcases phase with rfl|rfl <;> simp
  rw [phaseRotation,eq,conj,Matrix.mul_smul,Matrix.smul_mul,Matrix.mul_sub,
    Matrix.sub_mul,Matrix.mul_smul,Matrix.smul_mul,Matrix.mul_one]
  change _ = z • (2 • (H*P*Hᴴ) - H*Hᴴ)
  rw [hum]
  module

end FQChemQatlib.Dynamics.LowChuang
