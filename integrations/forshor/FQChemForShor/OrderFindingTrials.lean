import FQChemForShor.FourierOrbit
import FQChemForShor.OrderFinding

/-! # Independent repetitions of Shor's Fourier experiment

Take the smallest nonzero verified order among the measured outcomes. Its
failure probability is the mass of a finite product of independent Born laws.
-/

namespace FQChem.Complexity.OrderFindingTrials

open Shor OrderFinding FourierOrbit

/-- An executable aggregation of the measured candidate orders. -/
def selectOrder {t : ℕ} (inst : ShorOrderFindingInstance) (Q : ℕ) (o : Fin t → Fin Q) : ℕ :=
  OrderFindingDecoder.leastOrZero ((Finset.univ.image fun i =>
    (OrderFindingDecoder.decode inst.N inst.a (o i).val Q).order).filter (0 < ·))

theorem selected_if_hit {t Q : ℕ} (inst : ShorOrderFindingInstance) (o : Fin t → Fin Q)
    (hit : ∃ i, (OrderFindingDecoder.decode inst.N inst.a (o i).val Q).order =
      ord inst.a inst.N inst.coprime) : selectOrder inst Q o = ord inst.a inst.N inst.coprime := by
  classical
  obtain ⟨j,hj⟩ := hit
  have hQ : 0 < Q := (o j).isLt.trans_le' (Nat.zero_le _)
  let r := ord inst.a inst.N inst.coprime
  let D (i : Fin t) := (OrderFindingDecoder.decode inst.N inst.a (o i).val Q).order
  let S := (Finset.univ.image D).filter (0 < ·)
  have hr : 0 < r := by
    let : NeZero inst.N := ⟨by have := inst.range; omega⟩
    exact orderOf_pos _
  have mem : r ∈ S := Finset.mem_filter.mpr ⟨Finset.mem_image.mpr ⟨j,Finset.mem_univ _,hj⟩,hr⟩
  have ne : S.Nonempty := ⟨r,mem⟩
  change OrderFindingDecoder.leastOrZero S = r
  rw [OrderFindingDecoder.leastOrZero,dite_eq_left ne]
  refine le_antisymm (S.min'_le _ mem) ?_
  have hm := Finset.mem_filter.mp (S.min'_mem ne)
  obtain ⟨i,_,hi⟩ := Finset.mem_image.mp hm.1
  have hi' : 0 < D i := hi ▸ hm.2
  rw [← hi]
  change r ≤ (OrderFindingDecoder.decode _ _ _ _).order
  rw [executableDecoder inst Q _ hQ]
  unfold OF_post
  split
  next h =>
    have cand := Finset.mem_filter.mp (Finset.min'_mem _ h)
    exact ord_le_of_pow_mod_eq_one _ _ _ inst.coprime cand.2.1 (of_decide_eq_true cand.2.2)
  next h =>
    have bad := executableDecoder inst Q (o i).val hQ
    simp only [OF_post,dite_eq_right h] at bad
    exact False.elim ((Nat.ne_of_gt hi') bad)

/-- With the clock from the paper and explicit independent Born outcomes,
the probability of returning a wrong answer is at most 1/e. -/
theorem boundedErrorOrderFinding (inst : ShorOrderFindingInstance) :
    let Q := paperClock inst.N
    let r := ord inst.a inst.N inst.coprime
    let u := ZMod.unitOfCoprime inst.a ((Nat.coprime_iff_gcd_eq_one).mpr inst.coprime)
    let t := ⌈12 * Real.log ((Nat.log2 (r+1) : ℝ)+1)⌉₊
    ∑ outcomes : Fin t → Fin Q, (if selectOrder inst Q outcomes = r then 0
      else ∏ i, clockBorn u Q (outcomes i)) ≤ Real.exp (-1) := by
  classical
  let : NeZero inst.N := ⟨by have := inst.range; omega⟩
  let Q := paperClock inst.N
  let r := ord inst.a inst.N inst.coprime
  let u := ZMod.unitOfCoprime inst.a ((Nat.coprime_iff_gcd_eq_one).mpr inst.coprime)
  let t := ⌈12 * Real.log ((Nat.log2 (r+1) : ℝ)+1)⌉₊
  let hit (o : Fin Q) := (OrderFindingDecoder.decode inst.N inst.a o.val Q).order = r
  let win (o : Fin Q) := if hit o then clockBorn u Q o else 0
  let miss (o : Fin Q) := if hit o then 0 else clockBorn u Q o
  have hN : 1 < inst.N := by have := inst.range; omega
  have hQ : 0 < Q := lt_of_lt_of_le (by positivity : 0 < inst.N^2) (paperClock_bounds hN).1
  have hr : 0 < r := orderOf_pos _
  have prob (o : Fin Q) : 0 ≤ clockBorn u Q o := by unfold clockBorn; positivity
  have hm (o : Fin Q) : 0 ≤ miss o := by dsimp [miss]; split <;> simp [prob]
  have single := publishedClockRecovery inst
  have scale : (1:ℝ)/3 ≤ 4/Real.pi^2 := by
    apply (le_div_iff₀ (by positivity)).mpr
    nlinarith [Real.pi_lt_d2,Real.pi_pos,
      mul_pos (sub_pos.mpr Real.pi_lt_d2) (show 0 < 3.15 + Real.pi by positivity)]
  have lower : (Nat.totient r : ℝ)/(3*r) ≤ ∑ o, win o := by
    calc
      _ = (1/3:ℝ) * ((Nat.totient r : ℝ)/r) := by ring
      _ ≤ _ := (mul_le_mul_of_nonneg_right scale (by positivity)).trans single
  have total : ∑ o, win o + ∑ o, miss o = 1 := by
    rw [← Finset.sum_add_distrib, ← born_normalized u Q hQ]
    exact Finset.sum_congr rfl (fun o _ => by dsimp [win,miss]; split <;> simp_all)
  have fail : ∑ o, miss o ≤ 1 - (Nat.totient r : ℝ)/(3*r) := by linarith
  apply le_trans _ (independentTrialBound r hr)
  calc
    _ ≤ ∑ outcomes : Fin t → Fin Q, ∏ i, miss (outcomes i) := by
      apply Finset.sum_le_sum
      intro outcomes _
      split
      next => exact Finset.prod_nonneg (fun i _ => hm _)
      next wrong =>
        have nohit (i : Fin t) : ¬ hit (outcomes i) :=
          fun h => wrong (selected_if_hit inst outcomes ⟨i,h⟩)
        exact le_of_eq (Finset.prod_congr rfl (fun i _ => (ite_eq_right (nohit i)).symm))
    _ = (∑ o, miss o)^t := (Fintype.sum_pow miss t).symm
    _ ≤ _ := pow_le_pow_left₀ (Finset.sum_nonneg (fun o _ => hm o)) fail t

end FQChem.Complexity.OrderFindingTrials
