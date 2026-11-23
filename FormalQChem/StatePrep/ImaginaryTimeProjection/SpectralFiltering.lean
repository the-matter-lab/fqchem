module

public import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic

/-! # Repeated diagonal spectral filters -/

@[expose] public section
noncomputable section

namespace FormalQChem.StatePrep.ImaginaryTimeProjection

open Filter
open scoped Topology

variable {g e : ℕ}

/-- After k diagonal filter steps, each amplitude acquires the k-th power of its gain. -/
def sectorMass {d : ℕ} (c gain : Fin d → ℂ) (k : ℕ) :=
  ∑ i, Complex.normSq (gain i ^ k * c i)

/-- Spectral gains can be complex. A common nonzero gain on a degenerate ground
space preserves its direction. The contraction q bounds the ratio of squared gains.
Polynomial filters are one application. See [Lin and Tong (2020)](https://doi.org/10.22331/q-2020-11-11-361). -/
structure DiagonalFilter (g e : ℕ) where
  ground : Fin g → ℂ
  excited : Fin e → ℂ
  overlap : 0 < ∑ i, Complex.normSq (ground i)
  targetGain : ℂ
  target_ne_zero : targetGain ≠ 0
  gain : Fin e → ℂ
  q : ℝ
  q_nonneg : 0 ≤ q
  q_lt_one : q < 1
  contraction : ∀ i, Complex.normSq (gain i) ≤ q * Complex.normSq targetGain

def odds (F : DiagonalFilter g e) (k : ℕ) :=
  sectorMass F.excited F.gain k / sectorMass F.ground (fun _ => F.targetGain) k

def GeometricFiltering (F : DiagonalFilter g e) : Prop :=
  (∀ k, 0 ≤ odds F k ∧ odds F k ≤ F.q ^ k * odds F 0) ∧
  Tendsto (odds F) atTop (𝓝 0) ∧
  Tendsto (fun k => 1 / (1 + odds F k)) atTop (𝓝 1)

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
