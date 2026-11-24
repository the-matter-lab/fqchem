import FQChemForShor.CompiledSampling
import FQChem.Complexity.FactoringRecursion

/-! # The probability law of one physical factoring trial -/

namespace FQChem.Complexity.FactoringLaw

open Shor Shor.Model Shor.Model.QuantumLib OrderFinding QuantumFactoring CompiledSampling
open FactoringReduction MeasureTheory
open scoped ENNReal

local instance : MeasurableSpace (Option ℕ) := ⊤
local instance : DiscreteMeasurableSpace (Option ℕ) := ⟨fun _ => trivial⟩

noncomputable def measuredFactor (inst : ShorOrderFindingInstance)
    (o : Fin (ASize (program inst).output)) : Option ℕ :=
  extractFactor inst.N inst.a (OrderFindingDecoder.decode inst.N inst.a o.val (ASize (program inst).output)).order

/-- The output measure of the physical circuit after the executable gcd check. -/
noncomputable def unitLaw (inst : ShorOrderFindingInstance) : Measure (Option ℕ) :=
  (clockLaw inst).toMeasure.map (measuredFactor inst)

instance (inst : ShorOrderFindingInstance) : IsProbabilityMeasure (unitLaw inst) :=
  (Measure.isProbabilityMeasure_map_iff (measurable_of_countable _).aemeasurable).mpr inferInstance

theorem unitLaw_success (inst : ShorOrderFindingInstance) :
    (unitLaw inst).real {d | d.isSome} = factorProbability inst := by
  classical
  rw [measureReal_def,unitLaw,Measure.map_apply (measurable_of_countable _) MeasurableSet.of_discrete]
  rw [clockLaw,PMF.toMeasure_ofFintype_apply _ _ MeasurableSet.of_discrete,tsum_fintype]
  rw [← ENNReal.toReal_ofReal (show 0 ≤ factorProbability inst by
    unfold factorProbability; apply Finset.sum_nonneg; intro o _; split <;> simp [mass_pos])]
  congr 1
  unfold factorProbability
  rw [ENNReal.ofReal_sum_of_nonneg (by intro o _; split <;> simp [mass_pos])]
  refine Finset.sum_congr rfl fun o _ => ?_
  change _ = ENNReal.ofReal (if (measuredFactor inst o).isSome then mass inst o.val else 0)
  by_cases h : (measuredFactor inst o).isSome <;> simp [Set.indicator, h]
/-- A single ordinary positive base, before averaging the random word.
Nonunits produce a divisor deterministically. -/
noncomputable def baseLaw (N : ℕ) (hN : 1 < N) (x : Fin (N-1)) : Measure (Option ℕ) :=
  if hc : (x.val+1).Coprime N then
    unitLaw ⟨x.val+1,N,⟨by omega,by have := x.isLt; omega⟩,hc⟩
  else Measure.dirac (some ((x.val+1).gcd N))

private instance (N : ℕ) (hN : 1 < N) (x : Fin (N-1)) : IsProbabilityMeasure (baseLaw N hN x) := by
  unfold baseLaw; split <;> infer_instance

/-- Number of equally likely binary words in a single base draw. -/
def words (N : ℕ) := 2^((N-1).log2+1)

private theorem wordBounds (N : ℕ) (hN : 1 < N) : N-1 ≤ words N ∧ words N ≤ 2*(N-1) :=
  ⟨Nat.lt_log2_self.le, by
    unfold words
    rw [pow_succ, mul_comm]
    exact Nat.mul_le_mul_left _ (Nat.log2_self_le (by omega))⟩

/-- Grouping equal rejected words leaves one failure atom. Every positive
base has one preimage under `baseFromBits`. -/
noncomputable def drawLaw (N : ℕ) (hN : 1 < N) : Measure (Option ℕ) :=
  ((words N : ℝ≥0∞)⁻¹) • ((∑ x : Fin (N-1), baseLaw N hN x) +
    ((words N - (N-1) : ℕ) : ℝ≥0∞) • Measure.dirac none)

private instance (N : ℕ) (hN : 1 < N) : IsProbabilityMeasure (drawLaw N hN) := by
  constructor
  have h := (wordBounds N hN).1
  have hw : (words N : ℝ≥0∞) ≠ 0 := by exact_mod_cast (show words N ≠ 0 by unfold words; positivity)
  have eq : ((N-1:ℕ):ℝ≥0∞) + ((words N - (N-1):ℕ):ℝ≥0∞) = words N := by exact_mod_cast Nat.add_sub_of_le h
  have plain : (∑ x : Fin (N-1), baseLaw N hN x) Set.univ = ((N-1:ℕ):ℝ≥0∞) := by
    simp only [Measure.coe_finsetSum, Finset.sum_apply, measure_univ, Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_one]
  rw [drawLaw,Measure.smul_apply,Measure.add_apply,plain,Measure.smul_apply,measure_univ]
  simp only [smul_eq_mul,mul_one,eq]
  exact ENNReal.inv_mul_cancel hw (ENNReal.natCast_ne_top _)

private theorem unitLaw_certified (inst : ShorOrderFindingInstance) :
    (unitLaw inst).real {d | (FactoringRecursion.certify inst.N d).isSome} = factorProbability inst := by
  rw [← unitLaw_success, measureReal_def, measureReal_def, unitLaw,
    Measure.map_apply (measurable_of_countable _) MeasurableSet.of_discrete,
    Measure.map_apply (measurable_of_countable _) MeasurableSet.of_discrete]
  congr 2
  ext o
  change (FactoringRecursion.certify inst.N (measuredFactor inst o)).isSome = true ↔ _
  cases h : measuredFactor inst o with
  | none => simp [h,FactoringRecursion.certify]
  | some d =>
    have good := extractFactor_sound h
    simp [h, FactoringRecursion.certify,good]

private theorem input_ext {i j : ShorOrderFindingInstance} (ha : i.a = j.a) (hn : i.N = j.N) : i = j := by
  cases i; cases j; simp_all

private theorem baseLaw_certified (N : ℕ) (hN : 1 < N) (x : Fin (N-1)) :
    letI : Fact (1 < N) := ⟨hN⟩
    (baseLaw N hN x).real {d | (FactoringRecursion.certify N d).isSome} = positiveBaseTrial x := by
  let : Fact (1 < N) := ⟨hN⟩
  unfold baseLaw positiveBaseTrial
  split
  next hc =>
    let u := ZMod.unitOfCoprime (x.val+1) hc
    let inst : ShorOrderFindingInstance := ⟨_,N,⟨by omega,by have := x.isLt; omega⟩,hc⟩
    have hr : u.val.val = x.val+1 := ZMod.val_natCast_of_lt (by have := x.isLt;omega)
    have eq : inst = instanceOf u := input_ext hr.symm rfl
    exact (unitLaw_certified inst).trans (congrArg factorProbability eq)
  next hc =>
    have hv := extractFactor_nonunit (N := N) (a := x.val+1) (by omega) (by have := x.isLt;omega) hc 0
    have hcert := FactoringRecursion.certify_some (extractFactor_sound hv)
    rw [measureReal_def,Measure.dirac_apply_of_mem hcert]
    simp

theorem drawLaw_certified (N : ℕ) (hN : 1 < N) (ho : Odd N) :
    (1-1/(2:ℝ)^(N.primeFactors.card-1)) * (κ / (2*Real.log ((N.log2:ℝ)+1)) / 2) ≤
      (drawLaw N hN).real {d | (FactoringRecursion.certify N d).isSome} := by
  let : Fact (1 < N) := ⟨hN⟩
  let S : Set (Option ℕ) := {d | (FactoringRecursion.certify N d).isSome}
  have hn : (0:ℝ) < ((N-1:ℕ):ℝ) := by exact_mod_cast (show 0 < N-1 by omega)
  have hw : (0:ℝ) < (words N:ℝ) := by exact_mod_cast (show 0 < words N by unfold words; positivity)
  have bound : (words N:ℝ) ≤ 2*((N-1:ℕ):ℝ) := by exact_mod_cast (wordBounds N hN).2
  have hnmem : none ∉ S := by simp [S,FactoringRecursion.certify]
  have law : (drawLaw N hN).real S = (∑ x : Fin (N-1), positiveBaseTrial x) / words N := by
    rw [measureReal_def,drawLaw]
    simp only [Measure.smul_apply,Measure.add_apply,Measure.coe_finsetSum,Finset.sum_apply,
      Measure.dirac_apply' none MeasurableSet.of_discrete,Set.indicator_of_notMem hnmem,
      smul_eq_mul,mul_zero,add_zero,ENNReal.toReal_mul,ENNReal.toReal_inv,ENNReal.toReal_natCast]
    rw [ENNReal.toReal_sum (fun _ _ => measure_ne_top _ _)]
    simp_rw [← measureReal_def,show ∀ x, (baseLaw N hN x).real S = positiveBaseTrial x from baseLaw_certified N hN]
    ring
  change _ ≤ (drawLaw N hN).real S
  rw [law,le_div_iff₀ hw]
  have hp := (le_div_iff₀ hn).mp (positiveBaseFactorProbability (N:=N) ho)
  apply le_trans _ hp
  have hlog : 0 ≤ Real.log ((N.log2:ℝ)+1) := Real.log_nonneg (by linarith [Nat.cast_nonneg (α := ℝ) N.log2])
  have hk : 1 / (2:ℝ)^(N.primeFactors.card-1) ≤ 1 := (div_le_one (by positivity)).mpr (one_le_pow₀ (by norm_num))
  have hfac : 0 ≤ (1-1/(2:ℝ)^(N.primeFactors.card-1)) * (κ / (2*Real.log ((N.log2:ℝ)+1)) / 2) :=
    mul_nonneg (sub_nonneg.mpr hk) (by have := κ_pos; positivity)
  convert mul_le_mul_of_nonneg_left bound hfac using 1
  ring

/-- Attempt preprocessing first. Hard composite leaves are split by a single
ordinary fair-word quantum trial. Inputs below 2 produce no factor. -/
noncomputable def law (m : ℕ) : Measure (Option ℕ) :=
  if hm : 1 < m then
    match (preprocess m).1 with
    | some d => Measure.dirac (some d)
    | none => drawLaw m hm
  else Measure.dirac none

instance (m : ℕ) : IsProbabilityMeasure (law m) := by
  unfold law; split
  · split <;> infer_instance
  · infer_instance

/-- Every composite subproblem has a concrete verified probability of
yielding a proper divisor in one fair-word trial. -/
theorem compositeShot {m N : ℕ} (hm : 2 ≤ m) (hle : m ≤ N) (hc : ¬m.Prime) :
    1 / (FactoringRecursion.denominator N : ℝ) ≤
      (law m).real {d | (FactoringRecursion.certify m d).isSome} := by
  have hden : 1 ≤ (FactoringRecursion.denominator N : ℝ) := by
    change 1 ≤ ((128*(N.log2+1):ℕ):ℝ)
    exact_mod_cast (show 1 ≤ 128*(N.log2+1) by omega)
  unfold law
  rw [dite_eq_left (by omega : 1 < m)]
  cases hs : (preprocess m).1 with
  | some d =>
    have hcert := FactoringRecursion.certify_some (preprocess_sound hs)
    rw [measureReal_def,Measure.dirac_apply_of_mem hcert,ENNReal.toReal_one]
    exact (div_le_one (by linarith)).mpr hden
  | none =>
    obtain ⟨odd, hk⟩ := preprocess_miss hm hc hs
    apply le_trans _ (drawLaw_certified m hm odd)
    have hreg : m.log2 ≤ N.log2 := by simpa [Nat.log2_eq_log_two] using Nat.log_mono_right (b:=2) hle
    have hlog : 0 < m.log2 := by rw [Nat.log2_eq_log_two]; exact Nat.log_pos (by decide) hm
    have hLpos : 0 < Real.log ((m.log2:ℝ)+1) := Real.log_pos (by exact_mod_cast (show 1 < m.log2+1 by omega))
    have hL : Real.log ((m.log2:ℝ)+1) ≤ ((N.log2:ℝ)+1) := by
      have h := Real.log_le_sub_one_of_pos (show 0 < (m.log2:ℝ)+1 by positivity)
      have hw : (m.log2:ℝ) ≤ N.log2 := by exact_mod_cast hreg
      linarith
    have hp : (1:ℝ)/16 ≤ κ := by
      unfold κ
      apply one_div_le_one_div_of_le (by positivity)
      nlinarith [Real.pi_lt_four, Real.pi_pos, mul_nonneg (sub_nonneg.mpr Real.pi_lt_four.le) (show 0 ≤ 4 + Real.pi by positivity)]
    have rank : (2:ℝ) ≤ (2:ℝ)^(m.primeFactors.card-1) := by
      exact_mod_cast (show 2 ≤ (2:ℕ)^(m.primeFactors.card-1) from
        (show 2^1 ≤ (2:ℕ)^(m.primeFactors.card-1) from Nat.pow_le_pow_right (by decide) (by omega)))
    have good : (1:ℝ)/2 ≤ 1-1/(2:ℝ)^(m.primeFactors.card-1) := by
      have h := one_div_le_one_div_of_le (by norm_num : (0:ℝ)<2) rank
      linarith
    have shot : 1 / (16 * (2*((N.log2:ℝ)+1))) ≤ κ / (2*Real.log ((m.log2:ℝ)+1)) := by
      calc
        _ = ((1:ℝ)/16)/(2*((N.log2:ℝ)+1)) := by rw [div_div]
        _ ≤ _ := div_le_div₀ κ_pos.le hp (by positivity) (by linarith)
    have hh := mul_le_mul good (div_le_div_of_nonneg_right shot (by norm_num : (0:ℝ) ≤ 2))
      (by positivity) (by linarith)
    apply le_trans _ hh
    unfold FactoringRecursion.denominator
    push_cast
    have hpos : (N.log2:ℝ) + 1 ≠ 0 := by positivity
    apply le_of_eq
    field_simp
    ring

/-- The physical circuit, fair bits, executable decoder, gcd check and recursive
splitter produce a complete prime factorization with probability ≥2/3. On
every tape the product is exact and the number of trials is polynomial. -/
theorem primeFactorization (N : ℕ) (hN : 1 ≤ N) :
    (∀ tape : FactoringRecursion.Tape N,
      (FactoringRecursion.run N tape).factors.prod = N ∧
      (FactoringRecursion.run N tape).visits * FactoringRecursion.shots N ≤
        2*N.log2*(128*(N.log2+1)*(N.log2+3))) ∧
    (2/3 : ℝ) ≤ (FactoringRecursion.tapeLaw N law).real
      {tape | (FactoringRecursion.run N tape).factors.prod = N ∧
        ∀ d ∈ (FactoringRecursion.run N tape).factors, Nat.Prime d} :=
  FactoringRecursion.recursiveFactorization N hN law (fun _ hm hle hc => compositeShot hm hle hc)

end FQChem.Complexity.FactoringLaw
