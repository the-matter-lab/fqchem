module

public import FQChem.Dynamics.RealTimePropagation.OutOfTimeOrder
public import Mathlib.Analysis.Matrix.PosDef
import Mathlib.Tactic

/-! # Pauli correlations for the partially revealed observable experiment

The uniform nonidentity Pauli second-moment bound at the end of Huang et al.,
Supplementary Appendix D.3.d, Eq. (D35). A positive measurement effect may have
any rank. [Original paper](https://doi.org/10.1126/science.abn7293)
-/

@[expose] public section
noncomputable section

namespace FQChem.Properties.PauliPrediction

open FQChem.Complexity.ElectronicStructure FQChem.Dynamics.OTOC Matrix
open scoped Classical BigOperators ComplexConjugate ComplexOrder
variable {n : ℕ}

def identityWord (n : ℕ) : Word n := fun _ => .I
def nonidentity (n : ℕ) := (Finset.univ : Finset (Word n)).erase (identityWord n)
def dimension (n : ℕ) : ℝ := 2^n

/-- The raw and normalized trace scores of an individual POVM effect. -/
def correlation (E : Operator n) (p : Word n) := (E * wordMatrix p).trace.re

def response (E : Operator n) (p : Word n) := correlation E p / E.trace.re

theorem identityMatrix : wordMatrix (identityWord n) = 1 := by
  ext i j
  change wordEntry (identityWord n) i j = _
  rw [wordEntry_eq]
  simp [identityWord, logicalMove, logicalPhase, Pauli.move, Pauli.phase, Matrix.one_apply, eq_comm]

theorem pauliHermitian (p : Word n) : (wordMatrix p).IsHermitian := by
  ext i j
  change conj (wordEntry p j i) = wordEntry p i j
  have localH (q : Pauli) (a b : Bool) : conj (q.entry a b) = q.entry b a := by
    cases q <;> cases a <;> cases b <;> simp [Pauli.entry, Pauli.move, Pauli.phase]
  simp [wordEntry, localH]

theorem pauliSquare (p : Word n) : wordMatrix p * wordMatrix p = 1 := by
  have single (q : Pauli) (x y : Bool) :
      (∑ b : Bool, q.entry x b * q.entry b y) = (if x=y then (1:ℂ) else 0) := by
    cases q <;> cases x <;> cases y <;>
      norm_num [Fintype.sum_bool, Pauli.entry, Pauli.move, Pauli.phase]
  ext x y
  change (∑ z : Spin n, (∏ i, (p i).entry (x i) (z i)) * ∏ i, (p i).entry (z i) (y i)) = _
  simp_rw [← Finset.prod_mul_distrib]
  rw [← Fintype.prod_sum (fun i b => (p i).entry (x i) b * (p i).entry b (y i))]
  simp only [single, Fintype.prod_ite_zero, Finset.prod_const_one, Matrix.one_apply]
  simp [funext_iff]

theorem pauliTrace (p : Word n) (hp : p ∈ nonidentity n) : (wordMatrix p).trace = 0 := by
  have hn : p ≠ identityWord n := (Finset.mem_erase.mp hp).1
  obtain ⟨j,hj⟩ := Function.ne_iff.mp hn
  change (∑ x : Spin n, ∏ i, (p i).entry (x i) (x i)) = 0
  rw [← Fintype.prod_sum (fun i x => (p i).entry x x)]
  apply Finset.prod_eq_zero (Finset.mem_univ j)
  change p j ≠ .I at hj
  cases h : p j <;> simp_all [Pauli.entry, Pauli.move, Pauli.phase]

private theorem purityBound (E : Operator n) (h : E.PosSemidef) :
    (E * E).trace.re ≤ E.trace.re^2 := by
  let U := h.1.eigenvectorUnitary
  let values := h.1.eigenvalues
  let D := Matrix.diagonal (RCLike.ofReal ∘ values : Spin n → ℂ)
  have he : E = Unitary.conjStarAlgAut ℂ _ U D := h.1.spectral_theorem
  have tr (B : Operator n) : (Unitary.conjStarAlgAut ℂ _ U B).trace = B.trace := by
    rw [Unitary.conjStarAlgAut_apply, Matrix.trace_mul_cycle, Unitary.coe_star_mul_self, Matrix.one_mul]
  rw [he, ← map_mul, tr, tr, Matrix.diagonal_mul_diagonal, Matrix.trace_diagonal,
    Matrix.trace_diagonal, Complex.re_sum, Complex.re_sum]
  simpa [values, Function.comp_def, pow_two, Pi.mul_apply, RCLike.ofReal_real_eq_id]
    using Finset.sum_sq_le_sq_sum_of_nonneg (s := Finset.univ) (fun i _ => h.eigenvalues_nonneg i)

private theorem parseval (E : Operator n) (h : E.IsHermitian) :
    ∑ p : Word n, correlation E p ^ 2 = dimension n * (E * E).trace.re := by
  have em : E = ∑ p : Word n, pauliCoefficient E p • wordMatrix p := by
    ext x y
    simp only [Matrix.sum_apply, Matrix.smul_apply, smul_eq_mul]
    exact (pauliExpansion E x y).symm
  have e (p : Word n) : (E * wordMatrix p).trace = (pauliCoefficient E p).re * (2:ℂ)^n := by
    rw [pauliCoefficient_real E h]
    exact (div_eq_iff (by positivity)).mp (traceCoefficient E p)
  have hs : (E * E).trace = ∑ p : Word n, ((pauliCoefficient E p).re : ℂ) ^ 2 * (2:ℂ)^n := by
    conv_lhs => arg 1; arg 2; rw [em]
    simp only [Matrix.mul_sum, Matrix.mul_smul, Matrix.trace_sum, Matrix.trace_smul,
      smul_eq_mul, e, pauliCoefficient_real E h]
    ring_nf
  have castDim : (2 : ℂ)^n = ((2^n : ℝ) : ℂ) := by push_cast; rfl
  rw [castDim] at hs
  have hr := congrArg Complex.re hs
  simp only [Complex.re_sum, ← Complex.ofReal_pow, ← Complex.ofReal_mul, Complex.ofReal_re] at hr
  have er (p : Word n) : correlation E p = (pauliCoefficient E p).re * (2:ℝ)^n := by
    simpa only [correlation, castDim, ← Complex.ofReal_mul, Complex.ofReal_re] using congrArg Complex.re (e p)
  simp_rw [er, mul_pow]
  rw [← Finset.sum_mul, hr, ← Finset.sum_mul, dimension]
  ring

theorem nonidentityCount (n : ℕ) :
    ((nonidentity n).card : ℝ) = (dimension n - 1) * (dimension n + 1) := by
  have h4 : 0 < 4^n := by positivity
  have hcard : (nonidentity n).card = 4^n - 1 := by
    simp [nonidentity, Finset.card_erase_of_mem, Word, Fintype.card_congr Pauli.index]
  rw [hcard, Nat.cast_sub (by omega : 1 ≤ 4^n), Nat.cast_pow, Nat.cast_ofNat, Nat.cast_one]
  unfold dimension
  rw [show (4:ℝ) = 2*2 by norm_num, mul_pow]
  ring

/-- Eq. (D35) averaged over nonidentity Paulis. Pure effects attain equality;
mixed normalized effects obey the same upper bound. -/
theorem nonidentitySecondMoment (E : Operator n) (h : E.PosSemidef) :
    ∑ p ∈ nonidentity n, response E p ^ 2 ≤ dimension n - 1 := by
  have hD : 1 ≤ dimension n := one_le_pow₀ (by norm_num)
  have htr := Complex.nonneg_iff.mp h.trace_nonneg |>.1
  by_cases ht : E.trace.re = 0
  · simp [response, ht, sub_nonneg.mpr hD]
  have split := Finset.sum_erase_add (s := (Finset.univ : Finset (Word n)))
    (fun p => correlation E p ^ 2) (Finset.mem_univ (identityWord n))
  rw [show correlation E (identityWord n) = E.trace.re by simp [correlation, identityMatrix],
    parseval E h.1] at split
  simp only [response, div_pow, ← Finset.sum_div]
  apply (div_le_iff₀ (sq_pos_of_ne_zero ht)).mpr
  have hp := mul_le_mul_of_nonneg_left (purityBound E h) (by positivity : 0 ≤ dimension n)
  unfold nonidentity
  linarith

/-- Each normalized POVM effect returns a Pauli expectation in [-1,1]. -/
theorem responseAbs (E : Operator n) (h : E.PosSemidef) (p : Word n) : |response E p| ≤ 1 := by
  let W := wordMatrix p
  have hW : Wᴴ = W := (pauliHermitian p).eq
  have ww : W*W=1 := pauliSquare p
  have plus := (h.conjTranspose_mul_mul_same (1+W)).trace_nonneg
  have minus := (h.conjTranspose_mul_mul_same (1-W)).trace_nonneg
  have pos := (Complex.nonneg_iff.mp plus).1
  have neg := (Complex.nonneg_iff.mp minus).1
  rw [conjTranspose_add, conjTranspose_one, hW, Matrix.trace_mul_cycle] at pos
  rw [conjTranspose_sub, conjTranspose_one, hW, Matrix.trace_mul_cycle] at neg
  have pp : (1+W)*(1+W)=2•(1+W) := by noncomm_ring [ww]
  have mm : (1-W)*(1-W)=2•(1-W) := by noncomm_ring [ww]
  rw [pp, two_nsmul, Matrix.add_mul, Matrix.trace_add, Matrix.add_mul, Matrix.one_mul, Matrix.trace_add, Matrix.trace_mul_comm W E, Complex.add_re, Complex.add_re] at pos
  rw [mm, two_nsmul, Matrix.add_mul, Matrix.trace_add, Matrix.sub_mul, Matrix.one_mul, Matrix.trace_sub, Matrix.trace_mul_comm W E, Complex.add_re, Complex.sub_re] at neg
  have ht := (Complex.nonneg_iff.mp h.trace_nonneg).1
  by_cases hz : E.trace.re = 0
  · simp [response,hz]
  rw [response, abs_div, abs_of_nonneg ht, div_le_one (lt_of_le_of_ne ht (Ne.symm hz))]
  apply abs_le.mpr
  change -E.trace.re ≤ (E*W).trace.re ∧ (E*W).trace.re ≤ E.trace.re
  constructor <;> linarith

/-- The two alternatives are indexed by a hidden fair sign; the null state has zero bias. -/
def hardState (p : Word n) (a : ℝ) : Operator n :=
  ((dimension n : ℂ)⁻¹) • (1 + (a : ℂ) • wordMatrix p)

theorem hardStateTrace (p : Word n) (hp : p ∈ nonidentity n) (a : ℝ) :
    (hardState p a).trace = 1 := by
  have dim : Fintype.card (Spin n) = 2^n := by simp [Spin]
  simp [hardState, dimension, Matrix.trace_add, Matrix.trace_smul, pauliTrace p hp,
    Matrix.trace_one, dim]

theorem hardStateTracePairing (p : Word n) (hp : p ∈ nonidentity n) (a : ℝ) :
    (hardState p a * wordMatrix p).trace = (a : ℂ) := by
  have dim : Fintype.card (Spin n) = 2^n := by simp [Spin]
  simp [hardState, dimension, Matrix.add_mul, pauliSquare, Matrix.trace_smul, Matrix.trace_add,
    pauliTrace p hp, Matrix.trace_one, dim]
  field_simp

theorem hardStatePositive (p : Word n) {a : ℝ} (ha : |a| ≤ 1) : (hardState p a).PosSemidef := by
  let W := wordMatrix p
  have hw : Wᴴ = W := (pauliHermitian p).eq
  have ww : W * W = 1 := pauliSquare p
  have plus := Matrix.posSemidef_conjTranspose_mul_self (1 + W)
  have minus := Matrix.posSemidef_conjTranspose_mul_self (1 - W)
  rw [conjTranspose_add, conjTranspose_one, hw] at plus
  rw [conjTranspose_sub, conjTranspose_one, hw] at minus
  have hp : (1 + W) * (1 + W) = 1 + W + (1 + W) := by noncomm_ring [ww]
  have hm : (1 - W) * (1 - W) = 1 - W + (1 - W) := by noncomm_ring [ww]
  rw [hp] at plus
  rw [hm] at minus
  have h1 : (0 : ℝ) ≤ (1+a)/4 := by linarith [(abs_le.mp ha).1]
  have h2 : (0 : ℝ) ≤ (1-a)/4 := by linarith [(abs_le.mp ha).2]
  have pos := (plus.smul h1).add (minus.smul h2)
  have he : ((1+a)/4) • (1 + W + (1 + W)) + ((1-a)/4) • (1 - W + (1 - W)) =
      1 + (a : ℂ) • W := by
    ext i j
    simp only [Matrix.add_apply, Matrix.sub_apply, Matrix.smul_apply, Complex.real_smul, smul_eq_mul,
      Complex.ofReal_div, Complex.ofReal_add, Complex.ofReal_sub, Complex.ofReal_one, Complex.ofReal_ofNat]
    ring
  rw [he] at pos
  have hd : (0 : ℂ) ≤ ((dimension n : ℝ) : ℂ)⁻¹ := by
    rw [← Complex.ofReal_inv]; unfold dimension; exact_mod_cast (by positivity : (0:ℝ) ≤ (2^n:ℝ)⁻¹)
  exact pos.smul hd

end FQChem.Properties.PauliPrediction
