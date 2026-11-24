module

public import FQChemQatlib.Dynamics.LowChuangPhysical
public import FQChemQatlib.Dynamics.LowChuangStandardForm

/-! # Elementary-gate cost of standard-form simulation on qubit registers -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.Physical

open Matrix Query
open Qatlib.Concepts.GateVocabulary.LocalReflectionGates Qatlib.Concepts.GateVocabulary.FiniteGateDescription
open Qatlib.Concepts.QmaCompleteness.HistoryHam Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.BlockEncoding.EncodingCore Qatlib.Concepts.Execution.WorkspaceCP
open Qatlib.Concepts.QspSimulation.Achievability Qatlib.Concepts.PhaseGeometry.Phase
open Qatlib.Concepts.BlockEncoding.Postselection.Encoding Qatlib.Papers.Qubitization19.MainResults
open scoped Matrix.Norms.L2Operator

variable {a r : ℕ}
abbrev Operator (a r : ℕ) := Matrix (Basis a r) (Basis a r) ℂ

/-- Legal addressed one- and two-wire operations, or an arbitrary unitary on
the two flags. The basis relabeling sends each wire to itself up to a bit
complement. Adjoint operations preserve their support. -/
inductive Elementary (a r : ℕ) : Operator a r → Prop where
  | wire (mask : Reg a) (g : FiniteGateCode) (legal : finiteCodeLegal (width a r) g = true) :
      Elementary a r (Matrix.reindex (layout a r mask) (layout a r mask) (finiteCodeMatrix (width a r) g))
  | flags (V : Matrix Flags Flags ℂ) (unit : V ∈ Matrix.unitaryGroup Flags ℂ) : Elementary a r (onFlags V)
  | adj {M} : Elementary a r M → Elementary a r Mᴴ

def Emits (M : Operator a r) (k : ℕ) : Prop :=
  ∃ gs : List (Operator a r), gs.length ≤ k ∧ (∀ g∈gs, Elementary a r g) ∧ gs.prod = M

private theorem single {M : Operator a r} (h : Elementary a r M) : Emits M 1 :=
  ⟨[M],by simp,by simpa using h,by simp⟩

private theorem mul_emits {A B : Operator a r} {k l} (ha : Emits A k) (hb : Emits B l) :
    Emits (A*B) (k+l) := by
  obtain ⟨x,hx,ax,px⟩ := ha
  obtain ⟨y,hy,ay,py⟩ := hb
  exact ⟨x++y,by simp;omega,fun g h => (List.mem_append.mp h).elim (ax g) (ay g),by simp [px,py]⟩

private theorem adj_emits {A : Operator a r} {k} (ha : Emits A k) : Emits Aᴴ k := by
  obtain ⟨gs,len,mem,rfl⟩ := ha
  refine ⟨(gs.map Matrix.conjTranspose).reverse,by simpa using len,?_,?_⟩
  · intro g h
    obtain ⟨V,hv,rfl⟩ := List.mem_map.mp (List.mem_reverse.mp h)
    exact .adj (mem _ hv)
  · clear len mem
    induction gs with
    | nil => simp
    | cons g gs ih => simp [ih]

private theorem weaken {A : Operator a r} {k l} (h : Emits A k) (b : k≤l) : Emits A l := by
  obtain ⟨x,hx,good,eq⟩ := h
  exact ⟨x,hx.trans b,good,eq⟩

private theorem compiles_emits {M : Operator a r} {k} (h : Compiles a r M k) : Emits M k := by
  obtain ⟨mask,gs,len,legal,rfl⟩ := h
  apply weaken _ len
  clear len
  induction gs with
  | nil => exact ⟨[],by simp,by simp,by simp [finiteWordMatrix]⟩
  | cons g gs ih =>
    have ⟨hg,hgs⟩ := Bool.and_eq_true_iff.mp legal
    have tail := ih hgs
    have one := single (Elementary.wire (r:=r) mask g hg)
    simpa only [List.length_cons,finiteWordMatrix,← Matrix.coe_reindexAlgEquiv ℂ ℂ,map_mul]
      using mul_emits tail one

private theorem scalar_pair (z : ℂ) (hz : IsPhase z) :
    (z • (1 : Matrix Flags Flags ℂ)) ∈ Matrix.unitaryGroup Flags ℂ := by
  rw [Matrix.mem_unitaryGroup_iff',Matrix.star_eq_conjTranspose,Matrix.conjTranspose_smul,Matrix.conjTranspose_one,
    Matrix.smul_mul,Matrix.mul_smul,smul_smul,hz,one_smul,Matrix.one_mul]

private theorem scalar_flags (z : ℂ) : onFlags (J:=Reg a) (I:=Reg r) (z • (1 : Matrix Flags Flags ℂ)) =
    z • (1 : Operator a r) := by
  ext ⟨b,c,u⟩ ⟨d,f,v⟩
  by_cases h : u=v <;> by_cases hb : b=d <;> by_cases hc : c=f <;>
    simp [onFlags,onBlocks_apply,h,hb,hc]

/-- Every gate in the fixed-instruction classification has a bounded
elementary expansion on the original register. The extra control of a cubic
phase borrows and restores an existing system qubit. -/
theorem frameGate_emits (zero : Reg a) (scratch : Fin r) {M : Operator a r}
    (gate : FrameGate (encodingFiber (I:=Reg r) zero) M) : Emits M (250*(a+4)) := by
  induction gate with
  | phase z hz =>
    rw [fiberPhase_sandwich]
    have ⟨unit,eq⟩ := localPhase (J:=Reg a) (I:=Reg r) z hz
    rw [eq]
    have test := compiles_emits (testAncilla_compiles a r zero)
    exact weaken (mul_emits (mul_emits test (single (.flags _ unit))) test) (by omega)
  | flip =>
    rw [localFlip]
    exact weaken (single (.flags _ (tensorGate_unitary pauliX_unitary (Submonoid.one_mem _)))) (by omega)
  | scalar =>
    rw [localScalar]
    apply weaken (single (.flags _ ?_)) (by omega)
    rw [Matrix.mem_unitaryGroup_iff',Matrix.star_eq_conjTranspose,Matrix.diagonal_conjTranspose,
      Matrix.diagonal_mul_diagonal]
    ext ⟨b,c⟩ ⟨d,f⟩
    cases b <;> cases c <;> cases d <;> cases f <;> simp
  | cubic z hz =>
    rw [cubic_coordinate zero hz,cubic_mark,localHadamards]
    have had := single (Elementary.flags (a:=a) (r:=r) _ (tensorGate_unitary hadamard_unitary hadamard_unitary))
    have changeBasis := single (Elementary.flags (a:=a) (r:=r) _ cnotBasis_unit)
    have test := compiles_emits (testBoth_compiles a r zero scratch)
    have scalar := single (Elementary.flags (a:=a) (r:=r) _ (scalar_pair (-z) (by
      rcases hz with rfl|rfl <;> simp [IsPhase])))
    rw [scalar_flags] at scalar
    have all := mul_emits (mul_emits had (mul_emits scalar
      (mul_emits (mul_emits changeBasis test) (adj_emits changeBasis)))) (adj_emits had)
    apply weaken _ (by omega : 1+(1+((1+120*(a+4))+1))+1 ≤ 250*(a+4))
    simpa only [neg_mul,Matrix.smul_mul,Matrix.one_mul,neg_smul,smul_neg] using all
  | adj old ih => exact adj_emits ih

private theorem fixed_program {K : Type} [DecidableEq K] (gs : List (Operator a r)) :
    (∀ (d : K → Operator a r), run d (gs.map Step.fixed) = gs.prod) ∧
    (∀ k : K, cost k (gs.map (Step.fixed (K:=K)))=0) ∧
    fixedCount (gs.map (Step.fixed (K:=K)))=gs.length := by
  induction gs with
  | nil => simp [run,cost,fixedCount]
  | cons x xs ih => simp [run,matrix,cost,fixedCount,ih.1,ih.2.1,ih.2.2]

private theorem expand {K : Type} [DecidableEq K] (program : List (Step (Basis a r) K)) {k : ℕ}
    (gate : ∀ M, .fixed M ∈ program → Emits M k) :
    ∃ expanded : List (Step (Basis a r) K),
      (∀ d, run d expanded = run d program) ∧
      (∀ j, cost j expanded = cost j program) ∧
      fixedCount expanded ≤ k*fixedCount program ∧
      ∀ M, .fixed M ∈ expanded → Elementary a r M := by
  induction program with
  | nil => exact ⟨[],by simp,by simp,by simp [fixedCount],by simp⟩
  | cons g rest ih =>
    obtain ⟨ys,mats,counts,size,good⟩ := ih (fun M h => gate M (List.mem_cons_of_mem _ h))
    cases g with
    | query j b =>
      refine ⟨.query j b :: ys,?_,?_,size,?_⟩
      · simp [run,mats]
      · simp [cost,counts]
      · simpa using good
    | fixed V =>
      obtain ⟨xs,len,els,prod⟩ := gate V (by simp)
      have ⟨val,zero,hnum⟩ := fixed_program (K:=K) xs
      refine ⟨xs.map Step.fixed ++ ys,?_,?_,?_,?_⟩
      · intro d
        rw [run_append,val,mats,prod]; rfl
      · intro j
        rw [cost_append,zero,counts,zero_add]; rfl
      · rw [fixed_append,hnum]
        change _ ≤ k*(fixedCount rest+1)
        rw [Nat.mul_add,Nat.mul_one]
        omega
      · intro M mem
        rcases List.mem_append.mp mem with hx|hy
        · obtain ⟨G,hg,eq⟩ := List.mem_map.mp hx
          exact (Step.fixed.inj eq) ▸ els _ hg
        · exact good _ hy

/-- All resource and approximation guarantees for qubit registers with at
least one system wire. The program is fixed before either input oracle is
supplied. Its additional gates are explicitly confined to one or two wires. -/
theorem qubitRegisterSimulation (zero : Reg a) (scratch : Fin r) (t ε : ℝ) (positive : 0<ε) (small : ε<1) :
    ∃ q : ℕ, IsPaperCutoffQ t ε q ∧ ∃ program : List (Step (Basis a r) StandardOracle),
      cost StandardOracle.prepare program = 54*(64*q+1) ∧
      cost StandardOracle.block program = 27*(64*q+1) ∧
      fixedCount program ≤ 250*(a+4)*(27*(64*q+8)-2) ∧
      (∀ M, .fixed M ∈ program → Elementary a r M) ∧
      ∀ (G : Matrix (Reg a) (Reg a) ℂ) (U : Matrix (Reg a × Reg r) _ ℂ) (H : Matrix (Reg r) (Reg r) ℂ),
        G ∈ Matrix.unitaryGroup _ ℂ → U ∈ Matrix.unitaryGroup _ ℂ → H.IsHermitian →
        let F := encodingFiber (I:=Reg r) zero
        let prepared := TensorGate G (1 : Matrix (Reg r) _ ℂ) * F
        compress prepared U prepared = H →
        let M := run (standardInput G U) program
        let R := hamiltonianFrame F
        ‖compress R M R - hamiltonianEvolution H t‖ ≤ ε^2/2 ∧
        ∀ ψ : QState (Reg r), Normalized ψ → 1-ε^2 ≤ postselectionProbability M R R ψ := by
  obtain ⟨q,hq,word,prep,block,hsize,covered,_,acc⟩ :=
    standardFormProgram (I:=Reg r) zero t ε positive small
  obtain ⟨out,eval,cost,size,actual⟩ := expand word
    (fun M h => frameGate_emits zero scratch (covered M h))
  refine ⟨q,hq,out,(cost _).trans prep,(cost _).trans block,hsize ▸ size,actual,?_⟩
  intro G U H hG hU hH
  dsimp only
  intro hin
  rw [eval]
  exact acc G U H hG hU hH hin

end FQChemQatlib.Dynamics.LowChuang.Physical
