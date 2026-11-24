module

public import FQChemQatlib.Dynamics.LowChuangCutoff

/-! # Uniform cutoff bounds under constant sparse-normalization overhead -/

@[expose] public section
namespace FQChemQatlib.Dynamics.LowChuang.SparseBlock

open Qatlib.Papers.Qubitization19.MainResults

private theorem factorial_block (k q : ℕ) {i : ℕ} (hi : i ≤ k) :
    (k*q).factorial * i.factorial * (q+1)^i ≤ (k*q+i).factorial := by
  induction i with
  | zero => simp
  | succ i ih =>
    have prev := ih (by omega)
    have factor : (i+1)*(q+1) ≤ k*q+i+1 := by nlinarith [Nat.mul_le_mul_right q (show i+1 ≤ k by omega)]
    rw [show k*q+(i+1)=(k*q+i)+1 by omega,Nat.factorial_succ]
    calc
      _ = ((k*q).factorial * i.factorial * (q+1)^i) * ((i+1)*(q+1)) := by
        rw [pow_succ]; ring
      _ ≤ _ := (Nat.mul_le_mul prev factor).trans_eq (Nat.mul_comm _ _)

private theorem factorial_dilation (k q : ℕ) :
    k.factorial^q * q.factorial^k ≤ (k*q).factorial := by
  induction q with
  | zero => simp
  | succ q ih =>
    calc
      _ = (k.factorial^q * q.factorial^k) * k.factorial * (q+1)^k := by
        rw [pow_succ,Nat.factorial_succ,mul_pow]; ring
      _ ≤ (k*q).factorial * k.factorial * (q+1)^k :=
        Nat.mul_le_mul_right _ (Nat.mul_le_mul_right _ ih)
      _ ≤ _ := by simpa [Nat.mul_succ] using factorial_block k q (i:=k) le_rfl

/-- Multiplying scaled time by at most c increases the minimal factorial
cutoff by at most K whenever c^K ≤ K!. This bound holds uniformly in the
joint time/accuracy regime, including zero time. -/
theorem cutoff_dilation {t s ε : ℝ} {q r K c : ℕ} (hq : IsPaperCutoffQ t ε q)
    (hr : IsPaperCutoffQ s ε r) (hε : ε≤1) (Kpos : 0<K) (dil : |s| ≤ c*|t|)
    (small : c^K ≤ K.factorial) : r ≤ K*q := by
  let a := |t|^q / ((q.factorial:ℝ)*2^q)
  have apos : 0 ≤ a := by unfold a; positivity
  have h : 4*a ≤ ε := by simpa only [a,mul_div_assoc] using hq.2.1
  have a1 : a ≤ 1 := by linarith
  have shrink : a^K ≤ a := by
    simpa using pow_le_pow_of_le_one apos a1 (show 1 ≤ K by omega)
  have qsmall : ((c^K:ℕ):ℝ)^q ≤ ((K.factorial:ℕ):ℝ)^q := by
    exact_mod_cast Nat.pow_le_pow_left small q
  have fac : (K.factorial:ℝ)^q * (q.factorial:ℝ)^K ≤ ((K*q).factorial:ℝ) := by
    exact_mod_cast factorial_dilation K q
  have powbound : |s|^(K*q) ≤ (c*|t|)^(K*q) :=
    pow_le_pow_left₀ (by positivity) dil _
  have bound : |s|^(K*q) / (((K*q).factorial:ℝ)*2^(K*q)) ≤ a^K := by
    unfold a
    rw [div_pow,div_le_div_iff₀ (by positivity) (by positivity)]
    rw [mul_pow] at powbound
    have cc : (c:ℝ)^(K*q)*(q.factorial:ℝ)^K ≤ ((K*q).factorial:ℝ) := by
      rw [pow_mul]
      push_cast at qsmall
      exact (mul_le_mul_of_nonneg_right qsmall (by positivity)).trans fac
    calc
      _ ≤ ((c:ℝ)^(K*q)*|t|^(K*q))*((q.factorial:ℝ)*2^q)^K :=
        mul_le_mul_of_nonneg_right powbound (by positivity)
      _ = ((c:ℝ)^(K*q)*(q.factorial:ℝ)^K) * ((|t|^q)^K*2^(K*q)) := by
        rw [mul_pow,← pow_mul,← pow_mul,Nat.mul_comm q K]; ring
      _ ≤ _ := by
        have cmp := mul_le_mul_of_nonneg_right cc (by positivity : (0:ℝ) ≤ (|t|^q)^K*2^(K*q))
        linarith only [cmp,show ((K*q).factorial:ℝ)*((|t|^q)^K*2^(K*q)) =
          (|t|^q)^K*(((K*q).factorial:ℝ)*2^(K*q)) by ring]
  by_contra! gt
  apply hr.2.2 _ (Nat.mul_pos Kpos hq.1) gt
  rw [mul_div_assoc]
  exact (mul_le_mul_of_nonneg_left (bound.trans shrink) (by norm_num)).trans h

/-- Padded slots and the binary LCU normalization cost a factor of at most
four in scaled time, and at most nine in the optimal precision cutoff. -/
theorem cartesianCutoff {t s ε : ℝ} {q r : ℕ} (hq : IsPaperCutoffQ t ε q)
    (hr : IsPaperCutoffQ s ε r) (hε : ε≤1) (dil : |s| ≤ 4*|t|) : r ≤ 9*q :=
  cutoff_dilation (c:=4) hq hr hε (by decide) dil (by decide)

end FQChemQatlib.Dynamics.LowChuang.SparseBlock
