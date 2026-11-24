module

public import Qatlib.Concepts.HhlAlgorithms.SinEnvProgram.QlsHhl
import Mathlib.Tactic

/-! # Signed reciprocal filtering with the HHL sine clock

The successful flag amplitude has a relative, eigenvalue-dependent error.
This distinction matters after normalizing the solution for a superposition
of well- and ill-conditioned modes. See Harrow, Hassidim and Lloyd,
Appendix A, Theorem 1(3). -/

@[expose] public section
noncomputable section
namespace FQChemQatlib.Properties.SignedSineClock

open Matrix
open Qatlib.Concepts.HhlAlgorithms.SinEnvProgram
open Qatlib.Concepts.HhlAlgorithms.SinEnvProgram.SinEnvelopeHHLConsumers
open Qatlib.Concepts.HhlAlgorithms.SinEnvFilter.SinEnvelopeHHL
open Qatlib.Concepts.SpectralReadout.OffGridPhaseReadout
open Qatlib.Concepts.HhlErrorBridge.FilterStability

abbrev gain := canonicalSignedFilter.filterF

/-- A regular bin gives exactly the signed reciprocal. -/
theorem regularGain (d x : ℝ) (hx : 2*d≤|x|) : gain d x = d/x := by
  unfold gain canonicalSignedFilter
  change (if x<0 then (-1:ℝ) else 1) * sinEnvelopeFilterF d |x| = _
  unfold sinEnvelopeFilterF
  rw [ite_eq_left hx]
  by_cases neg : x<0
  · simp [neg,abs_of_neg neg,div_neg]
  · simp [neg,abs_of_nonneg (le_of_not_gt neg)]

/-- The signed success amplitude has small relative error even when the
decoded bin has the wrong spectral sign. -/
theorem relativeGain (d e x : ℝ) (hd : 0<d) (gap : 4*d ≤ |e|) :
    |e*gain d x-d| ≤ 3*|e-x| := by
  by_cases hx : 2*d ≤ |x|
  · rw [regularGain d x hx]
    have xn : x≠0 := abs_pos.mp (by linarith)
    rw [show e*(d/x)-d=(e-x)*(d/x) by field_simp,abs_mul,abs_div,abs_of_pos hd]
    have ratio : d/|x| ≤ 1 := (div_le_iff₀ (abs_pos.mpr xn)).mpr (by linarith)
    nlinarith [mul_le_mul_of_nonneg_left ratio (abs_nonneg (e-x)),abs_nonneg (e-x)]
  · have mass := canonicalSignedFilter_consistent.2.2.2.2 d x hd
    have bounded : |gain d x| ≤ 1 := by
      change |canonicalSignedFilter.filterF d x| ≤ 1
      rw [abs_le]; constructor <;> nlinarith [sq_nonneg (canonicalSignedFilter.filterG d x)]
    have tri : |e| ≤ |e-x|+|x| := by simpa using abs_add_le (e-x) x
    calc
      _ ≤ |e| * |gain d x|+d := by simpa [abs_mul,abs_of_pos hd] using abs_sub (e*gain d x) d
      _ ≤ _ := by nlinarith [mul_le_mul_of_nonneg_left bounded (abs_nonneg e)]

private theorem decodedDistance (M : ℕ) (z : Fin M) {a : ℝ} (ha : |a|≤1/4) :
    |a - sinEnvelopeDecode M z| ≤ 3*phaseDistance a (z.val/M) := by
  let y := (z.val:ℝ)/M
  have mpos : (0:ℝ)<M := by exact_mod_cast Nat.zero_lt_of_lt z.isLt
  have lo : 0≤y := by dsimp [y]; positivity
  have hi : y<1 := (div_lt_one mpos).mpr (by exact_mod_cast z.isLt)
  let x := sinEnvelopeDecode M z
  have bounds : -(1/2:ℝ)≤x ∧ x≤1/2 := by
    dsimp [x,sinEnvelopeDecode]
    split_ifs with hz
    · have h : 2*(z.val:ℝ) ≤ M := by exact_mod_cast hz
      exact ⟨by dsimp [y] at lo; linarith,(div_le_iff₀ mpos).mpr (by linarith)⟩
    · have h : (M:ℝ)<2*z.val := by exact_mod_cast lt_of_not_ge hz
      have hy : 1/2<y := (lt_div_iff₀ mpos).mpr (by linarith)
      change -_≤y-1 ∧ y-1≤_; constructor <;> linarith
  have periodic : phaseDistance a y = phaseDistance a x := by
    dsimp [x,sinEnvelopeDecode]
    split_ifs
    · rfl
    · change |a-y-↑⌊a-y+1/2⌋| = |a-(y-1)-↑⌊a-(y-1)+1/2⌋|
      rw [show a-(y-1)+1/2=(a-y+1/2)+(1:ℤ) by push_cast; ring,Int.floor_add_intCast]
      push_cast; ring_nf
  change |a-x| ≤ 3*phaseDistance a y
  rw [periodic,phaseDistance]
  have ha' := abs_le.mp ha
  have lf : -(1:ℤ) ≤ ⌊a-x+1/2⌋ := Int.le_floor.mpr (by push_cast; linarith [bounds.2])
  have uf : ⌊a-x+1/2⌋ < (2:ℤ) := Int.floor_lt.mpr (by push_cast; linarith [bounds.1])
  have hl := Int.floor_le (a-x+1/2)
  have hu := Int.lt_floor_add_one (a-x+1/2)
  obtain ⟨ha₁,ha₂⟩ := ha'
  obtain ⟨hx₁,hx₂⟩ := bounds
  interval_cases h : ⌊a-x+1/2⌋ <;> norm_num at hl hu ⊢ <;>
    simp only [abs,max_def] <;> split_ifs <;> linarith

/-- Kernel-weighted relative error is at most (80/(dM))² on both spectral
branches. The clock size needed for relative error η therefore scales as
1/(dη), with no promise of an exactly represented eigenphase. -/
theorem signedRelativeClock (M : ℕ) (hM : 2≤M) (d a : ℝ)
    (hd : 0<d) (gap : 4*d ≤ |a|) (small : |a| ≤ 1/4) :
    ∑ z : Fin M, ‖sinEnvelopeKernel M a z‖^2 *
      ((a*gain d (sinEnvelopeDecode M z)-d)/d)^2 ≤ (80/(d*M))^2 := by
  have mpos : (0:ℝ)<M := by exact_mod_cast (show 0<M by omega)
  have point (z : Fin M) : (a*gain d (sinEnvelopeDecode M z)-d)^2 ≤
      (9*phaseDistance a (z.val/M))^2 := by
    have h := (relativeGain d a _ hd gap).trans (mul_le_mul_of_nonneg_left (decodedDistance M z small) (by norm_num))
    rw [show (3:ℝ)*(3*phaseDistance a (z.val/M)) = 9*phaseDistance a (z.val/M) by ring] at h
    have hsq := pow_le_pow_left₀ (abs_nonneg _) h 2
    rwa [sq_abs] at hsq
  have moment := sin_envelope_kernel_second_moment M a hM
  let r := fun z : Fin M => phaseDistance a (z.val/M)
  let w := fun z : Fin M => ‖sinEnvelopeKernel M a z‖^2
  have rhs : 4*Real.pi^2*(M:ℝ)^2*(∑ z,w z*(r z)^2) ≤ 4*Real.pi^2+40*Real.pi^4/3 := by
    rw [Finset.mul_sum]
    convert moment using 1
    apply Finset.sum_congr rfl; intro z _
    dsimp [r,w]; ring
  have sumBound : (∑ z,w z*((a*gain d (sinEnvelopeDecode M z)-d)/d)^2) ≤
      (81/d^2)*(∑ z,w z*(r z)^2) := by
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro z _
    rw [div_pow]
    have := mul_le_mul_of_nonneg_left (div_le_div_of_nonneg_right (point z) (sq_nonneg d)) (sq_nonneg ‖sinEnvelopeKernel M a z‖)
    dsimp [w,r] at *; linarith only [this,show ‖sinEnvelopeKernel M a z‖^2*((9*phaseDistance a (z.val/M))^2/d^2) =
      81/d^2*(‖sinEnvelopeKernel M a z‖^2*(phaseDistance a (z.val/M))^2) by ring]
  have c : (M:ℝ)^2*(∑ z,w z*(r z)^2) ≤ 6400/81 := by
    apply le_of_mul_le_mul_left (a:=4*Real.pi^2) _ (by positivity)
    have piBound : Real.pi^2 ≤ 16 := by nlinarith [Real.pi_pos,Real.pi_lt_four]
    nlinarith [mul_nonneg (sub_nonneg.mpr piBound) (sq_nonneg Real.pi)]
  apply sumBound.trans
  rw [div_pow,mul_pow]
  field_simp
  nlinarith

/-- The selected flag coordinate of the implemented three-dimensional rotation. -/
theorem selectedGain (d x : ℝ) (hd : 0 < d) :
    (canonicalSignedProgram.rotation d x *ᵥ Qatlib.Foundations.PureStateMath.Ket (0 : Fin 3)) 1 =
      (gain d x : ℂ) := by
  rw [(canonicalSignedProgram_rotation d x hd).2]
  rfl

/-- The coherent success branch for any superposition of signed eigenphases.
Its squared vector error is relative to the actual inverse-weighted spectral
mass. The unitary inverse phase estimation preserves this error. -/
theorem superpositionError {I : Type*} [Fintype I] (M : ℕ) (hM : 2 ≤ M) (d : ℝ)
    (eig : I → ℝ) (b : I → ℂ) (hd : 0 < d)
    (spectrum : ∀ i, 4*d ≤ |eig i| ∧ |eig i| ≤ 1/4) :
    let K := fun i z => sinEnvelopeKernel M (eig i) z
    let sel := fun z => (canonicalSignedProgram.rotation d (sinEnvelopeDecode M z) *ᵥ
      Qatlib.Foundations.PureStateMath.Ket (0 : Fin 3)) 1
    let ideal := fun i => b i * ((d / eig i : ℝ) : ℂ)
    (∑ i, ∑ z, ‖b i * K i z * sel z - ideal i * K i z‖^2) ≤
      (80/(d*M))^2 * ∑ i, ‖ideal i‖^2 := by
  dsimp only
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  have he : eig i ≠ 0 := abs_pos.mp (by linarith [(spectrum i).1])
  let ideal := b i * ((d / eig i : ℝ) : ℂ)
  let err := fun z : Fin M => (eig i * gain d (sinEnvelopeDecode M z) - d) / d
  have split (z : Fin M) : b i * sinEnvelopeKernel M (eig i) z *
      ((gain d (sinEnvelopeDecode M z) : ℝ) : ℂ) - ideal * sinEnvelopeKernel M (eig i) z =
      ideal * sinEnvelopeKernel M (eig i) z * (err z : ℂ) := by
    dsimp [ideal,err]
    push_cast
    have hec : (eig i : ℂ) ≠ 0 := by exact_mod_cast he
    have hdc : (d : ℂ) ≠ 0 := by exact_mod_cast hd.ne'
    field_simp [hec, hdc]
  calc
    _ = ∑ z : Fin M, ‖ideal‖^2 * (‖sinEnvelopeKernel M (eig i) z‖^2 * (err z)^2) := by
      apply Finset.sum_congr rfl
      intro z _
      rw [selectedGain _ _ hd]
      change ‖b i * _ * _ - ideal * _‖^2 = _
      rw [split]
      simp [mul_pow, mul_assoc]
    _ = _ := (Finset.mul_sum ..).symm
    _ ≤ _ := (mul_le_mul_of_nonneg_left
      (signedRelativeClock M hM d (eig i) hd (spectrum i).1 (spectrum i).2)
      (sq_nonneg ‖ideal‖)).trans_eq (mul_comm _ _)

/-- State of the selected flag, in the joint eigenstate and clock coordinates. -/
def successBranch {I : Type*} (M : ℕ) (d : ℝ) (eig : I → ℝ) (b : I → ℂ) :
    EuclideanSpace ℂ (I × Fin M) :=
  WithLp.toLp 2 fun p => b p.1 * sinEnvelopeKernel M (eig p.1) p.2 *
    (canonicalSignedProgram.rotation d (sinEnvelopeDecode M p.2) *ᵥ
      Qatlib.Foundations.PureStateMath.Ket (0 : Fin 3)) 1

/-- The inverse-weighted target in the same coordinates, before inverse QPE. -/
def inverseBranch {I : Type*} (M : ℕ) (d : ℝ) (eig : I → ℝ) (b : I → ℂ) :
    EuclideanSpace ℂ (I × Fin M) :=
  WithLp.toLp 2 fun p => (b p.1 * ((d/eig p.1 : ℝ) : ℂ)) * sinEnvelopeKernel M (eig p.1) p.2

/-- With a normalized input and an exact sine clock of size M, the selected
branch has probability at least 4d² and normalized vector error at most
160/(dM), also after any common unitary uncomputation. -/
theorem normalizedBranch {I : Type*} [Fintype I] (M : ℕ) (hM : 2 ≤ M) (d : ℝ)
    (eig : I → ℝ) (b : I → ℂ) (hd : 0 < d) (hb : ∑ i, ‖b i‖^2 = 1)
    (spectrum : ∀ i, 4*d ≤ |eig i| ∧ |eig i| ≤ 1/4) (budget : 160 ≤ d*M)
    (undo : EuclideanSpace ℂ (I × Fin M) ≃ₗᵢ[ℂ] EuclideanSpace ℂ (I × Fin M)) :
    let actual := undo (successBranch M d eig b)
    let target := undo (inverseBranch M d eig b)
    4*d^2 ≤ ‖actual‖^2 ∧
      ‖NormedSpace.normalize actual - NormedSpace.normalize target‖ ≤ 160/(d*M) := by
  let A := successBranch M d eig b
  let T := inverseBranch M d eig b
  let η := 80/(d*M)
  have dm : 0 < d*(M:ℝ) := by linarith
  have ηpos : 0 ≤ η := by dsimp [η]; positivity
  have ηhalf : η ≤ 1/2 := (div_le_iff₀ dm).mpr (by linarith)
  have tMass : ‖T‖^2 = ∑ i, ‖b i * ((d / eig i : ℝ) : ℂ)‖^2 := by
    rw [EuclideanSpace.norm_sq_eq, Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro i _
    change ∑ z, ‖(b i * ((d / eig i : ℝ) : ℂ)) * sinEnvelopeKernel M (eig i) z‖^2 = _
    simp_rw [norm_mul, mul_pow, ← Finset.mul_sum, sin_envelope_kernel_normalized M _ hM, mul_one]
  have tLo : 4*d ≤ ‖T‖ := by
    apply (sq_le_sq₀ (by positivity) (norm_nonneg _)).mp
    rw [tMass, ← mul_one ((4*d)^2), ← hb, Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    have ep : 0 < |eig i| := by linarith [(spectrum i).1]
    have h : 4*d ≤ d/|eig i| := (le_div_iff₀ ep).mpr (by
      nlinarith [mul_le_mul_of_nonneg_left (spectrum i).2 hd.le])
    rw [norm_mul, Complex.norm_real, Real.norm_eq_abs, abs_div, abs_of_pos hd, mul_pow ‖b i‖, mul_comm (‖b i‖^2) _]
    exact mul_le_mul_of_nonneg_right (pow_le_pow_left₀ (by positivity) h 2) (sq_nonneg _)
  have diff : ‖A-T‖ ≤ η*‖T‖ := by
    apply (sq_le_sq₀ (norm_nonneg _) (mul_nonneg ηpos (norm_nonneg _))).mp
    rw [mul_pow, tMass, EuclideanSpace.norm_sq_eq, Fintype.sum_prod_type]
    exact superpositionError M hM d eig b hd spectrum
  change 4*d^2 ≤ ‖undo A‖^2 ∧ _ ≤ _
  have transported : ‖undo A - undo T‖ ≤ η*‖undo T‖ := by simpa only [← map_sub, undo.norm_map] using diff
  have ht : 0 < ‖undo T‖ := by rw [undo.norm_map]; linarith
  have hn := Qatlib.Concepts.BlockEncoding.Postselection.normalize_error_of_gap transported
    (by nlinarith [mul_le_mul_of_nonneg_right ηhalf ht.le] : η * ‖undo T‖ < ‖undo T‖)
  constructor
  · rw [undo.norm_map]
    have lo := norm_sub_norm_le T A
    rw [norm_sub_rev] at lo
    have half := mul_le_mul_of_nonneg_right ηhalf (norm_nonneg T)
    nlinarith [sq_nonneg (‖A‖-2*d),mul_nonneg (by linarith : 0 ≤ ‖A‖-2*d) (by positivity : 0 ≤ ‖A‖+2*d)]
  · apply hn.2.trans_eq
    dsimp [η]
    field_simp
    norm_num

end FQChemQatlib.Properties.SignedSineClock
