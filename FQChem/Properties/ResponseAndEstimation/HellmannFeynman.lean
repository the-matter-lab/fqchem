module

public import Mathlib.Analysis.InnerProductSpace.Calculus
public import Mathlib.Analysis.InnerProductSpace.Symmetric
public import Mathlib.Analysis.Calculus.Deriv.Inv
public import Mathlib.Analysis.Calculus.Deriv.Mul

/-!
# Hellmann–Feynman energy derivative
-/

@[expose] public section

namespace FQChem

open Filter
open scoped InnerProductSpace Topology

/-- On a differentiable eigenvector branch of bounded Hamiltonians, the energy
derivative is the expectation of the Hamiltonian derivative. Only the state at
the evaluation point must be normalized and the Hamiltonian there symmetric.

The real inner-product formulation applies directly to fixed real orbital
bases. A complex Hilbert space can also be viewed over the reals, with inner
product given by the real part of its complex inner product. -/
def HellmannFeynman (V : Type*) [NormedAddCommGroup V] [InnerProductSpace ℝ V] : Prop :=
  ∀ {H : ℝ → V →L[ℝ] V} {H' : V →L[ℝ] V} {ψ : ℝ → V} {ψ' : V}
    {energy : ℝ → ℝ} {x : ℝ},
    HasDerivAt H H' x →
    HasDerivAt ψ ψ' x →
    (H x).toLinearMap.IsSymmetric →
    ‖ψ x‖ = 1 →
    (∀ᶠ t in 𝓝 x, H t (ψ t) = energy t • ψ t) →
    HasDerivAt energy ⟪ψ x, H' (ψ x)⟫_ℝ x

/-- Differentiate the eigenvalue equation against the fixed vector at `x`.
Its overlap with the moving eigenvector stays nonzero near `x`, so the energy
is locally a quotient. Symmetry cancels the two eigenvector-derivative terms. -/
theorem hellmannFeynman (V : Type*) [NormedAddCommGroup V] [InnerProductSpace ℝ V] :
    HellmannFeynman V := by
  intro H H' ψ ψ' energy x hH hψ hsym hnorm heigen
  have hself : ⟪ψ x, ψ x⟫_ℝ = 1 := by
    simp [hnorm]
  have hfixed := hasDerivAt_const x (ψ x)
  have hden : HasDerivAt (fun t => ⟪ψ x, ψ t⟫_ℝ) ⟪ψ x, ψ'⟫_ℝ x := by
    simpa using hfixed.inner ℝ hψ
  have hnum : HasDerivAt (fun t => ⟪ψ x, H t (ψ t)⟫_ℝ)
      ⟪ψ x, H' (ψ x) + H x ψ'⟫_ℝ x := by
    simpa using hfixed.inner ℝ (hH.clm_apply hψ)
  have hnz : ⟪ψ x, ψ x⟫_ℝ ≠ 0 := by rw [hself]; norm_num
  have hquot := hnum.div hden hnz
  have hlocal : energy =ᶠ[𝓝 x]
      (fun t => ⟪ψ x, H t (ψ t)⟫_ℝ / ⟪ψ x, ψ t⟫_ℝ) := by
    filter_upwards [heigen, hden.continuousAt.eventually_ne hnz] with t ht hne
    rw [ht, real_inner_smul_right]
    exact (mul_div_cancel_right₀ _ hne).symm
  have hswap : ⟪ψ x, H x ψ'⟫_ℝ = energy x * ⟪ψ x, ψ'⟫_ℝ := by
    calc
      _ = ⟪H x (ψ x), ψ'⟫_ℝ := (hsym _ _).symm
      _ = _ := by rw [heigen.self_of_nhds, real_inner_smul_left]
  simpa [inner_add_right, hswap, heigen.self_of_nhds, real_inner_smul_right,
    hnorm] using hquot.congr_of_eventuallyEq hlocal

end FQChem
