import FQChemForShor.QuantumFactoring
import FQChem.Complexity.FactoringPreprocessing
import Mathlib.Probability.ProbabilityMassFunction.Constructions

/-! # Born normalization for the actual compiled order-finding circuit -/

namespace FQChem.Complexity.CompiledSampling
open Shor Shor.Model Shor.Model.QuantumLib OrderFinding QuantumFactoring
open FactoringReduction MeasureTheory

/-- Total mass of the physical register measurement on the compiled state. -/
theorem normalized (inst : ShorOrderFindingInstance) :
    ∑ o : Fin (ASize (program inst).output), mass inst o.val = 1 := by
  classical
  let p := program inst
  let dim := maxQubit p.circuit
  let M := denote dim p.circuit
  let v := M * e dim (zeroIdx dim)
  have col (k : Fin (2^dim)) : v k 0 = M k (zeroIdx dim) := by simp [v, Matrix.mul_apply, e]
  have unit := Matrix.mem_unitaryGroup_iff'.mp (denote_unitary p.circuit (le_refl dim))
  have length : cnorm2 v = 1 := by
    have eq := congrArg (fun A : Matrix (Fin (2^dim)) (Fin (2^dim)) ℂ => A (zeroIdx dim) (zeroIdx dim)) unit
    apply Complex.ofReal_injective
    push_cast [cnorm2, col, Complex.sq_norm]
    simp only [Complex.normSq_eq_conj_mul_self]
    simpa [Matrix.mul_apply, Matrix.star_eq_conjTranspose, M] using eq
  rw [← length]
  change (∑ o : Fin (ASize p.output), ∑ k, ‖(proj dim p.output o.val * v) k 0‖ ^ 2) = _
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun k _ => ?_
  let label : Fin (ASize p.output) := ⟨_,mToNat_lt p.output (idxBasis dim k)⟩
  rw [Finset.sum_eq_single label]
  · simp [proj_mul_apply,label]
  · intro j _ hj
    have hne : mToNat p.output (idxBasis dim k) ≠ j.val := fun e => hj (Fin.ext e.symm)
    simp [proj_mul_apply,hne]
  · simp

theorem mass_pos (inst : ShorOrderFindingInstance) (o : ℕ) : 0 ≤ mass inst o := by
  unfold mass cnorm2
  positivity

/-- A finite clock PMF computed from the matrix Born weights. -/
noncomputable def clockLaw (inst : ShorOrderFindingInstance) :
    PMF (Fin (ASize (program inst).output)) :=
  PMF.ofFintype (fun o => ENNReal.ofReal (mass inst o.val)) (by
    rw [← ENNReal.ofReal_sum_of_nonneg (fun o _ => mass_pos inst o.val), normalized]
    simp)

end FQChem.Complexity.CompiledSampling
