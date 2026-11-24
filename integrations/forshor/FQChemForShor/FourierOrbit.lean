import FQChem.Complexity.OrderFindingDecoder
import FQChem.Complexity.OrderFindingPostprocessing
import ForShor.ShorVerification.Implementation.Shor.Proofs.NaiveShor.Preliminaries
import Mathlib.RingTheory.RootsOfUnity.Complex

/-! # Ideal order finding on an arbitrary Fourier clock

The input has amplitude 1/√Q at (t, a^t mod N) for every exponent t. Apply the
explicit inverse Fourier matrix to the clock and marginalize over the full
residue register. Shor §5, Eqs. (5.4)–(5.13), applies as soon as r² < Q.
-/

namespace FQChem.Complexity.FourierOrbit
open Shor
open scoped BigOperators ComplexConjugate
noncomputable section

/-- Normalization of a uniform Q-level superposition. -/
def scale (Q : ℕ) : ℂ := ((Real.sqrt Q : ℝ) : ℂ)⁻¹

/-- The modular power is stored in a full N-residue register. -/
def powerRegister {N : ℕ} (u : (ZMod N)ˣ) (Q : ℕ) : Matrix (Fin Q) (Fin N) ℂ :=
  fun t y => if (u ^ t.val).val.val = y.val then scale Q else 0

/-- The normalized inverse Fourier matrix, also defined at non-power-of-two Q. -/
def inverseFourier (Q : ℕ) : Matrix (Fin Q) (Fin Q) ℂ :=
  fun o t => scale Q * star (qftPhase Q t.val o.val)

/-- Born probability after matrix multiplication, summed over all data labels. -/
def clockBorn {N : ℕ} (u : (ZMod N)ˣ) (Q : ℕ) (o : Fin Q) : ℝ :=
  ∑ y : Fin N, ‖(inverseFourier Q * powerRegister u Q) o y‖ ^ 2

private theorem scale_sq (Q : ℕ) : scale Q * scale Q = 1 / (Q : ℂ) := by
  rw [scale, ← mul_inv, ← Complex.ofReal_mul, Real.mul_self_sqrt (by positivity)]
  simp

theorem powerRegister_normalized {N Q : ℕ} [NeZero N] (u : (ZMod N)ˣ) (hQ : 0 < Q) :
    ∑ t : Fin Q, ∑ y : Fin N, ‖powerRegister u Q t y‖ ^ 2 = 1 := by
  have h (t : Fin Q) : ∑ y : Fin N, ‖powerRegister u Q t y‖ ^ 2 = ‖scale Q‖ ^ 2 := by
    let w : Fin N := ⟨(u ^ t.val).val.val, ZMod.val_lt _⟩
    rw [Finset.sum_eq_single w]
    · simp [powerRegister, w]
    · intro y _ hne
      have hv : (u ^ t.val).val.val ≠ y.val := fun hc => hne (Fin.ext hc.symm)
      simp only [powerRegister, ite_eq_right hv, norm_zero, zero_pow (by decide : 2 ≠ 0)]
    · simp
  simp only [h, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  have hh := congrArg norm (scale_sq Q)
  simp at hh
  rw [pow_two, hh]
  simp [hQ.ne']

private def label {N : ℕ} [NeZero N] (u : (ZMod N)ˣ) (s : Fin (orderOf u)) : Fin N :=
  ⟨(u ^ s.val).val.val, ZMod.val_lt _⟩

private theorem label_injective {N : ℕ} [NeZero N] (u : (ZMod N)ˣ) :
    Function.Injective (label u) := by
  intro i j h
  apply Fin.ext
  apply pow_injOn_Iio_orderOf (x := u) i.isLt j.isLt
  apply Units.ext
  exact (ZMod.val_injective _ (congrArg Fin.val h))

private theorem power_residue {N : ℕ} [NeZero N] (u : (ZMod N)ˣ) (t : ℕ) :
    (u ^ t).val.val = (label u ⟨t % orderOf u, Nat.mod_lt _ (orderOf_pos u)⟩).val :=
  congrArg (fun z : (ZMod N)ˣ => z.val.val) (pow_mod_orderOf u t).symm

private theorem amplitude_expand {N Q : ℕ} (u : (ZMod N)ˣ) (o : Fin Q) (y : Fin N) :
    (inverseFourier Q * powerRegister u Q) o y =
      1 / (Q : ℂ) * ∑ t ∈ Finset.range Q,
        if (u ^ t).val.val = y.val then star (qftPhase Q t o.val) else 0 := by
  rw [Matrix.mul_apply, ← Fin.sum_univ_eq_sum_range, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro t _
  by_cases h : (u ^ t.val).val.val = y.val
  · simp only [inverseFourier, powerRegister, ite_eq_left h]
    rw [mul_right_comm, scale_sq]
  · simp only [inverseFourier, powerRegister, ite_eq_right h, mul_zero]

private theorem amplitude_label {N Q : ℕ} [NeZero N] (u : (ZMod N)ˣ) (o : Fin Q)
    (s : Fin (orderOf u)) :
    (inverseFourier Q * powerRegister u Q) o (label u s) =
      shorPeriodClassAmplitude Q (orderOf u) s.val o.val := by
  rw [amplitude_expand, shorPeriodClassAmplitude, Finset.sum_filter]
  congr 1
  apply Finset.sum_congr rfl
  intro t _
  have h : (u^t).val.val = (label u s).val ↔ t % orderOf u = s.val := by
    rw [power_residue u t]
    exact Fin.val_inj.trans ((label_injective u).eq_iff.trans Fin.val_inj.symm)
  simp only [h]

/-- Equations (5.5)–(5.7) follow from the inverse Fourier matrix and
orthogonality of the computational residue basis, at every positive clock. -/
theorem born_eq_period_formula {N Q : ℕ} [NeZero N] (u : (ZMod N)ˣ) (o : Fin Q) :
    clockBorn u Q o = shorPaperOutcomeProb Q (orderOf u) o.val := by
  classical
  let U := Finset.univ.image (label u)
  let mass (y : Fin N) := ‖(inverseFourier Q * powerRegister u Q) o y‖ ^ 2
  have h0 (y : Fin N) (h : y ∉ U) : mass y = 0 := by
    have hne (t : ℕ) : (u^t).val.val ≠ y.val := by
      intro he
      apply h
      exact Finset.mem_image.mpr ⟨_, Finset.mem_univ _, Fin.ext ((power_residue u t).symm.trans he)⟩
    simp only [mass, amplitude_expand, ite_eq_right (hne _), Finset.sum_const_zero,
      mul_zero, norm_zero, zero_pow (by decide : 2 ≠ 0)]
  calc
    _ = ∑ y ∈ U, mass y := (Finset.sum_subset (Finset.subset_univ U) (fun y _ => h0 y)).symm
    _ = ∑ s : Fin (orderOf u), mass (label u s) := Finset.sum_image (label_injective u).injOn
    _ = _ := by
      simp only [mass, amplitude_label, shorPaperOutcomeProb]
      exact Fin.sum_univ_eq_sum_range (fun s => ‖shorPeriodClassAmplitude Q (orderOf u) s o.val‖ ^ 2) _

private theorem omega_norm (Q t : ℕ) : ‖(ω Q)^t‖ = 1 := by
  simpa [qftPhase, ωPow] using norm_qftPhase_one_shor Q t 1

private theorem phase_cross {Q : ℕ} (hQ : 0 < Q) (i j : Fin Q) :
    ∑ o : Fin Q, qftPhase Q i o * star (qftPhase Q j o) =
      if i = j then (Q : ℂ) else 0 := by
  let z := (ω Q)^i.val * conj ((ω Q)^j.val)
  have hunit (k : ℕ) : (ω Q)^k * conj ((ω Q)^k) = 1 := by
    rw [Complex.mul_conj', omega_norm]; norm_num
  have eqt (o : Fin Q) : qftPhase Q i o * star (qftPhase Q j o) = z ^ o.val := by
    simp only [z, qftPhase, ωPow, pow_mul, mul_pow, map_pow, Complex.star_def]
  simp only [eqt]
  by_cases h : i = j
  · subst j
    simp [z, hunit]
  · rw [ite_eq_right h, Fin.sum_univ_eq_sum_range (fun o => z^o)]
    have hprim : IsPrimitiveRoot (ω Q) Q := Complex.isPrimitiveRoot_exp Q hQ.ne'
    have hz : z ≠ 1 := by
      intro he
      have eq := congrArg (· * (ω Q)^j.val) he
      change (ω Q)^i.val * conj ((ω Q)^j.val) * (ω Q)^j.val = _ at eq
      rw [mul_assoc, mul_comm (conj _), hunit, mul_one, one_mul] at eq
      exact h (Fin.ext (hprim.pow_inj i.isLt j.isLt eq))
    have hpow (k : ℕ) : ((ω Q)^k)^Q = 1 := by rw [pow_right_comm, hprim.pow_eq_one, one_pow]
    have hzQ : z ^ Q = 1 := by
      simp only [z, mul_pow, ← map_pow, hpow, map_one, mul_one]
    exact (mul_eq_zero.mp ((geom_sum_mul z Q).trans (by rw [hzQ, sub_self]))).resolve_right
      (sub_ne_zero.mpr hz)

/-- The inverse Fourier matrix is unitary at every positive integer size. -/
theorem inverseFourier_unitary (Q : ℕ) (hQ : 0 < Q) :
    (inverseFourier Q).conjTranspose * inverseFourier Q = 1 := by
  ext i j
  rw [Matrix.mul_apply]
  have hs : star (scale Q) = scale Q := by simp [scale]
  have eqt (o : Fin Q) : (inverseFourier Q).conjTranspose i o * inverseFourier Q o j =
      (1/(Q:ℂ)) * (qftPhase Q i o * star (qftPhase Q j o)) := by
    simp only [Matrix.conjTranspose_apply, inverseFourier, star_mul, star_star, hs]
    rw [← scale_sq]
    ring
  simp only [eqt, ← Finset.mul_sum, phase_cross hQ, Matrix.one_apply]
  split <;> simp_all [hQ.ne']

private theorem total_trace {α β : Type*} [Fintype α] [Fintype β] (A : Matrix α β ℂ) :
    ∑ i, ∑ j, ‖A i j‖ ^ 2 = (A.conjTranspose * A).trace.re := by
  rw [Finset.sum_comm]
  simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply, Matrix.conjTranspose_apply,
    Complex.re_sum]
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro i _
  simp [Complex.conj_mul', ← Complex.ofReal_pow]

/-- Summing the measured Fourier marginal over the entire clock gives one. -/
theorem born_normalized {N : ℕ} [NeZero N] (u : (ZMod N)ˣ) (Q : ℕ) (hQ : 0 < Q) :
    ∑ o : Fin Q, clockBorn u Q o = 1 := by
  change ∑ o, ∑ y, ‖(inverseFourier Q * powerRegister u Q) o y‖ ^ 2 = 1
  rw [total_trace, Matrix.conjTranspose_mul, Matrix.mul_assoc,
    ← Matrix.mul_assoc (inverseFourier Q).conjTranspose, inverseFourier_unitary Q hQ,
    Matrix.one_mul, ← total_trace]
  exact powerRegister_normalized u hQ

private theorem good_decodes (inst : ShorOrderFindingInstance) {Q : ℕ} (o : Fin Q)
    (hg : GoodOutcome o.val Q (ord inst.a inst.N inst.coprime)) :
    (OrderFindingDecoder.decode inst.N inst.a o.val Q).order = ord inst.a inst.N inst.coprime := by
  let T (q : ℕ) := 2 * (q.log2+1) + 1
  let v (d : ℕ) := decide (inst.a^d % inst.N = 1)
  have h := goodOutcome_r_found_one T OrderFindingPostprocessing.logarithmic_scan inst hg
  have hp : OF_post T v o.val Q = ord inst.a inst.N inst.coprime := by
    by_contra hn
    simp [r_found, v, hn] at h
  exact (OrderFindingDecoder.scan_eq_reference inst.N inst.a o.val Q (T Q) (lt_of_le_of_lt (Nat.zero_le o.val) o.isLt)).trans hp

/-- Ideal single-shot recovery at any integer clock size above the squared
order, using the executable bounded decoder and Born probabilities of the
explicit Fourier transform of the modular-power state. -/
theorem idealRecovery (inst : ShorOrderFindingInstance) (Q : ℕ)
    (hQ : (ord inst.a inst.N inst.coprime)^2 < Q) :
    let r := ord inst.a inst.N inst.coprime
    let u := ZMod.unitOfCoprime inst.a ((Nat.coprime_iff_gcd_eq_one).mpr inst.coprime)
    4 / Real.pi ^ 2 * ((Nat.totient r : ℝ) / r) ≤
      ∑ o : Fin Q, if (OrderFindingDecoder.decode inst.N inst.a o.val Q).order = r
        then clockBorn u Q o else 0 := by
  classical
  let r := ord inst.a inst.N inst.coprime
  let u := ZMod.unitOfCoprime inst.a ((Nat.coprime_iff_gcd_eq_one).mpr inst.coprime)
  let : NeZero inst.N := ⟨(inst.range.1.trans inst.range.2).ne'⟩
  have hr : 0 < r := orderOf_pos u
  have hp (o : Fin Q) (hg : GoodOutcome o.val Q r) :
      4 / Real.pi ^ 2 * (1 / (r : ℝ)) ≤ clockBorn u Q o :=
    (shor_paper_goodOutcome_lower_bound hg).trans_eq (born_eq_period_formula u o).symm
  apply (goodOutcome_mass_lower_bound_from_card_and_pointwise Q r _ hr
    (goodOutcome_card_ge_totient hr hQ) hp).trans
  apply Finset.sum_le_sum
  intro o _
  change goodOutcomeIndicator o.val Q r * clockBorn u Q o ≤
    if (OrderFindingDecoder.decode inst.N inst.a o.val Q).order = r then clockBorn u Q o else 0
  by_cases hg : GoodOutcome o.val Q r
  · simp [goodOutcomeIndicator, hg, good_decodes inst o hg, r] at *
  · simp only [goodOutcomeIndicator, ite_eq_right hg, zero_mul]
    split
    next => exact Finset.sum_nonneg (fun _ _ => sq_nonneg _)
    next => rfl

/-- The smallest binary clock at least N². It equals N² when N is a
power of two, as required by the strict upper bound of Shor §5. -/
def paperClock (N : ℕ) : ℕ := 2^((N^2 - 1).log2+1)

theorem paperClock_bounds {N : ℕ} (hN : 1 < N) :
    N^2 ≤ paperClock N ∧ paperClock N < 2*N^2 := by
  have h2 : 1 < N^2 := by nlinarith
  have hlo := Nat.lt_log2_self (n := N^2 - 1)
  have hhi := Nat.log2_self_le (n := N^2 - 1) (by omega)
  constructor
  · change N^2 ≤ 2^((N^2 - 1).log2+1)
    omega
  · unfold paperClock
    rw [pow_succ]
    omega

/-- Recovery using Shor's N² ≤ Q < 2N² binary clock, including power-of-two
moduli. The order of any unit is bounded by φ(N) < N. -/
theorem publishedClockRecovery (inst : ShorOrderFindingInstance) :
    let Q := paperClock inst.N
    let r := ord inst.a inst.N inst.coprime
    let u := ZMod.unitOfCoprime inst.a ((Nat.coprime_iff_gcd_eq_one).mpr inst.coprime)
    4 / Real.pi ^ 2 * ((Nat.totient r : ℝ) / r) ≤
      ∑ o : Fin Q, if (OrderFindingDecoder.decode inst.N inst.a o.val Q).order = r
        then clockBorn u Q o else 0 := by
  apply idealRecovery
  have hN : 1 < inst.N := lt_of_le_of_lt inst.range.1 inst.range.2
  let : NeZero inst.N := ⟨by omega⟩
  let u := ZMod.unitOfCoprime inst.a ((Nat.coprime_iff_gcd_eq_one).mpr inst.coprime)
  have hle := orderOf_le_card_univ (x := u)
  rw [ZMod.card_units_eq_totient] at hle
  exact (Nat.pow_lt_pow_left (hle.trans_lt (Nat.totient_lt _ hN)) (by decide : 2 ≠ 0)).trans_le
    (paperClock_bounds hN).1

end
end FQChem.Complexity.FourierOrbit
