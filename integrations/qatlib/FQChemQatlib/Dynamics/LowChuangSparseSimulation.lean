module

public import FQChemQatlib.Dynamics.LowChuangSparsePacking

/-! # End-to-end sparse-oracle Hamiltonian simulation with elementary costs -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseAssembly

open Matrix Query SparseBlock SparseWires
open Sparse (Access)
open Qatlib.Foundations.PureStateMath Qatlib.Concepts.QspSimulation.Achievability
open Qatlib.Concepts.LocalMachine.LocalTransport Qatlib.Concepts.CopyEvolution.Discriminate
open Qatlib.Concepts.BlockEncoding.EncodingCore Qatlib.Concepts.Execution.WorkspaceCP
open Qatlib.Concepts.BlockEncoding.LCU Qatlib.Concepts.BlockEncoding.Postselection.Encoding
open Qatlib.Papers.Qubitization19.MainResults
open scoped Classical Matrix.Norms.L2Operator

abbrev System (n m : ℕ) := Physical.Basis (n+m) n

/-- Both branches are one- or two-qubit instructions on the same physical
wires. The second branch changes only tuple grouping and wire ordering. -/
inductive Allowed (n m : ℕ) : Matrix (System n m) (System n m) ℂ → Prop where
  | standard {M : Matrix (System n m) _ ℂ} : Physical.Elementary (n+m) n M → Allowed n m M
  | sparse {M : SparseControl.InMat n m} : SparseControl.Elementary n m (raw M) →
      Allowed n m (push (flags pack) M)
  | adj {M : Matrix (System n m) _ ℂ} : Allowed n m M → Allowed n m Mᴴ

def sparseInputs {n m : ℕ} (pos : Reg n→Equiv.Perm (Reg n))
    (load : Reg n→Reg n→Equiv.Perm (Reg m)) (a : Access) : Matrix (System n m) (System n m) ℂ :=
  push (flags pack) (inputs pos load a)

variable {k n p : ℕ}

private theorem instantiate {m : ℕ} (inner : List (Step (HostBits n m) Access))
    (outer : List (Step (System n m) StandardOracle)) (locals : SparseControl.Covered inner)
    (gates : ∀ M,.fixed M∈outer → Physical.Elementary (n+m) n M) :
    ∀ M, .fixed M∈compile (inner.map (renameStep (flags pack))) outer → Allowed n m M := by
  refine compile_gates (P:=Allowed n m) (fun _ p => .adj p) _ ?_ _ (fun _ h => .standard (gates _ h))
  intro M h
  obtain ⟨g,hg,eq⟩ := List.mem_map.mp h
  cases g with
  | query a b => cases eq
  | fixed A => cases eq; exact .sparse (locals _ hg)

private theorem logical_eq {a r : ℕ} (U : Matrix (Reg a×Reg r) (Reg a×Reg r) ℂ) :
    logical (lifted U) = standardInput (1 : Matrix (Reg a) (Reg a) ℂ) U := by
  funext j; cases j
  · simp [logical,standardInput,tensorGate_one,broadcast,parallelOracle,parallel_select_one]
  · rfl

private theorem run_physical {m : ℕ} (V : Matrix (Reg m) (Reg m) ℂ)
    (pos : Reg n → Equiv.Perm (Reg n)) (load : Reg n→Reg n→Equiv.Perm (Reg m))
    (S : Matrix (Reg n) (Reg n) ℂ) (inner : List (Step (HostBits n m) Access))
    (outer : List (Step (System n m) StandardOracle))
    (h : run (inputs pos load) inner=lifted (oracle S pos load V)) :
    run (sparseInputs pos load) (compile (inner.map (renameStep (flags pack))) outer) =
      run (standardInput (1 : Matrix (Reg (n+m)) _ ℂ) (push pack (oracle S pos load V))) outer := by
  rw [compile_run]
  have he : run (sparseInputs pos load) (inner.map (renameStep (flags pack))) =
      lifted (push pack (oracle S pos load V)) := (rename_run _ _ _).trans
        ((congrArg (push (flags pack)) h).trans (push_lifted _ _))
  rw [he,logical_eq]

/-- All four input/expense/accuracy statements refer to the same physical
program. Each entry oracle returns two centered p-bit Cartesian mantissas
in public physical units b. The position oracle is in place; the value
oracle XORs the two p-bit fields and leaves the clean workspace alone. -/
theorem elementarySparseSimulation (w : Fin k ↪ Fin n) (wire : Fin n) (p : ℕ)
    (b t ε : ℝ) (hb : 0<b) (he : 0<ε) (small : ε<1) :
    ∃ q : ℕ, IsPaperCutoffQ (t*(2*2^k*b)) ε q ∧
    ∃ program : List (Step (System n (Binary.size p)) Access),
      cost Access.position program=54*(64*q+1) ∧ cost Access.entry program=54*(64*q+1) ∧
      fixedCount program ≤ 250*(n+Binary.size p+4)*(27*(64*q+8)-2) +
        (2*k+415440*(n+(190*p+4)))*(27*(64*q+1)) ∧
      (∀ M,.fixed M∈program → Allowed n (Binary.size p) M) ∧
      ∀ (H : Matrix (Reg n) _ ℂ) (pos : Reg n → Equiv.Perm (Reg n)) (re im : Reg n→Reg n→Reg p),
      H.IsHermitian → (∀ i j, H i j≠0 → ∃ u, (pos i).symm j=slotAddress w u) →
      (∀ i j, Binary.signedValue (re i j) + Complex.I*Binary.signedValue (im i j) = (b⁻¹:ℝ) • H i j) →
      let F := encodingFiber (I:=Reg n) (blank (n+Binary.size p))
      let R := hamiltonianFrame F
      let M := run (sparseInputs pos (table re im)) program
      ‖compress R M R-hamiltonianEvolution H t‖ ≤ ε^2/2 ∧
      ∀ ψ : QState (Reg n), Normalized ψ → 1-ε^2 ≤ postselectionProbability M R R ψ := by
  let m := Binary.size p
  let τ := t*(2*2^k*b)
  obtain ⟨V,_,bc,coding⟩ := cartesianEncoding w p
  obtain ⟨cs,np,nv,ng,allCs,body⟩ := SparseControl.physicalBody w V bc
  obtain ⟨q,cut,word,_,visits,ordinary,allWord,evolution⟩ :=
    Physical.qubitRegisterSimulation (blank (n+m)) wire τ ε he small
  let E := flags (pack (n:=n) (m:=m))
  let program := compile (cs.map (renameStep E)) word
  refine ⟨q,cut,program,?_,?_,?_,instantiate cs word allCs allWord,?_⟩
  · rw [compile_cost,rename_cost,np,visits]; omega
  · rw [compile_cost,rename_cost,nv,visits]; omega
  · rw [compile_fixed,rename_fixed,visits]
    exact Nat.add_le_add ordinary (Nat.mul_le_mul_right _ ng)
  intro H pos re im hH support access
  let A := (b⁻¹:ℝ) • H
  have hA : A.IsHermitian := hH.smul (IsSelfAdjoint.all _)
  have supp (i j : Reg n) (nz : A i j≠0) := support i j (fun z => nz (by simp [A,Matrix.smul_apply,z]))
  have enc := coding A pos re im hA supp access
  let T := ((2:ℂ)*2^k)⁻¹ • A
  have hT : T.IsHermitian := hA.smul (by simp [IsSelfAdjoint])
  let U := oracle (slots w) pos (table re im) V
  let F := encodingFiber (I:=Reg n) (blank (n+m))
  have uunit := push_unit (pack (n:=n) (m:=m)) U enc.unitary
  have signal : compress F (push pack U) F=T := (packed_compression U).trans enc.encoded
  have cor := evolution (1 : Matrix (Reg (n+m)) _ ℂ) (push pack U) T
    (Submonoid.one_mem _) uunit hT (by simpa only [tensorGate_one,Matrix.one_mul] using signal)
  have exactRun := run_physical V pos (table re im) (slots w) cs word (body _ _)
  have exactTime := scaledEvolution H b t hb k
  let R := hamiltonianFrame F
  let Law (M : Matrix (System n m) (System n m) ℂ) (B : Matrix (Reg n) (Reg n) ℂ) :=
    ‖compress R M R-B‖ ≤ ε^2/2 ∧ ∀ ψ : QState (Reg n), Normalized ψ → 1-ε^2 ≤ postselectionProbability M R R ψ
  exact (congrArg₂ Law exactRun exactTime.symm).mpr cor

end FQChemQatlib.Dynamics.LowChuang.SparseAssembly
