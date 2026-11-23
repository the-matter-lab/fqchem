module

public import Mathlib.Analysis.InnerProductSpace.PiL2
public import Mathlib.LinearAlgebra.ExteriorPower.Pairing
import Mathlib.Tactic

/-!
# Number-conserving preparation of Slater determinants

An orthonormal family of occupied molecular orbitals extends to an orbital
unitary. Its action on the fixed-particle-number exterior power prepares the
requested determinant from an occupation-basis state. Coordinate elimination
factors the orbital unitary into a finite sequence of at-most-two-mode gates
with unrestricted connectivity. Occupation amplitudes are minors of the
occupied-orbital coefficient matrix.

* [Jiang et al., Quantum Algorithms to Simulate Many-Body Physics of Correlated Fermions (2018)](https://doi.org/10.1103/PhysRevApplied.9.044036)
* [Kivlichan et al., Quantum Simulation of Electronic Structure with Linear Depth and Connectivity (2018)](https://doi.org/10.1103/PhysRevLett.120.110501)
-/

@[expose] public section
noncomputable section

namespace FormalQChem.StatePrep.CircuitPreparation.SlaterDeterminants

open scoped InnerProductSpace ComplexConjugate

abbrev OrbitalSpace (d : ℕ) := EuclideanSpace ℂ (Fin d)

variable {d n : ℕ}

/-- The ordered list of occupied coordinate orbitals of a reference determinant.
An embedding allows arbitrary distinct input occupations. -/
def coordinateOrbitals (occ : Fin n ↪ Fin d) (j : Fin n) : OrbitalSpace d :=
  EuclideanSpace.basisFun (Fin d) ℂ (occ j)

/-- Every orthonormal target frame can be prepared from any ordered set of
distinct reference occupations by a complex one-particle unitary. -/
theorem existsOrbitalUnitary (occ : Fin n ↪ Fin d) {target : Fin n → OrbitalSpace d}
    (h : Orthonormal ℂ target) : ∃ U : OrbitalSpace d ≃ₗᵢ[ℂ] OrbitalSpace d,
      ∀ i, U (coordinateOrbitals occ i) = target i := by
  classical
  let v := Function.extend occ target (fun _ => 0)
  let e := Equiv.ofInjective occ occ.injective
  have hv : (Set.range occ).domRestrict v = target ∘ e.symm := by
    funext j
    obtain ⟨_, j, rfl⟩ := j
    simp [Set.domRestrict, v, e, occ.injective.extend_apply]
  obtain ⟨b, hb⟩ := (hv ▸ h.comp e.symm e.symm.injective).exists_orthonormalBasis_extension_of_card_eq
    finrank_euclideanSpace
  refine ⟨(EuclideanSpace.basisFun (Fin d) ℂ).equiv b (Equiv.refl _), fun i => ?_⟩
  rw [coordinateOrbitals, OrthonormalBasis.equiv_apply_basis]
  exact (hb (occ i) ⟨i, rfl⟩).trans (occ.injective.extend_apply _ _ i)

/-- Exterior multiplication of the occupied orbitals gives the Slater state
in the antisymmetric sector of exactly n particles. -/
def slater (target : Fin n → OrbitalSpace d) := exteriorPower.ιMulti ℂ n target

/-- The same unitary prepares both the one-particle frame and its Slater state. -/
theorem existsSlaterPreparation (occ : Fin n ↪ Fin d) {target : Fin n → OrbitalSpace d}
    (h : Orthonormal ℂ target) : ∃ U : OrbitalSpace d ≃ₗᵢ[ℂ] OrbitalSpace d,
      (∀ i, U (coordinateOrbitals occ i) = target i) ∧
      exteriorPower.map n U.toLinearEquiv.toLinearMap (slater (coordinateOrbitals occ)) =
        slater target := by
  obtain ⟨U, hU⟩ := existsOrbitalUnitary occ h
  exact ⟨U, hU, (exteriorPower.map_apply_ιMulti _ _).trans
    (congrArg (exteriorPower.ιMulti ℂ n) (funext hU))⟩

/-- The coefficient of the ordered occupation list is a minor, with rows
indexing the measured modes and columns indexing the occupied target orbitals. -/
theorem occupationAmplitude (occ : Fin n ↪ Fin d) (target : Fin n → OrbitalSpace d) :
    exteriorPower.pairingDual ℂ (OrbitalSpace d) n
      (exteriorPower.ιMulti ℂ n (fun i => PiLp.projₗ 2 (fun _ : Fin d => ℂ) (occ i))) (slater target) =
    Matrix.det (Matrix.of fun i j => target j (occ i)) := by
  rw [slater, exteriorPower.pairingDual_ιMulti_ιMulti,
    ← Matrix.det_transpose (Matrix.of fun i j => target j (occ i))]
  rfl

abbrev OrbitalUnitary (d : ℕ) := OrbitalSpace d ≃ₗᵢ[ℂ] OrbitalSpace d

/-- The unit vector in a single coordinate orbital. -/
abbrev basisMode (i : Fin d) : OrbitalSpace d := EuclideanSpace.single i 1

/-- A unitary supported on at most two coordinate modes. A single-mode
phase is included by allowing the two indices to coincide. -/
def IsTwoModeGate (G : OrbitalUnitary d) : Prop :=
  ∃ a b : Fin d, ∀ i, i ≠ a → i ≠ b → G (basisMode i) = basisMode i

private theorem coordinate_of_fixed (G : OrbitalUnitary d) {i : Fin d}
    (h : G (basisMode i) = basisMode i) (x : OrbitalSpace d) : (G.symm x) i = x i := by
  have he := G.inner_map_map (basisMode i) (G.symm x)
  simpa [h, basisMode, EuclideanSpace.inner_single_left] using he.symm

private theorem gateForPair {a b : Fin d} {v : OrbitalSpace d}
    (hn : ‖v‖ = 1) (h : ∀ i, i ≠ a → i ≠ b → v i = 0) :
    ∃ G : OrbitalUnitary d, G (basisMode a) = v ∧
      ∀ i, i ≠ a → i ≠ b → G (basisMode i) = basisMode i := by
  classical
  let s : Set (Fin d) := {i | i = a ∨ i ≠ b}
  let f : Fin d → OrbitalSpace d := fun i => if i = a then v else basisMode i
  have hf : Orthonormal ℂ (s.domRestrict f) := by
    constructor
    · rintro ⟨i, hi⟩
      by_cases hia : i = a
      · simpa [f, hia, Set.domRestrict] using hn
      · simp [f, hia, Set.domRestrict, basisMode]
    · rintro ⟨i, hi⟩ ⟨j, hj⟩ hij
      have hij' : i ≠ j := fun he => hij (Subtype.ext he)
      change i = a ∨ i ≠ b at hi
      change j = a ∨ j ≠ b at hj
      change inner ℂ (f i) (f j) = 0
      by_cases hia : i = a
      · subst i
        have hja := Ne.symm hij'
        simp [f, hja, basisMode, EuclideanSpace.inner_single_right, h j hja (hj.resolve_left hja)]
      · by_cases hja : j = a
        · subst j
          simp [f, hia, basisMode, EuclideanSpace.inner_single_left, h i hia (hi.resolve_left hia)]
        · simpa [f, hia, hja] using
            (EuclideanSpace.orthonormal_single (ι := Fin d) (𝕜 := ℂ)).inner_eq_zero hij'
  obtain ⟨B, hB⟩ := hf.exists_orthonormalBasis_extension_of_card_eq finrank_euclideanSpace
  let G := (EuclideanSpace.basisFun (Fin d) ℂ).equiv B (Equiv.refl _)
  have hg (i : Fin d) : G (basisMode i) = B i := by
    rw [basisMode, ← EuclideanSpace.basisFun_apply]
    exact OrthonormalBasis.equiv_apply_basis _ _ _ _
  refine ⟨G, (hg a).trans ((hB a (Or.inl rfl)).trans (by simp [f])), ?_⟩
  intro i hia hib
  exact (hg i).trans ((hB i (Or.inr hib)).trans (by simp [f, hia]))

private theorem eliminateCoefficient (v : OrbitalSpace d) {a b : Fin d} (hab : a ≠ b)
    (hb : v b ≠ 0) : ∃ G : OrbitalUnitary d, (G.symm v) b = 0 ∧
      ∀ i, i ≠ a → i ≠ b → G (basisMode i) = basisMode i := by
  classical
  let t : OrbitalSpace d := EuclideanSpace.single a (conj (v b)) -
    EuclideanSpace.single b (conj (v a))
  have ht : t ≠ 0 := by
    intro he
    have he' := congrArg (fun x : OrbitalSpace d => x a) he
    simp [t, hab, hb] at he'
  let w : OrbitalSpace d := (‖t‖⁻¹ : ℂ) • t
  have hs (i : Fin d) (hib : i ≠ b) (hia : i ≠ a) : w i = 0 := by
    simp [w, t, hia, hib]
  obtain ⟨G, hG, hrest⟩ := gateForPair (a := b) (b := a)
    (v := w) (norm_smul_inv_norm ht) hs
  refine ⟨G, ?_, fun i hia hib => hrest i hib hia⟩
  have hw : inner ℂ w v = 0 := by
    simp [w, t, inner_smul_left, inner_sub_left, EuclideanSpace.inner_single_left, mul_comm]
  have he := G.inner_map_map (basisMode b) (G.symm v)
  simpa [hG, basisMode, EuclideanSpace.inner_single_left, hw] using he.symm

private theorem prepareVector (a : Fin d) (s : Finset (Fin d)) (ha : a ∉ s)
    (v : OrbitalSpace d) (hv : ‖v‖ = 1) (hs : ∀ i, i ≠ a → i ∉ s → v i = 0) :
    ∃ gates : List (OrbitalUnitary d), gates.prod (basisMode a) = v ∧
      ∀ G ∈ gates, IsTwoModeGate G ∧ ∀ i, i ≠ a → i ∉ s → G (basisMode i) = basisMode i := by
  classical
  induction s using Finset.induction_on generalizing v with
  | empty =>
    obtain ⟨G, hG, h⟩ := gateForPair (a := a) (b := a) hv (fun i hi _ => hs i hi (by simp))
    refine ⟨[G], by simpa using hG, ?_⟩
    simpa using (And.intro (show IsTwoModeGate G from ⟨a, a, h⟩) (fun i hi => h i hi hi))
  | @insert b s hb ih =>
    have hab : a ≠ b := by rintro rfl; simp at ha
    have has : a ∉ s := fun h => ha (Finset.mem_insert_of_mem h)
    by_cases hzero : v b = 0
    · have hs' (i) (hia : i ≠ a) (his : i ∉ s) : v i = 0 := by
        by_cases hib : i = b
        · simpa [hib] using hzero
        · exact hs i hia (by simp [hib, his])
      obtain ⟨gates, hg, hfix⟩ := ih has v hv hs'
      refine ⟨gates, hg, fun G hG => ⟨(hfix G hG).1, fun i hia hi => ?_⟩⟩
      exact (hfix G hG).2 i hia (fun h => hi (Finset.mem_insert_of_mem h))
    · obtain ⟨G, hz, hfix⟩ := eliminateCoefficient v hab hzero
      have hz' (i) (hia : i ≠ a) (his : i ∉ s) : (G.symm v) i = 0 := by
        by_cases hib : i = b
        · simpa [hib] using hz
        · exact (coordinate_of_fixed G (hfix i hia hib) v).trans
            (hs i hia (by simp [hib, his]))
      obtain ⟨gates, hg, hgs⟩ := ih has (G.symm v) (by simpa using hv) hz'
      refine ⟨G :: gates, by simp [hg], ?_⟩
      intro K hK
      rcases List.mem_cons.mp hK with rfl | hk
      · refine ⟨⟨a, b, hfix⟩, fun i hia hi => hfix i hia ?_⟩
        exact fun e => hi (by simp [e])
      · exact ⟨(hgs _ hk).1, fun i hia hi =>
          (hgs _ hk).2 i hia (fun h => hi (Finset.mem_insert_of_mem h))⟩

private theorem listProduct_fixed (gates : List (OrbitalUnitary d)) (i : Fin d)
    (hg : ∀ G ∈ gates, G (basisMode i) = basisMode i) : gates.prod (basisMode i) = basisMode i := by
  induction gates with
  | nil => rfl
  | cons G gates ih =>
    simp only [List.prod_cons, LinearIsometryEquiv.coe_mul, Function.comp_apply]
    rw [ih (fun g h => hg _ (List.mem_cons_of_mem _ h)), hg _ List.mem_cons_self]

/-- A finite complex orbital unitary has a finite factorization into unitaries
which each fix every coordinate mode outside a pair. -/
theorem existsTwoModeFactorization (U : OrbitalUnitary d) :
    ∃ gates : List (OrbitalUnitary d), (∀ G ∈ gates, IsTwoModeGate G) ∧ gates.prod = U := by
  classical
  have forModes (s : Finset (Fin d)) : ∃ gates : List (OrbitalUnitary d),
      (∀ G ∈ gates, IsTwoModeGate G) ∧ ∀ i ∈ s, gates.prod (basisMode i) = U (basisMode i) := by
    induction s using Finset.induction_on with
    | empty => exact ⟨[], by simp, by simp⟩
    | @insert j s hj ih =>
      obtain ⟨P, hp, hm⟩ := ih
      let x := P.prod.symm (U (basisMode j))
      have hx : ‖x‖ = 1 := by simp [x, basisMode]
      have hz (i : Fin d) (hi : i ≠ j) (his : i ∉ sᶜ.erase j) : x i = 0 := by
        have hmem : i ∈ s := by simpa [hi] using his
        have he := P.prod.inner_map_map (basisMode i) x
        have he' := U.inner_map_map (basisMode i) (basisMode j)
        rw [hm i hmem, show P.prod x = U (basisMode j) from P.prod.apply_symm_apply _, he'] at he
        simpa [basisMode, EuclideanSpace.inner_single_left, hi, hi.symm] using he.symm
      obtain ⟨Q, hq, hQ⟩ := prepareVector j (sᶜ.erase j) (by simp) x hx hz
      refine ⟨P ++ Q, ?_, ?_⟩
      · intro G hg
        exact (List.mem_append.mp hg).elim (hp G) (fun h => (hQ G h).1)
      · intro i hi
        simp only [List.prod_append, LinearIsometryEquiv.coe_mul, Function.comp_apply]
        rcases Finset.mem_insert.mp hi with rfl | his
        · rw [hq]; exact P.prod.apply_symm_apply _
        · have hij : i ≠ j := fun h => hj (h ▸ his)
          rw [listProduct_fixed Q i (fun G h => (hQ G h).2 i hij (by simp [his])), hm i his]
  obtain ⟨gates, h, he⟩ := forModes Finset.univ
  refine ⟨gates, h, (EuclideanSpace.basisFun (Fin d) ℂ).toBasis.ext_linearIsometryEquiv ?_⟩
  intro i
  simpa [EuclideanSpace.basisFun_apply, basisMode] using he i (Finset.mem_univ i)

/-- The fixed-n action of a single orbital gate. -/
def exteriorGate (n : ℕ) (G : OrbitalUnitary d) :=
  exteriorPower.map n G.toLinearEquiv.toLinearMap

/-- Lifting the orbital gates individually and composing them gives exactly the
fixed-n action of their orbital product. Lists use right-to-left composition. -/
theorem exteriorGate_product (n : ℕ) (gates : List (OrbitalUnitary d)) :
    (gates.map (exteriorGate n)).prod = exteriorGate n gates.prod := by
  induction gates with
  | nil =>
    change 1 = exteriorPower.map n (LinearMap.id (R := ℂ) (M := OrbitalSpace d))
    exact exteriorPower.map_id.symm
  | cons G gates ih =>
    simp only [List.map_cons, List.prod_cons, ih]
    exact (exteriorPower.map_comp gates.prod.toLinearEquiv.toLinearMap G.toLinearEquiv.toLinearMap).symm

/-- Exact preparation using a finite sequence of number-conserving, at-most-two-mode
orbital gates. Their composite acts in the n-electron antisymmetric sector. -/
theorem existsTwoModeSlaterPreparation (occ : Fin n ↪ Fin d) {target : Fin n → OrbitalSpace d}
    (h : Orthonormal ℂ target) : ∃ gates : List (OrbitalUnitary d),
      (∀ G ∈ gates, IsTwoModeGate G) ∧
      (∀ i, gates.prod (coordinateOrbitals occ i) = target i) ∧
      (gates.map (exteriorGate n)).prod (slater (coordinateOrbitals occ)) = slater target := by
  obtain ⟨U, hU⟩ := existsSlaterPreparation occ h
  obtain ⟨gates, hg, he⟩ := existsTwoModeFactorization U
  exact ⟨gates, hg, by rw [exteriorGate_product, he]; exact hU⟩

end FormalQChem.StatePrep.CircuitPreparation.SlaterDeterminants
