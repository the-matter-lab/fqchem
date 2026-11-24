module

public import FQChem.Complexity.ElectronicStructurePauli
import Mathlib.Tactic

/-!
# Local Pauli classical shadows

Huang, Kueng and Preskill, Supplementary Sec. 3, Lemma 3
(https://doi.org/10.1038/s41567-020-0932-7). Work on the k-qubit support of a
Pauli observable. A uniformly random X/Y/Z measurement is chosen independently
at each site. A shot contributes only when all choices match the observable.
The Born law below is evaluated on the reduced density matrix of that support.
-/

@[expose] public section
noncomputable section
namespace FQChem.Properties.ClassicalShadows

open FQChem.Complexity.ElectronicStructure

abbrev Setting (k : ℕ) := Fin k → Fin 3

def axis (a : Fin 3) : Pauli := ![Pauli.X, Pauli.Y, Pauli.Z] a
def sign (b : Bool) : ℂ := if b then -1 else 1

/-- Matrix entry of the local spectral projector (I + s P)/2 for outcome s. -/
def projector (a : Fin 3) (b r c : Bool) : ℂ :=
  ((if r = c then 1 else 0) + sign b * (axis a).entry r c) / 2

variable {k : ℕ}

private theorem projector_sum (a : Fin 3) (r c : Bool) :
    ∑ b, projector a b r c = if r = c then 1 else 0 := by
  simp only [Fintype.sum_bool, projector, sign, ite_true, Bool.false_eq_true, ite_false]
  ring

private theorem signed_projector_sum (a : Fin 3) (r c : Bool) :
    ∑ b, projector a b r c * sign b = (axis a).entry r c := by
  simp only [Fintype.sum_bool, projector, sign, ite_true, Bool.false_eq_true, ite_false]
  ring

/-- Born probability of a full outcome string conditional on the local axes.
The trace formula extends linearly to arbitrary matrices. -/
def bornWeight (ρ : Matrix (Spin k) (Spin k) ℂ) (a : Setting k) (s : Spin k) : ℂ :=
  ∑ x, ∑ y, ρ x y * ∏ i, projector (a i) (s i) (y i) (x i)

/-- Single-shot classical-shadow estimate of a Pauli string of weight k. -/
def estimate (p a : Setting k) (s : Spin k) : ℂ :=
  if a = p then 3 ^ k * ∏ i, sign (s i) else 0

/-- Average over uniformly chosen local axes and Born-rule outcomes. -/
def mean (ρ : Matrix (Spin k) (Spin k) ℂ) (f : Setting k → Spin k → ℂ) : ℂ :=
  (∑ a, ∑ s, bornWeight ρ a s * f a s) / 3 ^ k

private theorem weighted_sum (ρ : Matrix (Spin k) (Spin k) ℂ) (a : Setting k)
    (f : Fin k → Bool → ℂ) :
    ∑ s : Spin k, bornWeight ρ a s * ∏ i, f i (s i) =
      ∑ x, ∑ y, ρ x y * ∏ i, ∑ b, projector (a i) b (y i) (x i) * f i b := by
  simp only [bornWeight, Finset.sum_mul, mul_assoc, ← Finset.prod_mul_distrib]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro x _
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro y _
  rw [← Finset.mul_sum, Fintype.prod_sum]

/-- The local Pauli estimator is unbiased for every reduced density matrix.
The right-hand side is Tr(ρP) in the computational basis. -/
theorem unbiased (ρ : Matrix (Spin k) (Spin k) ℂ) (p : Setting k) :
    mean ρ (estimate p) = ∑ x, ∑ y, ρ x y * wordEntry (axis ∘ p) y x := by
  classical
  have hm : ∀ a : Setting k, (∑ s, bornWeight ρ a s * estimate p a s) =
      if a = p then 3 ^ k * ∑ s, bornWeight ρ p s * ∏ i, sign (s i) else 0 := by
    intro a
    split_ifs with h
    · subst a
      simp only [estimate, ite_true, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro s _
      ring
    · simp [estimate, h]
  simp only [mean, hm, Finset.sum_ite_eq', Finset.mem_univ, ite_true]
  rw [mul_div_cancel_left₀ _ (pow_ne_zero k (by norm_num) : (3 : ℂ) ^ k ≠ 0)]
  simpa only [signed_projector_sum, wordEntry, Function.comp_apply] using
    weighted_sum ρ p (fun _ => sign)

/-- The second moment of a weight-k Pauli shadow is exactly 3^k on every
trace-one state. This is the Pauli-string case of the squared shadow norm. -/
theorem secondMoment (ρ : Matrix (Spin k) (Spin k) ℂ) (hρ : ρ.trace = 1) (p : Setting k) :
    mean ρ (fun a s => estimate p a s ^ 2) = 3 ^ k := by
  classical
  have unit (s : Spin k) : (∏ i, sign (s i)) ^ 2 = 1 := by
    rw [← Finset.prod_pow]
    exact Finset.prod_eq_one fun i _ => by cases s i <;> norm_num [sign]
  have mass : ∑ s, bornWeight ρ p s = 1 := by
    have h := weighted_sum ρ p (fun _ _ => 1)
    simp only [mul_one, Finset.prod_const_one, projector_sum] at h
    rw [h]
    simpa [Fintype.prod_ite_zero, ← funext_iff, mul_ite, Matrix.trace] using hρ
  have hm : ∀ a : Setting k, (∑ s, bornWeight ρ a s * estimate p a s ^ 2) =
      if a = p then ((3 : ℂ) ^ k) ^ 2 else 0 := by
    intro a
    split_ifs with h
    · subst a
      simp only [estimate, ite_true, mul_pow, unit, mul_one, ← Finset.sum_mul, mass, one_mul]
    · simp [estimate, h]
  simp only [mean, hm, Finset.sum_ite_eq', Finset.mem_univ, ite_true]
  rw [sq, mul_div_cancel_right₀ _ (pow_ne_zero k (by norm_num))]
end FQChem.Properties.ClassicalShadows
