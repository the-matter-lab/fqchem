module

public import FQChem.Properties.ResponseAndEstimation.ClassicalShadows
public import Mathlib.Probability.Moments.Variance
public import Mathlib.Data.Fin.Tuple.Sort
public import Mathlib.Data.Nat.Log
import Mathlib.Tactic

/-!
# Simultaneous Pauli prediction by median of means

Pauli specialization of the classical-shadow guarantee of Huang, Kueng and
Preskill, Supplementary Theorem 1 and Lemma 3 (doi:10.1038/s41567-020-0932-7).
A single collection of random measurement records is reused for every target.
-/

@[expose] public section
noncomputable section

namespace FQChem.Properties.ClassicalShadows

open MeasureTheory ProbabilityTheory FQChem.Complexity.ElectronicStructure
open scoped ComplexConjugate

abbrev Shot (n : ℕ) := Setting n × Spin n

def restrictShot {n k : ℕ} (wire : Fin k ↪ Fin n) (s : Shot n) : Shot k :=
  (s.1 ∘ wire, s.2 ∘ wire)

def singleEstimate {k : ℕ} (p : Setting k) (s : Shot k) : ℝ := (estimate p s.1 s.2).re

def pauliMean {k : ℕ} (ρ : Matrix (Spin k) (Spin k) ℂ) (p : Setting k) : ℝ :=
  (∑ x, ∑ y, ρ x y * wordEntry (axis ∘ p) y x).re

variable {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]

/-- Each block contains N measurement records. Draws within each block are
independent. The entire records of distinct blocks are mutually independent. -/
structure ShadowBlocks (μ : Measure Ω) (n N B : ℕ) where
  record : Fin B → Ω → Fin N → Shot n
  measurable : ∀ b, Measurable (record b)
  independentWithin : ∀ b, iIndepFun (fun i ω => record b ω i) μ
  independentBlocks : iIndepFun record μ

variable {n N B k : ℕ}

/-- The marginal law on a target support is the uniform-axis Born law of
its reduced density matrix, specified on all functions of that finite record. -/
def HasBornLaw (D : ShadowBlocks μ n N B) (wire : Fin k ↪ Fin n)
    (ρ : Matrix (Spin k) (Spin k) ℂ) : Prop :=
  ∀ b i (f : Shot k → ℝ),
    (∫ ω, f (restrictShot wire (D.record b ω i)) ∂μ) =
      (mean ρ (fun a s => (f (a, s) : ℂ))).re

def blockMean (wire : Fin k ↪ Fin n) (p : Setting k) (block : Fin N → Shot n) : ℝ :=
  (N : ℝ)⁻¹ * ∑ i, singleEstimate p (restrictShot wire (block i))

/-- The middle order statistic of an odd number of real block means. -/
def median {r : ℕ} (values : Fin (2*r+1) → ℝ) : ℝ :=
  values (Tuple.sort values ⟨r, by omega⟩)

private theorem estimate_real (p : Setting k) (a : Setting k) (s : Spin k) :
    ((singleEstimate p (a,s) : ℝ) : ℂ) = estimate p a s := by
  apply Complex.conj_eq_iff_re.mp
  have hs (b : Bool) : conj (sign b) = sign b := by cases b <;> simp [sign]
  have three : conj (3 : ℂ) = 3 := map_ofNat _ _
  by_cases h : a = p <;> simp [estimate, h, map_prod, hs, three]

/-- Chebyshev bound for one block, using the exact single-shot Pauli moments. -/
theorem blockPrediction (D : ShadowBlocks μ n N B) (wire : Fin k ↪ Fin n)
    (ρ : Matrix (Spin k) (Spin k) ℂ) (hρ : ρ.trace = 1) (law : HasBornLaw D wire ρ)
    (p : Setting k) (b : Fin B) (hN : 0 < N) {ε : ℝ} (hε : 0 < ε) :
    μ.real {ω | ε ≤ |blockMean wire p (D.record b ω) - pauliMean ρ p|} ≤
      (3 : ℝ)^k / ((N : ℝ) * ε^2) := by
  let eval := fun s : Shot n => singleEstimate p (restrictShot wire s)
  let X := fun i : Fin N => fun ω => eval (D.record b ω i)
  have me : Measurable eval := Measurable.of_discrete
  have mx (i : Fin N) : Measurable (X i) :=
    me.comp ((measurable_pi_apply i).comp (D.measurable b))
  obtain ⟨c, hc⟩ := (Set.finite_range (fun s : Shot n => ‖eval s‖)).bddAbove
  have lp (i) : MemLp (X i) 2 μ := MemLp.of_bound (mx i).aestronglyMeasurable c
    (Filter.Eventually.of_forall fun ω => hc (Set.mem_range_self (D.record b ω i)))
  have avg (i) : (∫ ω, X i ω ∂μ) = pauliMean ρ p := by
    rw [show (∫ ω, X i ω ∂μ) = _ from law b i (singleEstimate p)]
    simp only [estimate_real, unbiased, pauliMean]
  have moment (i) : (∫ ω, X i ω ^ 2 ∂μ) = (3 : ℝ)^k := by
    rw [show (∫ ω, X i ω ^ 2 ∂μ) = _ from law b i (fun s => singleEstimate p s ^ 2)]
    simp only [Complex.ofReal_pow, estimate_real, secondMoment ρ hρ]
    norm_cast
  have vbound (i) : variance (X i) μ ≤ (3 : ℝ)^k := by
    rw [variance_eq_sub (lp i)]
    change (∫ ω, X i ω ^ 2 ∂μ) - _ ≤ _
    rw [moment]
    exact sub_le_self _ (sq_nonneg _)
  have indep : Pairwise fun i j => IndepFun (X i) (X j) μ :=
    fun _ _ hij => ((D.independentWithin b).indepFun hij).comp me me
  let total : Ω → ℝ := ∑ i, X i
  have vtotal : variance total μ ≤ N * (3 : ℝ)^k := by
    unfold total
    rw [IndepFun.variance_sum (fun i _ => lp i) (fun _ _ _ _ hij => indep hij)]
    simpa using Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => vbound i)
  have scaled : (fun ω => blockMean wire p (D.record b ω)) = fun ω => (N : ℝ)⁻¹ * total ω := by
    ext ω
    simp [total, blockMean, X, eval, Finset.sum_apply]
  have hNr : (0 : ℝ) < N := by exact_mod_cast hN
  have meanB : (∫ ω, (N : ℝ)⁻¹ * total ω ∂μ) = pauliMean ρ p := by
    simp only [integral_const_mul, total, Finset.sum_apply]
    rw [integral_finsetSum _ fun i _ => (lp i).integrable (by norm_num)]
    simp [avg, hNr.ne']
  have lpTotal : MemLp total 2 μ := by
    convert! memLp_finsetSum Finset.univ (fun i _ => lp i) using 1
    ext ω
    simp [total, Finset.sum_apply]
  have cheb := meas_ge_le_variance_div_sq ((lpTotal.const_mul (N : ℝ)⁻¹)) hε
  rw [meanB] at cheb
  have realCheb := ENNReal.toReal_mono ENNReal.ofReal_ne_top cheb
  rw [ENNReal.toReal_ofReal (div_nonneg (variance_nonneg _ _) (sq_nonneg _))] at realCheb
  change μ.real {ω | ε ≤ |(fun t => blockMean wire p (D.record b t)) ω - pauliMean ρ p|} ≤ _
  rw [scaled]
  refine realCheb.trans ?_
  rw [variance_const_mul]
  calc
    _ ≤ (N : ℝ)⁻¹ ^ 2 * (N * (3 : ℝ)^k) / ε^2 := by gcongr
    _ = _ := by field_simp

/-- A failed median supplies r+1 distinct failed block estimates. -/
private theorem median_witness {r : ℕ} (v : Fin (2*r+1) → ℝ) (m ε : ℝ)
    (bad : ε ≤ |median v - m|) :
    ∃ S : Finset (Fin (2*r+1)), S.card = r+1 ∧ ∀ i ∈ S, ε ≤ |v i - m| := by
  let mid : Fin (2*r+1) := ⟨r, by omega⟩
  have mk (map : Fin (r+1) ↪ Fin (2*r+1)) (allBad : ∀ i, ε ≤ |v (map i) - m|) :
      ∃ S : Finset (Fin (2*r+1)), S.card = r+1 ∧ ∀ i ∈ S, ε ≤ |v i - m| := by
    refine ⟨Finset.univ.map map, by simp, ?_⟩
    intro i hi
    obtain ⟨j, _, rfl⟩ := Finset.mem_map.mp hi
    exact allBad j
  rcases le_abs.mp bad with upper | lower
  · let above : Fin (r+1) ↪ Fin (2*r+1) :=
      ⟨fun i => ⟨r+i.val, by omega⟩, fun a b h => Fin.ext (by simpa using congrArg Fin.val h)⟩
    apply mk (above.trans (Tuple.sort v).toEmbedding)
    intro i
    have hi : mid ≤ above i := by change r ≤ r + i.val; omega
    have hv := Tuple.monotone_sort v hi
    change median v ≤ v ((Tuple.sort v) (above i)) at hv
    apply le_abs.mpr
    exact Or.inl (by change ε ≤ v ((Tuple.sort v) (above i)) - m; linarith)
  · let below : Fin (r+1) ↪ Fin (2*r+1) := Fin.castLEEmb (by omega)
    apply mk (below.trans (Tuple.sort v).toEmbedding)
    intro i
    have hi : below i ≤ mid := by change i.val ≤ r; omega
    have hv := Tuple.monotone_sort v hi
    change v ((Tuple.sort v) (below i)) ≤ median v at hv
    apply le_abs.mpr
    exact Or.inr (by change ε ≤ -(v ((Tuple.sort v) (below i)) - m); linarith)

/-- If a single block fails with probability at most 1/8, independence of
2r+1 blocks makes the failure probability of the median at most 1/(4·2ʳ). -/
private theorem median_failure {r : ℕ} {Y : Fin (2*r+1) → Ω → ℝ}
    (indep : iIndepFun Y μ) (m ε : ℝ)
    (block : ∀ b, μ.real {ω | ε ≤ |Y b ω - m|} ≤ 1/8) :
    μ.real {ω | ε ≤ |median (fun b => Y b ω) - m|} ≤ 1 / (4 * (2 : ℝ)^r) := by
  let fail : Set ℝ := {x | ε ≤ |x-m|}
  let bad := fun S : Finset (Fin (2*r+1)) => ⋂ b ∈ S, Y b ⁻¹' fail
  let choices := (Finset.univ : Finset (Fin (2*r+1))).powersetCard (r+1)
  have cover : {ω | ε ≤ |median (fun b => Y b ω) - m|} ⊆ ⋃ S ∈ choices, bad S := by
    intro ω hω
    obtain ⟨S,hc,hs⟩ := median_witness (fun b => Y b ω) m ε hω
    apply Set.mem_iUnion.mpr
    refine ⟨S, Set.mem_iUnion.mpr ⟨Finset.mem_powersetCard.mpr ⟨Finset.subset_univ _,hc⟩, ?_⟩⟩
    exact Set.mem_iInter₂.mpr hs
  have joint (S : Finset (Fin (2*r+1))) (hS : S ∈ choices) :
      μ.real (bad S) ≤ (1 / 8 : ℝ)^(r+1) := by
    have mfail : MeasurableSet fail := measurableSet_le measurable_const (continuous_abs.measurable.comp (measurable_id.sub_const m))
    have h := indep.measure_inter_preimage_eq_mul S (sets := fun _ => fail) (fun _ _ => mfail)
    change (μ (⋂ b ∈ S, Y b ⁻¹' fail)).toReal ≤ _
    rw [h, ENNReal.toReal_prod]
    calc
      _ ≤ ∏ _b ∈ S, (1/8 : ℝ) :=
        Finset.prod_le_prod₀ (fun _ _ => ENNReal.toReal_nonneg) (fun b _ => block b)
      _ = _ := by simp [(Finset.mem_powersetCard.mp hS).2]
  have card : choices.card ≤ 2^(2*r+1) := by
    calc
      choices.card ≤ (Finset.univ : Finset (Fin (2*r+1))).powerset.card :=
        Finset.card_le_card fun _ h => Finset.mem_powerset.mpr (Finset.mem_powersetCard.mp h).1
      _ = _ := by simp
  calc
    _ ≤ μ.real (⋃ S ∈ choices, bad S) := measureReal_mono cover (measure_ne_top μ _)
    _ ≤ ∑ S ∈ choices, μ.real (bad S) := measureReal_biUnion_finset_le _ _
    _ ≤ ∑ _S ∈ choices, (1/8 : ℝ)^(r+1) := Finset.sum_le_sum joint
    _ ≤ (2 : ℝ)^(2*r+1) * (1/8 : ℝ)^(r+1) := by
      simp only [Finset.sum_const, nsmul_eq_mul]
      gcongr
      exact_mod_cast card
    _ = _ := by
      rw [pow_succ, pow_mul, pow_succ, one_div, inv_pow]
      field_simp
      rw [show (8 : ℝ) = 2 * 4 by norm_num, mul_pow]
      ring

/-- Uniform finite-shot accuracy for a list of Pauli targets with possibly
different supports. With Nε² ≥ 8·3^weight for every target, use 2r+1
independent blocks of N shadows each. The same records serve all targets and
the probability that any median misses by at least ε is at most M/(4·2ʳ).
This gives logarithmic block count in M/δ for failure probability δ. -/
theorem simultaneousPrediction {T : Type*} [Fintype T] {r : ℕ}
    (D : ShadowBlocks μ n N (2*r+1)) (width : T → ℕ)
    (wire : ∀ t, Fin (width t) ↪ Fin n)
    (ρ : ∀ t, Matrix (Spin (width t)) (Spin (width t)) ℂ)
    (traceOne : ∀ t, (ρ t).trace = 1) (law : ∀ t, HasBornLaw D (wire t) (ρ t))
    (p : ∀ t, Setting (width t)) (hN : 0 < N) {ε : ℝ} (hε : 0 < ε)
    (shots : ∀ t, 8 * (3 : ℝ)^(width t) ≤ N * ε^2) :
    μ.real {ω | ∃ t, ε ≤ |median (fun b => blockMean (wire t) (p t) (D.record b ω)) -
      pauliMean (ρ t) (p t)|} ≤ Fintype.card T / (4 * (2 : ℝ)^r) := by
  let bad := fun t : T => {ω | ε ≤ |median (fun b => blockMean (wire t) (p t) (D.record b ω)) -
    pauliMean (ρ t) (p t)|}
  have one (t : T) : μ.real (bad t) ≤ 1 / (4 * (2 : ℝ)^r) := by
    apply median_failure (D.independentBlocks.comp (fun _ => blockMean (wire t) (p t))
      (fun _ => Measurable.of_discrete))
    intro b
    refine (blockPrediction D (wire t) (ρ t) (traceOne t) (law t) (p t) b hN hε).trans ?_
    apply (div_le_iff₀ (by positivity : (0 : ℝ) < N * ε^2)).mpr
    linarith [shots t]
  calc
    _ = μ.real (⋃ t, bad t) := by congr 1; ext; simp [bad]
    _ ≤ ∑ t, μ.real (bad t) := measureReal_iUnion_fintype_le _
    _ ≤ ∑ _t : T, 1 / (4 * (2 : ℝ)^r) := Finset.sum_le_sum fun t _ => one t
    _ = _ := by simp [div_eq_mul_inv]

/-- Use 2r+1 blocks, where r is the ceiling binary logarithm of the rounded
ratio M/(4δ). A single block is sufficient when this ratio is at most one. -/
def confidenceIndex (M : ℕ) (δ : ℝ) := Nat.clog 2 ⌈(M : ℝ)/(4*δ)⌉₊

/-- Explicit logarithmic choice of block count for the requested failure
probability δ. All targets use the same N·(2·confidenceIndex M δ+1) shots. -/
theorem predictionAtConfidence {T : Type*} [Fintype T] {δ ε : ℝ} (hδ : 0 < δ) (hε : 0 < ε)
    (D : ShadowBlocks μ n N (2 * confidenceIndex (Fintype.card T) δ + 1))
    (width : T → ℕ) (wire : ∀ t, Fin (width t) ↪ Fin n)
    (ρ : ∀ t, Matrix (Spin (width t)) (Spin (width t)) ℂ)
    (traceOne : ∀ t, (ρ t).trace = 1) (law : ∀ t, HasBornLaw D (wire t) (ρ t))
    (p : ∀ t, Setting (width t)) (hN : 0 < N)
    (shots : ∀ t, 8 * (3 : ℝ)^(width t) ≤ N * ε^2) :
    μ.real {ω | ∃ t, ε ≤ |median (fun b => blockMean (wire t) (p t) (D.record b ω)) -
      pauliMean (ρ t) (p t)|} ≤ δ := by
  apply (simultaneousPrediction D width wire ρ traceOne law p hN hε shots).trans
  let M : ℝ := Fintype.card T
  let r := confidenceIndex (Fintype.card T) δ
  have bound : M/(4*δ) ≤ (2 : ℝ)^r := calc
    _ ≤ (⌈M/(4*δ)⌉₊ : ℝ) := Nat.le_ceil _
    _ ≤ _ := by exact_mod_cast Nat.le_pow_clog (by decide : 1 < 2) ⌈M/(4*δ)⌉₊
  apply (div_le_iff₀ (by positivity : 0 < 4 * (2 : ℝ)^r)).mpr
  have := (div_le_iff₀ (by positivity : 0 < 4*δ)).mp bound
  change M ≤ δ * (4 * (2 : ℝ)^r)
  linarith

end FQChem.Properties.ClassicalShadows
