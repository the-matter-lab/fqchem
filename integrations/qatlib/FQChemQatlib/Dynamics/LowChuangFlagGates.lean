module

public import FQChemQatlib.Dynamics.LowChuangReflections

/-! # Two-qubit gates on the signal flags and the selective sign change -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang

open Matrix Qatlib.Foundations.PureStateMath Qatlib.Concepts.BlockEncoding.LCU
open Qatlib.Concepts.CopyEvolution.Discriminate Qatlib.Concepts.QsvtCore.LinearSystems
open Qatlib.Concepts.LocalMachine.LocalTransport Qatlib.Concepts.QspSimulation.Achievability
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.PhaseGeometry.Phase

variable {J I : Type} [Fintype J] [DecidableEq J] [Fintype I] [DecidableEq I]
abbrev Flags := Bool × Bool

def regroup : (J × I) × Flags ≃ Signals J I where
  toFun x := (x.2.1,x.2.2,x.1)
  invFun x := (x.2.2,x.1,x.2.1)
  left_inv _ := rfl
  right_inv _ := rfl

def onBlocks (f : J × I → Matrix Flags Flags ℂ) : Matrix (Signals J I) (Signals J I) ℂ :=
  Matrix.reindexAlgEquiv ℂ ℂ regroup (select f)

def onFlags (A : Matrix Flags Flags ℂ) : Matrix (Signals J I) (Signals J I) ℂ :=
  onBlocks fun _ => A

theorem onBlocks_apply (f : J × I → Matrix Flags Flags ℂ) (x y : Signals J I) :
    onBlocks f x y = if x.2.2 = y.2.2 then f x.2.2 (x.1,x.2.1) (y.1,y.2.1) else 0 := by
  rfl

private theorem blocks_mul (f g : J × I → Matrix Flags Flags ℂ) :
    onBlocks f * onBlocks g = onBlocks (fun w => f w * g w) := by
  rw [onBlocks,onBlocks,onBlocks,← map_mul,parallel_select_mul]

private theorem blocks_star (f : J × I → Matrix Flags Flags ℂ) :
    (onBlocks f)ᴴ = onBlocks (fun w => (f w)ᴴ) := by
  change (Matrix.reindex _ _ _)ᴴ = Matrix.reindex _ _ _
  rw [Matrix.conjTranspose_reindex,parallel_select_adjoint]

theorem onFlags_unit {V : Matrix Flags Flags ℂ} (h : V ∈ Matrix.unitaryGroup Flags ℂ) :
    onFlags (J:=J) (I:=I) V ∈ Matrix.unitaryGroup _ ℂ := by
  rw [Matrix.mem_unitaryGroup_iff',Matrix.star_eq_conjTranspose,onFlags,blocks_star,blocks_mul]
  have u : Vᴴ * V = 1 := (Matrix.mem_unitaryGroup_iff').mp h
  rw [u]
  rw [onBlocks,parallel_select_one,map_one]

/-- Apply the ordinary two-qubit gate only on the selected ancilla coordinate. -/
def onAncilla (zero : J) (V : Matrix Flags Flags ℂ) : Matrix (Signals J I) (Signals J I) ℂ :=
  onBlocks fun w => if w.1=zero then V else 1

private theorem flags_conjugate (zero : J) {V : Matrix Flags Flags ℂ} (hv : V ∈ Matrix.unitaryGroup _ ℂ)
    (T : Matrix Flags Flags ℂ) : onFlags V * onAncilla (I:=I) zero T * (onFlags V)ᴴ =
    onAncilla zero (V*T*Vᴴ) := by
  simp only [onFlags,onAncilla,blocks_mul,blocks_star]
  congr 1
  funext w
  split <;> simp_all
  exact (Matrix.mem_unitaryGroup_iff).mp hv

/-- Flip the outer signal when the inner signal is one and the original
ancilla is at its designated coordinate. -/
def testBoth (zero : J) : Equiv.Perm (Signals J I) where
  toFun x := (if x.2.1=true ∧ x.2.2.1=zero then !x.1 else x.1,x.2)
  invFun x := (if x.2.1=true ∧ x.2.2.1=zero then !x.1 else x.1,x.2)
  left_inv x := by by_cases h : x.2.1=true ∧ x.2.2.1=zero <;> simp [h]
  right_inv x := by by_cases h : x.2.1=true ∧ x.2.2.1=zero <;> simp [h]

def pairCnot : Matrix Flags Flags ℂ := Qatlib.Foundations.PureStateMath.permMatrix
  fun x => (x.1 ^^ x.2,x.2)

/-- Change from the negative-eigenvalue CNOT flag state to the zero flag
coordinate, using a fixed unitary on the two flags. -/
def cnotBasis : Matrix Flags Flags ℂ := TensorGate (PauliX * Hadamard) PauliX

theorem cnotBasis_unit : cnotBasis ∈ Matrix.unitaryGroup Flags ℂ :=
  tensorGate_unitary (mul_mem pauliX_unitary hadamard_unitary) pauliX_unitary

private theorem cnot_basis_marker : cnotBasis * pairCnot * cnotBasisᴴ =
    Matrix.diagonal (fun b : Flags => if b=(false,false) then -1 else 1) := by
  have hs : (Real.sqrt 2 : ℂ)^2=2 := by exact_mod_cast Real.sq_sqrt (by norm_num : (0:ℝ)≤2)
  have hn : (Real.sqrt 2 : ℂ) ≠ 0 := by exact_mod_cast (Real.sqrt_pos.mpr (by norm_num : (0:ℝ)<2)).ne'
  ext ⟨a,b⟩ ⟨c,d⟩
  cases a <;> cases b <;> cases c <;> cases d <;>
    simp [cnotBasis,pairCnot,tensorGate_apply,PauliX,Qatlib.Foundations.PureStateMath.permMatrix,
      Hadamard,Matrix.mul_apply,Fintype.sum_prod_type,Matrix.conjTranspose_apply] <;> field_simp <;> first | linear_combination hs | linear_combination -hs

theorem conditionalCnot (zero : J) :
    (testBoth (I:=I) zero).permMatrix ℂ = onAncilla zero pairCnot := by
  ext ⟨a,b,j,i⟩ ⟨c,d,k,l⟩
  by_cases ej : j=k <;> by_cases ei : i=l <;> by_cases h : j=zero <;>
    cases a <;> cases b <;> cases c <;> cases d <;>
    simp_all [Equiv.Perm.permMatrix,PEquiv.toMatrix_apply,onAncilla,onBlocks_apply,
      testBoth,pairCnot,Qatlib.Foundations.PureStateMath.permMatrix]

theorem cubic_mark (zero : J) :
    2 • rangeProjector (flagsZero (I:=I) zero) - (1 : Matrix (Signals J I) (Signals J I) ℂ) =
    -(onFlags (J:=J) (I:=I) cnotBasis * (testBoth (I:=I) zero).permMatrix ℂ * (onFlags cnotBasis)ᴴ) := by
  rw [conditionalCnot,flags_conjugate zero cnotBasis_unit,cnot_basis_marker,zero_projector,two_nsmul]
  ext ⟨a,b,j,i⟩ ⟨c,d,k,l⟩
  simp only [Matrix.sub_apply,Matrix.add_apply,Matrix.neg_apply,Matrix.one_apply,Matrix.diagonal_apply]
  by_cases ej : j=k <;> by_cases ei : i=l <;> by_cases h : j=zero <;>
    cases a <;> cases b <;> cases c <;> cases d <;>
    simp_all [onAncilla,onBlocks_apply]

private theorem diagonal_flags (f : Flags → ℂ) : onFlags (J:=J) (I:=I) (diagonal f) =
    diagonal (fun x : Signals J I => f (x.1,x.2.1)) := by
  ext ⟨a,b,r⟩ ⟨c,d,s⟩
  by_cases h : r=s <;> simp [onFlags,onBlocks_apply,Matrix.diagonal_apply,h]

def pairPhase (z : ℂ) : Matrix Flags Flags ℂ := diagonal fun b =>
  if b.1 then if b.2 then star z else z else 1

theorem localPhase (z : ℂ) (hz : IsPhase z) :
    pairPhase z ∈ Matrix.unitaryGroup Flags ℂ ∧ flagsPhase (J:=J) (I:=I) z = onFlags (pairPhase z) := by
  refine ⟨?_,by rw [pairPhase,diagonal_flags]; rfl⟩
  rw [Matrix.mem_unitaryGroup_iff',Matrix.star_eq_conjTranspose,pairPhase,
    Matrix.diagonal_conjTranspose,Matrix.diagonal_mul_diagonal]
  ext ⟨a,b⟩ ⟨c,d⟩
  change (starRingEnd ℂ) z * z = 1 at hz
  cases a <;> cases b <;> cases c <;> cases d <;> simp [hz,mul_comm z]

theorem flagsTensor (A B : Matrix Bool Bool ℂ) : onFlags (J:=J) (I:=I) (TensorGate A B) =
    TensorGate A (TensorGate B (1 : Matrix (J × I) _ ℂ)) := by
  ext ⟨a,b,r⟩ ⟨c,d,s⟩
  by_cases h : r=s <;> simp [onFlags,onBlocks_apply,tensorGate_apply,h]

private theorem parallel_tensor {X : Type} [Fintype X] [DecidableEq X] (A : Matrix X X ℂ) :
    parallelOracle (J:=Bool) A = TensorGate (1 : Matrix Bool Bool ℂ) A := by
  ext ⟨b,i⟩ ⟨c,j⟩
  by_cases h : b=c <;> simp [parallelOracle,select,tensorGate_apply,h]

theorem localHadamards : flagsHadamard (J:=J) (I:=I) = onFlags (TensorGate Hadamard Hadamard) := by
  rw [flagsHadamard,parallel_tensor,inverseLabelH,inverseLabelH,flagsTensor,tensorGate_mul,
    Matrix.mul_one,Matrix.one_mul]

theorem localFlip : controlFlip (H:=Bool × (J × I)) = onFlags (TensorGate PauliX (1:Matrix Bool Bool ℂ)) := by
  rw [flagsTensor,tensorGate_one]
  ext ⟨a,i⟩ ⟨b,j⟩
  by_cases h : a= !b <;> simp [controlFlip,tensorGate_apply,PauliX,
    Qatlib.Foundations.PureStateMath.permMatrix,h]

theorem localScalar : controlOracle ((-Complex.I) • (1 : Matrix (Bool × (J × I)) _ ℂ)) =
    onFlags (J:=J) (I:=I) (diagonal (fun b : Flags => if b.1 then -Complex.I else 1)) := by
  rw [diagonal_flags]
  ext ⟨a,b,r⟩ ⟨c,d,s⟩
  cases a <;> cases c <;> by_cases hb : b=d <;> by_cases hr : r=s <;>
    simp [controlOracle,select,hb,hr]

end FQChemQatlib.Dynamics.LowChuang
