module

public import Mathlib.Combinatorics.Enumerative.IncidenceAlgebra
public import Mathlib.Data.Finset.Interval
public import Mathlib.Basic.Real.Basic
import Mathlib.Tactic

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- Linked-cluster subtraction on labeled finite subsets. The recursive subtraction
of proper subcluster weights uniquely recovers the Möbius coefficients of the observable. -/
def LinkedClusterInversion (n : ℕ) : Prop :=
  ∀ (obs weight : Finset (Fin n) → ℝ),
    (∀ S, weight S = obs S - ∑ T ∈ S.powerset.erase S, weight T) →
      ∀ S, weight S = ∑ T ∈ S.powerset, IncidenceAlgebra.mu ℝ T S * obs T

theorem linkedClusterInversion (n : ℕ) : LinkedClusterInversion n := by
  intro obs w hw S
  have total (T : Finset (Fin n)) : obs T = ∑ U ∈ Finset.Iic T, w U := by
    rw [Finset.Iic_eq_powerset, ← Finset.sum_erase_add _ _ (Finset.mem_powerset_self T)]
    linarith [hw T]
  simpa only [Finset.Iic_eq_powerset] using IncidenceAlgebra.moebius_inversion_bot w obs total S

end FormalQChem.Algorithms
