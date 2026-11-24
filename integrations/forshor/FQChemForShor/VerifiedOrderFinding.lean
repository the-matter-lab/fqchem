import FQChemForShor.OrderFindingTrials
import FQChemForShor.CompiledSampling
import FQChem.Complexity.OrderFindingBitCost
import Mathlib.Analysis.Complex.ExponentialBounds

/-!
# Bounded-error modular order finding with a known-input repetition count

The ideal Fourier experiment has the paper's order-dependent success estimate.
The implementable repetition schedule uses only the modulus. Every physical
trial starts the same compiled program in its zero state, measures its clock,
and uses the bit-level decoder. A streaming minimum ignores zero estimates.
-/

namespace FQChem.Complexity.VerifiedOrderFinding
open Shor Shor.Model Shor.Reference Shor.Model.QuantumLib
open OrderFinding QuantumFactoring

/-- Number of independent preparations computed from the known modulus. -/
def trials (N : ℕ) := 64 * ((N.log2 + 1).log2 + 1)

private theorem trial_inverse (N : ℕ) (hN : 1 < N) :
    (2 : ℝ) / trials N ≤ κ / (2 * Real.log ((N.log2 : ℝ)+1)) := by
  let W := N.log2+1
  let B := W.log2+1
  have hW : 1 < W := by
    have := (Nat.le_log2 (by omega : N ≠ 0)).mpr (by omega : 2^1 ≤ N)
    dsimp [W]; omega
  have hL : 0 < Real.log (W : ℝ) := Real.log_pos (by exact_mod_cast hW)
  have hB : 0 < (B : ℝ) := by dsimp [B]; positivity
  have log_le : Real.log (W : ℝ) ≤ B := by
    have bound : W ≤ 2^B := Nat.lt_log2_self.le
    have logbound := Real.log_le_log (show 0 < (W : ℝ) by positivity) (show (W : ℝ) ≤ (2:ℝ)^B by exact_mod_cast bound)
    rw [Real.log_pow] at logbound
    have log2le : Real.log 2 ≤ 1 := by linarith [Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)]
    nlinarith [mul_nonneg hB.le (sub_nonneg.mpr log2le)]
  have k : (1:ℝ)/16 ≤ κ := by
    unfold κ
    apply one_div_le_one_div_of_le (by positivity)
    nlinarith [Real.pi_lt_four, Real.pi_pos, mul_nonneg (sub_nonneg.mpr Real.pi_lt_four.le) (by positivity : 0 ≤ 4+Real.pi)]
  have he : ((N.log2 : ℝ)+1) = W := by dsimp [W]; norm_cast
  rw [he]
  change 2 / ((64 * B : ℕ) : ℝ) ≤ _
  push_cast
  apply (div_le_div_iff₀ (by positivity) (by positivity)).mpr
  nlinarith [mul_nonneg (sub_nonneg.mpr k) hB.le]

/-- The complete allocation fixes the measured register's size. -/
theorem physicalClock (inst : ShorOrderFindingInstance) :
    ASize (program inst).output = 2 ^ (2*inst.N^2).log2 := by
  simp [ASize,program,referenceXActive,referenceXWidth]

/-- Outcome tuple for t fresh shots of the compiled circuit. -/
abbrev Outcomes (inst : ShorOrderFindingInstance) (t : ℕ) := Fin t → Fin (ASize (program inst).output)

private theorem oneShot (inst : ShorOrderFindingInstance) :
    let Q := ASize (program inst).output
    let r := ord inst.a inst.N inst.coprime
    (2 : ℝ) / trials inst.N ≤ ∑ o : Fin Q,
      if (OrderFindingDecoder.decode inst.N inst.a o.val Q).order = r then mass inst o.val else 0 := by
  have hN : 1 < inst.N := by have h := inst.range; omega
  apply ((trial_inverse _ hN).trans (programRecovery inst)).trans_eq
  let Q := ASize (program inst).output
  have hQ : 0 < Q := by dsimp [Q, ASize]; positivity
  unfold qlSuccess qlSuccessOn
  apply Finset.sum_congr rfl
  intro o _
  let r := ord inst.a inst.N inst.coprime
  change (if OF_post budget _ o.val Q = r then 1 else 0) * mass inst o.val = _
  rw [← executableDecoder inst Q o.val hQ]
  split <;> simp_all

/-- The postprocessed physical product law has error at most exp(−2), with
a stopping budget fixed entirely before any circuit measurement. -/
theorem compiledError (inst : ShorOrderFindingInstance) :
    let Q := ASize (program inst).output
    let r := ord inst.a inst.N inst.coprime
    let t := trials inst.N
    ∑ v : Outcomes inst t, (if OrderFindingTrials.selectOrder inst Q v = r then 0
      else ∏ i, mass inst (v i).val) ≤ Real.exp (-2) := by
  classical
  let Q := ASize (program inst).output
  let r := ord inst.a inst.N inst.coprime
  let t := trials inst.N
  let hit (o : Fin Q) := (OrderFindingDecoder.decode inst.N inst.a o.val Q).order = r
  let miss (o : Fin Q) := if hit o then 0 else mass inst o.val
  let win (o : Fin Q) := if hit o then mass inst o.val else 0
  have pos (o : Fin Q) : 0 ≤ miss o := by dsimp [miss]; split <;> simp [CompiledSampling.mass_pos]
  have sumone : (∑ o, win o) + ∑ o, miss o = 1 := by
    rw [← Finset.sum_add_distrib, ← CompiledSampling.normalized inst]
    apply Finset.sum_congr rfl
    intro o _
    dsimp [win,miss]
    split <;> simp_all
  have single : (2:ℝ) / t ≤ ∑ o, win o := oneShot inst
  have fail : ∑ o, miss o ≤ 1 - 2/(t:ℝ) := by linarith
  have ht : (2:ℝ) ≤ t := by dsimp [t,trials]; push_cast; linarith [Nat.cast_nonneg ((inst.N.log2+1).log2) (α := ℝ)]
  calc
    _ ≤ ∑ v : Fin t → Fin Q, ∏ i, miss (v i) := by
      apply Finset.sum_le_sum
      intro v _
      split
      next => exact Finset.prod_nonneg (fun i _ => pos _)
      next h =>
        have nohit (i : Fin t) : ¬hit (v i) := fun hh =>
          h (OrderFindingTrials.selected_if_hit inst v ⟨i,hh⟩)
        exact le_of_eq (Finset.prod_congr rfl fun i _ => (ite_eq_right (nohit i)).symm)
    _ = (∑ o, miss o)^t := (Fintype.sum_pow miss t).symm
    _ ≤ (1-2/(t:ℝ))^t := pow_le_pow_left₀ (Finset.sum_nonneg (fun o _ => pos o)) fail t
    _ ≤ Real.exp (-2) := Real.one_sub_div_pow_le_exp_neg (t := 2) ht

private theorem expNegTwo_lt_third : Real.exp (-2) < (1:ℝ)/3 := by
  rw [Real.exp_neg, inv_eq_one_div]
  apply one_div_lt_one_div_of_lt (by norm_num)
  rw [show (2:ℝ) = 1+1 by norm_num, Real.exp_add]
  nlinarith [Real.exp_one_gt_two, sq_nonneg (Real.exp 1 - 2)]

private theorem decoded_le_clock (N a o Q t : ℕ) (hQ : 0 < Q) :
    (OrderFindingDecoder.scan N a o Q t).order ≤ Q := by
  induction t with
  | zero => simp [OrderFindingDecoder.scan]
  | succ t ih =>
    have h := (OrderFindingDecoder.convergent_bounds o Q t hQ).2.1
    simp only [OrderFindingDecoder.scan]
    split
    next => split <;> omega
    next => exact ih

/-- Stream the measured outputs through the Boolean decoder and minimum
selector, counting the Boolean gates of both. -/
def readRecords (N a Q : ℕ) : (t : ℕ) → (Fin t → Fin Q) → ℕ × ℕ
  | 0, _ => (0,0)
  | t+1, v =>
    let w := (max N Q).log2+1
    let prev := readRecords N a Q t (fun i => v i.succ)
    let d := OrderFindingBitCost.decode N a (v 0).val Q
    let zero := OrderFindingBitCost.equalWord w d.1 0
    let next := OrderFindingBitCost.update w prev.1 d.1 (!zero.1).toNat
    (next.1,prev.2+d.2+zero.2+1+next.2)

private theorem select_cons {t Q : ℕ} (inst : ShorOrderFindingInstance) (v : Fin (t+1) → Fin Q) :
    let p := OrderFindingTrials.selectOrder inst Q (fun i : Fin t => v i.succ)
    let d := (OrderFindingDecoder.decode inst.N inst.a (v 0).val Q).order
    OrderFindingTrials.selectOrder inst Q v = if d=0 then p else if p=0 then d else min d p := by
  classical
  let f (i : Fin (t+1)) := (OrderFindingDecoder.decode inst.N inst.a (v i).val Q).order
  let S := (Finset.univ.image (fun i : Fin t => f i.succ)).filter (0 < ·)
  have form : (Finset.univ.image f) = insert (f 0) (Finset.univ.image fun i : Fin t => f i.succ) := by
    ext k
    simp only [Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_insert,
      Fin.exists_fin_succ, eq_comm]
  change OrderFindingDecoder.leastOrZero ((Finset.univ.image f).filter (0 < ·)) = _
  rw [form,Finset.filter_insert]
  change OrderFindingDecoder.leastOrZero (if 0 < f 0 then insert (f 0) S else S) =
    if f 0 = 0 then _ else _
  by_cases hz : f 0=0
  · simp [hz,S,f,OrderFindingTrials.selectOrder]
  · have hpos : 0 < f 0 := Nat.pos_of_ne_zero hz
    rw [ite_eq_left hpos,ite_eq_right hz,OrderFindingDecoder.least_insert _ _ (fun _ h => (Finset.mem_filter.mp h).2)]
    rfl

private theorem records_spec (inst : ShorOrderFindingInstance) (Q t : ℕ) (hQ : 0 < Q)
    (v : Fin t → Fin Q) :
    let w := (max inst.N Q).log2+1
    let out := readRecords inst.N inst.a Q t v
    out.1 = OrderFindingTrials.selectOrder inst Q v ∧ out.1 < 2^w ∧
      out.2 ≤ t*(1000*(w+1)^4+27*w+1) := by
  let w := (max inst.N Q).log2+1
  have hN : 1 < inst.N := by have := inst.range; omega
  have hwQ : Q < 2^w := (Nat.le_max_right ..).trans_lt Nat.lt_log2_self
  have hw1 : 1 < 2^w := hN.trans ((Nat.le_max_left ..).trans_lt Nat.lt_log2_self)
  induction t with
  | zero => simp [readRecords,OrderFindingTrials.selectOrder,OrderFindingDecoder.leastOrZero]
  | succ t ih =>
    let tail (i : Fin t) := v i.succ
    let p := OrderFindingTrials.selectOrder inst Q tail
    let d := (OrderFindingDecoder.decode inst.N inst.a (v 0).val Q).order
    have old := ih tail
    have hp : p < 2^w := by change OrderFindingTrials.selectOrder inst Q tail < _; rw [← old.1]; exact old.2.1
    have b := OrderFindingBitCost.decode_input_bound inst.N inst.a (v 0).val Q hN inst.range.2 (v 0).isLt
    have hd : d < 2^w := (decoded_le_clock inst.N inst.a (v 0).val Q _ hQ).trans_lt hwQ
    have z := OrderFindingBitCost.equal_spec w d 0 hd (Nat.two_pow_pos _)
    let test := (!(decide (d=0))).toNat
    have ht : test < 2^w := by by_cases h : d=0 <;> simp [test,h]
    have next := OrderFindingBitCost.update_spec w p d test hw1 hp hd ht
    have eqs := select_cons inst v
    change OrderFindingTrials.selectOrder inst Q v = (if d=0 then p else if p=0 then d else min d p) at eqs
    have bv : (OrderFindingBitCost.decode inst.N inst.a (v 0).val Q).1 = d := b.1
    have ov : (readRecords inst.N inst.a Q t tail).1 = p := old.1
    have step : readRecords inst.N inst.a Q (t+1) v =
        (if test=1 then if p=0 then d else min d p else p,
          (readRecords inst.N inst.a Q t tail).2 + (OrderFindingBitCost.decode inst.N inst.a (v 0).val Q).2
            + 3*w + 1 + 24*w) := by
      simp only [readRecords]
      change (let prev := readRecords inst.N inst.a Q t tail
              let d' := OrderFindingBitCost.decode inst.N inst.a (v 0).val Q
              let z' := OrderFindingBitCost.equalWord w d'.1 0
              let u := OrderFindingBitCost.update w prev.1 d'.1 (!z'.1).toNat
              (u.1, prev.2+d'.2+z'.2+1+u.2)) = _
      simp only [bv,ov,z]
      exact (congrArg (fun z : ℕ × ℕ => (z.1, (readRecords inst.N inst.a Q t tail).2 +
        (OrderFindingBitCost.decode inst.N inst.a (v 0).val Q).2 + 3*w+1+z.2)) next)
    change (readRecords inst.N inst.a Q (t+1) v).1 = _ ∧
      (readRecords inst.N inst.a Q (t+1) v).1 < 2^w ∧ (readRecords inst.N inst.a Q (t+1) v).2 ≤ _
    rw [step,eqs]
    have hg : (readRecords inst.N inst.a Q t tail).2 + (OrderFindingBitCost.decode inst.N inst.a (v 0).val Q).2
          + 3*w + 1 + 24*w ≤ (t+1)*(1000*(w+1)^4+27*w+1) := by
      have hb : (OrderFindingBitCost.decode inst.N inst.a (v 0).val Q).2 ≤ 1000*(w+1)^4 := b.2
      have ho : (readRecords inst.N inst.a Q t tail).2 ≤ t*(1000*(w+1)^4+27*w+1) := old.2.2
      rw [Nat.succ_mul t (1000*(w+1)^4+27*w+1)]; omega
    by_cases hz : d=0
    · simp [test,hz,hp]
      exact hg
    · have hbest : (if p=0 then d else min d p) < 2^w := by split <;> omega
      simp [test,hz,hbest]
      exact hg

/-- Failure mass of the executable bit-decoding and selection program over
independent compiled-circuit Born outcomes. -/
noncomputable def physicalFailure (inst : ShorOrderFindingInstance) : ℝ :=
  let Q := ASize (program inst).output
  let t := trials inst.N
  ∑ v : Outcomes inst t, if (readRecords inst.N inst.a Q t v).1 = ord inst.a inst.N inst.coprime
    then 0 else ∏ i, mass inst (v i).val

theorem physical_bounded_error (inst : ShorOrderFindingInstance) : physicalFailure inst < 1/3 := by
  classical
  apply lt_of_le_of_lt _ expNegTwo_lt_third
  apply le_trans _ (compiledError inst)
  unfold physicalFailure
  apply Finset.sum_le_sum
  intro v _
  have hQ : 0 < ASize (program inst).output := by unfold ASize; positivity
  rw [(records_spec inst _ _ hQ v).1]

theorem joint_born_mass (inst : ShorOrderFindingInstance) :
    ∑ v : Outcomes inst (trials inst.N), ∏ i, mass inst (v i).val = 1 := by
  rw [← Fintype.sum_pow (fun o : Fin (ASize (program inst).output) => mass inst o.val),
    CompiledSampling.normalized, one_pow]

/-- Polynomial total resources for the known-modulus schedule. Quantum
logical gates and classical Boolean work are counted for the same physical
circuit and its complete measurement data path. -/
theorem polynomialWork :
    ∃ C : ℝ, 0 < C ∧ ∃ n₀ : ℕ, ∀ inst : ShorOrderFindingInstance,
      let L := (2*inst.N).log2
      let P := program inst
      let t := trials inst.N
      n₀ ≤ L →
      (t : ℝ) * LowGate.gateCount shorGateCostModel P.circuit ≤ C * (L : ℝ)^4 ∧
        ∀ v : Outcomes inst t, (readRecords inst.N inst.a (ASize P.output) t v).2 ≤
          40000000 * L^5 := by
  obtain ⟨C,n₀,hC,gate⟩ := programGateCount
  refine ⟨128*C, by positivity,n₀,?_⟩
  intro inst
  dsimp only
  intro hn
  let N := inst.N
  let L := (2*N).log2
  let Q := ASize (program inst).output
  let W := (max N Q).log2+1
  have hN : 1 < N := by dsimp [N]; have := inst.range; omega
  have hL : L = N.log2+1 := Nat.log2_two_mul (by omega)
  have hL0 : 0 < L := by omega
  have trialBound : trials N ≤ 128*L := by
    unfold trials
    have := Nat.log2_le_self (N.log2+1)
    omega
  constructor
  · have hg := gate inst hn
    have ht : (trials N : ℝ) ≤ 128*(L:ℝ) := by exact_mod_cast trialBound
    change (trials N : ℝ) * _ ≤ 128*C*(L:ℝ)^4
    calc
      _ ≤ (128*(L:ℝ)) * (C*(L:ℝ)^3) :=
        mul_le_mul ht hg (by positivity) (by positivity)
      _ = _ := by ring
  · intro v
    have hQ0 : 0 < Q := by dsimp [Q,ASize]; positivity
    have hQ : Q ≤ 2*N^2 := by
      rw [show Q = 2^((2*N^2).log2) from physicalClock inst]
      exact Nat.log2_self_le (by positivity)
    have nbits : N < 2^L := by rw [hL]; exact Nat.lt_log2_self
    have qbits : Q < 2^(2*L+1) := by
      have := Nat.pow_lt_pow_left nbits (by decide : 2 ≠ 0)
      rw [pow_succ, pow_mul']
      nlinarith
    have nbits' : N < 2^(2*L+1) :=
      nbits.trans_le (Nat.pow_le_pow_right (by decide) (by omega))
    have hW : W ≤ 2*L+1 := by
      have hm := (Nat.log2_lt (by omega : max N Q ≠ 0)).mpr (max_lt nbits' qbits)
      dsimp [W]; omega
    have hp : 1000*(W+1)^4+27*W+1 ≤ 300000*L^4 := by
      calc
        _ ≤ 1000*(4*L)^4 + 27*(4*L) + 1 := by gcongr <;> omega
        _ ≤ _ := by nlinarith [Nat.le_self_pow (by decide : 4 ≠ 0) L]
    have hres := (records_spec inst Q (trials N) hQ0 v).2.2
    have hmul : (128*L)*(300000*L^4) ≤ 40000000*L^5 := calc
      _ = 38400000*L^5 := by ring
      _ ≤ _ := Nat.mul_le_mul_right _ (by decide)
    exact hres.trans ((Nat.mul_le_mul trialBound hp).trans hmul)

/-- Single-shot exact-order probability for the clock prescribed in §5. -/
noncomputable def idealOneShot (inst : ShorOrderFindingInstance) : ℝ :=
  let Q := FourierOrbit.paperClock inst.N
  let u := ZMod.unitOfCoprime inst.a ((Nat.coprime_iff_gcd_eq_one).mpr inst.coprime)
  ∑ o : Fin Q, if (OrderFindingDecoder.decode inst.N inst.a o.val Q).order =
    ord inst.a inst.N inst.coprime then FourierOrbit.clockBorn u Q o else 0

/-- The ideal experiment's error at the order-dependent repetition count
used to express its sample complexity. The compiled procedure uses `trials N`. -/
noncomputable def idealErrorAt (inst : ShorOrderFindingInstance) (t : ℕ) : ℝ :=
  let Q := FourierOrbit.paperClock inst.N
  let r := ord inst.a inst.N inst.coprime
  let u := ZMod.unitOfCoprime inst.a ((Nat.coprime_iff_gcd_eq_one).mpr inst.coprime)
  ∑ v : Fin t → Fin Q, if OrderFindingTrials.selectOrder inst Q v = r then 0
    else ∏ i, FourierOrbit.clockBorn u Q (v i)

/-- Shor §5 order finding. At the paper's power-of-two clock, ideal Fourier
sampling succeeds with probability at least (4/π²)φ(r)/r and needs
O(log log r) independent trials for constant error. The known-N algorithm
runs a specific compiled circuit on independent zero states and returns the
true order with probability greater than 2/3. Its output law is normalized;
all repetitions together cost O(L⁴) logical gates and O(L⁵) data-path bit
operations for decoding and aggregation, where L is the modulus bit length. -/
theorem shorOrderFinding :
    ∃ C : ℝ, 0 < C ∧ ∃ n₀ : ℕ, ∀ inst : ShorOrderFindingInstance,
      let r := ord inst.a inst.N inst.coprime
      let L := (2*inst.N).log2
      let P := program inst
      let t := trials inst.N
      4 / Real.pi^2 * ((Nat.totient r : ℝ)/r) ≤ idealOneShot inst ∧
      idealErrorAt inst ⌈12 * Real.log ((Nat.log2 (r+1) : ℝ)+1)⌉₊ ≤ Real.exp (-1) ∧
      (∑ v : Outcomes inst t, ∏ i, mass inst (v i).val) = 1 ∧
      physicalFailure inst < 1/3 ∧
      (n₀ ≤ L → (t : ℝ) * LowGate.gateCount shorGateCostModel P.circuit ≤ C*(L:ℝ)^4 ∧
        ∀ v : Outcomes inst t, (readRecords inst.N inst.a (ASize P.output) t v).2 ≤
          40000000 * L^5) := by
  obtain ⟨C,hC,n₀,resource⟩ := polynomialWork
  exact ⟨C,hC,n₀,fun inst => ⟨FourierOrbit.publishedClockRecovery inst,
    OrderFindingTrials.boundedErrorOrderFinding inst, joint_born_mass inst,
    physical_bounded_error inst,resource inst⟩⟩

end FQChem.Complexity.VerifiedOrderFinding
