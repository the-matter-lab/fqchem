module

public import FQChem.Complexity.FixedBasisGaussians
public import Mathlib.Combinatorics.SimpleGraph.Basic
import Mathlib.Tactic

/-! # Placing orbital components for a finite interaction graph

Each spatial orbital i has one component for each possible partner j.
The two components associated with the unordered pair {i,j} occupy a
private interval on a line in three-space. Edge ends have separation 4;
all components of different nonadjacent vertices have separation at least R.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.FixedBasisGeometry
open FixedBasisGaussians Classical
variable {n : ℕ}

def block (i j : Fin n) := (finProdFinEquiv (min i j,max i j)).val

private theorem sameBlock {i j u v : Fin n} (h : block i j = block u v) :
    (i=u ∧ j=v) ∨ (i=v ∧ j=u) := by
  have eq := finProdFinEquiv.injective (Fin.ext h)
  change (min i j,max i j) = (min u v,max u v) at eq
  rcases le_total i j with h₁ | h₁ <;> rcases le_total u v with h₂ | h₂ <;>
    simp_all

open Classical in
def offset (G : SimpleGraph (Fin n)) (R : ℕ) (i j : Fin n) :=
  if i≤j then 0 else if G.Adj i j then 4 else R

def coordinate (G : SimpleGraph (Fin n)) (R : ℕ) (i j : Fin n) :=
  block i j*(3*R) + offset G R i j

def center (G : SimpleGraph (Fin n)) (R : ℕ) (i j : Fin n) : Space :=
  EuclideanSpace.single 0 (coordinate G R i j : ℝ)

private theorem lineDistance (G : SimpleGraph (Fin n)) (R : ℕ) (i j u v : Fin n) :
    dist (center G R i j) (center G R u v) =
      |(coordinate G R i j : ℝ) - (coordinate G R u v : ℝ)| := by
  rw [dist_eq_norm]
  simp only [center, ← PiLp.single_sub, PiLp.norm_single, Real.norm_eq_abs]

private theorem offset_le (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R) (i j : Fin n) :
    offset G R i j ≤ R := by unfold offset; split_ifs <;> omega

private theorem separateBlocks (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R)
    (i j u v : Fin n) (h : block i j < block u v) :
    (R:ℝ) ≤ dist (center G R i j) (center G R u v) := by
  have hm := Nat.mul_le_mul_right (3*R) (Nat.succ_le_of_lt h)
  rw [Nat.succ_mul] at hm
  have hpos : coordinate G R i j + R ≤ coordinate G R u v := by
    dsimp [coordinate]
    have := offset_le G R hR i j
    omega
  have hr : (coordinate G R i j : ℝ) + R ≤ coordinate G R u v := by exact_mod_cast hpos
  rw [lineDistance,abs_of_nonpos (by linarith [Nat.cast_nonneg (α:=ℝ) R])]
  linarith

private theorem partnerDistance (G : SimpleGraph (Fin n)) (R : ℕ) (i j : Fin n) (h : i<j) :
    dist (center G R i j) (center G R j i) = if G.Adj i j then 4 else (R:ℝ) := by
  classical
  rw [lineDistance]
  have same : block j i = block i j := by simp [block,min_comm j i,max_comm j i]
  simp only [coordinate,same,offset, h.le, ite_true, not_le.mpr h, ite_false, Nat.add_zero,
    Nat.cast_add, sub_add_eq_sub_sub, sub_self, zero_sub,abs_neg]
  by_cases adj : G.Adj i j <;> simp [adj,G.adj_comm j i]

theorem edgeDistance (G : SimpleGraph (Fin n)) (R : ℕ) {i j : Fin n} (h : G.Adj i j) :
    dist (center G R i j) (center G R j i) = 4 := by
  classical
  rcases lt_or_gt_of_ne h.ne with lt | gt
  · simp [partnerDistance G R i j lt,h]
  · rw [dist_comm]; simp [partnerDistance G R j i gt,h.symm]

/-- Every two distinct component centers are separated by at least four units.
This makes their closed unit balls disjoint, even across an edge. -/
theorem separated (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R)
    (i j u v : Fin n) (h : (i,j) ≠ (u,v)) :
    4 ≤ dist (center G R i j) (center G R u v) := by
  classical
  rcases lt_trichotomy (block i j) (block u v) with lt | eq | gt
  · exact (show (4:ℝ)≤R by exact_mod_cast hR).trans (separateBlocks G R hR i j u v lt)
  · rcases sameBlock eq with ⟨rfl,rfl⟩ | ⟨rfl,rfl⟩
    · exact (h rfl).elim
    · have ne : i≠j := by rintro rfl; exact h rfl
      rcases lt_or_gt_of_ne ne with lt | gt
      · rw [partnerDistance G R i j lt]; split <;> first | rfl | exact_mod_cast hR
      · rw [dist_comm,partnerDistance G R j i gt]; split <;> first | rfl | exact_mod_cast hR
  · rw [dist_comm]; exact (show (4:ℝ)≤R by exact_mod_cast hR).trans (separateBlocks G R hR u v i j gt)

/-- For different nonadjacent sites every pair of component supports is far. -/
theorem nonedgeDistance (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R)
    (i j u v : Fin n) (hne : i≠u) (hna : ¬G.Adj i u) :
    (R:ℝ) ≤ dist (center G R i j) (center G R u v) := by
  classical
  rcases lt_trichotomy (block i j) (block u v) with lt | eq | gt
  · exact separateBlocks G R hR i j u v lt
  · rcases sameBlock eq with ⟨rfl,rfl⟩ | ⟨rfl,rfl⟩
    · exact (hne rfl).elim
    · rcases lt_or_gt_of_ne hne with lt | gt
      · simp [partnerDistance G R _ _ lt,hna]
      · rw [dist_comm]; simp [partnerDistance G R _ _ gt,G.adj_comm,hna]
  · rw [dist_comm]; exact separateBlocks G R hR u v i j gt

/-- All n² component locations have integer coordinates below 3Rn²+R. -/
theorem coordinateBound (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R) (i j : Fin n) :
    coordinate G R i j < 3*R*n^2+R := by
  have hb : block i j < n*n := (finProdFinEquiv (min i j,max i j)).isLt
  have m := Nat.mul_lt_mul_of_pos_right hb (show 0<3*R by omega)
  dsimp [coordinate]; have := offset_le G R hR i j
  nlinarith

end FQChem.Complexity.FixedBasisGeometry
