module

public import FQChem.Complexity.SlaterEnergy
public import Mathlib.LinearAlgebra.Matrix.SchurComplement
import Mathlib.Tactic

/-! # One- and two-body Slater contractions

A rank-one orbital move replaces q by p on each of the occupied factors
of a determinant. The exterior power of I+|p⟩⟨q| contains at most one
such replacement since two parallel output orbitals wedge to zero.
The mixed part of two moves acts on two distinct particles. -/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SlaterContraction
open Matrix exteriorPower
open scoped ComplexConjugate ComplexInnerProductSpace

variable {ι : Type*} [Fintype ι] [DecidableEq ι] {k m : ℕ}
abbrev Orbital (ι : Type*) [Fintype ι] := EuclideanSpace ℂ ι
abbrev Sector (ι : Type*) [Fintype ι] (k : ℕ) := ⋀[ℂ]^k (Orbital ι)
abbrev Frame (ι : Type*) [Fintype ι] (k : ℕ) := Fin k → Orbital ι

def ket (f : Frame ι k) : Sector ι k := ιMulti ℂ k f

def bra (f : Frame ι k) : Module.Dual ℂ (Sector ι k) :=
  pairingDual ℂ (Orbital ι) k (ιMulti ℂ k fun j => (innerSL ℂ (f j)).toLinearMap)

/-- The exact one-particle density matrix of a frame. -/
def density (f : Frame ι k) : Matrix ι ι ℂ := Matrix.of fun p q => ∑ j, f j p*conj (f j q)

def move (p q : ι) : Module.End ℂ (Orbital ι) :=
  (PiLp.projₗ 2 (fun _ : ι => ℂ) q).smulRight (EuclideanSpace.single p 1)

def lifted (p q : Fin m → ι) : Module.End ℂ (Sector ι k) :=
  exteriorPower.map k (LinearMap.id + ∑ t, move (p t) (q t))

omit [DecidableEq ι] in
theorem normalized (f : Frame ι k) (hf : Orthonormal ℂ f) : bra f (ket f)=1 := by
  rw [bra,ket,pairingDual_ιMulti_ιMulti]
  have eq : (Matrix.of fun i j : Fin k => (innerSL ℂ (f j)).toLinearMap (f i))=1 := by
    ext i j
    simp [Matrix.one_apply,orthonormal_iff_ite.mp hf,eq_comm]
  rw [eq,det_one]

/-- Finite-rank exterior overlap. Each orbital move requires one row and
one column in the determinant on the right. -/
theorem overlap (f : Frame ι k) (hf : Orthonormal ℂ f) (p q : Fin m → ι) :
    bra f (lifted p q (ket f)) = det (1+Matrix.of fun a b => density f (q b) (p a)) := by
  let A : Matrix (Fin k) (Fin m) ℂ := Matrix.of fun i t => f i (q t)
  let B : Matrix (Fin m) (Fin k) ℂ := Matrix.of fun t j => conj (f j (p t))
  have left : (Matrix.of fun i j : Fin k => (innerSL ℂ (f j)).toLinearMap
       ((LinearMap.id + ∑ t, move (p t) (q t) : Module.End ℂ (Orbital ι)) (f i)))=1+A*B := by
    ext i j
    simp [A,B,move,Matrix.mul_apply,Matrix.one_apply,LinearMap.sum_apply,
      inner_add_right,inner_sum,inner_smul_right,EuclideanSpace.inner_single_right,orthonormal_iff_ite.mp hf,eq_comm]
  have right : B*A=Matrix.of fun a b => density f (q b) (p a) := by
    ext a b
    simp [B,A,density,Matrix.mul_apply,mul_comm]
  rw [bra,lifted,ket,exteriorPower.map_apply_ιMulti,pairingDual_ιMulti_ιMulti]
  exact (congrArg det left).trans ((det_one_add_mul_comm A B).trans (congrArg (fun T : Matrix (Fin m) (Fin m) ℂ => det (1+T)) right))

section Occupation
variable [LinearOrder ι]

def occupationBasis (k : ℕ) := (EuclideanSpace.basisFun ι ℂ).toBasis.exteriorPower k

/-- The exterior dual used here is precisely the conjugate Slater bra in
the computational occupation basis. -/
theorem braCoefficient (f : Frame ι k) (s : Set.powersetCard ι k) :
    bra f (occupationBasis (ι:=ι) k s) = conj ((occupationBasis (ι:=ι) k).repr (ket f) s) := by
  let e := Set.powersetCard.ofFinEmbEquiv.symm s
  let N := Matrix.of fun i j : Fin k => f i (e j)
  unfold occupationBasis
  rw [exteriorPower.basis_apply,bra,ιMulti_family,pairingDual_ιMulti_ιMulti,exteriorPower.basis_repr_apply,ket,ιMultiDual_apply_ιMulti]
  simp only [Function.comp_apply,OrthonormalBasis.coe_toBasis,EuclideanSpace.basisFun_apply,
    Module.Basis.coord_apply,OrthonormalBasis.coe_toBasis_repr_apply,EuclideanSpace.basisFun_repr]
  change (Matrix.of fun i j : Fin k => inner ℂ (f j) (EuclideanSpace.single (e i) 1)).det = conj N.det
  calc
    _ = Nᴴ.det := by congr 1; ext i j; simp [N,EuclideanSpace.inner_single_right]
    _ = _ := Matrix.det_conjTranspose _

theorem physicalBra (f : Frame ι k) (v : Sector ι k) :
    bra f v = ∑ s, conj ((occupationBasis (ι:=ι) k).repr (ket f) s) * (occupationBasis k).repr v s := by
  let b := occupationBasis (ι:=ι) k
  conv_lhs => rw [←b.sum_repr v]
  simp only [map_sum,map_smul,smul_eq_mul,b,braCoefficient]
  apply Finset.sum_congr rfl; intro i _; ring

end Occupation

def one (k : ℕ) (p q : ι) : Module.End ℂ (Sector ι k) :=
  lifted (m:=1) (fun _ => p) (fun _ => q) - LinearMap.id

def two (k : ℕ) (p q r s : ι) : Module.End ℂ (Sector ι k) :=
  lifted ![p,r] ![q,s] - one k p q - one k r s - LinearMap.id

theorem oneBody (f : Frame ι k) (hf : Orthonormal ℂ f) (p q : ι) :
    bra f (one k p q (ket f))=density f q p := by
  simp only [one,LinearMap.sub_apply,map_sub,LinearMap.id_apply,overlap f hf,normalized f hf]
  simp

theorem twoBody (f : Frame ι k) (hf : Orthonormal ℂ f) (p q r s : ι) :
    bra f (two k p q r s (ket f))=density f q p*density f s r-density f s p*density f q r := by
  simp only [two,LinearMap.sub_apply,map_sub,LinearMap.id_apply,overlap f hf,oneBody f hf,normalized f hf]
  simp [det_fin_two]
  ring

def coordinate (occ : Fin k ↪ ι) : Frame ι k := fun j => EuclideanSpace.single (occ j) 1

private theorem rankOneBasis (occ : Fin k ↪ ι) (i : Fin k) (p : ι) (j : Fin k) :
    move p (occ i) (coordinate occ j) =
      if j=i then EuclideanSpace.single p 1 else 0 := by
  by_cases eq : j=i
  · simp [eq,coordinate,move]
  · have ne : occ i≠occ j := fun e => eq (occ.injective e).symm
    simp [coordinate,move,eq,ne]

/-- On every occupied coordinate mode, the lifted one-body operator replaces
that orbital in its original ordered slot. Antisymmetry supplies the sign. -/
theorem oneAction (occ : Fin k ↪ ι) (i : Fin k) (p : ι) :
    one k p (occ i) (ket (coordinate occ)) =
      ket (Function.update (coordinate occ) i (EuclideanSpace.single p 1)) := by
  let f := coordinate occ
  simp only [one,lifted,ket,LinearMap.sub_apply,LinearMap.id_apply,map_apply_ιMulti,
    Fin.sum_univ_one]
  have eq : (⇑(LinearMap.id+move p (occ i) : Module.End ℂ (Orbital ι)) ∘ f) =
      Function.update f i (f i+EuclideanSpace.single p 1) := by
    funext j
    by_cases e : j=i <;> simp [f,Function.comp_apply,rankOneBasis,e,Function.update]
  rw [eq,AlternatingMap.map_update_add,Function.update_eq_self]
  abel

omit [DecidableEq ι] in
private theorem ket_update_pair (f : Frame ι k) {a b : Fin k} (ab : a≠b) (x y : Orbital ι) :
    ket (Function.update (Function.update f a (f a+x)) b (f b+y)) =
      ket f + ket (Function.update f a x) + ket (Function.update f b y) +
      ket (Function.update (Function.update f a x) b y) := by
  unfold ket
  rw [AlternatingMap.map_update_add,show f b=(Function.update f a (f a+x)) b from
    (Function.update_of_ne ab.symm _ _).symm,Function.update_eq_self,
    AlternatingMap.map_update_add,Function.update_eq_self,
    Function.update_comm ab,AlternatingMap.map_update_add,
    show f a=(Function.update f b y) a from (Function.update_of_ne ab _ _).symm,Function.update_eq_self]
  rw [Function.update_comm ab.symm]
  abel

/-- The mixed operator replaces two occupied orbitals in distinct ordered
slots, as the normal-ordered two-body term does on a basis determinant. -/
theorem twoAction (occ : Fin k ↪ ι) {a b : Fin k} (ab : a≠b) (p r : ι) :
    two k p (occ a) r (occ b) (ket (coordinate occ)) =
      ket (Function.update (Function.update (coordinate occ) a (EuclideanSpace.single p 1))
        b (EuclideanSpace.single r 1)) := by
  let f := coordinate occ
  let P := EuclideanSpace.single (𝕜:=ℂ) p 1
  let R := EuclideanSpace.single (𝕜:=ℂ) r 1
  have full : (⇑(LinearMap.id+(move p (occ a)+move r (occ b)) : Module.End ℂ (Orbital ι)) ∘ f) =
      Function.update (Function.update f a (f a+P)) b (f b+R) := by
    funext j
    by_cases A : j=a <;> by_cases B : j=b <;> simp_all [f,P,R,rankOneBasis,Function.update]
  simp only [two,LinearMap.sub_apply,LinearMap.id_apply,oneAction]
  have eq : lifted ![p,r] ![occ a,occ b] (ket f) =
      ket (Function.update (Function.update f a (f a+P)) b (f b+R)) := by
    simp only [lifted,ket,map_apply_ιMulti,Fin.sum_univ_two,Matrix.cons_val_zero,Matrix.cons_val_one,
      Matrix.cons_val_fin_one]
    rw [full]
  rw [eq,ket_update_pair f ab]
  change _ = ket (Function.update (Function.update f a P) b R)
  abel

private theorem absent_move (occ : Fin k ↪ ι) (p q : ι) (absent : ∀ i, occ i≠q) (j : Fin k) :
    move p q (coordinate occ j)=0 := by
  simp [move,coordinate,Ne.symm (absent j)]

/-- Annihilation of an absent mode gives zero. -/
theorem oneAbsent (occ : Fin k ↪ ι) (p q : ι) (absent : ∀ j, occ j≠q) :
    one k p q (ket (coordinate occ))=0 := by
  simp only [one,lifted,ket,LinearMap.sub_apply,LinearMap.id_apply,map_apply_ιMulti,Fin.sum_univ_one]
  rw [sub_eq_zero]
  congr 1
  funext j
  simp [absent_move occ p q absent]

private theorem twoSymm (p q r s : ι) : two k p q r s=two k r s p q := by
  unfold two lifted
  simp only [Fin.sum_univ_two,Matrix.cons_val_zero,Matrix.cons_val_one,Matrix.cons_val_fin_one]
  rw [add_comm (move p q)]
  abel

/-- A missing source mode makes the normally ordered pair excitation vanish. -/
theorem twoAbsent (occ : Fin k ↪ ι) (p q r s : ι) (absent : (∀ j, occ j≠q) ∨ (∀ j, occ j≠s)) :
    two k p q r s (ket (coordinate occ))=0 := by
  have missing (p q r s : ι) (abs : ∀ j, occ j≠q) :
      two k p q r s (ket (coordinate occ))=0 := by
    simp only [two,LinearMap.sub_apply,LinearMap.id_apply,oneAbsent occ p q abs,sub_zero]
    simp only [one,LinearMap.sub_apply,LinearMap.id_apply,lifted,ket,
      map_apply_ιMulti,Fin.sum_univ_two,Matrix.cons_val_zero,Matrix.cons_val_one,Matrix.cons_val_fin_one,Fin.sum_univ_one]
    have same : (⇑(LinearMap.id+(move p q+move r s) : Module.End ℂ (Orbital ι)) ∘ coordinate occ)=
        (⇑(LinearMap.id+move r s : Module.End ℂ (Orbital ι)) ∘ coordinate occ) := by
      funext j; simp [absent_move occ p q abs]
    rw [same]
    abel
  rcases absent with h|h
  · exact missing p q r s h
  · rw [twoSymm]; exact missing r s p q h

/-- Two annihilations of the same occupied mode vanish even when their target
modes differ. -/
theorem twoRepeated (occ : Fin k ↪ ι) (j : Fin k) (p r : ι) :
    two k p (occ j) r (occ j) (ket (coordinate occ))=0 := by
  let f := coordinate occ
  let P := EuclideanSpace.single (𝕜:=ℂ) p 1
  let R := EuclideanSpace.single (𝕜:=ℂ) r 1
  have full : (⇑(LinearMap.id+(move p (occ j)+move r (occ j)) : Module.End ℂ (Orbital ι)) ∘ f)=
      Function.update f j (f j+(P+R)) := by
    funext i
    by_cases h : i=j <;> simp [f,P,R,rankOneBasis,Function.update,h]
  simp only [two,LinearMap.sub_apply,LinearMap.id_apply,oneAction]
  simp only [lifted,ket,map_apply_ιMulti,
    Fin.sum_univ_two,Matrix.cons_val_zero,Matrix.cons_val_one,Matrix.cons_val_fin_one]
  rw [full,AlternatingMap.map_update_add,Function.update_eq_self,AlternatingMap.map_update_add]
  dsimp only [f,P,R]
  abel

/-- General one- and two-body operator in the finite orbital basis. The
two-body integral includes any conventional double-counting prefactor. -/
def hamiltonian (k : ℕ) (h : ι → ι → ℂ) (u : ι → ι → ι → ι → ℂ) : Module.End ℂ (Sector ι k) :=
  (∑ p, ∑ q, h p q • one k p q)+(∑ p, ∑ q, ∑ r, ∑ s, u p q r s • two k p q r s)

def score (P : Matrix ι ι ℂ) (h : ι → ι → ℂ) (u : ι → ι → ι → ι → ℂ) :=
  (∑ p, ∑ q, h p q*P q p)+(∑ p, ∑ q, ∑ r, ∑ s, u p q r s*(P q p*P s r-P s p*P q r))

theorem energy (f : Frame ι k) (hf : Orthonormal ℂ f) (h : ι → ι → ℂ) (u : ι → ι → ι → ι → ℂ) :
    bra f (hamiltonian k h u (ket f))=score (density f) h u := by
  simp [hamiltonian,score,LinearMap.sum_apply,oneBody f hf,twoBody f hf]

end FQChem.Complexity.SlaterContraction
