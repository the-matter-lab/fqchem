module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.SchmidtSimulation
public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.Storage
import Mathlib.Tactic

/-! # Final product-observable measurement of an MPS circuit -/

@[expose] public section
namespace FQChem.Algorithms.MPSCircuit
open Matrix
variable {K : Type*} [Field K] [DecidableEq K] [StarRing K]

/-- Dense contraction of ⟨ψ|⊗ⱼOⱼ|ψ⟩, including projectors for local Born probabilities. -/
def bornSum {n : ℕ} (O : Observable K n) (v : Bits n → K) :=
  ∑ p : Pattern n, productEntry O p * v (ket p) * star (v (bra p))

/-- Final contraction agrees with the product observable expectation of the dense output. -/
theorem final_measurement {n : ℕ} (gs : List (Gate K n)) (C : Chain K n 1 1) (O : Observable K n) :
    (readout (simulate gs C).1 O 1) 0 0 = bornSum O (dense gs (amplitude C)) := by
  rw [readout_exact, Matrix.sum_apply]
  apply Finset.sum_congr rfl
  intro p _
  simp only [Matrix.smul_apply, smul_eq_mul, Matrix.mul_one, Matrix.mul_apply,
    Fin.sum_univ_one, Matrix.conjTranspose_apply]
  rw [simulate_exact, simulate_exact]
  exact (mul_assoc _ _ _).symm

omit [StarRing K] in
theorem final_width {n l r : ℕ} (gs : List (Gate K n)) (C : Chain K n l r) :
    (simulate gs C).1.width ≤ peakWidth gs C := by
  induction gs generalizing C with
  | nil => exact le_rfl
  | cons g gs ih => exact (ih (advance g C).1).trans (le_max_right ..)

omit [StarRing K] in
/-- Scalar work of simulation followed by contraction of one product observable. -/
theorem measurement_work {n l r χ : ℕ} (gs : List (Gate K n)) (C : Chain K n l r)
    (h : peakWidth gs C ≤ χ) :
    (simulate gs C).2 + readoutWork (simulate gs C).1 ≤
      gs.length*(24*χ^3+40*χ^2) + n*(20*χ^3+8*χ^2) :=
  Nat.add_le_add (simulate_work gs C h) (readout_work _ ((final_width gs C).trans h))

/-- Peak temporary scalar storage during the right-to-left sweep. After returning
from the suffix, the incoming environment, one intermediate matrix, four output
blocks and the accumulated output matrix can coexist. The site tensors are shared. -/
def readoutScratch : {n l r : ℕ} → Chain K n l r → ℕ
  | _,_,_, .nil d => d^2
  | _,l,_, .cons (m := m) _ C => max (readoutScratch C) (m^2+l*m+5*l^2)

omit [Field K] [DecidableEq K] [StarRing K] in
theorem readout_scratch {n l r χ : ℕ} (C : Chain K n l r) (h : C.width ≤ χ) :
    readoutScratch C ≤ 7*χ^2 := by
  induction C with
  | nil d =>
    change d ≤ χ at h
    calc d^2 ≤ χ^2 := by gcongr
         _ ≤ _ := by omega
  | @cons n l m r A C ih =>
    obtain ⟨hl,hc⟩ := max_le_iff.mp h
    have hm := (left_le_width C).trans hc
    refine max_le (ih hc) ?_
    calc m^2+l*m+5*l^2 ≤ χ^2+χ*χ+5*χ^2 := by gcongr
         _ = _ := by ring

/-- Peak scalar workspace across the gate updates and the final product measurement.
Gate matrices and observable entries are read-only inputs. -/
def totalSpace {n l r : ℕ} (gs : List (Gate K n)) (C : Chain K n l r) :=
  let out := (simulate gs C).1
  max (simulationSpace gs C) (out.stored + readoutScratch out)

omit [StarRing K] in
theorem total_space {n l r χ : ℕ} (gs : List (Gate K n)) (C : Chain K n l r)
    (h : peakWidth gs C ≤ χ) : totalSpace gs C ≤ 2*n*χ^2 + 36*χ^2 + 4*χ := by
  have final := (final_width gs C).trans h
  refine max_le (simulate_space gs C h) ?_
  have sum := Nat.add_le_add (stored_le _ final) (readout_scratch _ final)
  omega

end FQChem.Algorithms.MPSCircuit
