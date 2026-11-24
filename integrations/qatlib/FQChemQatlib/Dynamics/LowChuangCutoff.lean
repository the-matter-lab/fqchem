module

public import Qatlib.Papers.Qubitization19.MainResults.SourceTheorem1

/-! # The factorial cutoff for qubitized evolution

Low and Chuang, Theorem 1, Eq. (1), specify the smallest positive factorial
cutoff. At a constant multiple of that same cutoff, the ordinary Taylor tail
is small enough even for coherent amplification with a square-root error loss.
-/

@[expose] public section

namespace FQChemQatlib.Dynamics.LowChuang

open Qatlib.Papers.Qubitization19.MainResults Qatlib.Concepts.QspSimulation.Achievability

private noncomputable def term (t : ℝ) (n : ℕ) := |t| ^ n / (n.factorial : ℝ)

/-- Existence and minimality in the paper's Eq. (1), including zero time. -/
theorem leastCutoff (t ε : ℝ) (positive : 0 < ε) : ∃ q, IsPaperCutoffQ t ε q := by
  classical
  obtain ⟨n,hn⟩ := exponentialTaylor_eventually_error_lt (t/2) (show 0 < ε/2 by positivity)
  have existsCut : ∃ k : ℕ, 0 < k ∧ 4 * |t|^k / ((k.factorial:ℝ)*2^k) ≤ ε := by
    refine ⟨n+1, by omega, ?_⟩
    have h := (hn (n+1) (by omega)).2.1
    rw [exponentialTaylorError,abs_div,abs_of_nonneg (by norm_num : (0:ℝ)≤2),div_pow] at h
    linarith only [h,show 4*|t|^(n+1)/((↑(n+1).factorial:ℝ)*2^(n+1)) =
      2*(|t|^(n+1)/2^(n+1)/(↑(n+1).factorial:ℝ)*2) by ring]
  refine ⟨Nat.find existsCut,(Nat.find_spec existsCut).1,(Nat.find_spec existsCut).2,?_⟩
  intro k pos less ok
  exact (Nat.find_min existsCut less) ⟨pos,ok⟩

private theorem timeBound (t ε : ℝ) {q : ℕ} (hq : 0 < q) (hε : ε ≤ 1)
    (cut : 4 * |t|^q / ((q.factorial:ℝ)*2^q) ≤ ε) : |t| ≤ 2*q := by
  have fac : (q.factorial:ℝ) ≤ (q:ℝ)^q := by exact_mod_cast Nat.factorial_le_pow q
  by_contra! big
  have power := pow_lt_pow_left₀ big (by positivity : (0:ℝ) ≤ 2*q) hq.ne'
  rw [mul_pow] at power
  have hcut := (div_le_iff₀ (by positivity)).mp (cut.trans hε)
  nlinarith only [power, mul_le_mul_of_nonneg_left fac (by positivity : (0:ℝ) ≤ 2^q),
    hcut, pow_nonneg (abs_nonneg t) q]

private theorem geometricTail (t c : ℝ) (m k : ℕ) (hc : 0 ≤ c)
    (ratio : |t| ≤ c*(m+1)) : term t (m+k) ≤ term t m * c^k := by
  induction k with
  | zero => simp
  | succ k ih =>
    have denom : (0:ℝ) < (m+k+1:ℕ) := by positivity
    have step : |t| / ((m+k+1:ℕ):ℝ) ≤ c := by
      apply (div_le_iff₀ denom).mpr
      exact ratio.trans (by push_cast; nlinarith)
    have eq : term t (m+(k+1)) = term t (m+k) * (|t|/((m+k+1:ℕ):ℝ)) := by
      unfold term
      rw [show m+(k+1)=(m+k)+1 by omega,pow_succ,Nat.factorial_succ]
      rw [Nat.cast_mul,mul_comm ((m+k+1:ℕ):ℝ),div_mul_div_comm]
    rw [eq,pow_succ,← mul_assoc]
    exact mul_le_mul ih step (by positivity) (by unfold term; positivity)

private theorem doubleTerm (t : ℝ) (q : ℕ) : term t (2*q) ≤ (term t q)^2 := by
  have fact : (q.factorial:ℝ)*(q.factorial:ℝ) ≤ ((q+q).factorial:ℝ) := by
    exact_mod_cast Nat.le_of_dvd (Nat.factorial_pos _) (Nat.factorial_mul_factorial_dvd_factorial_add q q)
  unfold term
  rw [two_mul, pow_add, pow_two, div_mul_div_comm]
  exact div_le_div_of_nonneg_left (by positivity) (by positivity) fact

/-- A Taylor cutoff of 16q suffices for clean simulation if q meets Eq. (1).
The bound is uniform jointly in time and accuracy. -/
theorem amplifiedTaylorCutoff (t ε : ℝ) {q : ℕ} (hq : 0<q) (positive : 0<ε) (small : ε≤1)
    (cut : 4 * |t|^q / ((q.factorial:ℝ)*2^q) ≤ ε) :
    2*|t| ≤ ((16*q:ℕ):ℝ)+1 ∧ exponentialTaylorError t (16*q) ≤ ε^2/6750 := by
  have ht := timeBound t ε hq small cut
  have base : term t q ≤ ε/4*2^q := by
    have h := (div_le_iff₀ (by positivity)).mp cut
    unfold term
    apply (div_le_iff₀ (by positivity)).mpr
    nlinarith
  have two := (doubleTerm t q).trans (pow_le_pow_left₀ (by unfold term; positivity) base 2)
  have four := geometricTail t 1 (2*q) (2*q) (by norm_num) (by push_cast; linarith)
  rw [one_pow,mul_one,show 2*q+2*q=4*q by omega] at four
  have last := geometricTail t (1/2) (4*q) (12*q) (by norm_num) (by push_cast; linarith)
  rw [show 4*q+12*q=16*q by omega] at last
  have combined := last.trans (mul_le_mul_of_nonneg_right (four.trans two) (by positivity))
  have shrink : 2*((ε/4*2^q)^2*(1/2:ℝ)^(12*q)) = ε^2/8 * (1/2:ℝ)^(10*q) := by
    rw [show 12*q = q+q+10*q by omega,pow_add,pow_add,div_pow,one_pow]
    field_simp
    ring
  have decay : (1/2:ℝ)^(10*q) ≤ (1/2:ℝ)^10 :=
    pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)
  constructor
  · push_cast; linarith
  · change term t (16*q)*2 ≤ _
    calc
      _ ≤ 2*((ε/4*2^q)^2*(1/2:ℝ)^(12*q)) := by linarith only [combined]
      _ = _ := shrink
      _ ≤ ε^2/8 * (1/2:ℝ)^10 := mul_le_mul_of_nonneg_left decay (by positivity)
      _ ≤ _ := by norm_num; nlinarith [sq_nonneg ε]

end FQChemQatlib.Dynamics.LowChuang
