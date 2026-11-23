module

public import FormalQChem.StatePrep.ImaginaryTimeProjection.AFQMC
public import FormalQChem.Dynamics.DigitalAlgorithms.LieTrotter
public import Mathlib.Analysis.Normed.Algebra.MatrixExponential
public import Mathlib.Analysis.Matrix.Normed
import Mathlib.Tactic

/-!
# Zero-time-step limit of the repulsive Hubbard field sum

On a finite lattice, the exact expectation over all discrete Hirsch field histories
converges to the unsplit propagator at fixed total imaginary time. The kinetic
matrix acts on the full occupation space and can mix different configurations.
The site factors include the uniform field probabilities. The limit concerns this
exact expectation, before finite sampling or a constraint on walkers.

* [Hirsch, Discrete Hubbard–Stratonovich transformation (1983)](https://doi.org/10.1103/PhysRevB.28.4059)
* [Sugiyama & Koonin, Auxiliary field Monte-Carlo for quantum many-body ground states (1986)](https://doi.org/10.1016/0003-4916(86)90107-7)
* [Trotter, On the product of semi-groups of operators (1959)](https://doi.org/10.1090/S0002-9939-1959-0108732-6)
-/

@[expose] public section
noncomputable section

namespace FormalQChem.StatePrep.ImaginaryTimeProjection.AFQMC

open Filter NormedSpace
open scoped Topology Matrix.Norms.Operator

abbrev HubbardMatrix (sites : ℕ) := Matrix (OccupationConfig sites) (OccupationConfig sites) ℂ

/-- Interaction energy of one occupation configuration in the particle–hole symmetric convention. -/
def interactionEnergy {sites : ℕ} (U : ℝ) (c : OccupationConfig sites) : ℝ :=
  U * ∑ i, (occupation (c.1 i) - 1/2) * (occupation (c.2 i) - 1/2)

/-- The diagonal on-site Hubbard Hamiltonian in the full spin-occupation basis. -/
def interactionHamiltonian (sites : ℕ) (U : ℝ) : HubbardMatrix sites :=
  Matrix.diagonal fun c => (interactionEnergy U c : ℂ)

/-- The product of local Hubbard factors is the matrix exponential for one interaction slice. -/
theorem interactionStep_eq_exp {sites : ℕ} (h U : ℝ) :
    interactionStep (sites := sites) (h * U) = exp ((-h) • interactionHamiltonian sites U) := by
  rw [interactionStep, interactionHamiltonian, ← Matrix.diagonal_smul, Matrix.exp_diagonal]
  congr 1
  funext c
  simp only [hubbardFactor]
  rw [Pi.coe_exp, Pi.smul_apply, ← Complex.exp_eq_exp_ℂ, ← Real.exp_sum]
  rw [Complex.ofReal_exp]
  congr 1
  rw [interactionEnergy, Complex.real_smul, ← Complex.ofReal_mul]
  norm_cast
  rw [← mul_assoc, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- Exact field-history expectation for `m` slices of width `β / m`. The factors
of one half for choosing each field are already part of `fieldStep`. -/
def hirschHistoryMean {sites : ℕ} (K : HubbardMatrix sites) (β U : ℝ) (m : ℕ) :
    HubbardMatrix sites :=
  let h := β / m
  let x := h * U
  let γ := Real.arcosh (Real.exp (x / 2))
  ∑ path : Fin m → Fin sites → Bool,
    historyProduct (fun field => exp ((-h) • K) * fieldStep x γ field) m path

/-- At each finite slice count the field expectation equals the kinetic/interaction splitting. -/
theorem hirschHistoryMean_eq_split {sites : ℕ} (K : HubbardMatrix sites) {β U : ℝ}
    (hβ : 0 ≤ β) (hU : 0 ≤ U) (m : ℕ) :
    hirschHistoryMean K β U m =
      (exp ((-(β / m)) • K) * exp ((-(β / m)) • interactionHamiltonian sites U)) ^ m := by
  rw [← interactionStep_eq_exp]
  exact (hubbardFreeProjection (Real.cosh_arcosh (Real.one_le_exp (by positivity))) _ _).symm

/-- At fixed `β ≥ 0` and repulsive `U ≥ 0`, the field-history expectation
converges in matrix norm to the exponential of the unsplit Hubbard Hamiltonian. -/
theorem hirschHistoryMean_tendsto {sites : ℕ} (K : HubbardMatrix sites) {β U : ℝ}
    (hβ : 0 ≤ β) (hU : 0 ≤ U) :
    Tendsto (hirschHistoryMean K β U) atTop
      (𝓝 (exp ((-β) • (K + interactionHamiltonian sites U)))) := by
  have limit := Dynamics.lieTrotter ((-β) • K) ((-β) • interactionHamiltonian sites U)
  unfold Dynamics.LieTrotter at limit
  rw [← smul_add] at limit
  refine limit.congr fun m => ?_
  have scalar : (m : ℝ)⁻¹ * (-β) = -(β / m) := by
    rw [div_eq_mul_inv]
    ring
  simp only [hirschHistoryMean_eq_split K hβ hU, smul_smul, scalar]
  rfl

/-- The exact field projection converges on every initial state. -/
theorem hirschHistoryMean_mulVec_tendsto {sites : ℕ} (K : HubbardMatrix sites) {β U : ℝ}
    (hβ : 0 ≤ β) (hU : 0 ≤ U) (ψ : OccupationConfig sites → ℂ) :
    Tendsto (fun m => (hirschHistoryMean K β U m).mulVec ψ) atTop
      (𝓝 ((exp ((-β) • (K + interactionHamiltonian sites U))).mulVec ψ)) :=
  (continuous_id.matrix_mulVec (continuous_const (y := ψ))).continuousAt.tendsto.comp
    (hirschHistoryMean_tendsto K hβ hU)

end FormalQChem.StatePrep.ImaginaryTimeProjection.AFQMC
