module

public import FQChem.StatePrep.SubspaceDiagonalization.RitzGalerkin
public import Mathlib.Analysis.InnerProductSpace.Spectrum
import FQChem.StatePrep.VariationalOptimization.GapCertificate
import Mathlib.Order.Interval.Finset.Fin

/-!
# Ritz eigenvalue interlacing

Mathlib numbers Hermitian eigenvalues in decreasing order, counting multiplicities.
For a trial subspace of codimension d the kth Ritz value lies between the kth
and (k+d)th full eigenvalues. In increasing order this gives an upper bound for
every energy level accessible in the trial calculation.
[MacDonald (1933)](https://doi.org/10.1103/PhysRev.43.830).

Select more trial eigenvectors than excluded full eigenvectors. Their overlaps with
the excluded vectors define a rectangular map with nonzero kernel. The corresponding
nonzero state witnesses the overlap of the two allowed spectral bands.
-/

@[expose] public section

namespace FQChem.StatePrep.SubspaceDiagonalization.Interlacing

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [FiniteDimensional ℂ E]

/-- Embed kth index with the codimension offset. -/
def shiftedIndex {m n : ℕ} (hmn : m ≤ n) (k : Fin m) : Fin n :=
  ⟨k.val + (n - m), by omega⟩

/-- Two-sided Poincaré separation for the actual sorted spectra of a finite
Hermitian operator and its orthogonal compression to any trial subspace. -/
def RitzInterlacing (H : E →L[ℂ] E) (V : Submodule ℂ E) (hermitian : H.toLinearMap.IsSymmetric) :
    Prop :=
  ∃ hV : (projected H V).toLinearMap.IsSymmetric, ∀ k : Fin (Module.finrank ℂ V),
    hermitian.eigenvalues rfl (shiftedIndex V.finrank_le k) ≤ hV.eigenvalues rfl k ∧
    hV.eigenvalues rfl k ≤ hermitian.eigenvalues rfl (k.castLE V.finrank_le)

end FQChem.StatePrep.SubspaceDiagonalization.Interlacing

namespace FQChem.StatePrep.SubspaceDiagonalization.Interlacing

open FQChem.StatePrep.VariationalOptimization

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

private theorem spectral_witness {m n : ℕ} (V : Submodule ℂ E)
    (full : OrthonormalBasis (Fin n) ℂ E) (trial : OrthonormalBasis (Fin m) ℂ V)
    (A : Finset (Fin m)) (B : Finset (Fin n)) (more : B.card < A.card) :
    ∃ x : V, x ≠ 0 ∧ (∀ i ∉ A, inner ℂ (trial i) x = 0) ∧
      ∀ j ∈ B, inner ℂ (full j) (x : E) = 0 := by
  classical
  let build := Fintype.linearCombination ℂ (fun i : A ↦ trial i)
  let restrict : V →ₗ[ℂ] (B → ℂ) :=
    LinearMap.pi fun j ↦ (innerSL ℂ (full j)).toLinearMap.comp V.subtype
  have dimension : Module.finrank ℂ (B → ℂ) < Module.finrank ℂ (A → ℂ) := by simpa
  obtain ⟨z, hz, nz⟩ := Submodule.exists_mem_ne_zero_of_ne_bot
    (LinearMap.ker_ne_bot_of_finrank_lt (f := restrict.comp build) dimension)
  have inj : Function.Injective build :=
    linearIndependent_iff_injective_fintypeLinearCombination.mp
      (trial.toBasis.linearIndependent.comp _ Subtype.val_injective)
  refine ⟨build z, fun eq ↦ nz (inj (eq.trans (map_zero build).symm)), ?_, ?_⟩
  · intro i hi
    simp only [build, Fintype.linearCombination_apply, inner_sum, inner_smul_right]
    apply Finset.sum_eq_zero
    intro j _
    have ne : i ≠ j.val := fun e ↦ hi (e ▸ j.property)
    simp [trial.inner_eq_zero ne]
  · intro j hj
    exact congrFun (show restrict (build z) = 0 from hz) ⟨j, hj⟩

private theorem spectral_lower {n : ℕ} (H : E →L[ℂ] E) (b : OrthonormalBasis (Fin n) ℂ E)
    (energy : Fin n → ℝ) (hermitian : H.toLinearMap.IsSymmetric)
    (eigen : ∀ i, H (b i) = (energy i : ℂ) • b i) (x : E) (L : ℝ)
    (supported : ∀ i, inner ℂ (b i) x ≠ 0 → L ≤ energy i) :
    L * ‖x‖ ^ 2 ≤ H.reApplyInnerSelf x := by
  rw [spectralExpectation H b energy hermitian eigen, ← b.sum_sq_norm_inner_right x, Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  by_cases hz : inner ℂ (b i) x = 0
  · simp [hz]
  · exact mul_le_mul_of_nonneg_right (supported i hz) (sq_nonneg _)

private theorem spectral_upper {n : ℕ} (H : E →L[ℂ] E) (b : OrthonormalBasis (Fin n) ℂ E)
    (energy : Fin n → ℝ) (hermitian : H.toLinearMap.IsSymmetric)
    (eigen : ∀ i, H (b i) = (energy i : ℂ) • b i) (x : E) (U : ℝ)
    (supported : ∀ i, inner ℂ (b i) x ≠ 0 → energy i ≤ U) :
    H.reApplyInnerSelf x ≤ U * ‖x‖ ^ 2 := by
  rw [spectralExpectation H b energy hermitian eigen, ← b.sum_sq_norm_inner_right x, Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  by_cases hz : inner ℂ (b i) x = 0
  · simp [hz]
  · exact mul_le_mul_of_nonneg_right (supported i hz) (sq_nonneg _)

theorem ritzInterlacing [FiniteDimensional ℂ E] (H : E →L[ℂ] E) (V : Submodule ℂ E)
    (hH : H.toLinearMap.IsSymmetric) : RitzInterlacing H V hH := by
  classical
  let K := projected H V
  have hK : K.toLinearMap.IsSymmetric := by
    intro x y
    change inner ℂ (V.orthogonalProjectionOnto (H x)) y = inner ℂ x (V.orthogonalProjectionOnto (H y))
    rw [V.inner_orthogonalProjectionOnto_eq_of_mem_right, V.inner_orthogonalProjectionOnto_eq_of_mem_left]
    exact hH x y
  have agree (x : V) : K.reApplyInnerSelf x = H.reApplyInnerSelf (x : E) := by
    apply congrArg RCLike.re
    exact V.inner_orthogonalProjectionOnto_eq_of_mem_right x _
  let full := hH.eigenvectorBasis rfl
  let trial := hK.eigenvectorBasis rfl
  have monoH := hH.eigenvalues_antitone rfl
  have monoK := hK.eigenvalues_antitone rfl
  refine ⟨hK, fun k ↦ ?_⟩
  constructor
  · let j := shiftedIndex V.finrank_le k
    have more : (Finset.Ioi j).card < (Finset.Ici k).card := by
      simp [j, shiftedIndex]
      have := V.finrank_le
      omega
    obtain ⟨x, nx, tzero, fzero⟩ := spectral_witness V full trial _ _ more
    have lo := spectral_lower H full _ hH (hH.apply_eigenvectorBasis rfl) (x : E) _ (fun i hi ↦
      monoH (show i ≤ j from le_of_not_gt (fun gt ↦ hi (fzero i (Finset.mem_Ioi.mpr gt)))))
    have up := spectral_upper K trial _ hK (hK.apply_eigenvectorBasis rfl) x _ (fun i hi ↦
      monoK (show k ≤ i from by_contra fun neg ↦ hi (tzero i (fun mem ↦ neg (Finset.mem_Ici.mp mem)))))
    rw [agree] at up
    exact (mul_le_mul_iff_left₀ (sq_pos_of_pos (norm_pos_iff.mpr nx))).mp (lo.trans up)
  · let j := k.castLE V.finrank_le
    have more : (Finset.Iio j).card < (Finset.Iic k).card := by simp [j]
    obtain ⟨x, nx, tzero, fzero⟩ := spectral_witness V full trial _ _ more
    have lo := spectral_lower K trial _ hK (hK.apply_eigenvectorBasis rfl) x _ (fun i hi ↦
      monoK (show i ≤ k from by_contra fun neg ↦ hi (tzero i (fun mem ↦ neg (Finset.mem_Iic.mp mem)))))
    have up := spectral_upper H full _ hH (hH.apply_eigenvectorBasis rfl) (x : E) _ (fun i hi ↦
      monoH (show j ≤ i from le_of_not_gt (fun lt ↦ hi (fzero i (Finset.mem_Iio.mpr lt)))))
    rw [agree] at lo
    exact (mul_le_mul_iff_left₀ (sq_pos_of_pos (norm_pos_iff.mpr nx))).mp (lo.trans up)

end FQChem.StatePrep.SubspaceDiagonalization.Interlacing
