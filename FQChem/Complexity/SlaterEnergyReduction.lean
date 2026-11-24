module

public import FQChem.Complexity.SlaterEnergy
public import FQChem.Complexity.SlaterEnergyOrbitals
import Mathlib.Tactic

/-! # Direct Coulomb energies implement the independent-set promise gap

An onsite pair or an edge has energy at least 1/(6n²), while all interactions
in the spin-polarized determinant of an independent set sum to at most
1/(12n²). The coefficients are the physical six-dimensional Coulomb integrals
of the explicitly placed normalized spatial orbitals.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SlaterEnergyReduction
open SlaterEnergy SlaterEnergyOrbitals ElectronicStructure Classical
open scoped ComplexConjugate
variable {n k : ℕ}

def spacing (n : ℕ) := 12*n^4+2

private theorem four_le_spacing (hn : 0<n) : 4 ≤ spacing n := by
  have h : 1 ≤ n^4 := Nat.one_le_pow _ _ hn
  unfold spacing; omega

def offsite (s : Sector n k) := (s.val ×ˢ s.val).filter fun p => vertex p.1 < vertex p.2

/-- Energy from the two-particle Coulomb term. For a doubly occupied spatial
orbital the up/down pair appears once. Each pair of electrons on different
sites occurs in increasing vertex order. -/
def repulsion (G : SimpleGraph (Fin n)) (s : Sector n k) : ℝ :=
  (∑ i ∈ doubles s.val, direct G (spacing n) i i) +
  ∑ p ∈ offsite s, direct G (spacing n) (vertex p.1) (vertex p.2)

theorem independent_upper (G : SimpleGraph (Fin n)) (hn : 0<n) (S : Finset (Fin n))
    (hk : S.card=k) (hind : G.IsIndepSet (S : Set (Fin n))) :
    repulsion G (polarized S hk) ≤ 1/(12*(n:ℝ)^2) := by
  let s := polarized S hk
  have hR := four_le_spacing hn
  have npos : (0:ℝ)<n := by exact_mod_cast hn
  have ud := polarized_zero G 1 1 S hk hind
  change (1:ℝ)*(doubles s.val).card + 1*(pairs G s.val).card = 0 at ud
  have empty : doubles s.val = ∅ := Finset.card_eq_zero.mp (by
    have h : ((doubles s.val).card:ℝ)=0 := by linarith [Nat.cast_nonneg (α:=ℝ) (pairs G s.val).card]
    exact_mod_cast h)
  have one (p) (hp : p ∈ offsite s) :
      direct G (spacing n) (vertex p.1) (vertex p.2) ≤ 1/((spacing n:ℝ)-2) := by
    have ⟨inside,lt⟩ := Finset.mem_filter.mp hp
    obtain ⟨i,hi,ei⟩ := Finset.mem_image.mp (Finset.mem_product.mp inside).1
    obtain ⟨j,hj,ej⟩ := Finset.mem_image.mp (Finset.mem_product.mp inside).2
    rw [← ei,← ej] at lt ⊢
    exact direct_nonedge G _ hR (ne_of_lt lt) (G.isIndepSet_iff.mp hind hi hj (ne_of_lt lt))
  have size : (offsite s).card ≤ n*n := by
    have h := Finset.card_le_univ S
    have pair := Finset.card_le_card (Finset.filter_subset (fun p : Mode n × Mode n => vertex p.1 < vertex p.2) (s.val ×ˢ s.val))
    simpa [offsite,Finset.card_product] using pair.trans (by
      rw [Finset.card_product,s.property,← hk]; simpa using Nat.mul_le_mul h h)
  change (∑ i ∈ doubles s.val, _) + _ ≤ _
  rw [empty, Finset.sum_empty,zero_add]
  calc
    _ ≤ ∑ _p ∈ offsite s, 1/((spacing n:ℝ)-2) := Finset.sum_le_sum one
    _ ≤ ((n:ℝ)*n) * (1/((spacing n:ℝ)-2)) := by
      simp only [Finset.sum_const,nsmul_eq_mul]
      have h : (4:ℝ) ≤ spacing n := by exact_mod_cast hR
      exact mul_le_mul_of_nonneg_right (by exact_mod_cast size) (one_div_nonneg.mpr (by linarith))
    _ = _ := by simp [spacing]; field_simp

theorem dependent_lower (G : SimpleGraph (Fin n)) (hn : 0<n) (hno : ¬ Independent G k)
    (s : Sector n k) : 1/(6*(n:ℝ)^2) ≤ repulsion G s := by
  let R := spacing n
  have hR := four_le_spacing hn
  have npos : (0:ℝ)<n := by exact_mod_cast hn
  have onsiteNonneg : 0 ≤ ∑ i ∈ doubles s.val, direct G R i i :=
    Finset.sum_nonneg fun i _ => direct_nonneg G R hR i i
  have offNonneg : 0 ≤ ∑ p ∈ offsite s, direct G R (vertex p.1) (vertex p.2) :=
    Finset.sum_nonneg fun p _ => direct_nonneg G R hR _ _
  by_cases d : (doubles s.val).Nonempty
  · obtain ⟨i,hi⟩ := d
    have lo := (direct_onsite G R hR i).trans (Finset.single_le_sum
      (f:=fun j => direct G R j j) (fun j _ => direct_nonneg G R hR j j) hi)
    change _ ≤ (∑ i ∈ doubles s.val, direct G R i i) + _
    calc
      _ ≤ (1/2:ℝ)/(n:ℝ)^2 := by field_simp; nlinarith
      _ ≤ _ := by linarith
  · have edge : (pairs G s.val).Nonempty := by
      by_contra h
      have bad := noInstance G 1 1 le_rfl zero_le_one hno s
      simp [cost,Finset.not_nonempty_iff_eq_empty.mp d, Finset.not_nonempty_iff_eq_empty.mp h] at bad
      norm_num at bad
    obtain ⟨p,hp⟩ := edge
    have ⟨inside,lt,adj⟩ := Finset.mem_filter.mp hp
    have p_in : p ∈ offsite s := Finset.mem_filter.mpr ⟨inside,lt⟩
    let f := fun q : Mode n × Mode n => direct G R (vertex q.1) (vertex q.2)
    have sum : f p ≤ ∑ q ∈ offsite s, f q := Finset.single_le_sum (f:=f) (fun q _ => direct_nonneg G R hR _ _) p_in
    have lo := (direct_edge G R hR adj).trans sum
    change _ ≤ _ + (∑ q ∈ offsite s, direct G R (vertex q.1) (vertex q.2))
    rw [← div_div]
    linarith

/-- Diagonal, fixed-particle interaction matrix with the common one-electron
energy entered as a scalar shift. -/
def hamiltonian (G : SimpleGraph (Fin n)) (shift : ℝ) : Matrix (Sector n k) (Sector n k) ℂ :=
  Matrix.diagonal (fun s => ((repulsion G s + shift : ℝ) : ℂ))

theorem expectation (G : SimpleGraph (Fin n)) (shift : ℝ) (ψ : Sector n k → ℂ) :
    matrixExpectation (hamiltonian G shift) ψ = (∑ s, ‖ψ s‖^2 * repulsion G s) + mass ψ * shift := by
  unfold matrixExpectation hamiltonian
  simp only [Matrix.mulVec_diagonal,Complex.re_sum]
  unfold mass
  rw [Finset.sum_mul,← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro s _
  rw [show conj (ψ s)*((↑(repulsion G s+shift):ℂ)*ψ s) = (↑(repulsion G s+shift):ℂ)*(ψ s*conj (ψ s)) by ring,
    Complex.mul_conj,Complex.sq_norm]
  simp; ring

theorem coulombDecisionGap (G : SimpleGraph (Fin n)) (hn : 0<n) (k : ℕ) (shift : ℝ) :
    (Independent G k → ∃ ψ : Sector n k → ℂ, IsSlater ψ ∧ mass ψ=1 ∧
       matrixExpectation (hamiltonian G shift) ψ ≤ shift+1/(12*(n:ℝ)^2)) ∧
    (¬ Independent G k → ∀ ψ : Sector n k → ℂ, mass ψ=1 →
       shift+1/(6*(n:ℝ)^2) ≤ matrixExpectation (hamiltonian G shift) ψ) := by
  classical
  constructor
  · rintro ⟨S,hk,hind⟩
    let s := polarized S hk
    let ψ : Sector n k → ℂ := fun t => if s=t then 1 else 0
    have unit : mass ψ=1 := by simp [mass,ψ,apply_ite]
    refine ⟨ψ,occupation_slater s,unit,?_⟩
    rw [expectation,unit,one_mul]
    have lo := independent_upper G hn S hk hind
    simpa [ψ,s,apply_ite,add_comm shift] using add_le_add_right lo shift
  · intro hno ψ hψ
    rw [expectation,hψ,one_mul,add_comm shift]
    apply add_le_add_left
    calc
      _ = ∑ s, ‖ψ s‖^2 * (1/(6*(n:ℝ)^2)) := by rw [←Finset.sum_mul]; change _ = mass ψ * _; rw [hψ,one_mul]
      _ ≤ _ := Finset.sum_le_sum fun s _ => mul_le_mul_of_nonneg_left (dependent_lower G hn hno s) (sq_nonneg _)

end FQChem.Complexity.SlaterEnergyReduction
