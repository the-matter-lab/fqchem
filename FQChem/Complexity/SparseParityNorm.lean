module

public import FQChem.Complexity.SpinPathEvolution
public import Mathlib.Analysis.CStarAlgebra.Matrix
import Mathlib.Analysis.Matrix.Spectrum
import Mathlib.Tactic

/-!
# Spectral norm of the crossed parity path

The positive binomial eigenvector bounds every eigenvalue in absolute value and
attains the bound. The norm here is the Hilbert-space operator norm entering the
scaled time in [Berry et al., Theorem 3](https://doi.org/10.1007/s00220-006-0150-x).
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SparseParityNorm
open FQChem.Complexity.SparseParityPath FQChem.Complexity.SpinPathEvolution Matrix
open scoped Matrix.Norms.L2Operator
variable {N : ℕ}

private def w (v : Vertex N) : ℝ := Real.sqrt (N.choose v.1 : ℝ)

private theorem w_pos (v : Vertex N) : 0 < w v := by
  exact Real.sqrt_pos_of_pos (by exact_mod_cast Nat.choose_pos (Nat.le_of_lt_succ v.1.isLt))

private theorem eigen (x : Fin N → Bool) :
    (crossed x).mulVec (fun v => (w v : ℂ)) = (N/2 : ℂ) • (fun v => (w v : ℂ)) := by
  funext r
  have h := congrFun (binomial_eigenvector N) r.1
  rw [crossed_eq_lift,Matrix.mulVec_apply, dotProduct, Fintype.sum_prod_type]
  change (∑ j : Level N, ∑ b : Bool,
    (if (r.2 ^^ prefixParity x r.1) = (b ^^ prefixParity x j) then path N r.1 j else 0) *
      coeff N j) = _
  rw [Matrix.mulVec_apply] at h
  apply Eq.trans _ h
  apply Finset.sum_congr rfl
  intro j _
  simp only [Fintype.sum_bool]
  cases r.2 <;> cases prefixParity x r.1 <;> cases prefixParity x j <;> simp

private theorem positive_entries (x : Fin N → Bool) (r c : Vertex N) :
    (‖crossed x r c‖ : ℂ) = crossed x r c := by
  simp only [crossed, Matrix.of_apply]
  split_ifs <;> simp [weight, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg (Real.sqrt_nonneg _)]

private theorem row_mass (x : Fin N → Bool) (r : Vertex N) :
    ∑ k, ‖crossed x r k‖ * w k = ((N:ℝ)/2) * w r := by
  apply Complex.ofReal_injective
  push_cast
  simp only [positive_entries]
  exact congrFun (eigen x) r

private theorem eigenvalue_bound (x : Fin N → Bool) (μ : ℝ) (u : Vertex N → ℂ)
    (hu : u ≠ 0) (eig : (crossed x).mulVec u = μ • u) : |μ| ≤ (N:ℝ)/2 := by
  obtain ⟨i,_,hi⟩ := Finset.exists_max_image Finset.univ (fun i => ‖u i‖/w i) Finset.univ_nonempty
  have hmax (j : Vertex N) : ‖u j‖ ≤ (‖u i‖/w i) * w j :=
    (div_le_iff₀ (w_pos j)).mp (hi j (Finset.mem_univ j))
  have hi0 : 0 < ‖u i‖ := by
    by_contra! hn
    have hz := le_antisymm hn (norm_nonneg _)
    apply hu
    funext j
    apply norm_eq_zero.mp
    exact le_antisymm (by simpa [hz] using hmax j) (norm_nonneg _)
  apply le_of_mul_le_mul_right _ hi0
  calc |μ| * ‖u i‖ = ‖((crossed x).mulVec u) i‖ := by rw [eig]; simp [Real.norm_eq_abs]
    _ ≤ ∑ j, ‖crossed x i j * u j‖ := norm_sum_le _ _
    _ ≤ ∑ j, (‖u i‖/w i) * (‖crossed x i j‖ * w j) := by
      apply Finset.sum_le_sum
      intro j _
      rw [norm_mul]
      calc _ ≤ ‖crossed x i j‖ * ((‖u i‖/w i) * w j) := mul_le_mul_of_nonneg_left (hmax j) (norm_nonneg _)
        _ = _ := by ring
    _ = ((N:ℝ)/2) * ‖u i‖ := by
      rw [← Finset.mul_sum, row_mass]
      field_simp [(w_pos i).ne']

/-- Every input gives a Hermitian crossed matrix with spectral norm exactly N/2. -/
theorem spectral_norm (x : Fin N → Bool) : ‖crossed x‖ = (N:ℝ)/2 := by
  have h := hermitian x
  apply le_antisymm
  · conv_lhs => rw [h.spectral_theorem]
    rw [Unitary.conjStarAlgAut_apply, ← Unitary.coe_star, CStarRing.norm_mul_coe_unitary,
      CStarRing.norm_coe_unitary_mul, Matrix.l2_opNorm_diagonal]
    apply (pi_norm_le_iff_of_nonneg (by positivity)).mpr
    intro j
    have nz := (WithLp.ofLp_eq_zero 2).ne.2 (h.eigenvectorBasis.orthonormal.ne_zero j)
    simpa [Function.comp_def, RCLike.ofReal_real_eq_id, Complex.norm_real, Real.norm_eq_abs] using
      eigenvalue_bound x _ _ nz (h.mulVec_eigenvectorBasis j)
  · let v : EuclideanSpace ℂ (Vertex N) := WithLp.toLp 2 (fun i => (w i : ℂ))
    have vne : v ≠ 0 := by
      intro he
      have hz : (w (0,false) : ℂ) = 0 := congrArg (fun z : EuclideanSpace ℂ (Vertex N) => z (0,false)) he
      exact (Complex.ofReal_ne_zero.mpr (w_pos (N:=N) (0,false)).ne') hz
    have b := (crossed x).l2_opNorm_mulVec v
    change ‖WithLp.toLp 2 ((crossed x).mulVec (fun i => (w i : ℂ)))‖ ≤ ‖crossed x‖ * ‖v‖ at b
    rw [eigen] at b
    change ‖(N/2 : ℂ) • v‖ ≤ _ at b
    rw [norm_smul] at b
    have nrm : ‖(N/2:ℂ)‖ = (N:ℝ)/2 := by simp
    exact le_of_mul_le_mul_right (nrm ▸ b) (norm_pos_iff.mpr vne)

end FQChem.Complexity.SparseParityNorm
