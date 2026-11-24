module

public import FQChemQatlib.Dynamics.LowChuangElementary
public import FQChemQatlib.Dynamics.LowChuangSparsePhysicalBlock

/-! # Composing a counted sparse-access word with standard-form simulation -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseAssembly

open Matrix Query
open scoped Classical

variable {I J K : Type} [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J] [DecidableEq K]

def push (e : I ≃ J) (M : Matrix I I ℂ) : Matrix J J ℂ := Matrix.reindexAlgEquiv ℂ ℂ e M

theorem push_mul (e : I≃J) (A B : Matrix I I ℂ) : push e (A*B)=push e A*push e B := map_mul _ _ _
theorem push_adj (e : I≃J) (A : Matrix I I ℂ) : push e Aᴴ=(push e A)ᴴ := rfl
theorem push_one (e : I≃J) : push e (1 : Matrix I I ℂ)=1 := map_one _
theorem undo (e : I≃J) (A : Matrix I I ℂ) : push e.symm (push e A)=A := by
  ext i j; change A (e.symm (e i)) (e.symm (e j))=A i j; simp

def renameStep (e : I≃J) : Step I K → Step J K
  | .fixed M => .fixed (push e M)
  | .query a b => .query a b

omit [DecidableEq K] in
theorem rename_run (e : I≃J) (inputs : K→Matrix I I ℂ) (word : List (Step I K)) :
    run (fun k => push e (inputs k)) (word.map (renameStep e)) = push e (run inputs word) := by
  induction word with
  | nil => exact (push_one e).symm
  | cons g gs ih =>
    simp only [List.map_cons,run,push_mul,ih]
    congr 1
    cases g with
    | fixed _ => rfl
    | query _ b => cases b <;> rfl

theorem rename_cost (e : I≃J) (a : K) (word : List (Step I K)) :
    cost a (word.map (renameStep e))=cost a word := by
  induction word with
  | nil => rfl
  | cons g gs ih => cases g <;> simp [renameStep,cost,ih]

omit [DecidableEq K] in
theorem rename_fixed (e : I≃J) (word : List (Step I K)) :
    fixedCount (word.map (renameStep e))=fixedCount word := by
  induction word with
  | nil => rfl
  | cons g gs ih => cases g <;> simp [renameStep,fixedCount,ih]

def compile (block : List (Step J K)) : List (Step J StandardOracle) → List (Step J K)
  | [] => []
  | .fixed M :: rest => .fixed M :: compile block rest
  | .query .prepare _ :: rest => compile block rest
  | .query .block false :: rest => block ++ compile block rest
  | .query .block true :: rest => inverse block ++ compile block rest

def logical (U : Matrix J J ℂ) : StandardOracle → Matrix J J ℂ
  | .prepare => 1
  | .block => U

omit [DecidableEq K] in
theorem compile_run (data : K→Matrix J J ℂ) (block : List (Step J K)) (word : List (Step J StandardOracle)) :
    run data (compile block word) = run (logical (run data block)) word := by
  induction word with
  | nil => rfl
  | cons g gs ih =>
    cases g with
    | fixed M => simp [compile,run,matrix,ih]
    | query k b => cases k <;> cases b <;> simp [compile,logical,run,matrix,run_append,run_inverse,ih]

omit [Fintype J] [DecidableEq J] in
theorem compile_cost (a : K) (block : List (Step J K)) (word : List (Step J StandardOracle)) :
    cost a (compile block word)=cost a block*cost .block word := by
  induction word with
  | nil => simp [compile,cost]
  | cons g gs ih =>
    cases g with
    | fixed M => simp [compile,cost,ih]
    | query k b => cases k <;> cases b <;> simp [compile,cost,cost_append,cost_inverse,ih,Nat.mul_add]

omit [Fintype J] [DecidableEq J] [DecidableEq K] in
private theorem inverse_fixed (block : List (Step J K)) : fixedCount (inverse block)=fixedCount block := by
  induction block with
  | nil => rfl
  | cons g gs ih =>
    have e : inverse (g::gs)=inverse gs++[adjoint g] := by simp [inverse]
    rw [e,fixed_append,ih]
    cases g <;> simp [adjoint,fixedCount]

omit [Fintype J] [DecidableEq J] [DecidableEq K] in
theorem compile_fixed (block : List (Step J K)) (word : List (Step J StandardOracle)) :
    fixedCount (compile block word)=fixedCount word+fixedCount block*cost .block word := by
  induction word with
  | nil => simp [compile,cost,fixedCount]
  | cons g gs ih =>
    cases g with
    | fixed M => simp [compile,fixedCount,cost,ih]; omega
    | query k b =>
      cases k <;> cases b <;> simp [compile,cost,fixedCount,fixed_append,inverse_fixed,ih,Nat.mul_add] <;> omega

omit [Fintype J] [DecidableEq J] [DecidableEq K] in
theorem compile_gates {P : Matrix J J ℂ → Prop} (adj : ∀ M,P M → P Mᴴ)
    (block : List (Step J K)) (bh : ∀ M, .fixed M∈block → P M)
    (word : List (Step J StandardOracle)) (wh : ∀ M, .fixed M∈word → P M) :
    ∀ M, .fixed M∈compile block word → P M := by
  have inv (M : Matrix J J ℂ) (h : .fixed M ∈ inverse block) : P M := by
    obtain ⟨g,mem,eq⟩ := List.mem_map.mp (List.mem_reverse.mp h)
    cases g with
    | query k b => cases eq
    | fixed V => cases eq; exact adj _ (bh _ mem)
  induction word with
  | nil => simp [compile]
  | cons g gs ih =>
    have tail := ih (fun M h => wh _ (List.mem_cons_of_mem _ h))
    cases g with
    | fixed V =>
      intro M h
      rcases List.mem_cons.mp h with eq | rest
      · cases eq; exact wh _ List.mem_cons_self
      · exact tail M rest
    | query k b =>
      cases k <;> cases b <;> intro M h
      · exact tail M h
      · exact tail M h
      · exact (List.mem_append.mp h).elim (bh M) (tail M)
      · exact (List.mem_append.mp h).elim (inv M) (tail M)

end FQChemQatlib.Dynamics.LowChuang.SparseAssembly
