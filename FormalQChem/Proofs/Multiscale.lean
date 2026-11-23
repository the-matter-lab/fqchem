module

public import FormalQChem.Theorems.Multiscale
public import Mathlib.Tactic.Ring
public import Mathlib.Tactic.Linarith

@[expose] public section

namespace FormalQChem.Multiscale

theorem layeredForce : LayeredForce := by
  intro full high low x f h l hf hh hl
  have d := (hf.add hh).sub hl
  convert d using 1
  · rfl
  · ring

theorem frozenDensityDerivative : FrozenDensityDerivative := by
  intro total active frozen t vt va ht ha
  exact ((ht.sub ha).sub_const frozen)

theorem frozenSearch {D : Type*} [Add D] (E : D → EReal) (valid active : Set D) (b : D) :
    FrozenSearch E valid active b := by
  intro feasible
  dsimp only
  have bound : (⨅ ρ : valid, E ρ.val) ≤ ⨅ a : active, E (a.val + b) :=
    le_iInf fun a => iInf_le (fun ρ : valid => E ρ.val) ⟨a.val + b, feasible a.val a.property⟩
  refine ⟨bound, fun a ha eq => le_antisymm ?_ bound⟩
  exact (iInf_le (fun r : active => E (r.val + b)) ⟨a, ha⟩).trans_eq eq

theorem pairReconstruction : PairReconstruction := by
  intro n mono dimer interaction pair
  unfold fragmentEnergy
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j hj
  rw [pair i j (Finset.mem_filter.mp hj).2]
  ring

theorem deltaLearningGap : DeltaLearningGap := by
  intro X hi lo predict x y ex ey hx hy
  have h := abs_sub (predict y - (hi y - lo y)) (predict x - (hi x - lo x))
  rw [show (lo y + predict y - (lo x + predict x) - (hi y - hi x)) =
    (predict y - (hi y - lo y)) - (predict x - (hi x - lo x)) by ring]
  exact h.trans ((add_le_add hy hx).trans_eq (add_comm ey ex))

theorem zwanzig (ι : Type*) [Fintype ι] [Nonempty ι] : Zwanzig ι := by
  intro β _ U V
  have positive (W : ι → ℝ) : 0 < partition β W :=
    Finset.sum_pos (fun i _ => Real.exp_pos _) Finset.univ_nonempty
  have term (i : ι) : Real.exp (-β * U i) / partition β U * Real.exp (-β * (V i - U i)) =
      Real.exp (-β * V i) / partition β U := by
    rw [div_mul_eq_mul_div, ← Real.exp_add]
    congr 2
    ring
  simp_rw [term]
  rw [← Finset.sum_div, ← partition]
  rw [Real.log_div (positive V).ne' (positive U).ne']
  unfold freeEnergy
  ring

theorem barrierRateError : BarrierRateError := by
  intro A β exact approx ε hA hβ bound
  dsimp only
  obtain ⟨hl, hu⟩ := abs_le.mp bound
  have ratio : A * Real.exp (-β * approx) / (A * Real.exp (-β * exact)) =
      Real.exp (-β * (approx - exact)) := by
    rw [mul_div_mul_left _ _ hA.ne', ← Real.exp_sub]
    congr 1
    ring
  rw [ratio]
  constructor <;> apply Real.exp_le_exp.mpr <;> nlinarith [mul_le_mul_of_nonneg_left hu hβ,
    mul_le_mul_of_nonneg_left hl hβ]

end FormalQChem.Multiscale
