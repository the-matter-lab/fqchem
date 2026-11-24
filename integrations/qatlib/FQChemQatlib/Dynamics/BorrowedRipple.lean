module

public import FQChemQatlib.Dynamics.BorrowedControls
import Mathlib.Tactic

/-! # A linear circuit for addition with a borrowed input carry

For a list of (addend,target) wires in little-endian order, a majority cascade
writes each carry into the restored addend wires. The return cascade writes
the sum bits. One final CNOT adds the outgoing carry to the extra target bit.
All other bits, including the incoming carry of either value, are restored.

The majority and unmajority blocks follow [Cuccaro et al., §2](https://arxiv.org/abs/quant-ph/0410184). The addressed Toffoli and borrowed-control decompositions use [Barenco et al., §VII](https://doi.org/10.1103/PhysRevA.52.3457).
-/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.BorrowedRipple

open FQChemQatlib.Dynamics.BorrowedControls
abbrev Reg (n : ℕ) := Fin n → Bool
variable {n : ℕ}
abbrev P (n : ℕ) := W n × W n

def maj (a b c : Bool) := (a && b) || (a && c) || (b && c)

def prepare (a b c : W n) (s : Reg n) : Reg n :=
  Function.update (Function.update (Function.update s a (maj (s a) (s b) (s c))) b (s b ^^ s a)) c (s c ^^ s a)

def finish (a b c : W n) (s : Reg n) : Reg n :=
  let a' := s a ^^ (s b && s c)
  let c' := s c ^^ a'
  Function.update (Function.update (Function.update s a a') b (s b ^^ c')) c c'

private theorem prepare_action (a b c : W n) (ab : a≠b) (ac : a≠c) (bc : b≠c) :
    Implements (prepare a b c) 17 := by
  have seq := compose (compose (controlledBit a b ab) (controlledBit a c ac)) (toff b c a bc ab.symm ac.symm)
  have eq : (fun s : Reg n => BorrowedControls.flip a (s b && s c) s) ∘
      ((fun s : Reg n => BorrowedControls.flip c (s a) s) ∘ (fun s : Reg n => BorrowedControls.flip b (s a) s))=prepare a b c := by
    have ba := ab.symm
    have ca := ac.symm
    have cb := bc.symm
    funext s i
    by_cases ia : i=a <;> by_cases ib : i=b <;> by_cases ic : i=c <;>
      simp_all [BorrowedControls.flip,prepare,Function.update_apply,Function.comp_apply,maj]
    cases s a <;> cases s b <;> cases s c <;> rfl
  exact eq ▸ seq

private theorem finish_action (a b c : W n) (ab : a≠b) (ac : a≠c) (bc : b≠c) :
    Implements (finish a b c) 17 := by
  have seq := compose (compose (toff b c a bc ab.symm ac.symm) (controlledBit a c ac)) (controlledBit c b bc.symm)
  have eq : (fun s : Reg n => BorrowedControls.flip b (s c) s) ∘
      ((fun s : Reg n => BorrowedControls.flip c (s a) s) ∘ (fun s : Reg n => BorrowedControls.flip a (s b && s c) s))=finish a b c := by
    have ba := ab.symm
    have ca := ac.symm
    have cb := bc.symm
    funext s i
    by_cases ia : i=a <;> by_cases ib : i=b <;> by_cases ic : i=c <;>
      simp_all [BorrowedControls.flip,finish,Function.comp_apply]
  exact eq ▸ seq

/-- Physical edge-to-edge recursion. The carry for the next layer is stored
in the first addend wire after the majority step. -/
def action (t : W n) : List (P n) → W n → Reg n → Reg n
  | [],c,s => BorrowedControls.flip t (s c) s
  | (a,b)::p,c,s => finish a b c (action t p a (prepare a b c s))

def wires (p : List (P n)) := p.flatMap fun e => [e.1,e.2]

theorem circuit (t c : W n) (p : List (P n)) (valid : (c::t::wires p).Nodup) :
    Implements (action t p c) (34*p.length+1) := by
  induction p generalizing c with
  | nil =>
    simpa [action] using controlledBit c t (by simpa [wires] using valid)
  | cons ab p ih =>
    obtain ⟨a,b⟩ := ab
    have h : (c::t::a::b::wires p).Nodup := valid
    simp only [List.nodup_cons,List.mem_cons,not_or] at h
    have recur := ih a (by simp [List.nodup_cons]; grind)
    have M := prepare_action a b c (by grind) (by grind) (by grind)
    have U := finish_action a b c (by grind) (by grind) (by grind)
    exact weaken (compose (compose M recur) U) (by simp; omega)

/-- Read the bits of one register in little-endian order. -/
def read (s : Reg n) : List (W n) → ℕ
  | [] => 0
  | a::as => (s a).toNat+2*read s as

private theorem read_congr {s v : Reg n} (p : List (W n)) (h : ∀i∈p,s i=v i) : read s p=read v p := by
  induction p with
  | nil => rfl
  | cons a p ih => simp [read,h a (by simp),ih (fun i hi => h i (by simp [hi]))]

theorem member (p : List (P n)) {i : W n} : i ∈ wires p ↔ i ∈ p.map Prod.fst ∨ i ∈ p.map Prod.snd := by
  induction p with
  | nil => simp [wires]
  | cons x p ih => change (i ∈ x.1::x.2::wires p) ↔ _; simp only [List.map_cons,List.mem_cons,ih]; tauto

theorem restored (t c : W n) (p : List (P n)) (valid : (c::t::wires p).Nodup) (s : Reg n) :
    ∀ i, i≠t → i∉p.map Prod.snd → action t p c s i=s i := by
  induction p generalizing c s with
  | nil => intro i ht _; exact Function.update_of_ne ht _ _
  | cons ab p ih =>
    obtain ⟨a,b⟩ := ab
    have h : (c::t::a::b::wires p).Nodup := valid
    simp only [List.nodup_cons,List.mem_cons,not_or] at h
    have stay :=  ih a (by simp [List.nodup_cons]; grind) (prepare a b c s)
    have same (i : W n) (hi : i≠t) (hu : i∉wires p) : action t p a (prepare a b c s) i=prepare a b c s i :=
      stay i hi (fun e => hu ((member p).mpr (Or.inr e)))
    let v := action t p a (prepare a b c s)
    have sA : v a=maj (s a) (s b) (s c) := (same a (by grind) (by grind)).trans (by simp only [prepare,Function.update_apply]; grind)
    have sB : v b=(s b ^^ s a) := (same b (by grind) (by grind)).trans (by simp only [prepare,Function.update_apply]; grind)
    have sC : v c=(s c ^^ s a) := (same c (by grind) (by grind)).trans (by simp only [prepare,Function.update_apply]; grind)
    have first : (v a ^^ (v b && v c))=s a := by
      rw [sA,sB,sC]; cases s a <;> cases s b <;> cases s c <;> rfl
    have third : (v c ^^ s a)=s c := by rw [sC]; simp
    intro i ht hi
    simp only [List.map_cons,List.mem_cons,not_or] at hi
    change finish a b c v i = s i
    simp only [finish,first,third,Function.update_apply,ite_eq_right hi.1]
    split_ifs with ic ia
    · rw [ic]
    · rw [ia]
    · change action t p a (prepare a b c s) i=s i
      rw [stay i ht hi.2]
      simp [prepare,ic,ia,hi.1]
private theorem innerWires (t c a b : W n) (p : List (P n))
    (valid : (c::t::wires ((a,b)::p)).Nodup) (s : Reg n) :
    let u := prepare a b c s
    let v := action t p a u
    v a = maj (s a) (s b) (s c) ∧ v b = (s b ^^ s a) ∧ v c = (s c ^^ s a) := by
  intro u v
  change (c::t::a::b::wires p).Nodup at valid
  simp only [List.nodup_cons,List.mem_cons,not_or] at valid
  have nd : (a::t::wires p).Nodup := by simp [List.nodup_cons]; grind
  have fix (i : W n) (it : i≠t) (hi : i∉wires p) : v i=u i :=
    restored t a p nd u i it (fun e => hi ((member p).mpr (Or.inr e)))
  rw [fix a (by grind) (by grind),fix b (by grind) (by grind),fix c (by grind) (by grind)]
  simp only [u,prepare,Function.update_apply]
  grind

/-- The sum of the target bits and the outgoing carry is exactly the sum of
the two low registers and the incoming carry. The high target is XORed with
the outgoing carry, so its initial value can be arbitrary. -/
theorem arithmetic (t c : W n) (p : List (P n)) (valid : (c::t::wires p).Nodup) (s : Reg n) :
    let v := action t p c s
    read v (p.map Prod.snd) + 2^p.length*(v t ^^ s t).toNat =
      read s (p.map Prod.snd)+read s (p.map Prod.fst)+(s c).toNat := by
  dsimp only
  induction p generalizing c s with
  | nil =>
    simp only [List.map_nil,read,List.length_nil,pow_zero,one_mul,zero_add,action,
      BorrowedControls.flip,Function.update_self]
    cases s t <;> cases s c <;> rfl
  | cons ab p ih =>
    obtain ⟨a,b⟩ := ab
    have h : (c::t::a::b::wires p).Nodup := valid
    simp only [List.nodup_cons,List.mem_cons,not_or] at h
    let u := prepare a b c s
    let v := action t p a u
    let out := finish a b c v
    have val := ih a (by simp [List.nodup_cons]; grind) u
    have ⟨a0,b0,c0⟩ := innerWires t c a b p valid s
    change v a = _ at a0
    change v b = _ at b0
    change v c = _ at c0
    have u0 : u a=maj (s a) (s b) (s c) := by simp only [u,prepare,Function.update_apply]; grind
    have keepU (i : W n) (ia : i≠a) (ib : i≠b) (ic : i≠c) : u i=s i := by simp [u,prepare,ia,ib,ic]
    have keepO (i : W n) (ia : i≠a) (ib : i≠b) (ic : i≠c) : out i=v i := by simp [out,finish,ia,ib,ic]
    have transferU (i : W n) (hi : i ∈ wires p) : u i=s i := keepU i (by grind) (by grind) (by grind)
    have transferO (i : W n) (hi : i ∈ wires p) : out i=v i := keepO i (by grind) (by grind) (by grind)
    have su := read_congr (p.map Prod.snd) (fun i e => transferU i ((member p).mpr (Or.inr e)))
    have au := read_congr (p.map Prod.fst) (fun i e => transferU i ((member p).mpr (Or.inl e)))
    have so := read_congr (p.map Prod.snd) (fun i e => transferO i ((member p).mpr (Or.inr e)))
    have bt : out b=(s a ^^ s b ^^ s c) := by
      simp only [out,finish,Function.update_apply,a0,b0,c0]
      rw [ite_eq_right (by grind : b≠c),ite_true]
      cases s a <;> cases s b <;> cases s c <;> rfl
    have ma (x y z : Bool) : (x ^^ y ^^ z).toNat + 2*(maj x y z).toNat=x.toNat+y.toNat+z.toNat := by
      cases x <;> cases y <;> cases z <;> rfl
    change read v (p.map Prod.snd)+2^p.length*(v t ^^ u t).toNat= _ at val
    rw [u0,su,au,keepU t (by grind) (by grind) (by grind)] at val
    simp only [List.map_cons,read,List.length_cons]
    change (out b).toNat + 2*read out _ + 2^(p.length+1)*(out t ^^ s t).toNat = _
    rw [bt,so,keepO t (by grind) (by grind) (by grind),pow_succ]
    nlinarith only [val,ma (s a) (s b) (s c)]

end FQChemQatlib.Dynamics.BorrowedRipple
