module

public import FormalQChem.Theorems.Dynamics
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add

public section

namespace FormalQChem.Dynamics

open Matrix
open scoped InnerProductSpace ComplexConjugate

variable {n m : Type*} [Fintype n] [DecidableEq n] [Fintype m] [DecidableEq m]

theorem splitOperator (V T : Matrix n n ℂ) : SplitOperator V T := by
  intro hV hT
  have product (A B : Matrix n n ℂ) (ha : Aᴴ * A = 1) (hb : Bᴴ * B = 1) :
      (A * B)ᴴ * (A * B) = 1 := by
    rw [conjTranspose_mul, Matrix.mul_assoc, ← Matrix.mul_assoc Aᴴ A, ha, one_mul, hb]
  exact product _ _ (product _ _ hV hT) hV

theorem krylovExact (H : Matrix n n ℂ) (Q : Matrix n m ℂ) (K : Matrix m m ℂ) :
    KrylovExact H Q K := by
  intro h k
  induction k with
  | zero => simp
  | succ k ih => rw [pow_succ, pow_succ, Matrix.mul_assoc, h, ← Matrix.mul_assoc, ih,
      Matrix.mul_assoc]

theorem krylovMoment (H : Matrix n n ℂ) (Q : Matrix n m ℂ) (v : Matrix n (Fin 1) ℂ)
    (d : ℕ) : KrylovMoment H Q v d := by
  intro h
  induction d with
  | zero => simpa [Matrix.mul_assoc] using h 0 (by omega)
  | succ d ih =>
    have prev := ih (fun j hj => h j (by omega))
    calc
      _ = (Q * Qᴴ) * (H * (Q * ((Qᴴ * H * Q) ^ d * (Qᴴ * v)))) := by
        rw [pow_succ']
        simp only [Matrix.mul_assoc]
      _ = (Q * Qᴴ) * (H ^ (d + 1) * v) := by rw [prev, pow_succ' H, Matrix.mul_assoc H]
      _ = _ := h _ le_rfl

omit [DecidableEq n] in
theorem pictureDuality (U ρ O : Matrix n n ℂ) : PictureDuality U ρ O := by
  unfold PictureDuality
  simp only [Matrix.mul_assoc]
  rw [trace_mul_comm U, Matrix.mul_assoc, Matrix.mul_assoc]

theorem pauliRotation (P Q : Matrix n n ℂ) (a b : ℂ) : PauliRotation P Q a b := by
  intro hP hcomm
  have hPQP : (P * Q) * P = -Q := by
    rw [Matrix.mul_assoc, hcomm, Matrix.mul_neg, ← Matrix.mul_assoc, hP, one_mul]
  simp only [add_mul, mul_sub, smul_mul_assoc, mul_smul_comm, one_mul, mul_one,
    hcomm, hPQP, smul_neg, add_smul]
  module

omit [DecidableEq n] in
theorem lindbladTrace (L ρ : Matrix n n ℂ) : LindbladTrace L ρ := by
  unfold LindbladTrace
  rw [trace_sub, trace_smul, trace_add, trace_mul_cycle L ρ Lᴴ,
    trace_mul_comm ρ (Lᴴ * L)]
  simp only [smul_eq_mul]
  ring

theorem krausTrace {a : Type*} [Fintype a] (K : a → Matrix n n ℂ) (ρ : Matrix n n ℂ) :
    KrausTrace K ρ := by
  intro h
  rw [trace_sum]
  simp_rw [trace_mul_cycle (K _) ρ]
  rw [← trace_sum, ← Matrix.sum_mul, h, one_mul]

theorem bornOppenheimerEnergy (mass : ℝ) (q v U : ℝ → ℝ) (t force : ℝ) :
    BornOppenheimerEnergy mass q v U t force := by
  intro hm hq hv hU
  have h := (((hv.pow 2).const_mul mass).div_const 2).add (hU.comp t hq)
  convert h using 1
  · funext s
    rfl
  · norm_num
    field_simp [hm.ne']
    ring

theorem invariantDirectionalForce {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
    (E : V → ℝ) (R : V ≃ₗᵢ[ℝ] V) (q : V) : InvariantDirectionalForce E R q := by
  intro hinv hdiff δ
  let r := R.toContinuousLinearEquiv.toContinuousLinearMap
  have h := hdiff.hasFDerivAt.comp q r.hasFDerivAt
  have eq : E ∘ R = E := funext hinv
  rw [eq] at h
  rw [h.fderiv]
  rfl

theorem ringPolymerSpringForce {b : Type*} [Fintype b] (next : Equiv.Perm b)
    (q : b → ℝ) (spring : ℝ) : RingPolymerSpringForce next q spring := by
  unfold RingPolymerSpringForce
  rw [← Finset.mul_sum, Finset.sum_sub_distrib, Finset.sum_add_distrib,
    Equiv.sum_comp next q, Equiv.sum_comp next.symm q, ← Finset.mul_sum]
  ring

theorem tdConfigurationInteraction {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (H : V →ₗ[ℝ] V) (a b : ℝ → V) (t : ℝ) : TDConfigurationInteraction H a b t := by
  intro hH ha hb
  have h := HasDerivAt.add (ha.inner ℝ ha) (hb.inner ℝ hb)
  convert h using 1
  rw [inner_neg_left, inner_neg_right, hH (b t) (a t), ← hH (a t) (b t)]
  ring

theorem sampledTangentMetric {s p : Type*} [Fintype s] [Fintype p]
    (weight : s → ℝ) (O : s → p → ℝ) (direction : p → ℝ) :
    SampledTangentMetric weight O direction := by
  intro hw centered covariance
  have expand (j k : p) : direction j * covariance j k * direction k =
      ∑ i, weight i * ((direction j * centered i j) * (direction k * centered i k)) := by
    dsimp [covariance]
    rw [Finset.mul_sum, Finset.sum_mul]
    exact Finset.sum_congr rfl fun i _ => by ring
  simp_rw [expand]
  simp_rw [Finset.sum_comm (f := fun k i => weight i * _)]
  rw [Finset.sum_comm]
  apply Finset.sum_nonneg
  intro i _
  simp_rw [← Finset.mul_sum]
  rw [← Finset.sum_mul]
  exact mul_nonneg (hw _) (mul_self_nonneg _)

theorem mcLachlanProjection {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (T : Submodule ℝ V) (exactVelocity trialVelocity : V) :
    McLachlanProjection T exactVelocity trialVelocity := by
  intro htrial horth v hv
  rw [show exactVelocity - v = (exactVelocity - trialVelocity) + (trialVelocity - v) by abel,
    norm_add_sq_real, horth _ (T.sub_mem htrial hv)]
  linarith [sq_nonneg ‖trialVelocity - v‖]

end FormalQChem.Dynamics
