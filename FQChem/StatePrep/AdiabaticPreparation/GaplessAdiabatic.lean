module

public import FQChem.StatePrep.AdiabaticPreparation.ApproximateCommutator
public import Mathlib.Analysis.InnerProductSpace.Adjoint
public import Mathlib.Analysis.InnerProductSpace.Spectrum
public import Mathlib.Analysis.InnerProductSpace.Projection.Submodule
public import Mathlib.Analysis.Calculus.Deriv.Star
import Mathlib.Tactic

/-! # Avron–Elgart's adiabatic theorem without a gap

A bounded self-adjoint Hamiltonian on a complex Hilbert space may have
continuous spectrum arbitrarily close to the selected eigenvalues. For a
finite-rank spectral projection its derivative is in the norm closure of
the commutators with the Hamiltonian. Compactness in time then gives
uniform convergence for all initial unit vectors in the selected band.

[Avron and Elgart (1999), Theorem 1](https://doi.org/10.1007/s002200050620).
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.AdiabaticPreparation

open Set InnerProductSpace ContinuousLinearMap
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E]
local notation "Op" => E →L[ℂ] E

/-- Finite-rank spectral projection in eigenbasis form. It includes each
selected eigenspace in full. No distance to the rest of the spectrum is specified. -/
structure SpectralBand (H P : Op) where
  rank : ℕ
  ket : Fin rank → E
  energy : Fin rank → ℝ
  orthonormal : Orthonormal ℂ ket
  eigen (i) : H (ket i) = (energy i : ℂ) • ket i
  full (i) (x : E) : H x = (energy i : ℂ) • x → P x = x
  resolution : P = ∑ i, rankOne ℂ (ket i) (ket i)

private theorem band_selfAdjoint {H P : Op} (b : SpectralBand H P) : IsSelfAdjoint P := by
  change star P = P
  rw [b.resolution, star_sum]
  apply Finset.sum_congr rfl
  intro i _; exact adjoint_rankOne _ _

omit [CompleteSpace E] in
private theorem band_idempotent {H P : Op} (b : SpectralBand H P) : P * P = P := by
  nth_rw 2 [b.resolution]
  rw [Finset.mul_sum]
  conv_rhs => rw [b.resolution]
  apply Finset.sum_congr rfl
  intro i _
  change P ∘L rankOne ℂ _ _ = _
  rw [comp_rankOne, b.full i _ (b.eigen i)]

private theorem comm_rankOne {H : Op} (hH : IsSelfAdjoint H) {e : E} {μ : ℝ}
    (he : H e = (μ : ℂ) • e) (z : E) :
    H * rankOne ℂ z e - rankOne ℂ z e * H = rankOne ℂ (H z - (μ : ℂ) • z) e := by
  change H ∘L _ - _ ∘L H = _
  rw [comp_rankOne, rankOne_comp, show adjoint H = H from hH, he]
  ext w
  simp only [sub_apply, rankOne_apply, smul_sub, inner_smul_left, Complex.conj_ofReal,
    smul_smul, mul_comm]

private theorem band_commutes {H P : Op} (hH : IsSelfAdjoint H) (b : SpectralBand H P) :
    Commute H P := by
  change H * P = P * H
  rw [b.resolution, Finset.mul_sum, Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro i _
  apply sub_eq_zero.mp
  rw [comm_rankOne hH (b.eigen i), b.eigen i, sub_self, map_zero]
  rfl

private def commRange (H : Op) : Submodule ℂ (E →L[ℂ] E) :=
  LinearMap.range (LinearMap.mulLeft ℂ H - LinearMap.mulRight ℂ H)

private theorem star_comm_closure {H D : Op} (hH : IsSelfAdjoint H)
    (h : D ∈ (commRange H).topologicalClosure) : star D ∈ (commRange H).topologicalClosure := by
  have maps : MapsTo star (commRange H : Set (E →L[ℂ] E)) (commRange H) := by
    rintro _ ⟨X, rfl⟩
    refine ⟨-star X, ?_⟩
    change H * -star X - -star X * H = star (H * X - X * H)
    simp [hH.star_eq]; abel
  exact maps.closure continuous_star h

private theorem rankOne_comm_closure {H : Op} (hH : IsSelfAdjoint H) {e u : E} {μ : ℝ}
    (he : H e = (μ : ℂ) • e)
    (hu : ∀ v : E, H v = (μ : ℂ) • v → inner ℂ v u = 0) :
    rankOne ℂ u e ∈ (commRange H).topologicalClosure := by
  let S : Op := H - (μ : ℂ) • 1
  have hS : IsSelfAdjoint S := by change star _ = _; simp [S, hH.star_eq]
  have mem : u ∈ S.range.topologicalClosure := by
    rw [← Submodule.orthogonal_orthogonal_eq_closure, hS.isStarNormal.orthogonal_range]
    apply (Submodule.mem_orthogonal _ _).mpr
    intro v hv
    apply hu
    change H v - (μ : ℂ) • v = 0 at hv
    exact sub_eq_zero.mp hv
  have maps : MapsTo (fun w => rankOne ℂ w e) (S.range : Set E) (commRange H) := by
    rintro _ ⟨z, rfl⟩
    exact ⟨rankOne ℂ z e, comm_rankOne hH he z⟩
  exact maps.closure (((rankOne ℂ (E := E) (F := E)).flip e).continuous) mem

/-- The tangent to a finite spectral band belongs to the norm closure of
commutators, even for eigenvalues embedded in continuous spectrum. -/
theorem approximateSpectralCommutator {H P D : Op} (hH : IsSelfAdjoint H)
    (band : SpectralBand H P) (hD : IsSelfAdjoint D) (tangent : D * P + P * D = D) :
    ∀ δ > 0, ∃ X : Op, ‖D - (H * X - X * H)‖ < δ := by
  have hP := band_selfAdjoint band
  have hPP := band_idempotent band
  have middle : P * D * P = 0 := by
    have eq := congrArg (P * ·) tangent
    simp only [mul_add, ← mul_assoc, hPP] at eq
    exact add_right_cancel (show _ + P * D = 0 + P * D by simpa using eq)
  have half : D * P ∈ (commRange H).topologicalClosure := by
    rw [band.resolution, Finset.mul_sum]
    apply Submodule.sum_mem
    intro i _
    change D ∘L _ ∈ _
    rw [comp_rankOne]
    apply rankOne_comm_closure hH (band.eigen i)
    intro v hv
    have zero : P (D (band.ket i)) = 0 := by
      have z := congrArg (fun B : E →L[ℂ] E => B (band.ket i)) middle
      simpa only [mul_apply_eq_comp, Function.comp_apply, band.full i _ (band.eigen i), zero_apply] using z
    calc inner ℂ v (D (band.ket i)) = inner ℂ (P v) (D (band.ket i)) := by rw [band.full i v hv]
         _ = inner ℂ v (P (D (band.ket i))) := hP.isSymmetric _ _
         _ = 0 := by rw [zero, inner_zero_right]
  have other := star_comm_closure hH half
  rw [star_mul, hP.star_eq, hD.star_eq] at other
  have complete : D ∈ (commRange H).topologicalClosure := tangent ▸
    (commRange H).topologicalClosure.add_mem half other
  intro δ hδ
  obtain ⟨_, ⟨X, rfl⟩, hx⟩ := Metric.mem_closure_iff.mp complete δ hδ
  exact ⟨X, by simpa [dist_eq_norm] using hx⟩


/-- Avron–Elgart Theorem 1. All unit initial vectors in the moving finite
spectral band approach that band uniformly in scaled time as runtime grows.
The norm here is the distance to the band, given by the orthogonal residual.
The propagators solve the rescaled forward and inverse Schrödinger equations. -/
theorem gaplessAdiabatic (H P P' : ℝ → (E →L[ℂ] E))
    (hH : ∀ s ∈ Icc (0:ℝ) 1, IsSelfAdjoint (H s))
    (band : ∀ s ∈ Icc (0:ℝ) 1, SpectralBand (H s) (P s))
    (contH : ContinuousOn H (Icc 0 1)) (contD : ContinuousOn P' (Icc 0 1))
    (hd : ∀ s ∈ Icc (0:ℝ) 1, HasDerivAt P (P' s) s) :
    ∀ ε > 0, ∃ T₀ : ℝ, ∀ T ≥ T₀, ∀ U V,
      SlowEvolution (fun t => (-Complex.I) • H t) T U V →
      ∀ s ∈ Icc (0:ℝ) 1, ∀ ψ : E, ‖ψ‖ = 1 → P 0 ψ = ψ →
        ‖U s ψ - P s (U s ψ)‖ < ε := by
  let A := fun t => (-Complex.I) • H t
  have hc (s : ℝ) (hs : s ∈ Icc (0:ℝ) 1) : Commute (A s) (P s) :=
    (band_commutes (hH s hs) (band s hs)).smul_left _
  have approx (s : ℝ) (hs : s ∈ Icc (0:ℝ) 1) (δ : ℝ) (hδ : 0 < δ) :
      ∃ X, ‖P' s - (A s * X - X * A s)‖ < δ := by
    have d := (hd s hs).hasDerivWithinAt (s := Icc (0:ℝ) 1)
    have diff := uniqueDiffOn_Icc_zero_one s hs
    have tangent : P' s * P s + P s * P' s = P' s :=
      diff.eq_deriv _ ((d.fun_mul d).congr_of_mem (fun t ht => (band_idempotent (band t ht)).symm) hs) d
    have self : IsSelfAdjoint (P' s) :=
      diff.eq_deriv _ (d.star.congr_of_mem (fun t ht => (band_selfAdjoint (band t ht)).star_eq.symm) hs) d
    obtain ⟨X, near⟩ := approximateSpectralCommutator (hH s hs) (band s hs) self tangent δ hδ
    refine ⟨Complex.I • X, ?_⟩
    simpa [A, smul_mul_assoc, mul_smul_comm, smul_smul] using near
  intro ε hε
  obtain ⟨T₀, transport⟩ := approximateCommutatorTransport A P P'
    (contH.const_smul (-Complex.I)) contD hc hd approx ε hε
  refine ⟨T₀, ?_⟩
  intro T hT U V ev s hs ψ hψ fixed
  have bound := transport T hT U V ev s hs
  have op := (P s * U s - U s * P 0).le_opNorm ψ
  rw [hψ, mul_one] at op
  rw [norm_sub_rev]
  exact lt_of_le_of_lt (by simpa only [sub_apply, mul_apply_eq_comp, Function.comp_apply, fixed] using op) bound


/-- The spectral theorem on the finite-dimensional invariant space supplies
the eigenbasis. The ambient Hilbert space may be infinite-dimensional. -/
def SpectralBand.ofInvariant (H : Op) (hH : IsSelfAdjoint H) (K : Submodule ℂ E)
    [FiniteDimensional ℂ K] (inv : ∀ x ∈ K, H x ∈ K)
    (full : ∀ μ : ℝ, (∃ x ∈ K, x ≠ 0 ∧ H x = (μ : ℂ) • x) →
      ∀ v, H v = (μ : ℂ) • v → v ∈ K) : SpectralBand H K.starProjection := by
  let B := H.toLinearMap.restrict inv
  have sym : B.IsSymmetric := hH.isSymmetric.restrict_invariant inv
  let b := sym.eigenvectorBasis rfl
  let energy := sym.eigenvalues rfl
  have eig (i : Fin (Module.finrank ℂ K)) : H (b i : E) = (energy i : ℂ) • (b i : E) :=
    congrArg Subtype.val (sym.apply_eigenvectorBasis rfl i)
  exact {
    rank := Module.finrank ℂ K
    ket := fun i => (b i : E)
    energy := energy
    orthonormal := K.subtypeₗᵢ.orthonormal_comp_iff.mpr b.orthonormal
    eigen := eig
    full := fun i v hv => K.starProjection_eq_self_iff.mpr (full (energy i)
      ⟨b i, (b i).property, by simpa using (b.orthonormal.ne_zero i), eig i⟩ v hv)
    resolution := b.starProjection_eq_sum_rankOne}

/-- Basis-free distance formulation for a finite-rank spectral subspace K(s).
An eigenvalue selected by K(s) has its whole eigenspace in K(s); arbitrarily
nearby spectrum outside K(s) is allowed. -/
theorem gaplessAdiabaticDistance (H : ℝ → (E →L[ℂ] E)) (K : ℝ → Submodule ℂ E)
    [∀ s, FiniteDimensional ℂ (K s)] (P' : ℝ → (E →L[ℂ] E))
    (hH : ∀ s ∈ Icc (0:ℝ) 1, IsSelfAdjoint (H s))
    (inv : ∀ s ∈ Icc (0:ℝ) 1, ∀ x ∈ K s, H s x ∈ K s)
    (spectral : ∀ s ∈ Icc (0:ℝ) 1, ∀ μ : ℝ, (∃ x ∈ K s, x ≠ 0 ∧ H s x = (μ : ℂ) • x) →
      ∀ v, H s v = (μ : ℂ) • v → v ∈ K s)
    (contH : ContinuousOn H (Icc 0 1)) (contD : ContinuousOn P' (Icc 0 1))
    (hd : ∀ s ∈ Icc (0:ℝ) 1, HasDerivAt (fun t => (K t).starProjection) (P' s) s) :
    ∀ ε > 0, ∃ T₀ : ℝ, ∀ T ≥ T₀, ∀ U V,
      SlowEvolution (fun t => (-Complex.I) • H t) T U V →
      ∀ s ∈ Icc (0:ℝ) 1, ∀ ψ ∈ K 0, ‖ψ‖ = 1 → Metric.infDist (U s ψ) (K s) < ε := by
  intro ε hε
  obtain ⟨T₀, bound⟩ := gaplessAdiabatic H _ P' hH
    (fun s hs => SpectralBand.ofInvariant (H s) (hH s hs) (K s) (inv s hs) (spectral s hs))
    contH contD hd ε hε
  refine ⟨T₀, ?_⟩
  intro T hT U V ev s hs ψ hψ hnorm
  rw [← Submodule.dist_starProjection_eq_infDist, dist_eq_norm]
  exact bound T hT U V ev s hs ψ hnorm ((K 0).starProjection_eq_self_iff.mpr hψ)

end FQChem.StatePrep.AdiabaticPreparation
