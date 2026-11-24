module

public import FQChemQatlib.Dynamics.LowChuangSparseOracle
public import FQChemQatlib.Dynamics.LowChuangBinaryDecoder

/-! # A sparse block encoding using a Cartesian binary value circuit -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseBlock

open Matrix Qatlib.Foundations.PureStateMath Qatlib.Concepts.BlockEncoding.LCU
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.BlockEncoding
open Qatlib.Concepts.BlockEncoding.EncodingCore Qatlib.Concepts.BlockEncoding.Encoding
open Qatlib.Concepts.CopyEvolution.Discriminate Qatlib.Concepts.LocalMachine.LocalTransport
open FQChemQatlib.Dynamics.LowChuang.Binary
open scoped Classical

abbrev Work (I B : Type) := I × (I × B)

variable {I B : Type} [Fintype I] [DecidableEq I] [Fintype B] [DecidableEq B]

def frame (zero : I) (blank : B) : Matrix (Work I B) I ℂ := fun w i => if w=(i,zero,blank) then 1 else 0

theorem frame_iso (z : I) (blank : B) : IsIsometry (frame z blank) := by
  ext i j
  simp [frame,Matrix.mul_apply,Matrix.conjTranspose_apply,Matrix.one_apply,eq_comm]

def slotGate (S : Matrix I I ℂ) : Matrix (Work I B) (Work I B) ℂ := parallelOracle (J:=I) (TensorGate S (1:Matrix B B ℂ))

def position (pos : I → Equiv.Perm I) : Equiv.Perm (Work I B) where
  toFun w := (w.1,pos w.1 w.2.1,w.2.2)
  invFun w := (w.1,(pos w.1).symm w.2.1,w.2.2)
  left_inv _ := by simp
  right_inv _ := by simp

def exchange : Equiv.Perm (Work I B) where
  toFun w := (w.2.1,w.1,w.2.2)
  invFun w := (w.2.1,w.1,w.2.2)
  left_inv _ := rfl
  right_inv _ := rfl

/-- The ordinary value lookup acts on the answer bits alone. Its first logical
argument is the column to agree with the matrix product convention. -/
def entry (lookup : I → I → Equiv.Perm B) : Equiv.Perm (Work I B) where
  toFun w := (w.1,w.2.1,lookup w.2.1 w.1 w.2.2)
  invFun w := (w.1,w.2.1,(lookup w.2.1 w.1).symm w.2.2)
  left_inv _ := by simp
  right_inv _ := by simp

def decoderGate (V : Matrix B B ℂ) : Matrix (Work I B) (Work I B) ℂ :=
  parallelOracle (J:=I) (parallelOracle (J:=I) V)

def prepared (S : Matrix I I ℂ) (pos : I → Equiv.Perm I) : Matrix (Work I B) (Work I B) ℂ :=
  Qatlib.Foundations.PureStateMath.permMatrix (position pos) * slotGate S

def oracle (S : Matrix I I ℂ) (pos : I → Equiv.Perm I)
    (lookup : I → I → Equiv.Perm B) (V : Matrix B B ℂ) :=
  let P := prepared (B:=B) S pos
  let X : Matrix (Work I B) (Work I B) ℂ := Qatlib.Foundations.PureStateMath.permMatrix (entry lookup)
  Pᴴ * Qatlib.Foundations.PureStateMath.permMatrix (exchange (I:=I) (B:=B)) * Xᴴ * decoderGate (I:=I) V * X * P

private theorem permutation_action {X Y : Type} [Fintype X] [DecidableEq X] (e : Equiv.Perm X)
    (A : Matrix X Y ℂ) (x : X) (y : Y) : (Qatlib.Foundations.PureStateMath.permMatrix e*A) x y = A (e.symm x) y := by
  simp only [Matrix.mul_apply,Qatlib.Foundations.PureStateMath.permMatrix,Matrix.of_apply,ite_mul,one_mul,zero_mul,
    show ∀ b, x=e b ↔ b=e.symm x from fun b => by simp [eq_comm,e.eq_symm_apply]]
  simp

private theorem prep_col (S : Matrix I I ℂ) (pos : I → Equiv.Perm I) (zero : I) (blank : B) (r k : I) (b : B) (j : I) :
    (prepared (B:=B) S pos * frame zero blank) (r,k,b) j =
      if r=j ∧ b=blank then S ((pos r).symm k) zero else 0 := by
  rw [prepared,Matrix.mul_assoc,permutation_action]
  change (slotGate (B:=B) S * frame zero blank) (r,(pos r).symm k,b) j=_
  simp [slotGate,parallelOracle,select,tensorGate_apply,frame,Matrix.mul_apply,Matrix.one_apply,mul_ite,ite_and]

private theorem loaded_col (S : Matrix I I ℂ) (pos : I → Equiv.Perm I) (lookup : I → I → Equiv.Perm B)
    (zero : I) (blank b : B) (r k j : I) :
    (Qatlib.Foundations.PureStateMath.permMatrix (entry lookup)*(prepared (B:=B) S pos * frame zero blank)) (r,k,b) j =
      if r=j ∧ b=lookup k r blank then S ((pos r).symm k) zero else 0 := by
  rw [permutation_action]
  change (prepared (B:=B) S pos * frame zero blank) (r,k,(lookup k r).symm b) j=_
  simp only [prep_col,Equiv.symm_apply_eq]

private theorem left_col (S : Matrix I I ℂ) (pos : I → Equiv.Perm I) (lookup : I → I → Equiv.Perm B)
    (zero : I) (blank b : B) (r k i : I) :
    (Qatlib.Foundations.PureStateMath.permMatrix (entry lookup) *
      (Qatlib.Foundations.PureStateMath.permMatrix (exchange (I:=I) (B:=B)) * (prepared (B:=B) S pos * frame zero blank))) (r,k,b) i =
      if k=i ∧ b=lookup k r blank then S ((pos k).symm r) zero else 0 := by
  rw [permutation_action]
  change (Qatlib.Foundations.PureStateMath.permMatrix (exchange (I:=I) (B:=B)) * (prepared (B:=B) S pos * frame zero blank)) (r,k,(lookup k r).symm b) i=_
  rw [permutation_action]
  change (prepared (B:=B) S pos * frame zero blank) (k,r,(lookup k r).symm b) i=_
  simp only [prep_col,Equiv.symm_apply_eq]

private theorem right_col (S : Matrix I I ℂ) (pos : I → Equiv.Perm I) (lookup : I → I → Equiv.Perm B)
    (V : Matrix B B ℂ) (zero : I) (blank b : B) (r k j : I) :
    (decoderGate (I:=I) V*(Qatlib.Foundations.PureStateMath.permMatrix (entry lookup)*(prepared (B:=B) S pos * frame zero blank))) (r,k,b) j =
      if r=j then V b (lookup k r blank) * S ((pos r).symm k) zero else 0 := by
  rw [Matrix.mul_apply,Fintype.sum_prod_type]
  simp [decoderGate,parallelOracle,select,loaded_col,Fintype.sum_prod_type,ite_mul,mul_ite,ite_and]

/-- Only the diagonal entries of the value circuit on loaded, clean words are
used. The row-preparation block can be any unitary, permitting an explicit
Hadamard circuit on a padded power-of-two set of slots. -/
theorem compression (S : Matrix I I ℂ) (pos : I → Equiv.Perm I) (lookup : I → I → Equiv.Perm B)
    (V : Matrix B B ℂ) (zero : I) (blank : B) (i j : I) :
    compress (frame zero blank) (oracle S pos lookup V) (frame zero blank) i j =
      star (S ((pos i).symm j) zero) * V (lookup i j blank) (lookup i j blank) * S ((pos j).symm i) zero := by
  let A : Matrix (Work I B) I ℂ := prepared (B:=B) S pos * frame zero blank
  let X : Matrix (Work I B) (Work I B) ℂ := Qatlib.Foundations.PureStateMath.permMatrix (entry lookup)
  let S' : Matrix (Work I B) (Work I B) ℂ := Qatlib.Foundations.PureStateMath.permMatrix (exchange (I:=I) (B:=B))
  have starS : S'ᴴ=S' := permMatrix_conjTranspose (fun _ => rfl)
  have eq : compress (frame zero blank) (oracle S pos lookup V) (frame zero blank) =
    (X*(S'*A))ᴴ * (decoderGate (I:=I) V*(X*A)) := by
    simp only [oracle,compress,A,Matrix.conjTranspose_mul,starS,Matrix.mul_assoc,X,S']
  rw [eq,Matrix.mul_apply,Fintype.sum_eq_single (j,i,lookup i j blank)]
  · simp only [Matrix.conjTranspose_apply,A,X,S',left_col,right_col,and_self,ite_true]; ring
  · rintro ⟨r,k,b⟩ h
    simp only [Matrix.conjTranspose_apply,A,X,S',left_col,right_col]
    by_cases rj : r=j
    · subst r
      have hnot : ¬(k=i ∧ b=lookup k j blank) := by rintro ⟨rfl,rfl⟩; exact h rfl
      rw [ite_eq_right hnot,star_zero,zero_mul]
    · rw [ite_eq_right rj,mul_zero]

theorem oracle_unit (S : Matrix I I ℂ) (hs : S ∈ Matrix.unitaryGroup _ ℂ) (pos : I → Equiv.Perm I)
    (lookup : I → I → Equiv.Perm B) (V : Matrix B B ℂ) (hv : V∈Matrix.unitaryGroup _ ℂ) :
    oracle S pos lookup V ∈ Matrix.unitaryGroup _ ℂ := by
  have perm (e : Equiv.Perm (Work I B)) : Qatlib.Foundations.PureStateMath.permMatrix e ∈ Matrix.unitaryGroup _ ℂ :=
    Qatlib.Concepts.HspRecovery.RecordExtract.permMatrix_unitary_of_injective e.injective
  have p : prepared (B:=B) S pos ∈ Matrix.unitaryGroup _ ℂ :=
    mul_mem (perm _) (parallelOracle_unitary (tensorGate_unitary hs (Submonoid.one_mem _)))
  exact mul_mem (mul_mem (mul_mem (mul_mem (mul_mem (Unitary.star_mem p) (perm _))
    (Unitary.star_mem (perm _))) (parallelOracle_unitary (parallelOracle_unitary hv))) (perm _)) p

end FQChemQatlib.Dynamics.LowChuang.SparseBlock
