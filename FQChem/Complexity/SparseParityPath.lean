module

public import Mathlib.Analysis.Normed.Algebra.MatrixExponential
public import Mathlib.LinearAlgebra.Matrix.Reindex
import Mathlib.Analysis.Matrix.Normed
import Mathlib.Tactic

/-!
# Berry–Ahokas–Cleve–Sanders parity path

The weighted two-track path in the proof of Theorem 3 of
[Berry et al.](https://doi.org/10.1007/s00220-006-0150-x) encodes one input bit
in the crossing between adjacent levels. Each row uses only its neighboring
bits. Relabeling each level by the prefix parity makes the Hamiltonian a direct
sum of two copies of the original spin path, and intertwines their propagators.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SparseParityPath

open Matrix NormedSpace
variable {N : ℕ}

abbrev Level (N : ℕ) := Fin (N+1)
abbrev Vertex (N : ℕ) := Level N × Bool

/-- Outside the N edges a read returns the known zero bit. -/
def bit (x : Fin N → Bool) (j : ℕ) : Bool := if h : j < N then x ⟨j,h⟩ else false

def prefixParity (x : Fin N → Bool) : ℕ → Bool
  | 0 => false
  | j+1 => prefixParity x j ^^ bit x j

/-- Spin-N/2 tridiagonal coupling, with ħ = 1. -/
def weight (N j : ℕ) : ℂ := (Real.sqrt ((N - j : ℕ) * (j+1 : ℕ) : ℝ) / 2 : ℝ)

def path (N : ℕ) : Matrix (Level N) (Level N) ℂ := Matrix.of fun r c =>
  if r.val+1 = c.val then weight N r else if c.val+1 = r.val then weight N c else 0

/-- The actual matrix entries depend only on an edge's bit, in either direction. -/
def crossed (x : Fin N → Bool) : Matrix (Vertex N) (Vertex N) ℂ := Matrix.of fun r c =>
  if r.1.val+1 = c.1.val then
    if c.2 = (r.2 ^^ bit x r.1) then weight N r.1 else 0
  else if c.1.val+1 = r.1.val then
    if r.2 = (c.2 ^^ bit x c.1) then weight N c.1 else 0
  else 0

theorem hermitian (x : Fin N → Bool) : (crossed x).IsHermitian := by
  ext r c
  simp only [Matrix.conjTranspose_apply, crossed, Matrix.of_apply]
  by_cases hr : r.1.val+1 = c.1.val
  · have hc : c.1.val+1 ≠ r.1.val := by omega
    by_cases edge : c.2 = (r.2 ^^ bit x r.1) <;> simp [hr, hc, weight, edge]
  · by_cases hc : c.1.val+1 = r.1.val
    · by_cases edge : r.2 = (c.2 ^^ bit x c.1) <;> simp [hr, hc, weight, edge]
    · simp [hr,hc]

/-- Giving the left and right incident bits suffices to determine the entire
row, including the two endpoints where only one neighbor exists. -/
theorem row_from_adjacent_bits (x y : Fin N → Bool) (r : Vertex N)
    (left : bit x (r.1.val-1) = bit y (r.1.val-1))
    (right : bit x r.1 = bit y r.1) : crossed x r = crossed y r := by
  funext c
  by_cases h : c.1.val+1 = r.1.val
  · have j : r.1.val-1 = c.1.val := by omega
    rw [j] at left
    simp [crossed, h, right, left]
  · simp [crossed, h, right]

private def level (N j : ℕ) : Level N := ⟨min j N, by omega⟩

/-- There are at most two nonzero entries per row for all N and all input strings. -/
theorem twoSparse (x : Fin N → Bool) (r : Vertex N) :
    (Finset.univ.filter fun c => crossed x r c ≠ 0).card ≤ 2 := by
  let prev : Vertex N := (level N (r.1.val-1), r.2 ^^ bit x (r.1.val-1))
  let next : Vertex N := (level N (r.1.val+1), r.2 ^^ bit x r.1)
  apply le_trans (Finset.card_le_card (t := {prev,next}) _) Finset.card_le_two
  intro c hc
  have nz := (Finset.mem_filter.mp hc).2
  simp only [crossed, Matrix.of_apply] at nz
  by_cases hr : r.1.val+1 = c.1.val
  · have eq : c.2 = (r.2 ^^ bit x r.1) := by by_contra h; simp [hr,h] at nz
    have cl := c.1.isLt
    have hlev : c.1 = level N (r.1.val+1) := Fin.ext (by simp [level,hr]; omega)
    have : c = next := Prod.ext hlev eq
    simp [this]
  · by_cases hl : c.1.val+1 = r.1.val
    · have eq : r.2 = (c.2 ^^ bit x c.1) := by by_contra h; simp [hr,hl,h] at nz
      have j : r.1.val-1 = c.1.val := by omega
      have cl := c.1.isLt
      have hlev : c.1 = level N (r.1.val-1) := Fin.ext (by simp [level,j]; omega)
      have hb : c.2 = (r.2 ^^ bit x (r.1.val-1)) := by rw [j,eq]; simp
      have : c = prev := Prod.ext hlev hb
      simp [this]
    · simp [hr,hl] at nz

def relabel (x : Fin N → Bool) : Vertex N ≃ Vertex N where
  toFun r := (r.1, r.2 ^^ prefixParity x r.1)
  invFun r := (r.1, r.2 ^^ prefixParity x r.1)
  left_inv r := by simp
  right_inv r := by simp

/-- Double the path into two tracks and relabel each level by its prefix parity. -/
def lift (x : Fin N → Bool) : Matrix (Level N) (Level N) ℂ →+* Matrix (Vertex N) (Vertex N) ℂ :=
  (reindexRingEquiv ℂ (relabel x)).toRingHom.comp
    ((blockDiagonalRingHom (Level N) Bool ℂ).comp (Pi.constRingHom Bool _))

private theorem lift_entry (x : Fin N → Bool) (A : Matrix (Level N) (Level N) ℂ)
    (r c : Vertex N) :
    lift x A r c = if (r.2 ^^ prefixParity x r.1) = (c.2 ^^ prefixParity x c.1) then A r.1 c.1 else 0 :=
  rfl

/-- The local crossed edges give exactly the direct-sum Hamiltonian in the
prefix-parity coordinates. -/
theorem crossed_eq_lift (x : Fin N → Bool) : crossed x = lift x (path N) := by
  ext r c
  simp only [lift_entry, crossed, path, Matrix.of_apply]
  by_cases hr : r.1.val+1 = c.1.val
  · simp only [hr, ↓reduceIte]
    rw [← hr, prefixParity]
    cases r.2 <;> cases c.2 <;> cases prefixParity x r.1 <;> cases bit x r.1 <;> simp
  · simp only [hr, ↓reduceIte]
    by_cases hc : c.1.val+1 = r.1.val
    · simp only [hc, ↓reduceIte]
      rw [← hc, prefixParity]
      cases r.2 <;> cases c.2 <;> cases prefixParity x c.1 <;> cases bit x c.1 <;> simp
    · simp [hc]

/-- The matrix exponential commutes with duplicating and crossing the two paths. -/
theorem evolution_lifts (x : Fin N → Bool) (t : ℝ) :
    exp ((-(t : ℂ) * Complex.I) • crossed x) =
      lift x (exp ((-(t : ℂ) * Complex.I) • path N)) := by
  have scaled : (-(t : ℂ) * Complex.I) • crossed x =
      lift x ((-(t : ℂ) * Complex.I) • path N) := by
    rw [crossed_eq_lift]
    ext r c
    simp only [Matrix.smul_apply, lift_entry, smul_eq_mul]
    split <;> simp
  rw [scaled]
  open scoped Matrix.Norms.Operator in
    apply (map_exp (lift x) _ _).symm
    apply continuous_matrix
    intro r c
    simp only [lift_entry]
    split <;> fun_prop

/-- At any time, the amplitude from level zero on track false to the far end
on the parity track equals the bare spin-path amplitude. The other track has
zero endpoint amplitude. This permits any global phase of the transferred ket. -/
theorem endpoint_amplitude (x : Fin N → Bool) (t : ℝ) (b : Bool) :
    exp ((-(t : ℂ) * Complex.I) • crossed x) (Fin.last N,b) (0,false) =
      if b = prefixParity x N then
        exp ((-(t : ℂ) * Complex.I) • path N) (Fin.last N) 0
      else 0 := by
  rw [evolution_lifts, lift_entry]
  cases b <;> cases h : prefixParity x N <;> simp [prefixParity, h]

end FQChem.Complexity.SparseParityPath
