module

public import FQChem.Properties.ResponseAndEstimation.ShadowConfidence
public import Mathlib.LinearAlgebra.UnitaryGroup
public import Mathlib.Analysis.Matrix.PosDef
public import Mathlib.MeasureTheory.Measure.ProbabilityMeasure
public import Mathlib.MeasureTheory.Integral.Bochner.ContinuousLinearMap
import Mathlib.Tactic

/-! # Shadow sample complexity for arbitrary unitary measurement ensembles

The basis index carries an arbitrary probability measure. The channel is specified
by its trace pairings (Eq. S2). Records contain the chosen basis and its Born
outcome (Eq. S1). Inverting this channel gives the score of each measured observable.
[Huang, Kueng and Preskill, Supplementary Theorem 1](https://doi.org/10.1038/s41567-020-0932-7)
-/

@[expose] public section
noncomputable section

namespace FQChem.Properties.ShadowMeasurement

open MeasureTheory ProbabilityTheory Matrix
open scoped Classical BigOperators ComplexConjugate ComplexOrder

abbrev Mat (d : ℕ) := Matrix (Fin d) (Fin d) ℂ
abbrev State (d : ℕ) := {ρ : Mat d // ρ.PosSemidef ∧ ρ.trace = 1}

variable {X : Type*} [MeasurableSpace X] {d : ℕ}

/-- The observed projector U†|b⟩⟨b|U, for the chosen basis and its output label. -/
def projector (U : X → Mat d) (r : X × Fin d) : Mat d :=
  fun i j => conj (U r.1 r.2 i) * U r.1 r.2 j

def pairing (A B : Mat d) : ℂ := (A * B).trace

/-- The measurement data in Supplementary Definition 1 and Eqs. (S1)–(S2).
The Born law is identified by all bounded measurable test functions. The
complex-linear channel is required to be invertible. -/
structure Primitive (X : Type*) [MeasurableSpace X] (d : ℕ) where
  basis : X → Mat d
  unitary : ∀ x, basis x ∈ Matrix.unitaryGroup (Fin d) ℂ
  measurable : ∀ i j, Measurable (fun x => basis x i j)
  ensemble : ProbabilityMeasure X
  law : State d → ProbabilityMeasure (X × Fin d)
  born : ∀ (ρ : State d) (f : X × Fin d → ℂ), Measurable f →
    (∃ C : ℝ, ∀ r, ‖f r‖ ≤ C) →
    (∫ r, f r ∂(law ρ : Measure _)) = ∫ x, ∑ b : Fin d,
      pairing ρ.val (projector basis (x,b)) * f (x,b) ∂(ensemble : Measure X)
  channel : Mat d ≃ₗ[ℂ] Mat d
  channel_eq : ∀ A B, pairing (channel A) B = ∫ x, ∑ b : Fin d,
    pairing A (projector basis (x,b)) * pairing B (projector basis (x,b)) ∂(ensemble : Measure X)

namespace Primitive

variable (P : Primitive X d)

private theorem traceProjector (x : X) (b : Fin d) : (projector P.basis (x,b)).trace = 1 := by
  have h := congrArg (fun A : Mat d => A b b) (Matrix.mem_unitaryGroup_iff.mp (P.unitary x))
  simpa [Matrix.trace, Matrix.diag, projector, Matrix.mul_apply, Matrix.star_eq_conjTranspose,
    Matrix.conjTranspose_apply, mul_comm] using h

private theorem sumProjector (x : X) : ∑ b, projector P.basis (x,b) = 1 := by
  have h := Matrix.mem_unitaryGroup_iff'.mp (P.unitary x)
  ext i j
  simpa [Matrix.sum_apply, projector, Matrix.mul_apply, Matrix.star_eq_conjTranspose,
    Matrix.conjTranspose_apply] using congrArg (fun A : Mat d => A i j) h

private theorem basisEntry (x : X) (i j : Fin d) : ‖P.basis x i j‖ ≤ 1 := by
  have h := P.traceProjector x i
  have he : (∑ k, ‖P.basis x i k‖ ^ 2 : ℝ) = 1 := by
    apply Complex.ofReal_injective
    simpa [Matrix.trace, Matrix.diag, projector, mul_comm, Complex.mul_conj,
      Complex.normSq_eq_norm_sq] using h
  have hi := Finset.single_le_sum (f := fun k => ‖P.basis x i k‖^2)
    (fun k _ => sq_nonneg _) (Finset.mem_univ j)
  rw [he] at hi
  nlinarith [norm_nonneg (P.basis x i j)]

private theorem projectorMeasurable (i j : Fin d) :
    Measurable (fun r => projector P.basis r i j) := by
  have h (k : Fin d) : Measurable (fun r : X × Fin d => P.basis r.1 r.2 k) := by
    apply measurable_from_prod_countable_left
    intro b
    exact P.measurable b k
  exact (Complex.continuous_conj.measurable.comp (h i)).mul (h j)

private theorem pairingMeasurable (A : Mat d) :
    Measurable (fun r => pairing A (projector P.basis r)) := by
  simp only [pairing, Matrix.trace, Matrix.diag, Matrix.mul_apply]
  exact Finset.univ.measurable_fun_sum fun i _ => Finset.univ.measurable_fun_sum fun j _ =>
    (P.projectorMeasurable j i).const_mul (A i j)

private theorem pairingBound (A : Mat d) (r : X × Fin d) :
    ‖pairing A (projector P.basis r)‖ ≤ ∑ i, ∑ j, ‖A i j‖ := by
  unfold pairing
  simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply]
  refine (norm_sum_le _ _).trans (Finset.sum_le_sum fun i _ =>
    (norm_sum_le _ _).trans (Finset.sum_le_sum fun j _ => ?_))
  rw [norm_mul]
  apply mul_le_of_le_one_right (norm_nonneg _)
  dsimp [projector]
  rw [norm_mul, Complex.norm_conj]
  exact (mul_le_of_le_one_right (norm_nonneg _) (P.basisEntry ..)).trans (P.basisEntry ..)

private theorem channelSymmetric (A B : Mat d) :
    pairing (P.channel A) B = pairing A (P.channel B) := by
  rw [show pairing A (P.channel B) = pairing (P.channel B) A from Matrix.trace_mul_comm ..,
    P.channel_eq, P.channel_eq]
  simp_rw [mul_comm (pairing A _) (pairing B _)]

private theorem pairingAdjoint (A B : Mat d) : pairing Aᴴ B = conj (pairing A Bᴴ) := by
  rw [pairing, pairing, ← Complex.star_def, ← Matrix.trace_conjTranspose,
    Matrix.conjTranspose_mul, Matrix.conjTranspose_conjTranspose, Matrix.trace_mul_comm]

private theorem projectorHermitian (r : X × Fin d) : (projector P.basis r).IsHermitian := by
  ext i j
  simp [projector, Matrix.conjTranspose_apply, mul_comm]

private theorem inverseHermitian (A : Mat d) (hA : A.IsHermitian) : (P.channel.symm A).IsHermitian := by
  have adj (C : Mat d) : P.channel Cᴴ = (P.channel C)ᴴ := by
    apply Matrix.ext_iff_trace_mul_right.mpr
    intro B
    change pairing (P.channel Cᴴ) B = pairing (P.channel C)ᴴ B
    rw [pairingAdjoint (P.channel C), P.channel_eq, P.channel_eq, ← integral_conj]
    congr 1
    funext x
    rw [map_sum]
    apply Finset.sum_congr rfl
    intro b _
    rw [pairingAdjoint C, pairingAdjoint B, (P.projectorHermitian (x,b)).eq,
      map_mul, Complex.conj_conj]
  apply P.channel.injective
  rw [adj, LinearEquiv.apply_symm_apply, hA.eq]

private theorem channelOne : P.channel 1 = 1 := by
  have h (B : Mat d) : pairing (P.channel 1) B = B.trace := by
    rw [P.channel_eq]
    simp_rw [show ∀ x (b : Fin d), pairing 1 (projector P.basis (x,b)) = 1 by
      intro x b; simpa [pairing] using P.traceProjector x b, one_mul]
    have sum (x : X) : ∑ b, pairing B (projector P.basis (x,b)) = B.trace := by
      simp only [pairing, ← Matrix.trace_sum, ← Matrix.mul_sum, P.sumProjector, Matrix.mul_one]
    simp [sum]
  exact Matrix.ext_iff_trace_mul_right.mpr fun B => by simpa [pairing] using h B

/-- The one-shot real observable score from Eq. (S7). -/
def score (A : Mat d) (r : X × Fin d) : ℝ := (pairing (P.channel.symm A) (projector P.basis r)).re

/-- Inverting the raw projector gives the same score as inverting the observable. -/
theorem inverseSnapshotScore (A : Mat d) (r : X × Fin d) :
    P.score A r = (pairing A (P.channel.symm (projector P.basis r))).re := by
  have h := P.channelSymmetric (P.channel.symm A) (P.channel.symm (projector P.basis r))
  simpa [score] using congrArg Complex.re h.symm

private theorem scoreMeasurable (A : Mat d) : Measurable (P.score A) :=
  Complex.continuous_re.measurable.comp (P.pairingMeasurable _)

private theorem scoreLp (ρ : State d) (A : Mat d) : MemLp (P.score A) 2 (P.law ρ : Measure _) :=
  MemLp.of_bound (P.scoreMeasurable A).aestronglyMeasurable _ (Filter.Eventually.of_forall
    fun r => (Complex.abs_re_le_norm _).trans (P.pairingBound (P.channel.symm A) r))

/-- Unbiasedness follows from the Born law and the inverse of the measurement channel. -/
theorem scoreMean (ρ : State d) (A : Mat d) :
    (∫ r, P.score A r ∂(P.law ρ : Measure _)) = (pairing A ρ.val).re := by
  let B := P.channel.symm A
  let f := fun r => pairing B (projector P.basis r)
  have hf := P.pairingMeasurable B
  have hb := P.pairingBound B
  have hi : Integrable f (P.law ρ : Measure _) :=
    (MemLp.of_bound (p := 2) hf.aestronglyMeasurable _ (Filter.Eventually.of_forall hb)).integrable (by norm_num)
  change (∫ r, RCLike.re (f r) ∂(P.law ρ : Measure _)) = _
  rw [integral_re hi, P.born ρ f hf ⟨_,hb⟩]
  simp only [f, mul_comm (pairing ρ.val _) (pairing B _), ← P.channel_eq, B, LinearEquiv.apply_symm_apply,
    RCLike.re_eq_complex_re]

/-- Remove the scalar part of the observable. -/
def centered (A : Mat d) : Mat d := A - (A.trace / (d : ℂ)) • (1 : Mat d)

private theorem scoreCentered (A : Mat d) (r : X × Fin d) :
    P.score (centered A) r = P.score A r - (A.trace / (d : ℂ)).re := by
  have h1 : P.channel.symm 1 = 1 := P.channel.symm_apply_eq.mpr P.channelOne.symm
  simp [score, centered, h1, pairing, Matrix.sub_mul, P.traceProjector]

/-- The trace score in (S7) is real for a Hermitian observable. -/
theorem hermitianScore (A : Mat d) (hA : A.IsHermitian) (r : X × Fin d) :
    (P.score A r : ℂ) = pairing (P.channel.symm A) (projector P.basis r) := by
  apply Complex.conj_eq_iff_re.mp
  have h := pairingAdjoint (P.channel.symm A) (projector P.basis r)
  rwa [(P.inverseHermitian A hA).eq, (P.projectorHermitian r).eq, eq_comm] at h

/-- The one-state term of Eq. (S7), directly in terms of the basis measure, Born weights
and the inverse observable. This identity also holds for non-discrete ensembles. -/
theorem bornSecondMoment (ρ : State d) (A : Mat d) (hA : A.IsHermitian) :
    (((∫ r, P.score A r ^ 2 ∂(P.law ρ : Measure _)) : ℝ) : ℂ) = ∫ x, ∑ b : Fin d,
      pairing ρ.val (projector P.basis (x,b)) * (pairing (P.channel.symm A) (projector P.basis (x,b)))^2
      ∂(P.ensemble : Measure X) := by
  rw [← integral_complex_ofReal]
  have hf : Measurable (fun r => ((P.score A r ^ 2 : ℝ) : ℂ)) :=
    Complex.continuous_ofReal.measurable.comp ((P.scoreMeasurable A).pow_const 2)
  rw [P.born ρ _ hf]
  · simp_rw [Complex.ofReal_pow, P.hermitianScore A hA]
  · refine ⟨(∑ i, ∑ j, ‖(P.channel.symm A) i j‖)^2, ?_⟩
    intro r
    rw [Complex.norm_real, Real.norm_eq_abs, abs_pow]
    exact pow_le_pow_left₀ (abs_nonneg _) ((Complex.abs_re_le_norm _).trans (P.pairingBound _ _)) 2

/-- The squared shadow norm in (S7) is the supremum of the one-shot second moment over states. -/
def shadowNormSq (A : Mat d) : ℝ :=
  sSup (Set.range fun ρ : State d => ∫ r, P.score A r ^ 2 ∂(P.law ρ : Measure _))

private theorem moment_le (ρ : State d) (A : Mat d) :
    (∫ r, P.score A r ^ 2 ∂(P.law ρ : Measure _)) ≤ P.shadowNormSq A := by
  let C := ∑ i, ∑ j, ‖(P.channel.symm A) i j‖
  apply le_csSup _ (Set.mem_range_self ρ)
  refine ⟨C^2, ?_⟩
  rintro _ ⟨σ,rfl⟩
  have hi := (P.scoreLp σ A).integrable_sq
  have bound (r) : |P.score A r| ≤ C := (Complex.abs_re_le_norm _).trans (P.pairingBound _ _)
  calc
    _ ≤ ∫ _ : X × Fin d, C^2 ∂(P.law σ : Measure _) :=
      integral_mono hi (integrable_const _) (fun r => by
        simpa only [sq_abs] using (pow_le_pow_left₀ (abs_nonneg _) (bound r) 2))
    _ = _ := by simp

/-- Supplementary Lemma 1. Removing the trace leaves the variance unchanged. -/
theorem centeredVariance (ρ : State d) (A : Mat d) :
    variance (P.score A) (P.law ρ : Measure _) ≤ P.shadowNormSq (centered A) := by
  have hx := variance_sub_const (μ := (P.law ρ : Measure _)) (P.scoreMeasurable A).aestronglyMeasurable
    (A.trace / (d : ℂ)).re
  have hc : P.score (centered A) = fun r => P.score A r - (A.trace / (d : ℂ)).re :=
    funext (P.scoreCentered A)
  rw [← hx, ← hc, variance_eq_sub (P.scoreLp ρ (centered A))]
  exact (sub_le_self _ (sq_nonneg _)).trans (P.moment_le ρ _)

/-- The largest centered squared shadow norm of the requested nonempty family. -/
def worstNorm {T : Type*} [Fintype T] [Nonempty T] (A : T → Mat d) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty fun t => P.shadowNormSq (centered (A t))

/-- Supplementary Theorem 1. Choose arbitrary Hermitian observables, a density state and
an invertible unitary-basis measurement primitive. All observables reuse the same NK
independent Born records. The probability of any prediction missing by ε is at most δ. -/
theorem sampleComplexity {T Ω : Type*} [Fintype T] [Nonempty T] [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (ρ : State d) (A : T → Mat d)
    (_hermitian : ∀ t, (A t).IsHermitian) (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ ≤ 1)
    (D : ShadowConfidence.Blocks μ (X × Fin d) (ShadowConfidence.shots (P.worstNorm A) ε)
      (ShadowConfidence.blocks (Fintype.card T) δ))
    (bornDraw : ∀ b i, MeasurePreserving (fun ω => D.record b ω i) μ (P.law ρ)) :
    μ.real {ω | ∃ t, ε ≤ |ShadowConfidence.median (ShadowConfidence.blocks_pos _ Fintype.card_pos hδ hδ1)
      (fun b => ShadowConfidence.blockMean (P.score (A t)) (D.record b ω)) - (pairing (A t) ρ.val).re|} ≤ δ := by
  apply ShadowConfidence.simultaneousConfidence _ (fun t => P.scoreMeasurable (A t)) _ _ _ _ hε hδ hδ1 D
  · intro t b i
    exact (P.scoreLp ρ (A t)).comp_measurePreserving (bornDraw b i)
  · intro t b i
    rw [← integral_map (bornDraw b i).aemeasurable (P.scoreMeasurable _).aestronglyMeasurable,
      (bornDraw b i).map_eq, P.scoreMean]
  · intro t b i
    rw [(bornDraw b i).variance_fun_comp (P.scoreMeasurable _).aemeasurable]
    exact (P.centeredVariance ρ (A t)).trans (Finset.le_sup'
      (fun s => P.shadowNormSq (centered (A s))) (Finset.mem_univ t))

/-- Eq. (S13) on the canonical NK-fold product of the actual Born law. -/
theorem iidSampleComplexity {T : Type*} [Fintype T] [Nonempty T] (ρ : State d) (A : T → Mat d)
    (hA : ∀ t, (A t).IsHermitian) (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ ≤ 1) :
    let N := ShadowConfidence.shots (P.worstNorm A) ε
    let K := ShadowConfidence.blocks (Fintype.card T) δ
    (ShadowConfidence.productLaw (P.law ρ : Measure _) N K).real
      {ω | ∃ t, ε ≤ |ShadowConfidence.median (ShadowConfidence.blocks_pos _ Fintype.card_pos hδ hδ1)
        (fun b => ShadowConfidence.blockMean (P.score (A t)) (ω b)) - (pairing (A t) ρ.val).re|} ≤ δ :=
  P.sampleComplexity _ ρ A hA ε δ hε hδ hδ1 (ShadowConfidence.iidBlocks (P.law ρ : Measure _) _ _)
    (fun b i => by simpa only [ShadowConfidence.iidBlocks] using
      ShadowConfidence.productDraw (P.law ρ : Measure (X × Fin d)) b i)

end Primitive

end FQChem.Properties.ShadowMeasurement
