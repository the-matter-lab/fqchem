import FQChem.Complexity.OrderFindingDecoder
import FQChem.Complexity.OrderFindingPostprocessing
import ForShor.ShorVerification.Model.QuantumLib.Headline
import ForShor.ShorVerification.Submission.Template
import Mathlib.Analysis.Real.Pi.Bounds

/-! # Fourier sampling and continued-fraction decoding

A bounded continued-fraction decoder recovers the order from Shor's ideal
order-finding experiment. The compiled circuit has a separate Born-probability
certificate in ForShor's finite matrix semantics.
-/

namespace FQChem.Complexity.OrderFinding

open Shor Shor.Model

/-- Number of convergents inspected for a clock of size `Q`. -/
def budget (Q : ℕ) : ℕ := 2 * (Q.log2 + 1) + 1

/-- Every rational clock outcome terminates inside the decoder's scan. -/
theorem complete : ContinuedFractionSearchComplete budget :=
  OrderFindingPostprocessing.logarithmic_scan

/-- On every valid measurement the executable natural-arithmetic decoder
returns the candidate selected by ForShor’s specification. -/
theorem executableDecoder (inst : ShorOrderFindingInstance) (Q o : ℕ) (hQ : 0 < Q) :
    (OrderFindingDecoder.decode inst.N inst.a o Q).order =
      OF_post budget (fun d => decide (inst.a^d % inst.N = 1)) o Q :=
  OrderFindingDecoder.scan_eq_reference inst.N inst.a o Q (budget Q) hQ

/-- Single-run Born probability of returning the exact order on an ideal
circuit. The register widths and the initial basis state satisfy the physical
preparation conditions of the reference implementation. -/
theorem fourierRecovery (inst : ShorOrderFindingInstance) (x y : ExtReg) (b₀ : qs.Basis)
    (widths : BasicSetting inst.a (ord inst.a inst.N inst.coprime) inst.N
      (regSize x.active) (regSize y.active))
    (init : IdealOrderFindingInput qs x y b₀) :
    let r := ord inst.a inst.N inst.coprime
    (4 / Real.pi ^ 2) * ((Nat.totient r : ℝ) / r) ≤
      probability_of_success (qs := qs) qs.eval budget (fun d => decide (inst.a^d % inst.N = 1))
        x.active r (ASize x.active) (orderFindingIdeal (qs := qs) inst.a inst.N x y) (qs.ket b₀) := by
  let r := ord inst.a inst.N inst.coprime
  let Q := ASize x.active
  let C := orderFindingIdeal (qs := qs) inst.a inst.N x y
  let prob (o : Fin Q) := MeasureClass.probMeas (qs := qs) x.active o.val (qs.eval C (qs.ket b₀))
  have bounds := shor_order_parameter_bounds widths
  have card := goodOutcome_card_ge_totient bounds.1 bounds.2.2
  have point (o : Fin Q) (hg : GoodOutcome o.val Q r) :
      4 / Real.pi ^ 2 * (1 / (r : ℝ)) ≤ prob o := by
    have formula := measProbAfter_orderFindingIdeal_eq_paper_formula inst x y b₀ widths init
      (eval_orderFindingIdeal_prefix inst x y b₀ widths init) o
    exact (shor_paper_goodOutcome_lower_bound hg).trans_eq formula.symm
  exact (goodOutcome_mass_lower_bound_from_card_and_pointwise Q r prob bounds.1 card point).trans
    (goodOutcome_mass_le_probability_of_success budget complete inst qs.eval x.active Q C (qs.ket b₀))

/-- Shor's published single-run lower bound on the ideal circuit. -/
theorem oneRun (inst : ShorOrderFindingInstance) (x y : ExtReg) (b₀ : qs.Basis)
    (widths : BasicSetting inst.a (ord inst.a inst.N inst.coprime) inst.N
      (regSize x.active) (regSize y.active))
    (init : IdealOrderFindingInput qs x y b₀) :
    let r := ord inst.a inst.N inst.coprime
    (Nat.totient r : ℝ) / (3*r) ≤
      probability_of_success (qs := qs) qs.eval budget (fun d => decide (inst.a^d % inst.N = 1))
        x.active r (ASize x.active) (orderFindingIdeal (qs := qs) inst.a inst.N x y) (qs.ket b₀) := by
  apply le_trans _ (fourierRecovery inst x y b₀ widths init)
  let r := ord inst.a inst.N inst.coprime
  change (Nat.totient r : ℝ) / (3*r) ≤ _
  have scale : (1:ℝ)/3 ≤ 4/Real.pi^2 := by
    apply (le_div_iff₀ (by positivity)).mpr
    nlinarith [Real.pi_lt_d2, Real.pi_pos,
      mul_pos (sub_pos.mpr Real.pi_lt_d2) (show 0 < 3.15 + Real.pi by positivity)]
  calc
    _ = (1/3:ℝ) * ((Nat.totient r : ℝ)/r) := by ring
    _ ≤ _ := mul_le_mul_of_nonneg_right scale (by positivity)

/-- A conservative per-run certificate appeared in Section 5 of Shor (1997).
With independent trials its failure bound falls below 1/e after at most
the ceiling of twelve times the natural logarithm of the bit width of r+1. -/
theorem independentTrialBound (r : ℕ) (hr : 0 < r) :
    let L := Real.log ((Nat.log2 (r+1) : ℝ) + 1)
    (1 - (Nat.totient r : ℝ) / (3*r)) ^ ⌈12*L⌉₊ ≤ Real.exp (-1) := by
  dsimp only
  let L := Real.log ((Nat.log2 (r+1) : ℝ) + 1)
  have hw : 0 < (r+1).log2 := (Nat.le_log2 (by omega : r+1 ≠ 0)).2 (by simpa using (show 2 ≤ r+1 by omega))
  have hL : 0 < L := Real.log_pos (by exact_mod_cast (by omega : 1 < (r+1).log2+1))
  have hphi := shor_totient_ratio (N := r+1) hr (Nat.lt_succ_self _)
  change 1 / (4 * L) ≤ _ at hphi
  let t := ⌈12*L⌉₊
  have ht : 12*L ≤ (t : ℝ) := Nat.le_ceil _
  have htpos : 0 < (t : ℝ) := by linarith
  have step : 1 / (t : ℝ) ≤ (Nat.totient r : ℝ) / (3*r) := by
    calc
      1 / (t : ℝ) ≤ 1 / (12*L) := one_div_le_one_div_of_le (by positivity) ht
      _ = (1 / (4*L)) / 3 := by ring
      _ ≤ ((Nat.totient r : ℝ) / r) / 3 := by gcongr
      _ = _ := by ring
  have hc : (Nat.totient r : ℝ) ≤ (r : ℝ) := by exact_mod_cast Nat.totient_le r
  have hnonneg : 0 ≤ 1 - (Nat.totient r : ℝ)/(3*r) := by
    apply sub_nonneg.mpr
    apply (div_le_iff₀ (by positivity)).mpr
    linarith
  have htNat : 0 < t := by exact_mod_cast htpos
  have htOne : (1 : ℝ) ≤ t := by exact_mod_cast htNat
  exact (pow_le_pow_left₀ hnonneg (sub_le_sub_left step 1) t).trans
    (Real.one_sub_div_pow_le_exp_neg (t := 1) htOne)

open Shor.Model.QuantumLib Shor.Reference

/-- The concrete two-limb reference circuit chooses its precision for the input
modulus. In finite matrix semantics on its all-zero input, the probability of
decoding the exact order meets a strictly positive certificate. -/
theorem compiledRecovery (inst : ShorOrderFindingInstance) :
    let P := ShorLoweringPolicy.constPolicy Submission.setup.table
    let prog := referenceSubmittedProgram P
      (ShorLoweringPolicy.constPolicy_admissible Submission.setup.table_admissible) inst
    0 < referenceSuccessProbability inst.N ∧ referenceSuccessProbability inst.N ≤
      qlSuccess (maxQubit prog.circuit) prog.circuit prog.output budget
        (fun d => decide (inst.a^d % inst.N = 1)) (ord inst.a inst.N inst.coprime)
        (ASize prog.output) := by
  have h := (referenceSubmittedProgram_correct (qs := qs) _
    (ShorLoweringPolicy.constPolicy_admissible Submission.setup.table_admissible) budget complete inst).2.2
  refine ⟨referenceSuccessProbability_pos _, ?_⟩
  exact h.trans_eq (probability_of_success_eq _ le_rfl _ _ _ _ _)

/-- An integer precision schedule for the two-limb reference compiler. -/
def precisionLevel (n : ℕ) := 2^26 * n^4

private theorem referencePrecision_le (inst : ShorOrderFindingInstance) (x y : ExtReg)
    (hx : regSize x.active = Nat.log2 (2*inst.N^2))
    (hy : regSize y.active = Nat.log2 (2*inst.N)) :
    referencePrecision (precisionLevel (regSize y.active)) ≤ shorPrecision inst.N x.active := by
  have hN : 1 < inst.N := by have := inst.range; omega
  have hxpos : 0 < regSize x.active := by rw [hx, Nat.log2_eq_log_two]; exact Nat.log_pos (by decide) (by nlinarith)
  have hlog : 0 < Nat.log2 inst.N := by rw [Nat.log2_eq_log_two]; exact Nat.log_pos (by decide) hN
  have hL : 0 < Real.log ((Nat.log2 inst.N : ℝ)+1) := Real.log_pos (by exact_mod_cast (show 1 < Nat.log2 inst.N + 1 by omega))
  have hp : 0 < shorPrecision inst.N x.active := by unfold shorPrecision; have := κ_pos; positivity
  have hi := shorPrecision_inv_le inst.N x y hN hx hy
  have coeff : (204800 : ℝ) / κ^2 ≤ 2^26 := by
    unfold κ
    have h := pow_le_pow_left₀ Real.pi_pos.le Real.pi_lt_four.le 4
    field_simp
    nlinarith
  have hbound : 1 / shorPrecision inst.N x.active ≤ (precisionLevel (regSize y.active) : ℝ) := by
    push_cast [precisionLevel]
    calc
      _ = 2 * (1 / (2 * shorPrecision inst.N x.active)) := by field_simp
      _ ≤ 2 * _ := mul_le_mul_of_nonneg_left hi (by norm_num)
      _ = (204800 / κ ^ 2) * (regSize y.active : ℝ)^4 := by ring
      _ ≤ _ := mul_le_mul_of_nonneg_right (by norm_num at coeff ⊢; exact coeff) (by positivity)
  rw [referencePrecision]
  exact (div_le_iff₀ (by positivity)).mpr (by
    have := (div_le_iff₀ hp).mp hbound
    nlinarith)

private theorem extraBits_linear (n : ℕ) (hn : 1 ≤ n) :
    algorithm1ExtraBits (referencePrecision (precisionLevel n)) ≤ 70*n := by
  rw [algorithm1ExtraBits_referencePrecision]
  have hnexp : n ≤ 2^n := Nat.le_of_lt Nat.lt_two_pow_self
  have exponent : precisionLevel n ≤ 2^(26+4*n) := by
    simp only [precisionLevel, pow_add, mul_comm 4 n, pow_mul]
    gcongr
  have small : 7 ≤ 2^(26+4*n) := by
    have : 2^26 ≤ 2^(26+4*n) := Nat.pow_le_pow_right (by decide) (by omega)
    omega
  have e : precisionLevel n + 7 ≤ 2^(26+4*n+1) := by rw [pow_succ]; omega
  have ec : Nat.clog 2 ((precisionLevel n + 7)^2) ≤ (26+4*n+1)*2 := by
    apply Nat.clog_le_of_le_pow
    rw [pow_mul]
    exact Nat.pow_le_pow_left e _
  unfold algorithm1ExtraBitsNat
  omega

private abbrev policy := ShorLoweringPolicy.constPolicy Submission.setup.table

private abbrev level (inst : ShorOrderFindingInstance) := precisionLevel (Nat.log2 (2*inst.N))

/-- Fully allocated circuit at the explicit polynomial precision level. -/
noncomputable def program (inst : ShorOrderFindingInstance) : ShorOrderFindingProgram :=
  let ready := referenceLayout_ready (qs := qs) policy inst (level inst)
  { circuit := Policy.lowerGate policy ready.circuit ready.workspace
    output := (allocateReferenceLayout policy inst (level inst)).x.active }

/-- Single-run recovery for the very circuit whose gates are counted below. -/
theorem programRecovery (inst : ShorOrderFindingInstance) :
    κ / (2 * Real.log ((Nat.log2 inst.N : ℝ)+1)) ≤
      qlSuccess (maxQubit (program inst).circuit) (program inst).circuit (program inst).output budget
        (fun d => decide (inst.a^d % inst.N = 1)) (ord inst.a inst.N inst.coprime)
        (ASize (program inst).output) := by
  let layout := allocateReferenceLayout policy inst (level inst)
  let ready := referenceLayout_ready (qs := qs) policy inst (level inst)
  have hx := allocateReferenceLayout_x_width policy inst (level inst)
  have hy := allocateReferenceLayout_data_width policy inst (level inst)
  have prec := referencePrecision_le inst layout.x layout.data hx hy
  rw [hy] at prec
  have h := Shor_correct_approx_lowered (qs := qs) budget complete inst policy
    (ShorLoweringPolicy.constPolicy_admissible Submission.setup.table_admissible)
    layout.x layout.data layout.work layout.scratch layout.flag _ hx hy _ prec ready ready.workspace
  exact h.trans_eq (probability_of_success_eq _ le_rfl _ _ _ _ _)

/-- The very same physical experiment has cubic logical gate count in the
binary data width, in ForShor's elementary-gate cost model. -/
theorem programGateCount :
    ∃ (C : ℝ) (n₀ : ℕ), 0 < C ∧ ∀ inst : ShorOrderFindingInstance,
      n₀ ≤ Nat.log2 (2*inst.N) →
      (LowGate.gateCount shorGateCostModel (program inst).circuit : ℝ) ≤
        C * (Nat.log2 (2*inst.N) : ℝ)^3 := by
  have hexp : Real.log (q Submission.setup.k : ℝ) / Real.log (Submission.setup.k : ℝ) ≤ 1 + 1 := by
    change Real.log 3 / Real.log 2 ≤ 1 + 1
    apply (div_le_iff₀ (Real.log_pos (by norm_num))).mpr
    have h := Real.log_le_log (by norm_num : (0:ℝ)<3) (by norm_num : (3:ℝ)≤2^2)
    rw [Real.log_pow] at h
    norm_num at h ⊢
    exact h
  obtain ⟨C,hC,n₀,_,bound⟩ := shorGateCountBound_of_setup qs Submission.setup 1 hexp 71 (by decide)
  refine ⟨C,n₀,hC,?_⟩
  intro inst hn
  let layout := allocateReferenceLayout policy inst (level inst)
  let ready := referenceLayout_ready (qs := qs) policy inst (level inst)
  have hx := allocateReferenceLayout_x_width policy inst (level inst)
  have hy := allocateReferenceLayout_data_width policy inst (level inst)
  have hw : 1 ≤ Nat.log2 (2*inst.N) := by
    rw [Nat.log2_two_mul (by have := inst.range; omega : inst.N ≠ 0)]
    omega
  have h := bound inst layout.x layout.data layout.work layout.scratch layout.flag _ hx hy _ ready ready.workspace
  have eqw : layout.data.width = Nat.log2 (2*inst.N) := hy
  have eb := extraBits_linear _ hw
  rw [← hy] at eb
  have g := h (eqw ▸ hn) (by simpa [layout, level, hy] using eb)
  simp only [eqw, max_eq_right hw] at g
  rw [show (2:ℝ)+1 = ((3:ℕ):ℝ) by norm_num] at g
  change _ ≤ C * ((Nat.log2 (2*inst.N) : ℝ) ^ ((3 : ℕ) : ℝ)) at g
  rwa [Real.rpow_natCast] at g

end FQChem.Complexity.OrderFinding
