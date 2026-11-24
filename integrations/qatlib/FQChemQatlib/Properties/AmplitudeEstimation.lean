module

public import Qatlib.Concepts.AEMeanReadout.LocalAEBackend.ComparativeStrictBounds

/-!
# Prepared amplitude estimation

Brassard, Høyer, Mosca and Tapp, Theorem 12
(https://doi.org/10.1090/conm/305/05215). The finite circuit's Born law is
decoded as a squared sine. In Qatlib's access convention initialization and the
M − 1 controlled marking queries are accounted for separately.
-/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Properties.AmplitudeEstimation

open Qatlib.Concepts.AmplitudeCore.PreparedReadout
open Qatlib.Concepts.AEMeanReadout.LocalAEBackend
open Qatlib.Concepts.LchsSimulation.StaticLchs
open Qatlib.Concepts.PhaseGeometry.Phase
open Qatlib.Foundations.QueryWordCore.Circuit
open Qatlib.Foundations.PureStateMath
open Qatlib.Foundations.InstrumentCore.Measurement
open Qatlib.Foundations.PureStateMath.BornBridge
open Qatlib.Concepts.SpectralReadout.PhaseReadout
open scoped Classical

/-- For a unitary preparation, the actual counter outcomes meet the k=1 BHMT
error bound with probability at least 8/π². The query count is for the expanded
circuit with a controlled marking oracle. -/
theorem amplitudeEstimation {I : Type} [Fintype I] [DecidableEq I] (M : ℕ) (hM : 2 ≤ M)
    (A : Matrix I I ℂ) (j : I) (S : Finset I) (hA : A ∈ Matrix.unitaryGroup I ℂ) :
    let a := MeasureProb (preparedAAState A j) S
    8 / Real.pi ^ 2 ≤ ∑ z ∈ Finset.univ.filter (fun z : Fin M =>
        |aeEstimate M z - a| ≤ 2 * Real.pi * Real.sqrt (a * (1 - a)) / M + Real.pi ^ 2 / (M : ℝ) ^ 2),
      (aeLaw M A j S hA hM).prob z ∧ QueryCount (countedAECircuit M A j) = M - 1 := by
  exact ⟨(prepared_ae_bhmt_error_and_endpoints M hM A j S hA).1,
    (prepared_ae_access_ledger M (by omega) A j).1⟩

/-- Theorem 12, general integer window k ≥ 2. The paper gives a strict
probability bound for the amplitude estimate returned by the counted circuit. -/
theorem amplitudeEstimationTail {I : Type} [Fintype I] [DecidableEq I]
    (M k : ℕ) (hM : 2 ≤ M) (hk : 2 ≤ k) (A : Matrix I I ℂ) (j : I) (S : Finset I)
    (hA : A ∈ Matrix.unitaryGroup I ℂ) :
    let a := MeasureProb (preparedAAState A j) S
    1 - 1 / (2 * ((k : ℝ) - 1)) < ∑ z ∈ Finset.univ.filter (fun z : Fin M =>
        |aeEstimate M z - a| ≤ 2 * Real.pi * k * Real.sqrt (a * (1 - a)) / M +
          (k : ℝ) ^ 2 * Real.pi ^ 2 / (M : ℝ) ^ 2), (aeLaw M A j S hA hM).prob z :=
  preparedAeWindow_strict M A j S hM hA k hk

end FQChemQatlib.Properties.AmplitudeEstimation
