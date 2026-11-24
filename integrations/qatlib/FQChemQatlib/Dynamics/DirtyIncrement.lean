module

public import FQChemQatlib.Dynamics.BorrowedRipple
public import Qatlib.Concepts.GateVocabulary.FiniteGateDescription
public import Mathlib.Data.ZMod.Basic
import Mathlib.Tactic

/-! # Borrowed-register conditional increment

The forward and reversed ripple adders cancel the unknown addend. Toggling
their shared input carry between the two changes the answer by +1 or −1.
Bitwise complementation controlled by the original carry fixes this sign.

This variant of the dirty-register arithmetic in [Gidney, §2.10 and Fig. 21](https://arxiv.org/abs/1706.07884) uses the incoming carry of the addition circuit from [Cuccaro et al., §2](https://arxiv.org/abs/quant-ph/0410184).
-/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.DirtyIncrement

open BorrowedControls BorrowedRipple
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Foundations.QueryWordCore.Circuit
open Qatlib.Foundations.PureStateMath (Ket)
variable {n : ℕ}

theorem inverseWord {f : Reg n → Reg n} {k} (impl : Implements f k) :
    ∃ g, Implements g k ∧ Function.LeftInverse g f ∧ Function.RightInverse g f := by
  obtain ⟨w,l,ok,eval⟩ := impl
  have cancel (s : Reg n) := (finite_gate_word_paid_adjoint_semantics n w (Ket s) ok).2.2.1
  simp only [finiteCodeCircuit,List.map_append,run_append] at cancel
  have back (s : Reg n) : Run 1 (finiteCodeCircuit n (finiteWordAdjoint w)) (Ket (f s))=Ket s := by
    rw [← eval]; exact cancel s
  have inj : Function.Injective f := by
    intro a b h
    by_contra ne
    have eq := (back a).symm.trans (by rw [h,back])
    simpa [Qatlib.Foundations.PureStateMath.Ket,ne] using congrFun eq a
  let e := Equiv.ofBijective f ⟨inj,Finite.surjective_of_injective inj⟩
  refine ⟨e.symm,?_,e.symm_apply_apply,e.apply_symm_apply⟩
  have cert := finite_gate_word_paid_adjoint_semantics n w (Ket (fun _ => false)) ok
  refine ⟨finiteWordAdjoint w,cert.2.1 ▸ l,cert.1,?_⟩
  intro s
  have h := back (e.symm s)
  change Run 1 (finiteCodeCircuit n (finiteWordAdjoint w)) (Ket (e (e.symm s))) = _ at h
  simpa using h

def controlledNotList (cs : List (W n)) (c : W n) (s : Reg n) : Reg n :=
  fun i => if i∈cs then s i ^^ s c else s i

theorem controlledNotWord (cs : List (W n)) (c : W n) (nd : (c::cs).Nodup) :
    Implements (controlledNotList cs c) cs.length := by
  induction cs with
  | nil =>
    have e (s : Reg n) : controlledNotList [] c s=s := by funext i; simp [controlledNotList]
    exact ⟨[],by simp,by simp [finiteWordLegal],fun s => by simp [finiteCodeCircuit,e]⟩
  | cons a cs ih =>
    simp only [List.nodup_cons,List.mem_cons,not_or] at nd
    have prior := ih (List.nodup_cons.mpr ⟨nd.1.2,nd.2.2⟩)
    have gate := controlledBit c a nd.1.1
    have e : (fun s : Reg n => BorrowedControls.flip a (s c) s) ∘ controlledNotList cs c =
        controlledNotList (a::cs) c := by
      funext s i
      by_cases h : i=a <;> by_cases k : i∈cs <;> simp_all [controlledNotList,BorrowedControls.flip]
    exact e ▸ compose prior gate

theorem read_append (s : Reg n) (cs ds : List (W n)) :
    BorrowedRipple.read s (cs++ds)=BorrowedRipple.read s cs+2^cs.length*BorrowedRipple.read s ds := by
  induction cs with
  | nil => simp [BorrowedRipple.read]
  | cons a cs ih => simp [BorrowedRipple.read,ih,pow_succ]; ring

theorem read_eq {s v : Reg n} (cs : List (W n)) (h : ∀i∈cs, s i=v i) : BorrowedRipple.read s cs=BorrowedRipple.read v cs := by
  induction cs with
  | nil => rfl
  | cons a cs ih => simp [BorrowedRipple.read,h a (by simp),ih (fun i e => h i (by simp [e]))]

theorem read_complement (s : Reg n) (cs : List (W n)) :
    BorrowedRipple.read (fun a => !(s a)) cs+BorrowedRipple.read s cs+1=2^cs.length := by
  induction cs with
  | nil => simp [BorrowedRipple.read]
  | cons a cs ih => cases z : s a <;> simp [BorrowedRipple.read,z,pow_succ] <;> omega

def register (p : List (P n)) (t : W n) := p.map Prod.snd ++ [t]

abbrev Z (k : ℕ) := ZMod (2^k)

def val (k : ℕ) (cs : List (W n)) (s : Reg n) : Z k := (BorrowedRipple.read s cs:ℕ)

theorem modulus (k : ℕ) : (2 : Z k)^k=0 := by
  change (2 : ZMod (2^k))^k=0
  simpa only [Nat.cast_pow,Nat.cast_ofNat] using (ZMod.natCast_self (2^k))

/-- Reading the whole target including its high bit gives modular addition.
The low addend and incoming carry are restored by the physical word. -/
theorem adds (t c : W n) (p : List (P n)) (nd : (c::t::wires p).Nodup) (s : Reg n) :
    let k := p.length+1
    val k (register p t) (action t p c s) =
      val k (register p t) s+val k (p.map Prod.fst) s+((s c).toNat:Z k) := by
  intro k
  let v := action t p c s
  have h := arithmetic t c p nd s
  change BorrowedRipple.read v _ + 2^p.length*(v t ^^ s t).toNat = _ at h
  have e := congrArg (fun d : ℕ => (d:Z k)) h
  have zero := modulus k
  change (2:Z k)^(p.length+1)=0 at zero
  rw [pow_succ] at zero
  simp only [val,register,read_append,BorrowedRipple.read,List.length_map,add_zero,mul_zero,Nat.cast_add,Nat.cast_mul,Nat.cast_pow,Nat.cast_ofNat] at e ⊢
  change (BorrowedRipple.read v (p.map Prod.snd):Z k)+2^p.length*((v t).toNat:Z k) = _
  cases h₁ : v t <;> cases h₂ : s t <;> simp [h₁,h₂] at e ⊢ <;> first | linear_combination e | linear_combination e - zero

theorem complement_value (k : ℕ) (cs : List (W n)) (c : W n) (s : Reg n) (len : cs.length=k) :
    val k cs (controlledNotList cs c s)=if s c then -val k cs s-1 else val k cs s := by
  cases hc : s c
  · simp only [Bool.false_eq_true,ite_false,val]
    exact congrArg (fun d : ℕ => (d:Z k)) (read_eq (s:=controlledNotList cs c s) (v:=s) cs (fun i hi => by simp [controlledNotList,hi,hc]))
  · have eq : BorrowedRipple.read (controlledNotList cs c s) cs=BorrowedRipple.read (fun i => !(s i)) cs :=
      read_eq cs (fun i hi => by simp [controlledNotList,hi,hc])
    have h := congrArg (fun v : ℕ => (v:Z k)) (read_complement s cs)
    simp only [Nat.cast_add,Nat.cast_one,Nat.cast_pow,Nat.cast_ofNat,len,modulus] at h
    simp only [val,eq,ite_true]
    linear_combination h

def confined (cs : List (W n)) (f : Reg n → Reg n) := ∀s i, i∉cs → f s i=s i

def enabled (z : Option (W n)) (s : Reg n) := z.elim true s

def tick (c : W n) (z : Option (W n)) (s : Reg n) := BorrowedControls.flip c (enabled z s) s

theorem tickCircuit (c : W n) (z : Option (W n)) (fresh : c∉z) : Implements (tick c z) 1 := by
  cases z with
  | none => exact bit c
  | some z => exact controlledBit z c (fun eq => fresh (by simp [eq]))

def incrementSpec (cs : List (W n)) (z : Option (W n)) (k : ℕ) :=
  ∃ f : Reg n → Reg n, Implements f k ∧ confined cs f ∧
    ∀s, val cs.length cs (f s)=val cs.length cs s+((enabled z s).toNat:Z cs.length)

theorem projections (p : List (P n)) : (p.map Prod.fst).Sublist (wires p) ∧ (p.map Prod.snd).Sublist (wires p) := by
  induction p with
  | nil => simp [wires]
  | cons ab p ih =>
    rcases ab with ⟨a,b⟩
    exact ⟨(ih.1.cons b).cons_cons a,(ih.2.cons_cons b).cons a⟩

theorem reflectedCarry {R} [CommRing R] (x a y b : R) (d e : Bool) (D : R)
    (ha : a=(if d then -x-1 else x)) (hy : y+D+(d.toNat:R)=a)
    (hb : b=y+D+((d ^^ e).toNat:R)) :
    (if d then -b-1 else b)=x+(e.toNat:R) := by
  cases d <;> cases e <;> simp_all
  linear_combination -hy

/-- Conditional (or unconditional) increment of k target bits using k dirty
bits. The borrowed low addend, borrowed carry and optional external control
are restored for both control values. -/
theorem manyDirty (t c : W n) (p : List (P n)) (z : Option (W n))
    (nd : (c::t::wires p).Nodup) (spare : ∀i∈z, i∉c::t::wires p) :
    incrementSpec (register p t) z (70*(p.length+1)+2) := by
  let cs := register p t
  let k := cs.length
  let ds := p.map Prod.fst
  let f := action t p c
  let C := controlledNotList cs c
  let T := tick c z
  have len : cs.length=p.length+1 := by simp [cs,register]
  have ndc : (c::cs).Nodup := by
    simp only [List.nodup_cons,List.mem_cons,not_or] at nd
    have sub := projections p
    simp [cs,register,List.nodup_cons,List.nodup_append',sub.2.nodup nd.2.2]
    grind [List.Sublist.subset]
  have csC : c∉cs := (List.nodup_cons.mp ndc).1
  have cz : c∉z := fun h => spare c h (by simp)
  have zs (i) (hi : i∈z) : i∉cs := by
    intro ht
    have h := spare i hi
    simp only [cs,register,List.mem_append,List.mem_singleton] at ht
    rcases ht with e|rfl
    · exact h (by simp [show i ∈ wires p from (BorrowedRipple.member p).mpr (Or.inr e)])
    · exact h (by simp)
  have dsOutside (i) (hi : i∈ds) : i∉cs := by
    have hw := (BorrowedRipple.member p).mpr (Or.inl hi)
    have ndw := (List.nodup_cons.mp (List.nodup_cons.mp nd).2)
    have dis (p : List (P n)) (ND : (wires p).Nodup) :
        (p.map Prod.fst).Disjoint (p.map Prod.snd) := by
      induction p with
      | nil => simp
      | cons ab p ih =>
        obtain ⟨a,b⟩ := ab
        change (a::b::wires p).Nodup at ND
        simp only [List.nodup_cons,List.mem_cons,not_or] at ND
        have smaller := ih ND.2.2
        simp only [List.map_cons,List.disjoint_left,List.mem_cons] at smaller ⊢
        grind [BorrowedRipple.member]
    simp only [cs,register,List.mem_append,List.mem_singleton,not_or]
    exact ⟨List.disjoint_left.mp (dis p ndw.2) hi,fun e => ndw.1 (e ▸ hw)⟩
  have F : confined cs f := by
    intro v i hi
    apply restored t c p nd v i <;> grind [register,List.mem_singleton]
  have co := circuit t c p nd
  obtain ⟨g,back,L,R⟩ := inverseWord co
  have G : confined cs g := fun s i h => (F (g s) i h).symm.trans (congrFun (R s) i)
  have CC : confined cs C := fun s i h => by simp [C,controlledNotList,h]
  have TT (s : Reg n) (i : W n) (h : i≠c) : T s i=s i := Function.update_of_ne h _ _
  have eqT (s : Reg n) : T s c=(s c ^^ enabled z s) := Function.update_self ..
  have eZ {s v : Reg n} (same : ∀i∈z, s i=v i) : enabled z s=enabled z v := by
    cases z with | none => rfl | some z => exact same z (by simp)
  have impT : Implements T 1 := tickCircuit c z cz
  have impC := controlledNotWord cs c ndc
  let final := C ∘ (T ∘ (f ∘ (T ∘ (g ∘ C))))
  have imp : Implements final (cs.length+(34*p.length+1)+1+(34*p.length+1)+1+cs.length) :=
    compose (compose (compose (compose (compose impC back) impT) co) impT) impC
  refine ⟨final,weaken imp (by omega),?_,?_⟩
  · intro s i hi
    let A := C s
    let B := g A
    let D := T B
    let E := f D
    have bZ : enabled z B=enabled z s := eZ fun j hj => (G A j (zs j hj)).trans (CC s j (zs j hj))
    have eZ' : enabled z E=enabled z B := eZ fun j hj =>
      (F D j (zs j hj)).trans (TT B j (fun h => cz (h ▸ hj)))
    change C (T E) i=s i
    rw [CC _ i hi]
    by_cases ic : i=c
    · subst i
      rw [eqT,show E c=D c from F D c csC,show D c=_ from eqT B,eZ',Bool.xor_assoc,Bool.xor_self,Bool.xor_false,
        show B c=A c from G A c csC,show A c=s c from CC s c csC]
    · rw [TT _ _ ic,show E i=D i from F D i hi,show D i=B i from TT B i ic,show B i=A i from G A i hi,show A i=s i from CC s i hi]
  · intro s
    let A := C s
    let B := g A
    let D := T B
    let E := f D
    let J := T E
    have Fv (v : Reg n) : val k cs (f v)=val k cs v+val k ds v+((v c).toNat:Z k) := by
      have gen (j : ℕ) (e : j=p.length+1) : val j cs (f v)=val j cs v+val j ds v+((v c).toNat:Z j) := by
        subst j; exact adds t c p nd v
      exact gen k len
    have dC (v) : val k ds (T v)=val k ds v := congrArg (fun d:ℕ => (d:Z k)) (read_eq ds (fun i hi =>
      TT v i (fun ic => (List.nodup_cons.mp nd).1 (by simp [← ic,(BorrowedRipple.member p).mpr (Or.inl hi)]))))
    have vT (v) : val k cs (T v)=val k cs v :=
      congrArg (fun d:ℕ => (d:Z k)) (read_eq cs (fun i hi => TT v i (fun eq => csC (eq ▸ hi))))
    have BC : B c=s c := (G A c csC).trans (CC s c csC)
    have BZ : enabled z B=enabled z s := eZ fun j hj => (G A j (zs j hj)).trans (CC s j (zs j hj))
    have DC : D c=(s c ^^ enabled z s) := by rw [show D c=_ from eqT B,BC,BZ]
    have eZ' : enabled z E=enabled z s := eZ (fun j hj =>
      (F D j (zs j hj)).trans ((TT B j (fun eq => cz (eq ▸ hj))).trans ((G A j (zs j hj)).trans (CC s j (zs j hj)))))
    have JC : J c=s c := by rw [show J c=_ from eqT E,show E c=D c from F D c csC,DC,eZ',Bool.xor_assoc,Bool.xor_self,Bool.xor_false]
    have ca := complement_value k cs c s rfl
    have gA := Fv B
    rw [BC,show f B=A from R A] at gA
    have fD := Fv D
    rw [show val k cs D=_ from vT B,show val k ds D=_ from dC B,DC] at fD
    change val k cs (controlledNotList cs c J)=_
    rw [complement_value k cs c J rfl,JC,show val k cs J=_ from vT E]
    exact reflectedCarry _ _ _ _ _ _ _ ca gA.symm fD

end FQChemQatlib.Dynamics.DirtyIncrement
