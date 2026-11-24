module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Tactic

/-! # Jerrum–Sinclair's mean-energy estimator

For the homogeneous zero-field coupling J=1, Theorem 12 of Jerrum and Sinclair
reduces the quantum Gibbs mean to an expectation over even subgraphs. Deleting or
inserting one edge gives the readout identity directly, without differentiating a
partition function.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
variable {n : ℕ}

private theorem toggleBoundary (e u d : Spin n) : exchange e u = d ↔ u = exchange e d := by
  have cancel (a : Spin n) : exchange e (exchange e a) = a := by funext i; simp [exchange]
  constructor <;> intro h
  · rw [← h,cancel]
  · rw [h,cancel]

private theorem sectorInsert (B : Finset (Spin n)) (x : ℝ) (d e : Spin n) (he : e ∉ B) :
    sector (insert e B) x d = sector B x d + x*sector B x (exchange e d) := by
  simp only [sector, Finset.sum_powerset_insert he,Finset.mul_sum,add_right_inj]
  apply Finset.sum_congr rfl
  intro A hA
  have h : e ∉ A := fun h => he (Finset.mem_powerset.mp hA h)
  rw [boundary_insert h, Finset.card_insert_of_notMem h]
  by_cases hd : boundary A = exchange e d <;> simp [toggleBoundary,hd,pow_succ,mul_comm]

def mass (B : Finset (Spin n)) (x : ℝ) := sector B x (aligned n)

def evenWeight (x : ℝ) (A : Finset (Spin n)) : ℝ :=
  if boundary A = aligned n then x^A.card else 0

def occupancy (B : Finset (Spin n)) (x : ℝ) (e : Spin n) : ℝ :=
  ∑ A ∈ B.powerset, if e∈A then evenWeight x A else 0

private theorem occupancyInsert (B : Finset (Spin n)) (x : ℝ) (e : Spin n) (he : e ∉ B) :
    occupancy (insert e B) x e = x*sector B x e := by
  rw [occupancy, Finset.sum_powerset_insert he]
  have none : (∑ A ∈ B.powerset, if e ∈ A then evenWeight x A else 0) = 0 :=
    Finset.sum_eq_zero (fun A hA => ite_eq_right fun h => he (Finset.mem_powerset.mp hA h))
  rw [none,zero_add,sector,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro A hA
  have h : e ∉ A := fun h => he (Finset.mem_powerset.mp hA h)
  have zero : exchange e (aligned n) = e := by funext i; simp [exchange,aligned]
  simp [evenWeight, boundary_insert h, Finset.card_insert_of_notMem h, toggleBoundary, zero,
    mul_ite,pow_succ,mul_comm]

/-- Toggling one edge gives its two-spin correlation numerator as a linear combination
of the even-sector mass and the even mass in which that edge is occupied. -/
theorem edgeReadout {B : Finset (Spin n)} (x : ℝ) (hx : x ≠ 0) {e : Spin n} (h : e ∈ B) :
    sector B x e = x*mass B x + (x⁻¹-x)*occupancy B x e := by
  let T := B.erase e
  have he : e ∉ T := Finset.notMem_erase _ _
  have eq : insert e T = B := Finset.insert_erase h
  rw [← eq]
  change sector (insert e T) x e = x*sector (insert e T) x (aligned n) + (x⁻¹-x)*occupancy (insert e T) x e
  have self : exchange e e = aligned n := by funext i; simp [exchange,aligned]
  have zero : exchange e (aligned n) = e := by funext i; simp [exchange,aligned]
  rw [sectorInsert _ _ _ _ he, sectorInsert _ _ _ _ he, self,zero,occupancyInsert _ _ _ he]
  field_simp; ring

def readout (m : ℕ) (x : ℝ) (A : Finset (Spin n)) := (m:ℝ)*x+(x⁻¹-x)*A.card

private theorem totalOccupancy (B : Finset (Spin n)) (x : ℝ) :
    ∑ e ∈ B, occupancy B x e = ∑ A ∈ B.powerset, (A.card:ℝ)*evenWeight x A := by
  simp only [occupancy, Finset.sum_comm (s := B) (t := B.powerset)]
  apply Finset.sum_congr rfl
  intro A hA
  rw [← Finset.sum_filter]
  have eq : B.filter (· ∈ A) = A := by
    ext e; exact ⟨fun he => (Finset.mem_filter.mp he).2,
      fun he => Finset.mem_filter.mpr ⟨Finset.mem_powerset.mp hA he,he⟩⟩
  simp [eq]

private theorem sumReadout (B : Finset (Spin n)) (x : ℝ) (hx : x ≠ 0) :
    ∑ e ∈ B, sector B x e = ∑ A ∈ B.powerset, evenWeight x A * readout B.card x A := by
  rw [Finset.sum_congr rfl (fun e he => edgeReadout x hx he), Finset.sum_add_distrib,
    Finset.sum_const, nsmul_eq_mul, ← Finset.mul_sum,totalOccupancy]
  simp only [readout,mul_add, Finset.sum_add_distrib]
  change (B.card:ℝ)*(x*(∑ A ∈ B.powerset, evenWeight x A)) + _ = _
  congr 1
  · rw [← Finset.sum_mul]; ring
  · rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro A _
    ring

theorem tanhPositive {β : ℝ} (hβ : 0 < β) : 0 < Real.tanh β := by
  rw [Real.tanh_eq_sinh_div_cosh]
  exact div_pos (Real.sinh_pos_iff.mpr hβ) (Real.cosh_pos _)

/-- Theorem 12's even-subgraph readout gives the exact negative quantum mean energy
at every positive β on the zero-field, unit-coupling ferromagnetic comparison graph. -/
theorem thermalReadout (g : Glass n) {β : ℝ} (hβ : 0 < β) :
    let x := Real.tanh β;
    -g.ferro.quantumThermal β =
      (∑ A ∈ g.bonds.powerset, evenWeight x A * readout g.bonds.card x A) / mass g.bonds x := by
  intro x
  exact (energySectors g β).trans (congrArg (· / mass g.bonds x)
    (sumReadout g.bonds x (tanhPositive hβ).ne'))

theorem readoutBounds {B : Finset (Spin n)} {x : ℝ} (hx : 0 < x) (h₁ : x ≤ 1)
    {A : Finset (Spin n)} (hA : A ⊆ B) :
    (B.card:ℝ)*x ≤ readout B.card x A ∧ readout B.card x A ≤ B.card/x := by
  have t : 0 ≤ x⁻¹-x := by
    have := (one_le_inv₀ hx).mpr h₁
    linarith
  have m : (A.card:ℝ) ≤ B.card := by exact_mod_cast Finset.card_le_card hA
  constructor
  · exact le_add_of_nonneg_right (mul_nonneg t (by positivity))
  · change (B.card:ℝ)*x+(x⁻¹-x)*A.card ≤ _
    rw [div_eq_mul_inv]; nlinarith [mul_le_mul_of_nonneg_left m t]

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
