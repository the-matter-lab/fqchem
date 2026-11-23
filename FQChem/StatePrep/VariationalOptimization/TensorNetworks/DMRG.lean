module

public import FQChem.StatePrep.VariationalOptimization.RayleighRitz

/-!
# One-site density matrix renormalization group

A fixed pair of MPS environments maps the center tensor into the physical state. Its
Gram operator accounts for nonorthonormal environments. In canonical gauge the map
is isometric and the one-site problem is an ordinary Hermitian eigenproblem.

The DMRG local eigenproblem is a Rayleigh–Ritz minimization on the center tensor.
-/

@[expose] public section

namespace FQChem.DMRG

/-- The coefficient map for fixed left and right environments. For physical coordinates
`(x,s,y)` it contracts the trial center tensor with `left x a` and `right b y`,
summing over both bond indices and preserving the on-site physical index `s`. -/
noncomputable def environmentMap {l r s a b : ℕ} (left : Matrix (Fin l) (Fin a) ℂ)
    (right : Matrix (Fin b) (Fin r) ℂ) :
    EuclideanSpace ℂ (Fin a × Fin s × Fin b) →L[ℂ] EuclideanSpace ℂ (Fin l × Fin s × Fin r) :=
  let B : Matrix (Fin l × Fin s × Fin r) (Fin a × Fin s × Fin b) ℂ := Matrix.of fun p q ↦
    if p.2.1 = q.2.1 then left p.1 q.1 * right q.2.2 p.2.2 else 0
  B.toEuclideanLin.toContinuousLinearMap

variable {Site Physical : Type*}
  [NormedAddCommGroup Site] [InnerProductSpace ℂ Site] [CompleteSpace Site]
  [NormedAddCommGroup Physical] [InnerProductSpace ℂ Physical] [CompleteSpace Physical]

/-- Local effective Hamiltonian B† H B. -/
noncomputable def effective (B : Site →L[ℂ] Physical) (H : Physical →L[ℂ] Physical) :
    Site →L[ℂ] Site := B.adjoint.comp (H.comp B)

/-- Local overlap B† B. -/
noncomputable def overlap (B : Site →L[ℂ] Physical) : Site →L[ℂ] Site := B.adjoint.comp B

/-- Effective one-site energy in an arbitrary gauge. Physical states require B a ≠ 0. -/
noncomputable def localEnergy (B : Site →L[ℂ] Physical) (H : Physical →L[ℂ] Physical)
    (a : Site) : ℝ := (effective B H).reApplyInnerSelf a / (overlap B).reApplyInnerSelf a

/-- The generalized Rayleigh quotient is exactly the physical energy. Any exact one-site
minimizer can replace the old tensor without increasing the physical energy. -/
def OneSiteUpdate (B : Site →L[ℂ] Physical) (H : Physical →L[ℂ] Physical) : Prop :=
  (∀ a, localEnergy B H a = H.rayleighQuotient (B a)) ∧
    ∀ new, B new ≠ 0 → IsMinOn (localEnergy B H) {a | B a ≠ 0} new →
      ∀ old, B old ≠ 0 → H.rayleighQuotient (B new) ≤ H.rayleighQuotient (B old)

/-- For isometric environments and a Hermitian Hamiltonian in a finite-dimensional
nonzero site space, an exact lowest-eigenvalue update exists. It minimizes the
energy in the full space of contractions with those fixed environments. -/
def CanonicalUpdate (B : Site →ₗᵢ[ℂ] Physical) (H : Physical →L[ℂ] Physical) : Prop :=
  overlap B.toContinuousLinearMap = 1 ∧
    ∃ (a : Site) (energy : ℝ), a ≠ 0 ∧
      effective B.toContinuousLinearMap H a = (energy : ℂ) • a ∧
      H.rayleighQuotient (B a) = energy ∧
      ∀ old, old ≠ 0 → energy ≤ H.rayleighQuotient (B old)

end FQChem.DMRG

namespace FQChem.DMRG

open FQChem.RayleighRitz

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

end FQChem.DMRG
