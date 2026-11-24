module

public import FQChemQatlib.Dynamics.LowChuangSparseReadout
public import Qatlib.Concepts.LchsSimulation.StaticLchs.StaticNoncommutingLCHS
public import Qatlib.Concepts.MixedFidelity.FidelityMetric.MixedFidelity
public import Qatlib.Papers.ResolventQPE24.MainResults.SpectralTheory.SourceSpectralBounds
public import Qatlib.Foundations.PureStateMath.BornBridge.RelabelOperatorNorm
public import Mathlib.Analysis.Normed.Module.Normalize

/-! # Successful output states, source rounding and the zero-sparsity case -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseAssembly

open Qatlib.Foundations.PureStateMath.Reflection
open Matrix Query Qatlib.Foundations.PureStateMath Qatlib.Foundations.PureStateMath.BornBridge
open Qatlib.Concepts.QspSimulation.Achievability Qatlib.Concepts.ReferenceError.RefTraceError
open Qatlib.Concepts.LchsSimulation.StaticLchs Qatlib.Concepts.MixedFidelity.FidelityMetric
open Sparse (Access)
open scoped Classical Matrix.Norms.L2Operator

variable {I : Type} [Fintype I] [DecidableEq I]

/-- The successful compressed operator approximates the evolution of the
exact matrix encoded by the value oracle. An additional source error δ in
spectral norm contributes at most |t|δ to comparison with another input. -/
theorem roundedHamiltonian (H K C : Matrix I I ℂ) (hH : H.IsHermitian) (hK : K.IsHermitian)
    (t ε δ : ℝ) (simulation : ‖C-hamiltonianEvolution K t‖≤ε) (source : ‖K-H‖≤δ) :
    ‖C-hamiltonianEvolution H t‖ ≤ ε+|t| * δ := by
  have stable := static_lchs_hamiltonian_evolution_stability K H hK hH t
  exact (norm_sub_le_norm_sub_add_norm_sub _ (hamiltonianEvolution K t) _).trans
    (add_le_add simulation (stable.trans (mul_le_mul_of_nonneg_left source (abs_nonneg _))))

/-- For Hermitian rounding errors on at most d positions per row, a bound
η on each complex entry implies spectral error at most dη. -/
theorem entryRoundoff (D : Matrix I I ℂ) (hD : D.IsHermitian) (d : ℕ) (η : ℝ) (hη : 0≤η)
    (rows : ∀ i,(Finset.univ.filter fun j => D i j≠0).card≤d) (entries : ∀ i j,‖D i j‖≤η) :
    ‖D‖≤d*η := by
  let b := (d:ℝ)*η
  have nonneg : 0≤b := by unfold b; positivity
  have bound (i : I) : (∑ j,‖D i j‖)≤b := by
    let s := Finset.univ.filter (fun j => D i j≠0)
    calc
      _ = ∑ j∈s,‖D i j‖ := by
        apply (Finset.sum_subset (Finset.subset_univ _) (fun j _ hj => ?_)).symm
        have zero : D i j=0 := by simpa [s] using hj
        simp [zero]
      _ ≤ ∑ _j∈s,η := Finset.sum_le_sum (fun j _ => entries i j)
      _ = (s.card:ℝ)*η := by simp
      _ ≤ b := mul_le_mul_of_nonneg_right (by exact_mod_cast rows i) hη
  have col (j : I) : (∑ i,‖D i j‖)≤b := by
    calc
      _ = ∑ i,‖D j i‖ := Finset.sum_congr rfl (fun i _ => by rw [←hD.apply j i,norm_star])
      _ ≤ _ := bound j
  let e := Fintype.equivFin I
  let V := relabelGate e D
  have vr (i : Fin (Fintype.card I)) : (∑ j,‖V i j‖)≤b := by
    exact ((e.symm.sum_comp fun j => ‖D (e.symm i) j‖).le).trans (bound _)
  have vc (j : Fin (Fintype.card I)) : (∑ i,‖V i j‖)≤b := by
    exact ((e.symm.sum_comp fun i => ‖D i (e.symm j)‖).le).trans (col _)
  have norm := Qatlib.Papers.ResolventQPE24.MainResults.SpectralTheory.spectral_norm_le_rowCol_sums
    V b b vr vc nonneg nonneg
  rw [Real.mul_self_sqrt nonneg] at norm
  exact (l2_norm_relabelGate e D).symm.le.trans norm

/-- The simulation error for the encoded Hamiltonian and a per-entry
rounding error η for an external Hermitian source are separate quantities.
Here d bounds the row support of their difference. -/
theorem roundedSparseEvolution (H K C : Matrix I I ℂ) (hH : H.IsHermitian) (hK : K.IsHermitian)
    (t ε η : ℝ) (hη : 0≤η) (d : ℕ) (simulation : ‖C-hamiltonianEvolution K t‖≤ε)
    (support : ∀ i,(Finset.univ.filter fun j => (K-H) i j≠0).card≤d)
    (entries : ∀ i j,‖(K-H) i j‖≤η) :
    ‖C-hamiltonianEvolution H t‖≤ε+|t| * (d*η) :=
  roundedHamiltonian H K C hH hK t ε _ simulation (entryRoundoff _ (hK.sub hH) d η hη support entries)

/-- Max-entry norm zero and zero nonzeros per row both force exact identity
evolution. The empty program makes zero calls to either sparse oracle. -/
theorem zeroAccess (n : ℕ) (t : ℝ) (H : Matrix (Reg n) (Reg n) ℂ)
    (h : (∀ i j, ‖H i j‖≤0) ∨ (∀ i,(Finset.univ.filter (fun j => H i j≠0)).card=0))
    (data : Access → Matrix (Reg n) (Reg n) ℂ) :
    run data []=hamiltonianEvolution H t ∧
    (∀ a : Access,cost a ([] : List (Step (Reg n) Access))=0) ∧ fixedCount ([] : List (Step (Reg n) Access))=0 := by
  have eq : H=0 := by
    ext i j
    change H i j=0
    rcases h with hn|hc
    · exact norm_le_zero_iff.mp (hn i j)
    · by_contra nz
      have mem : j∈Finset.univ.filter (fun k => H i k≠0) := by simp [nz]
      simp [Finset.card_eq_zero.mp (hc i)] at mem
  exact eq ▸ zeroHamiltonian n t data

private theorem normalize_error {E:Type} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (x y : E) {δ:ℝ} (small : δ<1) (hy : ‖y‖=1) (err : ‖x-y‖≤δ) :
    ‖NormedSpace.normalize x‖=1 ∧ ‖NormedSpace.normalize x-y‖≤2*δ := by
  have nz : x≠0 := by rintro rfl; simp [hy] at err; linarith
  have normed := NormedSpace.norm_normalize nz
  refine ⟨normed,?_⟩
  have diff : ‖NormedSpace.normalize x-x‖=|1-‖x‖| := by
    calc
      _ = ‖(1-‖x‖) • NormedSpace.normalize x‖ := by rw [sub_smul,one_smul,NormedSpace.norm_smul_normalize]
      _ = _ := by rw [norm_smul,normed,mul_one,Real.norm_eq_abs]
  have quality := abs_norm_sub_norm_le y x
  rw [hy,norm_sub_rev y x] at quality
  have tri := norm_sub_le_norm_sub_add_norm_sub (NormedSpace.normalize x) x y
  rw [diff] at tri
  linarith

/-- Explicit comparison for normalized successful pure states. The input
δ is the successful-block spectral error, e.g. ε²/2 for the physical
circuit above. The same 2δ bound applies to trace distance. -/
theorem successfulOutput (C U : Matrix I I ℂ) (unit : U∈Matrix.unitaryGroup _ ℂ)
    {δ : ℝ} (small : δ<1) (err : ‖C-U‖≤δ) (ψ : QState I) (hψ : Normalized ψ) :
    let x := toEuclidean_fromVec (C *ᵥ ψ)
    let y := toEuclidean_fromVec (U *ᵥ ψ)
    let v := NormedSpace.normalize x
    ‖x-y‖≤δ ∧ ‖v‖=1 ∧ ‖v-y‖≤2*δ ∧
    (outerProduct (WithLp.ofLp v)-outerProduct (U *ᵥ ψ)).traceNorm / 2 ≤ 2*δ := by
  let x := toEuclidean_fromVec (C *ᵥ ψ)
  let y := toEuclidean_fromVec (U *ᵥ ψ)
  let z := NormedSpace.normalize x
  have hraw := l2_norm_mulVec_fromVec_le (C-U) ψ
  rw [(normalized_iff_norm_toEuclidean_fromVec _).mp hψ,mul_one,Matrix.sub_mulVec] at hraw
  have diff : ‖x-y‖≤δ := hraw.trans err
  have hu := normalized_applyGate unit hψ
  have hy : ‖y‖=1 := (normalized_iff_norm_toEuclidean_fromVec _).mp hu
  obtain ⟨hz,ez⟩ := normalize_error x y small hy diff
  have hz' : Normalized (WithLp.ofLp z) := (normalized_iff_norm_toEuclidean_fromVec _).mpr hz
  refine ⟨diff,hz,ez,?_⟩
  have tr := pure_trace_distance_le_re_inner (WithLp.ofLp z) (U *ᵥ ψ) hz' hu
  apply tr.trans (le_trans _ ez)
  rw [Real.sqrt_le_iff]
  refine ⟨norm_nonneg _,?_⟩
  rw [norm_sub_sq (𝕜:=ℂ),hy,hz]
  have inner : inner ℂ z y = Inner (WithLp.ofLp z) (U *ᵥ ψ) := inner_euclidean_fromVec _ _
  rw [inner]
  let a := (Inner (WithLp.ofLp z) (U *ᵥ ψ)).re
  change 1-a^2 ≤ 1^2-2*a+1^2
  nlinarith [sq_nonneg (1-a)]

end FQChemQatlib.Dynamics.LowChuang.SparseAssembly
