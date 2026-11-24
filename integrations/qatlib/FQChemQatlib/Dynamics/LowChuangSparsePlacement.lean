module

public import FQChemQatlib.Dynamics.LowChuangSparseWires
public import FQChemQatlib.Dynamics.LowChuangSparseCartesian

/-! # Physical input-register wiring for sparse simulation -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseWires

open Matrix Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.LocalMachine.LocalTransport Qatlib.Concepts.CopyEvolution.Discriminate
open Qatlib.Concepts.BlockEncoding.LCU
open FQChemQatlib.Dynamics.LowChuang.Query FQChemQatlib.Dynamics.LowChuang.SparseBlock
open scoped Classical

variable {T : Type} [Fintype T] [DecidableEq T] {k n m : ℕ}

def triple (u v w : T) (uv : u≠v) (uw : u≠w) (vw : v≠w) : Fin 3 ↪ T :=
  ⟨![u,v,w],by intro i j h; fin_cases i <;> fin_cases j <;> simp_all [Ne.symm]⟩

omit [Fintype T] [DecidableEq T] in
theorem triple_range (u v w : T) (uv : u≠v) (uw : u≠w) (vw : v≠w) (i:T) :
    i∈Set.range (triple u v w uv uw vw) ↔ i=u ∨ i=v ∨ i=w := by
  constructor
  · rintro ⟨j,rfl⟩; fin_cases j <;> simp [triple]
  · rintro (rfl|rfl|rfl)
    · exact ⟨0,rfl⟩
    · exact ⟨1,rfl⟩
    · exact ⟨2,rfl⟩

/-- On a diagonal gate, placement is just restriction to the indicated
wires in the phase function. -/
theorem place_diag (w : Fin k ↪ T) (d : Reg k → ℂ) :
    place w (Matrix.diagonal d) = Matrix.diagonal (fun x => d (x ∘ w)) := by
  ext x y
  rw [place_apply]
  by_cases eq : x=y
  · subst y; simp
  · rw [Matrix.diagonal_apply_ne _ eq]
    split
    · rename_i outside
      have h : x ∘ w ≠ y ∘ w := by
        intro hg
        apply eq; funext i
        by_cases hi : i ∈ Set.range w
        · obtain ⟨i,rfl⟩ := hi; exact congrFun hg i
        · exact outside i hi
      exact Matrix.diagonal_apply_ne _ h
    · rfl

/-- A local reversible operation is identified on all computational basis
columns by its effect on the indicated wires and its unchanged spectators. -/
theorem place_perm (w : Fin k ↪ T) (f : Reg k → Reg k) (g : (T→Bool) → T→Bool)
    (outside : ∀ y i, i∉Set.range w → g y i=y i)
    (selected : ∀ y, g y ∘ w=f (y ∘ w)) :
    place w (permMatrix f)=permMatrix g := by
  ext x y
  rw [place_apply]
  simp only [permMatrix,Matrix.of_apply]
  by_cases eq : x=g y
  · subst x; rw [ite_eq_left (outside y),ite_eq_left (selected y),ite_eq_left rfl]
  · rw [ite_eq_right eq]
    split
    · rename_i out
      rw [ite_eq_right]
      intro sel
      apply eq; funext i
      by_cases hi : i∈Set.range w
      · obtain ⟨i,rfl⟩ := hi; exact congrFun (sel.trans (selected y).symm) i
      · exact (out i hi).trans (outside y i hi).symm
    · rfl

/-- The four registers and the two physical signal flags as labelled wires. -/
abbrev Addr (n m : ℕ) := Bool ⊕ Fin n ⊕ Fin n ⊕ Fin m
def outer : Addr n m := .inl false
def inner : Addr n m := .inl true
def row (i : Fin n) : Addr n m := .inr (.inl i)
def col (i : Fin n) : Addr n m := .inr (.inr (.inl i))
def dat (i : Fin m) : Addr n m := .inr (.inr (.inr i))

abbrev HostBits (n m : ℕ) := Bool × Bool × Work (Reg n) (Reg m)

def unpack : (Addr n m → Bool) ≃ HostBits n m where
  toFun s := (s outer,s inner,s ∘ row,s ∘ col,s ∘ dat)
  invFun x := Sum.elim (fun b => if b then x.2.1 else x.1)
    (Sum.elim x.2.2.1 (Sum.elim x.2.2.2.1 x.2.2.2.2))
  left_inv s := by
    funext i
    rcases i with (b|i); · cases b <;> rfl
    rcases i with (r|i); · rfl
    rcases i with (c|b) <;> rfl
  right_inv _ := rfl

def raw (M : Matrix (HostBits n m) (HostBits n m) ℂ) :=
  Matrix.reindexAlgEquiv ℂ ℂ (unpack (n:=n) (m:=m)).symm M

theorem raw_mul (A B : Matrix (HostBits n m) _ ℂ) : raw (A*B) = raw A * raw B := by
  exact map_mul _ _ _

theorem raw_star (A : Matrix (HostBits n m) _ ℂ) : raw Aᴴ=(raw A)ᴴ := rfl

theorem raw_control_diag (d : Reg m→ℂ) : raw (lifted (decoderGate (I:=Reg n) (Matrix.diagonal d))) =
    Matrix.diagonal (fun x : Addr n m → Bool => if x outer then d (x ∘ dat) else 1) := by
  ext x y
  change lifted (decoderGate (I:=Reg n) (Matrix.diagonal d)) (unpack x) (unpack y) = _
  have loc : ∀ (u v : HostBits n m),
      lifted (decoderGate (I:=Reg n) (Matrix.diagonal d)) u v =
        (Matrix.diagonal fun a : HostBits n m => if a.1 then d a.2.2.2.2 else 1) u v := by
    rintro ⟨b,e,i,j,z⟩ ⟨c,f,k,l,x⟩
    cases b <;> cases c <;> simp [lifted,controlOracle,decoderGate,parallelOracle,select,Matrix.one_apply,
      Matrix.diagonal_apply,Prod.mk.injEq,ite_and]
  rw [loc]
  simp only [Matrix.diagonal_apply,Equiv.apply_eq_iff_eq]; rfl

theorem raw_control_perm (f : Reg m → Reg m) :
    raw (lifted (decoderGate (I:=Reg n) (permMatrix f))) =
      permMatrix (fun x : Addr n m → Bool => unpack.symm
        (x outer,x inner,x ∘ row,x ∘ col,if x outer then f (x ∘ dat) else x ∘ dat)) := by
  ext x y
  change lifted (decoderGate (I:=Reg n) (permMatrix f)) (unpack x) (unpack y) = _
  have loc : ∀ u v : HostBits n m,
      lifted (decoderGate (I:=Reg n) (permMatrix f)) u v =
        permMatrix (fun a : HostBits n m => (a.1,a.2.1,a.2.2.1,a.2.2.2.1,
          if a.1 then f a.2.2.2.2 else a.2.2.2.2)) u v := by
    rintro ⟨b,e,i,j,z⟩ ⟨c,f',k,l,x⟩
    cases b <;> cases c <;> simp [lifted,controlOracle,decoderGate,parallelOracle,select,Matrix.one_apply,
      permMatrix,Prod.mk.injEq,ite_and]
  rw [loc]
  simp only [permMatrix,Matrix.of_apply,Equiv.eq_symm_apply]
  by_cases h : unpack x = (y outer,y inner,y ∘ row,y ∘ col,if y outer then f (y ∘ dat) else y ∘ dat)
  · exact (ite_eq_left h).trans (ite_eq_left h).symm
  · exact (ite_eq_right h).trans (ite_eq_right h).symm

end FQChemQatlib.Dynamics.LowChuang.SparseWires
