module

public import Qatlib.Concepts.QsvtCore.PhaseExistence.Corollary8ComplexPhaseExistenceGily
public import Qatlib.Concepts.QsvtCore.QsVtMain.ConventionBridge

/-! # Polynomial singular-value transformation

In the finite-dimensional formulation of Gilyén, Su, Low and Wiebe, choose orthonormal
frames `R` and `L` for the input and output projectors. The encoded rectangular matrix is
`A = Lᴴ * U * R`. For even degree the word begins with the adjoint oracle. The right
singular transform then acts on the entire input space, including the kernel of `A`.

* [Gilyén et al., Corollary 8 and Theorem 17, Eq. (32)](https://arxiv.org/abs/1806.01838)
-/

@[expose] public section

namespace FQChemQatlib.Dynamics.SingularValueTransformation

open Matrix Polynomial
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.CoherentSim.CoherentOAA
open Qatlib.Concepts.WalkSearch.Spectral Qatlib.Concepts.PhaseGeometry.Phase
open Qatlib.Concepts.QsvtCore.QsVtMain Qatlib.Concepts.QsvtCore.PhaseExistence
open Qatlib.Concepts.QsvtCore.PhaseExistence.PhaseSynthesis

variable {H I O : Type} [Fintype H] [DecidableEq H] [Fintype I] [DecidableEq I]
  [Fintype O] [DecidableEq O] {A : Matrix O I ℂ} {U : Matrix H H ℂ}
  {L : Matrix H O ℂ} {R : Matrix H I ℂ}

/-- Theorem 17, Eq. (32). A realizing phase sequence transforms the singular values of
the encoded matrix by `P`. This includes the empty word with response `P = 1`. -/
theorem singularValueTransformationOfPhases (h : ProjectedUnitaryEncoding A U L R)
    (Φ : List ℝ) (P : Polynomial ℂ) (hP : sourcePhaseResponse Φ = P) :
    (Φ.length % 2 = 1 →
      rangeProjector L * phasedAlternating U (rangeProjector R) (rangeProjector L) 1
          (Φ.map anglePhase) * rangeProjector R =
        L * oddSingularTransform A (fun x : ℝ => P.eval (x : ℂ)) * Rᴴ) ∧
    (Φ.length % 2 = 0 →
      rangeProjector R * phasedAlternating Uᴴ (rangeProjector L) (rangeProjector R) 1
          (Φ.map anglePhase) * rangeProjector R =
        R * rightSingularTransform A (fun x : ℝ => P.eval (x : ℂ)) * Rᴴ) := by
  subst P
  exact ⟨source_corner_odd_eq h Φ, source_corner_even_eq h Φ⟩

/-- Corollary 8 and Theorem 17. Every admissible complex polynomial of positive degree `d`
has `d` realizing phases. Its alternating word implements the odd or even singular transform. -/
theorem polynomialSingularValueTransformation (h : ProjectedUnitaryEncoding A U L R)
    (P : Polynomial ℂ) (d : ℕ) (hd : 0 < d) (hdeg : P.natDegree = d)
    (hparity : HasResponseParity d P)
    (hin : ∀ x : ℝ, x ∈ Set.Icc (-1 : ℝ) 1 → Complex.normSq (P.eval (x : ℂ)) ≤ 1)
    (hout : ∀ x : ℝ, x ∉ Set.Ioo (-1 : ℝ) 1 → 1 ≤ Complex.normSq (P.eval (x : ℂ)))
    (himag : d % 2 = 0 → ∀ y : ℝ, 1 ≤ Complex.normSq (P.eval ((y : ℂ) * Complex.I))) :
    ∃ Φ : List ℝ, Φ.length = d ∧ sourcePhaseResponse Φ = P ∧
      (d % 2 = 1 →
        rangeProjector L * phasedAlternating U (rangeProjector R) (rangeProjector L) 1
            (Φ.map anglePhase) * rangeProjector R =
          L * oddSingularTransform A (fun x : ℝ => P.eval (x : ℂ)) * Rᴴ) ∧
      (d % 2 = 0 →
        rangeProjector R * phasedAlternating Uᴴ (rangeProjector L) (rangeProjector R) 1
            (Φ.map anglePhase) * rangeProjector R =
          R * rightSingularTransform A (fun x : ℝ => P.eval (x : ℂ)) * Rᴴ) := by
  obtain ⟨Φ, hlen, hP, _⟩ := corollary8ComplexPhaseExistence P d hd hdeg hparity hin hout himag
  refine ⟨Φ, hlen, hP, ?_⟩
  simpa only [← hlen] using singularValueTransformationOfPhases h Φ P hP

end FQChemQatlib.Dynamics.SingularValueTransformation
