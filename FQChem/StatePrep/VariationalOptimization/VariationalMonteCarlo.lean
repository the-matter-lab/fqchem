module

public import FQChem.StatePrep.VariationalOptimization.RayleighRitz
public import Mathlib.Analysis.InnerProductSpace.PiL2
public import Mathlib.LinearAlgebra.Matrix.Symmetric
public import Mathlib.Basic.Real.Basic
public import Mathlib.Analysis.Calculus.Deriv.Inv
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic

/-!
# Variational Monte Carlo in a finite configuration basis

Born sampling gives the Rayleigh quotient of the trial vector. The local-energy
variance samples the residual on its support. An explicit nodal term completes
the squared residual norm. A symmetric Metropolis proposal preserves the Born law,
and differentiating a full-support real ansatz gives the energy covariance gradient.

[McMillan (1965)](https://doi.org/10.1103/PhysRev.138.A442),
[Assaraf and Caffarel (2003)](https://arxiv.org/abs/physics/0310035),
[Metropolis et al. (1953)](https://doi.org/10.1063/1.1699114),
[Sorella (2005)](https://arxiv.org/abs/cond-mat/0502553).
-/

@[expose] public section
noncomputable section

namespace FQChem.Algorithms

/-- Finite-configuration variational Monte Carlo. Born-probability averaging of the
local energy gives the Rayleigh quotient, including configurations where the trial state vanishes. -/
def VariationalMonteCarlo (n : ℕ) : Prop :=
  ∀ (H : Matrix (Fin n) (Fin n) ℝ) (ψ : Fin n → ℝ), H.IsSymm → ψ ≠ 0 →
    (∑ i, ψ i ^ 2 * ((H.mulVec ψ) i / ψ i)) / (∑ i, ψ i ^ 2) =
      (∑ i, ψ i * (H.mulVec ψ) i) / (∑ i, ψ i ^ 2)

theorem variationalMonteCarlo (n : ℕ) : VariationalMonteCarlo n := by
  intro H ψ _ _
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  by_cases h : ψ i = 0
  · simp [h]
  · field_simp

end FQChem.Algorithms

namespace FQChem.StatePrep.VariationalOptimization.VariationalMonteCarlo

open FQChem.RayleighRitz
open scoped ComplexConjugate

variable {ι E : Type*} [Fintype ι] [NormedAddCommGroup E] [InnerProductSpace ℂ E]
variable (b : OrthonormalBasis ι ℂ E) (H : E →L[ℂ] E) (ψ : E)

/-- For a normalized trial vector these weights are its Born distribution in the sampling basis. -/
def weight (i : ι) : ℝ := ‖inner ℂ (b i) ψ‖ ^ 2

theorem sum_weight (unit : ‖ψ‖ = 1) : ∑ i, weight b ψ i = 1 := by
  simpa [weight, unit] using b.sum_sq_norm_inner_right ψ

/-- The local-energy ratio may take any value at a node without affecting a Born average. -/
def localEnergy (i : ι) : ℂ := inner ℂ (b i) (H ψ) / inner ℂ (b i) ψ

theorem bornMean : ∑ i, (weight b ψ i : ℂ) * localEnergy b H ψ i = inner ℂ ψ (H ψ) := by
  rw [← b.sum_inner_mul_inner ψ (H ψ)]
  apply Finset.sum_congr rfl
  intro i _
  have conjugate : conj (inner ℂ (b i) ψ) = inner ℂ ψ (b i) := inner_conj_symm ..
  rw [weight, localEnergy, Complex.ofReal_pow, ← Complex.conj_mul', ← conjugate]
  by_cases h : inner ℂ (b i) ψ = 0
  · simp [h]
  · field_simp

/-- The population VMC energy upper-bounds the lowest Hermitian eigenvalue. -/
theorem variationalBound [FiniteDimensional ℂ E] [Nontrivial E]
    (hermitian : H.toLinearMap.IsSymmetric) (unit : ‖ψ‖ = 1) :
    Module.End.HasEigenvalue H.toLinearMap (groundEnergy H : ℂ) ∧
    groundEnergy H ≤ (∑ i, (weight b ψ i : ℂ) * localEnergy b H ψ i).re := by
  have hψ : ψ ≠ 0 := fun h ↦ by simp [h] at unit
  obtain ⟨eigen, bound⟩ := groundEnergyPrinciple H hermitian
  rw [bornMean]
  refine ⟨eigen, ?_⟩
  simpa [ContinuousLinearMap.rayleighQuotient, ContinuousLinearMap.reApplyInnerSelf_apply,
    unit, inner_re_symm (𝕜 := ℂ) (H ψ) ψ] using bound ψ hψ

/-- Born-weighted squared deviation. At the mean energy of a normalized Hermitian
trial calculation this is the variance of its complex local energy. -/
def centeredMoment (energy : ℝ) : ℝ :=
  ∑ i, weight b ψ i * ‖localEnergy b H ψ i - (energy : ℂ)‖ ^ 2

/-- The squared eigenvector residual splits into the sampled fluctuation and the
part supported on configurations of zero Born weight. -/
theorem residualDecomposition (energy : ℝ) :
    ‖H ψ - (energy : ℂ) • ψ‖ ^ 2 = centeredMoment b H ψ energy +
      ∑ i, if inner ℂ (b i) ψ = 0 then ‖inner ℂ (b i) (H ψ)‖ ^ 2 else 0 := by
  rw [← b.sum_sq_norm_inner_right (H ψ - (energy : ℂ) • ψ), centeredMoment, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  rw [inner_sub_right, inner_smul_right, weight, localEnergy]
  by_cases h : inner ℂ (b i) ψ = 0
  · simp [h]
  · rw [ite_eq_right h, add_zero, ← mul_pow, ← norm_mul]
    congr 2
    field_simp

/-- Zero sampled variance characterizes an eigenstate if Hψ also vanishes at every
node of ψ. Full support is a sufficient special case. -/
theorem zeroVarianceIff (energy : ℝ)
    (nodes : ∀ i, inner ℂ (b i) ψ = 0 → inner ℂ (b i) (H ψ) = 0) :
    centeredMoment b H ψ energy = 0 ↔ H ψ = (energy : ℂ) • ψ := by
  have residual := residualDecomposition b H ψ energy
  have vanish (i : ι) : (if inner ℂ (b i) ψ = 0 then ‖inner ℂ (b i) (H ψ)‖ ^ 2 else 0) = 0 := by
    split_ifs with h
    · simp [nodes i h]
    · rfl
  simp only [vanish, Finset.sum_const_zero, add_zero] at residual
  rw [← residual]
  simp [sub_eq_zero]

/-- Every exact eigenstate has zero local-energy variance, including states with nodes. -/
theorem eigenstateZeroVariance (energy : ℝ) (eig : H ψ = (energy : ℂ) • ψ) :
    centeredMoment b H ψ energy = 0 := by
  apply (zeroVarianceIff b H ψ energy ?_).mpr eig
  intro i hi
  rw [eig, inner_smul_right, hi, mul_zero]

section Sampling

variable {X : Type*} [Fintype X] [DecidableEq X]
variable (p : X → ℝ) (q : X → X → ℝ)

/-- Off-diagonal Metropolis transition with a symmetric proposal q. -/
def move (x y : X) : ℝ := if x = y then 0 else q x y * min 1 (p y / p x)

/-- Rejected proposals and self-proposals leave the walker at x. -/
def metropolis (x y : X) : ℝ :=
  move p q x y + if x = y then 1 - ∑ z, move p q x z else 0

private theorem acceptedFlow {a b : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b) :
    a * min 1 (b / a) = min a b := by
  by_cases h : a = 0
  · simp [h, min_eq_left hb]
  · rw [mul_min_of_nonneg _ _ ha, mul_one, mul_div_cancel₀ _ h]

theorem detailedBalance (hp : ∀ x, 0 ≤ p x) (symm : ∀ x y, q x y = q y x) (x y : X) :
    p x * metropolis p q x y = p y * metropolis p q y x := by
  by_cases h : x = y
  · subst y; rfl
  · simp only [metropolis, move, ite_eq_right h, ite_eq_right (Ne.symm h), add_zero]
    rw [mul_left_comm, acceptedFlow (hp x) (hp y), mul_left_comm (p y),
      acceptedFlow (hp y) (hp x), min_comm, symm x y]

theorem rowSum (x : X) : ∑ y, metropolis p q x y = 1 := by
  simp [metropolis, Finset.sum_add_distrib]

/-- A normalized nonnegative proposal gives a stochastic transition kernel even when
the trial state has nodes. Stationarity alone permits reducible chains. -/
theorem transitionNonnegative (hp : ∀ x, 0 ≤ p x) (hq : ∀ x y, 0 ≤ q x y)
    (stochastic : ∀ x, ∑ y, q x y = 1) (x y : X) : 0 ≤ metropolis p q x y := by
  have nonneg (j : X) : 0 ≤ move p q x j := by
    unfold move
    split_ifs
    · exact le_rfl
    · exact mul_nonneg (hq _ _) (le_min zero_le_one (div_nonneg (hp _) (hp _)))
  have total : ∑ j, move p q x j ≤ 1 := by
    rw [← stochastic x]
    apply Finset.sum_le_sum
    intro j _
    unfold move
    split_ifs
    · exact hq _ _
    · exact mul_le_of_le_one_right (hq _ _) (min_le_left ..)
  apply add_nonneg (nonneg y)
  split_ifs
  · exact sub_nonneg.mpr total
  · exact le_rfl

theorem stationary (hp : ∀ x, 0 ≤ p x) (symm : ∀ x y, q x y = q y x) (y : X) :
    ∑ x, p x * metropolis p q x y = p y := by
  simp_rw [detailedBalance p q hp symm _ y]
  rw [← Finset.mul_sum, rowSum, mul_one]

/-- Sampling from the Born law and making a Metropolis step preserves that law. -/
theorem bornStationary [DecidableEq ι] (proposal : ι → ι → ℝ)
    (nonneg : ∀ i j, 0 ≤ proposal i j) (rows : ∀ i, ∑ j, proposal i j = 1)
    (symmetric : ∀ i j, proposal i j = proposal j i) (unit : ‖ψ‖ = 1) :
    (∑ i, weight b ψ i) = 1 ∧
    (∀ i j, 0 ≤ metropolis (weight b ψ) proposal i j) ∧
    (∀ i, ∑ j, metropolis (weight b ψ) proposal i j = 1) ∧
    ∀ j, ∑ i, weight b ψ i * metropolis (weight b ψ) proposal i j = weight b ψ j :=
  ⟨sum_weight b ψ unit, transitionNonnegative _ _ (fun _ ↦ sq_nonneg _) nonneg rows,
    rowSum _ _, stationary _ _ (fun _ ↦ sq_nonneg _) symmetric⟩

end Sampling

section Optimization

open Matrix

variable {X : Type*} [Fintype X]

def energy (H : Matrix X X ℝ) (f : X → ℝ) := (f ⬝ᵥ (H *ᵥ f)) / (f ⬝ᵥ f)

/-- The parameter derivative of the variational energy equals twice the Born
covariance of local energy and logarithmic derivative. The real trial amplitudes
have full support at the evaluation point and may be unnormalized. -/
theorem energyGradient (H : Matrix X X ℝ) (symmetric : H.IsSymm) (f : ℝ → X → ℝ)
    (derivative : X → ℝ) (t : ℝ) (smooth : ∀ i, HasDerivAt (fun s ↦ f s i) (derivative i) t)
    (support : ∀ i, f t i ≠ 0) (mass : f t ⬝ᵥ f t ≠ 0) :
    HasDerivAt (fun s ↦ energy H (f s))
      (2 * ∑ i, (f t i ^ 2 / (f t ⬝ᵥ f t)) *
        (((H *ᵥ f t) i / f t i) - energy H (f t)) * (derivative i / f t i)) t := by
  have applied (i : X) : HasDerivAt (fun s ↦ (H *ᵥ f s) i) ((H *ᵥ derivative) i) t :=
    HasDerivAt.fun_sum fun j _ ↦ (smooth j).const_mul (H i j)
  have numerator := HasDerivAt.fun_sum (u := Finset.univ) fun i _ ↦
    (smooth i).fun_mul (applied i)
  have denominator := HasDerivAt.fun_sum (u := Finset.univ) fun i _ ↦
    (smooth i).fun_mul (smooth i)
  have symmetry : f t ⬝ᵥ (H *ᵥ derivative) = derivative ⬝ᵥ (H *ᵥ f t) := by
    rw [Matrix.dotProduct_mulVec, ← Matrix.mulVec_transpose, symmetric, dotProduct_comm]
  rw [Finset.sum_add_distrib] at numerator denominator
  change HasDerivAt (fun s ↦ f s ⬝ᵥ (H *ᵥ f s))
    (derivative ⬝ᵥ (H *ᵥ f t) + f t ⬝ᵥ (H *ᵥ derivative)) t at numerator
  change HasDerivAt (fun s ↦ f s ⬝ᵥ f s) (derivative ⬝ᵥ f t + f t ⬝ᵥ derivative) t at denominator
  rw [symmetry, ← two_mul] at numerator
  rw [dotProduct_comm (f t) derivative, ← two_mul] at denominator
  have term (i : X) :
      (f t i ^ 2 / (f t ⬝ᵥ f t)) * ((H *ᵥ f t) i / f t i - energy H (f t)) *
          (derivative i / f t i) =
      (derivative i * (H *ᵥ f t) i - energy H (f t) * (derivative i * f t i)) / (f t ⬝ᵥ f t) := by
    field_simp [support i, mass]
  convert numerator.fun_div denominator mass using 1
  · rfl
  simp_rw [term]
  rw [← Finset.sum_div, Finset.sum_sub_distrib, ← Finset.mul_sum]
  change 2 * ((derivative ⬝ᵥ (H *ᵥ f t) - energy H (f t) * (derivative ⬝ᵥ f t)) / _) = _
  unfold energy
  field_simp [mass]

end Optimization

end FQChem.StatePrep.VariationalOptimization.VariationalMonteCarlo
