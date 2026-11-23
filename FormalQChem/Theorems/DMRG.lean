module

public import FormalQChem.Theorems.RayleighRitz

/-! # One-site density matrix renormalization group

A fixed pair of MPS environments maps the center tensor into the physical state. Its
Gram operator accounts for nonorthonormal environments. In canonical gauge the map
is isometric and the one-site problem is an ordinary Hermitian eigenproblem. -/

@[expose] public section

namespace FormalQChem.DMRG

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

end FormalQChem.DMRG
