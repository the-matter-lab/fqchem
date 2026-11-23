module

public import Mathlib.Analysis.Calculus.Deriv.Add
public import Mathlib.Analysis.SpecialFunctions.Log.Basic
public import Mathlib.Algebra.BigOperators.Field
public import Mathlib.Data.EReal.Basic

/-! # Energies and error estimates at molecular interfaces
Energies are real and expressed in common units. Derivatives are along one nuclear
coordinate. The two-body expansion sums each unordered fragment pair once.
The ensemble is finite and nonempty, with positive inverse temperature. -/

@[expose] public section

namespace FormalQChem.Multiscale

/-- Two-layer subtractive ONIOM energy along a nuclear coordinate. -/
def layered (fullLow modelHigh modelLow : ℝ → ℝ) (x : ℝ) :=
  fullLow x + modelHigh x - modelLow x

/-- Forces are negative derivatives of the three energy surfaces. -/
def LayeredForce : Prop :=
  ∀ (full high low : ℝ → ℝ) (x f h l : ℝ),
    HasDerivAt full (-f) x → HasDerivAt high (-h) x → HasDerivAt low (-l) x →
    HasDerivAt (layered full high low) (-(f + h - l)) x

/-- The subsystem's nonadditive energy at active density a and frozen density b.
The functions below parameterize a directional variation of the active density. -/
def nonadditive (total active : ℝ → ℝ) (frozen t : ℝ) := total t - active t - frozen

/-- Along an admissible density variation, the nonadditive embedding potential contributes
the difference between the total and active functional derivatives. -/
def FrozenDensityDerivative : Prop :=
  ∀ (total active : ℝ → ℝ) (frozen t vt va : ℝ),
    HasDerivAt total vt t → HasDerivAt active va t →
    HasDerivAt (nonadditive total active frozen) (vt - va) t

/-- An additive split of the total density into active and frozen parts restricts
the feasible search. A representable minimizing split makes the bound exact. -/
def FrozenSearch {D : Type*} [Add D] (E : D → EReal) (valid active : Set D) (b : D) : Prop :=
  (∀ a ∈ active, a + b ∈ valid) →
  let full := ⨅ ρ : valid, E ρ.val
  let restricted := ⨅ a : active, E (a.val + b)
  full ≤ restricted ∧ (∀ a ∈ active, E (a + b) = full → restricted = full)

open scoped BigOperators

/-- FMO2 monomer plus dimer-increment reconstruction. -/
def fragmentEnergy {n : ℕ} (mono : Fin n → ℝ) (dimer : Fin n → Fin n → ℝ) :=
  (∑ i, mono i) + ∑ i, ∑ j ∈ Finset.univ.filter (i < ·), (dimer i j - mono i - mono j)

/-- Reconstruction is exact in a pair-additive model with consistent dimer energies. -/
def PairReconstruction : Prop :=
  ∀ {n : ℕ} (mono : Fin n → ℝ) (dimer interaction : Fin n → Fin n → ℝ),
    (∀ i j, i < j → dimer i j = mono i + mono j + interaction i j) →
    fragmentEnergy mono dimer =
      (∑ i, mono i) + ∑ i, ∑ j ∈ Finset.univ.filter (i < ·), interaction i j

/-- Adding a learned high-minus-low correction to the low-level surface bounds the
error in an energy difference by the sum of its endpoint correction errors. -/
def DeltaLearningGap : Prop :=
  ∀ {X : Type} (hi lo predict : X → ℝ) (x y : X) (ex ey : ℝ),
    |predict x - (hi x - lo x)| ≤ ex → |predict y - (hi y - lo y)| ≤ ey →
    |((lo y + predict y) - (lo x + predict x)) - (hi y - hi x)| ≤ ex + ey

noncomputable def partition {ι : Type*} [Fintype ι] (β : ℝ) (U : ι → ℝ) :=
  ∑ i, Real.exp (-β * U i)

noncomputable def freeEnergy {ι : Type*} [Fintype ι] (β : ℝ) (U : ι → ℝ) :=
  -Real.log (partition β U) / β

/-- Zwanzig's exact finite-ensemble free-energy perturbation identity. -/
def Zwanzig (ι : Type*) [Fintype ι] [Nonempty ι] : Prop :=
  ∀ (β : ℝ) (_ : 0 < β) (U V : ι → ℝ), freeEnergy β V - freeEnergy β U =
    -Real.log (∑ i, (Real.exp (-β * U i) / partition β U) * Real.exp (-β * (V i - U i))) / β

/-- At the same prefactor and temperature, a barrier error of at most ε gives
a multiplicative interval for the transition-state rate ratio. -/
def BarrierRateError : Prop :=
  ∀ (A β exact approx ε : ℝ), 0 < A → 0 ≤ β → |approx - exact| ≤ ε →
    let ratio := A * Real.exp (-β * approx) / (A * Real.exp (-β * exact))
    Real.exp (-β * ε) ≤ ratio ∧ ratio ≤ Real.exp (β * ε)

end FormalQChem.Multiscale
