module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticReadout
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Tactic

/-! # Sampling the even sector by rejecting odd-boundary subgraphs

Jerrum–Sinclair, Theorem 10. At zero magnetic field, boost the odd-vertex factor
to 1/n and condition on the absence of odd vertices. Finite-volume correlation
bounds imply a success probability of at least 1/3, uniformly in temperature.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
variable {n : ℕ}

def oddFactor (u : ℝ) (d : Spin n) := ∏ i, if d i then u else 1

def boostedWeight (x u : ℝ) (A : Finset (Spin n)) := x^A.card * oddFactor u (boundary A)

def boostedMass (B : Finset (Spin n)) (x u : ℝ) := ∑ A ∈ B.powerset, boostedWeight x u A

private theorem sumOddFactor (u : ℝ) : ∑ d : Spin n, oddFactor u d = (1+u)^n := by
  change (∑ d : Spin n, ∏ i, if d i then u else 1) = _
  rw [← Fintype.prod_sum (fun (_ : Fin n) (b : Bool) => if b then u else 1)]
  simp [add_comm]

private theorem factorPositive {u : ℝ} (h : 0 < u) (d : Spin n) : 0 < oddFactor u d := by
  apply Finset.prod_pos
  intro i _
  split <;> positivity

theorem boostedWeightPositive {x u : ℝ} (hx : 0 < x) (hu : 0 < u) (A : Finset (Spin n)) :
    0 < boostedWeight x u A := mul_pos (pow_pos hx _) (factorPositive hu _)

private theorem boostedExpansion (g : Glass n) (x u : ℝ) :
    boostedMass g.bonds x u = ∑ d, oddFactor u d * sector g.bonds x d := by
  simp only [sector,Finset.mul_sum, mul_ite, mul_zero]
  rw [Finset.sum_comm]
  simp [boostedMass,boostedWeight,mul_comm]

private theorem boostPositive (g : Glass n) {x u : ℝ} (hx : 0 < x) (hu : 0 < u) :
    0 < boostedMass g.bonds x u :=
  Finset.sum_pos (fun A _ => boostedWeightPositive hx hu A) ⟨∅, Finset.empty_mem_powerset _⟩

theorem evenAcceptance (g : Glass n) (hn : 0 < n) {β : ℝ} (hβ : 0 < β) :
    let x := Real.tanh β
    1/3 ≤ mass g.bonds x / boostedMass g.bonds x (n:ℝ)⁻¹ := by
  intro x
  let u := (n:ℝ)⁻¹
  have nr : 0 < (n:ℝ) := by exact_mod_cast hn
  have hu : 0 < u := by dsimp [u]; positivity
  have bound : boostedMass g.bonds x u ≤ 3 * mass g.bonds x := by
    rw [boostedExpansion]
    calc (∑ d, oddFactor u d * sector g.bonds x d) ≤ ∑ d : Spin n, oddFactor u d * mass g.bonds x :=
           Finset.sum_le_sum fun d _ => mul_le_mul_of_nonneg_left (sectorDomination g β d) (factorPositive hu d).le
         _ = (1+u)^n * mass g.bonds x := by rw [← Finset.sum_mul,sumOddFactor]
         _ ≤ 3 * mass g.bonds x := by
           apply mul_le_mul_of_nonneg_right _ (evenPositive g β).le
           have a : 1+u ≤ Real.exp u := by linarith [Real.add_one_le_exp u]
           calc (1+u)^n ≤ (Real.exp u)^n := pow_le_pow_left₀ (by positivity) a n
                _ = Real.exp 1 := by rw [← Real.exp_nat_mul]; congr 1; dsimp [u]; field_simp
                _ ≤ 3 := Real.exp_one_lt_three.le
  apply (le_div_iff₀ (boostPositive g (tanhPositive hβ) hu)).mpr
  linarith

theorem rejectionLaw (g : Glass n) {x u : ℝ} (hx : 0 < x) (hu : 0 < u)
    (A : Finset (Spin n)) :
    (if boundary A = aligned n then boostedWeight x u A / boostedMass g.bonds x u else 0) /
        (mass g.bonds x / boostedMass g.bonds x u) = evenWeight x A / mass g.bonds x := by
  by_cases h : boundary A=aligned n
  · simp [h,boostedWeight,evenWeight,oddFactor,aligned,
      div_div_div_cancel_right₀ (boostPositive g hx hu).ne']
  · simp [h,evenWeight]

theorem acceptanceMass (g : Glass n) (x u : ℝ) :
    (∑ A ∈ g.bonds.powerset, if boundary A = aligned n then boostedWeight x u A / boostedMass g.bonds x u else 0) =
    mass g.bonds x / boostedMass g.bonds x u := by
  rw [mass,sector,Finset.sum_div]
  apply Finset.sum_congr rfl
  intro A _
  by_cases h : boundary A=aligned n <;> simp [h,boostedWeight,oddFactor,aligned]

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
