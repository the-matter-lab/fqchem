module

public import FQChem.Complexity.SlaterCertificate
public import Mathlib.NumberTheory.Zsqrtd.GaussianInt
import Mathlib.Data.Nat.Size
import Mathlib.Tactic

/-! # Executable finite-precision Slater verifier

One- and two-electron inputs have signed Gaussian integer numerators over
one positive common denominator. The witness has two integer coordinates
per occupied-orbital coefficient. The verifier tests integer squared norms,
and evaluates the real energy by exact integer products and sums. -/

@[expose] public section
namespace FQChem.Complexity.SlaterIntegerVerifier
open Matrix SlaterCertificate SlaterContraction
open scoped ComplexConjugate Matrix.Norms.L2Operator
local notation "ℤ[i]" => GaussianInt
variable {d k : ℕ}

def raw (a : Digits d k) (p : Fin d) (i : Fin k) : ℤ[i] := ⟨a.re p i,a.im p i⟩

def projector (a : Digits d k) (p q : Fin d) : ℤ[i] :=
  ∑ j, raw a p j*star (raw a q j)

def residual (D : ℕ) (a : Digits d k) (i j : Fin k) : ℤ[i] :=
  (∑ p, star (raw a p i)*raw a p j) - if i=j then (D:ℤ[i])^2 else 0

structure Integrals (d : ℕ) where
  common : ℕ
  common_pos : 0<common
  h : Fin d → Fin d → ℤ[i]
  u : Fin d → Fin d → Fin d → Fin d → ℤ[i]

noncomputable def Integrals.oneBody (I : Integrals d) (p q : Fin d) : ℂ := I.h p q / (I.common:ℂ)
noncomputable def Integrals.twoBody (I : Integrals d) (p q r s : Fin d) : ℂ :=
  I.u p q r s / (I.common:ℂ)

def integerScore (I : Integrals d) (D : ℕ) (a : Digits d k) : ℤ[i] :=
  (D:ℤ[i])^2*(∑ p, ∑ q, I.h p q*projector a q p) +
    ∑ p, ∑ q, ∑ r, ∑ s, I.u p q r s*
      (projector a q p*projector a s r-projector a s p*projector a q r)

def rationalScore (I : Integrals d) (D : ℕ) (a : Digits d k) : ℚ :=
  ((integerScore I D a).re:ℚ)/(I.common*D^4:ℕ)

def accept (I : Integrals d) (D M : ℕ) (lo : ℚ) (a : Digits d k) : Bool :=
  decide (∀ i j, |a.re i j|≤(D:ℤ) ∧ |a.im i j|≤(D:ℤ)) &&
  decide (∀ i j, (residual D a i j).norm ≤ (8*(d:ℤ)*D)^2) &&
  decide (rationalScore I D a ≤ lo+(constant d k M:ℚ)*(2/D))

private theorem decode_raw (D : ℕ) (a : Digits d k) (p j) :
    a.decode D p j = (raw a p j : ℂ)/(D:ℂ) := by
  rw [GaussianInt.toComplex_def₂]
  apply Complex.ext <;> simp [Digits.decode,raw,Complex.div_natCast_re,Complex.div_natCast_im]

private theorem proj_spec (D : ℕ) (a : Digits d k) (p q) :
    density (frame (a.decode D)) p q = (GaussianInt.toComplex (projector a p q))/(D:ℂ)^2 := by
  simp only [density,Matrix.of_apply,frame,WithLp.ofLp_toLp,decode_raw,projector,map_sum,map_mul,GaussianInt.toComplex_star]
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl; intro j _
  simp [mul_div_mul_comm, sq, GaussianInt.toComplex]

private theorem residual_spec (D : ℕ) (hD : 0<D) (a : Digits d k) (i j) :
    ((a.decode D)ᴴ*(a.decode D)-1 : Matrix (Fin k) (Fin k) ℂ) i j =
      (GaussianInt.toComplex (residual D a i j))/(D:ℂ)^2 := by
  have ne : (D:ℂ)≠0 := by exact_mod_cast Nat.ne_of_gt hD
  simp only [Matrix.sub_apply,Matrix.mul_apply,Matrix.conjTranspose_apply,decode_raw,residual,map_sub,map_sum,map_mul,GaussianInt.toComplex_star]
  rw [sub_div,Finset.sum_div]
  congr 1
  · apply Finset.sum_congr rfl; intro p _
    simp [div_mul_div_comm,sq,GaussianInt.toComplex]
  · by_cases e : i=j <;> simp [Matrix.one_apply,e,ne]

theorem gram_test (D : ℕ) (hD : 0<D) (a : Digits d k) (i j) :
    (residual D a i j).norm ≤ (8*(d:ℤ)*D)^2 ↔
      ‖((a.decode D)ᴴ*(a.decode D)-1 : Matrix (Fin k) (Fin k) ℂ) i j‖≤8*d/D := by
  have pos : 0<(D:ℝ) := by exact_mod_cast hD
  rw [residual_spec D hD,norm_div,norm_pow,Complex.norm_natCast]
  have eq : ((residual D a i j).norm:ℝ)=‖GaussianInt.toComplex (residual D a i j)‖^2 := by
    rw [GaussianInt.intCast_real_norm,Complex.sq_norm]
  rw [show ‖GaussianInt.toComplex (residual D a i j)‖ / (D:ℝ)^2 ≤ 8*d/D ↔
      ‖GaussianInt.toComplex (residual D a i j)‖ ≤ 8*d*D by
      rw [div_le_div_iff₀ (by positivity) pos]; constructor <;> intro h <;>
        nlinarith [mul_pos pos (show 0<(D:ℝ)^2 by positivity)]]
  rw [←sq_le_sq₀ (norm_nonneg _) (by positivity),←eq]
  exact_mod_cast Iff.rfl

private theorem score_spec (I : Integrals d) (D : ℕ) (hD : 0<D) (a : Digits d k) :
    score (density (frame (a.decode D))) I.oneBody I.twoBody =
      GaussianInt.toComplex (integerScore I D a)/(I.common*(D:ℂ)^4) := by
  have ne : (D:ℂ)≠0 := by exact_mod_cast Nat.ne_of_gt hD
  simp only [score,proj_spec,Integrals.oneBody,Integrals.twoBody,integerScore,map_add,map_mul,map_pow,
    map_natCast,map_sum,map_sub]
  rw [add_div,Finset.mul_sum]
  congr 1
  · rw [Finset.sum_div]; apply Finset.sum_congr rfl; intro p _
    rw [Finset.mul_sum,Finset.sum_div]; apply Finset.sum_congr rfl; intro q _
    rw [div_mul_div_comm]
    field_simp [ne]
  · simp_rw [Finset.sum_div]
    apply Finset.sum_congr rfl; intro p _
    apply Finset.sum_congr rfl; intro q _
    apply Finset.sum_congr rfl; intro r _
    apply Finset.sum_congr rfl; intro s _
    simp only [div_mul_div_comm,←sub_div]
    rw [show (D:ℂ)^2*D^2=D^4 by ring]

theorem energy_test (I : Integrals d) (D : ℕ) (hD : 0<D) (a : Digits d k) :
    (rationalScore I D a:ℝ)=(score (density (frame (a.decode D))) I.oneBody I.twoBody).re := by
  rw [score_spec I D hD]
  unfold rationalScore
  push_cast
  rw [show (I.common:ℂ)*D^4=((I.common*(D:ℕ)^4:ℕ):ℂ) by push_cast; rfl,Complex.div_natCast_re]
  push_cast
  rw [GaussianInt.intCast_re]

theorem accept_iff (I : Integrals d) (D M : ℕ) (hd : 0<D) (lo : ℚ) (a : Digits d k) :
    accept I D M lo a=true ↔ passes I.oneBody I.twoBody D M (lo:ℝ) a := by
  simp only [accept,Bool.and_eq_true,decide_eq_true_eq,passes,Digits.bounded,and_assoc,gram_test D hd]
  apply and_congr_right; intro _
  apply and_congr_right; intro _
  rw [←energy_test I D hd]
  rw [show energyConstant d k (M:ℝ)=(constant d k M:ℝ) by simp [energyConstant,constant] ]
  have cast : ((lo+(constant d k M:ℚ)*(2/D):ℚ):ℝ)=(lo:ℝ)+(constant d k M:ℝ)*(2/D) := by push_cast; rfl
  rw [←cast,Rat.cast_le]

/-- A fixed-length certificate consists of two unsigned bit words per
occupied orbital entry. An offset of D represents signed integers. -/
abbrev Witness (d k D : ℕ) := Fin d → Fin k → Bool → BitVec (2*D).size

def unpack (D : ℕ) (w : Witness d k D) : Digits d k :=
  ⟨fun i j => ((w i j false).toNat:ℤ)-D,fun i j => ((w i j true).toNat:ℤ)-D⟩

private theorem pack (D : ℕ) (a : Digits d k) (h : a.bounded D) :
    ∃ w : Witness d k D, unpack D w = a := by
  let z (i : Fin d) (j : Fin k) (s : Bool) := if s then a.im i j else a.re i j
  let w : Witness d k D := fun i j s => BitVec.ofNat (2*D).size ((z i j s)+D).toNat
  have hword i j s : ((w i j s).toNat:ℤ)=z i j s+D := by
    have hcomp : |z i j s|≤D := by cases s <;> simp [z,(h i j).1,(h i j).2]
    have bounds := abs_le.mp hcomp
    have low : 0≤z i j s+D := by omega
    have top : (z i j s+D).toNat≤2*D := by omega
    simp [w,BitVec.toNat_ofNat,Nat.mod_eq_of_lt (top.trans_lt (Nat.lt_size_self _)),Int.toNat_of_nonneg low]
  refine ⟨w,?_⟩
  cases a
  unfold unpack
  congr 1 <;> funext i j <;> simp only [hword,z] <;> simp

def verify (I : Integrals d) (M t : ℕ) (lo : ℚ) (w : Witness d k (denominator d k M t)) : Bool :=
  let D := denominator d k M t
  accept I D M lo (unpack D w)

/-- Completeness and soundness for an arbitrary encoded one- and two-body
Hamiltonian, with its exact expectation on normalized exterior determinants. -/
theorem verifies (I : Integrals d) (M t : ℕ) (ht : 0<t) (lo hi : ℚ) (gap : 1/(t:ℚ)≤hi-lo)
    (hh : ∀ p q, ‖I.oneBody p q‖≤M) (hu : ∀ p q r s, ‖I.twoBody p q r s‖≤M) :
    ((∃ f : Frame (Fin d) k, Orthonormal ℂ f ∧
       (bra f (hamiltonian k I.oneBody I.twoBody (ket f))).re≤(lo:ℝ)) →
      ∃ w : Witness d k (denominator d k M t), verify I M t lo w=true) ∧
    ((∀ f : Frame (Fin d) k, Orthonormal ℂ f →
       (hi:ℝ)≤(bra f (hamiltonian k I.oneBody I.twoBody (ket f))).re) →
      ∀ w : Witness d k (denominator d k M t), verify I M t lo w=false) := by
  let D := denominator d k M t
  have pos : 0<D := by dsimp [D,denominator]; omega
  constructor
  · rintro ⟨f,hf,low⟩
    obtain ⟨a,ha⟩ := completeness I.oneBody I.twoBody D M pos (lo:ℝ) hh hu f hf low
    obtain ⟨w,hw⟩ := pack D a ha.1
    exact ⟨w, (accept_iff I D M pos lo _).mpr (hw.symm ▸ ha)⟩
  · intro no w
    by_contra! yes
    have good := (accept_iff I D M pos lo (unpack D w)).mp (Bool.eq_true_of_not_eq_false yes)
    have gapR : ((1/(t:ℚ):ℚ):ℝ)≤((hi-lo:ℚ):ℝ) := Rat.cast_le.mpr gap
    push_cast at gapR
    obtain ⟨f,hf,_,less⟩ := soundness I.oneBody I.twoBody M t ht lo hi gapR hh hu _ good
    exact (not_lt_of_ge (no f hf)) less

/-- If d,k,M,t each fit b bits, each of the 2dk witness integers fits
13+12b bits, regardless of the dimension of the many-body sector. -/
theorem witnessWidth (d k M t b : ℕ) (hd : d≤2^b) (hk : k≤2^b) (hM : M≤2^b) (ht : t≤2^b) :
    (2*denominator d k M t).size≤13+12*b := by
  let K := 2^b
  have one : 1≤K := Nat.one_le_two_pow
  have c : constant d k M≤68*K^7 := by
    calc
      _ ≤ K^2*K*(4*K)+K^4*K*(64*K^2) := by unfold constant; gcongr
      _ = 4*K^4+64*K^7 := by ring
      _ ≤ _ := by nlinarith [Nat.pow_le_pow_right one (by decide : 4≤7)]
  have a : 2+32*d*k^3≤34*K^4 := by
    calc
      _ ≤ 2+32*K*K^3 := by gcongr
      _ ≤ _ := by nlinarith [Nat.one_le_pow 4 K (by omega)]
  have g : denominator d k M t≤2330*K^12 := by
    calc
      _ ≤ 1+16*K*K^2+K*(68*K^7)*(34*K^4) := by unfold denominator; gcongr
      _ = 1+16*K^3+2312*K^12 := by ring
      _ ≤ _ := by nlinarith [Nat.pow_le_pow_right one (by decide : 3≤12),Nat.one_le_pow 12 K (by omega)]
  apply Nat.size_le.mpr
  rw [pow_add,Nat.mul_comm 12 b,pow_mul]
  change 2*denominator d k M t < 8192*K^12
  nlinarith [Nat.one_le_pow 12 K (by omega)]

end FQChem.Complexity.SlaterIntegerVerifier
