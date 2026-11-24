module

public import FQChemQatlib.Dynamics.LowChuangFlagGates
public import FQChemQatlib.Dynamics.BorrowedControls
public import Qatlib.Concepts.QmaCompleteness.HistoryHam.QmaCompletenessDefs
public import Mathlib.Logic.Equiv.Fin.Basic

/-! # Linear elementary-gate circuits for coordinate phase tests -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.Physical

open Matrix FQChemQatlib.Dynamics.BorrowedControls
open Qatlib.Concepts.GateVocabulary.LocalReflectionGates
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Foundations.PureStateMath Qatlib.Foundations.QueryWordCore.Circuit

variable (a r : ℕ)
abbrev width := a+r+2
abbrev Basis := Signals (Reg a) (Reg r)
def outer : Fin (width a r) := 0
def inner : Fin (width a r) := (0 : Fin (a+r+1)).succ
def anc (i : Fin a) : Fin (width a r) := (i.castAdd r).succ.succ
def system (i : Fin r) : Fin (width a r) := (i.natAdd a).succ.succ

/-- Each logical coordinate is one physical wire. A configurable choice of
positive/negative control convention flips only individual bits in the
ancilla register. -/
def layout (mask : Reg a) : Reg (width a r) ≃ Basis a r where
  toFun x := (x (outer a r),x (inner a r),fun i => x (anc a r i) ^^ mask i,fun i => x (system a r i))
  invFun x := Fin.cons x.1 (Fin.cons x.2.1 (Fin.append (fun i => x.2.2.1 i ^^ mask i) x.2.2.2))
  left_inv x := by
    funext i
    refine Fin.cases ?_ (fun j => ?_) i
    · simp [outer]
    refine Fin.cases ?_ (fun k => ?_) j
    · simp [inner]
    refine Fin.addCases (fun h => ?_) (fun h => ?_) k
    · simp [anc]
    · simp [system]
  right_inv x := by
    rcases x with ⟨b,c,u,v⟩
    simp [outer,inner,system,anc]

def ancList := (List.finRange a).map (anc a r)

theorem positive_controls (zero : Reg a) (s : Reg (width a r)) :
    (ancList a r).all s = decide ((layout a r (fun i => !(zero i)) s).2.2.1 = zero) := by
  apply Bool.eq_iff_iff.mpr
  simp only [ancList,List.all_eq_true,List.mem_map,List.mem_finRange,true_and,
    forall_exists_index,forall_apply_eq_imp_iff,decide_eq_true_eq,funext_iff,layout,Equiv.coe_fn_mk]
  constructor
  · intro h i
    have hi := h i
    cases e : s (anc a r i) <;> cases f : zero i <;> simp_all
  · intro h i
    have hi := h i
    cases e : s (anc a r i) <;> cases f : zero i <;> simp_all

private theorem distinct_anc : (outer a r :: inner a r :: ancList a r).Nodup := by
  have inj : Function.Injective (anc a r) := by
    intro i j eq
    apply Fin.ext
    simpa [anc] using congrArg Fin.val eq
  simp [ancList,outer,inner,anc,List.Nodup.map inj (List.nodup_finRange a)]
  intro i eq
  have h := congrArg Fin.val eq
  simp at h

/-- Allow the independently chosen sign convention on individual ancilla wires
when interpreting an addressed word. Its active wires and its length are
identical under this relabeling of computational coordinates. -/
def Compiles (M : Matrix (Basis a r) (Basis a r) ℂ) (k : ℕ) : Prop :=
  ∃ (mask : Reg a) (gs : List FiniteGateCode), gs.length ≤ k ∧ finiteWordLegal (width a r) gs=true ∧
    M = Matrix.reindex (layout a r mask) (layout a r mask) (finiteWordMatrix (width a r) gs)

private theorem compileToggle (mask : Reg a) (p : Equiv.Perm (Basis a r))
    (invol : Function.Involutive p) (cs : List (Fin (width a r))) (t w : Fin (width a r))
    (fresh : (w::t::cs).Nodup)
    (transport : ∀ s, layout a r mask (BorrowedControls.flip t (cs.all s) s) = p (layout a r mask s)) :
    Compiles a r (p.permMatrix ℂ) (120*(cs.length+3)) := by
  let e := layout a r mask
  obtain ⟨gs,len,leg,action⟩ := borrowedMCX cs t w fresh
  refine ⟨mask,gs,len,leg,?_⟩
  ext x y
  have col := congrFun (action (e.symm y)) (e.symm x)
  rw [run_finiteCodeCircuit] at col
  simp [Matrix.mulVec,dotProduct,Qatlib.Foundations.PureStateMath.Ket] at col
  change _ = finiteWordMatrix (width a r) gs (e.symm x) (e.symm y)
  rw [col]
  have eq : BorrowedControls.flip t (cs.all (e.symm y)) (e.symm y) = e.symm (p y) :=
    e.injective (by simpa only [e,Equiv.apply_symm_apply] using transport (e.symm y))
  have cond : p x = y ↔ x = p y := ⟨fun h => by rw [← h,invol],fun h => by rw [h,invol]⟩
  simp [Equiv.Perm.permMatrix,PEquiv.toMatrix_apply,eq,eq_comm]
  simp only [eq_comm (a:=y) (b:=p x),cond]

private theorem succ_ne_inner (i : Fin (a+r)) : i.succ.succ ≠ inner a r := by
  intro eq
  have h := congrArg Fin.val eq
  simp [inner] at h

/-- A zero-ancilla test with the outer signal as dirty workspace. Relabeling
individual ancilla bits permits arbitrary designated coordinates. The circuit
is exact on every input basis assignment, including both borrowed-bit values. -/
theorem testAncilla_compiles (zero : Reg a) :
    Compiles a r ((testAncilla (I:=Reg r) zero).permMatrix ℂ) (120*(a+3)) := by
  have cert := compileToggle a r (fun i => !(zero i)) (testAncilla zero)
    (fun s => (testAncilla zero).left_inv s) (ancList a r) (inner a r) (outer a r) (distinct_anc a r)
  simp only [ancList,List.length_map,List.length_finRange] at cert
  apply cert
  intro s
  have ho : outer a r ≠ inner a r := by simp [outer,inner]
  have ha (i : Fin a) : anc a r i ≠ inner a r := succ_ne_inner _ _ _
  have hs (i : Fin r) : system a r i ≠ inner a r := succ_ne_inner _ _ _
  change layout _ _ _ (BorrowedControls.flip _ ((ancList a r).all s) s) = _
  rw [positive_controls a r zero]
  by_cases he : (layout a r (fun i => !zero i) s).2.2.1=zero <;>
    simp only [layout,Equiv.coe_fn_mk,testAncilla,
      BorrowedControls.flip,Function.update_of_ne ho,Function.update_of_ne (ha _),
      Function.update_of_ne (hs _), Function.update_self,Prod.mk.injEq,
      true_and,and_true] <;> simp_all [layout]

/-- The additional control for cubic amplification uses one spectator system
wire as dirty workspace. It is restored on entangled inputs as well. -/
theorem testBoth_compiles (zero : Reg a) (scratch : Fin r) :
    Compiles a r ((testBoth (I:=Reg r) zero).permMatrix ℂ) (120*(a+4)) := by
  have sep (i : Fin a) : anc a r i ≠ system a r scratch := by
    intro eq
    have h := congrArg Fin.val eq
    simp [anc,system] at h
    omega
  have fresh : (system a r scratch :: outer a r :: inner a r :: ancList a r).Nodup := by
    apply List.nodup_cons.mpr
    refine ⟨?_,distinct_anc a r⟩
    simp [ancList,outer,system,inner]
    exact ⟨succ_ne_inner a r _,sep⟩
  have cert := compileToggle a r (fun i => !zero i) (testBoth zero)
    (fun s => (testBoth zero).left_inv s) (inner a r :: ancList a r)
    (outer a r) (system a r scratch) fresh
  have len : (inner a r :: ancList a r).length=a+1 := by simp [ancList]
  rw [len] at cert
  apply cert
  intro s
  have hi : inner a r ≠ outer a r := by simp [outer,inner]
  have ha (i : Fin a) : anc a r i ≠ outer a r := by simp [outer,anc]
  have hs (i : Fin r) : system a r i ≠ outer a r := by simp [outer,system]
  rw [List.all_cons,positive_controls a r zero]
  by_cases he : (layout a r (fun i => !zero i) s).2.2.1=zero <;> cases h : s (inner a r) <;>
    simp_all [layout,testBoth,BorrowedControls.flip]

end FQChemQatlib.Dynamics.LowChuang.Physical
