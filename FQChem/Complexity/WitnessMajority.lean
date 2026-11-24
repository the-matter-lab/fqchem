module

public import Mathlib.Analysis.Matrix.Order
import Mathlib.Tactic

/-! # Parallel repetition with quantum witnesses

In the three-copy majority verifier, a dishonest prover may send an entangled
state across the three witness registers. A bound on the joint acceptance
effect controls every such state. See Kitaev, Shen and Vyalyi (2002), Lemma 14.1.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.WitnessMajority

open Matrix
open scoped Kronecker MatrixOrder ComplexOrder

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
abbrev Effect (ι : Type*) := Matrix ι ι ℂ
abbrev Triple (ι : Type*) := (ι × ι) × ι

/-- Each term is one of the four accepting outcomes of the local binary measurements. -/
def majority (A B C : Effect ι) : Effect (Triple ι) :=
  A ⊗ₖ B ⊗ₖ C + (1-A) ⊗ₖ B ⊗ₖ C + A ⊗ₖ (1-B) ⊗ₖ C + A ⊗ₖ B ⊗ₖ (1-C)

/-- Increasing any of the three binary effects increases the joint acceptance
operator in the positive-semidefinite order, even for entangled inputs. -/
theorem monotone {A B C A' B' C' : Effect ι}
    (a : A ≤ A') (b : B ≤ B') (c : C ≤ C')
    (ha : 0 ≤ A') (ha' : A' ≤ 1) (hb : 0 ≤ B) (hb' : B ≤ 1)
    (hd : 0 ≤ B') (hd' : B' ≤ 1) (hc : 0 ≤ C) (hc' : C ≤ 1) :
    majority A B C ≤ majority A' B' C' := by
  rw [Matrix.le_iff]
  have diff : majority A' B' C' - majority A B C =
      (A'-A) ⊗ₖ B ⊗ₖ (1-C) + (A'-A) ⊗ₖ (1-B) ⊗ₖ C +
      A' ⊗ₖ (B'-B) ⊗ₖ (1-C) + (1-A') ⊗ₖ (B'-B) ⊗ₖ C +
      A' ⊗ₖ (1-B') ⊗ₖ (C'-C) + (1-A') ⊗ₖ B' ⊗ₖ (C'-C) := by
    ext ⟨⟨i,j⟩,k⟩ ⟨⟨l,m⟩,n⟩
    simp only [majority, Matrix.sub_apply, Matrix.add_apply, kronecker_apply]
    ring
  rw [diff]
  exact (((((((Matrix.le_iff.mp a).kronecker hb.posSemidef).kronecker hc').add
    (((Matrix.le_iff.mp a).kronecker hb').kronecker hc.posSemidef)).add
    ((ha.posSemidef.kronecker (Matrix.le_iff.mp b)).kronecker hc')).add
    (((Matrix.le_iff.mp ha').kronecker (Matrix.le_iff.mp b)).kronecker hc.posSemidef)).add
    ((ha.posSemidef.kronecker (Matrix.le_iff.mp hd')).kronecker (Matrix.le_iff.mp c))).add
    (((Matrix.le_iff.mp ha').kronecker hd.posSemidef).kronecker (Matrix.le_iff.mp c))

omit [Fintype ι] in
private theorem scalarMajority (q : ℝ) :
    majority (q • (1 : Effect ι)) (q • 1) (q • 1) = (3*q^2-2*q^3) • 1 := by
  have comp : (1 : Effect ι) - q • 1 = (1-q) • 1 := by rw [sub_smul, one_smul]
  simp only [majority, comp, smul_kronecker, kronecker_smul, one_kronecker_one, smul_smul,
    ← add_smul]
  congr 1
  ring

/-- A single-copy acceptance upper bound q implies the cubic soundness bound
on the full three-register Hilbert space. -/
theorem soundness {A : Effect ι} {q : ℝ} (h₀ : 0 ≤ A) (hA : A ≤ q • 1)
    (hq : 0 ≤ q) (h₁ : q ≤ 1) :
    majority A A A ≤ (3*q^2-2*q^3) • 1 := by
  have nonneg : 0 ≤ q • (1 : Effect ι) := (Matrix.PosSemidef.one.smul hq).nonneg
  have small : q • (1 : Effect ι) ≤ 1 := by
    rw [Matrix.le_iff, show (1 : Effect ι) - q • 1 = (1-q) • 1 by rw [sub_smul, one_smul]]
    exact Matrix.PosSemidef.one.smul (sub_nonneg.mpr h₁)
  rw [← scalarMajority]
  exact monotone hA hA hA nonneg small h₀ (hA.trans small) nonneg small h₀ (hA.trans small)

/-- Probability bound on every unit vector, without a product-state assumption. -/
theorem entangledAcceptance {A : Effect ι} {q : ℝ} (h₀ : 0 ≤ A) (hA : A ≤ q • 1)
    (hq : 0 ≤ q) (h₁ : q ≤ 1) (v : Triple ι → ℂ) (unit : star v ⬝ᵥ v = 1) :
    (star v ⬝ᵥ (majority A A A *ᵥ v)).re ≤ 3*q^2-2*q^3 := by
  have bound := (Matrix.le_iff.mp (soundness h₀ hA hq h₁)).dotProduct_mulVec_nonneg v
  rw [sub_mulVec, dotProduct_sub, smul_mulVec, one_mulVec, dotProduct_smul, unit] at bound
  exact sub_nonneg.mp (by simpa [← Complex.ofReal_pow] using (Complex.nonneg_iff.mp bound).1)

/-- The usual verifier hypothesis on individually normalized witnesses gives
the same operator bound used by the joint, possibly entangled measurement. -/
theorem boundOfWitnesses {A : Effect ι} (ha : A.IsHermitian) (q : ℝ)
    (hyp : ∀ v : ι → ℂ, star v ⬝ᵥ v=1 → (star v ⬝ᵥ (A *ᵥ v)).re ≤ q) :
    A ≤ q • 1 := by
  let D : Effect ι := q • 1 - A
  have hd : D.IsHermitian := by
    change (q • (1 : Effect ι) - A)ᴴ = _
    simp [conjTranspose_smul,ha.eq,D]
  apply hd.posSemidef_iff_eigenvalues_nonneg.mpr
  intro i
  change (0:ℝ) ≤ hd.eigenvalues i
  let u := hd.eigenvectorBasis i
  let v : ι → ℂ := u
  have hu : ‖u‖=1 := hd.eigenvectorBasis.orthonormal.1 i
  have unit : star v ⬝ᵥ v = 1 := by
    change star (WithLp.ofLp u) ⬝ᵥ WithLp.ofLp u = 1
    rw [dotProduct_comm,← EuclideanSpace.inner_eq_star_dotProduct,inner_self_eq_norm_sq_to_K,hu]
    norm_num
  have ev := congrArg (fun w : ι → ℂ => (star v ⬝ᵥ w).re) (hd.mulVec_eigenvectorBasis i)
  change (star v ⬝ᵥ ((q • (1:Effect ι)-A) *ᵥ v)).re = (star v ⬝ᵥ (hd.eigenvalues i • v)).re at ev
  rw [sub_mulVec,smul_mulVec,one_mulVec,dotProduct_sub,dotProduct_smul,dotProduct_smul,unit] at ev
  simp [Complex.real_smul] at ev
  linarith [hyp v unit]

/-- Ordinary one-copy soundness suffices against arbitrary entanglement
across the three registers in the repeated verifier. -/
theorem threeWitnessSoundness {A : Effect ι} (h₀ : 0 ≤ A) {q : ℝ} (hq : 0≤q) (h₁ : q≤1)
    (single : ∀ v : ι → ℂ, star v ⬝ᵥ v=1 → (star v ⬝ᵥ (A *ᵥ v)).re ≤ q)
    (w : Triple ι → ℂ) (unit : star w ⬝ᵥ w=1) :
    (star w ⬝ᵥ (majority A A A *ᵥ w)).re ≤ 3*q^2-2*q^3 :=
  entangledAcceptance h₀ (boundOfWitnesses h₀.posSemidef.isHermitian q single) hq h₁ w unit

end FQChem.Complexity.WitnessMajority
