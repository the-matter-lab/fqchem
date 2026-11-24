module

public import FQChemQatlib.Dynamics.LowChuangBinaryCompare

/-! # Binary register layout for complex sparse matrix elements -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.Binary

open Qatlib.Foundations.PureStateMath

/-- The five columns hold the uniform word, both input coordinates and their
two clean carry chains. The final three wires are the component selector and
the two carry seeds. -/
abbrev Key (p : ℕ) := (Fin p × Fin 5) ⊕ Fin 3
abbrev size (p : ℕ) := Fintype.card (Key p)
def addr (p : ℕ) := Fintype.equivFin (Key p)
def column (p : ℕ) (role : Fin 5) (i : Fin p) : Fin (size p) := addr p (.inl (i,role))
def extra (p : ℕ) (role : Fin 3) : Fin (size p) := addr p (.inr role)

def digits (p : ℕ) (imag : Bool) : List (Digit (size p)) :=
  List.ofFn fun i : Fin p => ⟨column p 0 i,column p (if imag then 2 else 1) i,
    column p (if imag then 4 else 3) i⟩
def seed (p : ℕ) (imag : Bool) := extra p (if imag then 2 else 1)
def branch (p : ℕ) := extra p 0
def threshold {p : ℕ} (imag : Bool) (x : Reg (size p)) : Reg p :=
  fun i => x (column p (if imag then 2 else 1) i)
def coins {p : ℕ} (x : Reg (size p)) : Reg p := fun i => x (column p 0 i)

theorem digits_valid (p : ℕ) (imag : Bool) : valid (seed p imag) (digits p imag) := by
  unfold valid addresses digits
  rw [List.nodup_cons,List.nodup_flatMap]
  constructor
  · simp [seed,extra,column,List.mem_flatMap,List.mem_ofFn]
  constructor
  · intro d hd
    obtain ⟨i,rfl⟩ := List.mem_ofFn.mp hd
    cases imag <;> simp [column]
  · rw [List.pairwise_ofFn]
    intro i j h
    have distinct : i≠j := h.ne
    cases imag <;> simp [column,List.disjoint_left,distinct]

def randomBits (p : ℕ) : Fin (p+1) ↪ Fin (size p) where
  toFun := Fin.cons (branch p) (column p 0)
  inj' := by
    intro i j
    refine Fin.cases ?_ (fun i => ?_) i <;> refine Fin.cases ?_ (fun j => ?_) j
    · simp
    · simp [branch,extra,column]
    · simp [branch,extra,column]
    · simp [column]

theorem digits_read (p : ℕ) (imag : Bool) (x : Reg (size p)) :
    ((digits p imag).map fun d => x d.left) = List.ofFn (coins x) ∧
    ((digits p imag).map fun d => x d.right) = List.ofFn (threshold imag x) := by
  simp [digits,List.map_ofFn,Function.comp_def]
  exact ⟨rfl,rfl⟩

theorem protect_branch (p : ℕ) (imag : Bool) (x : Reg (size p)) :
    compute (seed p imag) (digits p imag) x (branch p) = x (branch p) := by
  apply unchanged
  simp [digits,branch,extra,column,List.map_ofFn,Function.comp_def,List.mem_ofFn]

end FQChemQatlib.Dynamics.LowChuang.Binary
