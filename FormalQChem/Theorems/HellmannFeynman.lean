module

public import Mathlib.Analysis.InnerProductSpace.Calculus
public import Mathlib.Analysis.InnerProductSpace.Symmetric

/-! # Hellmann–Feynman energy derivative -/

@[expose] public section

namespace FormalQChem

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

end FormalQChem
