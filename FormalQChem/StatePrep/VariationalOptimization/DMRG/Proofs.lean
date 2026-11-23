module

public import FormalQChem.StatePrep.VariationalOptimization.DMRG.Theorems
public import FormalQChem.StatePrep.VariationalOptimization.RayleighRitz.Proofs

/-! The DMRG local eigenproblem is a Rayleigh–Ritz minimization on the center tensor. -/

@[expose] public section

namespace FormalQChem.DMRG

open FormalQChem.RayleighRitz

/-- The environment map actually performs the two virtual-bond contractions. -/
theorem environmentMap_apply {l r s a b : ℕ} (left : Matrix (Fin l) (Fin a) ℂ)
    (right : Matrix (Fin b) (Fin r) ℂ) (A : EuclideanSpace ℂ (Fin a × Fin s × Fin b))
    (x : Fin l) (t : Fin s) (y : Fin r) :
    environmentMap left right A (x, t, y) = ∑ i, ∑ j, left x i * right j y * A (i, t, j) := by
  change (∑ q : Fin a × Fin s × Fin b,
    (if t = q.2.1 then left x q.1 * right q.2.2 y else 0) * A q) = _
  simp [Fintype.sum_prod_type, ite_mul]

variable {Site Physical : Type*}
  [NormedAddCommGroup Site] [InnerProductSpace ℂ Site] [CompleteSpace Site]
  [NormedAddCommGroup Physical] [InnerProductSpace ℂ Physical] [CompleteSpace Physical]

theorem energy_identity (B : Site →L[ℂ] Physical) (H : Physical →L[ℂ] Physical) (a : Site) :
    localEnergy B H a = H.rayleighQuotient (B a) := by
  simp only [localEnergy, effective, overlap, ContinuousLinearMap.reApplyInnerSelf_apply,
    ContinuousLinearMap.rayleighQuotient, ContinuousLinearMap.comp_apply,
    ContinuousLinearMap.adjoint_inner_left, inner_self_eq_norm_sq]

theorem oneSiteUpdate (B : Site →L[ℂ] Physical) (H : Physical →L[ℂ] Physical) :
    OneSiteUpdate B H := by
  refine ⟨energy_identity B H, ?_⟩
  intro new _ minimizes old hold
  have h : localEnergy B H new ≤ localEnergy B H old := minimizes hold
  simpa only [energy_identity] using h

private theorem effective_symmetric (B : Site →L[ℂ] Physical) {H : Physical →L[ℂ] Physical}
    (hH : H.toLinearMap.IsSymmetric) : (effective B H).toLinearMap.IsSymmetric := by
  intro x y
  change inner ℂ (B.adjoint (H (B x))) y = inner ℂ x (B.adjoint (H (B y)))
  rw [ContinuousLinearMap.adjoint_inner_left, ContinuousLinearMap.adjoint_inner_right]
  exact hH (B x) (B y)

theorem canonicalUpdate [FiniteDimensional ℂ Site] [Nontrivial Site]
    (B : Site →ₗᵢ[ℂ] Physical) (H : Physical →L[ℂ] Physical) (hH : H.toLinearMap.IsSymmetric) :
    CanonicalUpdate B H := by
  let K := effective B.toContinuousLinearMap H
  have gram : overlap B.toContinuousLinearMap = 1 := B.adjoint_comp_self
  have rayleigh (x : Site) : H.rayleighQuotient (B x) = K.rayleighQuotient x := by
    rw [← show localEnergy B.toContinuousLinearMap H x = H.rayleighQuotient (B x) from
      energy_identity B.toContinuousLinearMap H x]
    simp [localEnergy, gram, K, ContinuousLinearMap.rayleighQuotient,
      ContinuousLinearMap.reApplyInnerSelf_apply, ← Complex.ofReal_pow]
  obtain ⟨eigen, lower⟩ := groundEnergyPrinciple K (effective_symmetric _ hH)
  obtain ⟨a, ha⟩ := eigen.exists_hasEigenvector
  have eqn : K a = (groundEnergy K : ℂ) • a := ha.apply_eq_smul
  refine ⟨gram, a, groundEnergy K, ha.2, eqn, ?_, fun x hx ↦ (lower x hx).trans_eq (rayleigh x).symm⟩
  rw [rayleigh, ContinuousLinearMap.rayleighQuotient, ContinuousLinearMap.reApplyInnerSelf_apply,
    eqn, inner_smul_left, inner_self_eq_norm_sq_to_K]
  simp [RCLike.re_to_complex, ← Complex.ofReal_pow, field, ha.2]

end FormalQChem.DMRG
