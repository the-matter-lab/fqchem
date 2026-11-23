module

public import FormalQChem.Multiscale.StitchingSolutions.Observables.Theorems
public import Mathlib.Tactic.Ring
public import Mathlib.Tactic.Linarith

@[expose] public section

namespace FormalQChem.Multiscale

open scoped BigOperators

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

end FormalQChem.Multiscale
