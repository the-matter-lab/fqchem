module

public import FQChemQatlib.Dynamics.LowChuangQueries
public import Qatlib.Concepts.QsvtCore.PhaseExistence.SparseAccessConstruction
public import Qatlib.Concepts.HspRecovery.RecordExtract.ExecutionSemantics

/-! # Standard form from sparse position and binary-entry oracles

A row permutation extends the in-place position oracle on the d designated
slots. A reversible XOR lookup returns the m-bit encoding of each matrix
entry. Its inverse cleans the value register after an input-independent
rotation selected by the decoded value. -/

@[expose] public section

namespace FQChemQatlib.Dynamics.LowChuang.Sparse

open FQChemQatlib.Dynamics.LowChuang.Query
open Qatlib.Concepts.LocalMachine.LocalTransport Qatlib.Concepts.CopyEvolution.Discriminate
open Qatlib.Concepts.QspSimulation.Achievability Qatlib.Concepts.CoherentSim.CoherentOAA
open Qatlib.Concepts.BlockEncoding.Postselection.Encoding Qatlib.Papers.Qubitization19.MainResults
open Matrix Qatlib.Foundations.PureStateMath Qatlib.Concepts.Execution.WorkspaceCP
open Qatlib.Concepts.BlockEncoding Qatlib.Concepts.BlockEncoding.EncodingCore
open Qatlib.Concepts.BlockEncoding.Encoding Qatlib.Concepts.BlockEncoding.LCU
open Qatlib.Concepts.QsvtCore.PhaseExistence Qatlib.Concepts.LocalMachine.LocalTransport
open scoped Classical Matrix.Norms.L2Operator

variable {I : Type} [Fintype I] [DecidableEq I] {m : ℕ}

scoped instance bitWordFintype (n : ℕ) : Fintype (BitVec n) :=
  Fintype.ofEquiv (Fin (2^n)) ⟨BitVec.ofFin,BitVec.toFin,fun _ => rfl,fun _ => rfl⟩

abbrev Work (I : Type) (m : ℕ) := I × I × BitVec m × Bool

def signalFrame (zero : I) : Matrix (Work I m) I ℂ :=
  fun w j => if w = (j,zero,0,false) then 1 else 0

private theorem frame_iso (zero : I) : IsIsometry (signalFrame (m := m) zero) := by
  ext i j
  simp [signalFrame,Matrix.mul_apply,Matrix.conjTranspose_apply,Matrix.one_apply,eq_comm]

/-- Amplitude of a uniform superposition over the available sparse slots. -/
noncomputable def slotAmplitude (slots : Finset I) (i : I) : ℝ :=
  if i ∈ slots then (Real.sqrt slots.card)⁻¹ else 0

private theorem slot_norm (slots : Finset I) (hd : 0 < slots.card) :
    ∑ i, (slotAmplitude slots i)^2 = 1 := by
  simp only [slotAmplitude,ite_pow,ne_eq,OfNat.ofNat_ne_zero,not_false_eq_true,zero_pow]
  rw [← Finset.sum_filter]
  simp [inv_pow,Real.sq_sqrt (by positivity : (0:ℝ)≤slots.card),ne_of_gt hd]

noncomputable def uniformOp (slots : Finset I) (zero : I) : Matrix (Work I m) (Work I m) ℂ :=
  select fun _ => TensorGate (nonnegativePrepare (slotAmplitude slots) zero)
    (1 : Matrix (BitVec m × Bool) (BitVec m × Bool) ℂ)

def position (pos : I → Equiv.Perm I) : Equiv.Perm (Work I m) where
  toFun w := (w.1,pos w.1 w.2.1,w.2.2)
  invFun w := (w.1,(pos w.1).symm w.2.1,w.2.2)
  left_inv w := by simp
  right_inv w := by simp

/-- The entry table is queried with (column,row) ordering to prepare the
right column of the desired matrix. Its output is a genuine reversible
exclusive-or on an arbitrary answer register. -/
def lookup (code : I → I → BitVec m) : Equiv.Perm (Work I m) where
  toFun w := (w.1,w.2.1,w.2.2.1 ^^^ code w.2.1 w.1,w.2.2.2)
  invFun w := (w.1,w.2.1,w.2.2.1 ^^^ code w.2.1 w.1,w.2.2.2)
  left_inv w := by simp [BitVec.xor_assoc]
  right_inv w := by simp [BitVec.xor_assoc]

def swap : Equiv.Perm (Work I m) where
  toFun w := (w.2.1,w.1,w.2.2)
  invFun w := (w.2.1,w.1,w.2.2)
  left_inv _ := rfl
  right_inv _ := rfl

private theorem permutation_action {J K : Type} [Fintype J] [DecidableEq J]
    (e : Equiv.Perm J) (A : Matrix J K ℂ) (w : J) (j : K) :
    (permMatrix e * A) w j = A (e.symm w) j := by
  simp only [Matrix.mul_apply,permMatrix,Matrix.of_apply,ite_mul,one_mul,zero_mul,
    show ∀ x, w=e x ↔ x=e.symm w from fun x => by simp [eq_comm,e.eq_symm_apply]]
  simp

/-- Fixed unitary depending on the public binary decoding convention. -/
noncomputable def rotation (decode : BitVec m → ℂ) : Matrix (Work I m) (Work I m) ℂ :=
  select fun _ => select fun _ => select fun z => ampGate (decode z)

private theorem rot_unit (a : ℂ) (ha : ‖a‖ ≤ 1) : ampGate a ∈ Matrix.unitaryGroup Bool ℂ := by
  have hs := Real.sq_sqrt (show 0 ≤ 1-‖a‖^2 by nlinarith [norm_nonneg a])
  have hs' : ((Real.sqrt (1-‖a‖^2) : ℝ) : ℂ)^2 = 1 - (‖a‖:ℂ)^2 := by exact_mod_cast hs
  have abs2 : star a*a = (‖a‖:ℂ)^2 := by
    rw [Complex.star_def,← Complex.normSq_eq_conj_mul_self,Complex.normSq_eq_norm_sq]; norm_cast
  rw [Matrix.mem_unitaryGroup_iff',Matrix.star_eq_conjTranspose]
  ext i j
  change (starRingEnd ℂ) a*a = (‖a‖:ℂ)^2 at abs2
  cases i <;> cases j <;> simp [Matrix.mul_apply,ampGate]
  all_goals ring_nf
  all_goals rw [hs']
  all_goals linear_combination abs2

private theorem uniform_unit (slots : Finset I) (zero : I) (hd : 0 < slots.card) :
    uniformOp (m := m) slots zero ∈ Matrix.unitaryGroup _ ℂ :=
  select_unitary _ fun _ => tensorGate_unitary (nonnegativePrepare_unitary _ zero
    (fun i => by unfold slotAmplitude; split <;> positivity) (slot_norm slots hd)) (Submonoid.one_mem _)

noncomputable def prepared (slots : Finset I) (zero : I) (pos : I → Equiv.Perm I) :
    Matrix (Work I m) (Work I m) ℂ := permMatrix (position pos) * uniformOp slots zero

noncomputable def valueGate (code : I → I → BitVec m) (decode : BitVec m → ℂ) :
    Matrix (Work I m) (Work I m) ℂ :=
  permMatrix (lookup code) * rotation decode * permMatrix (lookup code)

/-- F, O_H, the decoded rotation, O_H again, register swap, and F inverse
are the data-dependent part of one block query. The position unitary occurs
in the two copies of prepared. -/
noncomputable def oracle (slots : Finset I) (zero : I) (pos : I → Equiv.Perm I)
    (code : I → I → BitVec m) (decode : BitVec m → ℂ) : Matrix (Work I m) (Work I m) ℂ :=
  (prepared slots zero pos)ᴴ * permMatrix swap * valueGate code decode * prepared slots zero pos

private theorem prepared_column (slots : Finset I) (zero : I) (pos : I → Equiv.Perm I)
    (j i k : I) (z : BitVec m) (b : Bool) :
    (prepared (m := m) slots zero pos * signalFrame (m := m) zero) (i,k,z,b) j =
      if i=j ∧ z=0 ∧ b=false then (slotAmplitude slots ((pos i).symm k) : ℂ) else 0 := by
  rw [prepared,Matrix.mul_assoc,permutation_action]
  change (uniformOp (m := m) slots zero * signalFrame (m := m) zero) (i,(pos i).symm k,z,b) j = _
  simp only [Matrix.mul_apply,signalFrame,mul_ite,mul_one,mul_zero]
  rw [Fintype.sum_ite_eq']
  have col := nonnegativePrepare_column (slotAmplitude slots) zero
    (fun i => by unfold slotAmplitude; split <;> positivity) ((pos i).symm k)
  simp [uniformOp,select,tensorGate_apply,col,Matrix.one_apply,ite_and]

private theorem rotation_action (decode : BitVec m → ℂ) (A : Matrix (Work I m) I ℂ)
    (i k : I) (z : BitVec m) (b : Bool) (j : I) :
    (rotation (I := I) decode * A) (i,k,z,b) j = ∑ f, ampGate (decode z) b f * A (i,k,z,f) j := by
  simp [Matrix.mul_apply,rotation,select,Fintype.sum_prod_type,ite_mul]

private theorem value_action (code : I → I → BitVec m) (decode : BitVec m → ℂ)
    (A : Matrix (Work I m) I ℂ) (i k : I) (z : BitVec m) (b : Bool) (j : I) :
    (valueGate code decode * A) (i,k,z,b) j =
      ∑ f, ampGate (decode (z ^^^ code k i)) b f * A (i,k,z,f) j := by
  rw [valueGate,Matrix.mul_assoc,Matrix.mul_assoc,permutation_action]
  change (rotation (I := I) decode * (permMatrix (lookup code) * A)) (i,k,z ^^^ code k i,b) j = _
  rw [rotation_action]
  apply Finset.sum_congr rfl
  intro f _
  rw [permutation_action]
  simp [lookup,BitVec.xor_assoc]

private theorem right_column (slots : Finset I) (zero : I) (pos : I → Equiv.Perm I)
    (code : I → I → BitVec m) (decode : BitVec m → ℂ) (j i k : I) (z : BitVec m) (b : Bool) :
    (permMatrix (swap (I := I) (m := m)) * (valueGate code decode *
      (prepared (m := m) slots zero pos * signalFrame (m := m) zero))) (i,k,z,b) j =
      if k=j ∧ z=0 then ampGate (decode (code i k)) b false * slotAmplitude slots ((pos k).symm i) else 0 := by
  rw [permutation_action]
  change (valueGate code decode * (prepared (m := m) slots zero pos * signalFrame (m := m) zero)) (k,i,z,b) j = _
  rw [value_action]
  by_cases h : k=j ∧ z=0
  · obtain ⟨rfl,rfl⟩ := h; simp [prepared_column]
  · rw [ite_eq_right h]
    apply Finset.sum_eq_zero
    intro f _
    rw [prepared_column,ite_eq_right (fun ⟨a,b,_⟩ => h ⟨a,b⟩),mul_zero]

/-- For an in-place position oracle covering every nonzero entry in its row,
and an XOR oracle returning the binary entry, the displayed circuit exactly
encodes A/d through the clean workspace. The public decoder supplies unit-disk
values, so its controlled amplitude rotation is independent of the input. -/
theorem sparseOracleEncoding (A : Matrix I I ℂ) (hermitian : A.IsHermitian)
    (slots : Finset I) (hd : 0 < slots.card) (zero : I) (pos : I → Equiv.Perm I)
    (support : ∀ i j, A i j ≠ 0 → (pos i).symm j ∈ slots)
    (code : I → I → BitVec m) (decode : BitVec m → ℂ)
    (unitDisk : ∀ z, ‖decode z‖ ≤ 1) (access : ∀ i j, decode (code i j) = A i j) :
    ProjectedUnitaryEncoding (((slots.card : ℂ)⁻¹) • A) (oracle slots zero pos code decode)
      (signalFrame (m := m) zero) (signalFrame (m := m) zero) := by
  let Y := prepared (m := m) slots zero pos * signalFrame (m := m) zero
  let Z := permMatrix (swap (I := I) (m := m)) * (valueGate code decode * Y)
  have pu (e : Equiv.Perm (Work I m)) : permMatrix e ∈ Matrix.unitaryGroup _ ℂ :=
    Qatlib.Concepts.HspRecovery.RecordExtract.permMatrix_unitary_of_injective e.injective
  have prep : prepared (m := m) slots zero pos ∈ Matrix.unitaryGroup _ ℂ :=
    mul_mem (pu (position pos)) (uniform_unit slots zero hd)
  have rot : rotation (I := I) decode ∈ Matrix.unitaryGroup _ ℂ :=
    select_unitary _ fun _ => select_unitary _ fun _ => select_unitary _ fun z => rot_unit _ (unitDisk z)
  have val : valueGate code decode ∈ Matrix.unitaryGroup _ ℂ :=
    mul_mem (mul_mem (pu (lookup code)) rot) (pu (lookup code))
  refine ⟨mul_mem (mul_mem (mul_mem (Unitary.star_mem prep) (pu swap)) val) prep,
    frame_iso _,frame_iso _,?_⟩
  have asGram : compress (signalFrame (m := m) zero) (oracle slots zero pos code decode)
      (signalFrame (m := m) zero) = Yᴴ * Z := by
    simp only [compress,oracle,Y,Z,Matrix.conjTranspose_mul,Matrix.mul_assoc]
  rw [asGram]
  ext i j
  rw [Matrix.mul_apply,Fintype.sum_eq_single (i,j,(0 : BitVec m),false)]
  swap
  · rintro ⟨r,k,z,b⟩ different
    simp only [Matrix.conjTranspose_apply,Y,Z,prepared_column,right_column]
    by_cases left : r=i ∧ z=0 ∧ b=false
    · have right : ¬(k=j ∧ z=0) := by
        rintro ⟨rfl,_⟩; obtain ⟨rfl,rfl,rfl⟩ := left; exact different rfl
      rw [ite_eq_right right,mul_zero]
    · rw [ite_eq_right left,star_zero,zero_mul]
  simp only [Matrix.conjTranspose_apply,Y,Z,prepared_column,right_column,and_self,ite_true,
    Matrix.smul_apply,smul_eq_mul,access]
  simp only [ampGate,Matrix.of_apply,ite_true,slotAmplitude,Complex.star_def,
    Complex.conj_ofReal]
  by_cases nz : A i j = 0
  · simp [nz]
  · have h₁ := support i j nz
    have h₂ := support j i (by rwa [← hermitian.apply j i,star_ne_zero])
    simp [h₁,h₂]
    have sq : ((Real.sqrt (slots.card:ℝ) : ℝ):ℂ)^2 = (slots.card:ℂ) := by
      exact_mod_cast Real.sq_sqrt (Nat.cast_nonneg slots.card : (0:ℝ)≤slots.card)
    have scalar : ((Real.sqrt (slots.card:ℝ) : ℝ):ℂ)⁻¹ * ((Real.sqrt (slots.card:ℝ) : ℝ):ℂ)⁻¹ =
        (slots.card:ℂ)⁻¹ := by rw [← mul_inv,← pow_two,sq]
    linear_combination (norm := ring_nf) (A i j)*scalar

/-- The two distinct physical resources in the sparse input model. -/
inductive Access where | position | entry deriving DecidableEq

/-- Matrix-product order. Only the swap and known binary-decoder rotation
require an outer control. Lookup and its inverse run unconditionally. -/
noncomputable def blockProgram (slots : Finset I) (zero : I) (decode : BitVec m → ℂ) :
    List (Step (Bool × (Bool × Work I m)) Access) :=
  [.fixed (broadcast (uniformOp (m := m) slots zero))ᴴ, .query .position true,
   .fixed (lifted (permMatrix (swap (I := I) (m := m)))), .query .entry true,
   .fixed (lifted (rotation (I := I) decode)), .query .entry false,
   .query .position false, .fixed (broadcast (uniformOp (m := m) slots zero))]

noncomputable def inputOracles (pos : I → Equiv.Perm I) (code : I → I → BitVec m) :
    Access → Matrix (Bool × (Bool × Work I m)) (Bool × (Bool × Work I m)) ℂ
  | .position => broadcast (permMatrix (position pos))
  | .entry => broadcast (permMatrix (lookup code))

/-- The query circuit really uses two in-place position calls and two binary
value lookups, all with both signal flags untouched. Its matrix is the
controlled encoding that the signal-processing word expects. -/
theorem blockProgram_spec (slots : Finset I) (hd : 0<slots.card) (zero : I) (pos : I → Equiv.Perm I)
    (code : I → I → BitVec m) (decode : BitVec m → ℂ) :
    let cs := blockProgram slots zero decode
    cost Access.position cs=2 ∧ cost Access.entry cs=2 ∧
    run (inputOracles pos code) cs = lifted (oracle slots zero pos code decode) := by
  let P := prepared (m := m) slots zero pos
  let X := permMatrix (lookup code)
  have invol : Function.Involutive (lookup code) := by intro w; simp [lookup,BitVec.xor_assoc]
  have xu := permMatrix_unitary invol
  have xstar : Xᴴ=X := permMatrix_conjTranspose invol
  have pu : P ∈ Matrix.unitaryGroup _ ℂ := mul_mem
    (Qatlib.Concepts.HspRecovery.RecordExtract.permMatrix_unitary_of_injective (position pos).injective)
    (uniform_unit slots zero hd)
  refine ⟨rfl,rfl,?_⟩
  have factor : oracle slots zero pos code decode =
      Pᴴ * (permMatrix swap * (Xᴴ * rotation decode * X)) * P := by
    rw [xstar]; simp only [P,X,oracle,valueGate,Matrix.mul_assoc]
  rw [factor,lift_conjugate P _ pu,lift_mul,lift_conjugate X _ xu]
  simp only [P,X,prepared,broadcast_mul,Matrix.conjTranspose_mul,blockProgram,inputOracles,run,matrix,
    Matrix.mul_one,Matrix.mul_assoc]

/-- Low–Chuang (2019), Lemma 6. Any known positive entry scale may be used,
including the maximum entry norm of a nonzero Hamiltonian. The signal frame
has clean coordinate workspace. The circuit for controlled access uses two
ordinary queries of each kind. -/
theorem sparseStandardForm (H : Matrix I I ℂ) (hermitian : H.IsHermitian)
    (slots : Finset I) (hd : 0 < slots.card) (zero : I) (b : ℝ) (_hb : 0<b)
    (pos : I → Equiv.Perm I) (support : ∀ i j, H i j ≠ 0 → (pos i).symm j ∈ slots)
    (code : I → I → BitVec m) (decode : BitVec m → ℂ)
    (unitDisk : ∀ z, ‖decode z‖ ≤ 1) (access : ∀ i j, decode (code i j) = (b⁻¹:ℝ) • H i j) :
    let S := oracle slots zero pos code decode
    let F := signalFrame (m:=m) zero
    let program := blockProgram slots zero decode
    ProjectedUnitaryEncoding (((slots.card*b:ℝ)⁻¹ : ℝ) • H) S F F ∧
    run (inputOracles pos code) program = lifted S ∧
    cost Access.position program=2 ∧ cost Access.entry program=2 := by
  let A := (b⁻¹:ℝ) • H
  have enc := sparseOracleEncoding A (hermitian.smul (IsSelfAdjoint.all _)) slots hd zero pos
    (fun i j h => support i j (fun eq => h (by simp [A,eq]))) code decode unitDisk access
  have eq : (((slots.card : ℂ)⁻¹) • A) = ((slots.card*b : ℝ)⁻¹) • H := by
    ext i j
    simp [A,Matrix.smul_apply,Complex.real_smul,smul_eq_mul,_root_.mul_inv_rev,mul_assoc,mul_comm]
  obtain ⟨cp,ce,mat⟩ := blockProgram_spec slots hd zero pos code decode
  exact ⟨eq ▸ enc,mat,cp,ce⟩

/-- Sparse simulation with explicit, independently varied in-place position and
m-bit XOR-entry oracles. Every unit-disk decoder is fixed before the input.
d is the number of slots and b is the entry scale in physical time. -/
theorem sparseQuerySimulation (slots : Finset I) (hd : 0<slots.card) (zero : I)
    (decode : BitVec m → ℂ) (unitDisk : ∀ z, ‖decode z‖ ≤ 1) (b t ε : ℝ)
    (hb : 0<b) (positive : 0<ε) (small : ε<1) :
    ∃ q : ℕ, IsPaperCutoffQ (t*(slots.card*b)) ε q ∧
    ∃ program : List (Step (Bool × (Bool × Work I m)) Access),
      cost Access.position program = 54*(64*q+1) ∧ cost Access.entry program = 54*(64*q+1) ∧
      ∀ (H : Matrix I I ℂ) (pos : I → Equiv.Perm I) (code : I → I → BitVec m),
      H.IsHermitian → (∀ i j, H i j ≠ 0 → (pos i).symm j ∈ slots) →
      (∀ i j, decode (code i j) = (b⁻¹ : ℝ) • H i j) →
      let R := hamiltonianFrame (signalFrame (m := m) zero)
      let M := run (inputOracles pos code) program
      ‖compress R M R - hamiltonianEvolution H t‖ ≤ ε^2/2 ∧
      ∀ ψ : QState I, Normalized ψ → 1-ε^2 ≤ postselectionProbability M R R ψ := by
  let F := signalFrame (m := m) zero
  let body := blockProgram slots zero decode
  let τ := t*(slots.card*b)
  obtain ⟨q,cut,word,_,_,nq,_,correct⟩ := uniformCutoffWord F (frame_iso zero) τ ε positive small
  refine ⟨q,cut,substitute body word,?_,?_,?_⟩
  · rw [cost_substitute,nq]; change 2*(27*(64*q+1))=_; omega
  · rw [cost_substitute,nq]; change 2*(27*(64*q+1))=_; omega
  intro H pos code hermitian support access
  let A := (b⁻¹:ℝ) • H
  have hA : A.IsHermitian := hermitian.smul (IsSelfAdjoint.all _)
  have coding (i j : I) : decode (code i j) = A i j := access i j
  have hs (i j : I) (h : A i j ≠ 0) := support i j (fun z => h (by simp [A,Matrix.smul_apply,z]))
  have enc := sparseOracleEncoding A hA slots hd zero pos hs code decode unitDisk coding
  let B := (↑slots.card:ℂ)⁻¹ • A
  have hB : B.IsHermitian := hA.smul (by simp [IsSelfAdjoint])
  have evolve : hamiltonianEvolution B τ = hamiltonianEvolution H t := by
    unfold hamiltonianEvolution
    simp only [B,A,τ,Complex.ofReal_mul,Complex.ofReal_natCast]
    rw [show (b⁻¹ : ℝ) • H = ((b⁻¹:ℝ):ℂ) • H by rfl,smul_smul,smul_smul]
    congr 1
    push_cast
    field_simp [ne_of_gt hb,ne_of_gt hd]
  obtain ⟨error,_,born⟩ := correct B (oracle slots zero pos code decode) hB enc
  have same := (blockProgram_spec slots hd zero pos code decode).2.2
  simpa only [run_substitute,same,evolve,F,body] using And.intro error born

end FQChemQatlib.Dynamics.LowChuang.Sparse
