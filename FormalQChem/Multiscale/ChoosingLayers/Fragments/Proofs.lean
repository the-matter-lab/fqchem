module

public import FormalQChem.Multiscale.ChoosingLayers.Fragments.Theorems
public import Mathlib.Tactic.Ring
public import Mathlib.Tactic.Linarith

@[expose] public section

namespace FormalQChem.Multiscale

open scoped BigOperators

theorem pairReconstruction : PairReconstruction := by
  intro n mono dimer interaction pair
  unfold fragmentEnergy
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j hj
  rw [pair i j (Finset.mem_filter.mp hj).2]
  ring

end FormalQChem.Multiscale
