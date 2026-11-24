module

public import FQChemQatlib.Dynamics.AncillaFreePhase
import all FQChemQatlib.Dynamics.AncillaFreePhase
import Mathlib.Tactic

/-! # Exact ancilla-free multi-controlled NOT

Conjugating the all-ones phase of angle π by Hadamards on the target gives
the phase-free permutation X when each control is on. See
[Gidney, §2.10](https://arxiv.org/abs/1706.07884).
-/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.AncillaFreePhase

open Matrix BorrowedControls
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription Qatlib.Concepts.GateVocabulary.LocalReflectionGates
open Qatlib.Foundations.PureStateMath
open SingletonPhaseGradient (phase)
variable {n : ℕ}

private theorem hadamardColumn (t : W n) (i j : Reg n) :
    wireGate n t Hadamard i j =
      (if i=Function.update j t false then Hadamard false (j t) else 0)+
      (if i=Function.update j t true then Hadamard true (j t) else 0) := by
  have h := congrFun (applyGate_wireGate_ket n t Hadamard j) i
  simpa [ApplyGate,Matrix.mulVec,dotProduct,Qatlib.Foundations.PureStateMath.Ket,
    mul_ite] using h

private theorem readControls (cs : List (W n)) (t : W n) (ne : t∉cs) (s : Reg n) (b : Bool) :
    cs.all (Function.update s t b)=cs.all s := by
  induction cs with
  | nil => rfl
  | cons a cs ih =>
    simp only [List.mem_cons,not_or] at ne
    simp [Function.update_of_ne (Ne.symm ne.1),ih ne.2]

private theorem conjugate (t : W n) (cs : List (W n)) (ne : t∉cs) :
    wireGate n t Hadamard *
      (Matrix.diagonal (fun s => if s t && cs.all s then phase Real.pi else 1) * wireGate n t Hadamard) =
      mono (fun s => BorrowedControls.flip t (cs.all s) s) (fun _ => 0) := by
  ext i j
  have pi : phase Real.pi = -1 := Complex.exp_pi_mul_I
  rw [← Matrix.mul_assoc,Matrix.mul_apply]
  simp_rw [Matrix.mul_diagonal,hadamardColumn t _ j]
  simp only [mul_add,mul_ite,mul_zero,Finset.sum_add_distrib,Finset.sum_ite_eq',Finset.mem_univ,ite_true]
  have r := readControls cs t ne j
  have h0 : (Real.sqrt 2:ℂ)≠0 := by exact_mod_cast (Real.sqrt_pos.mpr (by norm_num : (0:ℝ)<2)).ne'
  have sq : (Real.sqrt 2:ℂ)^2=2 := by exact_mod_cast Real.sq_sqrt (by norm_num : (0:ℝ)≤2)
  by_cases off : ∀a : Fin n, a≠t → i a=j a
  · have o (b : Bool) : ∀a : Fin n, a≠t → i a=Function.update j t b a :=
      fun a u => (off a u).trans (Function.update_of_ne u _ _).symm
    have flipEq : i=BorrowedControls.flip t (cs.all j) j ↔ i t=(j t ^^ cs.all j) := by
      constructor
      · rintro rfl; simp [BorrowedControls.flip]
      · intro ht; funext a; by_cases eq : a=t
        · subst a; simpa [BorrowedControls.flip] using ht
        · simpa [BorrowedControls.flip,eq] using off a eq
    simp only [wireGate_apply,ite_eq_left (o true),ite_eq_left (o false),Function.update_self,r,pi,mono,flipEq]
    cases i t <;> cases j t <;> cases cs.all j <;>
      simp [Hadamard,SingletonPhaseGradient.phase] <;> field_simp <;> first | linear_combination sq | linear_combination -sq
  · have o (b : Bool) : ¬∀a : Fin n, a≠t → i a=Function.update j t b a :=
      fun h => off (fun a ha => (h a ha).trans (Function.update_of_ne ha _ _))
    have no : i≠BorrowedControls.flip t (cs.all j) j :=
      fun e => off (fun a ha => (congrFun e a).trans (Function.update_of_ne ha _ _))
    simp only [wireGate_apply,ite_eq_right (o true),ite_eq_right (o false),mono,ite_eq_right no,zero_mul,ite_self,zero_add]

/-- Exact multi-controlled NOT on k controls and the target, with ≤1442k+4323
one- or two-qubit gates and no additional qubits, including the complete-input
case. Its basis permutation has no residual relative or global phase. -/
theorem multiControlledNot (t : W n) (cs : List (W n)) (nd : (t::cs).Nodup) :
    Emits t cs (mono (fun s => BorrowedControls.flip t (cs.all s) s) (fun _ => 0))
      (2*(720*(cs.length+3))+2*cs.length+3) := by
  have phaseWord := multiControlledPhase t cs nd Real.pi
  have H : Emits t cs (wireGate n t Hadamard) 1 := by
    have legal : finiteCodeLegal n (.h t)=true := by simp [finiteCodeLegal]
    simpa only [finiteCodeMatrix,dite_eq_left t.isLt] using single (Local.code (t:=t) (cs:=cs) (.h t) legal)
  have seq := compose (compose H phaseWord) H
  rw [conjugate t cs (List.nodup_cons.mp nd).1] at seq
  convert seq using 1
  omega

end FQChemQatlib.Dynamics.AncillaFreePhase
