module

public import Qatlib.Concepts.ShadowModels.ShadowChannel.FiniteEnsembleShadows

/-! # Classical shadows of arbitrary Hermitian observables

A finite distribution of unitary measurement bases and an invertible measurement channel define
the inverse snapshots. Qatlib proves the centered shadow-norm variance bound and concentration
for the medians computed from a common set of Born records. The statements below expose that
proof for the prediction task in Huang, Kueng and Preskill, Supplementary Theorem 1.

* [Huang, Kueng and Preskill (2020)](https://doi.org/10.1038/s41567-020-0932-7)
* [Qatlib finite-ensemble proofs](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/ShadowModels/ShadowChannel/FiniteEnsembleShadows.lean#L465-L568)
-/

@[expose] public section
noncomputable section

namespace FQChemQatlib.Properties.ClassicalShadows

open Qatlib.Concepts.ShadowModels.ShadowChannel
open Qatlib.Concepts.MonteCarloMean.FinDistBounds
open Qatlib.Foundations.PureStateMath Qatlib.Foundations.PureStateMath.BornBridge
open Qatlib.Concepts.ReferenceError.RefTraceError
open Matrix
open scoped Classical BigOperators Matrix.Norms.L2Operator ComplexOrder

variable {X Z : Type} [Fintype X] [Fintype Z] {D : ℕ}

/-- The positive moment effect realizes the squared shadow norm of a Hermitian observable as
the largest second moment of the inverse-snapshot estimator over all density states. -/
theorem shadowNormSquaredMaximum (p : FinDist X) (U : X → Operator D)
    (hU : ∀ a, U a ∈ Matrix.unitaryGroup (Fin D) ℂ)
    (hM : Function.Bijective (ensembleMeasurementMap p U)) (hD : 0 < D)
    (A : Operator D) (hA : A.IsHermitian) :
    (ensembleMomentEffect p U hM A).PosSemidef ∧
      IsGreatest {v : ℝ | ∃ (ρ : Operator D) (hρ : IsDensityOperator ρ),
        v = (ensembleRecordLaw p U hU ρ hρ).expect
          (fun o => (ensembleStatistic p U hM A o) ^ 2)}
        ‖ensembleMomentEffect p U hM A‖ :=
  finite_ensemble_second_moment_spectral_maximum X D p U hU hM A hD hA

/-- All observables share the same K blocks of L independent measurement records. Four times
each centered squared shadow norm bounds the required product of block size and squared
tolerance. The displayed failure bound decays exponentially with the number of blocks. -/
theorem simultaneousPrediction (p : FinDist X) (U : X → Operator D)
    (hU : ∀ a, U a ∈ Matrix.unitaryGroup (Fin D) ℂ)
    (hM : Function.Bijective (ensembleMeasurementMap p U)) (ρ : Operator D)
    (hρ : IsDensityOperator ρ) (A : Z → Operator D) (L K : ℕ)
    (hL : 0 < L) (hK : 0 < K) (ε : ℝ) (hε : 0 < ε)
    (hA : ∀ z, (A z).IsHermitian ∧
      4 * ‖ensembleMomentEffect p U hM
        (A z - (Matrix.trace (A z) / (D : ℂ)) • (1 : Operator D))‖ ≤ (L : ℝ) * ε ^ 2) :
    (∑ ω ∈ Finset.univ.filter (fun ω : Fin K → Fin L → X × Fin D =>
        ∃ z, ε < |(ensembleRecordLaw p U hU ρ hρ).medianOfMeans
          (ensembleStatistic p U hM (A z)) ω - (Matrix.trace (A z * ρ)).re|),
      ∏ k, (ensembleRecordLaw p U hU ρ hρ).probOf (ω k))
      ≤ (Fintype.card Z : ℝ) * 3 ^ (K / 2) / 2 ^ K :=
  finite_ensemble_same_records_many_observables X Z D L K p U hU hM ρ hρ A ε hL hK hε hA

end FQChemQatlib.Properties.ClassicalShadows
