module

public import FormalQChem.StatePrep.ImaginaryTimeProjection.Theorems
import Mathlib.Tactic

public section
namespace FormalQChem.StatePrep.ImaginaryTimeProjection

open Filter
open scoped Topology
variable {g e : ℕ} (S : SpectralData g e)

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

theorem geometricFiltering (F : DiagonalFilter g e) : GeometricFiltering F := by
  let G := ∑ j, Complex.normSq (F.ground j)
  let X := ∑ i, Complex.normSq (F.excited i)
  let a := Complex.normSq F.targetGain
  have hG : 0 < G := F.overlap
  have ha : 0 < a := Complex.normSq_pos.mpr F.target_ne_zero
  have ground_eq (k : ℕ) : sectorMass F.ground (fun _ => F.targetGain) k = a ^ k * G := by
    simp [sectorMass, a, G, Complex.normSq_mul, Finset.mul_sum]
  have init : odds F 0 = X / G := by simp [odds, sectorMass, G, X]
  have upper (k : ℕ) :
      sectorMass F.excited F.gain k ≤ (F.q*a)^k * X := by
    simp only [sectorMass, Complex.normSq_mul, map_pow, X, Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    exact mul_le_mul_of_nonneg_right (pow_le_pow_left₀ (Complex.normSq_nonneg _) (F.contraction i) _)
      (Complex.normSq_nonneg _)
  have bound (k : ℕ) : 0 ≤ odds F k ∧ odds F k ≤ F.q ^ k * odds F 0 := by
    rw [init, odds, ground_eq]
    have hk : 0 < a^k := pow_pos ha _
    refine ⟨div_nonneg (Finset.sum_nonneg fun _ _ => Complex.normSq_nonneg _) (mul_pos hk hG).le, ?_⟩
    calc
      _ ≤ ((F.q*a)^k * X)/(a^k*G) := div_le_div_of_nonneg_right (upper k) (mul_pos hk hG).le
      _ = _ := by rw [mul_pow]; field_simp
  have decay := (tendsto_pow_atTop_nhds_zero_of_lt_one F.q_nonneg F.q_lt_one).mul_const (odds F 0)
  rw [zero_mul] at decay
  have vanish : Tendsto (odds F) atTop (𝓝 0) :=
    tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds decay
      (fun k => (bound k).1) (fun k => (bound k).2)
  refine ⟨bound, vanish, ?_⟩
  simpa only [Pi.div_def, add_zero, div_one] using (tendsto_const_nhds (x := (1 : ℝ))).div (vanish.const_add 1) (by norm_num)

end FormalQChem.StatePrep.ImaginaryTimeProjection
