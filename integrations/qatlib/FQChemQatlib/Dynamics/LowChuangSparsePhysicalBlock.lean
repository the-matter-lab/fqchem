module

public import FQChemQatlib.Dynamics.LowChuangSparseSwap
public import FQChemQatlib.Dynamics.LowChuangSparseAccess

/-! # Two sparse oracles and a linear number of elementary gates per block -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseControl

open Matrix Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.LocalMachine.LocalTransport Qatlib.Concepts.CopyEvolution.Discriminate
open Qatlib.Concepts.BlockEncoding.LCU
open Qatlib.Concepts.GateVocabulary.FiniteGateDescription Qatlib.Concepts.QmaCompleteness.HistoryHam
open SparseWires SparseBlock Query
open Sparse (Access)
open scoped Classical

variable {k n m : ℕ}

def slot (S : Matrix (Reg n) (Reg n) ℂ) : Op n m := raw (broadcast (slotGate (B:=Reg m) S))

private theorem slot_mul (A B : Matrix (Reg n) (Reg n) ℂ) : slot (m:=m) (A*B)=slot A*slot B := by
  have h {I J : Type} [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J] (X Y : Matrix I I ℂ) :
      parallelOracle (J:=J) (X*Y) = parallelOracle X * parallelOracle Y :=
    (parallel_select_mul _ _).symm
  have t : TensorGate (A*B) (1:Matrix (Reg m) _ ℂ)=TensorGate A (1:Matrix (Reg m) _ ℂ)*TensorGate B 1 := by
    rw [tensorGate_mul,one_mul]
  simp only [slot,slotGate,t,h,broadcast_mul,raw_mul]

private theorem slot_one : slot (m:=m) (1:Matrix (Reg n) _ ℂ)=1 := by
  simp [slot,slotGate,tensorGate_one,broadcast,parallelOracle,parallel_select_one,raw]

private theorem slot_word (gs : List FiniteGateCode) (leg : finiteWordLegal n gs=true) :
    Emits (slot (m:=m) (finiteWordMatrix n gs)) gs.length := by
  induction gs with
  | nil => simpa only [finiteWordMatrix,slot_one,List.length_nil] using (empty (n:=n) (m:=m))
  | cons g gs ih =>
    obtain ⟨hg,ht⟩ := Bool.and_eq_true_iff.mp leg
    rw [finiteWordMatrix,slot_mul]
    exact concat (ih ht) (single (.slots _ hg))

theorem slot_gates (w : Fin k ↪ Fin n) : Emits (slot (m:=m) (slots w)) k := by
  obtain ⟨count,leg⟩ := Binary.hWord_cost w
  exact weaken (slot_word _ leg) count.le

abbrev InMat (n m : ℕ) := Matrix (HostBits n m) (HostBits n m) ℂ

def fromRaw (M : Op n m) : InMat n m := Matrix.reindexAlgEquiv ℂ ℂ unpack M

private theorem raw_from (M : Op n m) : raw (fromRaw M)=M := by
  ext x y
  change M (unpack.symm (unpack x)) (unpack.symm (unpack y))=M x y
  simp

private theorem from_raw (M : InMat n m) : fromRaw (raw M)=M := by
  ext x y
  change M (unpack (unpack.symm x)) (unpack (unpack.symm y))=M x y
  simp

def Covered (program : List (Step (HostBits n m) Access)) :=
  ∀ M, .fixed M ∈ program → Elementary n m (raw M)

private theorem compileFixed (M : InMat n m) (q : ℕ) (h : Emits (raw M) q) :
    ∃ xs : List (Step (HostBits n m) Access), fixedCount xs≤q ∧
    (∀ a,cost a xs=0) ∧ Covered xs ∧ ∀ data, run data xs=M := by
  obtain ⟨gs,len,all,eq⟩ := h
  let xs : List (Step (HostBits n m) Access) := gs.map (fun A => Step.fixed (fromRaw A))
  have count : fixedCount xs=gs.length := by
    dsimp [xs]
    clear xs len all eq
    induction gs <;> simp [fixedCount, *]
  have noquery (a : Access) : cost a xs=0 := by
    dsimp [xs]
    clear count xs len all eq
    induction gs <;> simp [cost, *]
  have cov : Covered xs := by
    intro U hu
    obtain ⟨a,ha,eq⟩ := List.mem_map.mp hu
    cases eq
    rw [raw_from]
    exact all _ ha
  have sem (data : Access → InMat n m) : run data xs=fromRaw gs.prod := by
    dsimp [xs]
    clear cov noquery count xs len all eq
    induction gs with
    | nil => simp [run,fromRaw]
    | cons A gs ih =>
      change fromRaw A * run data (gs.map (fun A => Step.fixed (fromRaw A))) = fromRaw (A*gs.prod)
      rw [ih]
      exact (map_mul (Matrix.reindexAlgEquiv ℂ ℂ unpack) A gs.prod).symm
  exact ⟨xs,count ▸ len,noquery,cov,fun data => (sem data).trans (eq ▸ from_raw M)⟩

/-- The sparse block's logical matrix has a physical program in ordinary
position/value queries, plus local gates on the two signal flags, two
address registers, and the binary arithmetic workspace. The program is
fixed before the input tables are supplied. -/
theorem physicalBody (w : Fin k ↪ Fin n) {q : ℕ} (V : Matrix (Reg m) _ ℂ) (built : Binary.Built V q) :
    ∃ cs : List (Step (HostBits n m) Access),
    cost Access.position cs=2 ∧ cost Access.entry cs=2 ∧
    fixedCount cs ≤ 2*k+415440*(n+q) ∧ Covered cs ∧
    ∀ (pos : Reg n → Equiv.Perm (Reg n)) (load : Reg n → Reg n → Equiv.Perm (Reg m)),
      run (inputs pos load) cs = lifted (oracle (slots w) pos load V) := by
  let S := slots w
  let U := broadcast (slotGate (B:=Reg m) S)
  let W := lifted (permMatrix (exchange (I:=Reg n) (B:=Reg m)))
  let D := lifted (decoderGate (I:=Reg n) V)
  obtain ⟨a,ca,na,ga,ea⟩ := compileFixed Uᴴ k (adj (slot_gates w))
  obtain ⟨z,cz,nz,gz,ez⟩ := compileFixed U k (slot_gates w)
  obtain ⟨b,cb,nb,gb,eb⟩ := compileFixed W _ swapGate
  obtain ⟨v,cv,nv,gv,ev⟩ := compileFixed D _ (decoder built)
  let p : List (Step (HostBits n m) Access) :=
      a ++ [.query .position true] ++ b ++ [.query .entry true] ++ v ++ [.query .entry false,.query .position false] ++ z
  refine ⟨p,?_,?_,?_,?_,?_⟩
  · simp [p,cost_append,cost,na,nz,nb,nv]
  · simp [p,cost_append,cost,na,nz,nb,nv]
  · simp only [p,fixed_append,fixedCount,add_zero] ; omega
  · intro M hm
    simp only [p,List.mem_append,List.mem_cons,List.not_mem_nil,or_false,reduceCtorEq] at hm
    rcases hm with (((h|h)|h)|h)
    · exact ga M h
    · exact gb M h
    · exact gv M h
    · exact gz M h
  · intro pos load
    have orig := (body_spec S (finiteWordMatrix_unitary _ _ (Binary.hWord_cost w).2) V pos load).2.2
    rw [←orig]
    simp [p,run_append,ea,ez,eb,ev,body,run,matrix,U,W,D]

end FQChemQatlib.Dynamics.LowChuang.SparseControl
