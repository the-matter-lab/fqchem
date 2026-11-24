module

public import Qatlib.Papers.Qubitization19.SparseSim.SourceSparse
public import Qatlib.Concepts.QspSimulation.Achievability.ComputedSignalConsumers

/-! # Simulation from a sparse Hermitian matrix

Low and Chuang's standard-form encoding has normalization `d b`, where each
row has at most `d` nonzero entries and `b` bounds the entry magnitudes.
Here that encoding feeds a concrete segmented signal-processing circuit. The
query and fixed-matrix gate counts refer to this circuit, with exact frame
reflections. Position/entry-oracle synthesis and the optimal query bound of
the published simulation theorem require further results.

* [Low and Chuang (2019), Lemma 6 and Corollary 15](https://doi.org/10.22331/q-2019-07-12-163)
* [Low and Chuang (2017), Theorem 3](https://doi.org/10.1103/PhysRevLett.118.010501)
-/

@[expose] public section
namespace FQChemQatlib.Dynamics.SparseHamiltonianSimulation

open Matrix Qatlib.Foundations.PureStateMath Qatlib.Foundations.PureStateMath.BornBridge
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.CoherentSim.CoherentOAA
open Qatlib.Concepts.QspSimulation.Achievability Qatlib.Concepts.QspSimulation.JacobiAnger
open Qatlib.Concepts.QueryWordCore.AdjointCircuits Qatlib.Concepts.BlockEncoding
open Qatlib.Concepts.LocalMachine.LocalTransport
open Qatlib.Concepts.CopyEvolution.Discriminate Qatlib.Papers.Qubitization19.SparseSim
open scoped Classical Matrix.Norms.L2Operator

variable {I : Type} [Fintype I] [DecidableEq I]

/-- Lemma 6 in orthonormal frames. The swap of the sparse-state encoding is a unitary
oracle whose compression between the same frame equals the normalized Hamiltonian. -/
theorem sparseSignalEncoding (H : Matrix I I ℂ) (hH : H.IsHermitian)
    (d : ℕ) (hd : 0 < d) (b : ℝ) (hb : 0 < b)
    (row : ∀ i, (Finset.univ.filter fun j => H i j ≠ 0).card ≤ d)
    (entry : ∀ i j, ‖H i j‖ ≤ b) :
    ∃ W : SparseFrameWitness I H d b,
      ProjectedUnitaryEncoding (((((d : ℝ) * b)⁻¹ : ℝ) : ℂ) • H) W.S W.L W.L := by
  have column (i : I) : (Finset.univ.filter fun j => H j i ≠ 0).card ≤ d := by
    have hs : (Finset.univ.filter fun j => H j i ≠ 0) =
        (Finset.univ.filter fun j => H i j ≠ 0) := by
      ext j
      simp [← hH.apply j i]
    simpa only [hs] using row i
  obtain ⟨W⟩ := lemma6_sparse_standard_form I H d b hH hd hb row column entry
  refine ⟨W, W.S_mem_unitaryGroup, W.isIsometry_L, W.isIsometry_L, ?_⟩
  simpa only [compress, Matrix.mul_assoc, W.S_mul_L] using W.corner

/-- For rational scaled time τ, a well-formed circuit simulates evolution for physical
time τ/(db) on every input with error at most 2⁻ᵏ times the input norm. Its two counts
belong to the same circuit that satisfies the state error bound. -/
theorem segmentedSparseEvolution (H : Matrix I I ℂ) (hH : H.IsHermitian)
    (d : ℕ) (hd : 0 < d) (b : ℝ) (hb : 0 < b)
    (row : ∀ i, (Finset.univ.filter fun j => H i j ≠ 0).card ≤ d)
    (entry : ∀ i j, ‖H i j‖ ≤ b) (τ : ℚ) (k : ℕ) :
    ∃ W : SparseFrameWitness I H d b,
      let word := computedSignalWord W.L τ k
      let frame := scaleEightFrame (hamiltonianFrame W.L)
      let oracle := TensorGate (1 : Matrix Bool Bool ℂ) (controlOracle (parallelOracle (J := Bool) W.S))
      WellFormedAdjointCircuit word ∧
      adjointQueryCount word = computedSignalSegments τ * (27 * (4 * computedSignalCutoff τ k + 1)) ∧
      adjointGateCount word = computedSignalSegments τ * (27 * (4 * computedSignalCutoff τ k + 6) + 79) ∧
      ∀ ψ : QState I,
        ‖toEuclidean_fromVec (evaluate oracle word *ᵥ (frame *ᵥ ψ) -
          frame *ᵥ (hamiltonianEvolution H ((τ : ℝ) / (d * b)) *ᵥ ψ))‖ ≤
          (1 / 2 : ℝ) ^ k * ‖toEuclidean_fromVec ψ‖ := by
  obtain ⟨W, hW⟩ := sparseSignalEncoding H hH d hd b hb row entry
  let scale : ℝ := (d : ℝ) * b
  have hscaled : (((scale⁻¹ : ℝ) : ℂ) • H).IsHermitian :=
    hH.smul (by simp [IsSelfAdjoint])
  have htime : hamiltonianEvolution (((scale⁻¹ : ℝ) : ℂ) • H) τ =
      hamiltonianEvolution H ((τ : ℝ) / scale) := by
    unfold hamiltonianEvolution
    rw [smul_smul]
    push_cast
    ring_nf
  exact ⟨W, by simpa only [htime] using
    (computed_signal_full_segmented_program_and_cost W.W I _ W.S W.L τ k hscaled hW)⟩

end FQChemQatlib.Dynamics.SparseHamiltonianSimulation
