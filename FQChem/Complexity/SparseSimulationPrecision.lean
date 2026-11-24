module

public import FQChem.Complexity.SparseNoFastForwarding
import Mathlib.Analysis.Real.Pi.Bounds
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
import Mathlib.Tactic

/-! # Time and precision in sparse Hamiltonian simulation

The parity path in Low and Chuang's query lower bound retains a small but
strictly distinguishable endpoint signal also at short times. The argument
uses the Born probability of the output, allowing arbitrary discarded work.
[Low and Chuang, Theorem 2](https://doi.org/10.1103/PhysRevLett.118.010501).
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SparseSimulationPrecision

open FQChem.Complexity SparseParityPath SparseParityQueries
open scoped Matrix.Norms.L2Operator

variable {N q : ℕ} {B : Type*} [Fintype B] [DecidableEq B]

/-- Endpoint readout probability after time t on the two-sparse crossed path. -/
def probability (t : ℝ) (x : Fin N → Bool) : ℝ :=
  ‖NormedSpace.exp ((-(t:ℂ)*Complex.I) • crossed x) (Fin.last N,true) (0,false)‖^2

theorem endpointProbability (t : ℝ) (x : Fin N → Bool) :
    probability t x = if prefixParity x N then |Real.sin (t/2)|^(2*N) else 0 := by
  rw [probability,endpoint_amplitude,SpinPathEvolution.transfer_amplitude]
  cases h : prefixParity x N <;> simp [norm_pow, ← pow_mul, Nat.mul_comm, -Complex.ofReal_sin, Complex.norm_real,Real.norm_eq_abs]

/-- Any coherent whole-row-query simulator accurate to less than half the
endpoint probability requires at least N/4 queries. -/
theorem shortTimeLowerBound (r : RowCircuit N B q) (event : Finset B) (t ε : ℝ)
    (accuracy : ∀ x, |accept r event x - probability t x| ≤ ε)
    (precision : 2*ε < |Real.sin (t/2)|^(2*N)) : N ≤ 4*q := by
  apply separatedParity r event (|Real.sin (t/2)|^(2*N)/2)
  intro x
  have bound := abs_le.mp (accuracy x)
  rw [endpointProbability] at bound
  cases h : prefixParity x N <;> simp [h] at bound ⊢ <;> linarith

/-- The Taylor term bound obtained from the exponential series at a positive integer. -/
private theorem factorialBound {m : ℕ} (hm : 0<m) (a : ℝ) (ha : 0≤a) :
    a^m / m.factorial ≤ (3*a/m)^m := by
  have mpos : (0:ℝ) < m := by exact_mod_cast hm
  have ef := Real.pow_div_factorial_le_exp (m:ℝ) mpos.le m
  have ex : Real.exp m ≤ (3:ℝ)^m := by
    rw [← mul_one (m:ℝ),Real.exp_nat_mul]
    exact pow_le_pow_left₀ (Real.exp_pos 1).le Real.exp_one_lt_three.le _
  have factor : a^m / m.factorial = (a/m)^m * ((m:ℝ)^m / m.factorial) := by
    rw [div_pow]; field_simp
  rw [factor, show 3*a/m=(a/m)*3 by ring,mul_pow]
  exact mul_le_mul_of_nonneg_left (ef.trans ex) (by positivity)

/-- A signal of size |sin(τ/N)|²ᴺ bounds the Taylor term at cutoff 8N
throughout the interval before perfect transfer. -/
theorem cutoffFromSignal (hn : 0<N) (τ ε : ℝ) (hτ : 0≤τ)
    (beforeTransfer : τ ≤ Real.pi*N/2) (signal : |Real.sin (τ/N)|^(2*N) ≤ 2*ε) :
    4*(τ/2)^(8*N) / (8*N).factorial ≤ ε := by
  have hn' : (0:ℝ)<N := by exact_mod_cast hn
  let u := τ/(2*N)
  have hu : 0≤u := by dsimp [u]; positivity
  have hu1 : u ≤ 1 := by
    apply (div_le_iff₀ (by positivity : (0:ℝ)<2*N)).mpr
    nlinarith [mul_le_mul_of_nonneg_right Real.pi_lt_four.le hn'.le]
  have arg : τ/N ≤ Real.pi/2 := (div_le_iff₀ hn').mpr (by linarith)
  have sinbound : u ≤ |Real.sin (τ/N)| := by
    have cord := Real.mul_le_sin (div_nonneg hτ hn'.le) arg
    have half : (1:ℝ)/2 ≤ 2/Real.pi :=
      (le_div_iff₀ Real.pi_pos).mpr (by linarith [Real.pi_lt_four])
    calc
      u = (1/2)*(τ/N) := by dsimp [u]; ring
      _ ≤ (2/Real.pi)*(τ/N) := mul_le_mul_of_nonneg_right half (by positivity)
      _ ≤ _ := cord.trans (le_abs_self _)
  have small : (1/2:ℝ)^(8*N) ≤ 1/8 :=
    (pow_le_pow_of_le_one (by norm_num) (by norm_num) (show 3 ≤ 8*N by omega)).trans (by norm_num)
  have tail := factorialBound (m:=8*N) (by omega) (τ/2) (by positivity)
  have base : 3*(τ/2)/(↑(8*N):ℝ) ≤ (1/2)*u := by
    push_cast; dsimp [u]; field_simp; linarith
  have t := tail.trans (pow_le_pow_left₀ (by positivity) base _)
  rw [mul_pow] at t
  have signal' := (pow_le_pow_left₀ hu sinbound (2*N)).trans signal
  have shrink := mul_le_mul small (pow_le_pow_of_le_one hu hu1 (show 2*N ≤ 8*N by omega))
    (pow_nonneg hu _) (by norm_num : 0≤(1/8:ℝ))
  calc
    _ = 4*((τ/2)^(8*N)/(8*N).factorial) := by ring
    _ ≤ 4*(1/8*u^(2*N)) := by linarith [t.trans shrink]
    _ ≤ ε := by linarith

/-- If the N-edge endpoint can be simulated with fewer than N/4 queries,
the published factorial cutoff at scaled time τ = ‖H‖t is at most 8N
for 0 ≤ τ ≤ πN/2. This bounds the time and precision jointly. -/
theorem factorialObstruction (hn : 0 < N) (r : RowCircuit N B q) (event : Finset B)
    (τ ε : ℝ) (hτ : 0 ≤ τ) (beforeTransfer : τ ≤ Real.pi*N/2) (few : 4*q<N)
    (accuracy : ∀ x, |accept r event x - probability (2*τ/N) x| ≤ ε) :
    4*(τ/2)^(8*N) / (8*N).factorial ≤ ε := by
  apply cutoffFromSignal hn τ ε hτ beforeTransfer
  by_contra! better
  have period : (2*τ/N)/2=τ/N := by ring
  exact few.not_ge (shortTimeLowerBound r event _ ε accuracy (by rwa [period]))

/-- Any simulator that estimates the evolved endpoint on every crossed path
up to scaled time τ must use enough queries for the factorial cutoff. The
algorithm and measurement may depend on the requested time and the path
length. Only the bit string specifying the path is hidden. -/
theorem worstCaseCutoff (q : ℕ) (τ ε : ℝ) (hτ : 0≤τ) (hε : ε<1/2)
    (algorithm : ∀ (n : ℕ) (t : ℝ), 0≤t → n*t/2 ≤ τ →
      ∃ (w : ℕ) (r : RowCircuit n (Fin w) q) (event : Finset (Fin w)),
        ∀ x, |accept r event x - probability t x| ≤ ε) :
    ∃ m : ℕ, 0<m ∧ m ≤ 32*q+8 ∧ 4*(τ/2)^m/m.factorial ≤ ε := by
  let n := 4*q+1
  have hn : 0<n := by dsimp [n]; omega
  have hn' : (0:ℝ)<n := by exact_mod_cast hn
  have few : 4*q<n := by dsimp [n]; omega
  have beforeTransfer : τ ≤ Real.pi*n/2 := by
    by_contra! later
    obtain ⟨_,r,event,h⟩ := algorithm n Real.pi Real.pi_pos.le (by linarith)
    have signal : 2*ε < |Real.sin (Real.pi/2)|^(2*n) := by
      simp only [Real.sin_pi_div_two,abs_one,one_pow]; linarith
    exact few.not_ge (shortTimeLowerBound r event _ ε h signal)
  obtain ⟨_,r,event,h⟩ := algorithm n (2*τ/n) (by positivity) (by
    apply le_of_eq; field_simp)
  exact ⟨8*n,by omega,by dsimp [n]; omega,
    factorialObstruction hn r event τ ε hτ beforeTransfer few h⟩

end FQChem.Complexity.SparseSimulationPrecision
