/-
Copyright (c) 2026 Miguel A. L. Marques. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Miguel A. L. Marques
Adapted for FormalQChem from hyllios/lean_dft, revision b9065256a6ddb1a7a4e1df3fbbf49a9a3fd546a4.
-/
module

public import Mathlib.MeasureTheory.Integral.Bochner.Basic
public import Mathlib.Data.EReal.Operations

/-!
# Ground-state density functional theory

For a fixed internal energy form, a density records the expectation of every one-body
potential. In molecular notation this pairing is `ρ(v) = ∫ ρ(r) v(r) dr`.
The infima and suprema take extended real values. Existence of a normalized
minimizer is a separate hypothesis in the attainment statement.
-/

@[expose] public section

namespace FormalQChem.DFT

open MeasureTheory

variable {X : Type*} [MeasurableSpace X] {μ : Measure X} {P : Type*} [AddCommGroup P] [Module ℝ P]

/-- A real-wavefunction quantum system on the configuration space `(X, μ)` with one-body potentials in `P`. -/
structure Setting (μ : Measure X) (P : Type*) [AddCommGroup P] [Module ℝ P] where
  /-- The form domain. -/
  D : Submodule ℝ (X → ℝ)
  /-- The potential-free energy form (kinetic energy plus interaction), bilinear on `D`. -/
  h0 : (X → ℝ) → (X → ℝ) → ℝ
  h0_add : ∀ a ∈ D, ∀ b ∈ D, ∀ c ∈ D, h0 (a + b) c = h0 a c + h0 b c
  h0_smul : ∀ r : ℝ, ∀ a ∈ D, ∀ c ∈ D, h0 (r • a) c = r * h0 a c
  h0_symm : ∀ ψ ∈ D, ∀ φ ∈ D, h0 ψ φ = h0 φ ψ
  /-- The coupling of one-body potentials to configurations. -/
  L : P →ₗ[ℝ] (X → ℝ)
  int_L : ∀ w ψ φ, ψ ∈ D → φ ∈ D → Integrable (fun x => L w x * (ψ x * φ x)) μ
  int_sq : ∀ ψ φ, ψ ∈ D → φ ∈ D → Integrable (fun x => ψ x * φ x) μ

variable (S : Setting μ P)

/-- The `L²` inner product. -/
noncomputable def ip (ψ φ : X → ℝ) : ℝ := ∫ x, ψ x * φ x ∂μ

/-- The potential energy form of `w`. -/
noncomputable def pf (w : P) (ψ φ : X → ℝ) : ℝ := ∫ x, S.L w x * (ψ x * φ x) ∂μ

/-- The energy `⟨ψ, H(w) ψ⟩`. -/
noncomputable def Q (w : P) (ψ : X → ℝ) : ℝ := S.h0 ψ ψ + pf S w ψ ψ

/-- The density of `ψ`, as a functional on one-body potentials. -/
noncomputable def dens (ψ : X → ℝ) (w : P) : ℝ := pf S w ψ ψ

/-- `ψ` is a ground state of `H(w)`: a nonzero minimiser of the Rayleigh quotient on `D`. -/
def IsGS (w : P) (ψ : X → ℝ) : Prop :=
  ψ ∈ S.D ∧ 0 < ip (μ := μ) ψ ψ ∧
    ∀ φ ∈ S.D, Q S w ψ * ip (μ := μ) φ φ ≤ Q S w φ * ip (μ := μ) ψ ψ

/-- The form domain separates the functions `(L w - c) ψ` (fundamental lemma of the calculus of
variations). -/
def Sep : Prop :=
  ∀ (w : P) (c : ℝ) (ψ : X → ℝ), ψ ∈ S.D →
    (∀ φ ∈ S.D, ∫ x, (S.L w x - c) * ψ x * φ x ∂μ = 0) →
      (fun x => (S.L w x - c) * ψ x) =ᵐ[μ] 0

/-- Rigidity: a one-body potential whose coupling is a.e. constant is a multiple of `one`. -/
def RigidL (one : P) : Prop :=
  ∀ (w : P) (c : ℝ), (S.L w =ᵐ[μ] fun _ => c) → ∃ k : ℝ, w = k • one

/-- Normalised states. -/
def Nst : Set (X → ℝ) := {ψ | ψ ∈ S.D ∧ ip (μ := μ) ψ ψ = 1}

/-- `ψ` is a normalised ground state of `H(v)`. -/
def IsNGS (v : P) (ψ : X → ℝ) : Prop :=
  ψ ∈ Nst S ∧ ∀ φ ∈ Nst S, Q S v ψ ≤ Q S v φ

/-- The ground-state energy. -/
noncomputable def gsE (v : P) : EReal := ⨅ ψ ∈ Nst S, ((Q S v ψ : ℝ) : EReal)

/-- The Lieb functional. -/
noncomputable def liebF (ρ : P → ℝ) : EReal := ⨆ v, gsE S v - ((ρ v : ℝ) : EReal)

/-- Densities realized by normalized states in the model's form domain. -/
def Representable (ρ : P → ℝ) : Prop := ∃ ψ ∈ Nst S, dens S ψ = ρ

/-- Hohenberg–Kohn (1964). Equally normalized ground states with the same density determine
the external potential up to a constant. Separation, rigidity, and almost-everywhere
nonvanishing of one ground state are explicit analytic hypotheses. -/
def HohenbergKohn (one : P) : Prop :=
  Sep S → RigidL S one →
    ∀ {v v' : P} {ψ ψ' : X → ℝ}, IsGS S v ψ → IsGS S v' ψ' →
      ip (μ := μ) ψ ψ = ip (μ := μ) ψ' ψ' → dens S ψ = dens S ψ' →
      (∀ᵐ x ∂μ, ψ x ≠ 0) → ∃ k : ℝ, v - v' = k • one

/-- The universal-functional variational identity for every external potential.
The infimum runs over representable densities. -/
def VariationalPrinciple (F : (P → ℝ) → EReal) : Prop :=
  ∀ v : P, gsE S v = ⨅ ρ : {ρ // Representable S ρ}, F ρ.val + (ρ.val v : EReal)

/-- Existence of one potential-independent functional recovering all ground-state energies. -/
def UniversalFunctionalExists : Prop := ∃ F, VariationalPrinciple S F

/-- At the density of a normalized ground state, the Lieb functional gives its internal energy. -/
def GroundDensityExactness : Prop :=
  ∀ {v : P} {ψ : X → ℝ}, IsNGS S v ψ → liebF S (dens S ψ) = (S.h0 ψ ψ : EReal)

end FormalQChem.DFT
