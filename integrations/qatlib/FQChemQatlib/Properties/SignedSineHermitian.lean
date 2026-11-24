module

public import FQChemQatlib.Properties.SignedSineQueries
public import FQChemQatlib.Properties.LinearSystems
import Mathlib.Tactic

/-! # The signed HHL target for a Hermitian input in its original basis

The eigenvector matrix appears in the analysis of the circuit. Conjugating
the controlled evolution by the eigenvector change of coordinates is exactly
the spectral oracle for the original input. The clean-clock target transformed
back into the input basis is a positive scalar multiple of the ordinary matrix
inverse applied to the prepared state. -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Properties.SignedSineClock
open Matrix Qatlib.Foundations.PureStateMath Qatlib.Foundations.PureStateMath.BornBridge
open Qatlib.Foundations.QueryWordCore.Circuit
open Qatlib.Concepts.QueryWordCore.AdjointCircuits Qatlib.Concepts.NativeNumerics.LayeredMean
open Qatlib.Concepts.HhlAlgorithms.SinEnvProgram
open Qatlib.Concepts.HhlAlgorithms.SinEnvProgram.SinEnvelopeHHLConsumers
open Qatlib.Concepts.HhlAlgorithms.SinEnvFilter.SinEnvelopeHHL
open Qatlib.Concepts.SpectralReadout.OffGridPhaseReadout Qatlib.Concepts.SpectralFilter.PhaseReadout
open Qatlib.Concepts.CoherentSim.CoherentOAA.SignalProcessing Qatlib.Concepts.LocalMachine.LocalTransport
open Qatlib.Concepts.HhlAlgorithms.Postselection Qatlib.Concepts.LchsSimulation.StaticLchs
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.CoherentSim.CoherentOAA
open Qatlib.Concepts.QueryComplexity.DegreeMethod
open Qatlib.Concepts.QspSimulation.Achievability
open Qatlib.Concepts.QspSimulation.Achievability.WellFormedAdjointCircuit

variable {D : ℕ}

def basisOnClock (M : ℕ) (V : Matrix (Fin D) (Fin D) ℂ) :=
  TensorGate V (1 : Matrix (Fin M) _ ℂ)

/-- The input oracle on the actual system acts correctly in every clock
bin without knowing the eigenbasis. This is the controlled power used in
each branch of the finite phase-estimation loop. -/
theorem oracleConjugation (eig : Fin D → ℝ) (V : Matrix (Fin D) (Fin D) ℂ)
    (hV : V ∈ unitaryGroup _ ℂ) (k : ℕ) (x : Fin D → ℂ) :
    (continuousHHLOracle eig V)^k *ᵥ (V *ᵥ x) = V *ᵥ ((evolutionOracle eig)^k *ᵥ x) := by
  have inv := (Matrix.mem_unitaryGroup_iff').mp hV
  rw [star_eq_conjTranspose] at inv
  induction k with
  | zero => simp
  | succ k ih =>
    rw [pow_succ', ← mulVec_mulVec, ih, pow_succ', ← mulVec_mulVec]
    change (V * evolutionOracle eig * Vᴴ) *ᵥ (V *ᵥ _) = _
    simp only [mulVec_mulVec, Matrix.mul_assoc, ← Matrix.mul_assoc Vᴴ V, inv, Matrix.one_mul]

private def mix (M : ℕ) (V : Matrix (Fin D) (Fin D) ℂ) (x : Fin M × Fin D → ℂ) : Fin M × Fin D → ℂ :=
  fun p => (V *ᵥ fun i => x (p.1,i)) p.2

private theorem mixClock (M : ℕ) (V : Matrix (Fin D) (Fin D) ℂ) (T : Matrix (Fin M) _ ℂ)
    (x : Fin M × Fin D → ℂ) :
    ApplyGate (TensorGate T 1) (mix M V x) = mix M V (ApplyGate (TensorGate T 1) x) := by
  funext ⟨z,i⟩
  change (TensorGate T 1 *ᵥ _) (z,i) = _
  rw [tensorSlice]
  change _ = (V *ᵥ fun k => (TensorGate T 1 *ᵥ x) (z,k)) i
  simp only [mix, tensorSlice]
  simp only [mulVec,dotProduct,Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro k _
  apply Finset.sum_congr rfl
  intro w _
  ring

private def phasePowers (M : ℕ) (U : Matrix (Fin D) (Fin D) ℂ) (x : Fin M × Fin D → ℂ) :
    Fin M × Fin D → ℂ :=
  fun p => (U^(min (M-1) p.1.val) *ᵥ fun i => x (p.1,i)) p.2

private theorem mixPowers (M : ℕ) (eig : Fin D → ℝ) (V : Matrix (Fin D) (Fin D) ℂ)
    (hV : V ∈ unitaryGroup _ ℂ) (x : Fin M × Fin D → ℂ) :
    phasePowers M (continuousHHLOracle eig V) (mix M V x) =
      mix M V (phasePowers M (evolutionOracle eig) x) := by
  funext ⟨z,i⟩
  exact congrFun (oracleConjugation eig V hV (min (M-1) z.val) (fun j => x (z,j))) i

private theorem clockAction (M : ℕ) (hM : 2 ≤ M) (U : Matrix (Fin D) (Fin D) ℂ)
    (x : Fin M × Fin D → ℂ) :
    ApplyGate (evaluate (TensorGate (1 : Matrix (Fin M) _ ℂ) (controlOracle U))
        (sinEnvelopeForwardWord M hM)) (phaseFlagEmbed M x) =
      phaseFlagEmbed M (ApplyGate (TensorGate ((QFTMatrix M)ᴴ) 1)
        (phasePowers M U (ApplyGate (TensorGate (sinEnvelopePrep M hM) 1) x))) := by
  rw [sinEnvelopeForwardWord, ← run_eq_evaluate, sinEnvelopePhaseCircuit, run_append,run_append]
  simp only [Run,phaseFlagEmbed_phaseGate,phaseThresholdLoop_action]
  rfl

/-- The uniform clock word queries the evolution of the input matrix in its
original basis. Its system state is the change of coordinates of the signed
spectral calculation for every initial clock state. -/
theorem physicalForward (M : ℕ) (hM : 2 ≤ M) (eig : Fin D → ℝ)
    (V : Matrix (Fin D) (Fin D) ℂ) (hV : V ∈ unitaryGroup _ ℂ) (x : Fin D × Fin M → ℂ) :
    ApplyGate (evaluate (TensorGate (1 : Matrix (Fin M) _ ℂ) (controlOracle (continuousHHLOracle eig V)))
      (sinEnvelopeForwardWord M hM)) (embedClock M (basisOnClock M V *ᵥ x)) =
      embedClock M (basisOnClock M V *ᵥ (spectralClock M hM eig *ᵥ x)) := by
  let swap := fun (ψ : Fin D × Fin M → ℂ) (p : Fin M × Fin D) => ψ (p.2,p.1)
  have frame (ψ : Fin D × Fin M → ℂ) :
      swap (basisOnClock M V *ᵥ ψ) = mix M V (swap ψ) := funext fun ⟨z,i⟩ => tensorSlice _ _ _ _
  have embedded (a b : Fin M × Fin D → ℂ) (h : phaseFlagEmbed M a = phaseFlagEmbed M b) : a=b := by
    funext ⟨z,i⟩
    exact congrFun h (z,false,i)
  have actual := forwardQueries M hM eig x
  change ApplyGate _ (phaseFlagEmbed M (swap x)) = phaseFlagEmbed M (swap _) at actual
  rw [clockInput,clockAction] at actual
  change ApplyGate _ (phaseFlagEmbed M (swap _)) = phaseFlagEmbed M (swap _)
  rw [frame,frame,clockAction,mixClock,mixPowers _ _ _ hV,mixClock,embedded _ _ actual]

/-- The physical inverse uses the adjoint of the forward word, including on
a filtered state whose clock has not yet been reset. -/
theorem physicalInverse (M : ℕ) (hM : 2 ≤ M) (eig : Fin D → ℝ)
    (V : Matrix (Fin D) (Fin D) ℂ) (hV : V ∈ unitaryGroup _ ℂ) (x : Fin D × Fin M → ℂ) :
    (evaluate (TensorGate (1 : Matrix (Fin M) _ ℂ) (controlOracle (continuousHHLOracle eig V)))
      (sinEnvelopeForwardWord M hM))ᴴ *ᵥ embedClock M (basisOnClock M V *ᵥ x) =
      embedClock M (basisOnClock M V *ᵥ (inverseClock M hM eig *ᵥ x)) := by
  let O := continuousHHLOracle eig V
  let U := evaluate (TensorGate (1 : Matrix (Fin M) _ ℂ) (controlOracle O)) (sinEnvelopeForwardWord M hM)
  have form := wellFormedAdjointCircuit_stepToAdjoint_reverse _
    (sin_envelope_phase_circuit_unitary (I:=Fin D) M hM)
  have wunit : U ∈ unitaryGroup _ ℂ := form.evaluate_unitary (tensorGate_unitary
    (Submonoid.one_mem _) (controlOracle_unitary (continuous_hhl_oracle_unitary eig V hV)))
  have unit := (Matrix.mem_unitaryGroup_iff').mp wunit
  rw [star_eq_conjTranspose] at unit
  have fw := physicalForward M hM eig V hV (inverseClock M hM eig *ᵥ x)
  rw [clockUndo] at fw
  change Uᴴ *ᵥ embedClock M (basisOnClock M V *ᵥ x) = _
  rw [← fw]
  change Uᴴ *ᵥ (U *ᵥ _) = _
  rw [mulVec_mulVec,unit,one_mulVec]

/-- The ordinary matrix inverse equals the reciprocal eigenvalue filter on
both spectral branches. -/
theorem inverseInBasis (A : Matrix (Fin D) (Fin D) ℂ) (hA : A.IsHermitian)
    (hne : ∀ i, hA.eigenvalues i ≠ 0) (b : Fin D → ℂ) (d : ℝ) :
    let V : Matrix (Fin D) (Fin D) ℂ := hA.eigenvectorUnitary
    V *ᵥ (fun i => (Vᴴ *ᵥ b) i * ((d/hA.eigenvalues i : ℝ) : ℂ)) = (d : ℂ) • (A⁻¹ *ᵥ b) := by
  let V : Matrix (Fin D) (Fin D) ℂ := hA.eigenvectorUnitary
  let ev := hA.eigenvalues
  have vh := hA.eigenvectorUnitary.property
  have l : Vᴴ*V=1 := (mem_unitaryGroup_iff').mp vh
  have r : V*Vᴴ=1 := (mem_unitaryGroup_iff).mp vh
  let J := V * diagonal (fun i => ((ev i : ℂ))⁻¹) * Vᴴ
  have eqA : A = V * diagonal (fun i => (ev i : ℂ)) * Vᴴ := hA.spectral_theorem
  have inv : A⁻¹=J := by
    apply inv_eq_left_inv
    rw [eqA]
    have pair : diagonal (fun i => (ev i : ℂ)⁻¹) * diagonal (fun i => (ev i : ℂ)) = 1 := by
      rw [diagonal_mul_diagonal, ← diagonal_one]
      congr 1
      funext i
      have nz : (ev i : ℂ) ≠ 0 := by exact_mod_cast hne i
      simp [nz]
    dsimp only [J]
    calc
      _ = V * (diagonal (fun i => (ev i : ℂ)⁻¹) * (Vᴴ*V) * diagonal (fun i => (ev i : ℂ))) * Vᴴ := by
        simp only [Matrix.mul_assoc]
      _ = 1 := by rw [l,Matrix.mul_one,pair,Matrix.mul_one,r]
  rw [inv]
  change V *ᵥ _ = _ • ((V * _ * Vᴴ) *ᵥ b)
  rw [← mulVec_mulVec, ← mulVec_mulVec, ← mulVec_smul]
  congr 1
  funext i
  change _ = (d : ℂ) * ((diagonal (fun i => (ev i : ℂ)⁻¹)) *ᵥ (Vᴴ *ᵥ b)) i
  rw [mulVec_diagonal]
  simp [ev, V, div_eq_mul_inv]
  ring

/-- With eigenphases in the two signed HHL bands, uncomputation and returning
to the orbital basis sends the ideal branch to d A⁻¹b on clock zero. -/
theorem cleanInverse (A : Matrix (Fin D) (Fin D) ℂ) (hA : A.IsHermitian) (hne : ∀ i, hA.eigenvalues i ≠ 0)
    (M : ℕ) (hM : 2≤M) (d : ℝ) (b : Fin D → ℂ) :
    let V : Matrix (Fin D) (Fin D) ℂ := hA.eigenvectorUnitary
    basisOnClock M V *ᵥ WithLp.ofLp
      (undoClock M hM hA.eigenvalues (inverseBranch M d hA.eigenvalues (Vᴴ *ᵥ b))) =
    (fun p : Fin D × Fin M => ((d:ℂ) * (A⁻¹ *ᵥ b) p.1) * Qatlib.Foundations.PureStateMath.Ket
      (⟨0,by omega⟩ : Fin M) p.2) := by
  dsimp only
  rw [cleanClock]
  funext ⟨i,z⟩
  rw [basisOnClock,tensorSlice]
  let V : Matrix (Fin D) (Fin D) ℂ := hA.eigenvectorUnitary
  let t := fun k => (Vᴴ *ᵥ b) k * ((d/hA.eigenvalues k : ℝ) : ℂ)
  let c := Qatlib.Foundations.PureStateMath.Ket (⟨0,by omega⟩ : Fin M) z
  change (V *ᵥ fun k => t k * c) i = _
  have col : (fun k => t k * c) = c • t := by funext k; exact mul_comm ..
  rw [col,mulVec_smul]
  have eqn : V *ᵥ t = (d : ℂ) • (A⁻¹ *ᵥ b) := inverseInBasis A hA hne b d
  rw [eqn]
  exact mul_comm ..

private def orbitalIsometry (M : ℕ) (V : Matrix (Fin D) (Fin D) ℂ) (hV : V ∈ unitaryGroup _ ℂ) :
    EuclideanSpace ℂ (Fin D × Fin M) ≃ₗᵢ[ℂ] EuclideanSpace ℂ (Fin D × Fin M) :=
  let U : unitary (Matrix (Fin D × Fin M) (Fin D × Fin M) ℂ) :=
    ⟨basisOnClock M V, tensorGate_unitary hV (Submonoid.one_mem _)⟩
  let F := Matrix.toEuclideanCLM (n:=Fin D × Fin M) (𝕜:=ℂ)
  let f : Matrix (Fin D × Fin M) (Fin D × Fin M) ℂ →⋆*
      (EuclideanSpace ℂ (Fin D × Fin M) →L[ℂ] EuclideanSpace ℂ (Fin D × Fin M)) :=
    { toFun := F, map_one' := map_one F, map_mul' := map_mul F, map_star' := map_star F }
  Unitary.linearIsometryEquiv (Unitary.map f U)

/-- The successful state in the original orbital coordinates approximates
the normalized ordinary matrix inverse with clock zero. -/
theorem physicalSolution (A : Matrix (Fin D) (Fin D) ℂ) (hA : A.IsHermitian)
    (M : ℕ) (hM : 2 ≤ M) (d : ℝ) (hd : 0 < d) (b : Fin D → ℂ)
    (hb : ∑ i, ‖b i‖^2 = 1) (spectrum : ∀ i, 4*d ≤ |hA.eigenvalues i| ∧ |hA.eigenvalues i| ≤ 1/4)
    (budget : 160 ≤ d*M) :
    let V : Matrix (Fin D) (Fin D) ℂ := hA.eigenvectorUnitary
    let uncomputed := undoClock M hM hA.eigenvalues (successBranch M d hA.eigenvalues (Vᴴ *ᵥ b))
    let out := WithLp.toLp 2 (basisOnClock M V *ᵥ WithLp.ofLp uncomputed)
    let target : EuclideanSpace ℂ (Fin D × Fin M) := WithLp.toLp 2 fun p =>
      (A⁻¹ *ᵥ b) p.1 * Qatlib.Foundations.PureStateMath.Ket (⟨0,by omega⟩ : Fin M) p.2
    4*d^2 ≤ ‖out‖^2 ∧ ‖NormedSpace.normalize out - NormedSpace.normalize target‖ ≤ 160/(d*M) := by
  let V : Matrix (Fin D) (Fin D) ℂ := hA.eigenvectorUnitary
  have hV := hA.eigenvectorUnitary.property
  let f := (undoClock M hM hA.eigenvalues).trans (orbitalIsometry M V hV)
  have normb : ∑ i, ‖(Vᴴ *ᵥ b) i‖^2 = 1 := normalized_applyGate (Unitary.star_mem hV) hb
  have result := normalizedBranch M hM d hA.eigenvalues (Vᴴ *ᵥ b) hd normb spectrum budget f
  refine ⟨result.1,?_⟩
  dsimp only
  let x : EuclideanSpace ℂ (Fin D × Fin M) := WithLp.toLp 2 fun p =>
    (A⁻¹ *ᵥ b) p.1 * Qatlib.Foundations.PureStateMath.Ket (⟨0,by omega⟩ : Fin M) p.2
  have clean : f (inverseBranch M d hA.eigenvalues (Vᴴ *ᵥ b)) = d • x := by
    apply WithLp.ofLp_injective
    change basisOnClock M V *ᵥ WithLp.ofLp (undoClock M hM hA.eigenvalues
      (inverseBranch M d hA.eigenvalues (Vᴴ *ᵥ b))) = _
    rw [cleanInverse A hA (fun i => abs_pos.mp ((by linarith : 0 < 4*d).trans_le (spectrum i).1)) M hM d b]
    funext p
    change _ = (d : ℂ) * ((A⁻¹ *ᵥ b) p.1 * _)
    ring
  have distance := result.2
  rw [clean,NormedSpace.normalize_smul_of_pos hd] at distance
  exact distance

end FQChemQatlib.Properties.SignedSineClock
