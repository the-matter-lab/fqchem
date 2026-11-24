import FQChemForShor.OrderFinding
import FQChem.Complexity.FactoringReduction

/-! # From the compiled quantum experiment to a verified factor

Every measured clock output is decoded and its gcd candidate checked. The
probability below counts precisely those outputs that produce a proper factor.
The circuit runs on the all-zero basis vector. The random choice of base and
the quantum measurement are both included in the final lower bound.
-/

namespace FQChem.Complexity.QuantumFactoring

open Shor Shor.Model Shor.Model.QuantumLib OrderFinding FactoringReduction

/-- Weight of a clock outcome in the compiled finite-matrix experiment. -/
noncomputable def mass (inst : ShorOrderFindingInstance) (o : ℕ) : ℝ :=
  let p := program inst
  let dim := maxQubit p.circuit
  cnorm2 (proj dim p.output o * (denote dim p.circuit * e dim (zeroIdx dim)))

/-- Probability of detecting and returning a proper factor from one shot. -/
noncomputable def factorProbability (inst : ShorOrderFindingInstance) : ℝ :=
  let Q := ASize (program inst).output
  ∑ o : Fin Q, if (extractFactor inst.N inst.a
      (OrderFindingDecoder.decode inst.N inst.a o.val Q).order).isSome then mass inst o.val else 0

private theorem mass_nonneg (inst : ShorOrderFindingInstance) (o : ℕ) : 0 ≤ mass inst o := by
  unfold mass cnorm2
  positivity

private theorem factorProbability_nonneg (inst : ShorOrderFindingInstance) : 0 ≤ factorProbability inst := by
  apply Finset.sum_nonneg
  intro o _
  split <;> simp [mass_nonneg]

variable {N : ℕ} [Fact (1 < N)]

/-- A unit represented as a valid order-finding input. -/
def instanceOf (u : (ZMod N)ˣ) : ShorOrderFindingInstance :=
  ⟨u.val.val, N, ⟨ZMod.val_pos.mpr u.ne_zero, ZMod.val_lt _⟩, ZMod.val_coe_unit_coprime u⟩

private theorem unitOrder (u : (ZMod N)ˣ) :
    ord (instanceOf u).a N (instanceOf u).coprime = orderOf u := by
  unfold ord instanceOf
  congr 1
  apply Units.ext
  simp

private theorem acceptedOrder (u : (ZMod N)ˣ) (f : ℕ)
    (hf : extractFactor N u.val.val (orderOf u) = some f) :
    κ / (2 * Real.log ((Nat.log2 N : ℝ)+1)) ≤ factorProbability (instanceOf u) := by
  let inst := instanceOf u
  apply (programRecovery inst).trans
  unfold qlSuccess qlSuccessOn factorProbability
  apply Finset.sum_le_sum
  intro o _
  let Q := ASize (program inst).output
  let d := (OrderFindingDecoder.decode N u.val.val o.val Q).order
  have decoder := executableDecoder inst Q o.val (by unfold Q ASize; positivity)
  have eqr : ord inst.a inst.N inst.coprime = orderOf u := unitOrder u
  by_cases hd : d = orderOf u
  · have hpost := decoder.symm.trans hd
    change (if OF_post budget _ o.val Q = ord inst.a inst.N inst.coprime then 1 else 0) *
        mass inst o.val ≤ (if (extractFactor N u.val.val d).isSome then mass inst o.val else 0)
    rw [eqr, ite_eq_left hpost, hd, hf]
    simp
  · have hpost : OF_post budget (fun d => decide (inst.a^d % inst.N = 1)) o.val Q ≠ ord inst.a inst.N inst.coprime := by
      rw [← decoder, eqr]; exact hd
    change (if OF_post budget _ o.val Q = ord inst.a inst.N inst.coprime then 1 else 0) *
        mass inst o.val ≤ (if (extractFactor N u.val.val d).isSome then mass inst o.val else 0)
    rw [ite_eq_right hpost, zero_mul]
    split <;> simp [mass_nonneg]

/-- For a good base, the gcd of the measured half-order power yields a factor
with at least the certified probability of decoding the exact order. -/
theorem goodBaseRecovery (u : (ZMod N)ˣ) (hg : GoodOrder u) :
    κ / (2 * Real.log ((Nat.log2 N : ℝ)+1)) ≤ factorProbability (instanceOf u) := by
  obtain ⟨f,hf,_,_,_⟩ := extractFactor_of_good Fact.out u hg
  exact acceptedOrder u f hf

/-- A uniformly random unit followed by the compiled quantum circuit and the
executable gcd routine yields a proper factor with the stated probability. -/
theorem uniformFactorProbability (ho : Odd N) :
    (1 - 1/(2:ℝ)^(N.primeFactors.card-1)) * (κ / (2*Real.log ((Nat.log2 N : ℝ)+1))) ≤
      (∑ u : (ZMod N)ˣ, factorProbability (instanceOf u)) / Nat.card (ZMod N)ˣ := by
  classical
  let U := (ZMod N)ˣ
  let good := Finset.univ.filter (fun u : U => GoodOrder u)
  let p := κ / (2*Real.log ((Nat.log2 N : ℝ)+1))
  have hN : 1 < N := Fact.out
  have hlog : 0 < Nat.log2 N := by rw [Nat.log2_eq_log_two]; exact Nat.log_pos (by decide) hN
  have hp : 0 ≤ p := by
    have := Real.log_pos (by exact_mod_cast (show 1 < Nat.log2 N + 1 by omega) : (1:ℝ) < (Nat.log2 N : ℝ)+1)
    dsimp [p]; have := κ_pos; positivity
  have frac : 1 - 1/(2:ℝ)^(N.primeFactors.card-1) ≤ (Nat.card {u : U // GoodOrder u} : ℝ) / Nat.card U := by
    have h := (Rat.cast_le (K := ℝ)).mpr (goodUnitFraction N hN ho)
    push_cast at h
    exact h
  have card : Nat.card {u : U // GoodOrder u} = good.card := by simp [good, Nat.card_eq_fintype_card, Fintype.card_subtype]
  change _ ≤ _ / (Nat.card U : ℝ)
  calc
    _ ≤ ((good.card : ℝ)/Nat.card U)*p := by rw [← card]; exact mul_le_mul_of_nonneg_right frac hp
    _ = (∑ _u ∈ good, p)/(Nat.card U : ℝ) := by simp; ring
    _ ≤ _ := by
      apply div_le_div_of_nonneg_right _ (by positivity)
      apply (Finset.sum_le_sum (g := fun u => factorProbability (instanceOf u)) _).trans
        (Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ good) (fun u _ _ => factorProbability_nonneg _))
      intro u hu
      exact goodBaseRecovery u (Finset.mem_filter.mp hu).2

private def unitBase (x : Fin (N-1)) (hc : (x.val+1).Coprime N) : (ZMod N)ˣ :=
  ZMod.unitOfCoprime _ hc

omit [Fact (1 < N)] in
private theorem representative (x : Fin (N-1)) (hc : (x.val+1).Coprime N) :
    (unitBase x hc).val.val = x.val+1 := by
  have hx := x.isLt
  exact ZMod.val_natCast_of_lt (by omega)

/-- One accepted fair-bit word chooses a positive base; a nonunit returns its
gcd immediately and a unit runs the compiled quantum experiment. -/
noncomputable def positiveBaseTrial (x : Fin (N-1)) : ℝ :=
  if hc : (x.val+1).Coprime N then factorProbability (instanceOf (unitBase x hc)) else 1

private noncomputable def exactOrder (N a : ℕ) : ℕ :=
  if hc : a.Coprime N then orderOf (ZMod.unitOfCoprime a hc) else 0

/-- Success with an ordinary uniformly chosen positive base. The uniform
sampler covers all integers from 1 through N−1, with no unit-membership oracle. -/
theorem positiveBaseFactorProbability (ho : Odd N) :
    (1 - 1/(2:ℝ)^(N.primeFactors.card-1)) * (κ / (2*Real.log ((Nat.log2 N : ℝ)+1))) ≤
      (∑ x : Fin (N-1), positiveBaseTrial x) / (N-1 : ℕ) := by
  classical
  let k := N.primeFactors.card-1
  let p := κ / (2*Real.log ((Nat.log2 N : ℝ)+1))
  let S := Finset.univ.filter (fun x : Fin (N-1) => (extractFactor N (x.val+1) (exactOrder N (x.val+1))).isSome)
  have hN : 1 < N := Fact.out
  have hn : 0 < N.log2 := by rw [Nat.log2_eq_log_two]; exact Nat.log_pos (by decide) hN
  have hlog := Real.log_le_log (by norm_num : (0:ℝ)<2) (show (2:ℝ)≤(N.log2:ℝ)+1 by exact_mod_cast (show 2 ≤ N.log2+1 by omega))
  have hL : (1:ℝ) ≤ 2*Real.log ((N.log2:ℝ)+1) := by linarith [Real.log_two_gt_d9]
  have hp : 0 ≤ p := by dsimp [p]; exact div_nonneg κ_pos.le (by linarith)
  have hp1 : p ≤ 1 := by
    apply (div_le_one (by linarith)).mpr
    apply le_trans _ hL
    unfold κ
    apply (div_le_one (by positivity)).mpr
    nlinarith [Real.pi_gt_three]
  have hbase (u : (ZMod N)ˣ) : exactOrder N u.val.val = orderOf u := by
    rw [exactOrder, dite_eq_left (ZMod.val_coe_unit_coprime u)]
    congr 1; apply Units.ext; simp
  have hb := randomBaseFailure N hN ho (exactOrder N) hbase
  let D := Nat.card {x : Fin (N-1) // extractFactor N (x.val+1) (exactOrder N (x.val+1)) = none}
  have cs : S.card + D = N-1 := by
    have hd : D = (Finset.univ.filter (fun x : Fin (N-1) => ¬(extractFactor N (x.val+1) (exactOrder N (x.val+1))).isSome)).card := by
      simp [D, Nat.card_eq_fintype_card,Fintype.card_subtype, Option.isSome_iff_ne_none]
    rw [hd]
    have hc := Finset.card_filter_add_card_filter_not
      (s := (Finset.univ : Finset (Fin (N-1)))) (p := fun x => (extractFactor N (x.val+1) (exactOrder N (x.val+1))).isSome = true)
    simpa [S] using hc
  have hcard : 1-1/(2:ℝ)^k ≤ (S.card:ℝ)/(N-1 : ℕ) := by
    have hbr : (2:ℝ)^k * D ≤ ((N-1:ℕ):ℝ) := by exact_mod_cast hb
    have hcr : (S.card:ℝ) + D = ((N-1:ℕ):ℝ) := by exact_mod_cast cs
    have hden : (0:ℝ)<((N-1:ℕ):ℝ) := by exact_mod_cast (show 0 < N-1 by omega)
    field_simp
    nlinarith [congrArg ((2:ℝ)^k * ·) hcr]
  have estimate (x : Fin (N-1)) (hx : x ∈ S) : p ≤ positiveBaseTrial x := by
    have good := (Finset.mem_filter.mp hx).2
    unfold positiveBaseTrial
    split
    next hc =>
      have rep := representative x hc
      rw [← rep] at good
      rw [hbase] at good
      obtain ⟨f,hf⟩ := Option.isSome_iff_exists.mp good
      exact acceptedOrder (unitBase x hc) f hf
    next => exact hp1
  calc
    _ ≤ ((S.card:ℝ) / (N-1:ℕ))*p := mul_le_mul_of_nonneg_right hcard hp
    _ = (∑ _x ∈ S, p)/(N-1:ℕ) := by simp; ring
    _ ≤ _ := by
      apply div_le_div_of_nonneg_right _ (by positivity)
      apply (Finset.sum_le_sum estimate).trans
      apply Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
      intro x _ _
      unfold positiveBaseTrial
      split <;> simp [factorProbability_nonneg]

end FQChem.Complexity.QuantumFactoring
