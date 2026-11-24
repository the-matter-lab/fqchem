module

public import FQChem.Complexity.SlaterEnergyReduction
public import Mathlib.Analysis.InnerProductSpace.Laplacian
import Mathlib.Tactic

/-! # Kinetic integrals of graph orbitals with disjoint supports

For the compactly supported spatial orbitals, the physical matrix element
−½∫φᵢ Δφⱼ is diagonal and has the same value at each site. Thus the scalar
shift in the fixed-sector energy gap is k times a single primitive integral.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SlaterEnergyKinetic
open MeasureTheory Metric Set Filter InnerProductSpace FixedBasisGaussians SlaterEnergyCoulomb SlaterEnergyOrbitals
open FixedBasisGeometry (center separated)
open scoped Laplacian Topology
variable {n : ℕ}

def kinetic (G : SimpleGraph (Fin n)) (R : ℕ) (i j : Fin n) :=
  -(1/2:ℝ) * ∫ r, spatial G R i r * (Δ (spatial G R j)) r
def primitive := -(1/2:ℝ) * ∫ r, wave (0:Space) r * (Δ (wave (0:Space))) r

/-- Rational one-electron kinetic shift of the normalized C² component. -/
theorem primitive_value : primitive = 195/32 := by
  have w : weight = 4*Real.pi*(256/9009) := FixedBasisRadial.volumeMass
  have scaled : wave 0 = (Real.sqrt weight)⁻¹ • FixedBasisRadial.shape := by
    funext r; simp [wave,bump,div_eq_mul_inv,mul_comm]
  have pt (r : Space) : -(1/2:ℝ)*(wave 0 r*(Δ (wave 0)) r) =
      (-(1/2:ℝ)*(FixedBasisRadial.shape r*(Δ FixedBasisRadial.shape) r))/weight := by
    rw [scaled,laplacian_smul _ FixedBasisRadial.smooth.contDiffAt]
    simp only [Pi.smul_apply,smul_eq_mul]
    field_simp [(Real.sqrt_pos.mpr weight_pos).ne',weight_pos.ne']
    rw [Real.sq_sqrt weight_pos.le]
    ring
  unfold primitive
  rw [←integral_const_mul]
  simp_rw [pt]
  rw [integral_div,FixedBasisRadial.kineticNumerator,w]
  field_simp [Real.pi_ne_zero]

private theorem compact_wave (A : Space) : HasCompactSupport (wave A) := by
  apply (isCompact_closedBall A 1).of_isClosed_subset isClosed_closure
  apply closure_minimal _ isClosed_closedBall
  intro r hr
  by_contra outside
  exact hr (wave_zero (le_of_lt (lt_of_not_ge outside)))

private theorem lap_continuous (A : Space) : Continuous (Δ (wave A)) := by
  rw [laplacian_eq_iteratedFDeriv_orthonormalBasis _ (EuclideanSpace.basisFun (Fin 3) ℝ)]
  have h : Continuous (iteratedFDeriv ℝ 2 (wave A)) := (wave_smooth A).continuous_iteratedFDeriv (by simp)
  fun_prop

private theorem translated (A r : Space) :
    (Δ (wave A)) r = (Δ (wave 0)) (r-A) := by
  have shift : wave A = fun x => wave 0 (x-A) := by funext x; simp [wave]
  rw [laplacian_eq_iteratedFDeriv_orthonormalBasis _ (EuclideanSpace.basisFun (Fin 3) ℝ),
    laplacian_eq_iteratedFDeriv_orthonormalBasis _ (EuclideanSpace.basisFun (Fin 3) ℝ),shift]
  simp [iteratedFDeriv_comp_sub]

private theorem lap_zero {A r : Space} (h : 1<dist r A) : (Δ (wave A)) r=0 := by
  have near : wave A =ᶠ[𝓝 r] (0:Space→ℝ) := by
    filter_upwards [(show ContinuousAt (fun x : Space => dist x A) r from (continuous_id.dist continuous_const).continuousAt).eventually_const_lt h] with x hx
    exact wave_zero hx.le
  have eq := (laplacian_congr_nhds near).eq_of_nhds
  simpa only [Pi.zero_def,laplacian_const] using eq

private theorem disjoint_kinetic (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R)
    {i j u v : Fin n} (hne : (i,j)≠(u,v)) (r : Space) :
    wave (center G R i j) r * (Δ (wave (center G R u v))) r = 0 := by
  by_cases h : 1≤dist r (center G R i j)
  · simp [wave_zero h]
  · have sep := separated G R hR i j u v hne
    have far : 1<dist r (center G R u v) := by
      linarith [dist_triangle (center G R i j) r (center G R u v),dist_comm (center G R i j) r]
    simp [lap_zero far]

private theorem lap_sum (ι : Type*) [Fintype ι] (s : Finset ι) (f : ι → Space → ℝ)
    (hf : ∀ i, ContDiff ℝ 2 (f i)) (r : Space) :
    (Δ (∑ i ∈ s, f i)) r = ∑ i ∈ s, (Δ (f i)) r := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [Pi.zero_def]
  | insert j s hj ih =>
    have hs : ContDiff ℝ 2 (∑ i ∈ s, f i) := by
      change ContDiff ℝ 2 (fun x => (∑ i ∈ s, f i) x)
      simp only [Finset.sum_apply]; exact ContDiff.sum fun i _ => hf i
    rw [Finset.sum_insert hj,Finset.sum_insert hj,(hf j).contDiffAt.laplacian_add hs.contDiffAt,ih]

private theorem lap_spatial (G : SimpleGraph (Fin n)) (R : ℕ) (j : Fin n) (r : Space) :
    (Δ (spatial G R j)) r = (∑ v, (Δ (wave (center G R j v))) r)/Real.sqrt n := by
  let f := fun v => wave (center G R j v)
  have hf v : ContDiff ℝ 2 (f v) := (wave_smooth _).of_le (by simp)
  have eq : spatial G R j = (Real.sqrt n)⁻¹ • (∑ v, f v) := by
    funext x; simp [spatial,f,Finset.sum_apply,div_eq_mul_inv,mul_comm]
  have hs : ContDiff ℝ 2 (∑ v, f v) := by
    change ContDiff ℝ 2 (fun x => (∑ v, f v) x)
    simp only [Finset.sum_apply]; exact ContDiff.sum fun v _ => hf v
  rw [eq,laplacian_smul _ hs.contDiffAt, lap_sum _ _ f hf]
  simp [f,div_eq_mul_inv,mul_comm]

private theorem primitive_integral (A : Space) :
    (∫ r, wave A r * (Δ (wave A)) r) = ∫ r, wave 0 r * (Δ (wave 0)) r := by
  have eq (r : Space) : wave A r * (Δ (wave A)) r = wave 0 (r-A) * (Δ (wave 0)) (r-A) := by
    rw [translated]; simp [wave]
  simp_rw [eq]; exact integral_sub_right_eq_self (μ:=volume) (fun r : Space => wave 0 r * (Δ (wave 0)) r) A

theorem kinetic_matrix (G : SimpleGraph (Fin n)) (R : ℕ) (hR : 4≤R) (i j : Fin n) :
    kinetic G R i j = if i=j then primitive else 0 := by
  classical
  let f := fun u v (r : Space) => wave (center G R i u) r * (Δ (wave (center G R j v))) r
  have hf (u v : Fin n) : Integrable (f u v) :=
    (((wave_smooth _).continuous).mul (lap_continuous _)).integrable_of_hasCompactSupport
      ((compact_wave _).mul_right)
  have point (r : Space) : spatial G R i r * (Δ (spatial G R j)) r =
      (∑ u, ∑ v, f u v r) / n := by
    rw [lap_spatial,spatial,div_mul_div_comm,← sq,Real.sq_sqrt (Nat.cast_nonneg n),Fintype.sum_mul_sum]
  unfold kinetic
  simp_rw [point]
  rw [integral_div,integral_finsetSum _ (fun u _ => integrable_finsetSum _ (fun v _ => hf u v))]
  simp_rw [integral_finsetSum _ (fun v _ => hf _ v)]
  by_cases eq : i=j
  · subst j
    have inner (u : Fin n) : (∑ v, ∫ r, f u v r) = ∫ r, wave 0 r*(Δ (wave 0)) r := by
      rw [Finset.sum_eq_single u]
      · exact primitive_integral _
      · intro v _ hv
        simp [f,disjoint_kinetic G R hR (fun h => hv (congrArg Prod.snd h).symm)]
      · simp
    simp_rw [inner]
    have hn : (n:ℝ)≠0 := by exact_mod_cast Nat.ne_of_gt (Nat.zero_lt_of_lt i.isLt)
    simp [primitive,hn]
  · simp [f,eq,disjoint_kinetic G R hR (fun h => eq (congrArg Prod.fst h))]

/-- The scalar kinetic matrix acts on every k-electron occupation as k times
the primitive kinetic energy. The same full diagonal energy matrix therefore
has the inverse-polynomial YES and NO separation for the graph construction. -/
theorem physicalSlaterGap (G : SimpleGraph (Fin n)) (hn : 0<n) (k : ℕ) :
    let R := SlaterEnergyReduction.spacing n
    let shift := (k:ℝ)*primitive
    (∀ i j, kinetic G R i j = if i=j then primitive else 0) ∧
    (∀ i l j q, i≠l ∨ j≠q → coefficient G R i l j q = 0) ∧
    (SlaterEnergy.Independent G k → ∃ ψ : SlaterEnergy.Sector n k → ℂ,
      SlaterEnergy.IsSlater ψ ∧ ElectronicStructure.mass ψ=1 ∧
      ElectronicStructure.matrixExpectation (SlaterEnergyReduction.hamiltonian G shift) ψ ≤ shift+1/(12*(n:ℝ)^2)) ∧
    (¬ SlaterEnergy.Independent G k → ∀ ψ : SlaterEnergy.Sector n k → ℂ, ElectronicStructure.mass ψ=1 →
      shift+1/(6*(n:ℝ)^2) ≤ ElectronicStructure.matrixExpectation (SlaterEnergyReduction.hamiltonian G shift) ψ) := by
  let R := SlaterEnergyReduction.spacing n
  have large : 4 ≤ R := by
    dsimp [R,SlaterEnergyReduction.spacing]; have h : 1≤n^4 := Nat.one_le_pow _ _ hn; omega
  exact ⟨kinetic_matrix G R large,fun _ _ _ _ h => coefficient_offdiag G R large h,
    SlaterEnergyReduction.coulombDecisionGap G hn k _⟩

end FQChem.Complexity.SlaterEnergyKinetic
