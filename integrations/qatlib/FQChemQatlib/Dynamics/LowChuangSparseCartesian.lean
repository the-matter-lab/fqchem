module

public import FQChemQatlib.Dynamics.LowChuangSparseBlock

/-! # Hadamard-padded slots and an exact binary sparse block encoding -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseBlock

open Matrix Qatlib.Foundations.PureStateMath Qatlib.Concepts.BlockEncoding
open Qatlib.Concepts.Execution.WorkspaceCP

open Qatlib.Concepts.QsvtCore.PhaseExistence Qatlib.Concepts.BlockEncoding.Postselection.Encoding

open Qatlib.Concepts.BlockEncoding.EncodingCore Qatlib.Concepts.BlockEncoding.Encoding
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription Qatlib.Concepts.QmaCompleteness.HistoryHam
open Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermalCircuits
open FQChemQatlib.Dynamics.LowChuang.Binary
open scoped Classical

variable {n p k : ℕ}

def blank (n : ℕ) : Reg n := fun _ => false

def xorWord {n : ℕ} (u : Reg n) : Equiv.Perm (Reg n) where
  toFun x i := x i ^^ u i
  invFun x i := x i ^^ u i
  left_inv x := by funext i; simp
  right_inv x := by funext i; simp

def table (re im : Reg n → Reg n → Reg p) (i j : Reg n) :=
  xorWord (packed (re i j) (im i j))

theorem table_blank (re im : Reg n → Reg n → Reg p) (i j : Reg n) :
    table re im i j (blank _) = packed (re i j) (im i j) := by funext x; simp [table,xorWord,blank]

def slots (w : Fin k ↪ Fin n) := finiteWordMatrix n (hWord w)

theorem slots_column (w : Fin k ↪ Fin n) (y : Reg n) :
    slots w y (blank n) = if Outside w (blank n) y then ((Real.sqrt 2:ℂ)⁻¹)^k else 0 := by
  have eq := thermalUniformHWord_zero_column (List.ofFn w) (List.nodup_ofFn.mpr w.injective)
    y (blank n) (fun _ _ => rfl)
  rw [run_finiteCodeCircuit] at eq
  simpa [slots,hWord,Matrix.mulVec,dotProduct,Qatlib.Foundations.PureStateMath.Ket,Outside,
      List.mem_ofFn,Set.mem_range] using eq

/-- The ordinary binary slot labels occupy k designated wires; surplus row
address wires start clean. This also permits a non-power-of-two number of
designated addresses within that register. -/
def slotAddress (w : Fin k ↪ Fin n) (u : Reg k) : Reg n := fill w (blank _) u

theorem slot_supported (w : Fin k ↪ Fin n) (u : Reg k) : Outside w (blank n) (slotAddress w u) :=
  fun _ hw => fill_out _ _ _ hw

theorem padded_slot_bound {d : ℕ} (hd : 0<d) :
    d ≤ 2^Nat.clog 2 d ∧ 2^Nat.clog 2 d < 2*d := by
  refine ⟨Nat.le_pow_clog (by decide) _,?_⟩
  by_cases h : d=1
  · simp [h]
  have one : 1<d := by omega
  have small := Nat.pow_pred_clog_lt_self (b:=2) (by decide) one
  rw [Nat.pred_eq_sub_one] at small

  have pos : 0 < Nat.clog 2 d := (Nat.lt_clog_iff_pow_lt (by decide : 1 < 2)).mpr (by simpa using one)
  rw [show Nat.clog 2 d = (Nat.clog 2 d-1)+1 by omega,pow_succ]
  omega

/-- There is one public decoder circuit, uniform in the sparse table, with
190p+4 elementary gates. For every Hermitian input in centered p-bit
Cartesian fixed point, the displayed oracle encodes H/(2·2^k) when
nonzero positions use addresses within the k-bit slot register. -/
theorem cartesianEncoding (w : Fin k ↪ Fin n) (p : ℕ) :
    ∃ V : Matrix (Reg (size p)) _ ℂ,
    V ∈ Matrix.unitaryGroup _ ℂ ∧ Built V (190*p+4) ∧
    (∀ (H : Matrix (Reg n) _ ℂ) (pos : Reg n → Equiv.Perm (Reg n))
       (re im : Reg n → Reg n → Reg p), H.IsHermitian →
     (∀ i j, H i j ≠ 0 → ∃ u : Reg k, (pos i).symm j = slotAddress w u) →
     (∀ i j, signedValue (re i j) + Complex.I*signedValue (im i j) = H i j) →
      ProjectedUnitaryEncoding (((2:ℂ)*2^k)⁻¹ • H) (oracle (slots w) pos (table re im) V)
        (frame (blank n) (blank (size p))) (frame (blank n) (blank (size p)))) := by
  obtain ⟨V,hu,cost,eval⟩ := cartesianDecoder p
  refine ⟨V,hu,cost,fun H pos re im hermitian support access => ?_⟩
  have su := finiteWordMatrix_unitary n (hWord w) (hWord_cost w).2
  refine ⟨oracle_unit _ su _ _ _ hu,frame_iso _ _,frame_iso _ _,?_⟩
  ext i j
  rw [compression,table_blank,eval,access,slots_column,slots_column]
  by_cases hz : H i j = 0
  · simp [hz]
  obtain ⟨u,hu⟩ := support i j hz
  obtain ⟨v,hv⟩ := support j i (by rwa [← hermitian.apply j i,star_ne_zero])
  simp only [hu,hv,slot_supported,ite_true,Complex.star_def,map_pow,map_inv₀,Complex.conj_ofReal,
    Matrix.smul_apply,smul_eq_mul]
  have sq : ((Real.sqrt 2:ℂ)⁻¹)^k * ((Real.sqrt 2:ℂ)⁻¹)^k = ((2:ℂ)^k)⁻¹ := by
    have h : (Real.sqrt 2:ℂ)^2=2 := by exact_mod_cast Real.sq_sqrt (by norm_num : (0:ℝ)≤2)
    rw [← mul_pow,← mul_inv,← pow_two,h,inv_pow]
  rw [_root_.mul_inv_rev]
  linear_combination (norm := ring_nf) H i j/2 * sq

end FQChemQatlib.Dynamics.LowChuang.SparseBlock
