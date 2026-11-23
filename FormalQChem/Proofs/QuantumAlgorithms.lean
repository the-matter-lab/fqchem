module

public import FormalQChem.Theorems.QuantumAlgorithms
import Mathlib.Tactic

/-! # Proofs for finite quantum simulation and reconstruction -/

public section
namespace FormalQChem.Algorithms

theorem variationalMonteCarlo (n : ℕ) : VariationalMonteCarlo n := by
  intro H ψ _ _
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  by_cases h : ψ i = 0
  · simp [h]
  · field_simp

theorem mpsCutBound (l r d χ : ℕ) : MPSCutBound l r d χ := by
  intro A B a b
  let L := Matrix.of fun (x : Fin l → Fin d) (j : Fin χ) => (siteMatrices A x).prod a j
  let R := Matrix.of fun (j : Fin χ) (y : Fin r → Fin d) => (siteMatrices B y).prod j b
  have factor : (Matrix.of fun (x : Fin l → Fin d) (y : Fin r → Fin d) =>
      ((siteMatrices A x ++ siteMatrices B y).prod) a b) = L * R := by
    ext x y
    simp only [Matrix.of_apply, List.prod_append, Matrix.mul_apply, L, R]
  rw [factor]
  exact (Matrix.rank_mul_le_left L R).trans (by simpa using L.rank_le_card_width)

theorem exactCutFactorization (rows cols D : ℕ) : ExactCutFactorization rows cols D := by
  intro C
  constructor
  · intro h
    let f := C.mulVecLin
    have hdim : Module.finrank ℂ (LinearMap.range f) ≤ Module.finrank ℂ (Fin D → ℂ) := by
      simpa only [Matrix.rank, f, Module.finrank_pi, Fintype.card_fin] using h
    obtain ⟨encode, hinj⟩ := finrank_le_iff_exists_linearMap.mp hdim
    obtain ⟨decode, hleft⟩ := encode.exists_leftInverse_of_injective (LinearMap.ker_eq_bot.mpr hinj)
    let L := (LinearMap.range f).subtype.comp decode
    let R := encode.comp f.rangeRestrict
    refine ⟨LinearMap.toMatrix' L, LinearMap.toMatrix' R, ?_⟩
    rw [← LinearMap.toMatrix'_comp]
    have hcomp : L.comp R = f := by
      apply LinearMap.ext
      intro x
      exact congrArg Subtype.val (LinearMap.congr_fun hleft (f.rangeRestrict x))
    rw [hcomp]
    exact (LinearMap.toMatrix'.apply_symm_apply C).symm
  · rintro ⟨L, R, rfl⟩
    exact (Matrix.rank_mul_le_left L R).trans L.rank_le_width

theorem spectralIdentification (n : ℕ) : SpectralIdentification n := by
  intro dt energy a b hdt he hsample
  let z := fun j => Real.exp (-dt * energy j)
  have hz : Function.Injective z := by
    intro i j hij
    apply he
    exact mul_left_cancel₀ (neg_ne_zero.mpr hdt.ne') (Real.exp_injective hij)
  apply sub_eq_zero.mp
  apply Matrix.eq_zero_of_forall_pow_sum_mul_pow_eq_zero hz
  intro k
  simpa only [Pi.sub_apply, sub_mul, Finset.sum_sub_distrib, sub_eq_zero, z, laplaceSample]
    using sub_eq_zero.mpr (hsample k)

theorem realTimeReweighting (n : ℕ) : RealTimeReweighting n := by
  intro w O hw
  have restore (z : ℂ) : (‖z‖ : ℂ) * pathPhase z = z := by
    by_cases hz : z = 0
    · simp [hz, pathPhase]
    · have h : (‖z‖ : ℂ) ≠ 0 := by exact_mod_cast norm_ne_zero_iff.mpr hz
      unfold pathPhase
      field_simp
  simp_rw [restore]
  refine ⟨trivial, ?_⟩
  have bound := norm_sum_le (s := Finset.univ) (f := w)
  exact (div_le_one (lt_of_lt_of_le (norm_pos_iff.mpr hw) bound)).mpr bound

theorem linkedClusterInversion (n : ℕ) : LinkedClusterInversion n := by
  intro obs w hw S
  have total (T : Finset (Fin n)) : obs T = ∑ U ∈ Finset.Iic T, w U := by
    rw [Finset.Iic_eq_powerset, ← Finset.sum_erase_add _ _ (Finset.mem_powerset_self T)]
    linarith [hw T]
  simpa only [Finset.Iic_eq_powerset] using IncidenceAlgebra.moebius_inversion_bot w obs total S

theorem exactGridQPE (N : ℕ) [NeZero N] : ExactGridQPE N := by
  intro m k
  rw [AddChar.sum_mulShift _ (ZMod.isPrimitive_stdAddChar N)]
  by_cases h : m = k
  · simp [h, ZMod.card, NeZero.ne (N : ℂ)]
  · simp [h, sub_ne_zero.mpr h]

theorem rydbergBlockade (n : ℕ) : RydbergBlockade n := by
  intro edges penalty hp s
  have pos {t} (ht : blockadeViolations edges t ≠ 0) : 0 < blockadeEnergy edges penalty t := by
    have hw : (1 : ℝ) ≤ blockadeViolations edges t := by exact_mod_cast Nat.one_le_iff_ne_zero.mpr ht
    have hc : (t.card : ℝ) ≤ n := by exact_mod_cast (Finset.card_le_univ t).trans_eq (Fintype.card_fin n)
    have hp' : 0 ≤ penalty := le_trans (Nat.cast_nonneg n) hp.le
    unfold blockadeEnergy
    nlinarith [mul_le_mul_of_nonneg_left hw hp']
  constructor
  · intro h
    have hempty := h ∅
    have h0 : blockadeViolations edges ∅ = 0 := by simp [blockadeViolations]
    simp only [blockadeEnergy, h0, Nat.cast_zero, mul_zero, Finset.card_empty, sub_zero] at hempty
    have hs : blockadeViolations edges s = 0 := by
      by_contra hne
      exact (pos hne).not_ge hempty
    refine ⟨hs, fun t ht => ?_⟩
    simpa [blockadeEnergy, hs, ht] using h t
  · rintro ⟨hs, hmax⟩ t
    by_cases ht : blockadeViolations edges t = 0
    · simpa [blockadeEnergy, hs, ht] using hmax t ht
    · exact le_trans (by simp [blockadeEnergy, hs]) (pos ht).le

theorem commutingProductFormula (d : ℕ) : CommutingProductFormula d := by
  intro A B h n
  rw [← Matrix.exp_add_of_commute A B h, Matrix.exp_nsmul]

theorem hhlSpectralInversion (d k : ℕ) : HHLSpectralInversion d k := by
  intro A u eigenvalue b he hn
  rw [map_sum]
  apply Finset.sum_congr rfl
  intro j _
  rw [map_smul, he, smul_smul, div_mul_cancel₀ _ (hn j)]

theorem dirichletPoissonMode (N m : ℕ) : DirichletPoissonMode N m := by
  intro hm hmN h _
  dsimp only
  refine ⟨?_, by simp, ?_, ?_⟩
  · simp only [Int.cast_one, one_mul]
    apply Real.sin_pos_of_pos_of_lt_pi
    · positivity
    · apply (div_lt_iff₀ (by positivity : 0 < (N : ℝ) + 1)).mpr
      have hmn : (m : ℝ) < (N : ℝ) + 1 := by exact_mod_cast Nat.lt_succ_of_le hmN
      nlinarith [mul_lt_mul_of_pos_right hmn Real.pi_pos]
  · have hn : (N : ℝ) + 1 ≠ 0 := by positivity
    push_cast
    convert Real.sin_nat_mul_pi m using 2
    field_simp
  · intro j
    push_cast
    simp only [sub_mul, add_mul, one_mul, Real.sin_sub, Real.sin_add]
    ring

end FormalQChem.Algorithms
