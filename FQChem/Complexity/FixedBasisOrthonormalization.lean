module

public import Mathlib.Analysis.Matrix.Order
import Mathlib.Tactic

/-! # Global symmetric orthonormalization of a fixed orbital basis

Löwdin's transformation acts on the entire overlap matrix. A spectral-norm
bound on S−I gives both exact orthonormality of the new orbital frame and
a quantitative bound on the change of any one-electron matrix. -/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.FixedBasisOrthonormalization
open Matrix
open scoped Matrix.Norms.L2Operator Kronecker
variable {ι : Type*} [Fintype ι] [DecidableEq ι]
abbrev OrbitalMatrix (ι : Type*) := Matrix ι ι ℂ

def spectral (S : OrbitalMatrix ι) (h : S.IsHermitian) (f : ℝ → ℝ) : OrbitalMatrix ι :=
  Unitary.conjStarAlgAut ℂ _ h.eigenvectorUnitary (diagonal fun i => (f (h.eigenvalues i) : ℂ))

/-- Symmetric inverse square root of the overlap, in its orthonormal eigenbasis. -/
def transform (S : OrbitalMatrix ι) (h : S.IsHermitian) := spectral S h fun x => (Real.sqrt x)⁻¹

private theorem spectralDistance (S : OrbitalMatrix ι) (h : S.IsHermitian) (f : ℝ → ℝ) :
    ‖spectral S h f - 1‖ = ‖fun i => (f (h.eigenvalues i) : ℂ) - 1‖ := by
  let U := Unitary.conjStarAlgAut ℂ _ h.eigenvectorUnitary
  have sub : spectral S h f - 1 =
      U (diagonal (fun i => (f (h.eigenvalues i) : ℂ) - 1)) := by
    change U _ - 1 = _
    have de : diagonal (fun i => (f (h.eigenvalues i) : ℂ)-1) =
        diagonal (fun i => (f (h.eigenvalues i) : ℂ)) - 1 := by rw [← diagonal_one, ← diagonal_sub]
    rw [de,map_sub,map_one]
  rw [sub]
  simp only [U, Unitary.conjStarAlgAut_apply, ← Unitary.coe_star,
    CStarRing.norm_mul_coe_unitary, CStarRing.norm_coe_unitary_mul, l2_opNorm_diagonal]

private theorem squareRootBound {x δ : ℝ} (h : |x-1| ≤ δ) (small : δ ≤ 1/2) :
    0 < x ∧ |(Real.sqrt x)⁻¹-1| ≤ 2*δ := by
  have ⟨lo,hi⟩ := abs_le.mp h
  have hx : 0<x := by linarith
  have a := Real.sq_sqrt hx.le
  have pos := Real.sqrt_pos.mpr hx
  have lower : 1/2 ≤ Real.sqrt x := by nlinarith
  have rel : |(Real.sqrt x)⁻¹-1| * (Real.sqrt x*(Real.sqrt x+1)) = |1-x| := by
    rw [← abs_of_pos (mul_pos pos (by linarith) : 0<Real.sqrt x*(Real.sqrt x+1)), ← abs_mul]
    congr 1
    field_simp
    nlinarith
  have denom : 1/2 ≤ Real.sqrt x*(Real.sqrt x+1) := by nlinarith
  rw [abs_sub_comm (1:ℝ) x] at rel
  refine ⟨hx,?_⟩
  nlinarith [mul_nonneg (abs_nonneg ((Real.sqrt x)⁻¹-1)) (sub_nonneg.mpr denom)]

/-- A global overlap error δ≤1/2 controls the change to the entire orthogonalizing
matrix. There is no assumption that individual orbital pairs can be treated separately. -/
theorem globalTransform (S : OrbitalMatrix ι) (h : S.IsHermitian) (δ : ℝ)
    (close : ‖S-1‖ ≤ δ) (small : δ ≤ 1/2) :
    let R := transform S h
    R.IsHermitian ∧ R * S * R = 1 ∧ ‖R-1‖ ≤ 2*δ := by
  have specId : spectral S h id = S := h.spectral_theorem.symm
  have evalBound (i : ι) : |h.eigenvalues i - 1| ≤ δ := by
    rw [← specId, spectralDistance] at close
    simpa only [id_eq, ← Complex.ofReal_one, ← Complex.ofReal_sub, Complex.norm_real, Real.norm_eq_abs]
      using (norm_le_pi_norm (fun i => ((h.eigenvalues i : ℝ) : ℂ)-1) i).trans close
  have scalar := fun i => squareRootBound (evalBound i) small
  let U := Unitary.conjStarAlgAut ℂ _ h.eigenvectorUnitary
  let d := fun i => (((Real.sqrt (h.eigenvalues i))⁻¹ : ℝ) : ℂ)
  have herm : (diagonal d).IsHermitian := by
    rw [isHermitian_iff_isSelfAdjoint, IsSelfAdjoint, Matrix.star_eq_conjTranspose,
      diagonal_conjTranspose]
    simp [d]
  refine ⟨?_,?_,?_⟩
  · exact (isHermitian_iff_isSelfAdjoint).mpr ((isHermitian_iff_isSelfAdjoint.mp herm).map U)
  · change U (diagonal d) * S * U (diagonal d) = 1
    conv_lhs => rw [h.spectral_theorem]
    change U _ * U _ * U _ = _
    rw [← map_mul, ← map_mul, ← U.map_one]
    apply congrArg U
    rw [diagonal_mul_diagonal,diagonal_mul_diagonal,← diagonal_one]
    congr 1
    funext i
    have sq := Real.sq_sqrt (scalar i).1.le
    have nz := (Real.sqrt_pos.mpr (scalar i).1).ne'
    dsimp [d,Function.comp_def]
    norm_cast
    field_simp
    nlinarith
  · rw [transform,spectralDistance]
    apply (pi_norm_le_iff_of_nonneg (by linarith [norm_nonneg (S-1)] : 0 ≤ 2*δ)).mpr
    intro i
    simpa only [← Complex.ofReal_one, ← Complex.ofReal_sub, Complex.norm_real, Real.norm_eq_abs]
      using (scalar i).2

/-- In particular the columns of B R have identity Gram matrix. -/
theorem orthonormalColumns {κ : Type*} [Fintype κ] (B : Matrix κ ι ℂ)
    (δ : ℝ) (close : ‖Bᴴ*B-1‖ ≤ δ) (small : δ≤1/2) :
    let R := transform (Bᴴ*B) (isHermitian_conjTranspose_mul_self B)
    (B*R)ᴴ * (B*R) = 1 := by
  let S := Bᴴ*B
  have h := isHermitian_conjTranspose_mul_self B
  obtain ⟨herm,exactGram,_⟩ := globalTransform S h δ close small
  change (B*transform S h)ᴴ * (B*transform S h) = 1
  rw [conjTranspose_mul, herm.eq]
  simpa only [S, Matrix.mul_assoc] using exactGram

private theorem sandwichError (R T : OrbitalMatrix ι) (η : ℝ) (d : ‖R-1‖ ≤ η) :
    ‖R*T*R-T‖ ≤ (2*η+η^2)*‖T‖ := by
  let D := R-1
  have δ0 : 0≤η := (norm_nonneg _).trans d
  have eq : R*T*R-T = D*T*D + (D*T+T*D) := by dsimp [D]; noncomm_ring
  change ‖R*T*R-T‖ ≤ _
  rw [eq]
  calc
    _ ≤ ‖D*T*D‖ + (‖D*T‖+‖T*D‖) := (norm_add_le _ _).trans (add_le_add (le_refl _) (norm_add_le _ _))
    _ ≤ (η*‖T‖)*(η) + (η*‖T‖+‖T‖*(η)) := by
      gcongr
      · exact (norm_mul_le _ _).trans (mul_le_mul ((norm_mul_le _ _).trans
          (mul_le_mul_of_nonneg_right d (norm_nonneg T))) d (norm_nonneg D) (by positivity))
      · exact (norm_mul_le _ _).trans (mul_le_mul_of_nonneg_right d (norm_nonneg _))
      · exact (norm_mul_le _ _).trans (mul_le_mul_of_nonneg_left d (norm_nonneg _))
    _ = _ := by ring

/-- Orthonormalizing both indices of a one-electron integral matrix costs at
most (4δ+4δ²) times its spectral norm. -/
theorem oneBodyError (S T : OrbitalMatrix ι) (h : S.IsHermitian) (δ : ℝ)
    (close : ‖S-1‖ ≤ δ) (small : δ ≤ 1/2) :
    let R := transform S h
    ‖R*T*R-T‖ ≤ (4*δ+4*δ^2)*‖T‖ := by
  convert sandwichError (transform S h) T (2*δ) (globalTransform S h δ close small).2.2 using 1
  ring_nf

/-- The change of basis on both electron coordinates is close to the identity
in the joint spectral norm. The estimate is independent of basis size. -/
theorem pairTransform (S : OrbitalMatrix ι) (h : S.IsHermitian) (δ : ℝ)
    (close : ‖S-1‖ ≤ δ) (small : δ≤1/2) :
    let R := transform S h
    ‖R ⊗ₖ R - 1‖ ≤ 4*δ+4*δ^2 := by
  let Q := h.eigenvectorUnitary
  let Q₂ : unitary (OrbitalMatrix (ι × ι)) :=
    ⟨(Q.val ⊗ₖ Q.val), kronecker_mem_unitary Q.prop Q.prop⟩
  let U := Unitary.conjStarAlgAut ℂ _ Q₂
  let d := fun i => (((Real.sqrt (h.eigenvalues i))⁻¹ : ℝ) : ℂ)
  let v := fun p : ι × ι => d p.1 * d p.2
  have de : transform S h ⊗ₖ transform S h = U (diagonal v) := by
    simp only [U,Q₂,Unitary.conjStarAlgAut_apply, transform,spectral,
      Matrix.star_eq_conjTranspose, conjTranspose_kronecker, mul_kronecker_mul,
      diagonal_kronecker_diagonal]
    rfl
  have offset : transform S h ⊗ₖ transform S h - 1 = U (diagonal (fun p => v p-1)) := by
    rw [de]
    have diag : diagonal (fun p => v p-1) = diagonal v - 1 := by rw [← diagonal_one,← diagonal_sub]
    rw [diag,map_sub,map_one]
  have dnorm : ‖fun i => d i - 1‖ ≤ 2*δ := by
    simpa only [transform, spectralDistance] using (globalTransform S h δ close small).2.2
  have b (i : ι) : ‖d i-1‖ ≤ 2*δ := (norm_le_pi_norm _ i).trans dnorm
  have δ0 := (norm_nonneg _).trans close
  dsimp only
  rw [offset]
  simp only [U,Unitary.conjStarAlgAut_apply,← Unitary.coe_star,
    CStarRing.norm_mul_coe_unitary,CStarRing.norm_coe_unitary_mul,l2_opNorm_diagonal]
  apply (pi_norm_le_iff_of_nonneg (by positivity : 0 ≤ 4*δ+4*δ^2)).mpr
  rintro ⟨i,j⟩
  have eq : v (i,j)-1 = (d i-1)*(d j-1) + ((d i-1)+(d j-1)) := by dsimp [v]; ring
  rw [eq]
  have t := norm_add_le ((d i-1)*(d j-1)) ((d i-1)+(d j-1))
  have prod := mul_le_mul (b i) (b j) (norm_nonneg _) (by positivity)
  rw [norm_mul] at t
  nlinarith [norm_add_le (d i-1) (d j-1), b i, b j]

/-- All four indices of the two-electron repulsion matrix transform together.
If the overlap error is δ, its spectral perturbation is bounded by
((1+2δ)⁴−1) times the original two-electron norm. -/
theorem twoBodyError (S : OrbitalMatrix ι) (V : OrbitalMatrix (ι×ι)) (h : S.IsHermitian)
    (δ : ℝ) (close : ‖S-1‖ ≤ δ) (small : δ≤1/2) :
    let P := transform S h ⊗ₖ transform S h
    ‖P*V*P-V‖ ≤ ((1+2*δ)^4-1)*‖V‖ := by
  convert sandwichError (transform S h ⊗ₖ transform S h) V _ (pairTransform S h δ close small) using 1
  ring_nf

end FQChem.Complexity.FixedBasisOrthonormalization
