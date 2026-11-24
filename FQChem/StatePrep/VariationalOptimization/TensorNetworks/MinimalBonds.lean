module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.CircuitSimulation
import Mathlib.Tactic

/-! # Preservation of full bond spaces in an exact MPS gate update

A minimal MPS has no unreachable virtual directions on either side of any site.
The rank-revealing split supplies the two inner full ranks. An invertible physical
gate preserves the other two by allowing the input tensors to be recovered as
linear combinations of the updated physical slices.
-/

@[expose] public section
namespace FQChem.Algorithms.MPSCircuit
open Matrix
variable {K : Type*} [Field K] [DecidableEq K]

def LeftFull {l r : ℕ} (A : Site K l r) : Prop :=
  ∀ v : Fin r → K, (∀ i, A i *ᵥ v = 0) → v = 0

def RightFull {l r : ℕ} (A : Site K l r) : Prop :=
  ∀ v : Fin l → K, (∀ i, v ᵥ* A i = 0) → v = 0

def leftMatrix {l r : ℕ} (A : Site K l r) : Matrix (Fin (2*l)) (Fin r) K :=
  Matrix.of fun u j => let ia : Fin 2 × Fin l := finProdFinEquiv.symm u; A ia.1 ia.2 j

def rightMatrix {l r : ℕ} (A : Site K l r) : Matrix (Fin l) (Fin (2*r)) K :=
  Matrix.of fun a u => let ib : Fin 2 × Fin r := finProdFinEquiv.symm u; A ib.1 a ib.2

omit [DecidableEq K] in
private theorem injective_of_rank {X Y : Type*} [Fintype X] [Fintype Y] (M : Matrix X Y K)
    (hr : M.rank = Fintype.card Y) : Function.Injective M.mulVec := by
  have h := M.mulVecLin.finrank_range_add_finrank_ker
  change M.rank + _ = _ at h
  rw [hr, Module.finrank_pi] at h
  have hk : Module.finrank K (LinearMap.ker M.mulVecLin) = 0 := by omega
  exact LinearMap.ker_eq_bot.mp (Submodule.finrank_eq_zero.mp hk)

omit [DecidableEq K] in
private theorem left_of_rank {l r : ℕ} (A : Site K l r) (h : (leftMatrix A).rank = r) : LeftFull A := by
  intro v hv
  apply injective_of_rank (leftMatrix A) (by simpa using h)
  rw [Matrix.mulVec_zero]
  ext k
  obtain ⟨⟨i,a⟩,rfl⟩ := finProdFinEquiv.surjective k
  simpa only [leftMatrix, Matrix.mulVec, dotProduct, Matrix.of_apply, Equiv.symm_apply_apply, Pi.zero_apply]
    using congrFun (hv i) a

omit [DecidableEq K] in
private theorem right_of_rank {l r : ℕ} (A : Site K l r) (h : (rightMatrix A).rank = l) : RightFull A := by
  intro v hv
  apply injective_of_rank (rightMatrix A)ᵀ (by simpa using h)
  rw [Matrix.mulVec_zero]
  ext k
  obtain ⟨⟨i,b⟩,rfl⟩ := finProdFinEquiv.surjective k
  simpa only [rightMatrix, Matrix.mulVec, dotProduct, Matrix.of_apply, Matrix.transpose_apply,
    Equiv.symm_apply_apply, Matrix.vecMul, mul_comm, Pi.zero_apply] using congrFun (hv i) b

/-- Each updated slice is the corresponding linear combination of the old two-site slices. -/
theorem slice_update {l m r : ℕ} (G : Matrix Pair Pair K) (A : Site K l m) (B : Site K m r)
    (s : Pair) : (applyPair G A B).left s.1 * (applyPair G A B).right s.2 =
      ∑ t : Pair, G s t • (A t.1 * B t.2) := by
  ext a b
  simpa only [Matrix.mul_apply, Matrix.sum_apply, Matrix.smul_apply, smul_eq_mul] using
    pair_entry G A B s.1 s.2 a b

/-- Full column and row rank on the two sides of the newly computed bond. -/
theorem innerFull {l m r : ℕ} (G : Matrix Pair Pair K) (A : Site K l m) (B : Site K m r) :
    LeftFull (applyPair G A B).left ∧ RightFull (applyPair G A B).right := by
  let q := applyPair G A B
  have eq : theta G A B = leftMatrix q.left * rightMatrix q.right := by
    ext x y
    obtain ⟨⟨i,a⟩,rfl⟩ := finProdFinEquiv.surjective x
    obtain ⟨⟨j,b⟩,rfl⟩ := finProdFinEquiv.surjective y
    simp only [theta_entry, Matrix.mul_apply, leftMatrix, rightMatrix, Matrix.of_apply,
      Equiv.symm_apply_apply]
    exact (pair_entry G A B i j a b).symm
  have size : q.bond = (leftMatrix q.left * rightMatrix q.right).rank := (newBond G A B).trans (congrArg Matrix.rank eq)
  exact ⟨left_of_rank _ (le_antisymm (leftMatrix q.left).rank_le_width (size.trans_le (rank_mul_le_left _ _))),
    right_of_rank _ (le_antisymm (rightMatrix q.right).rank_le_height (size.trans_le (rank_mul_le_right _ _)))⟩

/-- Inverting the two-qubit operation recovers every pre-gate slice in the span of the output slices. -/
private theorem recover_slices {l m r : ℕ} (G H : Matrix Pair Pair K) (h : H * G = 1)
    (A : Site K l m) (B : Site K m r) (s : Pair) :
    A s.1 * B s.2 = ∑ t : Pair, H s t • ((applyPair G A B).left t.1 * (applyPair G A B).right t.2) := by
  simp_rw [slice_update, Finset.smul_sum, smul_smul]
  rw [Finset.sum_comm]
  simp_rw [← Finset.sum_smul, ← Matrix.mul_apply, h]
  simp [Matrix.one_apply]

/-- Invertible gates preserve reachability at both untouched outer bonds and at the updated bond. -/
theorem fullPair {l m r : ℕ} (G H : Matrix Pair Pair K) (h : H*G=1)
    (A : Site K l m) (B : Site K m r) (hA : LeftFull A ∧ RightFull A)
    (hB : LeftFull B ∧ RightFull B) :
    let q := applyPair G A B
    (LeftFull q.left ∧ RightFull q.left) ∧ (LeftFull q.right ∧ RightFull q.right) := by
  let q := applyPair G A B
  obtain ⟨hl,hr⟩ := innerFull G A B
  refine ⟨⟨hl,?_⟩,⟨?_,hr⟩⟩
  · intro v hv
    apply hA.2
    intro i
    apply hB.2
    intro j
    rw [Matrix.vecMul_vecMul, recover_slices G H h A B (i,j), Matrix.vecMul_sum]
    simp only [Matrix.vecMul_smul, ← Matrix.vecMul_vecMul, hv, Matrix.zero_vecMul,
      smul_zero, Finset.sum_const_zero]
  · intro v hv
    apply hB.1
    intro j
    apply hA.1
    intro i
    rw [Matrix.mulVec_mulVec, recover_slices G H h A B (i,j), Matrix.sum_mulVec]
    simp only [Matrix.smul_mulVec, ← Matrix.mulVec_mulVec, hv, Matrix.mulVec_zero,
      smul_zero, Finset.sum_const_zero]

def Chain.full : {n l r : ℕ} → Chain K n l r → Prop
  | _,_,_, .nil _ => True
  | _,_,_, .cons A C => (LeftFull A ∧ RightFull A) ∧ C.full

def Gate.invertible : {n : ℕ} → Gate K n → Prop
  | _, .here G => ∃ H, H * G = 1
  | _, .there g => g.invertible

theorem advance_full {n l r : ℕ} (g : Gate K n) (C : Chain K n l r)
    (hG : g.invertible) (hC : C.full) : (advance g C).1.full := by
  induction g generalizing l r with
  | here G =>
    cases C with | cons A tail =>
      cases tail with | cons B rest =>
        obtain ⟨H,h⟩ := hG
        obtain ⟨ha,hb⟩ := fullPair G H h A B hC.1 hC.2.1
        exact ⟨ha,hb,hC.2.2⟩
  | there g ih =>
    cases C with | cons A rest => exact ⟨hC.1, ih _ hG hC.2⟩

end FQChem.Algorithms.MPSCircuit
