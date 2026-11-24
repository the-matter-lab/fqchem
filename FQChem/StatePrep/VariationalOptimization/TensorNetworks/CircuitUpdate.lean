module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.RankRevealing
import Mathlib.Tactic

/-! # Classical gate updates of a matrix-product state

Vidal, [Phys. Rev. Lett. 91, 147902](https://doi.org/10.1103/PhysRevLett.91.147902),
Lemmas 1–2 and Eqs. (16), (20)–(22). Two local tensors absorb an adjacent two-qubit
gate and split back into two tensors at the exact new cut rank. Rank-revealing
elimination supplies an arithmetic alternative to the paper's Schmidt-basis update.
-/

@[expose] public section
namespace FQChem.Algorithms.MPSCircuit

open MPSElimination Matrix
variable {K : Type*} [Field K] [DecidableEq K]

abbrev Site (K : Type*) (l r : ℕ) := Fin 2 → Matrix (Fin l) (Fin r) K
abbrev Pair := Fin 2 × Fin 2

/-- Eager site table for a one-qubit gate, Eq. (16). -/
def oneSite {l r : ℕ} (U : Matrix (Fin 2) (Fin 2) K) (A : Site K l r) : Site K l r :=
  table fun i => Matrix.of (table fun a => table fun b => ∑ k, U i k * A k a b)

omit [DecidableEq K] in
/-- A local amplitude, with arbitrary left and right environments, after a one-qubit gate. -/
theorem oneSite_amplitude {l r : ℕ} (U : Matrix (Fin 2) (Fin 2) K) (A : Site K l r)
    (L : Fin l → K) (R : Fin r → K) (i : Fin 2) :
    (∑ a, ∑ b, L a * oneSite U A i a b * R b) =
      ∑ k, U i k * ∑ a, ∑ b, L a * A k a b * R b := by
  simp only [oneSite, table_apply, Matrix.of_apply, Finset.mul_sum, Finset.sum_mul]
  conv_lhs => enter [2, a]; rw [Finset.sum_comm]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro k _
  apply Finset.sum_congr rfl
  intro a _
  apply Finset.sum_congr rfl
  intro b _
  ring

/-- Cache all four input-pair contractions before applying the four-output gate. -/
def merged {l m r : ℕ} (A : Site K l m) (B : Site K m r) : Fin 4 → Matrix (Fin l) (Fin r) K :=
  table fun z =>
    let s : Pair := finProdFinEquiv.symm z
    Matrix.of (table fun a => table fun b => ∑ t, A s.1 a t * B s.2 t b)

/-- Eq. (22), with the left physical/outer labels and right physical/outer labels
packed as the row and column index of a 2l by 2r matrix. -/
def theta {l m r : ℕ} (G : Matrix Pair Pair K) (A : Site K l m) (B : Site K m r) :
    Matrix (Fin (2*l)) (Fin (2*r)) K :=
  let input := merged A B
  Matrix.of (table fun x => table fun y =>
    let i : Fin 2 × Fin l := finProdFinEquiv.symm x
    let j : Fin 2 × Fin r := finProdFinEquiv.symm y
    ∑ s : Pair, G (i.1,j.1) s * input (finProdFinEquiv s) i.2 j.2)

omit [DecidableEq K] in
theorem theta_entry {l m r : ℕ} (G : Matrix Pair Pair K) (A : Site K l m) (B : Site K m r)
    (i j : Fin 2) (a : Fin l) (b : Fin r) :
    theta G A B (finProdFinEquiv (i,a)) (finProdFinEquiv (j,b)) =
      ∑ s : Pair, G (i,j) s * ∑ t, A s.1 a t * B s.2 t b := by
  simp only [theta, Matrix.of_apply, table_apply, Equiv.symm_apply_apply, merged]

structure Updated (K : Type*) (l r : ℕ) where
  bond : ℕ
  left : Site K l bond
  right : Site K bond r
  work : ℕ

/-- Form the middle tensor, perform pivot elimination, and materialize the two
resulting sites. The work charge covers the dense arithmetic and equality probes. -/
def applyPair {l m r : ℕ} (G : Matrix Pair Pair K) (A : Site K l m) (B : Site K m r) :
    Updated K l r :=
  let q := factor (2*l) (theta G A B)
  let terms := q.terms.toArray
  { bond := q.terms.length
    left := table fun i => Matrix.of (table fun a => table fun t =>
      terms[t.val]'(by simp [terms]) |>.left (finProdFinEquiv (i,a)))
    right := table fun j => Matrix.of (table fun t => table fun b =>
      terms[t.val]'(by simp [terms]) |>.right (finProdFinEquiv (j,b)))
    work := 8*l*m*r + 32*l*r + q.work }

/-- The returned bond equals the local coefficient-matrix rank, including rank zero. -/
theorem newBond {l m r : ℕ} (G : Matrix Pair Pair K) (A : Site K l m) (B : Site K m r) :
    (applyPair G A B).bond = (theta G A B).rank := factor_minimal _

/-- The two returned sites reproduce the gate on every coefficient, without truncation. -/
theorem pair_entry {l m r : ℕ} (G : Matrix Pair Pair K) (A : Site K l m) (B : Site K m r)
    (i j : Fin 2) (a : Fin l) (b : Fin r) :
    let q := applyPair G A B
    (∑ t, q.left i a t * q.right j t b) = ∑ s : Pair, G (i,j) s * ∑ t, A s.1 a t * B s.2 t b := by
  rw [← theta_entry]
  have h := congrArg (fun (M : Matrix (Fin (2*l)) (Fin (2*r)) K) =>
    M (finProdFinEquiv (i,a)) (finProdFinEquiv (j,b))) (factor_matrix (theta G A B))
  dsimp only [Matrix.mul_apply, Matrix.of_apply] at h
  rw [h]
  apply Finset.sum_congr rfl
  intro t _
  change Fin (factor (2*l) (theta G A B)).terms.length at t
  simp only [applyPair, table_apply, List.getElem_toArray]
  change table (α := Fin (factor (2*l) (theta G A B)).terms.length → K) _ a t *
    table (α := Fin r → K) _ t b = _
  rw [table_apply, table_apply, table_apply, table_apply]
  rfl

/-- Cubic scalar arithmetic count, uniform in the number of qubits outside these sites. -/
theorem pair_work {l m r χ : ℕ} (G : Matrix Pair Pair K) (A : Site K l m) (B : Site K m r)
    (hl : l ≤ χ) (hm : m ≤ χ) (hr : r ≤ χ) :
    (applyPair G A B).work ≤ 24*χ^3 + 40*χ^2 := by
  change 8*l*m*r + 32*l*r + _ ≤ _
  have hf := factor_work (2*l) (theta G A B)
  calc
    _ ≤ 8*l*m*r + 32*l*r + ((2*l)*(2*r)+(2*l)*(2*l)+2*(2*l)*(2*l)*(2*r)) := by omega
    _ ≤ 8*χ*χ*χ + 32*χ*χ + ((2*χ)*(2*χ)+(2*χ)*(2*χ)+2*(2*χ)*(2*χ)*(2*χ)) := by gcongr
    _ = _ := by ring

/-- In independent outer frames (for example Schmidt frames), the rank of the
global updated cut equals the bond size computed on the small middle tensor. -/
theorem physicalBond {l m r : ℕ} {X Y : Type*} [Fintype X] [Fintype Y]
    (G : Matrix Pair Pair K) (A : Site K l m) (B : Site K m r)
    (L : Matrix X (Fin (2*l)) K) (R : Matrix (Fin (2*r)) Y K)
    (L' : Matrix (Fin (2*l)) X K) (R' : Matrix Y (Fin (2*r)) K)
    (hL : L' * L = 1) (hR : R * R' = 1) :
    (applyPair G A B).bond = (L * theta G A B * R).rank := by
  rw [newBond]
  let M := theta G A B
  have recover : M = L' * (L * M * R) * R' := by
    simp [← Matrix.mul_assoc, hL, Matrix.mul_assoc M R R', hR]
  refine le_antisymm ?_ ((Matrix.rank_mul_le_left _ _).trans (Matrix.rank_mul_le_right _ _))
  calc M.rank = (L' * (L * M * R) * R').rank := congrArg Matrix.rank recover
       _ ≤ (L' * (L * M * R)).rank := Matrix.rank_mul_le_left _ _
       _ ≤ (L * M * R).rank := Matrix.rank_mul_le_right _ _

end FQChem.Algorithms.MPSCircuit
