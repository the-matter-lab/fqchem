module

public import Mathlib.LinearAlgebra.Matrix.Rank
public import Mathlib.Analysis.Complex.Basic

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

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

end FormalQChem.Algorithms
