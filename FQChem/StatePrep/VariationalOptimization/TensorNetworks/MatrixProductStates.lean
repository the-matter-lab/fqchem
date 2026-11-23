module

public import Mathlib.LinearAlgebra.Matrix.Rank
public import Mathlib.Analysis.Complex.Basic
import Mathlib.Tactic

@[expose] public section
noncomputable section

namespace FQChem.Algorithms

/-- One local matrix is selected by the physical label at each site in an MPS. -/
def siteMatrices {k d χ : ℕ} (A : Fin k → Fin d → Matrix (Fin χ) (Fin χ) ℂ)
    (x : Fin k → Fin d) := List.ofFn (fun i => A i (x i))

/-- Open-boundary cut matrix. Flattening physical configurations on either side of
a bond of dimension χ gives a coefficient matrix of rank at most χ. -/
def MPSCutBound (l r d χ : ℕ) : Prop :=
  ∀ (A : Fin l → Fin d → Matrix (Fin χ) (Fin χ) ℂ)
    (B : Fin r → Fin d → Matrix (Fin χ) (Fin χ) ℂ) (a b : Fin χ),
    (Matrix.of fun (x : Fin l → Fin d) (y : Fin r → Fin d) =>
      ((siteMatrices A x ++ siteMatrices B y).prod) a b).rank ≤ χ

/-- A single bipartition admits a bond-D factorization exactly when the coefficient
matrix has rank at most D. Both factors may have rectangular physical dimensions. -/
def ExactCutFactorization (rows cols D : ℕ) : Prop :=
  ∀ C : Matrix (Fin rows) (Fin cols) ℂ, C.rank ≤ D ↔
    ∃ (L : Matrix (Fin rows) (Fin D) ℂ) (R : Matrix (Fin D) (Fin cols) ℂ), C = L * R

theorem mpsCutBound (l r d χ : ℕ) : MPSCutBound l r d χ := by
  intro A B a b
  let L := Matrix.of fun (x : Fin l → Fin d) (j : Fin χ) => (siteMatrices A x).prod a j
  let R := Matrix.of fun (j : Fin χ) (y : Fin r → Fin d) => (siteMatrices B y).prod j b
  have factor : (Matrix.of fun (x : Fin l → Fin d) (y : Fin r → Fin d) =>
      ((siteMatrices A x ++ siteMatrices B y).prod) a b) = L * R := by
    ext x y
    simp only [Matrix.of_apply, List.prod_append, Matrix.mul_apply, L, R]
  rw [factor]
  exact (Matrix.rank_mul_le_left L R).trans (by simpa using L.rank_le_card_width)

theorem exactCutFactorization (rows cols D : ℕ) : ExactCutFactorization rows cols D := by
  intro C
  constructor
  · intro h
    let f := C.mulVecLin
    have hdim : Module.finrank ℂ (LinearMap.range f) ≤ Module.finrank ℂ (Fin D → ℂ) := by
      simpa only [Matrix.rank, f, Module.finrank_pi, Fintype.card_fin] using h
    obtain ⟨encode, hinj⟩ := finrank_le_iff_exists_linearMap.mp hdim
    obtain ⟨decode, hleft⟩ := encode.exists_leftInverse_of_injective (LinearMap.ker_eq_bot.mpr hinj)
    let L := (LinearMap.range f).subtype.comp decode
    let R := encode.comp f.rangeRestrict
    refine ⟨LinearMap.toMatrix' L, LinearMap.toMatrix' R, ?_⟩
    rw [← LinearMap.toMatrix'_comp]
    have hcomp : L.comp R = f := by
      apply LinearMap.ext
      intro x
      exact congrArg Subtype.val (LinearMap.congr_fun hleft (f.rangeRestrict x))
    rw [hcomp]
    exact (LinearMap.toMatrix'.apply_symm_apply C).symm
  · rintro ⟨L, R, rfl⟩
    exact (Matrix.rank_mul_le_left L R).trans L.rank_le_width

end FQChem.Algorithms
