module

public import FormalQChem.Theorems.DFT
public import FormalQChem.Theorems.MolecularDFT

/-! # Hohenberg–Kohn uniqueness for pairs of molecular potentials -/

@[expose] public section
noncomputable section

namespace FormalQChem.MolecularHK

open MeasureTheory FormalQChem.MolecularDFT

/-- One external scalar potential acts independently on each electron. -/
def oneBodyLift {N : ℕ} (w : Position → ℝ) (q : Configuration N) := ∑ i, w (q i)

/-- Rigidity of a separable potential on three-dimensional electronic configuration space. -/
def OneBodyRigidity (n : ℕ) : Prop :=
  ∀ (w : Position → ℝ) (c : ℝ),
    (oneBodyLift (N := n + 1) w =ᵐ[volume] fun _ => c) →
      ∃ k : ℝ, w =ᵐ[volume] fun _ => k

/-- Data of a real spin-polarized molecular form domain with two external potentials.
The kinetic form and electron–electron repulsion are in atomic units. The two potential
coefficients parametrize their span. The form-domain realization is an explicit input. -/
structure MolecularForm (N : ℕ) (v₁ v₂ : Position → ℝ) where
  setting : DFT.Setting (volume : Measure (Configuration N)) (ℝ × ℝ)
  lift_eq : ∀ p q, setting.L p q = oneBodyLift (fun r => p.1 * v₁ r + p.2 * v₂ r) q
  kineticFinite : ∀ ψ ∈ setting.D, Integrable (kineticDensity ψ)
  repulsionFinite : ∀ ψ ∈ setting.D, Integrable (fun q => repulsion q * ψ q ^ 2)
  internal_eq : ∀ ψ ∈ setting.D, setting.h0 ψ ψ =
    (∫ q, kineticDensity ψ q) + ∫ q, repulsion q * ψ q ^ 2
  antisymmetric : ∀ ψ ∈ setting.D, ∀ i j : Fin N, i ≠ j →
    ∀ᵐ q ∂volume, ψ (q ∘ Equiv.swap i j) = -ψ q

/-- The one-electron densities agree as functionals on all one-body probes with
finite expectations in both states. -/
def EqualDensity {N : ℕ} (ψ φ : Configuration N → ℝ) : Prop :=
  ∀ w : Position → ℝ,
    Integrable (fun q => oneBodyLift w q * (ψ q * ψ q)) →
    Integrable (fun q => oneBodyLift w q * (φ q * φ q)) →
    (∫ q, oneBodyLift w q * (ψ q * ψ q)) = ∫ q, oneBodyLift w q * (φ q * φ q)

/-- For n+1 electrons and two sets of fixed nuclei, equally normalized ground states
with the same one-electron density determine the point-nucleus potential up to an
a.e. constant. The form domain, separation and ground-state nonvanishing are inputs. -/
def MolecularHohenbergKohn (n K J : ℕ) : Prop :=
  ∀ (Z : Fin K → ℝ) (R : Fin K → Position) (Z' : Fin J → ℝ) (R' : Fin J → Position)
    (M : MolecularForm (n + 1) (nuclearPotential Z R) (nuclearPotential Z' R'))
    (ψ φ : Configuration (n + 1) → ℝ),
    DFT.Sep M.setting → DFT.IsGS M.setting (1, 0) ψ → DFT.IsGS M.setting (0, 1) φ →
    DFT.ip (μ := volume) ψ ψ = DFT.ip (μ := volume) φ φ → EqualDensity ψ φ →
    (∀ᵐ q ∂volume, ψ q ≠ 0) →
      ∃ k : ℝ, (fun r => nuclearPotential Z R r - nuclearPotential Z' R' r) =ᵐ[volume] fun _ => k

end FormalQChem.MolecularHK
