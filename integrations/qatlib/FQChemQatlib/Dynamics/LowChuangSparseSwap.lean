module

public import FQChemQatlib.Dynamics.LowChuangSparseControl

/-! # Elementary-gate implementation of the controlled sparse-address swap -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseControl

open Matrix Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.LocalMachine.LocalTransport Qatlib.Concepts.CopyEvolution.Discriminate
open Qatlib.Concepts.BlockEncoding.LCU
open SparseWires SparseBlock Query
open scoped Classical

variable {n m : ℕ}

def swapSet (s : Finset (Fin n)) (x : R n m) : R n m
  | .inl b => x (.inl b)
  | .inr (.inl i) => if x outer=true ∧ i∈s then x (SparseWires.col i) else x (SparseWires.row i)
  | .inr (.inr (.inl i)) => if x outer=true ∧ i∈s then x (SparseWires.row i) else x (SparseWires.col i)
  | .inr (.inr (.inr i)) => x (dat i)

private def fredkin (x : Reg 3) : Reg 3 := ![x 0,if x 0 then x 2 else x 1,if x 0 then x 1 else x 2]

private theorem fredkin_inv : Function.Involutive fredkin := by
  intro x; funext i; fin_cases i <;> cases e : x 0 <;> simp [fredkin,e]

theorem swapOne (i : Fin n) : Emits (permMatrix (swapSet (m:=m) {i})) 415440 := by
  let w := triple (outer : Addr n m) (SparseWires.row i) (SparseWires.col i) (by intro h; cases h) (by intro h; cases h) (by intro h; cases h)
  have built := placed (three w (permMatrix fredkin) (permMatrix_unitary fredkin_inv))
  have out (x : R n m) (a : Addr n m) (h : a∉Set.range w) : swapSet {i} x a=x a := by
    rcases a with (b | a); · rfl
    rcases a with (j | a)
    · have neq : j≠i := by rintro rfl; exact h ⟨1,rfl⟩
      simp [swapSet,neq,SparseWires.row]
    rcases a with (j | a)
    · have neq : j≠i := by rintro rfl; exact h ⟨2,rfl⟩
      simp [swapSet,neq,SparseWires.col]
    · rfl
  have sel (x : R n m) : swapSet {i} x ∘ w=fredkin (x ∘ w) := by
    funext j; fin_cases j
    · rfl
    · change (if x outer=true ∧ i∈({i}:Finset _) then x (SparseWires.col i) else x (SparseWires.row i))=
        (if x outer then x (SparseWires.col i) else x (SparseWires.row i))
      simp
    · change (if x outer=true ∧ i∈({i}:Finset _) then x (SparseWires.row i) else x (SparseWires.col i))=
        (if x outer then x (SparseWires.row i) else x (SparseWires.col i))
      simp
  rw [place_perm w fredkin (swapSet {i}) out sel] at built
  exact built

private theorem insert_swap (i : Fin n) (s : Finset (Fin n)) (hi : i∉s) :
    swapSet (m:=m) (insert i s) = swapSet {i} ∘ swapSet s := by
  funext x a
  rcases a with (b | a); · rfl
  rcases a with (j | a)
  · by_cases flag : x outer=true <;> by_cases eq : j=i <;> simp_all [swapSet,outer,SparseWires.row,SparseWires.col]
  rcases a with (j | a)
  · by_cases flag : x outer=true <;> by_cases eq : j=i <;> simp_all [swapSet,outer,SparseWires.row,SparseWires.col]
  · rfl

private theorem perm_comp {J:Type} [Fintype J] [DecidableEq J] (f g : J→J) :
    permMatrix (f ∘ g)=permMatrix f * permMatrix g := by
  ext i j
  simp [permMatrix,Matrix.mul_apply,mul_ite]

theorem swapSubset (s : Finset (Fin n)) : Emits (permMatrix (swapSet (m:=m) s)) (415440*s.card) := by
  induction s using Finset.induction_on with
  | empty =>
    have eq : swapSet (n:=n) (m:=m) ∅=id := by
      funext x a
      rcases a with (b | a); · rfl
      rcases a with (j | a); · simp [swapSet,SparseWires.row]
      rcases a with (j | b); · simp [swapSet,SparseWires.col]
      rfl
    have M : permMatrix (id : R n m → _) = 1 := by ext i j; simp [permMatrix,Matrix.one_apply]
    simpa [eq,M] using (empty (n:=n) (m:=m))
  | insert i s h ih =>
    rw [insert_swap i s h,perm_comp,Finset.card_insert_of_notMem h,Nat.mul_succ,Nat.add_comm]
    exact concat (swapOne i) ih

/-- The lifted logical register exchange really is a product of n
three-qubit Fredkin gates, each with a constant elementary decomposition. -/
theorem swapGate : Emits (raw (lifted (permMatrix (exchange (I:=Reg n) (B:=Reg m))))) (415440*n) := by
  have eq : raw (lifted (permMatrix (exchange (I:=Reg n) (B:=Reg m))))=
      permMatrix (swapSet Finset.univ) := by
    ext x y
    change lifted (permMatrix (exchange (I:=Reg n) (B:=Reg m))) (unpack x) (unpack y)=_
    have loc : ∀ u v : HostBits n m, lifted (permMatrix (exchange (I:=Reg n) (B:=Reg m))) u v =
      permMatrix (fun z : HostBits n m => if z.1 then (z.1,z.2.1,z.2.2.2.1,z.2.2.1,z.2.2.2.2) else z) u v := by
      rintro ⟨b,e,i,j,v⟩ ⟨c,f,k,l,z⟩
      cases b <;> cases c <;> simp [lifted,controlOracle,parallelOracle,select,Matrix.one_apply,
        permMatrix,exchange,Prod.mk.injEq,ite_and]
    rw [loc]
    simp only [permMatrix,Matrix.of_apply]
    have perm : (if (unpack y).1 then ((unpack y).1,(unpack y).2.1,(unpack y).2.2.2.1,(unpack y).2.2.1,(unpack y).2.2.2.2) else unpack y)
       = unpack (swapSet Finset.univ y) := by
      cases flag : y outer <;> simp [unpack,swapSet,outer,SparseWires.inner,SparseWires.row,SparseWires.col,dat,Function.comp_def] at flag ⊢ <;> simp [flag]
    by_cases h : x=swapSet Finset.univ y
    · subst x; exact (ite_eq_left perm.symm).trans (ite_eq_left rfl).symm
    · exact (ite_eq_right (fun e => h (unpack.injective (e.trans perm)))).trans (ite_eq_right h).symm
  rw [eq]
  simpa using swapSubset (m:=m) (Finset.univ : Finset (Fin n))

end FQChemQatlib.Dynamics.LowChuang.SparseControl
