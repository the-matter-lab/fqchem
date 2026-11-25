module

public import FQChem.Unproven.CoupledCluster
import Mathlib.Data.Finset.Sort
import Mathlib.Tactic

/-! # Independent electrons in an ordered orbital basis

For a diagonal one-body Hamiltonian, filling the lowest spin orbitals gives
the exact many-electron ground energy at every allowed electron number.
The coupled-cluster reference is already exact in this limit. Work is counted
from the supplied ordered orbital energies, with one read and one addition
per occupied orbital. See the [convexity discussion](https://arxiv.org/abs/2409.08632)
and the [coupled-cluster scaling conjecture](https://doi.org/10.1038/s41467-023-37587-6). -/

@[expose] public section
noncomputable section

namespace FQChem.StatePrep.IndependentOrbitals

open FQChem.Unproven.CoupledCluster FQChem.StatePrep.CoupledClusterReplicas
open scoped ComplexOrder Matrix

/-- The prefix sum of the ordered spin-orbital energies. -/
def filledEnergy (ε : ℕ → ℝ) (N : ℕ) := ∑ i ∈ Finset.range N, ε i

def occupiedEnergy {L N : ℕ} (ε : ℕ → ℝ) (s : Determinant L N) :=
  ∑ i ∈ s.val, ε i.val

def filled {L N : ℕ} (h : N ≤ L) : Determinant L N :=
  ⟨Finset.univ.map (Fin.castLEEmb h), by simp⟩

private theorem filled_eq {L N : ℕ} (ε : ℕ → ℝ) (h : N ≤ L) :
    occupiedEnergy ε (filled h) = filledEnergy ε N := by
  simpa only [occupiedEnergy, filled, Finset.sum_map, Fin.castLEEmb_apply, Fin.val_castLE,
    filledEnergy] using Fin.sum_univ_eq_sum_range ε N

private theorem filling_minimum {L N : ℕ} {ε : ℕ → ℝ} (ordered : Monotone ε)
    (s : Determinant L N) : filledEnergy ε N ≤ occupiedEnergy ε s := by
  let e := s.val.orderEmbOfFin s.property
  have index (i : Fin N) : i.val ≤ (e i).val := by
    obtain ⟨k, hk⟩ := i
    induction k with
    | zero => exact Nat.zero_le _
    | succ k ih =>
      have step := e.strictMono (show (⟨k, by omega⟩ : Fin N) < ⟨k+1,hk⟩ from Nat.lt_succ_self k)
      exact (ih (by omega)).trans_lt step
  calc
    filledEnergy ε N = ∑ i : Fin N, ε i.val := (Fin.sum_univ_eq_sum_range ε N).symm
    _ ≤ ∑ i : Fin N, ε (e i).val := Finset.sum_le_sum fun i _ => ordered (index i)
    _ = ∑ j : s.val, ε j.val.val := Equiv.sum_comp
      (s.val.orderIsoOfFin s.property).toEquiv (fun j => ε j.val.val)
    _ = occupiedEnergy ε s := Finset.sum_coe_sort s.val (fun j => ε j.val)

/-- Diagonal second-quantized one-body Hamiltonian in a fixed electron sector. -/
abbrev hamiltonian {L N : ℕ} (ε : ℕ → ℝ) : Matrix (Determinant L N) (Determinant L N) ℂ :=
  Matrix.diagonal fun s => (occupiedEnergy ε s : ℂ)

/-- Supply the filled reference determinant along with the Hamiltonian. -/
def model {L N : ℕ} (ε : ℕ → ℝ) (h : N ≤ L) : Instance where
  orbitals := L
  electrons := N
  reference := filled h
  hamiltonian := hamiltonian ε
  hermitian := Matrix.isHermitian_diagonal_of_self_adjoint _ (by ext s; simp)

/-- The filled determinant attains the ground energy over the full sector,
including arbitrary superpositions of determinants. -/
theorem fillingGround {L N : ℕ} {ε : ℕ → ℝ} (ordered : Monotone ε) (h : N ≤ L) :
    GroundAt (model ε h).hamiltonian (filledEnergy ε N) := by
  let E := filledEnergy ε N
  let H := Matrix.diagonal (fun s : Determinant L N => (occupiedEnergy ε s : ℂ))
  change GroundAt H E
  have shift : H - (E : ℂ) • 1 =
      Matrix.diagonal (fun s : Determinant L N => ((occupiedEnergy ε s - E : ℝ) : ℂ)) := by
    ext s t
    by_cases eq : s = t
    · subst t; simp [H, Matrix.sub_apply, Matrix.smul_apply]
    · simp [H, Matrix.sub_apply, Matrix.smul_apply, eq]
  constructor
  · rw [shift, Matrix.posSemidef_diagonal_iff]
    exact fun s => Complex.zero_le_real.mpr (sub_nonneg.mpr (filling_minimum ordered s))
  · refine ⟨Pi.single (filled h) 1, ?_, ?_⟩
    · intro eq
      simpa using congrFun eq (filled h)
    · ext s
      by_cases eq : s = filled h
      · subst s; simp [H, E, Matrix.mulVec, dotProduct, Matrix.diagonal_apply, filled_eq, Pi.smul_apply]
      · simp [H, Matrix.mulVec, dotProduct, Matrix.diagonal_apply, Pi.smul_apply, eq]

/-- Discrete convexity of the ground energies of independent fermions. -/
theorem fillingConvex {ε : ℕ → ℝ} (ordered : Monotone ε) (n : ℕ) :
    2 * filledEnergy ε (n+1) ≤ filledEnergy ε n + filledEnergy ε (n+2) := by
  simp only [filledEnergy, Finset.sum_range_succ]
  linarith [ordered (Nat.le_succ n)]

/-- Strict binding at the next filling implies strict binding at the present one. -/
theorem fillingConsecutiveBinding {ε : ℕ → ℝ} (ordered : Monotone ε) (n : ℕ)
    (binds : filledEnergy ε (n+2) < filledEnergy ε (n+1)) :
    filledEnergy ε (n+1) < filledEnergy ε n := by
  linarith [fillingConvex ordered n]

/-- A positive semidefinite interaction can only increase the lowest energy in
a fixed finite determinant sector, even if it mixes different determinants. -/
theorem repulsiveLowerBound {L N : ℕ} {ε : ℕ → ℝ} (ordered : Monotone ε) (h : N ≤ L)
    (V : Matrix (Determinant L N) (Determinant L N) ℂ) (repulsive : V.PosSemidef)
    {E : ℝ} (ground : GroundAt (hamiltonian ε + V) E) : filledEnergy ε N ≤ E := by
  let H := hamiltonian (L := L) (N := N) ε
  let B := filledEnergy ε N
  obtain ⟨_, v, hv, eigen⟩ := ground
  change (H + V) *ᵥ v = (E : ℂ) • v at eigen
  have lower : (H - (B : ℂ) • 1).PosSemidef := (fillingGround ordered h).1
  have shifted : (H + V - (B : ℂ) • 1).PosSemidef := by
    rw [show H + V - (B : ℂ) • 1 = (H - (B : ℂ) • 1) + V by abel]
    exact lower.add repulsive
  have quad := shifted.dotProduct_mulVec_nonneg v
  rw [Matrix.sub_mulVec, eigen, Matrix.smul_mulVec, Matrix.one_mulVec,
    ← sub_smul, dotProduct_smul, smul_eq_mul] at quad
  by_contra! bad
  have negative : (E : ℂ) - (B : ℂ) < 0 := sub_neg.mpr (Complex.real_lt_real.mpr bad)
  exact (not_lt_of_ge quad) (mul_neg_of_neg_of_pos negative (Matrix.dotProduct_star_self_pos_iff.mpr hv))

/-- At the first electron number, convexity survives arbitrary repulsive
two-electron matrix elements. The vacuum energy is zero. -/
theorem twoElectronConvexity {L : ℕ} {ε : ℕ → ℝ} (ordered : Monotone ε) (h : 2 ≤ L)
    (V : Matrix (Determinant L 2) (Determinant L 2) ℂ) (repulsive : V.PosSemidef)
    {E₂ : ℝ} (ground : GroundAt (hamiltonian ε + V) E₂) :
    2 * filledEnergy ε 1 ≤ E₂ := by
  have convex := fillingConvex ordered 0
  have lower := repulsiveLowerBound ordered h V repulsive ground
  simpa [filledEnergy, Finset.sum_range_succ] using
    (convex.trans (add_le_add_right lower (filledEnergy ε 0)))

/-- Evaluate the energy and count one orbital-energy read and one addition per step. -/
def fill (ε : ℕ → ℝ) : ℕ → ℝ × ℕ
  | 0 => (0, 0)
  | n+1 => let (energy, work) := fill ε n; (energy + ε n, work + 2)

theorem fill_spec (ε : ℕ → ℝ) (n : ℕ) : fill ε n = (filledEnergy ε n, 2 * n) := by
  induction n with
  | zero => simp [fill, filledEnergy]
  | succ n ih => simp [fill, ih, filledEnergy, Finset.sum_range_succ, Nat.mul_succ]

/-- All orbital counts, electron counts, and ordered one-body spectra. -/
structure Spectrum where
  orbitals : ℕ
  electrons : ℕ
  fits : electrons ≤ orbitals
  energy : ℕ → ℝ
  ordered : Monotone energy

/-- In the supplied eigenbasis there are no excitation amplitudes to solve for.
The count includes evaluating the projected energy by filling. -/
def run (s : Spectrum) (_ : ℕ) : Option (List (Amplitude (model s.energy s.fits)) × ℕ) :=
  some ([], (fill s.energy s.electrons).2)

/-- The joint work bound holds on the entire independent-orbital family, with
exact energy and at most two arithmetic-model operations per occupied orbital. -/
theorem polynomialWork :
    PolynomialWork (fun s : Spectrum => model s.energy s.fits) Set.univ run := by
  refine ⟨2, 1, 0, ?_⟩
  intro s _ k hk
  refine ⟨[], 2*s.electrons, ?_, ?_, filledEnergy s.energy s.electrons,
    fillingGround s.ordered s.fits, ?_⟩
  · simp [run, fill_spec]
  · have fits := s.fits
    simp [model]; omega
  · have empty (x : Instance) : clusterMatrix x [] = 0 := by
      unfold clusterMatrix
      rw [List.map_nil, List.sum_nil, map_zero]
    simp only [empty, FQChem.VariationalMethods.transformed, neg_zero, NormedSpace.exp_zero,
      Matrix.one_mul, Matrix.mul_one]
    change ‖Matrix.diagonal (fun t : Determinant s.orbitals s.electrons => (occupiedEnergy s.energy t : ℂ))
      (filled s.fits) (filled s.fits) - _‖ ≤ _
    simp [filled_eq]


end FQChem.StatePrep.IndependentOrbitals
