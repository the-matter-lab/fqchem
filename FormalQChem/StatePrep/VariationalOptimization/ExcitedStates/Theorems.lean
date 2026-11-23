module

public import Mathlib.Analysis.Complex.Basic

@[expose] public section

namespace FormalQChem.VariationalMethods
open scoped BigOperators Matrix


/-- With amplitudes in an orthonormal eigenbasis, excluding every eigenstate below
the target energy bounds the trial expectation by the target. -/
def ExcitedStateBound {ι : Type*} [Fintype ι] (energy : ι → ℝ) (c : ι → ℂ) (target : ℝ) : Prop :=
  (∑ i, Complex.normSq (c i)) = 1 → (∀ i, energy i < target → c i = 0) →
    target ≤ ∑ i, energy i * Complex.normSq (c i)

/-- Variational quantum deflation in an exact orthonormal eigenbasis. The penalty on
each lower eigenstate must lift its energy to at least the target. The target eigenstate
itself achieves equality when it has zero penalty. -/
def QuantumDeflation {ι : Type*} [Fintype ι] [DecidableEq ι] (energy penalty : ι → ℝ) (k : ι) : Prop :=
  (∀ i, energy k ≤ energy i + penalty i) → penalty k = 0 →
    (∀ c : ι → ℂ, (∑ i, Complex.normSq (c i)) = 1 →
      energy k ≤ ∑ i, (energy i + penalty i) * Complex.normSq (c i)) ∧
    (∑ i, (energy i + penalty i) * Complex.normSq (if i = k then (1 : ℂ) else 0)) = energy k

end FormalQChem.VariationalMethods
