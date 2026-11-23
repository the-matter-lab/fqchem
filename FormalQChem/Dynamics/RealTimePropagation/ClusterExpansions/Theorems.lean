module

public import Mathlib.Combinatorics.Enumerative.IncidenceAlgebra
public import Mathlib.Data.Finset.Interval
public import Mathlib.Basic.Real.Basic

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- Linked-cluster subtraction on labeled finite subsets. The recursive subtraction
of proper subcluster weights uniquely recovers the Möbius coefficients of the observable. -/
def LinkedClusterInversion (n : ℕ) : Prop :=
  ∀ (obs weight : Finset (Fin n) → ℝ),
    (∀ S, weight S = obs S - ∑ T ∈ S.powerset.erase S, weight T) →
      ∀ S, weight S = ∑ T ∈ S.powerset, IncidenceAlgebra.mu ℝ T S * obs T

end FormalQChem.Algorithms
