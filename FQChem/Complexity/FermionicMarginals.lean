module

public import FQChem.StatePrep.VariationalOptimization.FermionicAnsatz
public import Mathlib.Analysis.Matrix.Order
public import Mathlib.LinearAlgebra.Matrix.Kronecker
import Mathlib.Tactic

/-! # Two-particle reduced density matrices and electronic energy

The two-electron marginal is the partial trace over the remaining electron
coordinates, normalized to trace one. The energy variational problem for a sum
of two-body terms can therefore be expressed exactly over N-representable
marginals. We use the ordered first-quantized basis for the antisymmetric
sector. [Liu, Christandl and Verstraete (2007)](https://doi.org/10.1103/PhysRevLett.98.110503).
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.FermionicMarginals
open Matrix
open scoped ComplexOrder Kronecker ComplexConjugate
variable {d n : ℕ}

abbrev Coordinates (d n : ℕ) := Fin n → Fin d
abbrev PairBasis (d : ℕ) := Fin d × Fin d
abbrev Operator (α : Type*) := Matrix α α ℂ

/-- The first two particle coordinates followed by the traced-out coordinates. -/
def join (d n : ℕ) : (PairBasis d × Coordinates d n) ≃ Coordinates d (n+2) :=
  (Equiv.prodAssoc _ _ _).trans
    ((Equiv.prodCongr (Equiv.refl _) (Fin.consEquiv fun _ => Fin d)).trans
      (Fin.consEquiv fun _ => Fin d))

/-- Each column of a physical density matrix lies in the fermion sector. -/
def FermionState (ρ : Operator (Coordinates d n)) : Prop :=
  ρ.PosSemidef ∧ ρ.trace = 1 ∧ ∀ y,
    WithLp.toLp 2 (fun x => ρ x y) ∈ FQChem.VariationalMethods.fermionSector d n

def marginal (ρ : Operator (Coordinates d (n+2))) : Operator (PairBasis d) :=
  ∑ z : Coordinates d n, ρ.submatrix (fun x => join d n (x,z)) (fun x => join d n (x,z))

@[simp] theorem marginal_apply (ρ : Operator (Coordinates d (n+2))) (a b : PairBasis d) :
    marginal ρ a b = ∑ z, ρ (join d n (a,z)) (join d n (b,z)) := by
  simp [marginal, Matrix.sum_apply]

theorem marginal_positive {ρ : Operator (Coordinates d (n+2))} (h : ρ.PosSemidef) :
    (marginal ρ).PosSemidef := by
  apply Matrix.posSemidef_sum
  exact fun z _ => h.submatrix _

theorem marginal_trace (ρ : Operator (Coordinates d (n+2))) :
    (marginal ρ).trace = ρ.trace := by
  simpa only [trace, diag, marginal_apply, Fintype.sum_prod_type] using
    (join d n).sum_comp (fun x => ρ x x)

/-- A pair density is representable when an antisymmetric mixed state has
exactly this two-coordinate marginal. -/
def Representable (n : ℕ) (γ : Operator (PairBasis d)) : Prop :=
  ∃ ρ : Operator (Coordinates d (n+2)), FermionState ρ ∧ marginal ρ = γ

theorem representable_density {γ : Operator (PairBasis d)} (h : Representable n γ) :
    γ.PosSemidef ∧ γ.trace = 1 := by
  obtain ⟨ρ, state, rfl⟩ := h
  exact ⟨marginal_positive state.1, (marginal_trace ρ).trans state.2.1⟩

/-- The admissible two-particle marginals form a convex set. Mixing physical
N-particle states witnesses each mixture of the corresponding marginals. -/
theorem convexRepresentable (d n : ℕ) :
    Convex ℝ {γ : Operator (PairBasis d) | Representable n γ} := by
  intro x hx y hy a b ha hb hab
  obtain ⟨ρ,hρ,rfl⟩ := hx
  obtain ⟨τ,hτ,rfl⟩ := hy
  refine ⟨a • ρ + b • τ, ⟨(hρ.1.smul ha).add (hτ.1.smul hb), ?_, ?_⟩, ?_⟩
  · simp [trace_add, trace_smul, hρ.2.1, hτ.2.1]
    exact_mod_cast hab
  · intro w z σ
    change (a:ℂ)*ρ (z ∘ σ) w + (b:ℂ)*τ (z ∘ σ) w = _
    rw [show ρ (z ∘ σ) w = _ from hρ.2.2 w z σ, show τ (z ∘ σ) w = _ from hτ.2.2 w z σ]
    change _ = _*((a:ℂ)*ρ z w+(b:ℂ)*τ z w)
    ring
  · ext x y
    simp [marginal_apply, Finset.sum_add_distrib, Finset.mul_sum]

/-- Trace out the last particle. -/
def traceLast (ρ : Operator (Coordinates d (n+1))) : Operator (Coordinates d n) :=
  ∑ z : Fin d, ρ.submatrix (fun x => Fin.snoc x z) (fun x => Fin.snoc x z)

private def fixLast (σ : Equiv.Perm (Fin n)) : Equiv.Perm (Fin (n+1)) :=
  finSumFinEquiv.permCongr (σ.sumCongr (Equiv.refl (Fin 1)))

private theorem snoc_relabel (σ : Equiv.Perm (Fin n)) (x : Coordinates d n) (z : Fin d) :
    Fin.snoc (x ∘ σ) z = (Fin.snoc x z : Coordinates d (n+1)) ∘ fixLast σ := by
  funext j
  refine Fin.lastCases ?_ (fun i => ?_) j <;>
    simp [fixLast, Equiv.permCongr_apply, Function.comp_def]
  · rw [show Fin.natAdd n (0 : Fin 1) = Fin.last n by ext; simp]
    exact (Fin.snoc_last (α := fun _ => Fin d) z x).symm
  · rw [show Fin.castAdd 1 (σ i) = Fin.castSucc (σ i) by rfl]
    exact (Fin.snoc_castSucc (α := fun _ => Fin d) z x (σ i)).symm

theorem traceLast_state {ρ : Operator (Coordinates d (n+1))} (h : FermionState ρ) :
    FermionState (traceLast ρ) := by
  refine ⟨Matrix.posSemidef_sum _ (fun z _ => h.1.submatrix _), ?_, ?_⟩
  · rw [← h.2.1]
    have eqn := (Fin.snocEquiv (n:=n) fun _ => Fin d).sum_comp (fun x => ρ x x)
    simp only [traceLast, trace, diag, Matrix.sum_apply, submatrix_apply]
    rw [Finset.sum_comm]
    simpa only [Fintype.sum_prod_type, Fin.snocEquiv_apply] using eqn
  · intro y x σ
    change traceLast ρ (x ∘ σ) y = _ * traceLast ρ x y
    simp only [traceLast, Matrix.sum_apply, submatrix_apply, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro z _
    rw [snoc_relabel]
    have hs := h.2.2 (Fin.snoc y z) (Fin.snoc x z) (fixLast σ)
    change ρ ((Fin.snoc x z) ∘ fixLast σ) _ = (Equiv.Perm.sign (fixLast σ) : ℂ)*_ at hs
    simpa [fixLast, Equiv.Perm.sign_permCongr, Equiv.Perm.sign_sumCongr] using hs

/-- Removing a spectator leaves the two-particle marginal unchanged.
This proves the nesting K(N+1) ⊆ K(N) used in Liu et al., note 27. -/
theorem representable_previous {γ : Operator (PairBasis d)} (h : Representable (n+1) γ) :
    Representable n γ := by
  obtain ⟨ρ,hρ,rfl⟩ := h
  refine ⟨traceLast ρ,traceLast_state hρ,?_⟩
  ext a b
  simp only [marginal_apply, traceLast, Matrix.sum_apply, submatrix_apply]
  rw [Finset.sum_comm, ← (Fin.snocEquiv (n:=n) fun _ => Fin d).sum_comp
    (fun z => ρ (join d (n+1) (a,z)) (join d (n+1) (b,z))), Fintype.sum_prod_type]
  apply Finset.sum_congr rfl; intro z _
  apply Finset.sum_congr rfl; intro x _
  change ρ (Fin.snoc (Fin.cons a.1 (Fin.cons a.2 x)) z) (Fin.snoc (Fin.cons b.1 (Fin.cons b.2 x)) z) =
    ρ (Fin.cons a.1 (Fin.cons a.2 (Fin.snoc x z))) (Fin.cons b.1 (Fin.cons b.2 (Fin.snoc x z)))
  simp only [Fin.cons_snoc_eq_snoc_cons]

private theorem trace_relabel {α β : Type*} [Fintype α] [Fintype β] (e : α ≃ β)
    (A B : Operator β) :
    ((A.submatrix e e)*(B.submatrix e e)).trace = (A*B).trace := by
  rw [Matrix.submatrix_mul_equiv]
  exact e.sum_comp fun x => (A*B) x x

/-- The same two-body kernel acting on the first pair and leaving all
spectator orbitals fixed. -/
def liftPair (n : ℕ) (K : Operator (PairBasis d)) : Operator (Coordinates d (n+2)) :=
  (K ⊗ₖ (1 : Operator (Coordinates d n))).submatrix (join d n).symm (join d n).symm

private theorem pairTrace {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (K : Operator α) (R : Operator (α × β)) :
    ((K ⊗ₖ (1 : Operator β))*R).trace =
      (K * of (fun x y => ∑ z, R (x,z) (y,z))).trace := by
  simp only [trace, diag, Matrix.mul_apply, Fintype.sum_prod_type, kroneckerMap_apply,
    Matrix.one_apply, of_apply, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro p _
  rw [Finset.sum_comm]
  simp [mul_ite, ite_mul]

theorem pairExpectation (K : Operator (PairBasis d)) (ρ : Operator (Coordinates d (n+2))) :
    ((liftPair n K)*ρ).trace = (K*marginal ρ).trace := by
  rw [← trace_relabel (join d n)]
  have relabel : (liftPair n K).submatrix (join d n) (join d n) =
      K ⊗ₖ (1 : Operator (Coordinates d n)) := by
    ext a b
    simp [liftPair, submatrix_apply]
  rw [relabel, pairTrace]
  congr 2
  ext x y
  simp [submatrix_apply]

def permute (σ : Equiv.Perm (Fin n)) : Equiv.Perm (Coordinates d n) :=
  (Equiv.arrowCongr σ.symm (Equiv.refl _))

private theorem invariant {ρ : Operator (Coordinates d n)} (h : FermionState ρ)
    (σ : Equiv.Perm (Fin n)) : ρ.submatrix (permute σ) (permute σ) = ρ := by
  have row (x y : Coordinates d n) : ρ (permute σ x) y = (Equiv.Perm.sign σ : ℂ)*ρ x y :=
    h.2.2 y x σ
  have herm (x y : Coordinates d n) : conj (ρ y x) = ρ x y :=
    congrFun (congrFun h.1.isHermitian x) y
  ext x y
  change ρ (permute σ x) (permute σ y) = ρ x y
  rw [row, ← herm x (permute σ y), row, map_mul, herm]
  rcases Int.units_eq_one_or (Equiv.Perm.sign σ) with hsign | hsign <;> simp [hsign]

/-- A term on any ordered pair has the same expectation as the first-pair
kernel. The sign cancels between bra and ket under the particle relabeling. -/
theorem anyPairExpectation {ρ : Operator (Coordinates d (n+2))} (h : FermionState ρ)
    (σ : Equiv.Perm (Fin (n+2))) (K : Operator (PairBasis d)) :
    (((liftPair n K).submatrix (permute σ) (permute σ))*ρ).trace =
      (K*marginal ρ).trace := by
  calc
    _ = (((liftPair n K).submatrix (permute σ) (permute σ))*
        (ρ.submatrix (permute σ) (permute σ))).trace := by rw [invariant h σ]
    _ = _ := (trace_relabel (permute σ) _ _).trans (pairExpectation K ρ)

/-- Full fixed-particle Hamiltonian given as a finite sum of pair kernels.
A one-body term can be represented by a kernel acting identically on one slot. -/
def hamiltonian {J : Type*} [Fintype J] (σ : J → Equiv.Perm (Fin (n+2)))
    (K : J → Operator (PairBasis d)) : Operator (Coordinates d (n+2)) :=
  ∑ j, (liftPair n (K j)).submatrix (permute (σ j)) (permute (σ j))

/-- The attainable energies agree exactly. In particular, taking the infimum
over normalized N-electron mixed states is equivalent to minimizing a linear
functional over representable two-electron density matrices. -/
theorem energyRange {J : Type*} [Fintype J] (σ : J → Equiv.Perm (Fin (n+2)))
    (K : J → Operator (PairBasis d)) :
    {E : ℝ | ∃ ρ, FermionState ρ ∧ E = ((hamiltonian σ K * ρ).trace).re} =
      {E : ℝ | ∃ γ, Representable n γ ∧ E = (((∑ j, K j) * γ).trace).re} := by
  have energy (ρ : Operator (Coordinates d (n+2))) (h : FermionState ρ) :
      (hamiltonian σ K * ρ).trace = ((∑ j, K j) * marginal ρ).trace := by
    simpa only [hamiltonian, Finset.sum_mul, Matrix.trace_sum] using
      Finset.sum_congr (s₁ := Finset.univ) rfl (fun j _ => anyPairExpectation h (σ j) (K j))
  ext E
  constructor
  · rintro ⟨ρ,h,rfl⟩
    exact ⟨marginal ρ, ⟨ρ,h,rfl⟩, congrArg Complex.re (energy ρ h)⟩
  · rintro ⟨_,⟨ρ,h,rfl⟩,rfl⟩
    exact ⟨ρ,h, congrArg Complex.re (energy ρ h).symm⟩

end FQChem.Complexity.FermionicMarginals
