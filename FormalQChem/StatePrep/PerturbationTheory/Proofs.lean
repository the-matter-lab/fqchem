module

public import FormalQChem.StatePrep.PerturbationTheory.Theorems

/-! # Solving the perturbation equations in the unperturbed eigenbasis -/

@[expose] public section

namespace FormalQChem.StatePrep.PerturbationTheory

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

omit [Fintype ι] [DecidableEq ι] in
private theorem gap_ne_zero {e : ι → ℝ} {k i : ι} (simple : Nondegenerate e k) (hi : i ≠ k) :
    ((e k - e i : ℝ) : ℂ) ≠ 0 := by
  exact_mod_cast sub_ne_zero.mpr (simple i hi).symm

private theorem shift_sum (e : ι → ℝ) (V : Matrix ι ι ℂ) (k : ι) (hermitian : V.IsHermitian) :
    ∑ j, V k j * firstResponse e V k j = (quadraticShift e V k : ℂ) := by
  rw [← Finset.sum_erase_add _ _ (Finset.mem_univ k)]
  simp only [firstResponse, ite_true, mul_zero, add_zero, quadraticShift, Complex.ofReal_sum]
  apply Finset.sum_congr rfl
  intro j hj
  rw [ite_eq_right (Finset.ne_of_mem_erase hj), ← hermitian.apply k j, ← mul_div_assoc,
    Complex.ofReal_div, Complex.normSq_eq_conj_mul_self]
  rfl

theorem nondegenerateExpansion (e : ι → ℝ) (V : Matrix ι ι ℂ) (k : ι) :
    NondegenerateExpansion e V k := by
  intro simple hermitian
  let a := firstResponse e V k
  let b (i : ι) : ℂ := if i = k then 0 else
    ((∑ j, V i j * a j) - V k k * a i) / ((e k - e i : ℝ) : ℂ)
  have ak : a k = 0 := by simp [a, firstResponse]
  have bk : b k = 0 := by simp [b]
  constructor
  · refine ⟨b, ak, bk, ?_, ?_⟩
    · intro i
      by_cases hi : i = k
      · subst i
        simp
      · have hgap := gap_ne_zero simple hi
        simp only [firstResponse, ite_eq_right hi, mul_zero, add_zero]
        field_simp [hgap]
        push_cast
        ring
    · intro i
      by_cases hi : i = k
      · subst i
        simpa [ak, bk, a] using shift_sum e V k hermitian
      · have hgap := gap_ne_zero simple hi
        simp only [b, ite_eq_right hi, mul_zero, add_zero]
        field_simp [hgap]
        push_cast
        ring
  · intro u v E₁ E₂ eqs
    have hE₁ : E₁ = V k k := by
      simpa [eqs.first_reference] using (eqs.linear k).symm
    have hu : u = a := by
      funext i
      by_cases hi : i = k
      · subst i
        rw [eqs.first_reference, ak]
      · have h := eqs.linear i
        simp only [ite_eq_right hi, mul_zero, add_zero] at h
        simp only [a, firstResponse, ite_eq_right hi]
        apply (eq_div_iff (gap_ne_zero simple hi)).mpr
        push_cast
        linear_combination -h
    refine ⟨hE₁, hu, ?_⟩
    have h := eqs.quadratic k
    simp only [eqs.first_reference, eqs.second_reference, mul_zero, ite_true, mul_one,
      add_zero, zero_add] at h
    rw [← h, hu]
    exact shift_sum e V k hermitian

theorem residualIdentity_of_coefficients (e : ι → ℝ) (V : Matrix ι ι ℂ) (k : ι)
    {a b : ι → ℂ} {E₁ E₂ : ℂ} (matched : CoefficientEquations e V k a b E₁ E₂) :
    ResidualIdentity e V k a b E₁ E₂ := by
  intro t
  constructor
  · simp [truncatedState, matched.first_reference, matched.second_reference]
  · intro i
    let d : ℂ := if i = k then 1 else 0
    have initial : (e i : ℂ) * d = (e k : ℂ) * d := by
      by_cases hi : i = k <;> simp [d, hi]
    have first : (e i : ℂ) * a i + V i k = e k * a i + E₁ * d := matched.linear i
    have second : (e i : ℂ) * b i + V.mulVec a i = e k * b i + E₁ * a i + E₂ * d :=
      matched.quadratic i
    simp only [perturbedHamiltonian, Matrix.add_mulVec, Pi.add_apply, Matrix.mulVec_diagonal,
      Matrix.smul_mulVec, truncatedState, Matrix.mulVec_add, Matrix.mulVec_smul,
      Matrix.mulVec_single_one, Matrix.col_apply, Pi.smul_apply, smul_eq_mul, truncatedEnergy]
    have single : (Pi.single k 1 : ι → ℂ) i = d := by by_cases hi : i = k <;> simp [hi, d]
    rw [single]
    linear_combination (norm := ring_nf) initial + t * first + t ^ 2 * second
    by_cases hi : i = k <;> simp [hi, d]

theorem secondOrderQuasimode (e : ι → ℝ) (V : Matrix ι ι ℂ) (k : ι) :
    SecondOrderQuasimode e V k := by
  intro gap hermitian
  obtain ⟨b, matched⟩ := (nondegenerateExpansion e V k gap hermitian).1
  exact ⟨b, residualIdentity_of_coefficients e V k matched⟩

end FormalQChem.StatePrep.PerturbationTheory
