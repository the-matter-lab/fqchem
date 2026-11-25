module

public import Mathlib.Order.Hom.PowersetCard
public import Mathlib.Analysis.Convex.Birkhoff
import Mathlib.Tactic

/-! # Ensemble occupation numbers

The convex hull of the occupation vectors of N-element subsets consists exactly
of vectors with entries in [0,1] and sum N. This is the combinatorial step of
[Coleman's ensemble one-matrix theorem](https://doi.org/10.1103/RevModPhys.35.668).
-/

@[expose] public section
noncomputable section
namespace FQChem.Properties.NRepresentability

abbrev Determinant (d N : ℕ) := Set.powersetCard (Fin d) N

/-- Expected occupation of each orbital under weights on fixed-size determinants. -/
def occupations {d N : ℕ} (w : Determinant d N → ℝ) (i : Fin d) : ℝ :=
  ∑ s, if i ∈ s.val then w s else 0

private theorem columnMass {d : ℕ} (S : Finset (Fin d)) (p : Fin d → ℝ)
    (nonneg : ∀ i, 0 ≤ p i) (mass : ∑ i, p i = S.card) (i : Fin d) :
    (∑ _j ∈ S, p i / S.card) = p i := by
  by_cases empty : S.card = 0
  · have le := Finset.single_le_sum (s := Finset.univ) (fun j _ => nonneg j) (Finset.mem_univ i)
    rw [mass, empty, Nat.cast_zero] at le
    simp [le_antisymm le (nonneg i)]
  · simp [nsmul_eq_mul]; field_simp

/-- Every admissible occupation vector is realized by a probability distribution
on N-element determinants. This includes the vacuum and the fully filled shell. -/
theorem exists_occupation_weights {d N : ℕ} (p : Fin d → ℝ)
    (nonneg : ∀ i, 0 ≤ p i) (pauli : ∀ i, p i ≤ 1) (mass : ∑ i, p i = N) :
    ∃ w : Determinant d N → ℝ, (∀ s, 0 ≤ w s) ∧ ∑ s, w s = 1 ∧ occupations w = p := by
  classical
  have bound : N ≤ d := by
    have le := Finset.sum_le_sum (s := Finset.univ) (fun i _ => pauli i)
    rw [mass] at le
    exact_mod_cast (by simpa using le : (N : ℝ) ≤ d)
  obtain ⟨S, _, card⟩ := Finset.exists_subset_card_eq
    (s := (Finset.univ : Finset (Fin d))) (n := N) (by simpa using bound)
  let hole (i : Fin d) := 1 - p i
  have holeNonneg i : 0 ≤ hole i := sub_nonneg.mpr (pauli i)
  have holeMass : ∑ i, hole i = (Sᶜ.card : ℝ) := by
    simp [hole, Finset.sum_sub_distrib, mass, Finset.card_compl, card, Nat.cast_sub bound]
  have part (i) : ∑ j ∈ S, p i / S.card = p i :=
    columnMass S p nonneg (card ▸ mass) i
  let M : Matrix (Fin d) (Fin d) ℝ := fun j i =>
    if j ∈ S then p i / S.card else hole i / Sᶜ.card
  have stochastic : M ∈ doublyStochastic ℝ (Fin d) := by
    apply mem_doublyStochastic_iff_sum.mpr
    refine ⟨fun j i => ?_, fun j => ?_, fun i => ?_⟩
    · dsimp [M]; split <;> apply div_nonneg <;> first | positivity | apply nonneg | apply holeNonneg
    · by_cases hj : j ∈ S
      · simp [M, hj, ← Finset.sum_div, mass, ← card, Finset.card_ne_zero_of_mem hj]
      · have mem : j ∈ Sᶜ := Finset.mem_compl.mpr hj
        simp [M, hj, ← Finset.sum_div, holeMass, Finset.card_ne_zero_of_mem mem]
    · rw [← Finset.sum_add_sum_compl S]
      rw [Finset.sum_congr rfl (fun j hj => ite_eq_left hj : ∀ j ∈ S, M j i = p i / S.card),
        Finset.sum_congr rfl (fun j hj => ite_eq_right (Finset.mem_compl.mp hj) :
          ∀ j ∈ Sᶜ, M j i = hole i / Sᶜ.card)]
      rw [part, columnMass Sᶜ hole holeNonneg holeMass]
      dsimp [hole]; ring
  obtain ⟨weights, positive, total, mix⟩ := exists_eq_sum_perm_of_mem_doublyStochastic stochastic
  let occ (σ : Equiv.Perm (Fin d)) : Determinant d N := ⟨S.map σ.toEmbedding, by simpa using card⟩
  let w (s : Determinant d N) := ∑ σ, if occ σ = s then weights σ else 0
  refine ⟨w, fun s => Finset.sum_nonneg fun σ _ => by split <;> simp [positive], ?_, ?_⟩
  · simp only [w]; rw [Finset.sum_comm]; simpa using total
  · funext i
    have represented := congrArg (fun A : Matrix (Fin d) (Fin d) ℝ => ∑ j ∈ S, A j i) mix
    have rhs : ∑ j ∈ S, M j i = p i := by
      exact (Finset.sum_congr rfl (fun j hj => ite_eq_left hj)).trans (part i)
    rw [rhs] at represented
    simp only [Matrix.sum_apply, Matrix.smul_apply, smul_eq_mul] at represented
    rw [Finset.sum_comm] at represented
    rw [← represented]
    unfold occupations
    have splitWeight (s : Determinant d N) :
        (if i ∈ s.val then w s else 0) =
        ∑ σ, if occ σ = s then (if i ∈ s.val then weights σ else 0) else 0 := by
      by_cases h : i ∈ s.val <;> simp [h, w]
    simp_rw [splitWeight]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl; intro σ _
    simp only [Finset.sum_ite_eq, Finset.mem_univ, ite_true, ← Finset.mul_sum]
    have indicator : ∑ j ∈ S, σ.permMatrix ℝ j i = if σ.symm i ∈ S then 1 else 0 := by
      simp [Equiv.Perm.permMatrix, PEquiv.toMatrix, Equiv.toPEquiv_apply,
        ← Equiv.eq_symm_apply]
    rw [indicator]
    by_cases h : σ.symm i ∈ S <;> simp [occ, h]

/-- Pauli bounds and particle-number sum rule for any ensemble of N-element determinants. -/
theorem occupation_bounds {d N : ℕ} {w : Determinant d N → ℝ}
    (nonneg : ∀ s, 0 ≤ w s) (total : ∑ s, w s = 1) :
    (∀ i, 0 ≤ occupations w i ∧ occupations w i ≤ 1) ∧ ∑ i, occupations w i = N := by
  constructor
  · intro i
    unfold occupations
    refine ⟨Finset.sum_nonneg (fun s _ => by split <;> simp [nonneg]), ?_⟩
    rw [← total]
    exact Finset.sum_le_sum (fun s _ => by split <;> simp [nonneg])
  · unfold occupations
    rw [Finset.sum_comm]
    simp [Finset.sum_ite_mem, show ∀ s : Determinant d N, s.val.card = N from fun s => s.property,
      nsmul_eq_mul, ← Finset.mul_sum, total]

end FQChem.Properties.NRepresentability
