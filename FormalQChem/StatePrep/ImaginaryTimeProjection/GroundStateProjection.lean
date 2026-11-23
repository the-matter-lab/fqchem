module

public import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic

/-!
# Imaginary-time spectral filtering

In a finite eigenbasis, shifting the generator by the ground energy leaves the
normalized state invariant. Its ground amplitudes then stay fixed before normalization,
and the excited amplitudes acquire real exponential factors. See
[Motta et al., Nature Physics 16 (2020)](https://doi.org/10.1038/s41567-019-0704-4).
-/

@[expose] public section
noncomputable section

namespace FormalQChem.StatePrep.ImaginaryTimeProjection

open Filter
open scoped Topology

/-- The ground eigenspace has dimension g and the excited sector dimension e.
An excitation energy is measured relative to the common ground energy. -/
structure SpectralData (g e : ℕ) where
  ground : Fin g → ℂ
  excited : Fin e → ℂ
  excitation : Fin e → ℝ
  gap : ℝ
  gap_pos : 0 < gap
  gap_le : ∀ i, gap ≤ excitation i
  overlap_pos : 0 < ∑ i, Complex.normSq (ground i)

variable {g e : ℕ} (S : SpectralData g e)

def groundMass := ∑ i, Complex.normSq (S.ground i)

def filteredExcited (τ : ℝ) (i : Fin e) :=
  (Real.exp (-τ * S.excitation i) : ℂ) * S.excited i

def excitedMass (τ : ℝ) := ∑ i, Complex.normSq (filteredExcited S τ i)

def totalMass (τ : ℝ) := groundMass S + excitedMass S τ

/-- The coefficients of exp(-τ(H-E₀))ψ divided by its Hilbert norm. -/
def state (τ : ℝ) (i : Fin g ⊕ Fin e) : ℂ :=
  Sum.elim S.ground (filteredExcited S τ) i / (Real.sqrt (totalMass S τ) : ℂ)

/-- Ground-subspace Born probability of the normalized state. -/
def fidelity (τ : ℝ) := ∑ i, Complex.normSq (state S τ (.inl i))

/-- Expectation of H-E₀ in the normalized filtered state. -/
def energyExcess (τ : ℝ) := ∑ i, S.excitation i * Complex.normSq (state S τ (.inr i))

def Normalization : Prop := ∀ τ, (∑ i, Complex.normSq (state S τ i)) = 1

/-- The excited-sector probability is bounded by its initial odds times exp(-2 Δ τ). -/
def ProjectionBound : Prop := ∀ τ, 0 ≤ τ →
  0 ≤ 1 - fidelity S τ ∧
    1 - fidelity S τ ≤ excitedMass S 0 / groundMass S * Real.exp (-(2 * S.gap) * τ)

def ProjectionLimit : Prop := Tendsto (fidelity S) atTop (𝓝 1)

/-- With spectral bandwidth W, the energy excess obeys the same exponential rate. -/
def EnergyBound : Prop := ∀ W, 0 ≤ W → (∀ i, S.excitation i ≤ W) → ∀ τ, 0 ≤ τ →
  0 ≤ energyExcess S τ ∧ energyExcess S τ ≤
    W * (excitedMass S 0 / groundMass S * Real.exp (-(2 * S.gap) * τ))

/-- The expected energy converges to the common ground energy. -/
def EnergyLimit : Prop := Tendsto (energyExcess S) atTop (𝓝 0)

private theorem excited_nonneg (τ : ℝ) : 0 ≤ excitedMass S τ :=
  Finset.sum_nonneg fun _ _ => Complex.normSq_nonneg _

private theorem total_pos (τ : ℝ) : 0 < totalMass S τ :=
  add_pos_of_pos_of_nonneg S.overlap_pos (excited_nonneg S τ)

private theorem bornWeight (τ : ℝ) (i : Fin g ⊕ Fin e) :
    Complex.normSq (state S τ i) =
      Complex.normSq (Sum.elim S.ground (filteredExcited S τ) i) / totalMass S τ := by
  simp [state, Complex.normSq_ofReal, Real.mul_self_sqrt (total_pos S τ).le]

theorem normalization : Normalization S := by
  intro τ
  simp_rw [bornWeight]
  rw [← Finset.sum_div, Fintype.sum_sum_type]
  exact div_self (total_pos S τ).ne'

private theorem infidelity (τ : ℝ) : 1 - fidelity S τ = excitedMass S τ / totalMass S τ := by
  simp only [fidelity, bornWeight, Sum.elim_inl, ← Finset.sum_div]
  change 1 - groundMass S / totalMass S τ = _
  field_simp [(total_pos S τ).ne']
  simp [totalMass]

private theorem excitedBound (τ : ℝ) (ht : 0 ≤ τ) :
    excitedMass S τ ≤ excitedMass S 0 * Real.exp (-(2 * S.gap) * τ) := by
  simp only [excitedMass, Finset.sum_mul, filteredExcited, neg_zero, zero_mul, Real.exp_zero,
    Complex.ofReal_one, one_mul, Complex.normSq_mul, Complex.normSq_ofReal]
  apply Finset.sum_le_sum
  intro i _
  rw [← Real.exp_add, mul_comm]
  apply mul_le_mul_of_nonneg_left _ (Complex.normSq_nonneg _)
  apply Real.exp_le_exp.mpr
  nlinarith [mul_le_mul_of_nonneg_right (S.gap_le i) ht]

theorem projectionBound : ProjectionBound S := by
  intro τ ht
  have hground : 0 < groundMass S := S.overlap_pos
  rw [infidelity]
  refine ⟨div_nonneg (excited_nonneg S τ) (total_pos S τ).le, ?_⟩
  calc
    _ ≤ excitedMass S τ / groundMass S :=
      div_le_div_of_nonneg_left (excited_nonneg S τ) hground (by
        unfold totalMass
        exact le_add_of_nonneg_right (excited_nonneg S τ))
    _ ≤ (excitedMass S 0 * Real.exp (-(2 * S.gap) * τ)) / groundMass S := by
      gcongr
      exact excitedBound S τ ht
    _ = _ := by ring

private theorem boundTendstoZero :
    Tendsto (fun τ : ℝ => excitedMass S 0 / groundMass S * Real.exp (-(2 * S.gap) * τ))
      atTop (𝓝 0) := by
  have hdecay : Tendsto (fun τ : ℝ => Real.exp (-(2 * S.gap) * τ)) atTop (𝓝 0) :=
    Real.tendsto_exp_atBot.comp (tendsto_id.const_mul_atTop_of_neg (neg_neg_of_pos (by
      have := S.gap_pos
      positivity)))
  have hscaled := hdecay.const_mul (excitedMass S 0 / groundMass S)
  rw [mul_zero] at hscaled
  exact hscaled

theorem projectionLimit : ProjectionLimit S := by
  have hinf : Tendsto (fun τ => 1 - fidelity S τ) atTop (𝓝 0) :=
    tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds (boundTendstoZero S)
      ((eventually_ge_atTop 0).mono fun τ ht => (projectionBound S τ ht).1)
      ((eventually_ge_atTop 0).mono fun τ ht => (projectionBound S τ ht).2)
  simpa [ProjectionLimit] using hinf.const_sub 1

theorem energyBound : EnergyBound S := by
  intro W hW cap τ ht
  have nonneg (i : Fin e) := S.gap_pos.le.trans (S.gap_le i)
  refine ⟨Finset.sum_nonneg (fun i _ => mul_nonneg (nonneg i) (Complex.normSq_nonneg _)), ?_⟩
  calc
    energyExcess S τ ≤ ∑ i, W * Complex.normSq (state S τ (.inr i)) :=
      Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_right (cap i) (Complex.normSq_nonneg _)
    _ = W * (1 - fidelity S τ) := by
      simp only [infidelity, bornWeight, Sum.elim_inr, ← Finset.mul_sum, ← Finset.sum_div, excitedMass]
    _ ≤ _ := mul_le_mul_of_nonneg_left (projectionBound S τ ht).2 hW

theorem energyLimit : EnergyLimit S := by
  let W := ∑ i, S.excitation i
  have he (i : Fin e) := S.gap_pos.le.trans (S.gap_le i)
  have hW : 0 ≤ W := Finset.sum_nonneg fun i _ => he i
  have cap (i : Fin e) : S.excitation i ≤ W :=
    Finset.single_le_sum (fun j _ => he j) (Finset.mem_univ i)
  have hscaled := (boundTendstoZero S).const_mul W
  rw [mul_zero] at hscaled
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hscaled
    ((eventually_ge_atTop 0).mono fun τ ht => (energyBound S W hW cap τ ht).1)
    ((eventually_ge_atTop 0).mono fun τ ht => (energyBound S W hW cap τ ht).2)

end FormalQChem.StatePrep.ImaginaryTimeProjection
