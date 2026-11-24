module

public import FQChemQatlib.Dynamics.DirtyIncrement
import Mathlib.Tactic

/-! # Reusing the two halves of a binary incrementer as workspace

The balanced-register construction follows [Gidney, §2.10 and Fig. 21](https://arxiv.org/abs/1706.07884) and [Constructing Large Increment Gates](https://algassert.com/circuits/2015/06/12/Constructing-Large-Increment-Gates.html). This implementation obtains the half-register increments from a toggled input carry.
-/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.HalvedIncrement

open BorrowedControls BorrowedRipple DirtyIncrement
variable {n : ℕ}

private theorem splitValid (p : List (P n)) :
    (wires p).Nodup ↔ ((p.map Prod.fst)++p.map Prod.snd).Nodup := by
  induction p with
  | nil => simp [wires]
  | cons ab p ih =>
    rcases ab with ⟨a,b⟩
    change (a::b::wires p).Nodup ↔ _
    simp only [List.map_cons,List.cons_append,List.nodup_cons,List.mem_cons,List.mem_append,
      not_or,member,List.nodup_append',List.disjoint_cons_right] at ih ⊢
    grind [List.disjoint_left]

private theorem target_snoc (cs : List (W n)) (pos : 0<cs.length) :
    ∃ xs t, cs=xs++[t] := by
  induction cs using List.reverseRecOn with
  | nil => simp at pos
  | append_singleton xs t ih => exact ⟨xs,t,rfl⟩

theorem manyOn (cs ds : List (W n)) (z : Option (W n)) (same : cs.length=ds.length) (pos : 0<cs.length)
    (nd : (cs++ds).Nodup) (spare : ∀i∈z, i∉cs++ds) : incrementSpec cs z (70*cs.length+2) := by
  obtain ⟨xs,t,rfl⟩ := target_snoc cs pos
  cases ds with
  | nil => simp at same
  | cons c ds =>
    have l : xs.length=ds.length := by simpa using same
    let p := ds.zip xs
    have s : p.map Prod.snd=xs := List.map_snd_zip l.le
    have a : p.map Prod.fst=ds := List.map_fst_zip l.ge
    have base : (xs++t::c::ds).Nodup := by simpa only [List.append_assoc,List.singleton_append] using nd
    obtain ⟨left,right,dis⟩ := List.nodup_append'.mp base
    simp only [List.nodup_cons,List.mem_cons,not_or] at right
    have cross := List.disjoint_left.mp dis
    have w : (wires p).Nodup := (splitValid p).mpr (by
      rw [s,a]; apply List.nodup_append'.mpr
      exact ⟨right.2.2,left,List.disjoint_left.mpr (fun i hi hj => cross hj (by simp [hi]))⟩)
    have fresh : (c::t::wires p).Nodup := by
      simp only [List.nodup_cons,List.mem_cons,not_or,member,s,a]
      exact ⟨⟨Ne.symm right.1.1,right.2.1,fun e => cross e (by simp)⟩,
        ⟨right.1.2,fun e => cross e (by simp)⟩,w⟩
    have good := manyDirty t c p z fresh (fun i e => by
      have h := spare i e; simp only [List.mem_append,List.mem_cons,member,s,a] at h ⊢; grind)
    have l' : p.length=xs.length := by simp [p,l]
    simpa [register,s,l'] using good

/-- Make a modular addition on an entire addressed register controlled by any
predicate that can toggle one borrowed wire. Two controlled increments of
opposite signs cancel the original borrowed value. -/
theorem transferredControl (cs : List (W n)) (z : W n) (nd : (z::cs).Nodup)
    (P : Reg n → Bool) (stable : ∀s v : Reg n, (∀i,i∉cs → i≠z → s i=v i) → P s=P v)
    {size toggleCost : ℕ} (inc : incrementSpec cs (some z) size)
    (toggle : Implements (fun s => BorrowedControls.flip z (P s) s) toggleCost) :
    ∃ f : Reg n → Reg n, Implements f (2*(cs.length+size+toggleCost)) ∧ confined cs f ∧
      ∀s, val cs.length cs (f s)=val cs.length cs s+((P s).toNat:Z cs.length) := by
  obtain ⟨f,impl,safe,add⟩ := inc
  obtain ⟨g,back,L,R⟩ := inverseWord impl
  have invSafe : confined cs g := fun s i hi => (safe (g s) i hi).symm.trans (congrFun (R s) i)
  let T := fun s : Reg n => BorrowedControls.flip z (P s) s
  let C := controlledNotList cs z
  have CZ := (List.nodup_cons.mp nd).1
  have CS : confined cs C := fun s i h => by simp [C,controlledNotList,h]
  have TS (s : Reg n) (i : W n) (h : i≠z) : T s i=s i := Function.update_of_ne h _ _
  have TZ (s : Reg n) : T s z=(s z ^^ P s) := Function.update_self ..
  have impC := controlledNotWord cs z nd
  let final := C ∘ (T ∘ (f ∘ (T ∘ (g ∘ C))))
  have imp : Implements final (cs.length+size+toggleCost+size+toggleCost+cs.length) :=
    compose (compose (compose (compose (compose impC back) toggle) impl) toggle) impC
  refine ⟨final,weaken imp (by omega),?_,?_⟩
  · intro s i hi
    let A := C s
    let B := g A
    let D := T B
    let E := f D
    have sameP : P E=P B := stable _ _ fun j hj jz => (safe D j hj).trans (TS B j jz)
    change C (T E) i=s i
    rw [CS _ i hi]
    by_cases iz : i=z
    · subst i
      rw [TZ,show E z=D z from safe D z CZ,show D z=_ from TZ B,sameP,
        Bool.xor_assoc,Bool.xor_self,Bool.xor_false,show B z=A z from invSafe A z CZ,show A z=s z from CS s z CZ]
    · exact (TS E i iz).trans ((safe D i hi).trans ((TS B i iz).trans ((invSafe A i hi).trans (CS s i hi))))
  · intro s
    let A := C s
    let B := g A
    let D := T B
    let E := f D
    let J := T E
    have sameB : P B=P s := stable _ _ fun j hj _ => (invSafe A j hj).trans (CS s j hj)
    have sameE : P E=P s := (stable _ _ (fun j hj jz => (safe D j hj).trans (TS B j jz))).trans sameB
    have BZ : B z=s z := (invSafe A z CZ).trans (CS s z CZ)
    have DZ : D z=(s z ^^ P s) := by rw [show D z=_ from TZ B,BZ,sameB]
    have JZ : J z=s z := by
      rw [show J z=_ from TZ E,show E z=D z from safe D z CZ,DZ,sameE,Bool.xor_assoc,Bool.xor_self,Bool.xor_false]
    have vT (v) : val cs.length cs (T v)=val cs.length cs v := congrArg (fun d:ℕ => (d:Z cs.length))
      (read_eq cs (fun i hi => TS v i (fun eq => CZ (eq ▸ hi))))
    have gA := add B
    change val _ cs (f B)=val _ cs B+((B z).toNat:Z _) at gA
    rw [BZ,show f B=A from R A] at gA
    have fD := add D
    change val _ cs E=val _ cs D+((D z).toNat:Z _) at fD
    rw [show val _ cs D=_ from vT B,DZ] at fD
    change val _ cs (controlledNotList cs z J)=_
    rw [complement_value _ cs z J rfl,JZ,show val _ cs J=_ from vT E]
    have mom := DirtyIncrement.reflectedCarry (val _ cs s) (val _ cs A) (val _ cs B) (val _ cs E)
      (s z) (P s) 0 (complement_value _ cs z s rfl) (by simpa using gA.symm) (by simpa using fD)
    simpa using mom

theorem readRange (s : Reg n) (cs : List (W n)) : BorrowedRipple.read s cs < 2^cs.length := by
  induction cs with
  | nil => simp [BorrowedRipple.read]
  | cons a cs ih => cases z : s a <;> simp [BorrowedRipple.read,z,pow_succ] <;> omega

theorem all_max (s : Reg n) (cs : List (W n)) : cs.all s = true ↔ BorrowedRipple.read s cs+1=2^cs.length := by
  induction cs with
  | nil => simp [BorrowedRipple.read]
  | cons a cs ih =>
    have odd (v d : ℕ) : 2*v+1≠d*2 := by omega
    cases h : s a <;> simp [h,BorrowedRipple.read,pow_succ,ih,odd]
    omega

theorem modular_read {cs : List (W n)} {s v : Reg n} {b : Bool}
    (eq : val cs.length cs v=val cs.length cs s+(b.toNat:Z cs.length)) :
    BorrowedRipple.read v cs = if b then (if BorrowedRipple.read s cs+1=2^cs.length then 0 else BorrowedRipple.read s cs+1)
      else BorrowedRipple.read s cs := by
  change (_ : ZMod (2^cs.length)) = (_ : ZMod (2^cs.length))+_ at eq
  change (BorrowedRipple.read v cs:ZMod (2^cs.length)) = (BorrowedRipple.read s cs:ZMod (2^cs.length))+_ at eq
  rw [← Nat.cast_add] at eq
  have h := congrArg ZMod.val eq
  rw [ZMod.val_natCast_of_lt (readRange v cs),ZMod.val_natCast] at h
  have r := readRange s cs
  cases b with
  | false => simpa [Nat.mod_eq_of_lt r] using h
  | true =>
    simp only [Bool.toNat_true] at h
    by_cases full : BorrowedRipple.read s cs+1=2^cs.length
    · simpa [full] using h
    · have lt : BorrowedRipple.read s cs+1<2^cs.length := by omega
      simpa [full,Nat.mod_eq_of_lt lt] using h

/-- Join a low unconditional increment and a high increment conditioned on
overflow of the original low register, preserving disjoint spectators. -/
theorem join (lo hi : List (W n)) (dis : lo.Disjoint hi) {l h : ℕ}
    (low : incrementSpec lo none l)
    (high : ∃ f : Reg n → Reg n, Implements f h ∧ confined hi f ∧
      ∀s,val hi.length hi (f s)=val hi.length hi s+((lo.all s).toNat:Z hi.length)) :
    incrementSpec (lo++hi) none (h+l) := by
  obtain ⟨f,F,FS,FA⟩ := high
  obtain ⟨g,G,GS,GA⟩ := low
  refine ⟨g ∘ f,compose F G,fun s i un => ?_,fun s => ?_⟩
  · have both := not_or.mp (List.mem_append.not.mp un)
    exact (GS (f s) i both.1).trans (FS s i both.2)
  · let v := f s
    let u := g v
    let k := (lo++hi).length
    let X := BorrowedRipple.read s lo
    let Y := BorrowedRipple.read s hi
    let A : ℕ := 2^lo.length
    let B : ℕ := 2^hi.length
    have lSame : BorrowedRipple.read v lo = X :=
      read_eq lo (fun i e => FS s i (List.disjoint_left.mp dis e))
    have hSame : BorrowedRipple.read u hi = BorrowedRipple.read v hi :=
      read_eq hi (fun i e => GS v i (List.disjoint_right.mp dis e))
    have lSum := modular_read (GA v)
    change BorrowedRipple.read u lo = (if true then _ else _) at lSum
    simp only [ite_true,lSame] at lSum
    have hSum := modular_read (FA s)
    change BorrowedRipple.read v hi = (if lo.all s then (if Y+1=B then 0 else Y+1) else Y) at hSum
    have max : lo.all s=true ↔ X+1=A := all_max s lo
    have zer : (A:Z k)*(B:Z k)=0 := by
      dsimp only [A,B]
      simp only [Nat.cast_pow,Nat.cast_ofNat,← pow_add]
      exact (congrArg (fun j : ℕ => (2:Z k)^j) (List.length_append (as:=lo) (bs:=hi)).symm).trans (modulus k)
    simp only [enabled,Option.elim_none,Bool.toNat_true,Nat.cast_one]
    change (BorrowedRipple.read u (lo++hi):Z k)=(BorrowedRipple.read s (lo++hi):Z k)+1
    rw [read_append,read_append,lSum,hSame,hSum]
    change (((if X+1=A then 0 else X+1) + A*(if lo.all s then (if Y+1=B then 0 else Y+1) else Y):ℕ):Z k) =
      ((X+A*Y:ℕ):Z k)+1
    by_cases lx : X+1=A
    · have al := max.mpr lx
      have ex : (X:Z k)+1=A := by simpa using congrArg (fun d : ℕ => (d:Z k)) lx
      by_cases hy : Y+1=B
      · have ey : (Y:Z k)+1=B := by simpa using congrArg (fun d : ℕ => (d:Z k)) hy
        simp [lx,al,hy]
        linear_combination -ex - (A:Z k)*ey - zer
      · simp [lx,al,hy]
        linear_combination -ex
    · have al : lo.all s=false := Bool.eq_false_iff.mpr (fun e => lx (max.mp e))
      simp [lx,al]
      ring

private theorem relax {cs : List (W n)} {z : Option (W n)} {i j} (H : incrementSpec cs z i) (le : i≤j) :
    incrementSpec cs z j := by obtain ⟨f,imp,h⟩ := H; exact ⟨f,weaken imp le,h⟩

theorem emptyInc : incrementSpec ([] : List (W n)) none 0 := by
  refine ⟨id,⟨[],by simp,by simp [Qatlib.Concepts.GateVocabulary.FiniteGateDescription.finiteWordLegal],
    fun s => by simp [Qatlib.Concepts.GateVocabulary.FiniteGateDescription.finiteCodeCircuit]⟩,fun _ _ _ => rfl,?_⟩
  intro s
  change (_:ZMod 1)=_; exact Subsingleton.elim ..

private theorem all_congr (cs : List (W n)) {s v : Reg n} (h : ∀i∈cs,s i=v i) : cs.all s=cs.all v := by
  induction cs with
  | nil => rfl
  | cons a cs ih => simp [h a (by simp),ih (fun i e => h i (by simp [e]))]

theorem evenHalves (lo hi : List (W n)) (z : W n) (same : lo.length=hi.length) (pos : 0<lo.length)
    (nd : (z::(lo++hi)).Nodup) : incrementSpec (lo++hi) none (600*(lo.length+2)) := by
  have ndparts := List.nodup_append'.mp (List.nodup_cons.mp nd).2
  have cz := (List.nodup_cons.mp nd).1
  have reverseParts : (hi++lo).Nodup := List.nodup_append'.mpr ⟨ndparts.2.1,ndparts.1,ndparts.2.2.symm⟩
  have hpos : 0<hi.length := same ▸ pos
  have controlled := manyOn hi lo (some z) same.symm hpos reverseParts (by
    intro i e h; have iz : i=z := (Option.mem_some_iff.mp e).symm; subst i
    exact cz (List.mem_append.mpr ((List.mem_append.mp h).symm)))
  obtain ⟨ds,t,hh⟩ := target_snoc hi hpos
  have first : t∈hi := by rw [hh]; simp
  have fresh : (t::z::lo).Nodup := by
    have tl : t∉lo := List.disjoint_right.mp ndparts.2.2 first
    simp only [List.nodup_cons,List.mem_cons,not_or]
    exact ⟨⟨fun eq => cz (List.mem_append.mpr (Or.inr (eq ▸ first))),tl⟩,
      fun e => cz (List.mem_append.mpr (Or.inl e)),ndparts.1⟩
  have mcx := borrowedMCX lo z t fresh
  have hzc : (z::hi).Nodup := List.nodup_cons.mpr ⟨fun e => cz (List.mem_append.mpr (Or.inr e)),ndparts.2.1⟩
  have high := transferredControl hi z hzc (fun s => lo.all s) (fun s v eq =>
    all_congr lo (fun i e => eq i (List.disjoint_left.mp ndparts.2.2 e) (fun iz =>
      cz (List.mem_append.mpr (Or.inl (iz ▸ e)))))) controlled mcx
  have low := manyOn lo hi none same pos (List.nodup_cons.mp nd).2 (by simp)
  exact relax (join lo hi ndparts.2.2 low high) (by omega)

theorem evenWidth (cs : List (W n)) (z : W n) (even : cs.length%2=0) (nd : (z::cs).Nodup) :
    incrementSpec cs none (600*(cs.length+2)) := by
  by_cases pos : cs.length=0
  · have emp : cs=[] := List.length_eq_zero_iff.mp pos
    subst cs; exact relax emptyInc (by omega)
  let l := cs.length/2
  let lo := cs.take l
  let hi := cs.drop l
  have eq : lo++hi=cs := List.take_append_drop _ _
  have lengthL : lo.length=l := by simp [lo,l]; omega
  have lengthH : hi.length=l := by simp [hi,l]; omega
  have cert := evenHalves lo hi z (lengthL.trans lengthH.symm) (by dsimp [l] at *; omega) (eq.symm ▸ nd)
  rw [eq] at cert
  exact relax cert (by dsimp [l] at *; omega)

/-- One borrowed wire suffices for an exact linear-sized classical increment.
Odd widths peel the high-order flip before the balanced even-width circuit.
All counts on the right are physical 1- or 2-qubit finite-gate instructions. -/
theorem oneDirty (cs : List (W n)) (z : W n) (nd : (z::cs).Nodup) :
    incrementSpec cs none (720*(cs.length+3)) := by
  by_cases even : cs.length%2=0
  · exact relax (evenWidth cs z even nd) (by omega)
  have pos : 0<cs.length := by omega
  obtain ⟨xs,t,rfl⟩ := target_snoc cs pos
  simp only [List.length_append,List.length_singleton] at even
  have lowerEven : xs.length%2=0 := by omega
  have parts := List.nodup_append'.mp (List.nodup_cons.mp nd).2
  have fresh := (List.nodup_cons.mp nd).1
  have h : (z::t::xs).Nodup := by
    simp only [List.nodup_cons,List.mem_cons,not_or]
    exact ⟨⟨fun eq => fresh (by simp [eq]),fun e => fresh (by simp [e])⟩,
      fun e => List.disjoint_left.mp parts.2.2 e (by simp),parts.1⟩
  have mcx := borrowedMCX xs t z h
  let f s := BorrowedControls.flip t (xs.all s) s
  have high : ∃ f : Reg n → Reg n, Implements f (120*(xs.length+3)) ∧ confined [t] f ∧
      ∀s,val [t].length [t] (f s)=val [t].length [t] s+((xs.all s).toNat:Z [t].length) := by
    refine ⟨f,mcx,fun s i ne => Function.update_of_ne (by simpa using ne) _ _,?_⟩
    intro s
    have two : (2:Z 1)=0 := by simpa using modulus 1
    simp only [val,BorrowedRipple.read,f,BorrowedControls.flip,Function.update_self,mul_zero,add_zero]
    change (((s t ^^ xs.all s).toNat:ℕ):Z 1)=((s t).toNat:Z 1)+((xs.all s).toNat:Z 1)
    cases s t <;> cases xs.all s <;> norm_num
    simpa using two.symm
  have low := evenWidth xs z lowerEven
    (List.nodup_cons.mpr ⟨fun e => fresh (by simp [e]),parts.1⟩)
  exact relax (join xs [t] parts.2.2 low high) (by simp; omega)

end FQChemQatlib.Dynamics.HalvedIncrement
