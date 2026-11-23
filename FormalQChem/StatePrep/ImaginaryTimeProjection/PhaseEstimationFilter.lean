module

public import FormalQChem.StatePrep.ImaginaryTimeProjection.GroundStateProjection
public import Mathlib.Analysis.Complex.Trigonometric
public import Mathlib.Algebra.Ring.GeomSum

/-! # Heralded ground-state preparation by phase estimation

After shifting the target energy to zero, postselect Fourier-register outcome zero.
The controlled powers and inverse Fourier transform multiply each energy eigenvector
by the finite Fourier average of its relative phase. Ground degeneracy is allowed.
[Abrams and Lloyd (1999)](https://doi.org/10.1103/PhysRevLett.83.5162). -/

@[expose] public section
noncomputable section

namespace FormalQChem.StatePrep.ImaginaryTimeProjection.PhaseEstimationFilter

/-- QPE amplitude at the zero readout after N phase samples. -/
def kernel (N : ℕ) (z : ℂ) : ℂ := (∑ j ∈ Finset.range N, z ^ j) / N

/-- The phase relative to the chosen ground-energy origin, in units ℏ = 1. -/
def phase (τ Δ : ℝ) : ℂ := Complex.exp ((-(τ * Δ) : ℝ) * Complex.I)

theorem kernel_at_target (N : ℕ) [NeZero N] : kernel N 1 = 1 := by
  simp [kernel, NeZero.ne (N : ℂ)]

theorem kernel_at_distinct_grid_phase {N : ℕ} {z : ℂ} (grid : z ^ N = 1) (distinct : z ≠ 1) :
    kernel N z = 0 := by
  have h := geom_sum_mul z N
  rw [grid, sub_self] at h
  simp [kernel, (mul_eq_zero.mp h).resolve_right (sub_ne_zero.mpr distinct)]

theorem kernel_norm_le_one (N : ℕ) [NeZero N] {z : ℂ} (unit : ‖z‖ = 1) :
    ‖kernel N z‖ ≤ 1 := by
  rw [kernel, norm_div, Complex.norm_natCast, div_le_one (by exact_mod_cast Nat.pos_of_ne_zero (NeZero.ne N))]
  calc ‖∑ j ∈ Finset.range N, z ^ j‖ ≤ ∑ j ∈ Finset.range N, ‖z ^ j‖ := norm_sum_le ..
       _ = N := by simp [norm_pow, unit]

/-- Uniform off-target suppression in terms of chord distance on the phase circle. -/
theorem kernel_suppression (N : ℕ) [NeZero N] {z : ℂ} (unit : ‖z‖ = 1)
    {δ : ℝ} (positive : 0 < δ) (separated : δ ≤ ‖z - 1‖) :
    ‖kernel N z‖ ≤ 2 / (N * δ) := by
  have sum_bound : ‖∑ j ∈ Finset.range N, z ^ j‖ * ‖z - 1‖ ≤ 2 := by
    rw [← norm_mul, geom_sum_mul]
    calc ‖z ^ N - 1‖ ≤ ‖z ^ N‖ + ‖(1 : ℂ)‖ := norm_sub_le ..
         _ = 2 := by norm_num [norm_pow, unit]
  have prod_le := (mul_le_mul_of_nonneg_left separated (norm_nonneg _)).trans sum_bound
  have npos : 0 < (N : ℝ) := by exact_mod_cast Nat.pos_of_ne_zero (NeZero.ne N)
  rw [kernel, norm_div, Complex.norm_natCast]
  apply (div_le_div_iff₀ npos (mul_pos npos positive)).mpr
  nlinarith [mul_le_mul_of_nonneg_left prod_le npos.le]

variable {g e : ℕ} (S : SpectralData g e)

/-- Unnormalized excited amplitudes in the selected measurement branch. The ground
amplitudes retain their values because the Fourier gain at zero energy is one. -/
def excitedBranch (N : ℕ) (τ : ℝ) (i : Fin e) : ℂ := kernel N (phase τ (S.excitation i)) * S.excited i

def leakage (N : ℕ) (τ : ℝ) : ℝ := ∑ i, Complex.normSq (excitedBranch S N τ i)

/-- Squared branch norm, equal to the readout probability for a normalized input. -/
def heralding (N : ℕ) (τ : ℝ) : ℝ := groundMass S + leakage S N τ

/-- Normalized postmeasurement amplitudes, in the supplied ground and excited eigenbasis. -/
def conditionalState (N : ℕ) (τ : ℝ) (i : Fin g ⊕ Fin e) : ℂ :=
  Sum.elim S.ground (excitedBranch S N τ) i / (Real.sqrt (heralding S N τ) : ℂ)

/-- Every postselected amplitude is the actual Fourier kernel times the input
amplitude, with a common normalization. This includes the on-target ground sector. -/
theorem conditional_amplitudes (N : ℕ) [NeZero N] (τ : ℝ) (i : Fin g ⊕ Fin e) :
    conditionalState S N τ i =
      kernel N (phase τ (Sum.elim (fun _ ↦ 0) S.excitation i)) *
        Sum.elim S.ground S.excited i / (Real.sqrt (heralding S N τ) : ℂ) := by
  cases i with
  | inl i => simp [conditionalState, phase, kernel_at_target]
  | inr i => rfl

/-- Ground-eigenspace population of the normalized postmeasurement state. -/
def conditionalFidelity (N : ℕ) (τ : ℝ) : ℝ := ∑ i, Complex.normSq (conditionalState S N τ (.inl i))

private theorem leakage_nonneg (N : ℕ) (τ : ℝ) : 0 ≤ leakage S N τ :=
  Finset.sum_nonneg fun _ _ ↦ Complex.normSq_nonneg _

private theorem heralding_pos (N : ℕ) (τ : ℝ) : 0 < heralding S N τ :=
  add_pos_of_pos_of_nonneg S.overlap_pos (leakage_nonneg S N τ)

private theorem branchWeight (N : ℕ) (τ : ℝ) (i : Fin g ⊕ Fin e) :
    Complex.normSq (conditionalState S N τ i) =
      Complex.normSq (Sum.elim S.ground (excitedBranch S N τ) i) / heralding S N τ := by
  simp [conditionalState, Complex.normSq_ofReal, Real.mul_self_sqrt (heralding_pos S N τ).le]

theorem branch_normalized (N : ℕ) (τ : ℝ) :
    (∑ i : Fin g ⊕ Fin e, Complex.normSq (conditionalState S N τ i)) = 1 := by
  simp_rw [branchWeight]
  simp only [div_eq_mul_inv, ← Finset.sum_mul, Fintype.sum_sum_type]
  exact div_self (heralding_pos S N τ).ne'

theorem fidelity_eq (N : ℕ) (τ : ℝ) :
    conditionalFidelity S N τ = groundMass S / heralding S N τ := by
  simp only [conditionalFidelity, branchWeight, Sum.elim_inl, div_eq_mul_inv, ← Finset.sum_mul, groundMass]

/-- For unit-norm input, the squared norm of the heralding branch is in (0, 1]. -/
theorem heralding_probability (N : ℕ) [NeZero N] (τ : ℝ)
    (normalized : groundMass S + (∑ i, Complex.normSq (S.excited i)) = 1) :
    0 < heralding S N τ ∧ heralding S N τ ≤ 1 := by
  refine ⟨heralding_pos S N τ, ?_⟩
  rw [← normalized, heralding]
  apply add_le_add_right
  apply Finset.sum_le_sum
  intro i _
  rw [excitedBranch, map_mul]
  have bound := kernel_norm_le_one N (Complex.norm_exp_ofReal_mul_I (-(τ * S.excitation i)))
  apply mul_le_of_le_one_left (Complex.normSq_nonneg _)
  rw [Complex.normSq_eq_norm_sq]
  change ‖kernel N (Complex.exp ((-(τ * S.excitation i) : ℝ) * Complex.I))‖ ^ 2 ≤ 1
  simpa using pow_le_pow_left₀ (norm_nonneg _) bound 2

/-- If each excited phase is a distinct-from-target Nth root of unity, zero-bin
postselection deletes every excited amplitude. For normalized input, the heralding
probability is exactly the initial ground overlap and conditional fidelity is one. -/
theorem exact_grid_preparation (N : ℕ) [NeZero N] (τ : ℝ)
    (grid : ∀ i, (phase τ (S.excitation i)) ^ N = 1)
    (noAlias : ∀ i, phase τ (S.excitation i) ≠ 1) :
    heralding S N τ = groundMass S ∧ conditionalFidelity S N τ = 1 ∧
    ∀ i, conditionalState S N τ (.inr i) = 0 := by
  have removed i : excitedBranch S N τ i = 0 := by
    simp [excitedBranch, kernel_at_distinct_grid_phase (grid i) (noAlias i)]
  have prob : heralding S N τ = groundMass S := by simp [heralding, leakage, removed]
  exact ⟨prob, by rw [fidelity_eq, prob]; exact div_self S.overlap_pos.ne',
    fun i ↦ by simp [conditionalState, removed]⟩

/-- Finite-resolution preparation needs only a chord separation δ between every
excited phase and the target. For normalized input with ground population a, false
heralding weight is at most (1−a)(2/(Nδ))². The target component is transmitted
exactly, giving the stated conditional fidelity bound even for off-grid excitations. -/
theorem separated_preparation (N : ℕ) [NeZero N] (τ : ℝ) {δ : ℝ} (positive : 0 < δ)
    (separated : ∀ i, δ ≤ ‖phase τ (S.excitation i) - 1‖)
    (normalized : groundMass S + (∑ i, Complex.normSq (S.excited i)) = 1) :
    groundMass S ≤ heralding S N τ ∧
    heralding S N τ ≤ groundMass S + (1 - groundMass S) * (2 / (N * δ)) ^ 2 ∧
    groundMass S / (groundMass S + (1 - groundMass S) * (2 / (N * δ)) ^ 2) ≤
      conditionalFidelity S N τ := by
  have excited : ∑ i, Complex.normSq (S.excited i) = 1 - groundMass S := by linarith
  have leak : leakage S N τ ≤ (1 - groundMass S) * (2 / (N * δ)) ^ 2 := by
    rw [← excited, Finset.sum_mul]
    apply Finset.sum_le_sum
    intro i _
    have unit : ‖phase τ (S.excitation i)‖ = 1 := Complex.norm_exp_ofReal_mul_I _
    have bound := kernel_suppression N unit positive (separated i)
    rw [excitedBranch, map_mul, mul_comm]
    apply mul_le_mul_of_nonneg_left _ (Complex.normSq_nonneg _)
    rw [Complex.normSq_eq_norm_sq]
    exact pow_le_pow_left₀ (norm_nonneg _) bound 2
  have upper := add_le_add_right leak (groundMass S)
  refine ⟨le_add_of_nonneg_right (leakage_nonneg S N τ), ?_, ?_⟩
  · simpa [heralding, add_comm] using upper
  · rw [fidelity_eq]
    exact div_le_div_of_nonneg_left S.overlap_pos.le (heralding_pos S N τ)
      (add_le_add_right leak (groundMass S))

end FormalQChem.StatePrep.ImaginaryTimeProjection.PhaseEstimationFilter
