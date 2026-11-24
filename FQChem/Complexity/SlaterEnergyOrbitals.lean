module

public import FQChem.Complexity.SlaterEnergyCoulomb
import Mathlib.Tactic

/-! # Physical two-electron integrals for a graph of disjoint spatial orbitals

Each vertex carries a normalized sum of n smooth localized orbitals. The
choice of centers controls the direct Coulomb coefficient of an edge. All
two-electron terms with distinct orbital indices at one position vanish.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SlaterEnergyOrbitals
open MeasureTheory FixedBasisGaussians SlaterEnergyCoulomb
open FixedBasisGeometry (center separated)
variable {n : ℕ}

def spatial (G : SimpleGraph (Fin n)) (R : ℕ) (i : Fin n) (r : Space) :=
  (∑ j, wave (center G R i j) r) / Real.sqrt n

theorem disjoint_components (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R)
    {i j u v : Fin n} (h : (i,j)≠(u,v)) (r : Space) :
    wave (center G R i j) r * wave (center G R u v) r = 0 := by
  by_cases a : 1 ≤ dist r (center G R i j)
  · rw [wave_zero a,zero_mul]
  · have b : 1 ≤ dist r (center G R u v) := by
      linarith [separated G R hR i j u v h,dist_triangle (center G R i j) r (center G R u v),
        dist_comm (center G R i j) r]
    rw [wave_zero b,mul_zero]

theorem disjoint_sites (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R)
    {i u : Fin n} (h : i≠u) (r : Space) : spatial G R i r * spatial G R u r = 0 := by
  rw [spatial,spatial,div_mul_div_comm,Fintype.sum_mul_sum]
  simp [disjoint_components G R hR (fun pairs => h (congrArg Prod.fst pairs))]

theorem spatial_density (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R)
    (i : Fin n) (r : Space) :
    spatial G R i r ^ 2 = (∑ j, density (center G R i j) r) / n := by
  rw [spatial,div_pow,Real.sq_sqrt (Nat.cast_nonneg n),sq,Fintype.sum_mul_sum]
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  rw [Finset.sum_eq_single j]
  · simp [density,sq]
  · intro v _ h
    exact disjoint_components G R hR (fun pairs => h (congrArg Prod.snd pairs).symm) r
  · simp

theorem spatial_orthonormal (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R) (i u : Fin n) :
    (∫ r, spatial G R i r * spatial G R u r) = if i=u then 1 else 0 := by
  classical
  by_cases h : i=u
  · subst u
    simp_rw [← sq,spatial_density G R hR]
    rw [integral_div,integral_finsetSum _ (fun j _ => Integrable.of_integral_ne_zero
      ((density_normalized (center G R i j)) ▸ one_ne_zero))]
    simp [density_normalized, (show (n:ℝ) ≠ 0 by exact_mod_cast (Nat.ne_of_gt (Nat.zero_lt_of_lt i.isLt)))]
  · simp [disjoint_sites G R hR h,h]

/-- The physical four-index Coulomb coefficient with spatial index pairs
(i,l) at r and (j,k) at s in the fixed-basis Hamiltonian. -/
def coefficient (G : SimpleGraph (Fin n)) (R : ℕ) (i l j k : Fin n) :=
  ∫ z : Space×Space, (spatial G R i z.1 * spatial G R l z.1) *
    (spatial G R j z.2 * spatial G R k z.2) / dist z.1 z.2 ∂volume.prod volume

def direct (G : SimpleGraph (Fin n)) (R : ℕ) (i j : Fin n) := coefficient G R i i j j

theorem coefficient_offdiag (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R)
    {i l j k : Fin n} (h : i≠l ∨ j≠k) : coefficient G R i l j k = 0 := by
  rcases h with h | h <;> simp [coefficient,disjoint_sites G R hR h]

theorem direct_formula (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R) (i j : Fin n) :
    direct G R i j = (∑ u, ∑ v, interaction (center G R i u) (center G R j v)) / (n:ℝ)^2 := by
  let f := fun u v (p : Space × Space) =>
    density (center G R i u) p.1 * density (center G R j v) p.2 / dist p.1 p.2
  have hf u v : Integrable (f u v) (volume.prod volume) := kernel_integrable _ _
  have point (p : Space × Space) : (spatial G R i p.1 * spatial G R i p.1) *
      (spatial G R j p.2 * spatial G R j p.2) / dist p.1 p.2 = (∑ u, ∑ v, f u v p)/(n:ℝ)^2 := by
    rw [← sq, ← sq,spatial_density G R hR,spatial_density G R hR,div_mul_div_comm,Fintype.sum_mul_sum]
    simp only [f,← Finset.sum_div]
    ring
  unfold direct coefficient
  simp_rw [point]
  rw [integral_div,integral_finsetSum _ (fun u _ => integrable_finsetSum _ (fun v _ => hf u v))]
  simp_rw [integral_finsetSum _ (fun v _ => hf _ v)]
  rfl

theorem direct_nonneg (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R) (i j : Fin n) :
    0 ≤ direct G R i j := by
  rw [direct_formula G R hR]
  exact div_nonneg (Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => nonnegative _ _) (sq_nonneg _)

private theorem component_le_sum (G : SimpleGraph (Fin n)) (R : ℕ) (i j u v : Fin n) :
    interaction (center G R i u) (center G R j v) ≤
      ∑ a, ∑ b, interaction (center G R i a) (center G R j b) :=
  by
    let f := fun a b => interaction (center G R i a) (center G R j b)
    have first : f u v ≤ ∑ b, f u b :=
      Finset.single_le_sum (f:=f u) (fun b _ => nonnegative _ _) (Finset.mem_univ v)
    have second : (∑ b, f u b) ≤ ∑ a, ∑ b, f a b :=
      Finset.single_le_sum (f:=fun a => ∑ b, f a b)
        (fun a _ => Finset.sum_nonneg fun b _ => nonnegative _ _) (Finset.mem_univ u)
    exact first.trans second

/-- A pair of opposite spins occupying the same spatial orbital has a
direct energy of at least 1/(2n²). -/
theorem direct_onsite (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R) (i : Fin n) :
    (1/2:ℝ)/(n:ℝ)^2 ≤ direct G R i i := by
  rw [direct_formula G R hR]
  apply div_le_div_of_nonneg_right _ (sq_nonneg _)
  have h := lower (center G R i i) (center G R i i)
  simp only [dist_self,zero_add] at h
  exact h.trans (component_le_sum _ _ _ _ _ _)

/-- The two close component centers on an edge contribute at least 1/(6n²). -/
theorem direct_edge (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R) {i j : Fin n} (h : G.Adj i j) :
    (1/6:ℝ)/(n:ℝ)^2 ≤ direct G R i j := by
  rw [direct_formula G R hR]
  apply div_le_div_of_nonneg_right _ (sq_nonneg _)
  have lo := lower (center G R i j) (center G R j i)
  rw [FixedBasisGeometry.edgeDistance _ _ h] at lo
  norm_num at lo
  exact lo.trans (component_le_sum _ _ _ _ _ _)

/-- Every component pair of different nonadjacent sites contributes at most
1/(R−2), so the same bound holds for the normalized direct coefficient. -/
theorem direct_nonedge (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R)
    {i j : Fin n} (hne : i≠j) (h : ¬G.Adj i j) :
    direct G R i j ≤ 1/((R:ℝ)-2) := by
  rw [direct_formula G R hR]
  have npos : (0:ℝ)<n := by exact_mod_cast Nat.zero_lt_of_lt i.isLt
  apply (div_le_iff₀ (sq_pos_of_pos npos)).mpr
  have hR' : (4:ℝ)≤R := by exact_mod_cast hR
  calc
    _ ≤ ∑ _ : Fin n, ∑ _ : Fin n, 1/((R:ℝ)-2) := Finset.sum_le_sum fun u _ => Finset.sum_le_sum fun v _ =>
      upper _ _ (by linarith) (FixedBasisGeometry.nonedgeDistance G R hR i u j v hne h)
    _ = _ := by simp; ring

end FQChem.Complexity.SlaterEnergyOrbitals
