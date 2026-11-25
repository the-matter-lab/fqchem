module

public import FQChem.Properties.NRepresentability.SlaterOccupations
public import Mathlib.Analysis.Matrix.PosDef
import Mathlib.Tactic

/-! # Finite-basis ensemble N-representability of the one-particle density matrix

In the trace-N convention, a Hermitian matrix is the one-particle reduced
density matrix of an ensemble of N fermions exactly when its natural spin-orbital
occupations are in [0,1] and sum to N. The witness reproduces orbital
occupation measurements in every orthonormal basis.
[A. J. Coleman (1963), §9](https://doi.org/10.1103/RevModPhys.35.668).
-/

@[expose] public section
noncomputable section
namespace FQChem.Properties.NRepresentability

open FQChem.Complexity.SlaterContraction Matrix
open scoped ComplexInnerProductSpace ComplexConjugate ComplexOrder
variable {d N : ℕ}

abbrev OneMatrix (d : ℕ) := Matrix (Fin d) (Fin d) ℂ

/-- A finite classical mixture of normalized vectors in the antisymmetric
N-electron space. Each wavefunction may be correlated. -/
structure Ensemble (d N : ℕ) where
  Label : Type
  [labels : Fintype Label]
  weight : Label → ℝ
  nonneg : ∀ a, 0 ≤ weight a
  total : ∑ a, weight a = 1
  state : Label → Sector (Fin d) N
  normalized : ∀ a, ∑ s, born (EuclideanSpace.basisFun (Fin d) ℂ) (state a) s = 1

attribute [instance] Ensemble.labels

/-- Joint probability for a complete pattern of measurement outcomes. -/
def Ensemble.law (e : Ensemble d N) (b : OrbitalBasis d) (s : Determinant d N) :=
  ∑ a, e.weight a * born b (e.state a) s

private theorem ensemble_weights (e : Ensemble d N) (b : OrbitalBasis d) :
    (∀ s, 0 ≤ e.law b s) ∧ ∑ s, e.law b s = 1 := by
  refine ⟨fun s => Finset.sum_nonneg fun a _ => mul_nonneg (e.nonneg a) (sq_nonneg _), ?_⟩
  unfold Ensemble.law
  rw [Finset.sum_comm]
  simpa only [← Finset.mul_sum, born_sum_basis_independent b (EuclideanSpace.basisFun (Fin d) ℂ),
    e.normalized, mul_one] using e.total

/-- The ensemble gives the Born expectation of the candidate one-matrix for
each orbital, including orbitals in bases with off-diagonal coherences. -/
def OneRepresentable (N : ℕ) (γ : OneMatrix d) : Prop :=
  γ.IsHermitian ∧ ∃ e : Ensemble d N, ∀ (b : OrbitalBasis d) i,
    occupations (e.law b) i = (inner ℂ (b i) (γ.toEuclideanLin (b i))).re

private theorem spectralReadout {γ : OneMatrix d} (h : γ.IsHermitian) (b : OrbitalBasis d)
    (i : Fin d) : (inner ℂ (b i) (γ.toEuclideanLin (b i))).re =
    ∑ j, h.eigenvalues j * ‖b.repr (h.eigenvectorBasis j) i‖^2 := by
  let v := b i
  let B := h.eigenvectorBasis
  have eigen (j) : γ.toEuclideanLin (B j) = (h.eigenvalues j : ℂ) • B j := by
    apply PiLp.ext; intro k
    exact congrFun (h.mulVec_eigenvectorBasis j) k
  have decomp := congrArg (fun y => (inner ℂ v (γ.toEuclideanLin y)).re) (B.sum_repr' v)
  rw [← decomp]
  simp only [map_sum, map_smul, eigen, inner_sum, inner_smul_right, Complex.re_sum]
  apply Finset.sum_congr rfl; intro j _
  rw [OrthonormalBasis.repr_apply_apply, show inner ℂ (B j) v = conj (inner ℂ v (B j)) from
    (inner_conj_symm _ _).symm]
  rw [mul_left_comm, mul_comm (conj _), Complex.mul_conj]
  simp [B, v, Complex.normSq_eq_norm_sq, -Complex.ofReal_pow]

def occupiedFrame (b : OrbitalBasis d) (s : Determinant d N) : Frame (Fin d) N :=
  fun j => b (s.val.orderEmbOfFin s.property j)

theorem occupiedFrame_orthonormal (b : OrbitalBasis d) (s : Determinant d N) :
    Orthonormal ℂ (occupiedFrame b s) :=
  b.orthonormal.comp _ (s.val.orderEmbOfFin s.property).injective

/-- An ensemble of Slater determinants in a single orbital basis. -/
def slaterEnsemble (b : OrbitalBasis d) (w : Determinant d N → ℝ)
    (hw : ∀ s, 0 ≤ w s) (total : ∑ s, w s = 1) : Ensemble d N where
  Label := Determinant d N
  weight := w
  nonneg := hw
  total := total
  state s := ket (occupiedFrame b s)
  normalized s := slaterBorn_total _ _ (occupiedFrame_orthonormal b s)

private theorem occupied_sum (w : Determinant d N → ℝ) (f : Fin d → ℝ) :
    (∑ s, w s * ∑ j, f (s.val.orderEmbOfFin s.property j)) =
      ∑ i, occupations w i * f i := by
  have subsum (s : Determinant d N) : ∑ j, f (s.val.orderEmbOfFin s.property j) =
      ∑ i ∈ s.val, f i :=
    (Equiv.sum_comp (s.val.orderIsoOfFin s.property).toEquiv (fun i => f i.val)).trans
      (Finset.sum_coe_sort s.val f)
  simp_rw [subsum]
  unfold occupations
  simp only [Finset.sum_mul, ite_mul, zero_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl; intro s _
  simp [Finset.mul_sum, Finset.sum_ite_mem]

/-- A determinant mixture diagonal in b is measured in an arbitrary basis c. -/
theorem slaterEnsemble_readout (b c : OrbitalBasis d) (w : Determinant d N → ℝ)
    (hw : ∀ s, 0 ≤ w s) (total : ∑ s, w s = 1) (i : Fin d) :
    occupations ((slaterEnsemble b w hw total).law c) i =
      ∑ j, occupations w j * ‖c.repr (b j) i‖^2 := by
  let e := slaterEnsemble b w hw total
  have mixture : occupations (e.law c) i =
      ∑ s, w s * occupations (born c (ket (occupiedFrame b s))) i := by
    change (∑ t : Determinant d N, if i ∈ t.val then
      ∑ s : Determinant d N, w s * born c (ket (occupiedFrame b s)) t else 0) = _
    unfold occupations
    simp only [Finset.mul_sum, mul_ite, mul_zero]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro t _
    by_cases h : i ∈ t.val <;> simp [h]
  rw [mixture]
  simp_rw [slaterOccupation c _ (occupiedFrame_orthonormal _ _)]
  exact occupied_sum w (fun j => ‖c.repr (b j) i‖^2)

/-- Coleman's ensemble theorem, with natural occupation numbers in the
trace-N normalization. The forward implication allows arbitrary mixed states.
In the reverse direction an explicit mixture of Slater determinants suffices. -/
theorem coleman {γ : OneMatrix d} (h : γ.IsHermitian) :
    OneRepresentable N γ ↔
      (∀ i, 0 ≤ h.eigenvalues i ∧ h.eigenvalues i ≤ 1) ∧ ∑ i, h.eigenvalues i = N := by
  constructor
  · rintro ⟨_, e, measured⟩
    have diag : occupations (e.law h.eigenvectorBasis) = h.eigenvalues := by
      funext i
      rw [measured]
      rw [EuclideanSpace.inner_eq_star_dotProduct]
      rw [dotProduct_comm]
      exact (h.eigenvalues_eq i).symm
    obtain ⟨hw, ht⟩ := ensemble_weights e h.eigenvectorBasis
    simpa only [diag] using occupation_bounds hw ht
  · rintro ⟨bounds, mass⟩
    obtain ⟨w, hw, ht, occ⟩ := exists_occupation_weights h.eigenvalues
      (fun i => (bounds i).1) (fun i => (bounds i).2) mass
    refine ⟨h, slaterEnsemble h.eigenvectorBasis w hw ht, fun b i => ?_⟩
    rw [slaterEnsemble_readout, occ, spectralReadout h]

private theorem hole_positive_iff {γ : OneMatrix d} (h : γ.IsHermitian) :
    (1 - γ).PosSemidef ↔ ∀ i, h.eigenvalues i ≤ 1 := by
  let U := Unitary.conjStarAlgAut ℂ _ h.eigenvectorUnitary
  have diag : diagonal (fun i => ((1 - h.eigenvalues i : ℝ) : ℂ)) =
      (1 : OneMatrix d) - diagonal (RCLike.ofReal ∘ h.eigenvalues) := by
    ext i j
    by_cases eq : i = j <;> simp [eq]
  have holes : 1 - γ = U (diagonal (fun i => ((1 - h.eigenvalues i : ℝ) : ℂ))) := by
    rw [diag, map_sub, map_one]
    exact congrArg (1 - ·) h.spectral_theorem
  rw [holes]
  simp [U, Unitary.isUnit_coe.posSemidef_star_right_conjugate_iff, posSemidef_diagonal_iff, Complex.le_def]

/-- In operator form a one-particle density matrix is ensemble N-representable
exactly when both the particle and hole matrices are positive and the trace is N. -/
theorem coleman_operator (γ : OneMatrix d) :
    OneRepresentable N γ ↔ γ.PosSemidef ∧ (1 - γ).PosSemidef ∧ γ.trace = (N : ℂ) := by
  constructor
  · intro rep
    have h := rep.1
    obtain ⟨bounds, mass⟩ := (coleman h).mp rep
    refine ⟨h.posSemidef_iff_eigenvalues_nonneg.mpr (fun i => (bounds i).1),
      (hole_positive_iff h).mpr (fun i => (bounds i).2), ?_⟩
    rw [h.trace_eq_sum_eigenvalues]
    change (∑ i, Complex.ofReal (h.eigenvalues i)) = (N : ℂ)
    rw [← Complex.ofReal_sum, mass, Complex.ofReal_natCast]
  · rintro ⟨pos, hole, trace⟩
    have h := pos.isHermitian
    apply (coleman h).mpr
    refine ⟨fun i => ⟨pos.eigenvalues_nonneg i, (hole_positive_iff h).mp hole i⟩, ?_⟩
    rw [h.trace_eq_sum_eigenvalues] at trace
    simpa [Complex.re_sum] using congrArg Complex.re trace

end FQChem.Properties.NRepresentability
