module

public import FQChemQatlib.Dynamics.LowChuangElementary
public import Mathlib.LinearAlgebra.Matrix.Bilinear
public import Mathlib.Data.Nat.Log

/-! # Binary embeddings for standard-form input spaces of arbitrary finite size -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.Padding

open Matrix FQChemQatlib.Dynamics.LowChuang.Physical Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.BlockEncoding Qatlib.Concepts.BlockEncoding.Encoding Qatlib.Concepts.BlockEncoding.EncodingCore
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.QspSimulation.Achievability
open Qatlib.Concepts.GateVocabulary.LocalReflectionGates
open Qatlib.Concepts.BlockEncoding.Postselection.Encoding Qatlib.Papers.Qubitization19.MainResults
open scoped Matrix.Norms.L2Operator Kronecker

variable {J I K L : Type} [Fintype J] [Fintype I] [Fintype K] [Fintype L]
  [DecidableEq J] [DecidableEq I] [DecidableEq K] [DecidableEq L]

def coord (e : J ↪ K) : Matrix K J ℂ := fun x i => if x=e i then 1 else 0

omit [Fintype J] in
theorem coord_iso (e : J ↪ K) : IsIsometry (coord e) := by
  ext i j
  simp [Matrix.mul_apply,Matrix.conjTranspose_apply,coord,Matrix.one_apply,eq_comm]

/-- Extend by identity on the orthogonal complement of an isometric image. -/
def pad (E : Matrix K J ℂ) (A : Matrix J J ℂ) : Matrix K K ℂ :=
  1 + E*(A-1)*Eᴴ

private theorem pad_action (E : Matrix K J ℂ) (iso : IsIsometry E) (A : Matrix J J ℂ) :
    pad E A * E = E * A := by
  have eq : Eᴴ * E = 1 := iso
  simp only [pad,Matrix.add_mul,Matrix.one_mul,Matrix.mul_assoc,eq,Matrix.mul_one,Matrix.mul_sub]
  abel

omit [Fintype K] in
private theorem pad_star (E : Matrix K J ℂ) (A : Matrix J J ℂ) : (pad E A)ᴴ = pad E Aᴴ := by
  simp [pad,Matrix.mul_assoc]

private theorem pad_mul (E : Matrix K J ℂ) (iso : IsIsometry E) (A B : Matrix J J ℂ) :
    pad E A * pad E B = pad E (A*B) := by
  calc
    _ = pad E A + (pad E A*E)*(B-1)*Eᴴ := by simp [pad,Matrix.mul_add,Matrix.mul_assoc]
    _ = _ := by
      rw [pad_action E iso]
      simp only [pad,Matrix.mul_sub,Matrix.sub_mul,Matrix.mul_one,Matrix.mul_assoc]
      abel

theorem pad_unit (E : Matrix K J ℂ) (iso : IsIsometry E) {A : Matrix J J ℂ}
    (h : A ∈ Matrix.unitaryGroup J ℂ) : pad E A ∈ Matrix.unitaryGroup K ℂ := by
  have eq : Aᴴ*A = 1 := (Matrix.mem_unitaryGroup_iff').mp h
  rw [Matrix.mem_unitaryGroup_iff',Matrix.star_eq_conjTranspose,pad_star,pad_mul E iso,eq]
  simp [pad]

omit [Fintype K] in
theorem pad_hermitian (E : Matrix K J ℂ) {A : Matrix J J ℂ} (h : A.IsHermitian) : (pad E A).IsHermitian := by
  exact (pad_star E A).trans (congrArg (pad E) h.eq)

private theorem exp_action (E : Matrix K J ℂ) (X : Matrix K K ℂ) (Y : Matrix J J ℂ) (h : X*E=E*Y) :
    NormedSpace.exp X * E = E * NormedSpace.exp Y := by
  have powers (k : ℕ) : X^k * E = E * Y^k := by
    induction k with
    | zero => simp
    | succ k ih => rw [pow_succ,pow_succ,Matrix.mul_assoc,h,← Matrix.mul_assoc,ih,Matrix.mul_assoc]
  let R := (mulRightLinearMap K ℂ E).toContinuousLinearMap
  let L := (mulLeftLinearMap J ℂ E).toContinuousLinearMap
  change R (NormedSpace.exp X) = L (NormedSpace.exp Y)
  rw [NormedSpace.exp_eq_tsum ℂ,R.map_tsum (NormedSpace.expSeries_summable' _),NormedSpace.exp_eq_tsum ℂ,L.map_tsum (NormedSpace.expSeries_summable' _)]
  apply tsum_congr
  intro k
  simp only [map_smul]
  exact congrArg _ (powers k)

theorem evolved_action (E : Matrix K J ℂ) (iso : IsIsometry E) (H : Matrix J J ℂ) (t : ℝ) :
    hamiltonianEvolution (pad E H) t * E = E * hamiltonianEvolution H t :=
  exp_action E _ _ (by rw [Matrix.smul_mul,Matrix.mul_smul,pad_action E iso])

private theorem unpad_error (s : I ↪ L) (A : Matrix L L ℂ) (H : Matrix I I ℂ) (t : ℝ) :
    ‖compress (coord s) A (coord s) - hamiltonianEvolution H t‖ ≤
      ‖A - hamiltonianEvolution (pad (coord s) H) t‖ := by
  have iso : (coord s)ᴴ * coord s = 1 := coord_iso s
  have evolved : compress (coord s) (hamiltonianEvolution (pad (coord s) H) t) (coord s) =
      hamiltonianEvolution H t := by
    rw [compress, Matrix.mul_assoc, evolved_action _ (coord_iso s), ← Matrix.mul_assoc,
      iso, Matrix.one_mul]
  rw [← evolved]
  simpa only [compress, Matrix.mul_sub, Matrix.sub_mul] using
    compress_norm_le (coord_iso s) (coord_iso s) (A - hamiltonianEvolution (pad (coord s) H) t)

/-- A physical binary register of the ceiling-logarithmic width contains an
injective labeling of every logical basis element. -/
def physicalBasis (X : Type) [Fintype X] : X ↪ Reg (Nat.clog 2 (Fintype.card X)) :=
  Classical.choice (Function.Embedding.nonempty_iff_card_le.mpr (by
    simp only [Reg,Fintype.card_fun,Fintype.card_fin,Fintype.card_bool]
    exact Nat.le_pow_clog (by decide) _))

omit [Fintype J] [Fintype L] [DecidableEq J] [DecidableEq L] in
private theorem mul_coord (e : J ↪ K) (M : Matrix L K ℂ) (x : L) (y : J) :
    (M * coord e) x y = M x (e y) := by
  simp [Matrix.mul_apply,coord,mul_ite]

omit [Fintype J] [Fintype L] [DecidableEq J] [DecidableEq L] in
private theorem star_coord_mul (e : J ↪ K) (M : Matrix K L ℂ) (x : J) (y : L) :
    ((coord e)ᴴ * M) x y = M (e x) y := by
  simp [Matrix.mul_apply,coord,Matrix.conjTranspose_apply,ite_mul]

private theorem frame_entry (G : Matrix J J ℂ) (z j : J) (i l : I) :
    (TensorGate G (1:Matrix I I ℂ) * encodingFiber (I:=I) z) (j,i) l =
    G j z * (1:Matrix I I ℂ) i l := by
  simp [Matrix.mul_apply,Fintype.sum_prod_type,encodingFiber,tensorGate_apply,Matrix.one_apply,ite_and]

/-- The adjoint inclusion of the prepared padded frame is the original
prepared frame followed by the adjoint system inclusion. -/
private theorem prepared_restrict (j : J ↪ K) (s : I ↪ L) (z : J) (G : Matrix J J ℂ) :
    (coord (j.prodMap s))ᴴ * (TensorGate (pad (coord j) G) (1:Matrix L L ℂ) * encodingFiber (I:=L) (j z)) =
    (TensorGate G (1:Matrix I I ℂ) * encodingFiber (I:=I) z) * (coord s)ᴴ := by
  ext ⟨u,i⟩ v
  rw [star_coord_mul,show j.prodMap s (u,i)=(j u,s i) by rfl,frame_entry]
  have p := congrFun (congrFun (pad_action (coord j) (coord_iso j) G) (j u)) z
  rw [mul_coord] at p
  have entry : ((coord j) * G) (j u) z = G u z := by simp [Matrix.mul_apply,coord,ite_mul]
  rw [entry] at p
  rw [p]
  rw [Matrix.mul_apply]
  simp only [frame_entry]
  simp [coord,Matrix.conjTranspose_apply,Matrix.one_apply,mul_ite,eq_comm]
  rw [Fintype.sum_eq_single i (fun j h => by simp [Ne.symm h])]
  simp

def preparation (z : J) (G : Matrix J J ℂ) := TensorGate G (1:Matrix I I ℂ) * encodingFiber (I:=I) z

private theorem prep_iso (z : J) {G : Matrix J J ℂ} (h : G ∈ Matrix.unitaryGroup J ℂ) :
    IsIsometry (preparation (I:=I) z G) := by
  exact IsIsometry.mul
    ((Matrix.mem_unitaryGroup_iff').mp (tensorGate_unitary h (Submonoid.one_mem _)))
    (encodingFiber_isIsometry z)

theorem padded_signal (j : J ↪ K) (s : I ↪ L) (z : J) (G : Matrix J J ℂ)
    (U : Matrix (J × I) (J × I) ℂ) (hG : G ∈ Matrix.unitaryGroup J ℂ) :
    let f := preparation (I:=I) z G
    let fp := preparation (I:=L) (j z) (pad (coord j) G)
    compress fp (pad (coord (j.prodMap s)) U) fp = pad (coord s) (compress f U f) := by
  let f := preparation (I:=I) z G
  let fp := preparation (I:=L) (j z) (pad (coord j) G)
  let E := coord s
  let Z := coord (j.prodMap s)
  have h : Zᴴ*fp=f*Eᴴ := prepared_restrict j s z G
  have h' : fpᴴ*Z=E*fᴴ := by
    simpa only [Matrix.conjTranspose_mul,Matrix.conjTranspose_conjTranspose] using (congrArg Matrix.conjTranspose h)
  have full : fpᴴ * fp = 1 := prep_iso _ (pad_unit _ (coord_iso j) hG)
  have base : fᴴ * f = 1 := prep_iso _ hG
  have sub : fᴴ*(U-1)*f = compress f U f-1 := by
    rw [Matrix.mul_sub,Matrix.sub_mul,Matrix.mul_one,base,compress]
  change compress fp (pad Z U) fp = pad E (compress f U f)
  calc
    _ = fpᴴ*fp + (fpᴴ*Z)*(U-1)*(Zᴴ*fp) := by
      simp only [compress,pad,Matrix.mul_add,Matrix.add_mul,Matrix.mul_one,Matrix.mul_assoc]
    _ = 1 + E*(fᴴ*(U-1)*f)*Eᴴ := by simp only [full,h,h',Matrix.mul_assoc]
    _ = _ := by rw [sub,pad]

/-- Original finite input dimensions, including non-powers of two. Identity
extension specifies the oracle outside its encoded basis. One physical
system bit is available when there are at least two logical system states. -/
theorem finiteSimulation (z : J) (two : 1 < Fintype.card I) (t ε : ℝ) (positive : 0<ε) (small : ε<1) :
    let a := Nat.clog 2 (Fintype.card J)
    let r := Nat.clog 2 (Fintype.card I)
    let j := physicalBasis J
    let s := physicalBasis I
    let E := coord s
    ∃ q : ℕ, IsPaperCutoffQ t ε q ∧ ∃ program : List (Query.Step (Basis a r) StandardOracle),
      Query.cost StandardOracle.prepare program = 54*(64*q+1) ∧
      Query.cost StandardOracle.block program = 27*(64*q+1) ∧
      Query.fixedCount program ≤ 250*(a+4)*(27*(64*q+8)-2) ∧
      (∀ M, .fixed M ∈ program → Elementary a r M) ∧
      ∀ (G : Matrix J J ℂ) (U : Matrix (J×I) (J×I) ℂ) (H : Matrix I I ℂ),
        G ∈ Matrix.unitaryGroup J ℂ → U ∈ Matrix.unitaryGroup _ ℂ → H.IsHermitian →
        let f := preparation (I:=I) z G
        compress f U f = H →
        let M := Query.run (standardInput (pad (coord j) G) (pad (coord (j.prodMap s)) U)) program
        let R := hamiltonianFrame (encodingFiber (I:=Reg r) (j z))
        ‖compress E (compress R M R) E - hamiltonianEvolution H t‖ ≤ ε^2/2 ∧
        ∀ ψ : QState I, Normalized ψ → 1-ε^2 ≤ postselectionProbability M R R (E *ᵥ ψ) := by
  let j := physicalBasis J
  let s := physicalBasis I
  let E := coord s
  let Z := coord (j.prodMap s)
  let R := hamiltonianFrame (encodingFiber (I:=Reg (Nat.clog 2 (Fintype.card I))) (j z))
  obtain ⟨q,hq,p,cg,cu,gates,loc,corr⟩ := qubitRegisterSimulation (j z) ⟨0,Nat.clog_pos (by decide : 1<2) two⟩ t ε positive small
  refine ⟨q,hq,p,cg,cu,gates,loc,?_⟩
  intro G U H hG hU hH
  dsimp only
  intro signal
  let M := Query.run (standardInput (pad (coord j) G) (pad Z U)) p
  have out := corr (pad (coord j) G) (pad Z U) (pad E H)
    (pad_unit _ (coord_iso j) hG) (pad_unit _ (coord_iso _) hU) (pad_hermitian _ hH)
    ((padded_signal j s z G U hG).trans (congrArg (pad E) signal))
  exact ⟨(unpad_error s (compress R M R) H t).trans out.1,
    fun ψ hψ => out.2 _ (Qatlib.Concepts.BlockEncoding.Postselection.Encoding.IsIsometry.normalized_mulVec (coord_iso s) hψ)⟩

end FQChemQatlib.Dynamics.LowChuang.Padding
