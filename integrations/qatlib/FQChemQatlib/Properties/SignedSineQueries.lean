module

public import FQChemQatlib.Properties.SignedSineAmplification
import Mathlib.Tactic

/-! # Controlled evolution queries for the signed HHL clock

A single list of oracle-independent gates works for every signed spectrum.
The ordinary controlled-evolution oracle runs the sine clock, restores its
work bit and also acts correctly when the inverse is called on an arbitrary
filtered clock vector. -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Properties.SignedSineClock
open Matrix Qatlib.Foundations.PureStateMath Qatlib.Foundations.PureStateMath.BornBridge
open Qatlib.Foundations.QueryWordCore.Circuit
open Qatlib.Concepts.QueryWordCore.AdjointCircuits
open Qatlib.Concepts.QspSimulation.Achievability
open Qatlib.Concepts.SpectralFilter.PhaseReadout
open Qatlib.Concepts.SpectralReadout.OffGridPhaseReadout
open Qatlib.Concepts.HhlAlgorithms.SinEnvFilter.SinEnvelopeHHL
open Qatlib.Concepts.HhlAlgorithms.SinEnvProgram.SinEnvelopeHHLConsumers
open Qatlib.Concepts.LocalMachine.LocalTransport
open Qatlib.Concepts.NativeNumerics.LayeredMean
open Qatlib.Concepts.QueryComplexity.DegreeMethod
open Qatlib.Concepts.HhlAlgorithms.Postselection
open Qatlib.Concepts.LchsSimulation.StaticLchs
open Qatlib.Concepts.Execution.WorkspaceCP
open Qatlib.Concepts.CoherentSim.CoherentOAA.SignalProcessing
open Qatlib.Concepts.CoherentSim.CoherentOAA
open Qatlib.Concepts.QspSimulation.Achievability.WellFormedAdjointCircuit
variable {I : Type} [Fintype I] [DecidableEq I]

def evolutionOracle (eig : I → ℝ) : Matrix I I ℂ :=
  diagonal fun i => Complex.exp (2*Real.pi*Complex.I*(eig i))

def clockInput (M : ℕ) (eig : I → ℝ) :=
  TensorGate (1 : Matrix (Fin M) _ ℂ) (controlOracle (evolutionOracle eig))

def embedClock (M : ℕ) (x : I × Fin M → ℂ) :=
  phaseFlagEmbed M (fun p : Fin M × I => x (p.2,p.1))

private theorem unitaryOracle (eig : I → ℝ) : evolutionOracle eig ∈ unitaryGroup _ ℂ := by
  rw [evolutionOracle, Matrix.mem_unitaryGroup_iff,Matrix.star_eq_conjTranspose,
    diagonal_conjTranspose,diagonal_mul_diagonal,← diagonal_one]
  congr 1; funext i
  change _ * (starRingEnd ℂ) _ = _
  rw [Complex.mul_conj,Complex.normSq_eq_norm_sq,norm_exp_two_pi_I]
  norm_num

private theorem powers (eig : I → ℝ) (M : ℕ) (z : Fin M) (v : I → ℂ) (i : I) :
    ((evolutionOracle eig)^z.val *ᵥ v) i = timePhase (eig i) z * v i := by
  simp only [evolutionOracle, diagonal_pow, mulVec_diagonal, timePhase, Pi.pow_apply, ← Complex.exp_nat_mul]
  congr 2
  push_cast
  ring

/-- One use of the forward half-word on any clock state, in the eigenbasis of
the input Hamiltonian. The query gate is the same controlled evolution in
every round and the workspace bit is returned to zero. -/
theorem forwardQueries (M : ℕ) (hM : 2≤M) (eig : I → ℝ) (x : I × Fin M → ℂ) :
    ApplyGate (evaluate (clockInput M eig) (sinEnvelopeForwardWord M hM)) (embedClock M x) =
      embedClock M (spectralClock M hM eig *ᵥ x) := by
  rw [sinEnvelopeForwardWord, ← run_eq_evaluate, sinEnvelopePhaseCircuit, run_append,run_append]
  simp only [Run,embedClock,phaseFlagEmbed_phaseGate,clockInput,phaseThresholdLoop_action]
  apply congrArg (phaseFlagEmbed M)
  funext ⟨z,i⟩
  rw [show (spectralClock M hM eig *ᵥ x) (i,z) =
      (forwardClock M hM (eig i) *ᵥ fun k => x (i,k)) z from blockSlice _ _ _ _]
  change (TensorGate ((QFTMatrix M)ᴴ) 1 *ᵥ _) (z,i) = _
  rw [tensorSlice, forwardClock, ← mulVec_mulVec, ← mulVec_mulVec]
  congr 2
  funext k
  change ((evolutionOracle eig)^min (M-1) k.val *ᵥ _) i = _
  rw [Nat.min_eq_right (by omega), powers, mulVec_diagonal]
  change timePhase (eig i) k * ((TensorGate (sinEnvelopePrep M hM) 1 *ᵥ _) (k,i)) = _
  rw [tensorSlice]

theorem clockUndo (M : ℕ) (hM : 2≤M) (eig : I → ℝ) (x : I × Fin M → ℂ) :
    spectralClock M hM eig *ᵥ (inverseClock M hM eig *ᵥ x) = x := by
  funext ⟨i,z⟩
  rw [spectralClock,blockSlice]
  have row : (fun k => (inverseClock M hM eig *ᵥ x) (i,k)) =
      (forwardClock M hM (eig i))ᴴ *ᵥ fun k => x (i,k) := funext fun k => blockSlice _ _ _ _
  rw [row,mulVec_mulVec]
  have u := (Matrix.mem_unitaryGroup_iff).mp (clockUnitary M hM (eig i))
  rw [Matrix.star_eq_conjTranspose] at u
  rw [u,one_mulVec]

/-- Inverse QPE uses the adjoint of the same uniform word on every input. -/
theorem inverseQueries (M : ℕ) (hM : 2≤M) (eig : I → ℝ) (x : I × Fin M → ℂ) :
    (evaluate (clockInput M eig) (sinEnvelopeForwardWord M hM))ᴴ *ᵥ embedClock M x =
      embedClock M (inverseClock M hM eig *ᵥ x) := by
  let U := evaluate (clockInput M eig) (sinEnvelopeForwardWord M hM)
  have form := wellFormedAdjointCircuit_stepToAdjoint_reverse _ (sin_envelope_phase_circuit_unitary (I:=I) M hM)
  have wunit : U ∈ unitaryGroup _ ℂ := form.evaluate_unitary
    (tensorGate_unitary (Submonoid.one_mem _) (controlOracle_unitary (unitaryOracle eig)))
  have unit := (Matrix.mem_unitaryGroup_iff').mp wunit
  rw [star_eq_conjTranspose] at unit
  have fw := forwardQueries M hM eig (inverseClock M hM eig *ᵥ x)
  rw [clockUndo] at fw
  change Uᴴ *ᵥ embedClock M x = _
  rw [← fw]
  change Uᴴ *ᵥ (U *ᵥ _) = _
  rw [mulVec_mulVec,unit,one_mulVec]

/-- Choose a sine-clock length for vector error ε and an amplification window
using only the spectral gap. The single-attempt success is at least 1/8,
and each seed costs at most 2/d input preparations (counting their inverses)
and 640/(d² ε) controlled-evolution queries. Both counts refer to the words
realizing the same signed solution. -/
theorem signedOracleResources (eig : I → ℝ) (d ε : ℝ) (hd : 0<d) (hε : 0<ε) (he₁ : ε≤1)
    (B : Matrix I I ℂ) (hB : B ∈ unitaryGroup _ ℂ) (j : I)
    (spectrum : ∀ i, 4*d ≤ |eig i| ∧ |eig i| ≤ 1/4) :
    let M := max 2 ⌈160/(d*ε)⌉₊
    let hM : 2 ≤ M := le_max_left _ _
    let m := ⌈1/(2*d)⌉₊
    let A := solver M hM eig d B
    let j₀ := start M hM j
    let b := B *ᵥ Qatlib.Foundations.PureStateMath.Ket j
    let actual := undoClock M hM eig (successBranch M d eig b)
    let ideal := undoClock M hM eig (inverseBranch M d eig b)
    let S := selected I M
    let run := fun s : Fin (2*m) => Run (preparedMark S) (preparedAACircuit A j₀ (depth m s))
        (Qatlib.Foundations.PureStateMath.Ket j₀)
    let word := sinEnvelopeForwardWord (I:=I) M hM
    ‖NormedSpace.normalize actual - NormedSpace.normalize ideal‖ ≤ ε ∧
    (1/8 : ℝ) ≤ (∑ s, MeasureProb (run s) S)/(2*m) ∧
    ∀ s, let calls := preparedInputQueries (preparedAAWord j₀ (depth m s))
         (calls:ℝ) ≤ 2/d ∧
         (calls * (adjointQueryCount word + adjointQueryCount (adjointCircuit word)) : ℕ) ≤
           (640 / (d^2*ε) : ℝ) := by
  let M := max 2 ⌈160/(d*ε)⌉₊
  let m := ⌈1/(2*d)⌉₊
  have hM : 2≤M := le_max_left _ _
  have de := mul_pos hd hε
  have ds : d≤1/16 := by linarith [(spectrum j).1,(spectrum j).2]
  have dε : d*ε ≤ d := by simpa using mul_le_mul_of_nonneg_left he₁ hd.le
  have big : (2:ℝ) ≤ 160/(d*ε) := (le_div_iff₀ de).mpr (by linarith)
  have ceilLo := Nat.le_ceil (160/(d*ε))
  have maxEq : M = ⌈160/(d*ε)⌉₊ := max_eq_right (by exact_mod_cast big.trans ceilLo)
  have lower : 160 ≤ (d*M)*ε := by
    have le : 160≤(M:ℝ)*(d*ε) := (div_le_iff₀ de).mp (maxEq ▸ ceilLo)
    linarith
  have budget : 160 ≤ d*M := by
    have mpos : (0:ℝ) ≤ M := by positivity
    nlinarith [mul_nonneg (mul_nonneg hd.le mpos) (sub_nonneg.mpr he₁)]
  have accuracy := (normalizedBranch M hM d eig _ hd (normalized_applyGate hB (normalized_ket j))
    spectrum budget (undoClock M hM eig)).2
  have prob := amplifiedSignedSolution M hM eig d hd B hB j spectrum budget
  refine ⟨accuracy.trans ((div_le_iff₀ (by linarith : 0<d*M)).mpr (by linarith)),prob.1,fun s => ?_⟩
  let calls := preparedInputQueries (preparedAAWord (start M hM j) (depth m s))
  have count : (calls:ℝ) ≤ 2*m := by exact_mod_cast (prob.2 s).1
  have win : (m:ℝ) ≤ 1/d := by
    have a := (Nat.ceil_lt_add_one (by positivity : 0≤1/(2*d))).le
    change (⌈1/(2*d)⌉₊ : ℝ) ≤ _
    apply a.trans
    field_simp
    linarith
  have cp : (calls:ℝ) ≤ 2/d := count.trans ((mul_le_mul_of_nonneg_left win (by norm_num : (0:ℝ)≤2)).trans_eq (by ring))
  have clock : ((M-1 : ℕ):ℝ) ≤ 160/(d*ε) := by
    rw [Nat.cast_sub (by omega : 1≤M),Nat.cast_one,maxEq]
    linarith [(Nat.ceil_lt_add_one (by positivity : 0≤160/(d*ε))).le]
  refine ⟨cp,?_⟩
  rw [adjointQueryCount_adjointCircuit,(sin_envelope_forward_word_counts (I:=I) M hM).1]
  push_cast
  calc
    _ ≤ (2/d)*(160/(d*ε)+160/(d*ε)) := mul_le_mul cp (add_le_add clock clock)
      (by positivity) (by positivity)
    _ = _ := by field_simp; ring

end FQChemQatlib.Properties.SignedSineClock
