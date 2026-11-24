module

public import FQChemQatlib.Dynamics.LowChuangSparseScalar
public import FQChemQatlib.Dynamics.LowChuangReadout
public import Mathlib.Analysis.SpecialFunctions.Log.Base

/-! # Sparse simulation from standard zeroes at physical entry scale -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseAssembly

open Matrix Query SparseBlock Qatlib.Foundations.PureStateMath
open Sparse (Access)
open Qatlib.Concepts.BlockEncoding.EncodingCore Qatlib.Concepts.BlockEncoding.Postselection.Encoding
open Qatlib.Concepts.BlockEncoding.LCU Qatlib.Concepts.Execution.WorkspaceCP
open Qatlib.Concepts.QspSimulation.Achievability Qatlib.Concepts.GateVocabulary.LocalReflectionGates
open Qatlib.Papers.Qubitization19.MainResults
open Qatlib.Concepts.UniformBqp.FiniteGateWord.FiniteThermalCircuits
open scoped Classical Matrix.Norms.L2Operator

/-- The next *strictly* greater binary range accommodates the positive
endpoint of a signed word and inflates the known maximum by at most two. -/
theorem binaryRange (c : ℝ) (hc : 0<c) : ∃ e : ℤ, c < (2:ℝ)^e ∧ (2:ℝ)^e ≤ 2*c := by
  let k := ⌊Real.logb 2 c⌋
  have lo : (2:ℝ)^k ≤ c := by
    rw [←Real.rpow_intCast]; exact (Real.le_logb_iff_rpow_le (by norm_num) hc).mp (Int.floor_le _)
  have hi : c < (2:ℝ)^(k+1) := by
    rw [←Real.rpow_intCast]; apply (Real.logb_lt_iff_lt_rpow (by norm_num) hc).mp
    push_cast; exact Int.lt_floor_add_one _
  exact ⟨k+1,hi,by rw [zpow_add_one₀ (by norm_num)]; linarith⟩

/-- Every integer on the signed fixed-point lattice in the advertised
range has the exact centered binary representation used by the oracle. -/
theorem representable (p : ℕ) (x : ℤ) (lo : -(2:ℤ)^p≤x) (hi : x<(2:ℤ)^p) :
    ∃ re : Reg (p+1), Binary.signedValue re=(x:ℂ)/(2:ℂ)^p := by
  let v := x+2^p
  have nonneg : 0≤v := by dsimp [v]; omega
  have bound : v.toNat < 2^(p+1) := by
    apply Int.ofNat_lt.mp
    rw [Int.toNat_of_nonneg nonneg]
    push_cast
    rw [pow_succ]; dsimp [v]; omega
  let word := (bitVecEquiv (p+1)).symm ⟨v.toNat,bound⟩
  refine ⟨word,?_⟩
  rw [Binary.signedValue,thermalBitValue_ofFn]
  have val : ((bitVecEquiv (p+1) word).val:ℤ)=v := by simp [word,Int.toNat_of_nonneg nonneg]
  have complex : ((bitVecEquiv (p+1) word).val:ℂ)=(v:ℂ) := by exact_mod_cast val
  rw [complex]
  dsimp [v]; push_cast; rw [pow_succ]; field_simp; ring

/-- All flags, address workspace and the decoder start in computational
zero. Two counted elementary gates prepare and read the signal flags.
Use c equal to the supplied positive maximum entry norm. A known dyadic
entry unit within a factor of two gives the same optimal query scale. -/
theorem sparseCoordinateSimulation {n d : ℕ} (wire : Fin n) (hd : 0<d) (range : d≤2^n)
    (p : ℕ) (b c t ε : ℝ) (hb : 0<b) (hc : 0<c) (tight : b≤2*c) (he : 0<ε) (small : ε<1) :
    ∃ Q : ℕ, IsPaperCutoffQ (t*(d*c)) ε Q ∧
    ∃ program : List (Step (System n (Binary.size p)) Access),
      cost Access.position program ≤ 69174*Q ∧ cost Access.entry program ≤ 69174*Q ∧
      fixedCount program ≤ 10000000000000*(n+p+1)*Q+2 ∧
      (∀ M,.fixed M∈program → Allowed n (Binary.size p) M) ∧
      ∀ (H : Matrix (Reg n) _ ℂ) (pos : Reg n → Equiv.Perm (Reg n)) (re im : Reg n→Reg n→Reg p),
      H.IsHermitian → (∀ i j, H i j≠0 → ∃ u : Fin d, (pos i).symm j=numberedSlot range u) →
      (∀ i j, Binary.signedValue (re i j) + Complex.I*Binary.signedValue (im i j) = (b⁻¹:ℝ) • H i j) →
      let F := flagsZero (I:=Reg n) (blank (n+Binary.size p))
      let M := run (sparseInputs pos (table re im)) program
      ‖compress F M F-hamiltonianEvolution H t‖ ≤ ε^2/2 ∧
      ∀ ψ : QState (Reg n), Normalized ψ → 1-ε^2 ≤ postselectionProbability M F F ψ := by
  obtain ⟨q,cut,program,np,nv,ng,legal,valid⟩ := sparseResourceBound wire hd range p b c t ε hb hc tight he small
  let m := Binary.size p
  let T := flagsHadamard (J:=Reg (n+m)) (I:=Reg n)
  let cs : List (Step (System n m) Access) := .fixed Tᴴ :: (program ++ [.fixed T])
  have had : Allowed n m T := by
    rw [show T=onFlags (J:=Reg (n+m)) (I:=Reg n) (TensorGate Hadamard Hadamard) from localHadamards]
    exact .standard (.flags _ (tensorGate_unitary hadamard_unitary hadamard_unitary))
  refine ⟨q,cut,cs,?_,?_,?_,?_,?_⟩
  · simpa [cs,cost,cost_append] using np
  · simpa [cs,cost,cost_append] using nv
  · simp only [cs,fixedCount,fixed_append]; omega
  · intro M h
    rcases List.mem_cons.mp h with e|h
    · cases e; exact .adj had
    rcases List.mem_append.mp h with h|e
    · exact legal _ h
    · cases List.mem_singleton.mp e; exact had
  intro H pos re im hermitian supp val
  obtain ⟨err,born⟩ := valid H pos re im hermitian supp val
  let data := sparseInputs pos (table re im)
  have eq : run data cs=Tᴴ*run data program*T := by simp [cs,run,matrix,run_append,Matrix.mul_assoc]
  have wrap := coordinate_acts (blank (n+m)) (run data program)
  dsimp only
  rw [eq,wrap.1]
  exact ⟨err,fun ψ h => (wrap.2 ψ).symm ▸ born ψ h⟩

/-- A zero public entry norm specifies the zero Hamiltonian. The empty
program is exact at every time and uses no queries or elementary gates. -/
theorem zeroHamiltonian (n : ℕ) (t : ℝ) (data : Access → Matrix (Reg n) (Reg n) ℂ) :
    run data []=hamiltonianEvolution (0 : Matrix (Reg n) (Reg n) ℂ) t ∧
    (∀ a : Access,cost a ([] : List (Step (Reg n) Access))=0) ∧
    fixedCount ([] : List (Step (Reg n) Access))=0 := by
  exact ⟨by simp [run,hamiltonianEvolution],fun _ => rfl,rfl⟩

end FQChemQatlib.Dynamics.LowChuang.SparseAssembly
