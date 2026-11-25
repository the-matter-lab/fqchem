module

public import FQChem.Properties.ResponseAndEstimation.BellSampling
public import FQChem.Properties.ResponseAndEstimation.PauliPrediction
public import Mathlib.Analysis.Matrix.Order
public import Mathlib.Probability.ProbabilityMassFunction.Integrals
public import Mathlib.Probability.ProbabilityMassFunction.Constructions
public import Mathlib.Probability.Independence.Integration
public import Mathlib.Probability.Moments.SubGaussian
import Mathlib.Tactic

/-! # Predicting a Pauli expectation after data collection

Each shot measures every corresponding pair of qubits of two copies in the Bell basis.
The same classical record thus supports any subsequently specified Pauli. The clipped
square root of its mean sign estimates the magnitude of the Pauli expectation.

* [Huang et al., Supplement D.2, Eqs. (D6)–(D11)](https://doi.org/10.1126/science.abn7293)
-/

@[expose] public section
noncomputable section
namespace FQChem.Properties.BellConfidence

open FQChem.Complexity.ElectronicStructure FQChem.Properties.BellSampling
open MeasureTheory ProbabilityTheory Matrix
open scoped ComplexOrder Kronecker Classical

variable {n : ℕ}
abbrev Record (n : ℕ) := Fin n → Bell
abbrev State (n : ℕ) := {ρ : Matrix (Spin n) (Spin n) ℂ // ρ.PosSemidef ∧ ρ.trace = 1}

private def localAmplitude (b : Bell) (r u : Bool) : ℂ :=
  if u = (r ^^ b.1) then sign (b.2 && r) else 0

private theorem projector_gram (b : Bell) (r u c v : Bool) :
    projector b r u c v = localAmplitude b r u * star (localAmplitude b c v) / 2 := by
  obtain ⟨f,z⟩ := b
  cases f <;> cases z <;> cases r <;> cases u <;> cases c <;> cases v <;>
    norm_num [projector, localAmplitude, sign]

/-- Every product Bell outcome on the two copies has a nonnegative real Born weight. -/
theorem weight_nonneg (ρ : State n) (b : Record n) : 0 ≤ bornWeight ρ.1 b := by
  let v (x : Spin n × Spin n) : ℂ := ∏ i, localAmplitude (b i) (x.1 i) (x.2 i)
  have gram : bornWeight ρ.1 b =
      (star v ⬝ᵥ (ρ.1 ⊗ₖ ρ.1) *ᵥ v) / (2:ℂ)^n := by
    unfold bornWeight
    simp only [projector_gram, Finset.prod_div_distrib, Finset.prod_mul_distrib,
      Finset.prod_const, Finset.card_univ, Fintype.card_fin,
      dotProduct, Matrix.mulVec, Pi.star_apply, Finset.mul_sum]
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro x _
    rw [Finset.sum_div]
    apply Finset.sum_congr rfl
    intro y _
    simp [v, div_eq_mul_inv, mul_comm, mul_assoc, mul_left_comm]
  rw [gram]
  exact div_nonneg ((ρ.2.1.kronecker ρ.2.1).dotProduct_mulVec_nonneg v) (by positivity)

/-- Bell weights are normalized for every positive trace-one input. -/
theorem weight_sum (ρ : State n) : ∑ b, bornWeight ρ.1 b = 1 := by
  have hid (x y : Spin n) : wordEntry (fun _ => Pauli.I) y x = if x = y then 1 else 0 := by
    rw [wordEntry_eq]
    simp [logicalMove, logicalPhase, Pauli.move, Pauli.phase]
  have h := squaredPauliExpectation ρ.1 (fun _ => Pauli.I)
  simpa [readout, hid, show ∑ x, ρ.1 x x = 1 from ρ.2.2] using h

def law (ρ : State n) : PMF (Record n) :=
  PMF.ofFintype (fun b => ENNReal.ofReal (bornWeight ρ.1 b).re) (by
    rw [← ENNReal.ofReal_sum_of_nonneg (fun b _ => (Complex.nonneg_iff.mp (weight_nonneg ρ b)).1)]
    simp [← Complex.re_sum, weight_sum])

def magnitude (ρ : State n) (p : Word n) : ℝ := ‖∑ x, ∑ y, ρ.1 x y * wordEntry p y x‖

def score (p : Word n) (b : Record n) : ℝ := (∏ i, readout (p i) (b i)).re

private theorem score_sign (p : Word n) (b : Record n) :
    (∏ i, readout (p i) (b i)) = 1 ∨ (∏ i, readout (p i) (b i)) = -1 := by
  apply Finset.prod_induction _ (fun x : ℂ => x = 1 ∨ x = -1)
  · intro x y hx hy
    rcases hx with rfl | rfl <;> rcases hy with rfl | rfl <;> norm_num
  · simp
  · intro i _
    obtain ⟨f,z⟩ := b i
    cases p i <;> cases f <;> cases z <;> norm_num [readout, sign]

/-- The record law is independent of the Pauli; its bounded sign statistic has mean |Tr(Pρ)|². -/
theorem score_mean (ρ : State n) (p : Word n) :
    ∫ b, score p b ∂(law ρ).toMeasure = magnitude ρ p ^ 2 := by
  rw [PMF.integral_eq_sum]
  have h := congrArg Complex.re (magnitudeSquaredPauliExpectation ρ.1 ρ.2.1.isHermitian p)
  simp only [Complex.re_sum, Complex.ofReal_re] at h
  change _ = ‖∑ x, ∑ y, ρ.1 x y * wordEntry p y x‖ ^ 2
  rw [← h]
  apply Finset.sum_congr rfl
  intro b _
  change ENNReal.toReal (ENNReal.ofReal _) * _ = _
  rw [ENNReal.toReal_ofReal (Complex.nonneg_iff.mp (weight_nonneg ρ b)).1]
  rcases score_sign p b with hb | hb <;> simp [score, hb]

abbrev records (ρ : State n) (N : ℕ) : Measure (Fin N → Record n) :=
  Measure.pi fun _ => (law ρ).toMeasure

def mean {N : ℕ} (p : Word n) (v : Fin N → Record n) : ℝ :=
  (∑ i, score p (v i)) / N

/-- Appendix D.2.b, Lemma 1. The ordinary mean of N Bell signs has two-sided
Hoeffding failure probability at most 2 exp(−N u²/2) at squared-magnitude error u. -/
theorem meanFailure (ρ : State n) (p : Word n) {N : ℕ} (hN : 0 < N) (u : ℝ) (hu : 0 < u) :
    (records ρ N).real {v | u ≤ |mean p v - magnitude ρ p ^ 2|} ≤
      2 * Real.exp (-((N : ℝ) * u ^ 2) / 2) := by
  let μ := records ρ N
  let m := magnitude ρ p ^ 2
  let Z (i : Fin N) (v : Fin N → Record n) := score p (v i) - m
  have mscore : Measurable (score p) := .of_discrete
  have hsub : HasSubgaussianMGF (fun b => score p b - m) 1 (law ρ).toMeasure := by
    have h := hasSubgaussianMGF_of_mem_Icc mscore.aemeasurable
      (a := (-1 : ℝ)) (b := (1 : ℝ)) (μ := (law ρ).toMeasure)
      (Filter.Eventually.of_forall fun b => by
        rcases score_sign p b with hb | hb <;> simp [score, hb])
    norm_num [score_mean, m] at h ⊢
    exact h
  have hind : iIndepFun Z μ :=
    iIndepFun_pi (X := fun _ b => score p b - m) (fun _ => (mscore.sub_const m).aemeasurable)
  have hs (i : Fin N) : HasSubgaussianMGF (Z i) 1 μ := by
    have mapped : HasSubgaussianMGF (fun b => score p b - m) 1 (μ.map (Function.eval i)) := by
      rwa [(measurePreserving_eval (fun _ : Fin N => (law ρ).toMeasure) i).map_eq]
    exact HasSubgaussianMGF.of_map (X := fun b : Record n => score p b - m) (Y := Function.eval i)
      (μ := μ) (measurable_pi_apply i).aemeasurable mapped
  have hsum := HasSubgaussianMGF.sum_of_iIndepFun (s := Finset.univ) hind (fun i _ => hs i)
  have hNr : (0 : ℝ) < N := by exact_mod_cast hN
  let t := (N : ℝ) * u
  have ht : 0 ≤ t := mul_nonneg hNr.le hu.le
  have hpos := hsum.measure_ge_le ht
  have hneg := hsum.neg.measure_ge_le ht
  let f := fun v => ∑ i, Z i v
  have hs' (v) : f v = N * (mean p v - m) := by
    simp [f, Z, mean, Finset.sum_sub_distrib, mul_sub]
    field_simp
  have incl : {v | u ≤ |mean p v - m|} ⊆ {v | t ≤ f v} ∪ {v | t ≤ -f v} := by
    intro v hv
    change u ≤ |mean p v - m| at hv
    change t ≤ f v ∨ t ≤ - f v
    rw [hs']
    rcases le_abs.mp hv with h | h
    · exact Or.inl (mul_le_mul_of_nonneg_left h hNr.le)
    · exact Or.inr (by dsimp [t]; nlinarith [mul_le_mul_of_nonneg_left h hNr.le])
  have htail : Real.exp (-t^2 / (2 * (N : ℝ))) = Real.exp (-((N : ℝ) * u^2) / 2) := by
    congr 1
    dsimp [t]
    field_simp
  calc
    _ ≤ μ.real ({v | t ≤ f v} ∪ {v | t ≤ -f v}) := measureReal_mono incl
    _ ≤ μ.real {v | t ≤ f v} + μ.real {v | t ≤ -f v} := measureReal_union_le _ _
    _ ≤ _ := by
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one,
        NNReal.coe_natCast, Pi.neg_apply] at hpos hneg
      rw [← htail, two_mul]
      exact add_le_add hpos hneg

private theorem clipped_error (x y : ℝ) (hy : 0 ≤ y) :
    (Real.sqrt (max 0 x) - y)^2 ≤ |x - y^2| := by
  rcases le_total 0 x with hx | hx
  · rw [max_eq_right hx]
    have hs := Real.sq_sqrt hx
    have hp := Real.sqrt_nonneg x
    rcases le_total (Real.sqrt x) y with hr | hr
    · exact le_trans (by nlinarith [mul_nonneg hp (sub_nonneg.mpr hr)] : _ ≤ -(x-y^2))
        (neg_le_abs _)
    · exact le_trans (by nlinarith [mul_nonneg hy (sub_nonneg.mpr hr)] : _ ≤ x-y^2) (le_abs_self _)
  · rw [max_eq_left hx, Real.sqrt_zero, zero_sub, neg_sq]
    exact le_trans (by linarith : y^2 ≤ -(x-y^2)) (neg_le_abs _)

/-- D.2, Corollary 1. With 2048 independent pair measurements the estimate for any
subsequently specified Pauli is within 1/4 with probability at least 4/5, for every
n-qubit density operator. All 4096 copies are measured before the Pauli is specified. -/
theorem predictMagnitude (ρ : State n) (p : Word n) :
    (records ρ 2048).real {v | 1/4 < |Real.sqrt (max 0 (mean p v)) - magnitude ρ p|} ≤ 1/5 := by
  have incl : {v : Fin 2048 → Record n | 1/4 < |Real.sqrt (max 0 (mean p v)) - magnitude ρ p|} ⊆
      {v | 1/16 ≤ |mean p v - magnitude ρ p ^ 2|} := by
    intro v hv
    change 1/4 < |_ - _| at hv
    exact le_trans (by nlinarith [sq_abs (Real.sqrt (max 0 (mean p v)) - magnitude ρ p),
      mul_self_le_mul_self (by norm_num : (0 : ℝ) ≤ 1/4) hv.le] :
      1/16 ≤ (Real.sqrt (max 0 (mean p v)) - magnitude ρ p)^2)
      (clipped_error _ _ (norm_nonneg _))
  refine (measureReal_mono incl).trans ((meanFailure ρ p (by decide : 0 < 2048) _ (by norm_num)).trans ?_)
  norm_num
  rw [Real.exp_neg]
  have h4 : (10 : ℝ) ≤ Real.exp 4 := calc
    (10 : ℝ) ≤ 2 ^ 4 := by norm_num
    _ ≤ (Real.exp 1) ^ 4 := by gcongr; linarith [Real.add_one_le_exp (1:ℝ)]
    _ = _ := by rw [← Real.exp_nat_mul]; norm_num
  rw [← div_eq_mul_inv]
  exact (div_le_div_iff₀ (Real.exp_pos _) (by norm_num : (0:ℝ)<5)).mpr (by nlinarith)

open FQChem.Dynamics.OTOC FQChem.Properties.PauliPrediction

private theorem traceDifferent (p q : Word n) (hne : p ≠ q) :
    (wordMatrix p * wordMatrix q).trace = 0 := by
  classical
  obtain ⟨j, hj⟩ := Function.ne_iff.mp hne
  let g (i : Fin n) (x y : Bool) := (p i).entry x y * (q i).entry y x
  change (∑ x : Spin n, ∑ y : Spin n, (∏ i, (p i).entry (x i) (y i)) * ∏ i, (q i).entry (y i) (x i)) = 0
  simp_rw [← Finset.prod_mul_distrib]
  change (∑ x : Spin n, ∑ y : Spin n, ∏ i, g i (x i) (y i)) = 0
  have inner (x : Spin n) : (∑ y : Spin n, ∏ i, g i (x i) (y i)) =
      ∏ i, ∑ y : Bool, g i (x i) y := (Fintype.prod_sum (fun i y => g i (x i) y)).symm
  simp_rw [inner]
  rw [← Fintype.prod_sum (fun i x => ∑ y, g i x y)]
  have orthogonal (P Q : Pauli) (distinct : P ≠ Q) :
      (∑ x : Bool, ∑ y : Bool, P.entry x y * Q.entry y x) = 0 := by
    simp only [Fintype.sum_bool]
    cases P <;> cases Q <;> first
      | exact (distinct rfl).elim
      | norm_num [Pauli.entry, Pauli.phase, Pauli.move]
  exact Finset.prod_eq_zero (Finset.mem_univ j) (orthogonal _ _ hj)

/-- The promised state (I+aP)/2ⁿ is a density operator for a nonidentity P and |a|≤1. -/
def hiddenState (p : Word n) (hp : p ∈ nonidentity n) (a : ℝ) (ha : |a| ≤ 1) : State n :=
  ⟨hardState p a, hardStatePositive p ha, hardStateTrace p hp a⟩

/-- Under the task's hidden state, every nonidentity query other than P has zero mean
Pauli expectation. The true Pauli has expectation of magnitude |a|. -/
theorem hiddenMagnitude (p q : Word n) (hp : p ∈ nonidentity n) (hq : q ∈ nonidentity n)
    (a : ℝ) (ha : |a| ≤ 1) :
    magnitude (hiddenState p hp a ha) q = if q = p then |a| else 0 := by
  change ‖(hardState p a * wordMatrix q).trace‖ = _
  by_cases he : q = p
  · subst q
    simp [hardStateTracePairing p hp a]
  · simp [hardState, Matrix.add_mul, Matrix.trace_smul, Matrix.trace_add, pauliTrace q hq,
      traceDifferent p q (Ne.symm he), he]

/-- With the two labels in either order, report whether the first has the larger shared-record
score. Ties are resolved in favor of the second candidate. -/
def firstLarger {N : ℕ} (left right : Word n) (v : Fin N → Record n) : Bool :=
  decide (mean right v < mean left v)

/-- Appendix D.4, Task 1 and Eq. (D39). For each distinct nonidentity pair and either
hidden sign, 256 pair measurements select the true Pauli with success at least 4/5,
in both orderings. The two scores use the very same 512 copies. -/
theorem selectHiddenWord (p q : Word n) (hp : p ∈ nonidentity n) (hq : q ∈ nonidentity n)
    (hne : p ≠ q) (a : ℝ) (ha : |a| = 9/10) :
    let ρ := hiddenState p hp a (by rw [ha]; norm_num)
    (records ρ 256).real {v | firstLarger p q v ≠ true ∨ firstLarger q p v ≠ false} ≤ 1/5 := by
  let ρ := hiddenState p hp a (by rw [ha]; norm_num)
  have H₁ : magnitude ρ p = 9/10 := by rw [hiddenMagnitude p p hp hp]; simp [ha]
  have H₂ : magnitude ρ q = 0 := by rw [hiddenMagnitude p q hp hq]; simp [Ne.symm hne]
  let bad (w : Word n) := {v : Fin 256 → Record n | 3/8 ≤ |mean w v - magnitude ρ w^2|}
  have incl : {v : Fin 256 → Record n | firstLarger p q v ≠ true ∨ firstLarger q p v ≠ false} ⊆
      bad p ∪ bad q := by
    intro v hv
    by_contra hh
    have b₁ : |mean p v - magnitude ρ p^2| < 3/8 := lt_of_not_ge (fun h => hh (Or.inl h))
    have b₂ : |mean q v - magnitude ρ q^2| < 3/8 := lt_of_not_ge (fun h => hh (Or.inr h))
    rw [H₁] at b₁
    rw [H₂] at b₂
    have hlt : mean q v < mean p v := by linarith [(abs_lt.mp b₁).1, (abs_lt.mp b₂).2]
    change firstLarger p q v ≠ true ∨ firstLarger q p v ≠ false at hv
    simp [firstLarger, hlt, not_lt.mpr hlt.le] at hv
  have tail (w : Word n) : (records ρ 256).real (bad w) ≤ 1/10 := by
    refine (meanFailure ρ w (by decide : 0 < 256) _ (by norm_num)).trans ?_
    norm_num
    rw [Real.exp_neg, ← div_eq_mul_inv]
    apply (div_le_div_iff₀ (Real.exp_pos _) (by norm_num : (0:ℝ)<10)).mpr
    have h9 := Real.add_one_le_exp (9 : ℝ)
    have h18 : Real.exp 18 = Real.exp 9 ^ 2 := by rw [pow_two, ← Real.exp_add]; norm_num
    rw [h18]
    nlinarith [sq_nonneg (Real.exp 9 - 10)]
  refine (measureReal_mono incl).trans ((measureReal_union_le _ _).trans ?_)
  linarith [tail p, tail q]

end FQChem.Properties.BellConfidence
