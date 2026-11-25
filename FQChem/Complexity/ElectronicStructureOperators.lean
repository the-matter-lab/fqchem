module

public import FQChem.Complexity.ElectronicStructure
public import Mathlib.LinearAlgebra.Matrix.Hermitian
import Mathlib.Tactic

/-!
# Fermionic generators, resource bounds and variational decision thresholds

The ordered two-mode Fock matrices implement the encoded spin generators.
Real Pauli coefficients and one on-site penalty per spin suffice. Matrix and
variational interfaces use arbitrary normalized complex amplitudes.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.ElectronicStructure
open scoped ComplexConjugate
variable {n m : ℕ}

/-- Annihilation in lexicographic pair order. Removing the second fermion from
a doubly occupied pair incurs the canonical minus sign. -/
def annihilate : Bool → Matrix Rail Rail ℂ
  | false => fun out inp => match out, inp with
    | .empty, .single false | .single true, .double => 1 | _, _ => 0
  | true => fun out inp => match out, inp with
    | .empty, .single true => 1 | .single false, .double => -1 | _, _ => 0

def oneBody (i j : Bool) := (annihilate i).conjTranspose * annihilate j

private theorem oneBody_apply (i j : Bool) (out inp : Rail) : oneBody i j out inp =
    ∑ k : Rail, conj (annihilate i k out) * annihilate j k inp := rfl

def railMatrix (p : Pauli) : Matrix Rail Rail ℂ :=
  fun x y => if y = p.railMove x then p.railPhase x else 0

private theorem sum_rail (f : Rail → ℂ) : ∑ x, f x =
    f .empty + f (.single true) + f (.single false) + f .double := by
  rw [← Equiv.sum_comp Rail.bits.symm f, Fintype.sum_prod_type]
  simp [Rail.bits]
  ring

/-- The occupation-basis encoding of each Pauli generator is the identity or
a sum of two number-conserving one-body monomials. -/
theorem railMatrix_secondQuantized (p : Pauli) :
    railMatrix p = match p with
      | .I => 1
      | .X => oneBody false true + oneBody true false
      | .Y => (-Complex.I) • oneBody false true + Complex.I • oneBody true false
      | .Z => oneBody false false - oneBody true true := by
  ext i j
  cases i <;> cases j <;> cases p <;> repeat' first | rename_i b; cases b
  all_goals norm_num [railMatrix, Pauli.railMove, Pauli.railPhase, Pauli.phase, Pauli.move,
    oneBody_apply, sum_rail, annihilate, Matrix.one_apply]

/-- The local penalty is diagonal and equals (n₀+n₁−1)². -/
theorem numberPenalty :
    Matrix.diagonal (fun x : Rail => if x = .single x.bit then (0 : ℂ) else 1) =
      (oneBody false false + oneBody true true - 1)^2 := by
  let shifted (x : Rail) : ℂ := (x.count : ℂ) - 1
  have diagonal : oneBody false false + oneBody true true - 1 = Matrix.diagonal shifted := by
    ext i j
    simp only [Matrix.sub_apply, Matrix.add_apply, oneBody_apply, sum_rail, Matrix.one_apply,
      Matrix.diagonal_apply]
    rcases i with _ | (_ | _) | _ <;> dsimp [annihilate] <;>
      rcases j with _ | (_ | _) | _ <;>
      norm_num [shifted, Rail.count]
  rw [diagonal, Matrix.diagonal_pow]
  congr 1
  funext x
  cases x <;> norm_num [shifted, Rail.count, Rail.bit]

def support (w : Word n) : Finset (Fin n) := Finset.univ.filter (fun i => w i ≠ .I)

def activeModes (w : Word n) := (support w) ×ˢ (Finset.univ : Finset Bool)

/-- A k-site spin term uses at most 2k fermion modes. The complete register
uses exactly 2n modes. The penalty strength can be bounded linearly in the
number of terms and in the maximum absolute input coefficient. -/
theorem encodingResources (c : Fin m → ℝ) (w : Fin m → Word n) (k : ℕ) (B : ℝ)
    (hk : ∀ j, (support (w j)).card ≤ k) (hc : ∀ j, |c j| ≤ B) :
    Fintype.card (Fin n × Bool) = 2*n ∧ (∀ j, (activeModes (w j)).card ≤ 2*k) ∧
    strength c ≤ m*B := by
  refine ⟨by simp [Nat.mul_comm], fun j => ?_, ?_⟩
  · simpa [activeModes, Nat.mul_comm] using Nat.mul_le_mul_left 2 (hk j)
  · simpa [strength] using Finset.sum_le_sum (s := Finset.univ) (fun j _ => hc j)

def kernelSum {α : Type*} [DecidableEq α] (c : Fin m → ℝ) (e : Fin m → Equiv.Perm α)
    (z : Fin m → α → ℂ) : Matrix α α ℂ :=
  fun x y => ∑ j, (c j : ℂ) * (if y = e j x then z j x else 0)

def spinKernel (c : Fin m → ℝ) (w : Fin m → Word n) : Matrix (Spin n) (Spin n) ℂ :=
  kernelSum c (fun j => logicalMove (w j)) (fun j => logicalPhase (w j))

def matrixExpectation {α : Type*} [Fintype α] (H : Matrix α α ℂ) (ψ : α → ℂ) : ℝ :=
  (∑ x, conj (ψ x) * H.mulVec ψ x).re

private theorem kernelSum_expectation {α : Type*} [Fintype α] [DecidableEq α]
    (c : Fin m → ℝ) (e : Fin m → Equiv.Perm α) (z : Fin m → α → ℂ) (ψ : α → ℂ) :
    matrixExpectation (kernelSum c e z) ψ = ∑ j, c j * expectation (e j) (z j) ψ := by
  classical
  have action (x) : (kernelSum c e z).mulVec ψ x =
      ∑ j, (c j : ℂ) * z j x * ψ (e j x) := by
    unfold kernelSum Matrix.mulVec dotProduct
    simp_rw [Finset.sum_mul]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro j _
    simp [mul_ite, ite_mul]
  rw [matrixExpectation, Complex.re_sum]
  simp_rw [action, Finset.mul_sum, Complex.re_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j _
  rw [expectation, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x _
  rw [show conj (ψ x) * (↑(c j) * z j x * ψ (e j x)) =
    ↑(c j) * (conj (ψ x) * z j x * ψ (e j x)) by ring]
  simp only [Complex.mul_re, Complex.ofReal_re, Complex.ofReal_im, zero_mul, sub_zero]

theorem spinKernel_expectation (c : Fin m → ℝ) (w : Fin m → Word n) (ψ : Spin n → ℂ) :
    matrixExpectation (spinKernel c w) ψ = spinEnergy c w ψ := kernelSum_expectation _ _ _ _

def fermionKernel (c : Fin m → ℝ) (w : Fin m → Word n) (J : ℝ) :
    Matrix (Occupation n) (Occupation n) ℂ :=
  kernelSum c (fun j => physicalMove (w j)) (fun j => physicalPhase (w j)) +
    Matrix.diagonal (fun x => ((J * defects x : ℝ) : ℂ))

private theorem railPhase_reverse (p : Pauli) (r : Rail) :
    conj (p.railPhase (p.railMove r)) = p.railPhase r := by
  cases r with
  | single b => cases p <;> cases b <;> simp [Pauli.railPhase, Pauli.railMove, Pauli.phase, Pauli.move]
  | _ => cases p <;> simp [Pauli.railPhase, Pauli.railMove]

/-- The constructed fixed-particle matrix is Hermitian for all real
coefficients and every real penalty strength. -/
theorem fermionKernel_hermitian (c : Fin m → ℝ) (w : Fin m → Word n) (J : ℝ) :
    (fermionKernel c w J).IsHermitian := by
  refine Matrix.IsHermitian.add ?_ (Matrix.isHermitian_diagonal_of_self_adjoint _ ?_)
  · ext x y
    change conj (∑ j, (c j : ℂ) * (if x = physicalMove (w j) y then physicalPhase (w j) y else 0)) =
      ∑ j, (c j : ℂ) * (if y = physicalMove (w j) x then physicalPhase (w j) x else 0)
    rw [map_sum]
    apply Finset.sum_congr rfl
    intro j _
    have H (v : Occupation n) : physicalMove (w j) (physicalMove (w j) v) = v := (physicalMove _).left_inv _
    by_cases hy : y = physicalMove (w j) x
    · subst y
      simp only [H, ↓reduceIte, map_mul, Complex.conj_ofReal, physicalPhase, map_prod]
      congr 1
      exact Finset.prod_congr rfl fun i _ => railPhase_reverse _ _
    · have hx : x ≠ physicalMove (w j) y := fun h => hy (by rw [h, H])
      simp [hx, hy]
  · ext x
    exact Complex.conj_ofReal _

theorem fermionKernel_expectation (c : Fin m → ℝ) (w : Fin m → Word n) (J : ℝ)
    (ψ : Occupation n → ℂ) : matrixExpectation (fermionKernel c w J) ψ = fermionEnergy c w J ψ := by
  unfold fermionKernel matrixExpectation
  simp only [Matrix.add_mulVec, Pi.add_apply, mul_add, Finset.sum_add_distrib, Complex.add_re]
  rw [fermionEnergy, interactionEnergy, ← kernelSum_expectation c (fun j => physicalMove (w j)) (fun j => physicalPhase (w j)) ψ]
  congr 1
  simp only [Matrix.mulVec_diagonal, penaltyEnergy, Complex.re_sum, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x _
  rw [show conj (ψ x) * (↑(J * (defects x : ℝ)) * ψ x) =
    ↑(J * (defects x : ℝ)) * (ψ x * conj (ψ x)) by ring, Complex.mul_conj, ← Complex.ofReal_mul]
  rw [Complex.ofReal_re, Complex.normSq_eq_norm_sq, mul_assoc]

/-- Hilbert-space operator used by the Rayleigh–Ritz and VQE statements. -/
def fermionOperator (c : Fin m → ℝ) (w : Fin m → Word n) (J : ℝ) :=
  (fermionKernel c w J).toEuclideanLin.toContinuousLinearMap

theorem fermionExpectation (c : Fin m → ℝ) (w : Fin m → Word n) (J : ℝ)
    (ψ : EuclideanSpace ℂ (Occupation n)) :
    (fermionOperator c w J).reApplyInnerSelf ψ = fermionEnergy c w J ψ := by
  rw [← fermionKernel_expectation, ContinuousLinearMap.reApplyInnerSelf_apply]
  rw [inner_re_symm]
  apply congrArg Complex.re
  simp only [PiLp.inner_apply, RCLike.inner_apply]
  apply Finset.sum_congr rfl
  intro x _
  exact mul_comm _ _

/-- The existing Rayleigh–Ritz VQE bound applies to the actual encoded
fixed-particle operator and to every prepared parameter value. -/
theorem variationalUpperBound {Θ : Type*} (c : Fin m → ℝ) (w : Fin m → Word n) (J : ℝ)
    (U : Θ → EuclideanSpace ℂ (Occupation n) ≃ₗᵢ[ℂ] EuclideanSpace ℂ (Occupation n))
    (ref : EuclideanSpace ℂ (Occupation n)) (hr : ‖ref‖ = 1) (θ : Θ) :
    FQChem.RayleighRitz.groundEnergy (fermionOperator c w J) ≤ fermionEnergy c w J (U θ ref) := by
  rw [← fermionExpectation]
  exact (FQChem.VariationalMethods.vqe _ U ref hr θ).1

/-- A uniform energy error below half the promise gap decides the original
spin instance using a threshold on the estimated fixed-particle energy.
The NO case permits every normalized variational state. -/
theorem variationalThreshold (c : Fin m → ℝ) (w : Fin m → Word n) (J a b ε δ : ℝ)
    (hJ : 0 ≤ J) (hsep : b + strength c ≤ J) (accuracy : ε + 2*δ < b-a)
    (trial : Occupation n → ℂ) (normTrial : mass trial = 1) (report : ℝ)
    (readout : |report - fermionEnergy c w J trial| ≤ δ)
    (prepare : ∀ φ, mass φ = 1 → fermionEnergy c w J trial ≤ fermionEnergy c w J φ + ε) :
    ((∃ ψ, mass ψ = 1 ∧ matrixExpectation (spinKernel c w) ψ ≤ a) → report < b-δ) ∧
    ((∀ ψ, mass ψ = 1 → b ≤ matrixExpectation (spinKernel c w) ψ) → b-δ ≤ report) := by
  simp only [spinKernel_expectation]
  have hp := energyPromise_transfer c w J a b hJ hsep
  constructor
  · intro yes
    obtain ⟨φ, hm, he⟩ := hp.1 yes
    linarith [prepare φ hm, (abs_le.mp readout).2]
  · intro no
    linarith [hp.2 no trial normTrial, (abs_le.mp readout).1]

end FQChem.Complexity.ElectronicStructure
