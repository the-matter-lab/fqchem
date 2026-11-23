module

public import FormalQChem.Proofs.RayleighRitz
public import FormalQChem.Theorems.VariationalMethods

/-! # Proofs for finite-basis wavefunction methods -/

@[expose] public section

namespace FormalQChem.VariationalMethods

open FormalQChem.RayleighRitz
open scoped BigOperators Matrix
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

theorem slaterTrialBound {m n : ℕ} (orbital : Fin n → Fin m → ℂ)
    (H : EuclideanSpace ℂ (Fin n → Fin m) →L[ℂ] EuclideanSpace ℂ (Fin n → Fin m)) :
    SlaterTrialBound orbital H :=
  fun hψ ↦ ritzEnergy_le H (by
    intro x σ
    exact Matrix.det_permute σ (Matrix.of fun i j ↦ orbital j (x i))) hψ

theorem selectedCI {ι : Type*} (H : E →L[ℂ] E) (determinant : ι → E) :
    SelectedCI H determinant := by
  rintro A B hAB ⟨i, hi, hi0⟩
  exact (basisEnlargement H _ _ (Submodule.span_mono (Set.image_mono hAB))
    ⟨determinant i, Submodule.subset_span ⟨i, hi, rfl⟩, hi0⟩).2

private theorem orbit_step (H : E →L[ℂ] E) (step : E → E) (ψ : E) (hψ : ψ ≠ 0) (n : ℕ) :
    ritzEnergy H (orbitSpace step ψ (n + 1)) ≤ ritzEnergy H (orbitSpace step ψ n) := by
  apply (basisEnlargement H _ _ (Submodule.span_mono (Set.image_mono (Set.Iic_subset_Iic.mpr
    (Nat.le_succ n)))) ?_).2
  exact ⟨ψ, Submodule.subset_span ⟨0, Nat.zero_le _, rfl⟩, hψ⟩

theorem classicalKrylov (H : E →L[ℂ] E) (ψ : E) : ClassicalKrylov H ψ :=
  orbit_step H H ψ

theorem quantumKrylov (H : E →L[ℂ] E) (U : E ≃ₗᵢ[ℂ] E) (ψ : E) : QuantumKrylov H U ψ :=
  orbit_step H U ψ

theorem coupledCluster {n : ℕ} (H T : Matrix (Fin n) (Fin n) ℂ) (ref : Fin n → ℂ) (energy : ℂ) :
    CoupledCluster H T ref energy := by
  have cancel (A : Matrix (Fin n) (Fin n) ℂ) :
      NormedSpace.exp A * NormedSpace.exp (-A) = 1 := by
    rw [← Matrix.exp_add_of_commute _ _ (Commute.refl A).neg_right, add_neg_cancel,
      NormedSpace.exp_zero]
  have cancel' : NormedSpace.exp (-T) * NormedSpace.exp T = 1 := by simpa using cancel (-T)
  unfold CoupledCluster
  simp only [← Matrix.mulVec_mulVec]
  constructor
  · intro h
    have heq := congrArg ((NormedSpace.exp T).mulVec) h
    simpa only [Matrix.mulVec_mulVec _ (NormedSpace.exp T) (NormedSpace.exp (-T)),
      cancel, Matrix.one_mulVec, Matrix.mulVec_smul] using heq
  · intro h
    rw [h, Matrix.mulVec_smul, Matrix.mulVec_mulVec, cancel', Matrix.one_mulVec]

theorem mrpt2Shift {ι : Type*} [Fintype ι] (coupling : ι → ℂ) (gap : ι → ℝ) :
    MRPT2Shift coupling gap := by
  intro hg
  exact Finset.sum_nonpos fun i _ ↦ neg_nonpos.mpr
    (div_nonneg (Complex.normSq_nonneg _) (hg i).le)

theorem neuralAntisymmetry {X : Type*} {n k : ℕ}
    (orb : Fin k → (Fin n → X) → Matrix (Fin n) (Fin n) ℂ) (w : Fin k → ℂ) :
    NeuralAntisymmetry orb w := by
  intro equivariant x σ
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  rw [equivariant, Matrix.det_permute]
  ring

private theorem weighted_bound {ι : Type*} [Fintype ι] {w e : ι → ℝ} {target : ℝ}
    (hw : ∑ i, w i = 1) (h : ∀ i, target * w i ≤ e i * w i) : target ≤ ∑ i, e i * w i :=
  calc target = ∑ i, target * w i := by rw [← Finset.mul_sum, hw, mul_one]
       _ ≤ _ := Finset.sum_le_sum fun i _ ↦ h i

theorem excitedStateBound {ι : Type*} [Fintype ι] (energy : ι → ℝ) (c : ι → ℂ) (target : ℝ) :
    ExcitedStateBound energy c target := by
  intro normed excluded
  refine weighted_bound normed fun i ↦ ?_
  by_cases h : energy i < target
  · simp [excluded i h]
  · exact mul_le_mul_of_nonneg_right (le_of_not_gt h) (Complex.normSq_nonneg _)

theorem vqe {Θ : Type*} (H : E →L[ℂ] E) (U : Θ → E ≃ₗᵢ[ℂ] E) (ref : E) : VQE H U ref := by
  intro href θ
  have hn : ‖U θ ref‖ = 1 := (LinearIsometryEquiv.norm_map _ _).trans href
  have hne : U θ ref ≠ 0 := fun h ↦ by simp [h] at hn
  constructor
  · simpa [ContinuousLinearMap.rayleighQuotient, hn] using groundEnergy_le H hne
  · intro heig
    rw [ContinuousLinearMap.reApplyInnerSelf_apply, heig, inner_smul_left]
    simp [inner_self_eq_norm_sq_to_K, hn]

theorem reachableVQEMinimum {Θ : Type*} (H : E →L[ℂ] E) (U : Θ → E ≃ₗᵢ[ℂ] E) (ref : E) :
    ReachableVQEMinimum H U ref := by
  rintro href ⟨θ₀, hground⟩
  refine ⟨⟨θ₀, (vqe H U ref href θ₀).2 hground⟩, ?_⟩
  rintro _ ⟨θ, rfl⟩
  exact (vqe H U ref href θ).1

theorem sampledDiagonalization {ι : Type*} (H : E →L[ℂ] E) (config : ι → E) (samples : Set ι) :
    SampledDiagonalization H config samples := by
  intro ψ hψ hne hmin
  apply le_antisymm
  · rw [← hmin]
    exact ritzEnergy_le H hψ hne
  · exact (basisEnlargement H _ _ le_rfl ⟨ψ, hψ, hne⟩).1

theorem quantumDeflation {ι : Type*} [Fintype ι] [DecidableEq ι]
    (energy penalty : ι → ℝ) (k : ι) : QuantumDeflation energy penalty k := by
  intro lifted zeroPenalty
  constructor
  · intro c hc
    exact weighted_bound hc fun i ↦
      mul_le_mul_of_nonneg_right (lifted i) (Complex.normSq_nonneg _)
  · simp [apply_ite, Finset.sum_ite_eq', zeroPenalty]

end FormalQChem.VariationalMethods
