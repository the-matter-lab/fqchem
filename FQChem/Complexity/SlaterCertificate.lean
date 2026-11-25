module

public import FQChem.Complexity.SlaterContraction
public import FQChem.Complexity.FixedBasisOrthonormalization
import Mathlib.Tactic

/-! # Quantitative finite orbital certificates

The certificate stores approximations to occupied orbitals and checks their
Gram matrix entrywise. Symmetric orthonormalization produces a genuine
exterior determinant close to any accepted approximately orthonormal frame.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SlaterCertificate
open Matrix SlaterContraction FixedBasisOrthonormalization
open scoped ComplexConjugate ComplexInnerProductSpace Matrix.Norms.L2Operator
variable {d k : ℕ}

abbrev Coeff (d k : ℕ) := Matrix (Fin d) (Fin k) ℂ

def frame (B : Coeff d k) : Frame (Fin d) k := fun j => WithLp.toLp 2 fun i => B i j

theorem gram_iff (B : Coeff d k) : Orthonormal ℂ (frame B) ↔ Bᴴ*B=1 := by
  rw [orthonormal_iff_ite]
  constructor
  · intro h; ext i j
    simpa [frame,PiLp.inner_apply,Matrix.mul_apply,Matrix.one_apply,mul_comm] using h i j
  · intro h i j
    simpa [frame,PiLp.inner_apply,Matrix.mul_apply,Matrix.one_apply,mul_comm] using congrFun (congrFun h i) j

private theorem sumBound {n : ℕ} (v : Fin n → ℂ) (C : ℝ) (h : ∀ i, ‖v i‖≤C) :
    ‖∑ i, v i‖≤n*C := by
  simpa using norm_sum_le_of_le Finset.univ fun i _ => h i

private theorem vectorBound {n : ℕ} (x : Orbital (Fin n)) :
    ‖x‖≤∑ i, ‖x i‖ := by
  let e := (EuclideanSpace.basisFun (Fin n) ℂ).toBasis
  calc
    _ = ‖∑ i, e.repr x i • e i‖ := by rw [e.sum_repr]
    _ ≤ _ := by simpa [e,norm_smul] using norm_sum_le Finset.univ (fun i => e.repr x i • e i)

theorem matrixNorm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℂ) (C : ℝ) (hC : 0≤C)
    (h : ∀ i j, ‖A i j‖≤C) : ‖A‖≤n*n*C := by
  rw [←l2_opNorm_toEuclideanCLM]
  refine ContinuousLinearMap.opNorm_le_bound _ (by positivity) fun x => ?_
  refine (vectorBound _).trans ?_
  have ev i : (toEuclideanCLM (𝕜:=ℂ) A x) i=∑ j, A i j*x j := rfl
  simp_rw [ev]
  calc
    _ ≤ ∑ _i : Fin n, ((n:ℝ)*(C*‖x‖)) := Finset.sum_le_sum fun i _ =>
        sumBound _ _ fun j => by rw [norm_mul]; exact mul_le_mul (h i j) (PiLp.norm_apply_le x j) (norm_nonneg _) hC
    _ = _ := by simp; ring

theorem entryNorm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℂ) (i j : Fin n) : ‖A i j‖≤‖A‖ := by
  let x : EuclideanSpace ℂ (Fin n) := EuclideanSpace.single j 1
  have ev : (toEuclideanCLM (𝕜:=ℂ) A x) i=A i j := by
    change (A *ᵥ (Pi.single j 1)) i = _
    simp
  rw [←ev]
  exact (PiLp.norm_apply_le _ _).trans (by simpa [x,l2_opNorm_toEuclideanCLM] using
    ((toEuclideanCLM (𝕜:=ℂ) A).le_opNorm x))

private theorem entry_of_unit (f : Frame (Fin d) k) (h : Orthonormal ℂ f) (i : Fin d) (j : Fin k) :
    ‖f j i‖≤1 := (PiLp.norm_apply_le _ i).trans (h.norm_eq_one j).le

private theorem productError {a b c e : ℂ} {r v M : ℝ} (ha : ‖a‖≤M) (he : ‖e‖≤M)
    (h₁ : ‖a-c‖≤r) (h₂ : ‖b-e‖≤v) :
    ‖a*b-c*e‖≤M*v+r*M := by
  rw [show a*b-c*e=a*(b-e)+(a-c)*e by ring]
  calc
    _ ≤ ‖a*(b-e)‖ + ‖(a-c)*e‖ := norm_add_le _ _
    _ ≤ _ := by rw [norm_mul,norm_mul]; gcongr <;> first | exact (norm_nonneg _).trans ha | exact (norm_nonneg _).trans h₁

/-- Energy error caused by an entrywise perturbation of occupied orbital
coefficients. Each frame entry has modulus at most 2. -/
def energyConstant (d k : ℕ) (M : ℝ) := (d:ℝ)^2*M*(4*k)+(d:ℝ)^4*M*(64*(k:ℝ)^2)

theorem score_error (f g : Frame (Fin d) k) (h : Fin d → Fin d → ℂ)
    (u : Fin d → Fin d → Fin d → Fin d → ℂ) (M e : ℝ)
    (hn : ∀ i j, ‖f j i‖≤2 ∧ ‖g j i‖≤2 ∧ ‖f j i-g j i‖≤e)
    (hh : ∀ p q, ‖h p q‖≤M) (hu : ∀ p q r s, ‖u p q r s‖≤M) :
    ‖score (density f) h u-score (density g) h u‖≤energyConstant d k M*e := by
  let K : ℝ := k
  have dens (v : Frame (Fin d) k) (hv : ∀ i j, ‖v j i‖≤2) (p q : Fin d) :
      ‖density v p q‖≤4*K := by
    calc
      _ ≤ (k:ℝ)*4 := sumBound _ _ fun j => by
        rw [norm_mul, Complex.norm_conj]
        simpa only [show (2:ℝ)*2 = 4 by norm_num] using
          mul_le_mul (hv p j) (hv q j) (norm_nonneg _) (by norm_num)
      _ = _ := mul_comm _ _
  have err (p q : Fin d) : ‖density f p q-density g p q‖≤4*K*e := by
    change ‖(∑ j : Fin k, f j p*conj (f j q)) - ∑ j : Fin k, g j p*conj (g j q)‖≤_
    rw [←Finset.sum_sub_distrib]
    calc
      _ ≤ (k:ℝ)*(2*e+e*2) := sumBound _ _ fun j => productError
        (hn p j).1 (by simpa using (hn q j).2.1) (hn p j).2.2
        (by simpa [←map_sub] using (hn q j).2.2)
      _ = _ := by dsimp [K];ring
  have cross (p q r s : Fin d) :
      ‖density f p q*density f r s-density g p q*density g r s‖≤32*K^2*e := by
    calc
      _ ≤ (4*K)*(4*K*e)+(4*K*e)*(4*K) := productError (dens f (fun a b => (hn a b).1) p q)
        (dens g (fun a b => (hn a b).2.1) r s) (err p q) (err r s)
      _ = _ := by ring
  have part1 p q : ‖h p q*density f q p-h p q*density g q p‖≤M*(4*K*e) := by
    rw [←mul_sub,norm_mul]; exact mul_le_mul (hh _ _) (err _ _) (norm_nonneg _) ((norm_nonneg _).trans (hh p q))
  have part2 p q r s : ‖u p q r s*(density f q p*density f s r-density f s p*density f q r)-
      u p q r s*(density g q p*density g s r-density g s p*density g q r)‖≤M*(64*K^2*e) := by
    rw [←mul_sub,sub_sub_sub_comm,norm_mul]
    apply mul_le_mul (hu _ _ _ _) _ (norm_nonneg _) ((norm_nonneg _).trans (hu p q r s))
    exact (norm_sub_le _ _).trans (by linarith [cross q p s r,cross s p q r])
  unfold score
  rw [add_sub_add_comm]
  simp_rw [←Finset.sum_sub_distrib]
  calc
    _ ≤ _ := norm_add_le _ _
    _ ≤ (d:ℝ)*(d*(M*(4*K*e)))+d*(d*(d*(d*(M*(64*K^2*e))))) :=
      add_le_add (sumBound _ _ fun p => sumBound _ _ fun q => part1 p q)
        (sumBound _ _ fun p => sumBound _ _ fun q => sumBound _ _ fun r => sumBound _ _ fun s => part2 p q r s)
    _ = _ := by dsimp [K,energyConstant]; ring

/-- Every frame passing the finite Gram check lies near an actual orthonormal
frame. The correction is only needed to prove soundness of the certificate. -/
theorem corrected (B : Coeff d k) (z : ℝ) (hz : 0≤z) (hB : ∀ i j, ‖B i j‖≤2)
    (hg : ∀ i j, ‖(Bᴴ*B-1 : Matrix (Fin k) (Fin k) ℂ) i j‖≤z) (small : (k:ℝ)*k*z≤1/2) :
    ∃ f : Frame (Fin d) k, Orthonormal ℂ f ∧
      ∀ i j, ‖f j i-B i j‖≤4*k*((k:ℝ)*k*z) := by
  let S := Bᴴ*B
  let δ := (k:ℝ)*k*z
  let R := transform S (isHermitian_conjTranspose_mul_self B)
  have close : ‖S-1‖≤δ := matrixNorm _ z hz hg
  have unit := orthonormalColumns B δ close small
  obtain ⟨_,_,near⟩ := globalTransform S _ δ close small
  refine ⟨frame (B*R),(gram_iff _).mpr unit,?_⟩
  intro i j
  change ‖(B*R) i j-B i j‖≤_
  have eq : (B*R) i j-B i j=(B*(R-1) : Coeff d k) i j := by simp [Matrix.mul_sub]
  rw [eq,Matrix.mul_apply]
  calc
    _ ≤ (k:ℝ)*(2*(2*δ)) := sumBound _ _ fun a => by
      rw [norm_mul]
      exact mul_le_mul (hB i a) ((entryNorm (R-1) a j).trans near) (norm_nonneg _) (by norm_num)
    _ = _ := by dsimp [δ];ring

structure Digits (d k : ℕ) where
  re : Fin d → Fin k → ℤ
  im : Fin d → Fin k → ℤ

def Digits.bounded (D : ℕ) (a : Digits d k) :=
  ∀ i j, |a.re i j|≤D ∧ |a.im i j|≤D

def Digits.decode (D : ℕ) (a : Digits d k) : Coeff d k :=
  Matrix.of fun i j => ⟨(a.re i j : ℝ)/D,(a.im i j : ℝ)/D⟩

private theorem floor_bound (D : ℕ) (y : ℝ) (hy : |y|≤1) : |⌊D*y⌋|≤(D:ℤ) := by
  obtain ⟨lo, hi⟩ := abs_le.mp hy
  have nonneg : 0 ≤ (D:ℝ) := Nat.cast_nonneg D
  apply abs_le.mpr
  constructor
  · apply Int.le_floor.mpr
    simpa using mul_le_mul_of_nonneg_left lo nonneg
  · simpa using Int.floor_le_floor (mul_le_mul_of_nonneg_left hi nonneg)

private theorem floor_error (D : ℕ) (hD : 0<D) (y : ℝ) :
    |(⌊D*y⌋:ℝ)/D-y|≤1/D := by
  have pos : 0<(D:ℝ) := by exact_mod_cast hD
  have h₁ := Int.floor_le (D*y)
  have h₂ := Int.lt_floor_add_one (D*y)
  rw [abs_le]
  constructor <;> field_simp <;> linarith

/-- Two signed integers of magnitude at most D per orbital entry suffice
to approximate every orthonormal occupied frame within 2/D entrywise. -/
theorem finiteWitness (D : ℕ) (hD : 0<D) (f : Frame (Fin d) k) (hf : Orthonormal ℂ f) :
    ∃ a : Digits d k, a.bounded D ∧ ∀ i j, ‖a.decode D i j-f j i‖≤2/D := by
  let a : Digits d k := ⟨fun i j => ⌊D*(f j i).re⌋,fun i j => ⌊D*(f j i).im⌋⟩
  refine ⟨a,fun i j => ⟨floor_bound D _ ((Complex.abs_re_le_norm _).trans (entry_of_unit _ hf i j)),
    floor_bound D _ ((Complex.abs_im_le_norm _).trans (entry_of_unit _ hf i j))⟩,?_⟩
  intro i j
  calc
    _ ≤ |(a.decode D i j-f j i).re|+|(a.decode D i j-f j i).im| := Complex.norm_le_abs_re_add_abs_im _
    _ ≤ 1/(D:ℝ)+1/D := add_le_add (floor_error D hD _) (floor_error D hD _)
    _ = _ := by ring

theorem digits_norm {D : ℕ} (hD : 0<D) {a : Digits d k} (hb : a.bounded D) (i j) :
    ‖a.decode D i j‖≤2 := by
  have hd : 0<(D:ℝ) := by exact_mod_cast hD
  obtain ⟨hr,hi⟩ := hb i j
  calc
    _ ≤ |(a.decode D i j).re|+|(a.decode D i j).im| := Complex.norm_le_abs_re_add_abs_im _
    _ ≤ 1+1 := by
      change |(a.re i j:ℝ)/D|+|(a.im i j:ℝ)/D|≤_
      rw [abs_div,abs_div,abs_of_pos hd]
      gcongr <;> apply (div_le_one hd).mpr <;> exact_mod_cast ‹_›
    _ = _ := by norm_num

theorem gram_error (B : Coeff d k) (f : Frame (Fin d) k) (hf : Orthonormal ℂ f) (e : ℝ)
    (h : ∀ i j, ‖B i j‖≤2 ∧ ‖B i j-f j i‖≤e) (i j : Fin k) :
    ‖(Bᴴ*B-1 : Matrix (Fin k) (Fin k) ℂ) i j‖ ≤ 4*d*e := by
  let F : Coeff d k := Matrix.of fun a b => f b a
  have gram : Fᴴ*F=1 := (gram_iff F).mp hf
  rw [←gram]
  simp only [Matrix.sub_apply,Matrix.mul_apply,Matrix.conjTranspose_apply,←Finset.sum_sub_distrib]
  calc
    _ ≤ (d:ℝ)*(2*e+e*2) := sumBound _ _ fun a => productError
      (by simpa using (h a i).1) ((entry_of_unit f hf a j).trans (by norm_num)) (by
        simpa [F,←map_sub] using (h a i).2) (h a j).2
    _ = _ := by ring

/-- Integer version of the energy Lipschitz constant. -/
def constant (d k M : ℕ) := d^2*M*(4*k)+d^4*M*(64*k^2)

/-- Grid denominator for inverse gap t and integral magnitudes at most M. -/
def denominator (d k M t : ℕ) :=
  1+16*d*k^2 + t*constant d k M*(2+32*d*k^3)

private theorem constant_cast (d k M : ℕ) :
    (constant d k M : ℝ)=energyConstant d k M := by simp [constant,energyConstant]

def passes (h : Fin d → Fin d → ℂ) (u : Fin d → Fin d → Fin d → Fin d → ℂ)
    (D M : ℕ) (lo : ℝ) (a : Digits d k) : Prop :=
  a.bounded D ∧ (∀ i j, ‖((a.decode D)ᴴ*(a.decode D)-1 : Matrix (Fin k) (Fin k) ℂ) i j‖≤8*d/D) ∧
  (score (density (frame (a.decode D))) h u).re≤lo+energyConstant d k M*(2/D)

/-- The finite grid preserves every YES witness. -/
theorem completeness (h : Fin d → Fin d → ℂ) (u : Fin d → Fin d → Fin d → Fin d → ℂ)
    (D M : ℕ) (hD : 0<D) (lo : ℝ) (hh : ∀ p q, ‖h p q‖≤M) (hu : ∀ p q r s, ‖u p q r s‖≤M)
    (f : Frame (Fin d) k) (hf : Orthonormal ℂ f) (low : (bra f (hamiltonian k h u (ket f))).re≤lo) :
    ∃ a : Digits d k, passes h u D M lo a := by
  obtain ⟨a,bounded,near⟩ := finiteWitness D hD f hf
  have both := fun i j => And.intro (digits_norm hD bounded i j) (near i j)
  refine ⟨a,bounded,fun i j => (gram_error _ _ hf _ both i j).trans (le_of_eq (by ring)),?_⟩
  rw [energy f hf] at low
  have pert := score_error (frame (a.decode D)) f h u M (2/D) (fun i j =>
    ⟨(both i j).1,(entry_of_unit f hf i j).trans (by norm_num),(both i j).2⟩) hh hu
  have re := (Complex.re_le_norm _).trans pert
  simp only [Complex.sub_re] at re
  linarith

/-- Any accepted witness yields an actual normalized Slater determinant
with energy strictly below the NO threshold. -/
theorem soundness (h : Fin d → Fin d → ℂ) (u : Fin d → Fin d → Fin d → Fin d → ℂ)
    (M t : ℕ) (ht : 0<t) (lo hi : ℝ) (gap : 1/(t:ℝ)≤hi-lo)
    (hh : ∀ p q, ‖h p q‖≤M) (hu : ∀ p q r s, ‖u p q r s‖≤M)
    (a : Digits d k) (pass : passes h u (denominator d k M t) M lo a) :
    ∃ f : Frame (Fin d) k, Orthonormal ℂ f ∧ bra f (ket f)=1 ∧
      (bra f (hamiltonian k h u (ket f))).re<hi := by
  let D := denominator d k M t
  let z : ℝ := 8*d/D
  let L := energyConstant d k M
  have den : (D:ℝ) = 1+16*d*(k:ℝ)^2+t*L*(2+32*d*(k:ℝ)^3) := by
    dsimp [D,denominator,L]; push_cast; rw [constant_cast]
  have Lpos : 0≤L := by dsimp [L,energyConstant]; positivity
  have Dpos : 0<(D:ℝ) := by rw [den]; positivity
  have tpos : 0<(t:ℝ) := by exact_mod_cast ht
  have hD : 0<D := by exact_mod_cast Dpos
  obtain ⟨bounded,gram,accept⟩ := pass
  have small : (k:ℝ)*k*z≤1/2 := by
    dsimp [z]
    field_simp
    nlinarith [mul_nonneg (mul_nonneg tpos.le Lpos) (show 0≤2+32*(d:ℝ)*k^3 by positivity)]
  obtain ⟨f,hf,close⟩ := corrected (a.decode D) z (by dsimp [z]; positivity)
    (digits_norm hD bounded) gram small
  refine ⟨f,hf,normalized f hf,?_⟩
  rw [energy f hf]
  have pert := score_error f (frame (a.decode D)) h u M _ (fun i j =>
    ⟨(entry_of_unit f hf i j).trans (by norm_num),digits_norm hD bounded i j,close i j⟩) hh hu
  have re := (Complex.re_le_norm _).trans pert
  simp only [Complex.sub_re] at re
  change (score (density (frame (a.decode D))) h u).re≤lo+L*(2/D) at accept
  change _≤L*(4*k*((k:ℝ)*k*z)) at re
  have strict : L*(2/D)+L*(4*k*((k:ℝ)*k*z))<1/t := by
    dsimp [z]
    field_simp
    nlinarith [show 0≤(16:ℝ)*d*k^2 by positivity]
  linarith

end FQChem.Complexity.SlaterCertificate
