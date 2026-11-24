module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.GateRouting
public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.SchmidtSimulation

/-! # Physical Schmidt-rank promises for arbitrary qubit pairs
Every bipartition is a prefix cut in a suitable ordering of the wires. Vidal's χ
therefore bounds the physical cuts after every permutation. This is the property
needed at the artificial intermediate steps of an adjacent SWAP compilation. -/

@[expose] public section
namespace FQChem.Algorithms.MPSCircuit.Routing

open Matrix
variable {K : Type*} [Field K]

def digit : {n : ℕ} → Bits n → Fin n → Fin 2
  | 0, _, i => Fin.elim0 i
  | _+1, (a,x), i => Fin.cases a (digit x) i

def tabulate : (n : ℕ) → (Fin n → Fin 2) → Bits n
  | 0, _ => ()
  | n+1, f => (f 0, tabulate n (Fin.tail f))

theorem digit_tabulate (n : ℕ) (f : Fin n → Fin 2) (i : Fin n) :
    digit (n:=n) (tabulate n f) i = f i := by
  induction n with
  | zero => exact Fin.elim0 i
  | succ n ih => exact Fin.cases rfl (fun j => ih (Fin.tail f) j) i

theorem tabulate_digit (n : ℕ) (x : Bits n) : tabulate n (digit x) = x := by
  induction n with
  | zero => rfl
  | succ n ih => rcases x with ⟨a,x⟩; exact congrArg (fun y => (a,y)) (ih x)

/-- Physical coordinates touched by one adjacent wire exchange. -/
def Bond.index : {n : ℕ} → Bond n → Fin n → Fin n
  | _, .head => Fin.cases 1 (Fin.cases 0 (fun i => i.succ.succ))
  | _, .tail b => Fin.cases 0 (fun i => (b.index i).succ)

theorem Bond.index_involutive {n : ℕ} (b : Bond n) : Function.Involutive b.index := by
  induction b with
  | head => exact Fin.cases rfl (Fin.cases rfl (fun _ => rfl))
  | tail b ih => exact Fin.cases rfl (fun i => congrArg Fin.succ (ih i))

def Bond.permutation {n : ℕ} (b : Bond n) : Equiv.Perm (Fin n) :=
  ⟨b.index, b.index, b.index_involutive, b.index_involutive⟩

theorem Bond.exchange_digit {n : ℕ} (b : Bond n) (x : Bits n) (i : Fin n) :
    digit (b.exchange x) i = digit x (b.index i) := by
  induction b with
  | head =>
    rcases x with ⟨a,b,x⟩
    exact Fin.cases rfl (Fin.cases rfl (fun _ => rfl)) i
  | tail b ih =>
    rcases x with ⟨a,x⟩
    exact Fin.cases rfl (fun j => ih x j) i

def ordered {n : ℕ} (π : Equiv.Perm (Fin n)) (x : Bits n) : Bits n :=
  tabulate n fun i => digit x (π i)

/-- The rank promise of Vidal Eq. (2), for every bipartition of physical wires.
For each ordering, PhysicalCuts checks all prefix/suffix coefficient matrices. -/
def AllCuts {n : ℕ} (v : Bits n → K) (χ : ℕ) : Prop :=
  ∀ π : Equiv.Perm (Fin n), PhysicalCuts (fun x => v (ordered π x)) χ

theorem AllCuts.physical {n χ : ℕ} {v : Bits n → K} (h : AllCuts v χ) : PhysicalCuts v χ := by
  simpa only [ordered, Equiv.refl_apply, tabulate_digit] using h (Equiv.refl _)

theorem AllCuts.swap {n χ : ℕ} {v : Bits n → K} (h : AllCuts v χ) (b : Bond n) :
    AllCuts ((b.gate swapMatrix).act v) χ := by
  intro π
  have eq (x : Bits n) : b.exchange (ordered π x) = ordered (b.permutation.trans π) x := by
    rw [← tabulate_digit n (b.exchange (ordered π x))]
    apply congrArg (tabulate n)
    funext i
    rw [Bond.exchange_digit]
    exact digit_tabulate n _ _
  simpa only [Bond.swap_act, eq] using h (b.permutation.trans π)

theorem trajectory_append {n χ : ℕ} (a b : List (Gate K n)) (v : Bits n → K)
    (ha : trajectory χ a v) (hb : trajectory χ b (dense a v)) :
    trajectory χ (a++b) v := by
  induction a generalizing v with
  | nil => exact hb
  | cons g a ih => exact ⟨ha.1, ih _ ha.2 hb⟩

/-- A logical gate requires a rank promise only before and after that gate.
Every intermediate SWAP state is a permutation of one of those two states. -/
theorem Route.trajectory {n χ : ℕ} (r : Route n) (G : Matrix Pair Pair K) (v : Bits n → K)
    (hi : AllCuts v χ) (ho : AllCuts (dense (r.gates G) v) χ) :
    trajectory χ (r.gates G) v := by
  induction r generalizing v with
  | direct b => exact ⟨hi.physical, ho.physical⟩
  | via s r ih =>
    let sw := s.gate (swapMatrix (K:=K))
    let mid := dense (r.gates G) (sw.act v)
    have out : dense ((Route.via s r).gates G) v = sw.act mid := by
      simp [Route.gates, dense, dense_append, sw, mid]
    have back : sw.act (sw.act mid) = mid := by
      funext x
      simp [sw, Bond.swap_act, Bond.exchange_twice]
    rw [out] at ho
    have hm : AllCuts (sw.act (sw.act mid)) χ := ho.swap s
    rw [back] at hm
    refine ⟨hi.physical, trajectory_append _ _ _ (ih _ (hi.swap s) hm) ?_⟩
    exact ⟨hm.physical,ho.physical⟩

abbrev Program (K : Type*) (n : ℕ) := List (Address n × Matrix Pair Pair K)

def compile {n : ℕ} (P : Program K n) : List (Gate K n) :=
  P.flatMap (fun (a,G) => a.route.gates G)

def reference {n : ℕ} : Program K n → (Bits n → K) → Bits n → K
  | [], v => v
  | (a,G)::gs, v => reference gs (a.act G v)

/-- Eq. (2) is assumed solely at the physical states of the original program. -/
def promised {n : ℕ} (χ : ℕ) : Program K n → (Bits n → K) → Prop
  | [], v => AllCuts v χ
  | (a,G)::gs, v => AllCuts v χ ∧ promised χ gs (a.act G v)

theorem promised_first {n χ : ℕ} (P : Program K n) (v : Bits n → K) (h : promised χ P v) :
    AllCuts v χ := by
  cases P with
  | nil => exact h
  | cons g gs => exact h.1

theorem compile_exact {n : ℕ} (P : Program K n) (v : Bits n → K) :
    dense (compile P) v = reference P v := by
  induction P generalizing v with
  | nil => rfl
  | cons g gs ih =>
    rcases g with ⟨a,G⟩
    simpa only [compile, List.flatMap_cons, dense_append, Address.exact, reference] using ih (a.act G v)

theorem compile_length {n : ℕ} (P : Program K n) : (compile P).length ≤ P.length*(2*n) := by
  induction P with
  | nil => simp [compile]
  | cons g gs ih =>
    rcases g with ⟨a,G⟩
    change ((a.route.gates G) ++ compile gs).length ≤ (gs.length+1)*(2*n)
    rw [List.length_append, Nat.add_mul, one_mul, Nat.add_comm (gs.length * _) _]
    exact Nat.add_le_add (a.gate_count G) ih

theorem compile_invertible {n : ℕ} (P : Program K n) (h : ∀ g ∈ P, ∃ H, H * g.2 = 1) :
    ∀ g ∈ compile P, g.invertible := by
  intro z hz
  obtain ⟨⟨a,G⟩,hin,hz⟩ := List.mem_flatMap.mp hz
  obtain ⟨H,hg⟩ := h _ hin
  exact a.route.invertible G H hg z hz

theorem compile_trajectory {n χ : ℕ} (P : Program K n) (v : Bits n → K) (h : promised χ P v) :
    trajectory χ (compile P) v := by
  induction P generalizing v with
  | nil => exact h.physical
  | cons g gs ih =>
    rcases g with ⟨a,G⟩
    obtain ⟨hi,hr⟩ := h
    have ht := promised_first gs (a.act G v) hr
    rw [← a.exact G v] at ht
    exact trajectory_append _ _ _ (a.route.trajectory G v hi ht) (by rw [a.exact]; exact ih _ hr)

end FQChem.Algorithms.MPSCircuit.Routing
