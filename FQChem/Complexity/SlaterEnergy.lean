module

public import FQChem.StatePrep.CircuitPreparation.SlaterDeterminants
public import FQChem.Complexity.ElectronicStructureOperators
public import Mathlib.Combinatorics.SimpleGraph.Clique
public import Mathlib.Analysis.CStarAlgebra.Matrix
public import Mathlib.LinearAlgebra.ExteriorPower.Basis
import Mathlib.Tactic

/-! # Independent sets and the diagonal spin-orbital Hamiltonian

O'Gorman et al., Appendix F, Eqs. (F1)–(F5). A fixed-particle occupation
is a set of distinct spin orbitals. Edge energies count the interacting
electron pairs, including both spin labels when a site is doubly occupied.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SlaterEnergy
open scoped ComplexConjugate InnerProductSpace
open ElectronicStructure
abbrev Mode (n : ℕ) := (Fin n ×ₗ Bool)
abbrev Sector (n k : ℕ) := Set.powersetCard (Mode n) k
abbrev Frame (n k : ℕ) := Fin k → EuclideanSpace ℂ (Mode n)

variable {n k : ℕ}

def vertex (p : Mode n) : Fin n := (ofLex p).1
def mode (i : Fin n) (spin : Bool) : Mode n := toLex (i,spin)

def sites (s : Finset (Mode n)) := s.image vertex

def doubles (s : Finset (Mode n)) :=
  Finset.univ.filter fun i : Fin n => mode i false ∈ s ∧ mode i true ∈ s

open Classical in
def pairs (G : SimpleGraph (Fin n)) (s : Finset (Mode n)) :=
  (s ×ˢ s).filter fun p => vertex p.1 < vertex p.2 ∧ G.Adj (vertex p.1) (vertex p.2)

/-- The diagonal entry of the two number-operator terms of Eq. (F1). -/
def cost (G : SimpleGraph (Fin n)) (U V : ℝ) (s : Sector n k) : ℝ :=
  U * (doubles s.val).card + V * (pairs G s.val).card

def Independent (G : SimpleGraph (Fin n)) (k : ℕ) :=
  ∃ S : Finset (Fin n), S.card = k ∧ G.IsIndepSet (S : Set (Fin n))

def polarized (S : Finset (Fin n)) (hk : S.card=k) : Sector n k :=
  ⟨S.image (fun i => mode i true), (Finset.card_image_of_injective (f := fun i => mode i true) S
    (fun _ _ h => congrArg vertex h)).trans hk⟩

theorem polarized_zero (G : SimpleGraph (Fin n)) (U V : ℝ) (S : Finset (Fin n))
    (hk : S.card=k) (hind : G.IsIndepSet (S : Set (Fin n))) :
    cost G U V (polarized S hk) = 0 := by
  classical
  have nil : doubles (polarized S hk).val = ∅ := by
    apply Finset.eq_empty_iff_forall_notMem.mpr
    intro i hi
    obtain ⟨x,_,hx⟩ := Finset.mem_image.mp (Finset.mem_filter.mp hi).2.1
    have := congrArg (fun m : Mode n => (ofLex m).2) hx
    contradiction
  have nil' : pairs G (polarized S hk).val = ∅ := by
    apply Finset.eq_empty_iff_forall_notMem.mpr
    intro p hp
    have ⟨inside,lt,adj⟩ := Finset.mem_filter.mp hp
    obtain ⟨i,hi,hp₁⟩ := Finset.mem_image.mp (Finset.mem_product.mp inside).1
    obtain ⟨j,hj,hp₂⟩ := Finset.mem_image.mp (Finset.mem_product.mp inside).2
    rw [← hp₁, ← hp₂] at lt adj
    exact (G.isIndepSet_iff.mp hind) hi hj (ne_of_lt lt) adj
  simp [cost,nil,nil']

private theorem injective_sites (s : Finset (Mode n)) (hs : doubles s = ∅) :
    Set.InjOn vertex (s : Set (Mode n)) := by
  intro p hp q hq h
  obtain ⟨i,b⟩ := p
  obtain ⟨j,c⟩ := q
  change i = j at h
  subst j
  cases b <;> cases c
  · rfl
  · have mem : i ∈ doubles s := Finset.mem_filter.mpr ⟨Finset.mem_univ _,hp,hq⟩
    simp [hs] at mem
  · have mem : i ∈ doubles s := Finset.mem_filter.mpr ⟨Finset.mem_univ _,hq,hp⟩
    simp [hs] at mem
  · rfl

private theorem independent_sites (G : SimpleGraph (Fin n)) (s : Finset (Mode n))
    (h : pairs G s = ∅) : G.IsIndepSet (sites s : Set (Fin n)) := by
  classical
  apply G.isIndepSet_iff.mpr
  intro i hi j hj hne adj
  obtain ⟨p,hp,rfl⟩ := Finset.mem_image.mp hi
  obtain ⟨q,hq,rfl⟩ := Finset.mem_image.mp hj
  rcases lt_or_gt_of_ne hne with lt | gt
  · have mem : (p,q) ∈ pairs G s := Finset.mem_filter.mpr ⟨Finset.mem_product.mpr ⟨hp,hq⟩,lt,adj⟩
    simp [h] at mem
  · have mem : (q,p) ∈ pairs G s := Finset.mem_filter.mpr ⟨Finset.mem_product.mpr ⟨hq,hp⟩,gt,adj.symm⟩
    simp [h] at mem

/-- Without an independent k-set every k-electron configuration has a
doubly occupied site or an interacting edge. The NO bound already holds
when the onsite penalty is at least the edge penalty. -/
theorem noInstance (G : SimpleGraph (Fin n)) (U V : ℝ) (hU : V ≤ U) (hV : 0 ≤ V)
    (hno : ¬ Independent G k) (s : Sector n k) : V ≤ cost G U V s := by
  classical
  by_cases d : (doubles s.val).Nonempty
  · have one : (1:ℝ) ≤ (doubles s.val).card := by exact_mod_cast d.card_pos
    exact (hU.trans (le_mul_of_one_le_right (hV.trans hU) one)).trans
      (le_add_of_nonneg_right (mul_nonneg hV (Nat.cast_nonneg _)))
  · have e : (pairs G s.val).Nonempty := by
      by_contra empty
      exact hno ⟨sites s.val, (Finset.card_image_of_injOn
        (injective_sites _ (Finset.not_nonempty_iff_eq_empty.mp d))).trans s.property,
        independent_sites G _ (Finset.not_nonempty_iff_eq_empty.mp empty)⟩
    have one : (1:ℝ) ≤ (pairs G s.val).card := by exact_mod_cast e.card_pos
    exact (le_mul_of_one_le_right hV one).trans
      (le_add_of_nonneg_left (mul_nonneg (hV.trans hU) (Nat.cast_nonneg _)))

/-- Occupation amplitudes of the exterior product of k occupied orbitals. -/
def amplitudes (f : Frame n k) (s : Sector n k) : ℂ :=
  ((EuclideanSpace.basisFun (Mode n) ℂ).toBasis.exteriorPower k).repr
    (exteriorPower.ιMulti ℂ k f) s

def IsSlater (ψ : Sector n k → ℂ) :=
  ∃ f : Frame n k, Orthonormal ℂ f ∧ amplitudes f = ψ

/-- Every occupation basis vector is a single determinant of orthonormal
coordinate orbitals. This supplies the YES witness in the Slater subclass. -/
theorem occupation_slater (s : Sector n k) :
    IsSlater (fun t => if s=t then 1 else 0) := by
  classical
  let b := EuclideanSpace.basisFun (Mode n) ℂ
  let e := Set.powersetCard.ofFinEmbEquiv.symm s
  refine ⟨b ∘ e, b.orthonormal.comp _ e.injective, ?_⟩
  funext t
  change (b.toBasis.exteriorPower k).repr (exteriorPower.ιMulti_family ℂ k b.toBasis s) t = _
  rw [exteriorPower.basis_repr]
  simp [Finsupp.single_apply]

def diagonal (G : SimpleGraph (Fin n)) (U V : ℝ) :
    Matrix (Sector n k) (Sector n k) ℂ := Matrix.diagonal fun s => (cost G U V s : ℂ)

theorem diagonal_energy (G : SimpleGraph (Fin n)) (U V : ℝ) (ψ : Sector n k → ℂ) :
    matrixExpectation (diagonal G U V) ψ = ∑ s, ‖ψ s‖^2 * cost G U V s := by
  unfold matrixExpectation diagonal
  simp only [Matrix.mulVec_diagonal, Complex.re_sum]
  apply Finset.sum_congr rfl
  intro s _
  rw [show conj (ψ s)*((cost G U V s : ℂ)*ψ s) = (cost G U V s : ℂ)*(ψ s*conj (ψ s)) by ring,
    Complex.mul_conj, Complex.sq_norm]
  simp [mul_comm]

/-- Separation of the Slater YES and NO energies under any perturbation
whose expectation error on the fixed-particle sector is bounded by ε.
An additive energy offset is allowed. -/
theorem slaterDecisionGap (G : SimpleGraph (Fin n)) (U V shift ε : ℝ)
    (hU : V ≤ U) (hV : 0 ≤ V) (H : Matrix (Sector n k) (Sector n k) ℂ)
    (herr : ∀ ψ, mass ψ = 1 →
      |matrixExpectation H ψ - shift - matrixExpectation (diagonal G U V) ψ| ≤ ε) :
    (Independent G k → ∃ ψ, IsSlater ψ ∧ mass ψ = 1 ∧ matrixExpectation H ψ ≤ shift+ε) ∧
    (¬ Independent G k → ∀ ψ, mass ψ = 1 → shift+V-ε ≤ matrixExpectation H ψ) := by
  classical
  constructor
  · rintro ⟨S,hk,hind⟩
    let s := polarized S hk
    let ψ : Sector n k → ℂ := fun t => if s=t then 1 else 0
    have normed : mass ψ = 1 := by simp [mass,ψ,apply_ite]
    have zero : matrixExpectation (diagonal G U V) ψ = 0 := by
      rw [diagonal_energy]
      simpa [ψ, Finset.sum_ite_eq, apply_ite] using polarized_zero G U V S hk hind
    refine ⟨ψ,occupation_slater s,normed,?_⟩
    have upper := (abs_le.mp (herr ψ normed)).2
    linarith
  · intro hno ψ normed
    have lower := (abs_le.mp (herr ψ normed)).1
    have costLower : V ≤ matrixExpectation (diagonal G U V) ψ := by
      rw [diagonal_energy]
      calc
        V = ∑ s, ‖ψ s‖^2 * V := by rw [← Finset.sum_mul]; change V = mass ψ * V; rw [normed,one_mul]
        _ ≤ _ := Finset.sum_le_sum fun s _ => mul_le_mul_of_nonneg_left (noInstance G U V hU hV hno s) (sq_nonneg _)
    linarith

def operator {ι : Type*} [Fintype ι] [DecidableEq ι] (A : Matrix ι ι ℂ) :
    EuclideanSpace ℂ ι →L[ℂ] EuclideanSpace ℂ ι := Matrix.toEuclideanCLM (𝕜 := ℂ) (n := ι) A

/-- A scalar offset and an operator-norm bound supply the uniform energy-error
hypothesis of the fixed-particle reduction. -/
theorem expectationPerturbation {ι : Type*} [Fintype ι] [DecidableEq ι]
    (H D : Matrix ι ι ℂ) (shift : ℝ) (ψ : ι → ℂ) (hψ : mass ψ = 1) :
    |matrixExpectation H ψ - shift - matrixExpectation D ψ| ≤
      ‖operator H - (shift : ℂ) • ContinuousLinearMap.id ℂ _ - operator D‖ := by
  let z := WithLp.toLp 2 ψ
  have normed : ‖z‖=1 := by
    have sq : ‖z‖^2=1 := (EuclideanSpace.norm_sq_eq z).trans hψ
    nlinarith [norm_nonneg z]
  have energy (A : Matrix ι ι ℂ) : matrixExpectation A ψ = (⟪z,operator A z⟫_ℂ).re := by
    simp [matrixExpectation,z,operator,EuclideanSpace.inner_eq_star_dotProduct,dotProduct,mul_comm]
  let E := operator H - (shift : ℂ) • ContinuousLinearMap.id ℂ _ - operator D
  have diff : matrixExpectation H ψ - shift - matrixExpectation D ψ = (⟪z,E z⟫_ℂ).re := by
    simp [energy,E,inner_sub_right,inner_smul_right_eq_smul,normed]
  rw [diff]
  exact (Complex.abs_re_le_norm _).trans ((norm_inner_le_norm _ _).trans (by
    simpa [normed] using E.le_opNorm z))

/-- With sector operator error at most ε < V/2 the thresholds are strictly
separated. The YES witness is an actual orthonormal-orbital determinant,
and the NO lower bound also holds for arbitrary normalized superpositions. -/
theorem robustSlaterReduction (G : SimpleGraph (Fin n)) (U V shift ε : ℝ)
    (hU : V ≤ U) (hV : 0 < V) (hε : ε < V/2) (H : Matrix (Sector n k) (Sector n k) ℂ)
    (herr : ‖operator H - (shift : ℂ) • ContinuousLinearMap.id ℂ _ -
        operator (diagonal G U V)‖ ≤ ε) :
    shift+ε < shift+V-ε ∧
    (Independent G k → ∃ ψ, IsSlater ψ ∧ mass ψ=1 ∧ matrixExpectation H ψ ≤ shift+ε) ∧
    (¬ Independent G k → ∀ ψ, mass ψ=1 → shift+V-ε ≤ matrixExpectation H ψ) :=
  ⟨by linarith,slaterDecisionGap G U V shift ε hU hV.le H
    (fun ψ h => (expectationPerturbation _ _ _ ψ h).trans herr)⟩

end FQChem.Complexity.SlaterEnergy
