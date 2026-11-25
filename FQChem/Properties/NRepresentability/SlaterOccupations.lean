module

public import FQChem.Properties.NRepresentability.Occupations
public import FQChem.Complexity.SlaterContraction
import Mathlib.Tactic

/-! # Measuring orbital occupation in a Slater determinant

The Born weights of the occupation determinants in any orthonormal orbital
basis sum to one. Summing over determinants containing a specified orbital
gives the diagonal of the one-particle projector of the occupied frame.
-/

@[expose] public section
noncomputable section
namespace FQChem.Properties.NRepresentability

open FQChem.Complexity.SlaterContraction
open scoped ComplexConjugate ComplexInnerProductSpace Matrix
variable {d N : ℕ}

abbrev OrbitalBasis (d : ℕ) := OrthonormalBasis (Fin d) ℂ (Orbital (Fin d))

/-- Born weight of a determinant when all orbital occupations are measured in b. -/
def born (b : OrbitalBasis d) (ψ : Sector (Fin d) N) (s : Determinant d N) :=
  ‖(b.toBasis.exteriorPower N).repr ψ s‖ ^ 2

private def slots (s : Determinant d N) : Fin N ↪ Fin d :=
  (Set.powersetCard.ofFinEmbEquiv.symm s).toEmbedding

private theorem inSlots (s : Determinant d N) (i : Fin d) :
    (∃ j, slots s j = i) ↔ i ∈ s.val :=
  Set.powersetCard.mem_range_ofFinEmbEquiv_symm_iff_mem s i

private theorem basisKet (s : Determinant d N) :
    occupationBasis (ι := Fin d) N s = ket (coordinate (slots s)) := by
  simp [occupationBasis, exteriorPower.basis_apply, exteriorPower.ιMulti_family,
    slots, ket, Function.comp_def, EuclideanSpace.basisFun_apply]
  rfl

private theorem number_basis (i : Fin d) (s : Determinant d N) :
    one N i i (occupationBasis N s) = if i ∈ s.val then occupationBasis N s else 0 := by
  rw [basisKet]
  by_cases h : i ∈ s.val
  · obtain ⟨j, rfl⟩ := (inSlots s i).mpr h
    rw [ite_eq_left h, oneAction]
    exact congrArg ket (Function.update_eq_self j (coordinate (slots s)))
  · rw [ite_eq_right h]
    exact oneAbsent _ _ _ (fun j eq => h ((inSlots s i).mp ⟨j, eq⟩))

private theorem numberCoeff (ψ : Sector (Fin d) N) (i : Fin d) (s : Determinant d N) :
    (occupationBasis N).repr (one N i i ψ) s =
      if i ∈ s.val then (occupationBasis N).repr ψ s else 0 := by
  let B := occupationBasis (ι := Fin d) N
  have eq : (B.coord s).comp (one N i i) = if i ∈ s.val then B.coord s else 0 := by
    apply B.ext; intro t
    by_cases same : t = s
    · subst t
      by_cases mem : i ∈ s.val <;> simp [B, number_basis, mem, Module.Basis.coord_apply]
    · by_cases ht : i ∈ t.val <;> by_cases hs : i ∈ s.val <;>
        simp [B, number_basis, ht, hs, Module.Basis.coord_apply, same]
  by_cases hs : i ∈ s.val <;> simpa [B, hs, Module.Basis.coord_apply] using LinearMap.congr_fun eq ψ

private theorem coefficient_change (b : OrbitalBasis d) (f : Frame (Fin d) N)
    (s : Determinant d N) : (b.toBasis.exteriorPower N).repr (ket f) s =
      (occupationBasis N).repr (ket (b.repr ∘ f)) s := by
  simp [occupationBasis, exteriorPower.basis_repr_apply, ket,
    exteriorPower.ιMultiDual_apply_ιMulti, Module.Basis.coord_apply, Function.comp_def]

private theorem mixedOverlap (b : OrbitalBasis d) (f g : Frame (Fin d) N) :
    (∑ s, conj ((b.toBasis.exteriorPower N).repr (ket f) s) *
      (b.toBasis.exteriorPower N).repr (ket g) s) =
    (Matrix.of fun i j => inner ℂ (f j) (g i)).det := by
  simp_rw [coefficient_change]
  rw [← physicalBra]
  unfold bra ket
  rw [exteriorPower.pairingDual_ιMulti_ιMulti]
  simp [b.repr.inner_map_map]

/-- The total Born weight of an arbitrary antisymmetric state is independent
of the orthonormal orbital basis, including for correlated states. -/
theorem born_sum_basis_independent (a b : OrbitalBasis d) (ψ : Sector (Fin d) N) :
    ∑ s, born a ψ s = ∑ s, born b ψ s := by
  let A := a.toBasis.exteriorPower N
  let B := b.toBasis.exteriorPower N
  let T := A.toMatrix B
  have frame (s : Determinant d N) : B s = ket (fun j => b (slots s j)) := by
    rw [show B = b.toBasis.exteriorPower N from rfl, exteriorPower.basis_apply]
    rfl
  have unitary : T.conjTranspose * T = 1 := by
    ext s t
    change (∑ r, conj (A.repr (B s) r) * A.repr (B t) r) = _
    simp_rw [frame, A, mixedOverlap a, ← mixedOverlap b]
    change (∑ r, conj (B.repr (ket (fun j => b (slots s j))) r) *
      B.repr (ket (fun j => b (slots t j))) r) = _
    simp [← frame, Module.Basis.repr_self, Finsupp.single_apply, Matrix.one_apply]
  let v : Determinant d N → ℂ := B.repr ψ
  have coords : T.mulVec v = A.repr ψ := Module.Basis.toMatrix_mulVec_repr ..
  have moment (c : Determinant d N → ℂ) : (star c ⬝ᵥ c).re = ∑ i, ‖c i‖^2 := by
    simp [dotProduct, Complex.re_sum, ← Complex.normSq_eq_norm_sq, mul_comm, Complex.mul_conj]
  change ∑ s, ‖A.repr ψ s‖^2 = ∑ s, ‖v s‖^2
  rw [← moment, ← moment, ← coords, Matrix.star_mulVec, Matrix.dotProduct_mulVec,
    Matrix.vecMul_vecMul, unitary, Matrix.vecMul_one]

private theorem norm_from_bra (g : Frame (Fin d) N) (hg : Orthonormal ℂ g) :
    ∑ s, ‖(occupationBasis N).repr (ket g) s‖ ^ 2 = 1 := by
  have eq := congrArg Complex.re ((physicalBra g (ket g)).symm.trans (normalized g hg))
  simpa [Complex.re_sum, ← Complex.normSq_eq_norm_sq, mul_comm, Complex.mul_conj] using eq

/-- A Slater determinant of orthonormal orbitals is normalized in every orbital basis. -/
theorem slaterBorn_total (b : OrbitalBasis d) (f : Frame (Fin d) N) (hf : Orthonormal ℂ f) :
    ∑ s, born b (ket f) s = 1 := by
  simp only [born, coefficient_change]
  exact norm_from_bra _ (hf.comp_linearIsometryEquiv b.repr)

/-- The probability that an orbital is occupied equals the sum of its squared
overlaps with the occupied Slater orbitals. -/
theorem slaterOccupation (b : OrbitalBasis d) (f : Frame (Fin d) N) (hf : Orthonormal ℂ f)
    (i : Fin d) : occupations (born b (ket f)) i = ∑ j, ‖b.repr (f j) i‖^2 := by
  let g := b.repr ∘ f
  have hg : Orthonormal ℂ g := hf.comp_linearIsometryEquiv b.repr
  let c := (occupationBasis N).repr (ket g)
  have eq := (physicalBra g (one N i i (ket g))).symm.trans (oneBody g hg i i)
  simp only [numberCoeff, density, Matrix.of_apply] at eq
  have moment : (∑ s, conj (c s) * (if i ∈ s.val then c s else 0)) =
      ∑ j, g j i * conj (g j i) := eq
  have reSq (z : ℂ) : (z * conj z).re = ‖z‖^2 := by
    rw [Complex.mul_conj, Complex.ofReal_re, Complex.normSq_eq_norm_sq]
  calc
    _ = (∑ s, conj (c s) * (if i ∈ s.val then c s else 0)).re := by
      rw [Complex.re_sum]; apply Finset.sum_congr rfl; intro s _
      by_cases h : i ∈ s.val
      · simpa only [h, ite_true, born, coefficient_change, c, g, mul_comm] using
          (reSq (c s)).symm
      · simp [h]
    _ = _ := by rw [moment, Complex.re_sum]; simp only [reSq]; rfl

end FQChem.Properties.NRepresentability
