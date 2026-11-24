module

public import FQChemQatlib.Dynamics.LowChuangSparseAssembly

/-! # Packing the sparse address and binary workspace into QSP registers -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Dynamics.LowChuang.SparseAssembly

open Matrix Query SparseBlock SparseWires
open Qatlib.Foundations.PureStateMath Qatlib.Concepts.QspSimulation.Achievability
open Qatlib.Concepts.LocalMachine.LocalTransport Qatlib.Concepts.CopyEvolution.Discriminate
open Qatlib.Concepts.Execution.WorkspaceCP Qatlib.Concepts.BlockEncoding.LCU
open Qatlib.Concepts.BlockEncoding.EncodingCore
open scoped Classical

variable {n m : ℕ}
variable {I J : Type} [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J]

def pack : Work (Reg n) (Reg m) ≃ Reg (n+m) × Reg n :=
  (Equiv.prodComm _ _).trans ((Fin.appendEquiv n m).prodCongr (Equiv.refl _))

def flags (e : I≃J) : (Bool×Bool×I) ≃ (Bool×Bool×J) :=
  (Equiv.refl Bool).prodCongr ((Equiv.refl Bool).prodCongr e)

theorem push_unit (e : I≃J) (U : Matrix I I ℂ) (unit : U∈Matrix.unitaryGroup _ ℂ) :
    push e U ∈ Matrix.unitaryGroup _ ℂ := by
  rw [Matrix.mem_unitaryGroup_iff',Matrix.star_eq_conjTranspose] at unit ⊢
  rw [←push_adj,←push_mul,unit,push_one]

theorem push_lifted (e : I≃J) (U : Matrix I I ℂ) : push (flags e) (lifted U)=lifted (push e U) := by
  ext ⟨b,c,i⟩ ⟨d,f,j⟩
  change lifted U (b,c,e.symm i) (d,f,e.symm j)=lifted (push e U) (b,c,i) (d,f,j)
  cases b <;> cases d <;> simp [lifted,controlOracle,parallelOracle,select,Matrix.one_apply,push]

/-- The clean position/decoder workspace is exactly the all-zero coordinate
of the standard-form ancilla register. -/
theorem packed_compression (U : Matrix (Work (Reg n) (Reg m)) (Work (Reg n) (Reg m)) ℂ) :
    let F := encodingFiber (I:=Reg n) (blank (n+m))
    compress F (push pack U) F = compress (frame (blank n) (blank m)) U (frame (blank n) (blank m)) := by
  have coordinate {L R:Type} [Fintype L] [DecidableEq L] (idx : R→L) (V : Matrix L L ℂ)
      (C : Matrix L R ℂ) (hc : ∀ l r, C l r=if l=idx r then 1 else 0) (i j:R) :
      compress C V C i j=V (idx i) (idx j) := by
    simp only [compress,Matrix.mul_apply,Matrix.conjTranspose_apply,hc,mul_one,mul_zero,
      Fintype.sum_ite_eq',apply_ite,star_one,star_zero,ite_mul,one_mul,zero_mul]
  have phy (x : Reg (n+m) × Reg n) (i : Reg n) : encodingFiber (blank (n+m)) x i=
      if x=(blank (n+m),i) then 1 else 0 := by
    rcases x with ⟨a,j⟩
    simp [encodingFiber,Prod.mk.injEq,ite_and]
  ext i j
  have nat (w : Work (Reg n) (Reg m)) (l : Reg n) : frame (blank n) (blank m) w l=
      if w=(l,blank n,blank m) then 1 else 0 := rfl
  exact (coordinate _ _ _ phy i j).trans (coordinate _ U _ nat i j).symm

theorem scaledEvolution {I:Type} [Fintype I] [DecidableEq I] (H : Matrix I I ℂ)
    (b t : ℝ) (hb : 0<b) (k : ℕ) :
    hamiltonianEvolution (((2:ℂ)*2^k)⁻¹ • ((b⁻¹:ℝ) • H)) (t*(2*2^k*b)) = hamiltonianEvolution H t := by
  unfold hamiltonianEvolution
  simp only [Complex.ofReal_mul,Complex.ofReal_ofNat,Complex.ofReal_pow]
  rw [show (b⁻¹:ℝ) • H=((b⁻¹:ℝ):ℂ) • H by rfl,smul_smul,smul_smul]
  congr 1; push_cast; field_simp [ne_of_gt hb]

end FQChemQatlib.Dynamics.LowChuang.SparseAssembly
