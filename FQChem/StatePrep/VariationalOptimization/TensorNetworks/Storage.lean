module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.CircuitSimulation
import Mathlib.Tactic

/-! # Scalar storage of the dense MPS update schedule

This is peak live coefficient storage for dense tables. Input and residual matrices
coexist while the residual is filled. Once filled, only the pivot row and multipliers
are retained from that elimination stage. Integer indices and the representation of
individual field elements lie outside the scalar RAM accounting.
-/

@[expose] public section
namespace FQChem.Algorithms.MPSCircuit

/-- In a pivot step, the input and next residual coexist during materialization.
Afterward the saved pivot row and multiplier column coexist with the recursive call. -/
def eliminationSpace : ℕ → ℕ → ℕ
  | 0, _ => 0
  | r+1, c => max ((r+1)*c + r*c + r+c+1) (r+c+1 + eliminationSpace r c)

theorem elimination_space (r c : ℕ) : eliminationSpace r c ≤ 2*r*c+r^2+2*r := by
  induction r with
  | zero => simp [eliminationSpace]
  | succ r ih =>
    rw [eliminationSpace]
    apply max_le <;> nlinarith

/-- The four merged input blocks, theta, elimination temporaries and both copies of
the factor data (the returned terms and materialized output sites). -/
def pairSpace (l r bond : ℕ) :=
  8*l*r + eliminationSpace (2*l) (2*r) + 2*(2*l*bond+2*bond*r)

variable {K : Type*} [Field K] [DecidableEq K]

theorem pair_space {l m r χ : ℕ} (G : Matrix Pair Pair K) (A : Site K l m) (B : Site K m r)
    (hl : l ≤ χ) (hr : r ≤ χ) :
    pairSpace l r (applyPair G A B).bond ≤ 36*χ^2 + 4*χ := by
  have hb : (applyPair G A B).bond ≤ 2*χ :=
    (newBond G A B).trans_le ((theta G A B).rank_le_height.trans (by omega))
  calc
    _ ≤ 8*χ*χ + (2*(2*χ)*(2*χ)+(2*χ)^2+2*(2*χ)) + 2*(2*χ*(2*χ)+2*(2*χ)*χ) := by
      unfold pairSpace
      have he := elimination_space (2*l) (2*r)
      apply Nat.add_le_add
      · apply Nat.add_le_add
        · gcongr
        · apply he.trans; gcongr
      · gcongr
    _ = _ := by ring

def gateSpace : {n l r : ℕ} → Gate K n → Chain K n l r → ℕ
  | _,_,_, .here G, .cons (l := l) A (.cons (m := r) B _) => pairSpace l r (applyPair G A B).bond
  | _,_,_, .there g, .cons _ C => gateSpace g C

private theorem gate_space {n l r χ : ℕ} (g : Gate K n) (C : Chain K n l r) (h : C.width ≤ χ) :
    gateSpace g C ≤ 36*χ^2+4*χ := by
  induction g generalizing l r with
  | here G =>
    cases C with | cons A tail =>
      cases tail with | cons B rest =>
        obtain ⟨hl,h'⟩ := max_le_iff.mp h
        exact pair_space G A B hl ((left_le_width rest).trans (max_le_iff.mp h').2)
  | there g ih =>
    cases C with | cons A rest => exact ih rest (max_le_iff.mp h).2

/-- Peak stored coefficients of the current chain and temporary tables across all updates. -/
def simulationSpace {n l r : ℕ} : List (Gate K n) → Chain K n l r → ℕ
  | [], C => C.stored
  | g :: gs, C => max (C.stored + gateSpace g C) (simulationSpace gs (advance g C).1)

theorem simulate_space {n l r χ : ℕ} (gs : List (Gate K n)) (C : Chain K n l r)
    (h : peakWidth gs C ≤ χ) : simulationSpace gs C ≤ 2*n*χ^2 + 36*χ^2 + 4*χ := by
  induction gs generalizing C with
  | nil => exact (stored_le C h).trans (by omega)
  | cons g gs ih =>
    obtain ⟨hc,hr⟩ := max_le_iff.mp h
    refine max_le ?_ (ih _ hr)
    have h' := Nat.add_le_add (stored_le C hc) (gate_space g C hc)
    omega

end FQChem.Algorithms.MPSCircuit
