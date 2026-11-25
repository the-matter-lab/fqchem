module

public import FQChem.StatePrep.VariationalOptimization.DensityFunctionals.MolecularConstrainedSearch

/-!
# Atomic energy as a function of electron number

For a single fixed nucleus at the origin, does removing successive electrons cost
increasing amounts of energy? This is the atomic case of the convexity question in
[Di Marino, Lewin and Nenna, Eq. (4)](https://arxiv.org/abs/2409.08632).
Their six-centre counterexample leaves the single-nucleus question open. See also
[Hofacker, Appendix C, Eq. (63)](https://arxiv.org/abs/2610.34480).
-/

@[expose] public section
noncomputable section

namespace FQChem.Unproven.AtomicEnergy

open FQChem.MolecularDFT MeasureTheory
open scoped ContDiff

abbrev Spins (N : ℕ) := Fin N → Fin 2

/-- The spatial kinetic energy density of a complex spin component, in atomic units. -/
def kinetic {N : ℕ} (ψ : Configuration N → ℂ) (q : Configuration N) : ℝ :=
  (∑ i : Fin N, ∑ a : Fin 3, ‖fderiv ℝ ψ q (Pi.single i (EuclideanSpace.single a 1))‖ ^ 2) / 2

/-- Form integrand for the nonrelativistic point-nucleus Coulomb Hamiltonian. -/
def energyDensity {N : ℕ} (Z : ℕ) (ψ : Configuration N → ℂ) (q : Configuration N) : ℝ :=
  kinetic ψ q + (repulsion q - ∑ i, (Z : ℝ) / ‖q i‖) * ‖ψ q‖ ^ 2

/-- Normalized spin-½ fermionic trial spinors on the smooth compactly supported form core.
Electron exchange permutes the spatial and spin labels together. -/
structure TrialSpinor (Z N : ℕ) where
  wave : Spins N → Configuration N → ℂ
  smooth : ∀ s, ContDiff ℝ ∞ (wave s)
  compact_support : ∀ s, HasCompactSupport (wave s)
  antisymmetric : ∀ s q (i j : Fin N), i ≠ j →
    wave (s ∘ Equiv.swap i j) (q ∘ Equiv.swap i j) = -wave s q
  normalized : (∑ s, ∫ q, ‖wave s q‖ ^ 2) = 1
  finiteEnergy : ∀ s, Integrable (energyDensity Z (wave s))

/-- Variational ground energy with nuclear charge Z and N electrons. The vacuum has zero energy. -/
def groundEnergy (Z : ℕ) : ℕ → EReal
  | 0 => 0
  | n + 1 => ⨅ ψ : TrialSpinor Z (n + 1), ((∑ s, ∫ q, energyDensity Z (ψ.wave s) q : ℝ) : EReal)

/-- Discrete convexity for a positive integer-charge atom, at every electron number ≥ 1. -/
def ElectronNumberConvexity : Prop :=
  ∀ Z : ℕ, 0 < Z → ∀ n : ℕ,
    groundEnergy Z (n + 1) + groundEnergy Z (n + 1) ≤
      groundEnergy Z n + groundEnergy Z (n + 2)

/-- Can an atom strictly bind its next electron after failing to bind the preceding one?
[Nam, discussion after Conjecture 3](https://arxiv.org/abs/2206.15393) singles out
this weaker consequence of energy convexity. Binding here means a strict energy
gap to the one-electron removal threshold. -/
def ConsecutiveBinding : Prop :=
  ∀ Z : ℕ, 0 < Z → ∀ n : ℕ, groundEnergy Z (n + 2) < groundEnergy Z (n + 1) →
    groundEnergy Z (n + 1) < groundEnergy Z n

end FQChem.Unproven.AtomicEnergy
