module

public import FQChem.StatePrep.PerturbationTheory.CoupledCluster
public import Mathlib.Analysis.Matrix.Order
import Mathlib.Analysis.Matrix.Normed
import Mathlib.Tactic

/-! # Coupled-cluster energies for noninteracting replicas

In the independent-copy argument of Lee et al., the similarity-transformed
Hamiltonian is additive even when the fragment cluster operators are truncated.
The diagonal at the product reference therefore gives the sum of the fragment
energies. We track the fragment accuracy needed for a prescribed total error.
[Lee et al. (2023), Fig. 3A](https://doi.org/10.1038/s41467-023-37587-6). -/

@[expose] public section
noncomputable section

namespace FQChem.StatePrep.CoupledClusterReplicas
open Matrix NormedSpace FQChem.VariationalMethods
open scoped Kronecker Matrix ComplexOrder

variable {ι κ : Type} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]

/-- Sum of independent operators on the tensor product. -/
def separated (A : Matrix ι ι ℂ) (B : Matrix κ κ ℂ) :=
  A ⊗ₖ (1 : Matrix κ κ ℂ) + (1 : Matrix ι ι ℂ) ⊗ₖ B

private theorem expRight (B : Matrix κ κ ℂ) :
    exp ((1 : Matrix ι ι ℂ) ⊗ₖ B) = (1 : Matrix ι ι ℂ) ⊗ₖ exp B := by
  open scoped Matrix.Norms.Operator in
    let f : Matrix κ κ ℂ →+* Matrix (ι × κ) (ι × κ) ℂ := {
      toFun := fun M => (1 : Matrix ι ι ℂ) ⊗ₖ M
      map_one' := one_kronecker_one
      map_mul' := fun A B => by simp [← mul_kronecker_mul]
      map_add' := kronecker_add 1
      map_zero' := by ext; simp [kroneckerMap_apply] }
    have cont : Continuous f := by
      change Continuous (fun M : Matrix κ κ ℂ => (1 : Matrix ι ι ℂ) ⊗ₖ M)
      refine continuous_pi (fun i => continuous_pi (fun j => ?_))
      exact continuous_const.mul ((continuous_apply j.2).comp (continuous_apply i.2))
    exact (NormedSpace.map_exp f cont B).symm

/-- The cluster exponential of the composite equals the tensor product of the
fragment exponentials for arbitrary finite cluster matrices. -/
theorem expSeparated (A : Matrix ι ι ℂ) (B : Matrix κ κ ℂ) :
    exp (separated A B) = exp A ⊗ₖ exp B := by
  have commute : Commute (A ⊗ₖ (1 : Matrix κ κ ℂ)) ((1 : Matrix ι ι ℂ) ⊗ₖ B) := by
    unfold Commute SemiconjBy
    simp [← mul_kronecker_mul]
  rw [separated, Matrix.exp_add_of_commute _ _ commute, expRight]
  rw [kronecker_one, exp_blockDiagonal]
  have point : exp (fun _ : κ => A) = fun _ => exp A := by
    open scoped Matrix.Norms.Operator in
      funext i
      exact Pi.coe_exp _ _
  rw [point, ← kronecker_one, ← mul_kronecker_mul, Matrix.mul_one, Matrix.one_mul]

/-- Fragment similarity transforms add as a Kronecker sum. No amplitude
equation or exactness assumption is needed. -/
theorem transformedSeparated (H T : Matrix ι ι ℂ) (K S : Matrix κ κ ℂ) :
    transformed (separated H K) (separated T S) =
      separated (transformed H T) (transformed K S) := by
  have neg : -separated T S = separated (-T) (-S) := by
    ext i j
    simp [separated, kroneckerMap_apply, add_comm]
  unfold transformed
  rw [neg, expSeparated, expSeparated]
  simp only [separated, mul_add, add_mul,
    ← mul_kronecker_mul, Matrix.mul_one, expClusterInverse]

/-- The usual projected coupled-cluster energy at a reference determinant. -/
def projected (H T : Matrix ι ι ℂ) (ref : ι) := (transformed H T ref ref).re

theorem projectedSeparated (H T : Matrix ι ι ℂ) (K S : Matrix κ κ ℂ) (i : ι) (j : κ) :
    projected (separated H K) (separated T S) (i,j) = projected H T i + projected K S j := by
  unfold projected
  rw [transformedSeparated]
  simp [separated, kroneckerMap_apply]

/-- A ground energy bound and an eigenvector attaining it. -/
def GroundAt (H : Matrix ι ι ℂ) (E : ℝ) : Prop :=
  (H - (E : ℂ) • (1 : Matrix ι ι ℂ)).PosSemidef ∧
    ∃ v : ι → ℂ, v ≠ 0 ∧ H *ᵥ v = (E : ℂ) • v

omit [DecidableEq ι] [DecidableEq κ] in
private theorem tensorAction (H : Matrix ι ι ℂ) (K : Matrix κ κ ℂ) (u : ι → ℂ) (v : κ → ℂ) :
    (H ⊗ₖ K) *ᵥ (fun p => u p.1 * v p.2) =
      fun p => (H *ᵥ u) p.1 * (K *ᵥ v) p.2 := by
  funext p
  simp only [mulVec, dotProduct, kroneckerMap_apply, Finset.sum_mul, Finset.mul_sum,
    Fintype.sum_prod_type]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl; intro i _
  apply Finset.sum_congr rfl; intro j _
  ring

/-- Ground energies of independent fragments add, including the lower bound
over entangled states on the composite space. -/
theorem groundSeparated {H : Matrix ι ι ℂ} {K : Matrix κ κ ℂ} {E F : ℝ}
    (h : GroundAt H E) (k : GroundAt K F) : GroundAt (separated H K) (E+F) := by
  obtain ⟨hp,u,hu,he⟩ := h
  obtain ⟨kp,v,hv,ke⟩ := k
  constructor
  · have sum := (hp.kronecker (PosSemidef.one (n := κ) (R := ℂ))).add
      ((PosSemidef.one (n := ι) (R := ℂ)).kronecker kp)
    convert sum using 1
    simp only [separated, sub_eq_add_neg, ← neg_smul, add_kronecker, kronecker_add,
      smul_kronecker, kronecker_smul, one_kronecker_one, Complex.ofReal_add,
      neg_add, add_smul]
    abel
  · refine ⟨fun p => u p.1 * v p.2, ?_, ?_⟩
    · obtain ⟨i, hi⟩ := Function.ne_iff.mp hu
      obtain ⟨j, hj⟩ := Function.ne_iff.mp hv
      exact Function.ne_iff.mpr ⟨(i,j), mul_ne_zero hi hj⟩
    · simp only [separated, add_mulVec, tensorAction, one_mulVec, he, ke]
      funext p
      simp [smul_eq_mul]
      ring

/-- Product basis for L identical replicas, with a one-dimensional vacuum. -/
abbrev ReplicaBasis (ι : Type) : ℕ → Type
  | 0 => Unit
  | n+1 => ReplicaBasis ι n × ι

instance replicaFintype [Fintype α] : (n : ℕ) → Fintype (ReplicaBasis α n)
  | 0 => inferInstanceAs (Fintype Unit)
  | n+1 =>
    letI := replicaFintype (α := α) n
    inferInstanceAs (Fintype (ReplicaBasis α n × α))

instance replicaDecEq [DecidableEq α] : (n : ℕ) → DecidableEq (ReplicaBasis α n)
  | 0 => inferInstanceAs (DecidableEq Unit)
  | n+1 =>
    letI := replicaDecEq (α := α) n
    inferInstanceAs (DecidableEq (ReplicaBasis α n × α))

def reference (i : ι) : (n : ℕ) → ReplicaBasis ι n
  | 0 => ()
  | n+1 => (reference i n, i)

/-- The many-fragment operator, with no terms coupling different replicas. -/
def repeated (A : Matrix ι ι ℂ) : (n : ℕ) → Matrix (ReplicaBasis ι n) (ReplicaBasis ι n) ℂ
  | 0 => 0
  | n+1 => separated (repeated A n) A

theorem projectedCopies (H T : Matrix ι ι ℂ) (i : ι) (n : ℕ) :
    projected (repeated H n) (repeated T n) (reference i n) = n * projected H T i := by
  induction n with
  | zero => simp [repeated, projected, transformed]
  | succ n ih =>
    rw [repeated, repeated, reference, projectedSeparated, ih, Nat.cast_succ, add_mul, one_mul]

theorem groundCopies {H : Matrix ι ι ℂ} {E : ℝ} (h : GroundAt H E) (n : ℕ) :
    GroundAt (repeated H n) (n*E) := by
  induction n with
  | zero =>
    constructor
    · simpa [repeated] using (PosSemidef.zero : (0 : Matrix Unit Unit ℂ).PosSemidef)
    · refine ⟨fun _ => 1, ?_, ?_⟩
      · exact Function.ne_iff.mpr ⟨(), one_ne_zero⟩
      · simp [repeated]
  | succ n ih =>
    rw [Nat.cast_succ, add_mul, one_mul]
    exact groundSeparated ih h

/-- The independent-replica implication at Fig. 3A of Lee et al.
Assume that solving *one fixed fragment*, including evaluating its projected
energy, costs at most C δ⁻ᵇ for absolute error δ. Solving L independent copies
at precision ε/L and adding their energies costs at most
(C+1) Lᵇ⁺¹ ε⁻ᵇ, with absolute error at most ε on the entire composite.
The assumed cost and accuracy are for the fragment alone. -/
theorem replicaScaling (H : Matrix ι ι ℂ) (i : ι) (E C : ℝ) (b : ℕ)
    (ground : GroundAt H E) (T : ℝ → Matrix ι ι ℂ) (work : ℝ → ℕ)
    (fragment : ∀ δ : ℝ, 0 < δ → δ ≤ 1 →
      |projected H (T δ) i - E| ≤ δ ∧ (work δ : ℝ) ≤ C*(1/δ)^b)
    (L : ℕ) (hL : 0 < L) (ε : ℝ) (hε : 0<ε) (small : ε ≤ 1) :
    let δ := ε/L
    GroundAt (repeated H L) (L*E) ∧
    |projected (repeated H L) (repeated (T δ) L) (reference i L) - L*E| ≤ ε ∧
    (L : ℝ)*((work δ : ℝ)+1) ≤ (C+1)*(L:ℝ)^(b+1)*(1/ε)^b := by
  dsimp only
  have lpos : 0 < (L:ℝ) := by exact_mod_cast hL
  have large : (1:ℝ) ≤ L := by exact_mod_cast hL
  obtain ⟨accuracy, cost⟩ := fragment (ε/L) (div_pos hε lpos)
    ((div_le_iff₀ lpos).mpr (by linarith))
  refine ⟨groundCopies ground L, ?_, ?_⟩
  · rw [projectedCopies, ← mul_sub, abs_mul, abs_of_pos lpos]
    exact (mul_le_mul_of_nonneg_left accuracy lpos.le).trans_eq (by field_simp)
  · have precision : 1 ≤ ((L:ℝ)*(1/ε))^b := one_le_pow₀ (by
      rw [mul_one_div, le_div_iff₀ hε]; linarith)
    rw [show 1/(ε/(L:ℝ)) = L*(1/ε) by field_simp] at cost
    calc
      _ ≤ (L:ℝ)*(C*((L:ℝ)*(1/ε))^b + ((L:ℝ)*(1/ε))^b) :=
        mul_le_mul_of_nonneg_left (add_le_add cost precision) lpos.le
      _ = _ := by rw [mul_pow, pow_succ]; ring

end FQChem.StatePrep.CoupledClusterReplicas
