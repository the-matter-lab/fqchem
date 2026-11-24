module

public import FQChemQatlib.Dynamics.LowChuangBinaryCompare
public import Qatlib.Concepts.QmaCompleteness.HistoryHam.QmaCompletenessDefs

/-! # Exact signed binary amplitudes from coherent comparison -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.Binary

open Matrix FQChemQatlib.Dynamics.BorrowedControls
open Qatlib.Foundations.PureStateMath Qatlib.Foundations.QueryWordCore.Circuit
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermalCircuits

variable {n : ℕ}

def sign (b : Bool) : ℂ := if b then 1 else -1

/-- The centered fixed-point value of a binary input, in offset-binary
representation. Complementing the high bit converts two's complement. -/
def signedValue {p : ℕ} (bits : Reg p) : ℂ :=
  2*(thermalBitValue (List.ofFn bits):ℂ)/(2:ℂ)^p-1

theorem averaged_sign {p : ℕ} (bits : Reg p) :
    (∑ u : Reg p, sign (decide (thermalBitValue (List.ofFn u) < thermalBitValue (List.ofFn bits)))) /
    (2:ℂ)^p = signedValue bits := by
  let k := thermalBitValue (List.ofFn bits)
  have h := thermalUniformBits_less_complex p k (by dsimp [k]; simpa using (thermalBitValue_bound (List.ofFn bits)).le)
  have eq (u : Reg p) : sign (decide (thermalBitValue (List.ofFn u)<k)) =
      2*(if thermalBitValue (List.ofFn u)<k then 1 else 0)-1 := by
    by_cases c : thermalBitValue (List.ofFn u)<k <;> norm_num [sign,c]
  change (∑ u : Reg p, sign (decide (thermalBitValue (List.ofFn u)<k)))/(2:ℂ)^p=_
  simp_rw [eq]
  rw [Finset.sum_sub_distrib,← Finset.mul_sum,h]
  simp [Reg,signedValue,k]
  field_simp

theorem encoded_diagonal {word : List FiniteGateCode} {f : Reg n → Reg n}
    (valid : finiteWordLegal n word=true)
    (h : ∀ s, Run 1 (finiteCodeCircuit n word) (Qatlib.Foundations.PureStateMath.Ket s) =
      Qatlib.Foundations.PureStateMath.Ket (f s)) (d : Reg n → ℂ) :
    (finiteWordMatrix n word)ᴴ * Matrix.diagonal d * finiteWordMatrix n word =
    Matrix.diagonal (fun s => d (f s)) := by
  let F := finiteWordMatrix n word
  have col (i j : Reg n) : F i j = if i=f j then 1 else 0 := by
    have eq := congrFun (h j) i
    rw [run_finiteCodeCircuit] at eq
    simpa [Matrix.mulVec,dotProduct,Qatlib.Foundations.PureStateMath.Ket,F] using eq
  have unit : F ∈ Matrix.unitaryGroup _ ℂ := finiteWordMatrix_unitary n word valid
  have intertwine : Matrix.diagonal d * F = F * Matrix.diagonal (fun s => d (f s)) := by
    ext i j
    by_cases eq : i=f j <;> simp [Matrix.diagonal_mul,Matrix.mul_diagonal,col,eq]
  change Fᴴ * _ * F = _
  rw [Matrix.mul_assoc,intertwine,← Matrix.mul_assoc,show Fᴴ*F=1 from (Matrix.mem_unitaryGroup_iff').mp unit,Matrix.one_mul]

/-- A forward ripple, one diagonal phase on the output wire, and the exact
inverse implement the comparison phase. On clean carries it is +1 below the
threshold and −1 elsewhere, for every pair of input words. -/
theorem ripple_phase (seed : Fin n) (ds : List (Digit n)) (h : Binary.valid seed ds) :
    ∃ gs : List FiniteGateCode, gs.length≤47*ds.length ∧ finiteWordLegal n gs=true ∧
      let C := finiteWordMatrix n gs
      let D := Matrix.diagonal (fun s : Reg n => sign (s (result seed ds)))
      Cᴴ*D*C = Matrix.diagonal (fun x => sign (compute seed ds x (result seed ds))) ∧
      ∀ (x : Reg n), x seed=false → (∀ d∈ds, x d.output=false) →
      (Cᴴ*D*C) x x = sign (decide (thermalBitValue (ds.map fun d => x d.left) <
        thermalBitValue (ds.map fun d => x d.right))) := by
  obtain ⟨gs,size,legal,action⟩ := ripple_word seed ds h
  let d := fun s : Reg n => sign (s (result seed ds))
  have eq := encoded_diagonal legal action d
  exact ⟨gs,size,legal,eq,fun x init clean => by
    rw [eq,Matrix.diagonal_apply_eq]; exact congrArg sign (ripple_result seed ds h x init clean)⟩

end FQChemQatlib.Dynamics.LowChuang.Binary
