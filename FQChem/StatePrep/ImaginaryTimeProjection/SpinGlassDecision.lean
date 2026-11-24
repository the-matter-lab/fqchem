module

public import FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
public import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic

/-! # Deciding the spin-glass ground threshold from a thermal energy estimate

[Troyer and Wiese, pp. 3–4, Eqs. (9)–(11) and note 9](https://doi.org/10.1103/PhysRevLett.94.170201).
Energies below are measured in units of J. A three-dimensional nearest-neighbour
graph has at most 3N undirected bonds. The proof uses this edge bound, the 2ᴺ
configuration count, and the integer spacing of the energies.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
variable {n : ℕ}

private theorem minimum (g : Glass n) : ∃ s, ∀ x, g.energy s ≤ g.energy x := by
  obtain ⟨s,_,hs⟩ := Finset.exists_min_image (Finset.univ : Finset (Spin n)) g.energy Finset.univ_nonempty
  exact ⟨s,fun x => hs x (Finset.mem_univ _)⟩

def relativeWeight (g : Glass n) (β : ℝ) (s x : Spin n) :=
  Real.exp (-β * ((g.energy x : ℝ) - g.energy s))

private theorem weightSum (g : Glass n) (β : ℝ) (s : Spin n) :
    1 ≤ ∑ x, relativeWeight g β s x := by
  have h := Finset.single_le_sum (s := Finset.univ) (f := relativeWeight g β s)
    (fun x _ => (Real.exp_pos _).le) (Finset.mem_univ s)
  simpa [relativeWeight] using h

/-- Express the excess thermal mean as the Gibbs mean excitation above any reference configuration. -/
theorem shiftedThermal (g : Glass n) (β : ℝ) (s : Spin n) :
    g.classicalThermal β = (g.energy s : ℝ) +
      (∑ x, ((g.energy x : ℝ)-g.energy s) * relativeWeight g β s x) / ∑ x, relativeWeight g β s x := by
  let E := fun x => (g.energy x : ℝ)
  let w := relativeWeight g β s
  have point (x) : Real.exp (-β * E x) = w x * Real.exp (-β * E s) := by
    dsimp only [w, relativeWeight, E]
    rw [← Real.exp_add]; congr 1; ring
  have z : 0 < ∑ x, w x := by linarith [weightSum g β s]
  change (∑ x, E x * Real.exp (-β * E x)) / (∑ x, Real.exp (-β * E x)) = _
  have num : (∑ x, E x * Real.exp (-β * E x)) = (∑ x, E x*w x) * Real.exp (-β*E s) := by
    rw [Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro x _
    rw [point x, mul_assoc]
  have den : (∑ x, Real.exp (-β*E x)) = (∑ x, w x)*Real.exp (-β*E s) := by
    rw [Finset.sum_mul]; exact Finset.sum_congr rfl (fun x _ => point x)
  rw [num, den]
  rw [mul_div_mul_right _ _ (Real.exp_ne_zero _)]
  change (∑ x, E x * w x) / (∑ x, w x) =
    E s + (∑ x, (E x-E s)*w x) / ∑ x, w x
  simp only [sub_mul, Finset.sum_sub_distrib, ← Finset.mul_sum]
  field_simp
  ring

/-- With integer level spacing and excitation range at most D, finite-temperature
excess above a ground configuration is strictly below 2ᴺ D exp(−β). -/
theorem excitationEstimate (g : Glass n) {β D : ℝ} (beta : 0 ≤ β) (hD : 0<D)
    (s : Spin n) (hs : ∀ x, g.energy s ≤ g.energy x)
    (range : ∀ x, (g.energy x : ℝ)-g.energy s ≤ D) :
    (g.energy s : ℝ) ≤ g.quantumThermal β ∧
      g.quantumThermal β < g.energy s + (2:ℝ)^n*D*Real.exp (-β) := by
  let diff := fun x => ((g.energy x : ℝ)-g.energy s)
  let w := relativeWeight g β s
  have nonneg (x) : 0 ≤ diff x := sub_nonneg.mpr (by exact_mod_cast hs x)
  have each (x) : diff x * w x ≤ D*Real.exp (-β) := by
    by_cases he : g.energy x = g.energy s
    · simp [diff, he, show 0 ≤ D*Real.exp (-β) by positivity]
    · have one : 1 ≤ diff x := by
        have hh := hs x
        have h : (1:ℤ) ≤ g.energy x - g.energy s := by omega
        dsimp [diff]; exact_mod_cast h
      have hw : w x ≤ Real.exp (-β) := Real.exp_le_exp.mpr (by change -β * diff x ≤ -β; nlinarith [mul_nonneg beta (sub_nonneg.mpr one)])
      exact mul_le_mul (range x) hw (Real.exp_pos _).le hD.le
  have strict : (∑ x, diff x * w x) < ∑ _ : Spin n, D*Real.exp (-β) := by
    apply Finset.sum_lt_sum (fun x _ => each x)
    refine ⟨s,Finset.mem_univ _,?_⟩
    simp only [diff, sub_self, zero_mul]
    positivity
  simp only [Finset.sum_const, Finset.card_univ, Spin, Fintype.card_fun, Fintype.card_bool,
    Fintype.card_fin, nsmul_eq_mul, Nat.cast_pow, Nat.cast_ofNat, ← mul_assoc] at strict
  have z := weightSum g β s
  have zpos : 0 < ∑ x, w x := by linarith
  rw [thermal_identity, shiftedThermal]
  change _ ≤ _ + (∑ x, diff x*w x)/(∑ x, w x) ∧ _ + (∑ x, diff x*w x)/(∑ x, w x) < _
  constructor
  · exact le_add_of_nonneg_right (div_nonneg (Finset.sum_nonneg fun x _ => mul_nonneg (nonneg x) (Real.exp_pos _).le) zpos.le)
  · apply add_lt_add_right
    apply (div_lt_iff₀ zpos).mpr
    exact strict.trans_le (le_mul_of_one_le_right (by positivity) z)

theorem energyRange (g : Glass n) (s x : Spin n) : (g.energy x : ℝ)-g.energy s ≤ 2*g.bonds.card := by
  have hx : |(g.energy x : ℝ)| ≤ g.bonds.card := by exact_mod_cast (energy_bound g x)
  have hy : |(g.energy s : ℝ)| ≤ g.bonds.card := by exact_mod_cast (energy_bound g s)
  linarith [(abs_le.mp hx).2, (abs_le.mp hy).1]

/-- At β ≥ N log 2 + log(12N), the expected thermal excitation is strictly less
than half an energy unit. The estimate is valid for any glass with at most 3N bonds. -/
theorem coldEnergy (g : Glass n) (hn : 0<n) (hedges : g.bonds.card ≤ 3*n) (β : ℝ)
    (cold : n*Real.log 2 + Real.log (12*n) ≤ β) (s : Spin n) (hs : ∀ x, g.energy s ≤ g.energy x) :
    (g.energy s : ℝ) ≤ g.quantumThermal β ∧ g.quantumThermal β < g.energy s + 1/2 := by
  have nr : 0 < (n:ℝ) := by exact_mod_cast hn
  have edges : (g.bonds.card:ℝ) ≤ 3*n := by exact_mod_cast hedges
  have cost : (2:ℝ)^n * (12*n) ≤ Real.exp β := calc
    _ = Real.exp (n*Real.log 2 + Real.log (12*n)) := by
      rw [Real.exp_add, Real.exp_nat_mul, Real.exp_log (by norm_num : (0:ℝ)<2),
        Real.exp_log (by positivity)]
    _ ≤ _ := Real.exp_le_exp.mpr cold
  have beta : 0 ≤ β := by
    apply le_trans _ cold
    have nn : 1 ≤ 12*(n:ℝ) := by exact_mod_cast (by omega : 1 ≤ 12*n)
    exact add_nonneg (mul_nonneg (Nat.cast_nonneg _) (Real.log_nonneg (by norm_num))) (Real.log_nonneg nn)
  obtain ⟨lo,hi⟩ := excitationEstimate g beta (D := 6*n) (by positivity) s hs
    (fun x => (energyRange g s x).trans (by linarith))
  have small : (2:ℝ)^n*(6*n)*Real.exp (-β) ≤ 1/2 := by
    rw [Real.exp_neg, ← div_eq_mul_inv, div_le_iff₀ (Real.exp_pos _)]
    linarith
  exact ⟨lo,hi.trans_le (by linarith)⟩

def feasible (g : Glass n) (t : ℤ) := ∃ x, g.energy x ≤ t

/-- The yes and no ranges are separated by half an energy unit. Equality in the
no bound is possible (for example, a constant energy landscape). -/
theorem thermalSeparation (g : Glass n) (hn : 0<n) (hedges : g.bonds.card ≤ 3*n) (β : ℝ)
    (cold : n*Real.log 2 + Real.log (12*n) ≤ β) (t : ℤ) :
    (feasible g t → g.quantumThermal β < t+1/2) ∧ (¬feasible g t → t+1 ≤ g.quantumThermal β) := by
  obtain ⟨s,hs⟩ := minimum g
  obtain ⟨hl,hu⟩ := coldEnergy g hn hedges β cold s hs
  constructor
  · rintro ⟨x,hx⟩
    have h : (g.energy s : ℝ) ≤ t := by exact_mod_cast (hs x).trans hx
    linarith
  · intro no
    have h : t < g.energy s := lt_of_not_ge (fun h => no ⟨s,h⟩)
    have h' : t+1 ≤ g.energy s := by omega
    exact (show (t:ℝ)+1 ≤ g.energy s by exact_mod_cast h').trans hl

/-- The thermal observable for a common physical interaction scale J. -/
def physicalMean (g : Glass n) (J β : ℝ) :=
  let H := J • g.hamiltonian
  (H * NormedSpace.exp ((-β) • H)).trace / (NormedSpace.exp ((-β) • H)).trace

theorem physicalScaling (g : Glass n) (J β : ℝ) :
    physicalMean g J β = J*g.quantumThermal (β*J) := by
  simp [physicalMean, Glass.quantumThermal, smul_smul, Matrix.trace_smul, mul_div_assoc]

/-- With couplings 0, ±J and threshold tJ, the inverse-temperature promise is on βJ
and the separating window has width J/2. -/
theorem physicalSeparation (g : Glass n) (hn : 0<n) (hedges : g.bonds.card ≤ 3*n)
    (J β : ℝ) (hJ : 0<J) (cold : n*Real.log 2 + Real.log (12*n) ≤ β*J) (t : ℤ) :
    (feasible g t → physicalMean g J β < J*t+J/2) ∧
      (¬feasible g t → J*t+J ≤ physicalMean g J β) := by
  rw [physicalScaling]
  obtain ⟨yes,no⟩ := thermalSeparation g hn hedges (β*J) cold t
  constructor
  · intro h
    nlinarith only [mul_lt_mul_of_pos_left (yes h) hJ]
  · intro h
    nlinarith only [mul_le_mul_of_nonneg_left (no h) hJ.le]

/-- Polynomial inverse temperature 13N suffices in units J=1. -/
theorem polynomialTemperature (n : ℕ) (hn : 0<n) :
    (n:ℝ)*Real.log 2 + Real.log (12*n) ≤ 13*n := by
  have h2 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
  have hN := Real.log_le_sub_one_of_pos (by positivity : (0:ℝ)<12*n)
  nlinarith [mul_le_mul_of_nonneg_left h2 (Nat.cast_nonneg (α:=ℝ) n)]

end FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
