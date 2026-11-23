module

public import Mathlib.Data.Finset.Card
public import Mathlib.Basic.Real.Basic

@[expose] public section
noncomputable section

namespace FormalQChem.Algorithms

/-- Number of occupied conflicting pairs in a classical configuration at zero drive. -/
def blockadeViolations {n : ℕ} (edges : Finset (Fin n × Fin n)) (s : Finset (Fin n)) :=
  (edges.filter (fun e => e.1 ∈ s ∧ e.2 ∈ s)).card

/-- Unit-detuning, uniform-penalty energy of an ideal zero-drive Rydberg blockade model. -/
def blockadeEnergy {n : ℕ} (edges : Finset (Fin n × Fin n)) (penalty : ℝ)
    (s : Finset (Fin n)) := penalty * blockadeViolations edges s - s.card

/-- For a penalty exceeding the number of sites, the ground configurations of the
blockade energy are exactly the maximum independent sets of the interaction graph. -/
def RydbergBlockade (n : ℕ) : Prop :=
  ∀ (edges : Finset (Fin n × Fin n)) (penalty : ℝ), (n : ℝ) < penalty →
    ∀ s, (∀ t, blockadeEnergy edges penalty s ≤ blockadeEnergy edges penalty t) ↔
      blockadeViolations edges s = 0 ∧
        ∀ t, blockadeViolations edges t = 0 → t.card ≤ s.card

end FormalQChem.Algorithms
