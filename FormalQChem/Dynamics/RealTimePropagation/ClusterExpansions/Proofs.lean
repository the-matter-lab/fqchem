module

public import FormalQChem.Dynamics.RealTimePropagation.ClusterExpansions.Theorems
import Mathlib.Tactic

public section
namespace FormalQChem.Algorithms

theorem linkedClusterInversion (n : ℕ) : LinkedClusterInversion n := by
  intro obs w hw S
  have total (T : Finset (Fin n)) : obs T = ∑ U ∈ Finset.Iic T, w U := by
    rw [Finset.Iic_eq_powerset, ← Finset.sum_erase_add _ _ (Finset.mem_powerset_self T)]
    linarith [hw T]
  simpa only [Finset.Iic_eq_powerset] using IncidenceAlgebra.moebius_inversion_bot w obs total S

end FormalQChem.Algorithms
