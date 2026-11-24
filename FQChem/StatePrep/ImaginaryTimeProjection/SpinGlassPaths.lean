module

public import FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
public import FQChem.StatePrep.ImaginaryTimeProjection.SignProblem
import Mathlib.Analysis.Matrix.Normed
import Mathlib.Tactic

/-! # Powers, closed spin-flip paths and bosonic reweighting

[Troyer and Wiese, Eqs. (4)–(8)](https://doi.org/10.1103/PhysRevLett.94.170201).
Each positive Taylor order is a finite closed-path measure. In the frustrated model
some path weights are signed, while the ferromagnetic partner has exactly their moduli.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
open Matrix FQChem.StatePrep.ImaginaryTimeProjection.SignProblem
variable {n : ℕ}

/-- Sum all possible intermediate configurations in one power of the signed transition kernel. -/
theorem kernelPaths (g : Glass n) (k : ℕ) (x y : Spin n) :
    ((-g.hamiltonian)^(k+1)) x y =
      ∑ z : Fin k → Spin n, pathWeight g x (List.ofFn z ++ [y]) := by
  induction k generalizing x with
  | zero => simp [pathWeight]
  | succ k ih =>
    rw [pow_succ' _ (k+1), Matrix.mul_apply]
    conv_rhs => rw [← Equiv.sum_comp (Fin.consEquiv (fun _ => Spin n)), Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro u _
    rw [ih, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro z _
    simp [Fin.consEquiv, List.ofFn_succ, pathWeight]

abbrev Closed (n k : ℕ) := Spin n × (Fin k → Spin n)

def taylorWeight (g : Glass n) (β : ℝ) (k : ℕ) (p : Closed n k) :=
  (β^(k+1) / (k+1).factorial) * pathWeight g p.1 (List.ofFn p.2 ++ [p.1])

/-- The signed closed paths sum to the exact order-(k+1) trace Taylor coefficient. -/
theorem taylorTrace (g : Glass n) (β : ℝ) (k : ℕ) :
    (∑ p : Closed n k, taylorWeight g β k p) =
      (β^(k+1) / (k+1).factorial) * ((-g.hamiltonian)^(k+1)).trace := by
  simp only [Closed, taylorWeight, Fintype.sum_prod_type, Matrix.trace, Matrix.diag_apply,
    kernelPaths, Finset.mul_sum]

open scoped Matrix.Norms.Operator in
/-- Eq. (4) as a convergent series, including the trace of the identity at order zero. -/
theorem taylorPartition (g : Glass n) (β : ℝ) :
    HasSum (fun k => match k with
      | 0 => (2:ℝ)^n
      | k+1 => ∑ p : Closed n k, taylorWeight g β k p)
      (NormedSpace.exp ((-β) • g.hamiltonian)).trace := by
  let tr := Matrix.traceLinearMap (Spin n) ℝ ℝ
  have h := (NormedSpace.exp_series_hasSum_exp' (𝕂 := ℝ) ((-β) • g.hamiltonian)).map
    tr.toAddMonoidHom tr.continuous_of_finiteDimensional
  apply h.congr_fun
  intro k
  symm
  change (((k.factorial : ℝ)⁻¹) • ((-β) • g.hamiltonian)^k).trace = _
  cases k with
  | zero => simp [Matrix.trace_one, Spin]
  | succ k =>
    change _ = ∑ p : Closed n k, taylorWeight g β k p
    rw [taylorTrace, show (-β) • g.hamiltonian = β • (-g.hamiltonian) by simp, smul_pow,
      Matrix.trace_smul, Matrix.trace_smul]
    simp only [smul_eq_mul, div_eq_mul_inv]
    ring

theorem taylorAbsolute (g : Glass n) (β : ℝ) (hβ : 0 ≤ β) (k : ℕ) (p : Closed n k) :
    taylorWeight g.ferro β k p = |taylorWeight g β k p| := by
  simp only [taylorWeight, absolute_path, abs_mul]
  rw [abs_of_nonneg (by positivity : 0 ≤ β^(k+1) / ((k+1).factorial : ℝ))]

def bosonicMean (g : Glass n) (β : ℝ) (k : ℕ) (f : Closed n k → ℝ) :=
  (∑ p, taylorWeight g.ferro β k p * f p) / ∑ p, taylorWeight g.ferro β k p

/-- Eq. (6) specialized to each positive Taylor order with nonzero signed mass:
the signed observable is the bosonic signed observable divided by the bosonic mean sign. -/
theorem taylorReweighting (g : Glass n) (β : ℝ) (hβ : 0 ≤ β) (k : ℕ) (f : Closed n k → ℝ)
    (_h : (∑ p : Closed n k, taylorWeight g β k p) ≠ 0) :
    (∑ p, taylorWeight g β k p * f p) / ∑ p, taylorWeight g β k p =
      bosonicMean g β k (fun p => sign (taylorWeight g β k p) * f p) /
        bosonicMean g β k (fun p => sign (taylorWeight g β k p)) := by
  have base (a : Closed n k → ℝ) : bosonicMean g β k a = absMean (taylorWeight g β k) a := by
    simp [bosonicMean, absMean, taylorAbsolute g β hβ k]
  rw [base, base, absMean_sign, reweighting]

end FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
