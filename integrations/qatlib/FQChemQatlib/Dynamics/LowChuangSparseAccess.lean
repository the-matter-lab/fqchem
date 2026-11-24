module

public import FQChemQatlib.Dynamics.LowChuangSparseCartesian
public import FQChemQatlib.Dynamics.LowChuangSparseCutoff

/-! # Replacing controlled sparse block queries by ordinary input queries -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseBlock

open Query
open Sparse (Access)
open Matrix Qatlib.Foundations.PureStateMath Qatlib.Concepts.BlockEncoding.LCU
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.BlockEncoding
open Qatlib.Concepts.BlockEncoding.EncodingCore Qatlib.Concepts.BlockEncoding.Encoding
open Qatlib.Concepts.CopyEvolution.Discriminate Qatlib.Concepts.LocalMachine.LocalTransport
open Qatlib.Concepts.QspSimulation.Achievability Qatlib.Concepts.CoherentSim.CoherentOAA
open Qatlib.Concepts.BlockEncoding.Postselection.Encoding Qatlib.Papers.Qubitization19.MainResults
open FQChemQatlib.Dynamics.LowChuang.Binary
open scoped Classical Matrix.Norms.L2Operator

variable {I B : Type} [Fintype I] [DecidableEq I] [Fintype B] [DecidableEq B]

abbrev Host (I B : Type) := Bool × (Bool × Work I B)

def body (S : Matrix I I ℂ) (V : Matrix B B ℂ) : List (Step (Host I B) Access) :=
  [.fixed (broadcast (slotGate (B:=B) S))ᴴ, .query .position true,
   .fixed (lifted (permMatrix (exchange (I:=I) (B:=B)))), .query .entry true,
   .fixed (lifted (decoderGate (I:=I) V)), .query .entry false, .query .position false,
   .fixed (broadcast (slotGate (B:=B) S))]

def inputs (pos : I → Equiv.Perm I) (lookup : I → I → Equiv.Perm B) :
    Access → Matrix (Host I B) (Host I B) ℂ
  | .position => broadcast (permMatrix (position pos))
  | .entry => broadcast (permMatrix (entry lookup))

/-- The controlled block requires two position calls and two value calls.
All four are ordinary access, with both flags untouched. -/
theorem body_spec (S : Matrix I I ℂ) (hs : S∈Matrix.unitaryGroup _ ℂ) (V : Matrix B B ℂ)
    (pos : I → Equiv.Perm I) (lookup : I → I → Equiv.Perm B) :
    cost Access.position (body S V)=2 ∧ cost Access.entry (body S V)=2 ∧
    run (inputs pos lookup) (body S V) = lifted (oracle S pos lookup V) := by
  let P := prepared (B:=B) S pos
  let X := permMatrix (entry lookup)
  have perm (f : Equiv.Perm (Work I B)) : permMatrix f ∈ Matrix.unitaryGroup _ ℂ :=
    Qatlib.Concepts.HspRecovery.RecordExtract.permMatrix_unitary_of_injective f.injective
  have pu : P ∈ Matrix.unitaryGroup _ ℂ := mul_mem (perm _) (parallelOracle_unitary (tensorGate_unitary hs (Submonoid.one_mem _)))
  have xu : X ∈ Matrix.unitaryGroup _ ℂ := perm _
  have fac : oracle S pos lookup V = Pᴴ * (permMatrix (exchange (I:=I) (B:=B)) * (Xᴴ * decoderGate V * X)) * P := by
    simp only [oracle,P,X,Matrix.mul_assoc]
  refine ⟨rfl,rfl,?_⟩
  rw [fac,lift_conjugate P _ pu,lift_mul,lift_conjugate X _ xu]
  simp only [P,X,prepared,broadcast_mul,Matrix.conjTranspose_mul,body,inputs,run,matrix,Matrix.mul_one,Matrix.mul_assoc]

end FQChemQatlib.Dynamics.LowChuang.SparseBlock
