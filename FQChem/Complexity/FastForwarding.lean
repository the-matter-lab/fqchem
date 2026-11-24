module

public import FQChem.Dynamics.RealTimePropagation.SchrodingerGroup
import Mathlib.Tactic

/-!
# Fast-forwarding by concatenation

Atia and Aharonov, *Fast-forwarding of Hamiltonians and exponentially precise
measurements*, arXiv:1610.09619v2, Lemma 3. The simulator acts on a workspace
containing the system and a clean ancilla. Its error guarantee is required only
on normalized system inputs embedded with that ancilla. The approximate output
may leave the clean subspace, so the hybrid argument applies the next
approximation guarantee to the **ideal** intermediate state.
-/

@[expose] public section
noncomputable section

namespace FQChem.Complexity.FastForwarding

open FQChem.Dynamics.RealTimePropagation

variable {E F G : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E]
variable [NormedAddCommGroup F] [InnerProductSpace ℂ F]

/-- A gate alphabet on the simulation workspace. The leftmost gate runs first. -/
def run (gate : G → F ≃ₗᵢ[ℂ] F) : List G → F ≃ₗᵢ[ℂ] F
  | [] => LinearIsometryEquiv.refl ℂ F
  | g :: w => (gate g).trans (run gate w)

/-- Concatenate k instances of the same physical circuit. -/
def copies (w : List G) : ℕ → List G
  | 0 => []
  | k + 1 => copies w k ++ w

theorem copies_length (w : List G) (k : ℕ) : (copies w k).length = k * w.length := by
  induction k with
  | zero => simp [copies]
  | succ k ih => simp [copies, ih, Nat.succ_mul]

private theorem run_append (gate : G → F ≃ₗᵢ[ℂ] F) (a b : List G) (x : F) :
    run gate (a ++ b) x = run gate b (run gate a x) := by
  induction a generalizing x with
  | nil => rfl
  | cons g a ih => exact ih (gate g x)

/-- A realization of the paper's clean-ancilla accuracy requirement with an
explicit finite-word gate budget. The embedding represents ψ ↦ ψ ⊗ |0⟩.
The constructor of a suitable word may depend on the requested evolution time. -/
def SimulatesUpTo (H : E →L[ℂ] E) (gate : G → F ≃ₗᵢ[ℂ] F)
    (clean : E →ₗᵢ[ℂ] F) (T α : ℝ) (budget : ℕ) : Prop :=
  ∀ t : ℝ, 0 ≤ t → t ≤ T → ∃ w : List G, w.length ≤ budget ∧
    ∀ ψ : E, ‖ψ‖ = 1 → dist (run gate w (clean ψ)) (clean (evolution H t ψ)) ≤ α

/-- A k-segment circuit accumulates at most kα error even if its approximate
intermediate states have acquired a nonzero ancilla component. -/
theorem repeat_error (H : E →L[ℂ] E) (hH : IsSelfAdjoint H) (gate : G → F ≃ₗᵢ[ℂ] F)
    (clean : E →ₗᵢ[ℂ] F) (w : List G) {s α : ℝ}
    (step : ∀ ψ : E, ‖ψ‖ = 1 → dist (run gate w (clean ψ)) (clean (evolution H s ψ)) ≤ α)
    (k : ℕ) (ψ : E) (hψ : ‖ψ‖ = 1) :
    dist (run gate (copies w k) (clean ψ)) (clean (evolution H (k * s) ψ)) ≤ k * α := by
  obtain ⟨hz, hadd, hunitary, _⟩ := unitaryEvolution H hH
  induction k with
  | zero => simp [copies, run, hz]
  | succ k ih =>
    let ideal := evolution H (k * s) ψ
    have hi : ‖ideal‖ = 1 := (ContinuousLinearMap.norm_map_of_mem_unitary (hunitary _) ψ).trans hψ
    have time : ((k + 1 : ℕ) : ℝ) * s = s + k * s := by push_cast; ring
    rw [copies, run_append, time, hadd]
    calc
      _ ≤ dist (run gate w (run gate (copies w k) (clean ψ))) (run gate w (clean ideal)) +
          dist (run gate w (clean ideal)) (clean (evolution H s ideal)) := dist_triangle _ _ _
      _ ≤ k * α + α := add_le_add (by rwa [(run gate w).dist_map]) (step ideal hi)
      _ = _ := by push_cast; ring

/-- Atia–Aharonov, FF by concatenation (arXiv v2, Lemma 3). For every requested
time in [0,kT], use k copies of a circuit for t/k. The gate count is at most kB
and the error at most kα. In particular a fixed k preserves a polynomial gate
budget for a family of systems. -/
theorem byConcatenation (H : E →L[ℂ] E) (hH : IsSelfAdjoint H) (gate : G → F ≃ₗᵢ[ℂ] F)
    (clean : E →ₗᵢ[ℂ] F) {T α : ℝ} {budget k : ℕ} (hk : 0 < k)
    (short : SimulatesUpTo H gate clean T α budget) :
    SimulatesUpTo H gate clean (k * T) (k * α) (k * budget) := by
  intro t ht hT
  have pos : 0 < (k : ℝ) := by exact_mod_cast hk
  have segment : t / k ≤ T := (div_le_iff₀ pos).mpr (by simpa [mul_comm] using hT)
  obtain ⟨w, hw, err⟩ := short (t / k) (div_nonneg ht pos.le) segment
  refine ⟨copies w k, (copies_length w k).trans_le (Nat.mul_le_mul_left k hw), ?_⟩
  intro ψ hψ
  have h := repeat_error H hH gate clean w err k ψ hψ
  rwa [← mul_div_assoc, mul_div_cancel_left₀ _ pos.ne'] at h

end FQChem.Complexity.FastForwarding
