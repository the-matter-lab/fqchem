module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.MatrixProductStates
import Mathlib.Tactic

/-! # Rank-revealing refactorization of a compressed two-site tensor

A first-nonzero-pivot row elimination returns outer products. Each successful pivot
strictly decreases row-space dimension. All divisions, products and differences use
field arithmetic, so the algorithm also applies to exact rational gates. The work
account charges the dense residual update and a full scan of the candidate pivot row.
-/

@[expose] public section

namespace FQChem.Algorithms.MPSElimination

variable {K : Type*} [Field K] [DecidableEq K]

structure Term (K : Type*) (r c : ℕ) where
  left : Fin r → K
  right : Fin c → K

structure Factorization (K : Type*) (r c : ℕ) where
  terms : List (Term K r c)
  work : ℕ

def expand {r c : ℕ} (terms : List (Term K r c)) (i : Fin r) (j : Fin c) : K :=
  (terms.map fun t => t.left i * t.right j).sum

def extend {r c : ℕ} (t : Term K r c) : Term K (r+1) c :=
  ⟨Fin.cons 0 t.left, t.right⟩

omit [DecidableEq K] in
private theorem expand_zero {r c : ℕ} (ts : List (Term K r c)) (j : Fin c) :
    expand (ts.map extend) 0 j = 0 := by
  simp [expand, extend, Function.comp_def]

omit [DecidableEq K] in
private theorem expand_succ {r c : ℕ} (ts : List (Term K r c)) (i : Fin r) (j : Fin c) :
    expand (ts.map extend) i.succ j = expand ts i j := by
  simp [expand, extend, Function.comp_def]

def tailRows {r c : ℕ} (M : Matrix (Fin (r+1)) (Fin c) K) : Matrix (Fin r) (Fin c) K :=
  Matrix.of fun i j => M i.succ j

/-- Eagerly build a table so that downstream lookups reuse its entries. -/
def table {s : ℕ} {α : Type*} (f : Fin s → α) : Fin s → α :=
  let data := Vector.ofFn f
  fun i => data[i]

@[simp] theorem table_apply {s : ℕ} {α : Type*} (f : Fin s → α) (i : Fin s) : table f i = f i := by
  simp [table]

def multipliers {r c : ℕ} (M : Matrix (Fin (r+1)) (Fin c) K) (k : Fin c) :=
  table fun i : Fin r => M i.succ k / M 0 k

def residualFrom {r c : ℕ} (M : Matrix (Fin (r+1)) (Fin c) K) (col : Fin r → K) :
    Matrix (Fin r) (Fin c) K :=
  Matrix.of (table fun i => table fun j => M i.succ j - col i * M 0 j)

abbrev residual {r c : ℕ} (M : Matrix (Fin (r+1)) (Fin c) K) (k : Fin c) :=
  residualFrom M (multipliers M k)

def pivot {r c : ℕ} (M : Matrix (Fin (r+1)) (Fin c) K) :=
  Fin.find? fun j => decide (M 0 j ≠ 0)

/-- Materializing the r multipliers once costs r divisions. Filling the r×c residual
table costs one multiply and one subtract per entry. A zero row uses only its pivot scan. -/
def factor {c : ℕ} : (r : ℕ) → Matrix (Fin r) (Fin c) K → Factorization K r c
  | 0, _ => ⟨[], 0⟩
  | r+1, M =>
    match pivot M with
    | none =>
      let f := factor r (tailRows M)
      ⟨f.terms.map extend, c + f.work⟩
    | some k =>
      let col := multipliers M k
      let top := table (M 0)
      let f := factor r (residualFrom M col)
      ⟨⟨Fin.cons 1 col, top⟩ :: f.terms.map extend,
       c + r + 2*r*c + f.work⟩

private theorem pivot_nonzero {r c : ℕ} {M : Matrix (Fin (r+1)) (Fin c) K} {k : Fin c}
    (hk : pivot M = some k) : M 0 k ≠ 0 := by
  have h := (Fin.mem_find?_iff.mp (show k ∈ Fin.find? (fun j => decide (M 0 j ≠ 0)) from hk)).1
  simpa using h

private theorem pivot_none {r c : ℕ} {M : Matrix (Fin (r+1)) (Fin c) K} (hk : pivot M = none)
    (j : Fin c) : M 0 j = 0 := by
  by_contra h
  have hs := Fin.isSome_find?_of_eq_true (p := fun j => decide (M 0 j ≠ 0)) (i := j) (by simp [h])
  change (pivot M).isSome at hs
  simp [hk] at hs

/-- The algorithm reconstructs every matrix entry exactly, including rectangular and
zero matrices. -/
theorem factor_exact {c : ℕ} (r : ℕ) (M : Matrix (Fin r) (Fin c) K) (i : Fin r) (j : Fin c) :
    expand (factor r M).terms i j = M i j := by
  induction r with
  | zero => exact Fin.elim0 i
  | succ r ih =>
    cases h : pivot M with
    | none =>
      simp only [factor, h]
      refine Fin.cases ?_ (fun v => ?_) i
      · rw [expand_zero, pivot_none h j]
      · simpa [expand_succ, tailRows] using ih (tailRows M) v
    | some k =>
      simp only [factor, h]
      refine Fin.cases ?_ (fun v => ?_) i
      · change 1 * table (M 0) j + expand _ 0 j = _
        rw [expand_zero, table_apply]; ring
      · change multipliers M k v * table (M 0) j + expand _ v.succ j = M v.succ j
        rw [expand_succ, ih]; simp [residualFrom]

omit [DecidableEq K] in
private theorem residual_rank {r c : ℕ} (M : Matrix (Fin (r+1)) (Fin c) K) (k : Fin c)
    (hk : M 0 k ≠ 0) : (residual M k).rank < M.rank := by
  classical
  rw [Matrix.rank_eq_finrank_span_row, Matrix.rank_eq_finrank_span_row]
  apply Submodule.finrank_lt_finrank_of_lt
  have mem (i : Fin (r+1)) := Submodule.subset_span (R := K) (Set.mem_range_self (f := M.row) i)
  have vanish : Submodule.span K (Set.range (residual M k).row) ≤
      LinearMap.ker (LinearMap.proj k : (Fin c → K) →ₗ[K] K) := by
    apply Submodule.span_le.mpr
    rintro _ ⟨i,rfl⟩
    change residual M k i k = 0
    simp only [residual, residualFrom, Matrix.of_apply, table_apply, multipliers]
    field_simp; ring
  refine lt_iff_le_not_ge.mpr ⟨Submodule.span_le.mpr ?_, ?_⟩
  · rintro _ ⟨i,rfl⟩
    have he : (residual M k).row i = M.row i.succ - (multipliers M k i) • M.row 0 := by
      ext j; simp [Matrix.row, residual, residualFrom]
    rw [he]; exact Submodule.sub_mem _ (mem i.succ) (Submodule.smul_mem _ (multipliers M k i) (mem 0))
  · intro h
    exact hk (vanish (h (mem 0)))

/-- The computed number of bond labels never exceeds the actual rank. -/
theorem factor_rank {c : ℕ} (r : ℕ) (M : Matrix (Fin r) (Fin c) K) :
    (factor r M).terms.length ≤ M.rank := by
  induction r with
  | zero => simp [factor]
  | succ r ih =>
    cases h : pivot M with
    | none =>
      simp only [factor, h, List.length_map]
      exact (ih (tailRows M)).trans (Matrix.rank_submatrix_le M Fin.succ id)
    | some k =>
      simp only [factor, h, List.length_cons, List.length_map]
      exact (ih (residual M k)).trans_lt (residual_rank M k (pivot_nonzero h))

/-- Reconstruction as a matrix product of the two returned factor tables. -/
theorem factor_matrix {r c : ℕ} (M : Matrix (Fin r) (Fin c) K) :
    let ts := (factor r M).terms
    M = (Matrix.of fun i (t : Fin ts.length) => (ts.get t).left i) *
      (Matrix.of fun (t : Fin ts.length) j => (ts.get t).right j) := by
  intro ts
  ext i j
  rw [Matrix.mul_apply, ← factor_exact r M i j]
  change ((ts.map fun t => t.left i * t.right j).sum) = _
  induction ts with
  | nil => simp
  | cons t ts ih =>
    simp [Fin.sum_univ_succ, Matrix.of_apply, List.get_eq_getElem, ih]

/-- The number of returned rank-one terms is the minimum possible bond size. -/
theorem factor_minimal {r c : ℕ} (M : Matrix (Fin r) (Fin c) K) :
    (factor r M).terms.length = M.rank := by
  refine le_antisymm (factor_rank r M) ?_
  let ts := (factor r M).terms
  let left := Matrix.of fun i (t : Fin ts.length) => (ts.get t).left i
  let right := Matrix.of fun (t : Fin ts.length) j => (ts.get t).right j
  calc M.rank = (left * right).rank := congrArg Matrix.rank (factor_matrix M)
       _ ≤ left.rank := Matrix.rank_mul_le_left _ _
       _ ≤ ts.length := left.rank_le_width

/-- Worst-case scalar operations and equality probes for the dense elimination schedule. -/
theorem factor_work {c : ℕ} (r : ℕ) (M : Matrix (Fin r) (Fin c) K) :
    (factor r M).work ≤ r*c + r*r + 2*r*r*c := by
  induction r with
  | zero => simp [factor]
  | succ r ih =>
    cases h : pivot M with
    | none =>
      simp only [factor, h]
      nlinarith [ih (tailRows M)]
    | some k =>
      simp only [factor, h]
      nlinarith [ih (residual M k)]

end FQChem.Algorithms.MPSElimination
