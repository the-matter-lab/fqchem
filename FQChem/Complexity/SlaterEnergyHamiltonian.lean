module

public import FQChem.Complexity.SlaterEnergyKinetic
import Mathlib.Tactic

/-! # Assembly of the electronic Hamiltonian in the occupation basis

Annihilating a mode in an ordered determinant contributes (−1) to the
power of the number of preceding occupied modes. Inner products of the
remaining determinants give the one- and two-body matrix entries. The
two-body part sums over unordered pairs and uses antisymmetrized integrals.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SlaterEnergyHamiltonian
open SlaterEnergy SlaterEnergyOrbitals SlaterEnergyKinetic SlaterEnergyReduction Classical
variable {n k : ℕ}

abbrev Pair (n : ℕ) := Mode n × Mode n

def sameSite (i : Fin n) : Pair n := (mode i false,mode i true)

def occupied (s : Sector n k) : Finset (Pair n) := (doubles s.val).image sameSite ∪ offsite s

theorem occupied_spec {s : Sector n k} {p : Pair n} (h : p ∈ occupied s) :
    p.1 ∈ s.val ∧ p.2 ∈ s.val ∧ p.1 < p.2 := by
  rcases Finset.mem_union.mp h with hi | he
  · obtain ⟨i,hin,rfl⟩ := Finset.mem_image.mp hi
    have both : mode i false ∈ s.val ∧ mode i true ∈ s.val := (Finset.mem_filter.mp hin).2
    exact ⟨both.1,both.2,Prod.Lex.right _ (by decide)⟩
  · obtain ⟨hmem,lt⟩ := Finset.mem_filter.mp he
    obtain ⟨h₁,h₂⟩ := Finset.mem_product.mp hmem
    exact ⟨h₁,h₂,Prod.Lex.left _ _ lt⟩

/-- Every pair of distinct occupied modes occurs exactly once in increasing order. -/
theorem occupied_iff {s : Sector n k} {p : Pair n} :
    p ∈ occupied s ↔ p.1 ∈ s.val ∧ p.2 ∈ s.val ∧ p.1 < p.2 := by
  refine ⟨occupied_spec,?_⟩
  obtain ⟨⟨i,b⟩,⟨j,c⟩⟩ := p
  rintro ⟨hb,hc,hlt⟩
  cases hlt with
  | left _ _ h => exact Finset.mem_union_right _ (Finset.mem_filter.mpr ⟨Finset.mem_product.mpr ⟨hb,hc⟩,h⟩)
  | right _ h =>
    cases b <;> cases c <;> try contradiction
    exact Finset.mem_union_left _ (Finset.mem_image.mpr ⟨i,Finset.mem_filter.mpr ⟨Finset.mem_univ _,hb,hc⟩,rfl⟩)

def spin (p : Mode n) := (ofLex p).2

private theorem mode_ext {p q : Mode n} (v : vertex p = vertex q) (b : spin p=spin q) : p=q :=
  Prod.ext v b

def sign (s : Finset (Mode n)) (p : Mode n) : ℝ := (-1)^((s.filter (· < p)).card)

def signTwo (s : Finset (Mode n)) (p : Pair n) := sign s p.1 * sign (s.erase p.1) p.2

private theorem sign_sq (s : Finset (Mode n)) (p : Mode n) : sign s p * sign s p = 1 := by
  rw [sign,←mul_pow]; norm_num

/-- The inner product of the determinants left after deleting occupied mode
sets, with their fermionic signs from the original annihilations. -/
def residual (s t : Sector n k) (P Q : Finset (Mode n)) (σ τ : ℝ) :=
  if s.val \ P = t.val \ Q then σ*τ else 0

private theorem sameResidual (s t : Sector n k) (P : Finset (Mode n)) (hs : P⊆s.val)
    (ht : P⊆t.val) (σ : Finset (Mode n) → ℝ) (hσ : ∀ c, σ c * σ c = 1) :
    residual s t P P (σ s.val) (σ t.val) = if s=t then 1 else 0 := by
  have iff : s.val \ P = t.val \ P ↔ s=t := by
    constructor
    · intro e
      apply Subtype.ext
      rw [←Finset.sdiff_union_of_subset hs,← Finset.sdiff_union_of_subset ht,e]
    · rintro rfl; rfl
  unfold residual
  by_cases h : s=t
  · subst t; simp [hσ]
  · have e : s.val \ P ≠ t.val \ P := fun eq => h (iff.mp eq)
    rw [ite_eq_right e,ite_eq_right h]

def kineticIntegral (G : SimpleGraph (Fin n)) (R : ℕ) (p q : Mode n) :=
  if spin p=spin q then kinetic G R (vertex p) (vertex q) else 0

def coulombIntegral (G : SimpleGraph (Fin n)) (R : ℕ) (p q : Pair n) :=
  if spin p.1=spin q.1 ∧ spin p.2=spin q.2 then
    coefficient G R (vertex p.1) (vertex q.1) (vertex p.2) (vertex q.2) else 0

private theorem kinetic_delta (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R) (p q : Mode n) :
    kineticIntegral G R p q = if p=q then primitive else 0 := by
  unfold kineticIntegral
  rw [kinetic_matrix G R hR]
  by_cases h : p=q
  · simp [h]
  · by_cases v : vertex p=vertex q <;> by_cases b : spin p=spin q <;> simp_all
    exact (h (mode_ext v b)).elim

private theorem coulomb_delta (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R) (p q : Pair n) :
    coulombIntegral G R p q = if p=q then direct G R (vertex p.1) (vertex p.2) else 0 := by
  unfold coulombIntegral
  by_cases h : p=q
  · simp [h,direct]
  · rw [ite_eq_right h]
    split
    next spinEq =>
      apply coefficient_offdiag _ _ hR
      by_contra! equalSites
      exact h (Prod.ext (mode_ext equalSites.1 spinEq.1) (mode_ext equalSites.2 spinEq.2))
    next => rfl

/-- Matrix element of antisymmetrized Coulomb integrals on two ordered modes. -/
def antisymmetrized (G : SimpleGraph (Fin n)) (R : ℕ) (p q : Pair n) :=
  coulombIntegral G R p q - coulombIntegral G R p q.swap

theorem pair_delta (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R)
    {p q : Pair n} (hp : p.1<p.2) (hq : q.1<q.2) :
    antisymmetrized G R p q = if p=q then direct G R (vertex p.1) (vertex p.2) else 0 := by
  have ne : p ≠ q.swap := by rintro rfl; exact lt_asymm hp hq
  simp [antisymmetrized,coulomb_delta G R hR,ne]

/-- The fixed-electron-number matrix of Eq. (3) with V=0. For each occupied
bra and ket mode (or ordered pair), the coefficient multiplies the inner
product after the appropriate signed annihilations. -/
def electronic (G : SimpleGraph (Fin n)) (R : ℕ) : Matrix (Sector n k) (Sector n k) ℂ := Matrix.of fun s t =>
  ((∑ p ∈ s.val, ∑ q ∈ t.val, kineticIntegral G R p q *
      residual s t {p} {q} (sign s.val p) (sign t.val q)) +
   (∑ p ∈ occupied s, ∑ q ∈ occupied t, antisymmetrized G R p q *
      residual s t {p.1,p.2} {q.1,q.2} (signTwo s.val p) (signTwo t.val q)) : ℝ)

private theorem singleSum (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R) (s t : Sector n k) :
    (∑ p ∈ s.val, ∑ q ∈ t.val, kineticIntegral G R p q *
      residual s t {p} {q} (sign s.val p) (sign t.val q)) = if s=t then (k:ℝ)*primitive else 0 := by
  have inner p (hp : p∈s.val) : (∑ q ∈ t.val, kineticIntegral G R p q *
      residual s t {p} {q} (sign s.val p) (sign t.val q)) = if s=t then primitive else 0 := by
    simp_rw [kinetic_delta G R hR,ite_mul,zero_mul]
    rw [Finset.sum_ite_eq]
    by_cases ht : p∈t.val
    · rw [ite_eq_left ht,sameResidual s t {p} (Finset.singleton_subset_iff.mpr hp)
        (Finset.singleton_subset_iff.mpr ht) (fun c => sign c p) (fun c => sign_sq c p)]
      split <;> simp
    · have h : s ≠ t := by rintro rfl; exact ht hp
      simp [ht,h]
  rw [Finset.sum_congr rfl inner]
  by_cases h : s=t <;> simp [h]

private theorem sum_direct (G : SimpleGraph (Fin n)) (s : Sector n k) :
    (∑ p ∈ occupied s, direct G (spacing n) (vertex p.1) (vertex p.2)) = repulsion G s := by
  have disj : Disjoint ((doubles s.val).image sameSite) (offsite s) := by
    apply Finset.disjoint_left.mpr
    intro p hp he
    obtain ⟨i,_,rfl⟩ := Finset.mem_image.mp hp
    exact lt_irrefl i (Finset.mem_filter.mp he).2
  unfold occupied repulsion
  rw [Finset.sum_union disj,Finset.sum_image (g:=sameSite) (fun x _ y _ h => congrArg (fun p : Pair n => vertex p.1) h)]
  rfl

private theorem pairSum (G : SimpleGraph (Fin n)) (hn : 0<n) (s t : Sector n k) :
    let R := spacing n
    (∑ p ∈ occupied s, ∑ q ∈ occupied t, antisymmetrized G R p q *
      residual s t {p.1,p.2} {q.1,q.2} (signTwo s.val p) (signTwo t.val q)) =
      if s=t then repulsion G s else 0 := by
  let R := spacing n
  have hR : 4≤R := by unfold R spacing; have := Nat.one_le_pow 4 n hn; omega
  have inner p (hp : p∈occupied s) : (∑ q ∈ occupied t, antisymmetrized G R p q *
      residual s t {p.1,p.2} {q.1,q.2} (signTwo s.val p) (signTwo t.val q)) =
      if s=t then direct G R (vertex p.1) (vertex p.2) else 0 := by
    have eq (q) (hq : q ∈ occupied t) := pair_delta G R hR (occupied_spec hp).2.2 (occupied_spec hq).2.2
    rw [Finset.sum_congr rfl (fun q hq => congrArg (· * residual s t {p.1,p.2} {q.1,q.2} (signTwo s.val p) (signTwo t.val q)) (eq q hq))]
    simp_rw [ite_mul,zero_mul]
    rw [Finset.sum_ite_eq]
    by_cases ht : p∈occupied t
    · have sub {x : Sector n k} (hx : p∈occupied x) : {p.1,p.2} ⊆ x.val := by
        intro a ha
        rcases Finset.mem_insert.mp ha with rfl | he
        · exact (occupied_spec hx).1
        · rw [Finset.mem_singleton.mp he]; exact (occupied_spec hx).2.1
      have sig (x : Finset (Mode n)) : signTwo x p * signTwo x p = 1 := by
        rw [signTwo, mul_mul_mul_comm,sign_sq,sign_sq,one_mul]
      rw [ite_eq_left ht,sameResidual s t _ (sub hp) (sub ht) (fun c => signTwo c p) sig]
      split <;> simp
    · have h : s≠t := by rintro rfl; exact ht hp
      simp [ht,h]
  dsimp only
  rw [Finset.sum_congr rfl inner]
  split <;> simp_all [sum_direct,R]

/-- Exact identification of the assembled one- and two-body matrix with the
matrix in the independent-set energy theorem, including its kinetic offset. -/
theorem electronic_eq (G : SimpleGraph (Fin n)) (hn : 0<n) :
    electronic (k:=k) G (spacing n) = hamiltonian G ((k:ℝ)*primitive) := by
  have hR : 4≤spacing n := by unfold spacing; have := Nat.one_le_pow 4 n hn; omega
  ext s t
  simp only [electronic,Matrix.of_apply,singleSum G _ hR,pairSum G hn,hamiltonian,Matrix.diagonal_apply]
  by_cases h : s=t <;> simp [h,add_comm]

/-- Independent set reduces to an inverse-polynomial energy gap in the physical
fixed-basis electronic Hamiltonian with zero external potential. The YES
witness is a single Slater determinant and the NO inequality holds for every
normalized state in the same electron-number sector. -/
theorem physicalReduction (G : SimpleGraph (Fin n)) (hn : 0<n) (k : ℕ) :
    let E := electronic (k:=k) G (spacing n)
    let shift := (k:ℝ)*primitive
    (Independent G k → ∃ ψ : Sector n k → ℂ, IsSlater ψ ∧ ElectronicStructure.mass ψ=1 ∧
       ElectronicStructure.matrixExpectation E ψ ≤ shift+1/(12*(n:ℝ)^2)) ∧
    (¬ Independent G k → ∀ ψ : Sector n k → ℂ, ElectronicStructure.mass ψ=1 →
       shift+1/(6*(n:ℝ)^2) ≤ ElectronicStructure.matrixExpectation E ψ) := by
  dsimp only
  rw [electronic_eq G hn]
  exact coulombDecisionGap G hn k _

/-- Explicit rational thresholds for the physical reduction, including the
verified normalized kinetic offset. -/
theorem rationalThresholds (G : SimpleGraph (Fin n)) (hn : 0<n) (k : ℕ) :
    let E := electronic (k:=k) G (spacing n)
    let low : ℚ := k*(195/32)+1/(12*(n:ℚ)^2)
    let high : ℚ := k*(195/32)+1/(6*(n:ℚ)^2)
    high-low=1/(12*(n:ℚ)^2) ∧
    (Independent G k → ∃ ψ : Sector n k → ℂ, IsSlater ψ ∧ ElectronicStructure.mass ψ=1 ∧
       ElectronicStructure.matrixExpectation E ψ ≤ (low:ℝ)) ∧
    (¬ Independent G k → ∀ ψ : Sector n k → ℂ, ElectronicStructure.mass ψ=1 →
       (high:ℝ) ≤ ElectronicStructure.matrixExpectation E ψ) := by
  dsimp only
  constructor
  · have nn : (n:ℚ)≠0 := by exact_mod_cast Nat.ne_of_gt hn
    field_simp [nn]
    ring
  · push_cast
    simpa only [primitive_value] using physicalReduction G hn k

end FQChem.Complexity.SlaterEnergyHamiltonian
