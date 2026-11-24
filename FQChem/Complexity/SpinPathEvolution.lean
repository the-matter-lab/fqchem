module

public import FQChem.Complexity.SparseParityPath
import Mathlib.Analysis.SpecialFunctions.Exponential
public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Deriv
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Analysis.Matrix.Normed
import Mathlib.Tactic

/-!
# Evolution on the spin path

The tridiagonal path in [Berry et al., Theorem 3](https://doi.org/10.1007/s00220-006-0150-x)
is the spin-N/2 rotation in the basis of excitation counts. Its amplitudes arise from the
binomial expansion of N identical two-level amplitudes.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SpinPathEvolution
open FQChem.Complexity.SparseParityPath Matrix NormedSpace
open scoped Matrix.Norms.Operator

def coeff (N j : ℕ) : ℂ := (Real.sqrt (N.choose j : ℝ) : ℝ)

private theorem couplings (N j : ℕ) :
    2 * weight N j * coeff N (j + 1) = coeff N j * ((N-j : ℕ) : ℂ) ∧
    2 * weight N j * coeff N j = coeff N (j+1) * ((j+1 : ℕ) : ℂ) := by
  have hc : (N.choose (j+1) : ℝ) * ((j+1 : ℕ) : ℝ) = (N.choose j : ℝ) * ((N-j : ℕ) : ℝ) := by
    exact_mod_cast Nat.choose_succ_right_eq N j
  have hs (m n k l : ℕ) (h : (k : ℝ) * n = (l : ℝ) * m) :
      Real.sqrt ((m:ℝ) * n) * Real.sqrt k = Real.sqrt l * m := by
    have eq : (Real.sqrt ((m:ℝ) * n) * Real.sqrt k)^2 = (Real.sqrt l * m)^2 := by
      simp only [mul_pow, Real.sq_sqrt (show 0 ≤ (m:ℝ)*n by positivity),
        Real.sq_sqrt (show 0 ≤ (k:ℝ) by positivity), Real.sq_sqrt (show 0 ≤ (l:ℝ) by positivity)]
      linear_combination (m : ℝ) * h
    nlinarith [show 0 ≤ Real.sqrt ((m:ℝ)*n)*Real.sqrt k by positivity,
      show 0 ≤ Real.sqrt l * m by positivity]
  have h1 := hs (N-j) (j+1) (N.choose (j+1)) (N.choose j) hc
  have h2 := hs (j+1) (N-j) (N.choose j) (N.choose (j+1)) hc.symm
  rw [mul_comm ((j+1 : ℕ) : ℝ)] at h2
  have c1 := congrArg Complex.ofReal h1
  have c2 := congrArg Complex.ofReal h2
  constructor <;> unfold weight coeff <;> push_cast at *
  · linear_combination c1
  · linear_combination c2

/-- The normalized binomial coefficient is the excitation-basis amplitude
for the product of N identical single-spin states with amplitudes a and b. -/
def wave (N : ℕ) (a b : ℂ) (j : Level N) : ℂ :=
  coeff N j * a ^ (N-j.val) * b ^ j.val

private theorem row_action (N : ℕ) (a b : ℂ) (j : Level N) :
    2 * ((path N).mulVec (wave N a b)) j =
      coeff N j * (((N-j.val : ℕ) : ℂ) * a^(N-j.val-1) * b^(j.val+1) +
        (j.val : ℂ) * a^(N-j.val+1) * b^(j.val-1)) := by
  let hi (k : Level N) := if j.val+1 = k.val then weight N j.val * wave N a b k else 0
  let lo (k : Level N) := if k.val+1 = j.val then weight N k.val * wave N a b k else 0
  have act : ((path N).mulVec (wave N a b)) j = (∑ k, hi k) + ∑ k, lo k := by
    rw [← Finset.sum_add_distrib, Matrix.mulVec_apply]
    apply Finset.sum_congr rfl
    intro k _
    by_cases h : j.val+1 = k.val
    · have hn : k.val+1 ≠ j.val := by omega
      simp [path, hi, lo, h, hn]
    · simp [path, hi, lo, h, ite_mul]
  have up : 2 * (∑ k, hi k) =
      coeff N j * ((N-j.val : ℕ) : ℂ) * a^(N-j.val-1) * b^(j.val+1) := by
    by_cases h : j.val < N
    · let k : Level N := ⟨j.val+1,by omega⟩
      rw [Finset.sum_eq_single k]
      · have e : N-k.val = N-j.val-1 := by dsimp [k]; omega
        simp only [hi, k, ↓reduceIte, wave]
        rw [show N - (j.val+1) = N-j.val-1 by omega]
        linear_combination a^(N-j.val-1) * b^(j.val+1) * (couplings N j).1
      · intro i _ hne
        have : j.val+1 ≠ i.val := fun he => hne (Fin.ext he.symm)
        simp [hi,this]
      · simp
    · have hn : N-j.val = 0 := by omega
      have hz (i : Level N) : j.val+1 ≠ i.val := by have := i.isLt; omega
      simp [hi, hz, hn]
  have down : 2 * (∑ k, lo k) =
      coeff N j * (j.val : ℂ) * a^(N-j.val+1) * b^(j.val-1) := by
    by_cases h : 0 < j.val
    · let k : Level N := ⟨j.val-1, by have := j.isLt; omega⟩
      have eq : k.val + 1 = j.val := by dsimp [k]; omega
      have ed : N - k.val = N-j.val+1 := by have := j.isLt; dsimp [k]; omega
      rw [Finset.sum_eq_single k]
      · have c := (couplings N k.val).2
        rw [eq] at c
        simp only [lo, eq, ↓reduceIte, wave, ed]
        linear_combination a^(N-j.val+1) * b^(j.val-1) * c
      · intro i _ hne
        have hn : i.val+1 ≠ j.val := fun he => hne (Fin.ext (by dsimp [k]; omega))
        simp [lo,hn]
      · simp
    · have hj : j.val = 0 := by omega
      simp [lo, hj]
  rw [act,mul_add,up,down]
  ring


/-- The same binomial coefficients at equal single-spin amplitudes form a strictly
positive eigenvector of the path with eigenvalue N/2. -/
theorem binomial_eigenvector (N : ℕ) :
    (path N).mulVec (fun j => coeff N j) = (N / 2 : ℂ) • (fun j : Level N => coeff N j) := by
  funext j
  have h := row_action N 1 1 j
  have w : wave N 1 1 = fun j : Level N => coeff N j := by funext k; simp [wave]
  simp only [w, one_pow, mul_one, Nat.cast_sub (Nat.le_of_lt_succ j.isLt)] at h
  change (path N *ᵥ (fun j => coeff N j)) j = (N / 2 : ℂ) * coeff N j
  linear_combination h / 2

private def state (N : ℕ) (t : ℂ) : Level N → ℂ :=
  wave N (Complex.cos (t/2)) (-Complex.I * Complex.sin (t/2))

private theorem state_deriv (N : ℕ) (t : ℂ) (j : Level N) :
    HasDerivAt (fun z => state N z j)
      (((-Complex.I) • path N).mulVec (state N t) j) t := by
  let a (z : ℂ) := Complex.cos (z/2)
  let b (z : ℂ) := -Complex.I * Complex.sin (z/2)
  have hd : HasDerivAt (fun z : ℂ => z/2) (1/2) t := (hasDerivAt_id t).div_const 2
  have ha : HasDerivAt a (-Complex.I / 2 * b t) t := by
    convert! (Complex.hasDerivAt_cos (t/2)).comp t hd using 1
    dsimp [b]
    linear_combination (Complex.sin (t/2)/2) * Complex.I_sq
  have hb : HasDerivAt b (-Complex.I / 2 * a t) t := by
    convert! ((Complex.hasDerivAt_sin (t/2)).comp t hd).const_mul (-Complex.I) using 1
    dsimp [a]; ring
  have h := (HasDerivAt.const_mul (coeff N j) (ha.pow (N-j.val))).mul (hb.pow j.val)
  convert! h using 1
  rw [Matrix.smul_mulVec, Pi.smul_apply, smul_eq_mul]
  change -Complex.I * (path N *ᵥ wave N (a t) (b t)) j = _
  have e := row_action N (a t) (b t) j
  simp only [pow_succ] at e
  simp only [Pi.pow_apply]
  linear_combination (-Complex.I / 2) * e

/-- A finite constant-coefficient Schrödinger equation with given initial column
has the matrix exponential as its propagator. -/
private theorem exp_column {n : Type} [Fintype n] [DecidableEq n] (A : Matrix n n ℂ)
    (v : ℂ → n → ℂ) (dv : ∀ z i, HasDerivAt (fun w => v w i) (A.mulVec (v z) i) z)
    (t : ℂ) : (exp (t • A)).mulVec (v 0) = v t := by
  let E (z : ℂ) := exp ((t-z) • A)
  have de (z : ℂ) (i k : n) : HasDerivAt (fun w => E w i k) (-((E z * A) i k)) z := by
    have h := (hasDerivAt_exp_smul_const A (t-z)).scomp z ((hasDerivAt_const z t).sub (hasDerivAt_id z))
    let ev := (Matrix.entryLinearMap ℂ ℂ i k).toContinuousLinearMap
    have he := ev.hasFDerivAt.comp_hasDerivAt z h
    convert! he using 1
    change -((E z * A) i k) = ((0 - 1 : ℂ) • (E z * A)) i k
    simp
  funext i
  have he (z : ℂ) : HasDerivAt (fun w => ((E w).mulVec (v w)) i) 0 z := by
    have h := HasDerivAt.fun_sum (u := Finset.univ) (fun k _ => (de z i k).mul (dv z k))
    convert! h using 1
    rw [Finset.sum_add_distrib]
    simp only [neg_mul, Finset.sum_neg_distrib]
    change 0 = -(((E z * A).mulVec (v z)) i) + ((E z).mulVec (A.mulVec (v z))) i
    rw [Matrix.mulVec_mulVec]
    abel
  have eq := is_const_of_deriv_eq_zero (fun z => (he z).differentiableAt)
    (fun z => (he z).deriv) (0 : ℂ) t
  simpa [E] using eq

private theorem state_zero (N : ℕ) : state N 0 = Pi.single 0 1 := by
  funext j
  by_cases hj : j = 0
  · subst j
    simp [state, wave, coeff]
  · have hn : j.val ≠ 0 := by simpa using hj
    simp [state,wave,hn, Pi.single_eq_of_ne hj]

/-- Every entry in the first column of the propagator is a binomial spin amplitude. -/
theorem evolution_column (N : ℕ) (t : ℝ) (j : Level N) :
    exp ((-(t:ℂ) * Complex.I) • path N) j 0 =
      wave N (Real.cos (t/2) : ℂ) (-Complex.I * (Real.sin (t/2) : ℂ)) j := by
  have h := congrFun (exp_column ((-Complex.I) • path N) (state N) (state_deriv N) (t : ℂ)) j
  rw [state_zero, Matrix.mulVec_single_one, smul_smul, mul_neg, ← neg_mul] at h
  refine h.trans ?_
  have hs : Complex.sin ((t : ℂ) / 2) = (Real.sin (t/2) : ℂ) := by
    rw [Complex.ofReal_sin]; push_cast; rfl
  have hc : Complex.cos ((t : ℂ) / 2) = (Real.cos (t/2) : ℂ) := by
    rw [Complex.ofReal_cos]; push_cast; rfl
  simp only [state, hc, hs]

/-- Exact spin-path amplitude at the right endpoint for arbitrary physical time. -/
theorem transfer_amplitude (N : ℕ) (t : ℝ) :
    exp ((-(t:ℂ) * Complex.I) • path N) (Fin.last N) 0 =
      (-Complex.I * (Real.sin (t/2) : ℂ)) ^ N := by
  rw [evolution_column]
  simp [wave, coeff]

/-- Rotation by π transfers the entire population between the endpoints. -/
theorem perfect_transfer (N : ℕ) :
    ‖exp ((-(Real.pi:ℂ) * Complex.I) • path N) (Fin.last N) 0‖ = 1 := by
  rw [transfer_amplitude]
  simp

end FQChem.Complexity.SpinPathEvolution
