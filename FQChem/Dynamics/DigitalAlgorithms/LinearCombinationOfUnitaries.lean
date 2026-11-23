module

public import Mathlib.LinearAlgebra.UnitaryGroup
public import Mathlib.Data.Matrix.Block
public import Mathlib.Analysis.Complex.Basic
import Mathlib.Tactic

/-!
# Linear combinations of unitaries by PREPARE and SELECT

The ancilla is the second index of the joint register. Preparing it, applying a
controlled term, and reversing preparation encodes a weighted sum of system
unitaries in the reference-ancilla block. [Berry et al.](https://arxiv.org/abs/1412.4687)
-/

@[expose] public section
noncomputable section

namespace FQChem.Dynamics.DigitalAlgorithms.LinearCombinationOfUnitaries

open Matrix
open scoped Kronecker ComplexConjugate

variable {d ι : Type*} [Fintype d] [DecidableEq d] [Fintype ι] [DecidableEq ι]

def select (U : ι → unitaryGroup d ℂ) : Matrix (d × ι) (d × ι) ℂ :=
  blockDiagonal fun k ↦ (U k).val

/-- A coherent switch among unitary system operators is unitary on the joint register. -/
theorem select_unitary (U : ι → unitaryGroup d ℂ) : select U ∈ unitaryGroup (d × ι) ℂ := by
  rw [mem_unitaryGroup_iff', star_eq_conjTranspose, select, blockDiagonal_conjTranspose,
    ← blockDiagonal_mul, ← blockDiagonal_one]
  congr 1
  funext k
  exact (U k).2.1

def circuit (B : unitaryGroup ι ℂ) (U : ι → unitaryGroup d ℂ) : Matrix (d × ι) (d × ι) ℂ :=
  ((1 : Matrix d d ℂ) ⊗ₖ B.valᴴ) * (select U * ((1 : Matrix d d ℂ) ⊗ₖ B.val))

theorem circuit_unitary (B : unitaryGroup ι ℂ) (U : ι → unitaryGroup d ℂ) :
    circuit B U ∈ unitaryGroup (d × ι) ℂ := by
  have hb : B.valᴴ ∈ unitaryGroup ι ℂ := (star B).property
  have one : (1 : Matrix d d ℂ) ∈ unitaryGroup d ℂ := (unitaryGroup d ℂ).one_mem
  exact (unitaryGroup _ _).mul_mem (kronecker_mem_unitary one hb)
    ((unitaryGroup _ _).mul_mem (select_unitary U) (kronecker_mem_unitary one B.property))

private theorem select_prepare (B : unitaryGroup ι ℂ) (U : ι → unitaryGroup d ℂ)
    (i j : d) (u v : ι) :
    (select U * ((1 : Matrix d d ℂ) ⊗ₖ B.val)) (i,u) (j,v) = (U u).val i j * B.val u v := by
  rw [Matrix.mul_apply, Fintype.sum_prod_type]
  simp [select, blockDiagonal_apply, Matrix.one_apply, ite_mul, mul_ite]

/-- The reference block equals the sum of the term unitaries weighted by ancilla
Born probabilities. The operator identity applies to every system input. -/
theorem referenceBlock (B : unitaryGroup ι ℂ) (U : ι → unitaryGroup d ℂ) (ref : ι) :
    (circuit B U).submatrix (fun i ↦ (i,ref)) (fun j ↦ (j,ref)) =
      ∑ k, (Complex.normSq (B.val k ref) : ℂ) • (U k).val := by
  ext i j
  rw [submatrix_apply, circuit, Matrix.mul_apply, Fintype.sum_prod_type]
  simp [select_prepare, Matrix.one_apply, ite_mul, Matrix.sum_apply,
    Matrix.smul_apply, Finset.sum_ite_irrel]
  apply Finset.sum_congr rfl
  intro k _
  rw [← Complex.mul_conj]
  ring

/-- Preparing amplitudes with squared modulus cₖ/α block-encodes H/α where
H = ∑ cₖUₖ. Phases of signed or complex coefficients can be included in Uₖ. -/
theorem blockEncodes (B : unitaryGroup ι ℂ) (U : ι → unitaryGroup d ℂ) (ref : ι)
    (c : ι → ℝ) {α : ℝ} (positive : 0 < α)
    (prepared : ∀ k, Complex.normSq (B.val k ref) = c k / α) :
    (α : ℂ) • (circuit B U).submatrix (fun i ↦ (i,ref)) (fun j ↦ (j,ref)) =
      ∑ k, (c k : ℂ) • (U k).val := by
  rw [referenceBlock, Finset.smul_sum]
  apply Finset.sum_congr rfl
  intro k _
  rw [smul_smul, prepared, Complex.ofReal_div, mul_div_cancel₀ _ (by exact_mod_cast positive.ne')]

/-- For a unit system input, the probability of measuring the reference ancilla
after the full circuit is ‖Hψ‖²/α². The identity also holds for unnormalized inputs. -/
theorem postselectionWeight (B : unitaryGroup ι ℂ) (U : ι → unitaryGroup d ℂ) (ref : ι)
    (c : ι → ℝ) {α : ℝ} (positive : 0 < α)
    (prepared : ∀ k, Complex.normSq (B.val k ref) = c k / α) (ψ : d → ℂ) :
    let input := fun x : d × ι ↦ if x.2 = ref then ψ x.1 else 0
    let H := ∑ k, (c k : ℂ) • (U k).val
    (∑ i, Complex.normSq ((circuit B U *ᵥ input) (i,ref))) =
      (∑ i, Complex.normSq ((H *ᵥ ψ) i)) / α ^ 2 := by
  intro input H
  let A := (circuit B U).submatrix (fun i ↦ (i,ref)) (fun j ↦ (j,ref))
  have encoded : (α : ℂ) • A = H := blockEncodes B U ref c positive prepared
  have amp (i : d) : (circuit B U *ᵥ input) (i,ref) = (A *ᵥ ψ) i := by
    simp [A, input, mulVec, dotProduct, Fintype.sum_prod_type, mul_ite]
  rw [← encoded, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i _
  rw [amp, Matrix.smul_mulVec]
  simp only [Pi.smul_apply, smul_eq_mul, Complex.normSq_mul, Complex.normSq_ofReal, ← sq]
  field_simp [positive.ne']

end FQChem.Dynamics.DigitalAlgorithms.LinearCombinationOfUnitaries
