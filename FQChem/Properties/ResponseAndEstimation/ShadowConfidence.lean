module

public import Mathlib.Probability.Moments.Variance
public import Mathlib.Data.Fin.Tuple.Sort
public import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Tactic

/-! # Finite-sample confidence for classical-shadow prediction

Huang, Kueng and Preskill, Supplementary Theorem 1, Eq. (S13).
The same independent records serve every real-valued observable. The median can use
an even or an odd number of blocks.
[Original paper](https://doi.org/10.1038/s41567-020-0932-7)
-/

@[expose] public section
noncomputable section

namespace FQChem.Properties.ShadowConfidence

open MeasureTheory ProbabilityTheory
open scoped Classical

variable {Ω S T : Type*} [MeasurableSpace Ω] [MeasurableSpace S]
variable {μ : Measure Ω} [IsProbabilityMeasure μ] {N K : ℕ}

/-- The draws can take values in any measurable space, including a continuous set of bases. -/
structure Blocks (μ : Measure Ω) (S : Type*) [MeasurableSpace S] (N K : ℕ) where
  record : Fin K → Ω → Fin N → S
  measurable : ∀ b, Measurable (record b)
  independentWithin : ∀ b, iIndepFun (fun i ω => record b ω i) μ
  independentBlocks : iIndepFun record μ

/-- Product law of K batches of N independent observations. -/
abbrev productLaw (ν : Measure S) (N K : ℕ) : Measure (Fin K → Fin N → S) :=
  Measure.pi fun _ : Fin K => Measure.pi fun _ : Fin N => ν

theorem productDraw (ν : Measure S) [IsProbabilityMeasure ν] (b : Fin K) (i : Fin N) :
    MeasurePreserving (fun ω : Fin K → Fin N → S => ω b i) (productLaw ν N K) ν :=
  (measurePreserving_eval (fun _ : Fin N => ν) i).comp
    (measurePreserving_eval (fun _ : Fin K => Measure.pi fun _ : Fin N => ν) b)

/-- The coordinate observations on the product law satisfy both levels of independence. -/
def iidBlocks (ν : Measure S) [IsProbabilityMeasure ν] (N K : ℕ) :
    Blocks (productLaw ν N K) S N K where
  record b ω := ω b
  measurable b := measurable_pi_apply b
  independentBlocks := iIndepFun_pi (X := fun _ => id) (fun _ => aemeasurable_id)
  independentWithin b := by
    rw [iIndepFun_iff_map_fun_eq_pi_map (fun i => (productDraw ν b i).aemeasurable)]
    change (productLaw ν N K).map (Function.eval b) = _
    rw [(measurePreserving_eval _ b).map_eq]
    congr 1
    funext i
    exact (productDraw ν b i).map_eq.symm

def blocks (M : ℕ) (δ : ℝ) := ⌈2 * Real.log (2 * (M : ℝ) / δ)⌉₊

/-- At least one shot is used even for an observable with zero centered shadow norm. -/
def shots (V ε : ℝ) := max 1 ⌈34 * V / ε^2⌉₊

def blockMean (f : S → ℝ) (v : Fin N → S) : ℝ := (N : ℝ)⁻¹ * ∑ i, f (v i)

def median (hK : 0 < K) (v : Fin K → ℝ) : ℝ :=
  v (Tuple.sort v ⟨K / 2, by omega⟩)

private theorem blockFailure (D : Blocks μ S N K) (f : S → ℝ) (mf : Measurable f)
    (b : Fin K) (m V ε : ℝ) (hN : 0 < N) (hε : 0 < ε)
    (lp : ∀ i, MemLp (fun ω => f (D.record b ω i)) 2 μ)
    (avg : ∀ i, (∫ ω, f (D.record b ω i) ∂μ) = m)
    (var : ∀ i, variance (fun ω => f (D.record b ω i)) μ ≤ V)
    (budget : 34 * V ≤ (N : ℝ) * ε^2) :
    μ.real {ω | ε ≤ |blockMean f (D.record b ω) - m|} ≤ 1/34 := by
  let X := fun i : Fin N => fun ω => f (D.record b ω i)
  let total : Ω → ℝ := ∑ i, X i
  have vtotal : variance total μ ≤ N * V := by
    unfold total
    rw [IndepFun.variance_sum (fun i _ => lp i)
      (fun i _ j _ hij => ((D.independentWithin b).indepFun hij).comp mf mf)]
    simpa [X] using Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => var i)
  have hNr : (0 : ℝ) < N := by exact_mod_cast hN
  have meanB : (∫ ω, (N : ℝ)⁻¹ * total ω ∂μ) = m := by
    simp only [integral_const_mul, total, Finset.sum_apply]
    rw [integral_finsetSum _ fun i _ => (lp i).integrable (by norm_num)]
    simp [avg, hNr.ne']
  have lpTotal : MemLp total 2 μ := by
    convert! memLp_finsetSum Finset.univ (fun i _ => lp i) using 1
    ext ω
    simp [total, X, Finset.sum_apply]
  have cheb := meas_ge_le_variance_div_sq (lpTotal.const_mul (N : ℝ)⁻¹) hε
  rw [meanB] at cheb
  have realCheb := ENNReal.toReal_mono ENNReal.ofReal_ne_top cheb
  rw [ENNReal.toReal_ofReal (div_nonneg (variance_nonneg _ _) (sq_nonneg _))] at realCheb
  have eqB (ω) : blockMean f (D.record b ω) = (N : ℝ)⁻¹ * total ω := by
    simp [blockMean, total, X, Finset.sum_apply]
  simp_rw [eqB]
  refine realCheb.trans ?_
  rw [variance_const_mul]
  calc
    _ ≤ (N : ℝ)⁻¹ ^ 2 * (N * V) / ε^2 := by gcongr
    _ = V / ((N : ℝ) * ε^2) := by field_simp
    _ ≤ 1/34 := by apply (div_le_div_iff₀ (by positivity) (by norm_num)).mpr; linarith

/-- An upper median outside the accuracy interval requires at least ⌈K/2⌉ bad blocks. -/
private theorem medianWitness (hK : 0 < K) (v : Fin K → ℝ) (m ε : ℝ)
    (bad : ε ≤ |median hK v - m|) :
    ∃ J : Finset (Fin K), J.card = K - K/2 ∧ ∀ i ∈ J, ε ≤ |v i - m| := by
  let mid : Fin K := ⟨K/2, by omega⟩
  have mk (map : Fin (K-K/2) ↪ Fin K) (h : ∀ i, ε ≤ |v (map i) - m|) :
      ∃ J : Finset (Fin K), J.card = K-K/2 ∧ ∀ i ∈ J, ε ≤ |v i - m| := by
    refine ⟨Finset.univ.map map, by simp, ?_⟩
    intro i hi
    obtain ⟨j, _, rfl⟩ := Finset.mem_map.mp hi
    exact h j
  rcases le_abs.mp bad with upper | lower
  · let above : Fin (K-K/2) ↪ Fin K :=
      ⟨fun i => ⟨K/2+i.val, by omega⟩, fun a b h => Fin.ext (by simpa using congrArg Fin.val h)⟩
    apply mk (above.trans (Tuple.sort v).toEmbedding)
    intro i
    have hi : mid ≤ above i := by change K/2 ≤ K/2 + i.val; omega
    have hv := Tuple.monotone_sort v hi
    change median hK v ≤ v ((Tuple.sort v) (above i)) at hv
    exact le_abs.mpr (Or.inl (by change ε ≤ v ((Tuple.sort v) (above i)) - m; linarith))
  · let below : Fin (K-K/2) ↪ Fin K := Fin.castLEEmb (by omega)
    apply mk (below.trans (Tuple.sort v).toEmbedding)
    intro i
    have hi : below i ≤ mid := by change i.val ≤ K/2; omega
    have hv := Tuple.monotone_sort v hi
    change v ((Tuple.sort v) (below i)) ≤ median hK v at hv
    exact le_abs.mpr (Or.inr (by change ε ≤ -(v ((Tuple.sort v) (below i)) - m); linarith))

private theorem medianFailure {Y : Fin K → Ω → ℝ} (hK : 0 < K)
    (indep : iIndepFun Y μ) (m ε : ℝ)
    (block : ∀ b, μ.real {ω | ε ≤ |Y b ω - m|} ≤ 1/34) :
    μ.real {ω | ε ≤ |median hK (fun b => Y b ω) - m|} ≤ 1 / (2 : ℝ)^K := by
  let q := K-K/2
  let fail : Set ℝ := {x | ε ≤ |x-m|}
  let bad := fun J : Finset (Fin K) => ⋂ b ∈ J, Y b ⁻¹' fail
  let choices := (Finset.univ : Finset (Fin K)).powersetCard q
  have cover : {ω | ε ≤ |median hK (fun b => Y b ω) - m|} ⊆ ⋃ J ∈ choices, bad J := by
    intro ω hω
    obtain ⟨J,hc,hs⟩ := medianWitness hK (fun b => Y b ω) m ε hω
    exact Set.mem_iUnion.mpr ⟨J, Set.mem_iUnion.mpr
      ⟨Finset.mem_powersetCard.mpr ⟨Finset.subset_univ _,hc⟩, Set.mem_iInter₂.mpr hs⟩⟩
  have joint (J : Finset (Fin K)) (hJ : J ∈ choices) : μ.real (bad J) ≤ (1 / 34 : ℝ)^q := by
    have mfail : MeasurableSet fail := measurableSet_le measurable_const
      (continuous_abs.measurable.comp (measurable_id.sub_const m))
    have h := indep.measure_inter_preimage_eq_mul J (sets := fun _ => fail) (fun _ _ => mfail)
    change (μ (⋂ b ∈ J, Y b ⁻¹' fail)).toReal ≤ _
    rw [h, ENNReal.toReal_prod]
    calc
      _ ≤ ∏ _b ∈ J, (1/34 : ℝ) :=
        Finset.prod_le_prod₀ (fun _ _ => ENNReal.toReal_nonneg) (fun b _ => block b)
      _ = _ := by rw [Finset.prod_const, (Finset.mem_powersetCard.mp hJ).2]
  have count : (choices.card : ℝ) ≤ 2^K := by
    exact_mod_cast (Finset.card_le_card (fun _ h => Finset.mem_powerset.mpr (Finset.mem_powersetCard.mp h).1) : choices.card ≤ (Finset.univ : Finset (Fin K)).powerset.card).trans_eq
      (by simp : (Finset.univ : Finset (Fin K)).powerset.card = 2^K)
  have arith : (4 : ℝ)^K ≤ 34^q := calc
    _ ≤ 4^(2*q) := pow_le_pow_right₀ (by norm_num) (by dsimp [q]; omega)
    _ = (16 : ℝ)^q := by rw [pow_mul]; norm_num
    _ ≤ 34^q := by gcongr; norm_num
  calc
    _ ≤ μ.real (⋃ J ∈ choices, bad J) := measureReal_mono cover (measure_ne_top μ _)
    _ ≤ ∑ J ∈ choices, μ.real (bad J) := measureReal_biUnion_finset_le _ _
    _ ≤ ∑ _J ∈ choices, (1/34 : ℝ)^q := Finset.sum_le_sum joint
    _ = choices.card * (1/34 : ℝ)^q := by simp
    _ ≤ (2 : ℝ)^K * (1/34)^q := by gcongr
    _ ≤ _ := by
      rw [div_pow, one_pow, mul_one_div, div_le_div_iff₀ (by positivity) (by positivity), one_mul,
        ← mul_pow]
      convert arith using 1; norm_num

theorem blocks_pos (M : ℕ) (hM : 0 < M) {δ : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1) :
    0 < blocks M δ := by
  have hr : 1 < 2 * (M : ℝ) / δ := (lt_div_iff₀ hδ).mpr (by
    have : (1 : ℝ) ≤ M := by exact_mod_cast hM
    linarith)
  exact Nat.ceil_pos.mpr (mul_pos (by norm_num) (Real.log_pos hr))

private theorem confidence (M : ℕ) (hM : 0 < M) {δ : ℝ} (hδ : 0 < δ) :
    (M : ℝ) / 2^(blocks M δ) ≤ δ := by
  let k := blocks M δ
  have hk : 2 * Real.log (2*M/δ) ≤ (k : ℝ) := Nat.le_ceil _
  have hhalf : (1/2 : ℝ) ≤ Real.log 2 := by linarith [Real.log_two_gt_d9]
  have hexp : 2*(M : ℝ)/δ ≤ 2^k := by
    conv_rhs => rw [← Real.exp_log (by norm_num : (0 : ℝ) < 2), ← Real.exp_nat_mul]
    rw [← Real.exp_log (by positivity : (0 : ℝ) < 2*(M : ℝ)/δ)]
    apply Real.exp_le_exp.mpr
    nlinarith [mul_nonneg (Nat.cast_nonneg (α := ℝ) k) (sub_nonneg.mpr hhalf)]
  apply (div_le_iff₀ (by positivity)).mpr
  have := (div_le_iff₀ hδ).mp hexp
  linarith [Nat.cast_nonneg (α := ℝ) M]

/-- Published Eq. (S13) applied to square-integrable single-shot scores on shared records.
The mean and variance inputs are the quantities calculated from the measurement channel. -/
theorem simultaneousConfidence [Fintype T] [Nonempty T]
    (f : T → S → ℝ) (mf : ∀ t, Measurable (f t)) (m : T → ℝ)
    (V ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ ≤ 1)
    (D : Blocks μ S (shots V ε) (blocks (Fintype.card T) δ))
    (lp : ∀ t b i, MemLp (fun ω => f t (D.record b ω i)) 2 μ)
    (avg : ∀ t b i, (∫ ω, f t (D.record b ω i) ∂μ) = m t)
    (var : ∀ t b i, variance (fun ω => f t (D.record b ω i)) μ ≤ V) :
    μ.real {ω | ∃ t, ε ≤ |median (blocks_pos _ Fintype.card_pos hδ hδ1)
        (fun b => blockMean (f t) (D.record b ω)) - m t|} ≤ δ := by
  have hN := show 0 < shots V ε by unfold shots; omega
  have hK := blocks_pos _ (Fintype.card_pos (α := T)) hδ hδ1
  have budget : 34 * V ≤ (shots V ε : ℝ) * ε^2 := by
    apply (div_le_iff₀ (sq_pos_of_pos hε)).mp
    exact (Nat.le_ceil _).trans (by exact_mod_cast le_max_right 1 _)
  let bad (t : T) := {ω | ε ≤ |median hK (fun b => blockMean (f t) (D.record b ω)) - m t|}
  have one (t : T) : μ.real (bad t) ≤ 1 / (2 : ℝ)^blocks (Fintype.card T) δ := by
    apply medianFailure hK (D.independentBlocks.comp (fun _ => blockMean (f t)) (fun _ => ?_)) (m t) ε
    · intro b
      exact blockFailure D (f t) (mf t) b (m t) V ε hN hε (lp t b) (avg t b) (var t b) budget
    · unfold blockMean
      fun_prop (disch := exact mf t)
  calc
    _ = μ.real (⋃ t, bad t) := by congr 1; ext; simp [bad]
    _ ≤ ∑ t, μ.real (bad t) := measureReal_iUnion_fintype_le _
    _ ≤ ∑ _t : T, 1 / (2 : ℝ)^blocks (Fintype.card T) δ := Finset.sum_le_sum (fun t _ => one t)
    _ = (Fintype.card T : ℝ) / 2^(blocks (Fintype.card T) δ) := by simp [div_eq_mul_inv]
    _ ≤ δ := confidence _ Fintype.card_pos hδ

end FQChem.Properties.ShadowConfidence
