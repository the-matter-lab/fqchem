module

public import FQChem.Properties.LinearSystems.HHL
public import Mathlib.Analysis.InnerProductSpace.Adjoint
public import Mathlib.Data.Matrix.Block
public import Mathlib.LinearAlgebra.Matrix.Hermitian
import Mathlib.Tactic

/-! # Damped molecular response as a linear solve

The frequency-shifted electronic Hamiltonian acts on the response vector
driven by the ground-state dipole. Positive damping gives a unique solution
even at resonance. The doubled Hermitian system is the input to a
quantum linear solver in [Cai et al. (2020), Eqs. (3)–(13)](https://arxiv.org/abs/2001.03406).
-/

@[expose] public section
noncomputable section
namespace FQChem.Properties.MolecularResponse
open Matrix
open scoped ComplexConjugate InnerProductSpace Matrix

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- D is H − (E₀ + ω)I for the resonant branch of the response. -/
def damped (D : E →L[ℂ] E) (γ : ℝ) : E →L[ℂ] E := D - ((γ : ℂ)*Complex.I) • 1

theorem dampingIdentity (D : E →L[ℂ] E) (hD : D.toLinearMap.IsSymmetric) (γ : ℝ) (v : E) :
    ‖damped D γ v‖^2 = ‖D v‖^2 + γ^2*‖v‖^2 := by
  change ‖D v - ((γ : ℂ)*Complex.I) • v‖^2 = _
  rw [@norm_sub_sq ℂ, inner_smul_right, ← hD.coe_reApplyInnerSelf_apply, norm_smul, norm_mul]
  simp [mul_pow]

/-- A residual r in the damped response equation certifies absolute
wavefunction error at most ‖r‖/γ for arbitrary input and approximate vectors. -/
theorem residualError (D : E →L[ℂ] E) (hD : D.toLinearMap.IsSymmetric)
    {γ : ℝ} (hγ : 0 < γ) (u v : E) :
    ‖u-v‖ ≤ ‖damped D γ u - damped D γ v‖ / γ := by
  rw [← map_sub, le_div_iff₀ hγ]
  have square := dampingIdentity D hD γ (u-v)
  nlinarith [sq_nonneg ‖D (u-v)‖, norm_nonneg (damped D γ (u-v)), norm_nonneg (u-v)]

/-- In any finite electronic basis, the damped linear response equation
has a unique solution for every right-hand side and every optical frequency. -/
theorem uniqueResponse [FiniteDimensional ℂ E] (D : E →L[ℂ] E) (hD : D.toLinearMap.IsSymmetric)
    {γ : ℝ} (hγ : 0<γ) (b : E) : ∃! v, damped D γ v = b := by
  have inj : Function.Injective (damped D γ) := by
    intro u v eqn
    have err := residualError D hD hγ u v
    rw [eqn, sub_self, norm_zero, zero_div] at err
    exact sub_eq_zero.mp (norm_le_zero_iff.mp err)
  obtain ⟨v,hv⟩ := (LinearMap.injective_iff_surjective (f := (damped D γ).toLinearMap)).mp inj b
  exact ⟨v,hv,fun u hu => inj (hu.trans hv.symm)⟩

/-- The Hermitian dilation used in Eq. (12) implements the original complex
response equation exactly on vectors supported on its second block. -/
theorem hermitianResponseSystem {ι : Type*} [Fintype ι] (A : Matrix ι ι ℂ) (u b : ι → ℂ) :
    (Matrix.fromBlocks 0 A Aᴴ 0).IsHermitian ∧
    ((Matrix.fromBlocks 0 A Aᴴ 0) *ᵥ Sum.elim (0 : ι → ℂ) u = Sum.elim b 0 ↔ A *ᵥ u = b) := by
  constructor
  · simp [Matrix.IsHermitian, Matrix.fromBlocks_conjTranspose]
  · rw [Matrix.fromBlocks_mulVec]
    simp only [zero_mulVec, Function.comp_def, Sum.elim_inl, Sum.elim_inr, zero_add,
      add_zero]
    constructor
    · intro h
      exact funext fun i => congrFun h (Sum.inl i)
    · intro h
      change Sum.elim (A *ᵥ u) (Aᴴ *ᵥ (0 : ι → ℂ)) = Sum.elim b 0
      rw [h, mulVec_zero]

/-- In energy coordinates, a driven amplitude bⱼ contributes bⱼ/(Δⱼ−z).
Both frequency branches enter the dynamic dipole polarizability. -/
def amplitude (Δ : ℝ) (z b : ℂ) : ℂ := b / ((Δ:ℂ)-z)

/-- The spectral-inversion step of HHL solves the driven equation in a
supplied eigenbasis of the shifted operator, including off-resonant modes. -/
theorem spectralResponse {d k : ℕ} (A : (Fin d → ℂ) →ₗ[ℂ] (Fin d → ℂ))
    (u : Fin k → Fin d → ℂ) (Δ : Fin k → ℝ) (b : Fin k → ℂ) (z : ℂ) (hz : z.im ≠ 0)
    (eig : ∀ j, A (u j) = ((Δ j : ℂ)-z) • u j) :
    A (∑ j, amplitude (Δ j) z (b j) • u j) = ∑ j, b j • u j := by
  apply FQChem.Algorithms.hhlSpectralInversion d k A u (fun j => (Δ j : ℂ)-z) b eig
  intro j h
  have eqn := congrArg Complex.im (sub_eq_zero.mp h)
  exact hz (by simpa using eqn.symm)

/-- Sum-over-states polarizability, Eq. (3), from the two auxiliary solutions.
A permanent dipole is allowed. Its ground-state component cancels between the
two solves, giving exactly the sum over excited states. -/
theorem polarizability {ι : Type*} [Fintype ι] [DecidableEq ι] (g : ι)
    (Δ : ι → ℝ) (b : ι → ℂ) (z : ℂ) (hg : Δ g = 0) :
    (∑ j, conj (b j) * amplitude (Δ j) z (b j)) +
        (∑ j, conj (b j) * amplitude (Δ j) (-z) (b j)) =
    ∑ j ∈ Finset.univ.erase g, (Complex.normSq (b j) : ℂ) *
      (1/((Δ j : ℂ)-z) + 1/((Δ j : ℂ)+z)) := by
  rw [← Finset.sum_add_distrib, ← Finset.sum_erase_add _ _ (Finset.mem_univ g)]
  have ground : conj (b g) * amplitude (Δ g) z (b g) +
      conj (b g) * amplitude (Δ g) (-z) (b g) = 0 := by simp [hg, amplitude, div_neg]
  rw [ground, add_zero]
  apply Finset.sum_congr rfl
  intro j _
  rw [← Complex.mul_conj]
  simp [amplitude, div_eq_mul_inv, mul_add]
  ring

end FQChem.Properties.MolecularResponse
