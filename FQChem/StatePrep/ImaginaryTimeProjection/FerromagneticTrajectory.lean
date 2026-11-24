module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticApproximation
import Mathlib.Tactic

/-! # Consecutive observations after one ferromagnetic burn-in

A trajectory of length k has its actual finite Markov probability: draw the initial
state from q, then draw each following state from the row of the current state.
First and second moments of its additive observable satisfy exact recurrences.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
variable {α : Type*} [Fintype α]

def trajectory (K : α → α → ℝ) : (k : ℕ) → (α → ℝ) → (Fin k → α) → ℝ
  | 0,_,_ => 1
  | k+1,q,ω => q (ω 0)*trajectory K k (K (ω 0)) (Fin.tail ω)

theorem trajectoryCons (K : α → α → ℝ) (q : α → ℝ) (k : ℕ) (F : (Fin (k+1) → α) → ℝ) :
    expected (trajectory K (k+1) q) F =
      expected q (fun a => expected (trajectory K k (K a)) (fun ω => F (Fin.cons a ω))) := by
  unfold expected
  rw [← Equiv.sum_comp (Fin.consEquiv (fun _ : Fin (k+1) => α)),Fintype.sum_prod_type]
  simp [trajectory,Fin.consEquiv,Finset.mul_sum,mul_assoc]

theorem trajectoryProbability (K : α → α → ℝ) (row : ∀ a, (∀ b,0≤K a b) ∧ ∑ b, K a b=1)
    (q : α → ℝ) (hq : ∀ a, 0≤q a) (one : ∑ a,q a=1) (k : ℕ) :
    (∀ ω, 0≤trajectory K k q ω) ∧ ∑ ω, trajectory K k q ω = 1 := by
  induction k generalizing q with
  | zero => simp [trajectory]
  | succ k ih =>
    refine ⟨fun ω => mul_nonneg (hq _) ((ih _ (row _).1 (row _).2).1 _),?_⟩
    have eq := trajectoryCons K q k (fun _ => 1)
    simp only [expected,mul_one,(fun a => (ih _ (row a).1 (row a).2).2),one] at eq
    exact eq

def futureSum (K : α → α → ℝ) (f : α → ℝ) : ℕ → α → ℝ
  | 0,_ => 0
  | k+1,a => f a + expected (K a) (futureSum K f k)

def futureSquare (K : α → α → ℝ) (f : α → ℝ) : ℕ → α → ℝ
  | 0,_ => 0
  | k+1,a => (f a)^2+2*f a*expected (K a) (futureSum K f k)+expected (K a) (futureSquare K f k)

/-- Exact second moment of a shifted cumulative readout. The recurrences include
all temporal correlations of one trajectory. -/
theorem trajectoryMoment (K : α → α → ℝ) (row : ∀ a, ∑ b, K a b=1)
    (q f : α → ℝ) (one : ∑ a,q a=1) (k : ℕ) (d : ℝ) :
    expected (trajectory K k q) (fun ω => (d + ∑ i, f (ω i))^2) =
      d^2+2*d*expected q (futureSum K f k)+expected q (futureSquare K f k) := by
  induction k generalizing d q with
  | zero => simp [trajectory,expected,futureSum,futureSquare]
  | succ k ih =>
    rw [trajectoryCons]
    simp only [Fin.sum_univ_succ,Fin.cons_zero,Fin.cons_succ,← add_assoc]
    simp_rw [ih _ (row _) _]
    simp only [expected,futureSum,futureSquare]
    have const : d^2 = ∑ a, q a*d^2 := by rw [← Finset.sum_mul,one,one_mul]
    conv_rhs => rw [const]
    rw [Finset.mul_sum,← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun _ _ => by ring

/-- Changing only the initial law by unhalved L¹ distance η changes the expectation
of a whole bounded trajectory readout in [0,L] by at most ηL, independently of k. -/
theorem initialDrift (K : α → α → ℝ) (row : ∀ a, (∀ b,0≤K a b) ∧ ∑ b, K a b=1)
    (q p : α → ℝ) {k : ℕ} (hk : 0<k) (F : (Fin k → α) → ℝ) {L : ℝ} (hr : ∀ ω,0≤F ω ∧ F ω≤L) :
    |expected (trajectory K k q) F-expected (trajectory K k p) F| ≤ (∑ a, |q a-p a|)*L := by
  cases k with
  | zero => omega
  | succ k =>
    rw [trajectoryCons,trajectoryCons]
    apply expectedDrift
    intro a
    have h := trajectoryProbability K row (K a) (row a).1 (row a).2 k
    exact expectedBounds _ _ h.1 h.2 (fun ω => hr (Fin.cons a ω))

/-- The stationary expectation is preserved when an observable is averaged over one
actual Metropolis row. -/
theorem stationaryMean {n} (g : IsingSign.Glass n) {x u : ℝ} (hx : 0<x) (hu : 0<u) (f : Config g.bonds → ℝ) :
    expected (law g x u) (fun a => expected (kernel g x u a) f) = expected (law g x u) f := by
  unfold expected
  simp only [Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro b _
  simp_rw [← mul_assoc]
  rw [← Finset.sum_mul]
  exact congrArg (· * f b) (stationary g hx hu b)

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
