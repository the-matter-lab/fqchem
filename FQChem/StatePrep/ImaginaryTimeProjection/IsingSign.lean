module

public import Mathlib.Analysis.Normed.Algebra.MatrixExponential
public import Mathlib.Analysis.SpecialFunctions.Exponential
import Mathlib.Tactic

/-! # The spin-glass sign-problem construction

Troyer and Wiese, [Phys. Rev. Lett. 94, 170201](https://doi.org/10.1103/PhysRevLett.94.170201),
Eqs. (4), (8), (10)–(11). A two-bit mask labels an undirected Ising bond. In the
computational basis the two-site Pauli X product flips both bits; in the Walsh
basis its eigenvalues are the corresponding products of two classical spins.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
open Matrix
variable {n : ℕ}

abbrev Spin (n : ℕ) := Fin n → Bool
abbrev Operator (n : ℕ) := Matrix (Spin n) (Spin n) ℝ

def pairMask (a b : Fin n) : Spin n := fun i => decide (i=a ∨ i=b)

structure Glass (n : ℕ) where
  bonds : Finset (Spin n)
  twoSite : ∀ e ∈ bonds, ∃ a b : Fin n, a ≠ b ∧ e = pairMask a b
  negative : Spin n → Bool

def Glass.coupling (g : Glass n) (e : Spin n) : ℤ :=
  if e ∈ g.bonds then (if g.negative e then -1 else 1) else 0

def Glass.ferro (g : Glass n) : Glass n := {g with negative := fun _ => false}

theorem ferro_coupling (g : Glass n) (e : Spin n) : (g.ferro.coupling e) = |g.coupling e| := by
  by_cases h : e ∈ g.bonds <;> cases k : g.negative e <;> simp [Glass.ferro, Glass.coupling, h, k]

def exchange (x y : Spin n) : Spin n := fun i => x i ^^ y i

def bitCharacter (a b : Bool) : ℤ := if a && b then -1 else 1

def character (s e : Spin n) : ℤ := ∏ i, bitCharacter (s i) (e i)

theorem abs_character (s e : Spin n) : |character s e| = 1 := by
  have each (a b : Bool) : |bitCharacter a b| = 1 := by cases a <;> cases b <;> decide
  simp [character, Finset.abs_prod, each]

/-- The eigenvalue of the Pauli-X bond (a,b) is exactly the classical spin product. -/
theorem character_pair (s : Spin n) (a b : Fin n) (hne : a ≠ b) :
    character s (pairMask a b) = bitCharacter (s a) true * bitCharacter (s b) true := by
  classical
  let J : Finset (Fin n) := {a,b}
  have trim := Finset.prod_subset (s₁ := J) (s₂ := Finset.univ)
    (f := fun i => bitCharacter (s i) (pairMask a b i)) (Finset.subset_univ _)
    (fun i _ hi => by
      have hn : i ≠ a ∧ i ≠ b := by simpa [J] using hi
      simp [pairMask, bitCharacter, hn.1, hn.2])
  change (∏ i, bitCharacter (s i) (pairMask a b i)) = _
  rw [← trim]
  simp [J, hne, pairMask]

def Glass.energy (g : Glass n) (s : Spin n) : ℤ := -∑ e ∈ g.bonds, g.coupling e * character s e

theorem energy_bound (g : Glass n) (s : Spin n) : |g.energy s| ≤ (g.bonds.card : ℤ) := by
  rw [Glass.energy, abs_neg]
  refine (Finset.abs_sum_le_sum_abs _ _).trans ?_
  have each (e) (he : e ∈ g.bonds) : |g.coupling e * character s e| = 1 := by
    rw [abs_mul, abs_character, mul_one]
    cases c : g.negative e <;> simp [Glass.coupling, he, c]
  rw [Finset.sum_congr rfl each]
  simp

/-- Hx is the sum of two-site X flips with coefficients −Jₑ (energy unit J=1). -/
def Glass.hamiltonian (g : Glass n) : Operator n := Matrix.of fun x y => -(g.coupling (exchange x y) : ℝ)

/-- A product of Pauli X matrices, specified by the mask of the flipped sites. -/
def flipMatrix (e : Spin n) : Operator n := Matrix.of fun x y => if exchange x y = e then 1 else 0

theorem pauliExpansion (g : Glass n) :
    g.hamiltonian = ∑ e ∈ g.bonds, (-(g.coupling e : ℝ)) • flipMatrix e := by
  ext x y
  simp only [Matrix.sum_apply, Matrix.smul_apply, smul_eq_mul, flipMatrix, Matrix.of_apply,
    mul_ite, mul_one, mul_zero]
  by_cases h : exchange x y ∈ g.bonds
  · simp [Glass.hamiltonian, h]
  · simp [Glass.hamiltonian, Glass.coupling, h]

/-- The bosonic comparison kernel is the entrywise absolute value of the expansion kernel −Hx. -/
theorem abs_kernel (g : Glass n) (x y : Spin n) :
    -(g.ferro.hamiltonian x y) = |-(g.hamiltonian x y)| := by
  simp [Glass.hamiltonian, ferro_coupling]

/-- Unscaled series-expansion weight for a path, formed from successive entries of −Hx.
The trace expansion uses closed paths and the common nonnegative factor βᵏ/k!. -/
def pathWeight (g : Glass n) : Spin n → List (Spin n) → ℝ
  | _, [] => 1
  | x, y::ys => -(g.hamiltonian x y) * pathWeight g y ys

theorem absolute_path (g : Glass n) (x : Spin n) (ys : List (Spin n)) :
    pathWeight g.ferro x ys = |pathWeight g x ys| := by
  induction ys generalizing x with
  | nil => simp [pathWeight]
  | cons y ys ih => rw [pathWeight, pathWeight, abs_kernel, ih, abs_mul]

private def integerPath (g : Glass n) : Spin n → List (Spin n) → ℤ
  | _, [] => 1
  | x,y::ys => g.coupling (exchange x y) * integerPath g y ys

private theorem path_cast (g : Glass n) (x : Spin n) (ys : List (Spin n)) :
    pathWeight g x ys = (integerPath g x ys : ℝ) := by
  induction ys generalizing x with
  | nil => simp [pathWeight, integerPath]
  | cons y ys ih => simp [pathWeight, integerPath, Glass.hamiltonian, ih]

/-- One negative bond on a four-spin square closes a four-flip path with negative
weight; the corresponding bosonic path has positive weight. -/
def square : Glass 4 where
  bonds := {pairMask 0 1, pairMask 1 2, pairMask 2 3, pairMask 3 0}
  negative e := decide (e = pairMask 0 1)
  twoSite := by
    intro e he
    simp only [Finset.mem_insert, Finset.mem_singleton] at he
    rcases he with rfl|rfl|rfl|rfl
    · exact ⟨0,1,by decide,rfl⟩
    · exact ⟨1,2,by decide,rfl⟩
    · exact ⟨2,3,by decide,rfl⟩
    · exact ⟨3,0,by decide,rfl⟩

theorem frustratedSquare :
    let z : Spin 4 := fun _ => false
    let path := [pairMask 0 1, pairMask 0 2, pairMask 0 3, z]
    pathWeight square z path = -1 ∧ pathWeight square.ferro z path = 1 := by
  intro z path
  have h : integerPath square z path = -1 := by decide
  rw [absolute_path, path_cast, h]
  norm_num

private theorem character_exchange (s x y : Spin n) :
    character s (exchange x y) = character s x * character s y := by
  have bit (a b c : Bool) : bitCharacter a (b ^^ c) = bitCharacter a b * bitCharacter a c := by
    cases a <;> cases b <;> cases c <;> decide
  simp [character, exchange, bit, Finset.prod_mul_distrib]

def walsh (n : ℕ) : Operator n := Matrix.of fun x s => (character s x : ℝ)

/-- The unnormalized Walsh matrix squared is 2ⁿI. -/
theorem walsh_square (n : ℕ) : walsh n * walsh n = (2:ℝ)^n • (1 : Operator n) := by
  ext x y
  simp only [Matrix.mul_apply, walsh, Matrix.of_apply, character, Int.cast_prod]
  simp_rw [← Finset.prod_mul_distrib]
  rw [← Fintype.prod_sum (fun i t => (bitCharacter t (x i) : ℝ) * (bitCharacter (y i) t : ℝ))]
  have ortho' (a b : Bool) :
      (∑ t : Bool, (bitCharacter t a : ℝ) * (bitCharacter b t : ℝ)) = if a=b then 2 else 0 := by
    cases a <;> cases b <;> norm_num [Fintype.sum_bool, bitCharacter]
  simp only [ortho', Fintype.prod_ite_zero, Finset.prod_const, Finset.card_univ, Fintype.card_fin,
    Matrix.smul_apply, smul_eq_mul, Matrix.one_apply]
  by_cases h : x=y
  · simp [h]
  · simp [h, funext_iff.mpr.mt h]

private def translate (x : Spin n) : Spin n ≃ Spin n :=
  ⟨exchange x,exchange x, fun y => by funext i; simp [exchange],fun y => by funext i; simp [exchange]⟩

/-- Walsh conjugation diagonalizes the actual spin-flip Hamiltonian with the classical
spin-glass energies, including multiplicity. -/
theorem walsh_eigen (g : Glass n) :
    g.hamiltonian * walsh n = walsh n * Matrix.diagonal (fun s => (g.energy s : ℝ)) := by
  ext x s
  rw [Matrix.mul_apply, Matrix.mul_diagonal]
  rw [← Equiv.sum_comp (translate x)]
  simp only [Glass.hamiltonian, walsh, Matrix.of_apply]
  have invol (e : Spin n) : exchange x (translate x e) = e := (translate x).left_inv _
  simp only [invol, show ∀ e, character s (translate x e) = character s x * character s e
    from fun e => character_exchange .., Int.cast_mul]
  have all : ∑ e : Spin n, (g.coupling e : ℝ) * (character s e : ℝ) =
      ∑ e ∈ g.bonds, (g.coupling e : ℝ) * (character s e : ℝ) := by
    apply (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro e _ he
    simp [Glass.coupling, he]
  simp only [Glass.energy, Int.cast_neg, Int.cast_sum, Int.cast_mul]
  rw [← all, ← neg_mul_eq_mul_neg, Finset.mul_sum, ← Finset.sum_neg_distrib]
  apply Finset.sum_congr rfl
  intro e _
  ring

def walshUnit (n : ℕ) : (Operator n)ˣ where
  val := walsh n
  inv := (2:ℝ)⁻¹^n • walsh n
  val_inv := by simp [walsh_square, smul_smul]
  inv_val := by simp [walsh_square, smul_smul]

theorem hamiltonian_conjugate (g : Glass n) :
    g.hamiltonian = (walshUnit n : Operator n) * Matrix.diagonal (fun s => (g.energy s : ℝ)) * (↑(walshUnit n)⁻¹ : Operator n) := by
  change _ = (walsh n * _) * _
  rw [← walsh_eigen]
  change _ = (g.hamiltonian * (walshUnit n : Operator n)) * _
  simp [Matrix.mul_assoc]

def Glass.classicalThermal (g : Glass n) (β : ℝ) : ℝ :=
  (∑ s, (g.energy s : ℝ) * Real.exp (-β * g.energy s)) / ∑ s, Real.exp (-β * g.energy s)

def Glass.quantumThermal (g : Glass n) (β : ℝ) : ℝ :=
  (g.hamiltonian * NormedSpace.exp ((-β) • g.hamiltonian)).trace /
    (NormedSpace.exp ((-β) • g.hamiltonian)).trace

/-- Equality of the quantum Gibbs mean of Hx with the classical Gibbs energy. The
partition sum and its energy-weighted numerator are computed with all multiplicities. -/
theorem thermal_identity (g : Glass n) (β : ℝ) : g.quantumThermal β = g.classicalThermal β := by
  let U := walshUnit n
  let E (s : Spin n) : ℝ := g.energy s
  let W (s : Spin n) := Real.exp (-β * E s)
  have expd : NormedSpace.exp ((-β) • Matrix.diagonal E) = Matrix.diagonal W := by
    rw [← Matrix.diagonal_smul, Matrix.exp_diagonal]
    congr 1
    funext s
    simp [W, Real.exp_eq_exp_ℝ]
  have expH : NormedSpace.exp ((-β) • g.hamiltonian) = (U : Operator n) * Matrix.diagonal W * (↑U⁻¹ : Operator n) := by
    have factor : (-β) • g.hamiltonian = (U : Operator n) * ((-β) • Matrix.diagonal E) * (↑U⁻¹ : Operator n) := by
      rw [hamiltonian_conjugate, Matrix.mul_smul, Matrix.smul_mul]
    rw [factor, Matrix.exp_units_conj, expd]
  have tr (M : Operator n) : ((U : Operator n) * M * (↑U⁻¹ : Operator n)).trace = M.trace := by
    rw [Matrix.trace_mul_cycle]; simp
  rw [Glass.quantumThermal, expH, hamiltonian_conjugate]
  change (((U : Operator n) * Matrix.diagonal E * (↑U⁻¹ : Operator n)) *
    (U * Matrix.diagonal W * (↑U⁻¹ : Operator n))).trace / _ = _
  have mul : ((U : Operator n)*Matrix.diagonal E*(↑U⁻¹ : Operator n)) *
      (U * Matrix.diagonal W * (↑U⁻¹ : Operator n)) =
      U * (Matrix.diagonal E * Matrix.diagonal W) * (↑U⁻¹ : Operator n) := by
    simp [Matrix.mul_assoc]
    rw [← Matrix.mul_assoc, Matrix.diagonal_mul_diagonal]
  rw [mul, tr, tr, Matrix.diagonal_mul_diagonal, Matrix.trace_diagonal, Matrix.trace_diagonal]
  rfl

end FQChem.StatePrep.ImaginaryTimeProjection.IsingSign
