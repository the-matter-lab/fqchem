module

public import FQChemQatlib.Properties.SignedSineClock
import Mathlib.Tactic

/-! # Uncomputing the signed sine-clock solution state

In eigenphase coordinates, inverse phase estimation is the adjoint of a
sine-state preparation, controlled-time phase, and inverse Fourier transform.
It maps the successful ideal target to the reciprocal solution with a clean
clock. The normalized error bound uses the same inverse circuit. -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Properties.SignedSineClock
open Matrix Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.SpectralFilter.PhaseReadout
open Qatlib.Concepts.HhlAlgorithms.SinEnvFilter.SinEnvelopeHHL
open Qatlib.Concepts.QueryComplexity.DegreeMethod

def timePhase (a : ℝ) {M : ℕ} (z : Fin M) := Complex.exp (2*Real.pi*Complex.I*((z.val:ℝ)*a))

def forwardClock (M : ℕ) (hM : 2≤M) (a : ℝ) :=
  (QFTMatrix M)ᴴ * diagonal (timePhase a) * sinEnvelopePrep M hM

theorem clockUnitary (M : ℕ) (hM : 2≤M) (a : ℝ) :
    forwardClock M hM a ∈ Matrix.unitaryGroup _ ℂ := by
  have ph : diagonal (timePhase a) ∈ Matrix.unitaryGroup (Fin M) ℂ := by
    rw [Matrix.mem_unitaryGroup_iff, Matrix.star_eq_conjTranspose, diagonal_conjTranspose,
      diagonal_mul_diagonal, ← diagonal_one]
    congr 1
    funext z
    change timePhase a z * star (timePhase a z) = 1
    change timePhase a z * (starRingEnd ℂ) (timePhase a z) = 1
    rw [Complex.mul_conj, Complex.normSq_eq_norm_sq]
    have hn : ‖timePhase a z‖ = 1 := by
      simpa only [timePhase, Complex.ofReal_mul, Complex.ofReal_natCast] using norm_exp_two_pi_I ((z.val:ℝ)*a)
    simp [hn]
  apply (unitaryGroup _ ℂ).mul_mem _ (sin_envelope_state_normalized_and_prep M hM).2.1
  exact (unitaryGroup _ ℂ).mul_mem (Unitary.star_mem (qftMatrix_unitary (by omega))) ph

theorem forwardKernel (M : ℕ) (hM : 2≤M) (a : ℝ) :
    forwardClock M hM a *ᵥ Ket (⟨0,by omega⟩ : Fin M) = sinEnvelopeKernel M a := by
  rw [forwardClock, ← mulVec_mulVec, ← mulVec_mulVec, (sin_envelope_state_normalized_and_prep M hM).2.2]
  have diag : diagonal (timePhase a) *ᵥ sinEnvelopeState M =
      (fun z => timePhase a z * sinEnvelopeState M z) := by ext; rw [mulVec_diagonal]
  rw [diag]
  rfl

def undoClock {I : Type*} [Fintype I] [DecidableEq I] (M : ℕ) (hM : 2≤M) (eig : I → ℝ) :
    EuclideanSpace ℂ (I × Fin M) ≃ₗᵢ[ℂ] EuclideanSpace ℂ (I × Fin M) :=
  let W := fun i => (forwardClock M hM (eig i))ᴴ
  let V : unitary (Matrix (I × Fin M) (I × Fin M) ℂ) :=
    ⟨BlockDiag W, blockDiag_unitary W (fun i => Unitary.star_mem (clockUnitary M hM (eig i)))⟩
  let F := Matrix.toEuclideanCLM (n:=I × Fin M) (𝕜:=ℂ)
  let f : Matrix (I × Fin M) (I × Fin M) ℂ →⋆* (EuclideanSpace ℂ (I × Fin M) →L[ℂ] EuclideanSpace ℂ (I × Fin M)) :=
    { toFun := F, map_one' := map_one F, map_mul' := map_mul F, map_star' := map_star F }
  Unitary.linearIsometryEquiv (Unitary.map f V)

/-- With the inverse circuit, the target is supported exclusively on clock
zero and its system amplitudes are the signed reciprocal eigenvalue weights. -/
theorem cleanClock {I : Type*} [Fintype I] [DecidableEq I] (M : ℕ) (hM : 2≤M)
    (d : ℝ) (eig : I → ℝ) (b : I → ℂ) :
    undoClock M hM eig (inverseBranch M d eig b) =
      WithLp.toLp 2 fun p : I × Fin M => (b p.1 * ((d/eig p.1 : ℝ) : ℂ)) *
        Ket (⟨0, by omega⟩ : Fin M) p.2 := by
  ext ⟨i,z⟩
  change (BlockDiag (fun i => (forwardClock M hM (eig i))ᴴ) *ᵥ
      (fun p : I × Fin M => (b p.1 * ((d/eig p.1 : ℝ) : ℂ)) * sinEnvelopeKernel M (eig p.1) p.2)) (i,z) = _
  simp only [BlockDiag, Matrix.mulVec, dotProduct, Fintype.sum_prod_type, Matrix.of_apply,
    ite_mul, zero_mul, Finset.sum_ite_irrel, Finset.sum_const_zero, Finset.sum_ite_eq, Finset.mem_univ, ite_true]
  have hU := (Matrix.mem_unitaryGroup_iff').mp (clockUnitary M hM (eig i))
  rw [Matrix.star_eq_conjTranspose] at hU
  have inv : (forwardClock M hM (eig i))ᴴ *ᵥ sinEnvelopeKernel M (eig i) = Ket (⟨0,by omega⟩ : Fin M) := by
    rw [← forwardKernel M hM, mulVec_mulVec, hU, one_mulVec]
  rw [← inv]
  simp only [Matrix.mulVec,dotProduct,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro k _
  ring

/-- Actual inverse phase estimation yields a clean-clock inverse-state target
with relative amplitude accuracy using a clock proportional to 1/(d ε). -/
theorem signedSolution {I : Type*} [Fintype I] [DecidableEq I] (M : ℕ) (hM : 2≤M)
    (d : ℝ) (eig : I → ℝ) (b : I → ℂ) (hd : 0<d) (hb : ∑ i, ‖b i‖^2=1)
    (spectrum : ∀ i, 4*d ≤ |eig i| ∧ |eig i|≤1/4) (budget : 160≤d*M) :
    let actual := undoClock M hM eig (successBranch M d eig b)
    let target : EuclideanSpace ℂ (I × Fin M) := WithLp.toLp 2 fun p =>
      (b p.1 * ((d/eig p.1 : ℝ) : ℂ)) * Ket (⟨0, by omega⟩ : Fin M) p.2
    4*d^2 ≤ ‖actual‖^2 ∧
      ‖NormedSpace.normalize actual - NormedSpace.normalize target‖ ≤ 160/(d*M) := by
  simpa only [cleanClock] using normalizedBranch M hM d eig b hd hb spectrum budget (undoClock M hM eig)

end FQChemQatlib.Properties.SignedSineClock
