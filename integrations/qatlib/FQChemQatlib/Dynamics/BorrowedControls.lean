module

public import Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermal.FiniteThermalToffoli
import Qatlib.Concepts.QmaCompleteness.HistoryHam.QmaCompletenessDefs
import Mathlib.Tactic

/-! # Linear-size multiply controlled gates with borrowed wires

Barenco et al., Lemmas 7.2–7.3, compile a multiply controlled NOT by toggling
and restoring workspace with unknown initial contents. The gate count below
counts one- and two-qubit instructions, and the basis action has no relative phases.
-/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.BorrowedControls

open Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Concepts.GateVocabulary.LocalReflectionGates
open Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermalCircuits
open Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Foundations.QueryWordCore.Circuit Qatlib.Foundations.PureStateMath
open scoped Classical

variable {n : ℕ}
abbrev W (n : ℕ) := Fin n
def flip (t : W n) (b : Bool) (s : Reg n) := Function.update s t (s t ^^ b)

/-- An instruction sequence on exactly n physical wires with verified basis action. -/
def Implements (f : Reg n → Reg n) (k : ℕ) : Prop :=
  ∃ gs : List FiniteGateCode, gs.length ≤ k ∧ finiteWordLegal n gs = true ∧
    ∀ s, Run 1 (finiteCodeCircuit n gs) (Ket s) = Ket (f s)

theorem compose {f g : Reg n → Reg n} {k l : ℕ}
    (a : Implements f k) (b : Implements g l) : Implements (g ∘ f) (k+l) := by
  obtain ⟨u,hu,lu,au⟩ := a
  obtain ⟨v,hv,lv,av⟩ := b
  exact ⟨u++v,by simp; omega,by simpa [finiteWordLegal] using And.intro lu lv,
    fun s => by rw [show finiteCodeCircuit n (u++v) = finiteCodeCircuit n u ++ finiteCodeCircuit n v by simp [finiteCodeCircuit],run_append,au,av]; rfl⟩

theorem weaken {f : Reg n → Reg n} {k l : ℕ} (a : Implements f k) (le : k≤l) :
    Implements f l := by obtain ⟨u,hu,h⟩ := a; exact ⟨u,hu.trans le,h⟩

theorem toff (a b t : W n) (hab : a≠b) (hat : a≠t) (hbt : b≠t) :
    Implements (fun s => flip t (s a && s b) s) 15 := by
  have ab : a.val ≠ b.val := fun h => hab (Fin.ext h)
  have at' : a.val ≠ t.val := fun h => hat (Fin.ext h)
  have bt : b.val ≠ t.val := fun h => hbt (Fin.ext h)
  have legal : finiteWordLegal n (thermalToffoliWord a b t) = true := by
    simp [thermalToffoliWord,finiteWordLegal,finiteCodeLegal,ab,at',bt]
  exact ⟨thermalToffoliWord a b t,by exact Nat.le_refl 15,legal,fun s => by
    simpa [finiteWordRun,legal,flip] using (thermalToffoliWord_exact n a b t hab hat hbt s).1⟩

theorem bit (t : W n) :
    Implements (fun s => flip t true s) 1 := by
  refine ⟨[.x t],by simp,by simp [finiteWordLegal,finiteCodeLegal],?_⟩
  intro s
  simp only [finiteCodeCircuit,List.map_cons,List.map_nil,run_gate,run_nil,finiteCodeMatrix,
    dite_eq_left t.isLt,applyGate_wireGate_ket]
  cases h : s t <;> simp [PauliX,permMatrix,Matrix.of_apply,flip,h]

theorem controlledBit (a t : W n) (h : a≠t) :
    Implements (fun s => flip t (s a) s) 1 := by
  have av : a.val ≠ t.val := fun e => h (Fin.ext e)
  refine ⟨[.cx a t],by simp,by simp [finiteWordLegal,finiteCodeLegal,av],?_⟩
  intro s
  simp [finiteCodeCircuit,finiteCodeMatrix,a.isLt,t.isLt,av,applyGate_cnotGate_ket,
    flip,h]

variable {W' : Type*}

/-- Read a carry through arbitrary scratch bits. Each pair gives a control
and the borrowed wire into which the carry is temporarily added. -/
private def carry (s : W' → Bool) (last : W') : List (W' × W') → Bool → Bool
  | [],v => v && s last
  | (a,b)::p,v => carry s last p (s b ^^ (v && s a))

private theorem carry_congr {s u : W' → Bool} {last : W'} (p : List (W' × W'))
    (hl : s last=u last) (same : ∀ a b, (a,b)∈p → s a=u a ∧ s b=u b) (v : Bool) :
    carry s last p v = carry u last p v := by
  induction p generalizing v with
  | nil => simp [carry,hl]
  | cons ab p ih =>
    rcases ab with ⟨a,b⟩
    obtain ⟨ha,hb⟩ := same a b (by simp)
    simp only [carry,ha,hb]
    exact ih (fun a b h => same a b (by simp [h])) _

private theorem carry_xor (s : W' → Bool) (last : W') (p : List (W' × W')) (v b : Bool) :
    carry s last p (v ^^ b) = (carry s last p v ^^ (b && (p.map Prod.fst).all s && s last)) := by
  induction p generalizing v b with
  | nil => simp [carry,Bool.and_xor_distrib_right]
  | cons ab p ih =>
    rcases ab with ⟨a,z⟩
    simp only [carry,Bool.and_xor_distrib_right,← Bool.xor_assoc,List.map_cons,List.all_cons]
    rw [ih]
    cases b <;> cases s a <;> cases s last <;> cases (p.map Prod.fst).all s <;> simp

private theorem restore (z t : W n) (hz : z≠t) (a b : Bool) (s : Reg n) :
    flip z a (flip t b (flip z a s)) = flip t b s := by
  funext i
  by_cases h : i=z <;> by_cases k : i=t <;>
    simp_all [flip,Function.update_apply]

/-- Use a borrowed control twice. The two toggles cancel its initial value,
leaving just the change in the target predicate. -/
private theorem toggleDifference (z t : W n) (hz : z≠t) (A E B : Reg n → Bool)
    (az : ∀ s b, A (flip z b s) = A s) (at' : ∀ s b, A (flip t b s) = A s)
    (et : ∀ s b, E (flip t b s) = E s)
    (change : ∀ s, E (flip z (A s) s) = (E s ^^ B s))
    {k l : ℕ} (g : Implements (fun s => flip z (A s) s) k)
    (h : Implements (fun s => flip t (E s) s) l) :
    Implements (fun s => flip t (B s) s) (2*(k+l)) := by
  have eq : (fun s => flip t (E s) s) ∘ ((fun s => flip z (A s) s) ∘
      ((fun s => flip t (E s) s) ∘ (fun s => flip z (A s) s))) = fun s => flip t (B s) s := by
    funext s i
    simp only [Function.comp_apply,at',az,restore z t hz,et,change]
    by_cases hi : i=t <;> simp_all [flip,Function.update_apply,Bool.xor_comm]
    all_goals cases s t <;> cases E s <;> cases B s <;> rfl
  exact weaken (eq ▸ compose (compose (compose g h) g) h) (by omega)

private theorem allFlip (ws : List (W n)) {i : W n} (h : i∉ws) (s : Reg n) (b : Bool) :
    ws.all (flip i b s) = ws.all s := by
  induction ws with
  | nil => rfl
  | cons a ws ih =>
    simp only [List.mem_cons,not_or] at h
    simp only [List.all_cons,ih h.2]; rw [show flip i b s a = s a from Function.update_of_ne (Ne.symm h.1) _ _]

private theorem carryFlip (last i : W n) (p : List (W n × W n))
    (hl : last≠i) (hc : i ∉ p.map Prod.fst) (hd : i ∉ p.map Prod.snd) (s : Reg n) (b v : Bool) :
    carry (flip i b s) last p v = carry s last p v := by
  apply carry_congr
  · exact Function.update_of_ne hl _ _
  · intro j k h
    have h1 : j≠i := by rintro rfl; exact hc (List.mem_map.mpr ⟨(j,k),h,rfl⟩)
    have h2 : k≠i := by rintro rfl; exact hd (List.mem_map.mpr ⟨(j,k),h,rfl⟩)
    exact ⟨Function.update_of_ne h1 _ _,Function.update_of_ne h2 _ _⟩

/-- Pass down the chain, toggle the output, then reverse the chain. -/
private theorem readCarry (seed last t : W n) (p : List (W n × W n))
    (valid : (seed::last::t::(p.map Prod.fst ++ p.map Prod.snd)).Nodup) :
    Implements (fun s => flip t (carry s last p (s seed)) s) (15*(2*p.length+1)) := by
  induction p generalizing seed with
  | nil =>
    simp only [List.map_nil, List.append_nil, List.nodup_cons, List.mem_cons, List.not_mem_nil,
      or_false, not_or, List.nodup_nil, and_true, not_false_eq_true] at valid
    simpa [carry] using toff seed last t valid.1.1 valid.1.2 valid.2
  | cons ab p ih =>
    obtain ⟨a,z⟩ := ab
    -- Move the new scratch wire next to its control before taking the induction tail.
    have ordered : (seed :: last :: t :: a :: z :: (p.map Prod.fst ++ p.map Prod.snd)).Nodup :=
      ((((List.perm_middle.cons a).cons t).cons last).cons seed).nodup valid
    simp only [List.nodup_cons, List.mem_cons, not_or] at ordered
    obtain ⟨⟨_, st, sa, sz, _⟩, ⟨lt, _, lz, lastTail⟩, ⟨ta, tz, targetTail⟩,
      ⟨az, _⟩, scratchTail, tail⟩ := ordered
    have smaller : (z :: last :: t :: (p.map Prod.fst ++ p.map Prod.snd)).Nodup := by
      simp only [List.nodup_cons, List.mem_cons, not_or]
      exact ⟨⟨Ne.symm lz, Ne.symm tz, scratchTail⟩, ⟨lt, lastTail⟩, targetTail, tail⟩
    obtain ⟨freshControls, freshScratch⟩ := by
      simpa only [List.mem_append, not_or] using scratchTail
    have same (s : Reg n) : carry (flip z (s seed && s a) s) last p
        ((flip z (s seed && s a) s) z) = carry s last ((a,z)::p) (s seed) := by
      simp only [carry, flip, Function.update_self]
      exact carryFlip last z p lz freshControls freshScratch s _ _
    have eq : (fun s : Reg n => flip z (s seed && s a) s) ∘
        ((fun s : Reg n => flip t (carry s last p (s z)) s) ∘
          (fun s => flip z (s seed && s a) s)) =
        fun s => flip t (carry s last ((a,z)::p) (s seed)) s := by
      funext s
      simp only [Function.comp_apply, same]
      have keep (i : W n) (iz : i ≠ z) (it : i ≠ t) (outer inner : Bool) :
          flip t outer (flip z inner s) i = s i :=
        (Function.update_of_ne it _ _).trans (Function.update_of_ne iz _ _)
      rw [keep seed sz st, keep a az (Ne.symm ta)]
      exact restore z t (Ne.symm tz) _ _ s
    have gate := toff seed a z sa sz az
    exact weaken (eq ▸ compose (compose gate (ih z smaller)) gate) (by simp; omega)

/-- A chain with two seed controls and one final control uses one borrowed
wire for each control beyond the first two. -/
private theorem manyFromPath (a b last z t : W n) (p : List (W n × W n))
    (valid : (a::b::z::last::t::(p.map Prod.fst ++ p.map Prod.snd)).Nodup) :
    Implements (fun s => flip t ((a::b::last::p.map Prod.fst).all s) s) (60*(p.length+1)) := by
  have core := readCarry z last t p valid.of_cons.of_cons
  simp only [List.nodup_cons,List.mem_cons,List.mem_append,not_or] at valid
  let A := fun s : Reg n => s a && s b
  let E := fun s : Reg n => carry s last p (s z)
  apply weaken (toggleDifference z t (by grind) A E _ _ _ _ _ (toff a b z (by grind) (by grind) (by grind)) core)
  · omega
  · intro s k; simp [A,flip,Function.update_of_ne (show a≠z by grind),Function.update_of_ne (show b≠z by grind)]
  · intro s k; simp [A,flip,Function.update_of_ne (show a≠t by grind),Function.update_of_ne (show b≠t by grind)]
  · intro s k
    change carry (flip t k s) last p ((flip t k s) z) = _
    rw [carryFlip last t p (by grind) (by grind) (by grind)]
    simp [E,flip,Function.update_of_ne (show z≠t by grind)]
  · intro s
    change carry (flip z (A s) s) last p ((flip z (A s) s) z) = _
    rw [carryFlip last z p (by grind) (by grind) (by grind)]
    simp only [flip,Function.update_self,carry_xor,E,A,List.all_cons]
    cases s a <;> cases s b <;> cases s last <;> cases (p.map Prod.fst).all s <;> simp

private theorem zipNames {α : Type*} (cs ds : List α) (enough : cs.length ≤ ds.length) :
    (cs.zip ds).map Prod.fst = cs ∧ List.Sublist ((cs.zip ds).map Prod.snd) ds := by
  induction cs generalizing ds with
  | nil => simp
  | cons a cs ih =>
    cases ds with
    | nil => simp at enough
    | cons z ds =>
      obtain ⟨left,right⟩ := ih ds (by simpa using enough)
      exact ⟨by simp [left],List.Sublist.cons_cons _ right⟩

/-- Multi-controlled X using a list of borrowed wires. All workspace is restored. -/
private theorem many (cs ds : List (W n)) (t : W n) (enough : cs.length ≤ ds.length+2)
    (valid : (t::(cs++ds)).Nodup) :
    Implements (fun s => flip t (cs.all s) s) (60*(cs.length+1)) := by
  match cs with
  | [] => exact weaken (bit t) (by simp)
  | [a] =>
    simpa using weaken (controlledBit a t (by grind [List.nodup_cons])) (show 1 ≤ 60*(1+1) by decide)
  | [a,b] =>
    simpa using weaken (toff a b t (by grind [List.nodup_cons]) (by grind [List.nodup_cons])
      (by grind [List.nodup_cons])) (show 15 ≤ 60*(2+1) by decide)
  | a::b::last::cs =>
    cases ds with
    | nil => simp at enough
    | cons z ds =>
      have ⟨left,right⟩ := zipNames cs ds (by simp at enough; omega)
      have shorter : (t::(a::b::last::cs ++ z::(cs.zip ds).map Prod.snd)).Nodup :=
        List.Pairwise.sublist (List.Sublist.cons_cons _ ((List.Sublist.cons_cons z right).append_left (a::b::last::cs))) valid
      have ordered : (a::b::z::last::t::((cs.zip ds).map Prod.fst ++ (cs.zip ds).map Prod.snd)).Nodup := by
        rw [left]
        simp only [List.cons_append,List.nodup_cons,List.mem_cons,List.mem_append,not_or,
          List.nodup_append',List.disjoint_cons_right] at shorter ⊢
        grind [List.disjoint_left]
      have g := manyFromPath a b last z t (cs.zip ds) ordered
      rw [left] at g
      exact weaken g (by simp)

/-- An exact multiply controlled NOT on any list of controls with just one
borrowed wire. The executable gate sequence uses at most 120(k+3) local
Clifford+T instructions for k controls; it restores every other wire. -/
theorem borrowedMCX (cs : List (W n)) (target scratch : W n)
    (fresh : (scratch::target::cs).Nodup) :
    Implements (fun s => flip target (cs.all s) s) (120*(cs.length+3)) := by
  let left := cs.take (cs.length/2)
  let right := cs.drop (cs.length/2)
  have join : left++right=cs := List.take_append_drop _ _
  have l : left.length=cs.length/2 := by simp [left]; omega
  have r : right.length=cs.length-cs.length/2 := by simp [right]
  have dis : (scratch::target::(left++right)).Nodup := join ▸ fresh
  simp only [List.nodup_cons,List.mem_cons,List.mem_append,not_or,List.nodup_append'] at dis
  have ga := many left right scratch (by omega) (by simp [List.nodup_cons,List.nodup_append']; tauto)
  have gb := many (scratch::right) left target (by simp; omega) (by
    simp only [List.cons_append,List.nodup_cons,List.mem_cons,List.mem_append,not_or,List.nodup_append']
    grind [List.disjoint_left])
  let A := fun s : Reg n => left.all s
  let E := fun s : Reg n => (scratch::right).all s
  apply weaken (toggleDifference scratch target (by tauto) A E _ _ _ _ _ ga gb)
  · simp only [List.length_cons]; omega
  · exact allFlip left (by tauto)
  · exact allFlip left (by tauto)
  · apply allFlip; simp; grind
  · intro s
    simp only [E,List.all_cons]
    rw [allFlip right (show scratch∉right by tauto)]
    simp only [flip,Function.update_self]
    rw [← join,List.all_append]
    simp only [A,Bool.and_xor_distrib_right]

/-- Linearity upgrades the basis permutation to its exact action on every
input state, including a borrowed qubit entangled with the controls or output. -/
theorem coherentMCX (cs : List (W n)) (target scratch : W n)
    (fresh : (scratch::target::cs).Nodup) :
    ∃ gs : List FiniteGateCode, gs.length ≤ 120*(cs.length+3) ∧ finiteWordLegal n gs = true ∧
      ∀ ψ : QState (Reg n), Run 1 (finiteCodeCircuit n gs) ψ =
        ∑ s, ψ s • Ket (flip target (cs.all s) s) := by
  obtain ⟨gs,len,legal,basis⟩ := borrowedMCX cs target scratch fresh
  refine ⟨gs,len,legal,fun ψ => ?_⟩
  have expansion : ψ = ∑ s, ψ s • Ket s := by funext i; simp [Qatlib.Foundations.PureStateMath.Ket,Finset.sum_apply]
  simp only [run_finiteCodeCircuit] at basis ⊢
  conv_lhs => rw [expansion,Matrix.mulVec_sum]
  simp only [Matrix.mulVec_smul,basis]

end FQChemQatlib.Dynamics.BorrowedControls
