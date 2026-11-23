module

public import FormalQChem.Properties.MeasurementTheory.Theorems
import Mathlib.Tactic

public section
namespace FormalQChem.Properties.MeasurementTheory

open scoped InnerProductSpace
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E]
variable {ι : Type*} [Fintype ι]

theorem bornCompleteness (K : ι → E →L[ℂ] E) : BornCompleteness K := by
  intro hK ψ hn
  refine ⟨fun i => sq_nonneg _, ?_⟩
  simp only [probability, ContinuousLinearMap.apply_norm_sq_eq_inner_adjoint_right]
  have hsum : (∑ i, (K i).adjoint.comp (K i) ψ) = ψ := by
    simpa using congrArg (fun T : E →L[ℂ] E => T ψ) hK
  rw [← map_sum, ← inner_sum, hsum, inner_self_eq_norm_sq, hn, one_pow]

omit [CompleteSpace E] [Fintype ι] in
theorem projectiveRepeatability [DecidableEq ι] (P : ι → E →L[ℂ] E) :
    ProjectiveRepeatability P := by
  intro hP ψ i hi
  have hn : ‖P i ψ‖ ≠ 0 := by
    intro h
    simp [probability, h] at hi
  have unit : ‖posterior (P i) ψ‖ = 1 := by
    simp [posterior, norm_smul, Complex.norm_real, hn]
  refine ⟨unit, fun j => ?_⟩
  have hx := congrArg (fun A : E →L[ℂ] E => A ψ) (hP i j)
  by_cases h : i = j
  · subst j
    simp at hx
    have fixed : P i (posterior (P i) ψ) = posterior (P i) ψ := by simp [posterior, hx]
    simp only [probability, fixed, unit, one_pow, ite_true]
  · simp [h] at hx
    simp [probability, posterior, h, hx]

theorem unsharpQubit : UnsharpQubit := by
  intro a b η hn hlo hhi
  dsimp only
  have weights (x : ℝ) (hx : -1 ≤ x) (hx' : x ≤ 1) :
      Complex.normSq (weakBranch x a b).1 = (1+x)/2 * Complex.normSq a ∧
      Complex.normSq (weakBranch x a b).2 = (1-x)/2 * Complex.normSq b := by
    simp only [weakBranch, Complex.normSq_mul, Complex.normSq_ofReal, Real.mul_self_sqrt (by linarith : 0 ≤ (1+x)/2),
      Real.mul_self_sqrt (by linarith : 0 ≤ (1-x)/2), and_self]
  have plus := weights η hlo hhi
  have minus := weights (-η) (by linarith) (by linarith)
  have hp : branchMass (weakBranch η a b) = (1 + η*(Complex.normSq a - Complex.normSq b))/2 := by
    unfold branchMass
    rw [plus.1, plus.2]
    linarith
  refine ⟨hp, ?_, ?_⟩
  · simp only [branchMass, plus.1, plus.2, minus.1, minus.2]
    linarith
  · intro _
    unfold branchZ
    rw [plus.1, plus.2, hp]
    have hd : (1+η)/2*Complex.normSq a - (1-η)/2*Complex.normSq b =
        (Complex.normSq a - Complex.normSq b + η)/2 := by nlinarith [congrArg (η * ·) hn]
    rw [hd, div_div_div_cancel_right₀ (by norm_num : (2 : ℝ) ≠ 0)]

end FormalQChem.Properties.MeasurementTheory
