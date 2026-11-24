module

public import Qatlib.Concepts.HhlAlgorithms.UniformHHL.OffGridSignedHHL
public import Qatlib.Papers.QLinearSolver18.MainResults.Readout.PseudoinverseReadout

/-! # Solution states for invertible Hermitian systems

Harrow, Hassidim and Lloyd's output is the normalized inverse applied to the prepared input.
The circuit here uses a uniform phase-estimation clock and signed reciprocal rotations.
Its precision and success bounds refer to exact spectral-oracle queries.

* [Harrow, Hassidim and Lloyd, Appendix A, Theorem 1(3)](https://doi.org/10.1103/PhysRevLett.103.150502)
-/

@[expose] public section
namespace FQChemQatlib.Properties.LinearSystems

open Matrix Qatlib.Foundations.PureStateMath Qatlib.Foundations.PureStateMath.BornBridge
open Qatlib.Concepts.CoherentSim.CoherentOAA

open Qatlib.Foundations.InstrumentCore.Measurement Qatlib.Concepts.QueryWordCore.AdjointCircuits
open Qatlib.Concepts.CopyEvolution.Discriminate Qatlib.Concepts.HhlAlgorithms.UniformHHL
open Qatlib.Concepts.HhlAlgorithms.SinEnvProgram Qatlib.Concepts.HhlAlgorithms.GridExactHHL
open Qatlib.Papers.QLinearSolver18.MainResults.Readout.PseudoinverseReadout
open scoped Classical

/-- Given a Hermitian matrix of either spectral sign with eigenvalue magnitudes between
d and 1/4, the selected state of the uniform-clock circuit is within ε of normalized
A⁻¹b. One run succeeds with probability at least d²/4. Its oracle and fixed-gate
counts use the same clock that guarantees this accuracy. -/
theorem signedInverseState {D : ℕ} (A : Operator D) (hA : A.IsHermitian)
    (B : Operator D) (hB : B ∈ Matrix.unitaryGroup (Fin D) ℂ) (j : Fin D)
    (d ε : ℝ) (hd : 0 < d) (hε : 0 < ε) (hε1 : ε ≤ 1)
    (spectrum : ∀ i, d ≤ |hA.eigenvalues i| ∧ |hA.eigenvalues i| ≤ 1 / 4) :
    let M := max 2 ⌈65536 / (d ^ 6 * ε ^ 4)⌉₊
    let hM : 2 ≤ M := le_max_left _ _
    let O := continuousHHLOracle hA.eigenvalues hA.eigenvectorUnitary
    let out := uniformHHLRun M hM O d B j
    let S := Finset.univ.filter (fun p : Fin M × (Bool × (Bool × Fin D)) => p.2.2.1 = true)
    let x := A⁻¹ *ᵥ (B *ᵥ Ket j)
    adjointQueryCount (uniformHHLWord M d B) = 2 * (M - 1) ∧
      adjointGateCount (uniformHHLWord M d B) = 4 * (M - 1) + 6 ∧
      d ^ 2 / 4 ≤ MeasureProb out S ∧
      ‖toEuclidean_fromVec (PostMeasure out S -
        uniformHHLSuccessEmbed M hM ((‖toEuclidean_fromVec x‖ : ℂ)⁻¹ • x))‖ ≤ ε := by
  let η := d * ε / 2
  let M := max 2 ⌈65536 / (d ^ 6 * ε ^ 4)⌉₊
  have hM : 2 ≤ M := le_max_left _ _
  have hη : 0 < η := by dsimp [η]; positivity
  have hηd : η ≤ d / 2 := by dsimp [η]; nlinarith
  have hbudget : 4096 / (d ^ 2 * η ^ 4) ≤ (M : ℝ) := by
    calc
      4096 / (d ^ 2 * η ^ 4) = 65536 / (d ^ 6 * ε ^ 4) := by
        dsimp [η]
        field_simp
        ring
      _ ≤ _ := (Nat.le_ceil _).trans (by exact_mod_cast (le_max_right 2 _))
  have hV := hA.eigenvectorUnitary.property
  have hmat : continuousHHLMatrix hA.eigenvalues hA.eigenvectorUnitary = A :=
    hA.spectral_theorem.symm
  have hpinv := pseudoinverse_eq_inv_of_ne_zero hA.eigenvalues hA.eigenvectorUnitary hV
    (fun i => abs_pos.mp (hd.trans_le (spectrum i).1))
  rw [hmat] at hpinv
  obtain ⟨hmass, _, hdist⟩ := uniform_offgrid_signed_hhl_born_and_solution D M hM
    hA.eigenvalues hA.eigenvectorUnitary B j d η hV hB hd hη hηd spectrum hbudget
  have htarget : 2 * η / d = ε := by dsimp [η]; field_simp
  rw [uniformHHLSolutionTarget, hmat, hpinv, htarget] at hdist
  have counts := (uniform_hhl_actual_legal_forward_inverse_ledger D M d B hM hd hB).2
  exact ⟨counts.1, counts.2, hmass, hdist⟩

end FQChemQatlib.Properties.LinearSystems
