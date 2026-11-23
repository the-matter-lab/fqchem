module

public import Mathlib.Analysis.SpecialFunctions.Exp

/-!
# Imaginary-time spectral filtering

In a finite eigenbasis, shifting the generator by the ground energy leaves the
normalized state invariant. Its ground amplitudes then stay fixed before normalization,
and the excited amplitudes acquire real exponential factors. See
[Motta et al., Nature Physics 16 (2020)](https://doi.org/10.1038/s41567-019-0704-4).
-/

@[expose] public section
noncomputable section

namespace FormalQChem.StatePrep.ImaginaryTimeProjection

open Filter
open scoped Topology

/-- The ground eigenspace has dimension g and the excited sector dimension e.
An excitation energy is measured relative to the common ground energy. -/
structure SpectralData (g e : ℕ) where
  ground : Fin g → ℂ
  excited : Fin e → ℂ
  excitation : Fin e → ℝ
  gap : ℝ
  gap_pos : 0 < gap
  gap_le : ∀ i, gap ≤ excitation i
  overlap_pos : 0 < ∑ i, Complex.normSq (ground i)

variable {g e : ℕ} (S : SpectralData g e)

def groundMass := ∑ i, Complex.normSq (S.ground i)

def filteredExcited (τ : ℝ) (i : Fin e) :=
  (Real.exp (-τ * S.excitation i) : ℂ) * S.excited i

def excitedMass (τ : ℝ) := ∑ i, Complex.normSq (filteredExcited S τ i)

def totalMass (τ : ℝ) := groundMass S + excitedMass S τ

/-- The coefficients of exp(-τ(H-E₀))ψ divided by its Hilbert norm. -/
def state (τ : ℝ) (i : Fin g ⊕ Fin e) : ℂ :=
  Sum.elim S.ground (filteredExcited S τ) i / (Real.sqrt (totalMass S τ) : ℂ)

/-- Ground-subspace Born probability of the normalized state. -/
def fidelity (τ : ℝ) := ∑ i, Complex.normSq (state S τ (.inl i))

/-- Expectation of H-E₀ in the normalized filtered state. -/
def energyExcess (τ : ℝ) := ∑ i, S.excitation i * Complex.normSq (state S τ (.inr i))

def Normalization : Prop := ∀ τ, (∑ i, Complex.normSq (state S τ i)) = 1

/-- The excited-sector probability is bounded by its initial odds times exp(-2 Δ τ). -/
def ProjectionBound : Prop := ∀ τ, 0 ≤ τ →
  0 ≤ 1 - fidelity S τ ∧
    1 - fidelity S τ ≤ excitedMass S 0 / groundMass S * Real.exp (-(2 * S.gap) * τ)

def ProjectionLimit : Prop := Tendsto (fidelity S) atTop (𝓝 1)

/-- With spectral bandwidth W, the energy excess obeys the same exponential rate. -/
def EnergyBound : Prop := ∀ W, 0 ≤ W → (∀ i, S.excitation i ≤ W) → ∀ τ, 0 ≤ τ →
  0 ≤ energyExcess S τ ∧ energyExcess S τ ≤
    W * (excitedMass S 0 / groundMass S * Real.exp (-(2 * S.gap) * τ))

/-- The expected energy converges to the common ground energy. -/
def EnergyLimit : Prop := Tendsto (energyExcess S) atTop (𝓝 0)

/-- After k diagonal filter steps, each amplitude acquires the k-th power of its gain. -/
def sectorMass {d : ℕ} (c gain : Fin d → ℂ) (k : ℕ) :=
  ∑ i, Complex.normSq (gain i ^ k * c i)

/-- Spectral gains can be complex. A common nonzero gain on a degenerate ground
space preserves its direction. The contraction q bounds the ratio of squared gains.
Polynomial filters are one application. See [Lin and Tong (2020)](https://doi.org/10.22331/q-2020-11-11-361). -/
structure DiagonalFilter (g e : ℕ) where
  ground : Fin g → ℂ
  excited : Fin e → ℂ
  overlap : 0 < ∑ i, Complex.normSq (ground i)
  targetGain : ℂ
  target_ne_zero : targetGain ≠ 0
  gain : Fin e → ℂ
  q : ℝ
  q_nonneg : 0 ≤ q
  q_lt_one : q < 1
  contraction : ∀ i, Complex.normSq (gain i) ≤ q * Complex.normSq targetGain

def odds (F : DiagonalFilter g e) (k : ℕ) :=
  sectorMass F.excited F.gain k / sectorMass F.ground (fun _ => F.targetGain) k

def GeometricFiltering (F : DiagonalFilter g e) : Prop :=
  (∀ k, 0 ≤ odds F k ∧ odds F k ≤ F.q ^ k * odds F 0) ∧
  Tendsto (odds F) atTop (𝓝 0) ∧
  Tendsto (fun k => 1 / (1 + odds F k)) atTop (𝓝 1)

end FormalQChem.StatePrep.ImaginaryTimeProjection
