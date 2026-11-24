module

public import FQChem.Complexity.FermionicMarginals
public import Mathlib.Analysis.Convex.Combination
import Mathlib.LinearAlgebra.Matrix.Gershgorin
import Mathlib.Tactic

/-! # Detecting inconsistent two-fermion marginals

Liu, Christandl and Verstraete's verifier measures two-body observables on
witness blocks. Its soundness argument works with the average of the block
marginals, even when the measurement records are correlated.
[Original paper](https://doi.org/10.1103/PhysRevLett.98.110503).
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.MarginalVerification

open Matrix FermionicMarginals
open scoped ComplexConjugate ComplexOrder
variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The trace norm of a Hermitian difference, with the unhalved convention
used for the N-representability promise. -/
def traceNorm {M : Operator ι} (h : M.IsHermitian) := ∑ i, |h.eigenvalues i|

/-- Gershgorin bounds the trace norm by dimension squared times the largest
entry norm. The resulting measurement precision is polynomial in the modes. -/
theorem traceNormBound {M : Operator ι} (h : M.IsHermitian) {δ : ℝ}
    (bound : ∀ i j, ‖M i j‖ ≤ δ) : traceNorm h ≤ (Fintype.card ι : ℝ)^2 * δ := by
  have row (i : ι) : |h.eigenvalues i| ≤ Fintype.card ι * δ := by
    have eig : Module.End.HasEigenvalue M.toLin' (h.eigenvalues i : ℂ) := by
      rw [Module.End.hasEigenvalue_iff_mem_spectrum,Matrix.spectrum_toLin',h.spectrum_eq_image_range]
      exact ⟨_,⟨i,rfl⟩,rfl⟩
    obtain ⟨j,hj⟩ := eigenvalue_mem_ball eig
    rw [Metric.mem_closedBall,dist_eq_norm] at hj
    calc
      |h.eigenvalues i| = ‖(h.eigenvalues i:ℂ)‖ := (Complex.norm_real _).symm
      _ ≤ ‖(h.eigenvalues i:ℂ) - M j j‖ + ‖M j j‖ := norm_le_norm_sub_add _ _
      _ ≤ _ := by
        have all := Finset.sum_le_sum (s:=Finset.univ) (fun k _ => bound j k)
        have split := Finset.sum_erase_add Finset.univ (fun k => ‖M j k‖) (Finset.mem_univ j)
        simp only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul] at all
        linarith
  calc
    traceNorm h ≤ ∑ _i : ι, (Fintype.card ι:ℝ)*δ := Finset.sum_le_sum fun i _ => row i
    _ = _ := by simp [pow_two,mul_assoc]

/-- Hermitian observables extracting the real or imaginary part of a matrix
entry. Either can be lifted to the first pair of fermionic coordinates. -/
def observable (imag : Bool) (i j : ι) : Operator ι :=
  let K := Matrix.single j i (1:ℂ)
  if imag then (-Complex.I/2) • (K-Kᴴ) else (1/2:ℂ) • (K+Kᴴ)

theorem observableReadout {M : Operator ι} (h : M.IsHermitian) (imag : Bool) (i j : ι) :
    (observable imag i j).IsHermitian ∧
    ((observable imag i j * M).trace).re = (if imag then (M i j).im else (M i j).re) := by
  have rev : M j i = conj (M i j) := (h.apply j i).symm
  cases imag <;> constructor
  all_goals simp [observable,IsHermitian,conjTranspose_single,conjTranspose_smul,
    add_mul,sub_mul,trace_add,trace_sub,trace_smul,trace_single_mul,rev,
    Complex.mul_re,Complex.div_ofNat_re,Complex.div_ofNat_im]
  all_goals first | module | ring_nf

/-- A NO instance forces an inverse-polynomial signal on at least one of
the explicit two-body observables, for every mixture of physical blocks. -/
theorem measurableDiscrepancy {d n : ℕ} (γ : Operator (PairBasis d)) (herm : γ.IsHermitian)
    (β : ℝ) (pos : 0<β) (promise : ∀ σ, (r : Representable n σ) →
      β ≤ traceNorm (herm.sub (representable_density r).1.isHermitian))
    {J : Type*} [Fintype J] (w : J → ℝ) (hw : ∀ j, 0≤w j) (sum : ∑ j,w j=1)
    (blocks : J → Operator (PairBasis d)) (physical : ∀ j, Representable n (blocks j)) :
    let σ := ∑ j, w j • blocks j
    ∃ i j imag, β/(4*(d:ℝ)^4) < |((observable imag i j * (γ-σ)).trace).re| := by
  intro σ
  have rep : Representable n σ :=
    (convexRepresentable d n).sum_mem (fun j _ => hw j) sum (fun j _ => physical j)
  have h := herm.sub (representable_density rep).1.isHermitian
  by_contra! none
  let δ := β/(4*(d:ℝ)^4)
  have entries (i j : PairBasis d) : ‖(γ-σ) i j‖ ≤ 2*δ := by
    have a := none i j false
    have b := none i j true
    rw [(observableReadout h false i j).2] at a
    rw [(observableReadout h true i j).2] at b
    exact (Complex.norm_le_abs_re_add_abs_im _).trans (by dsimp [δ]; simp at a b; linarith)
  have bound := (promise σ rep).trans (traceNormBound h entries)
  simp only [PairBasis,Fintype.card_prod,Fintype.card_fin,Nat.cast_mul] at bound
  by_cases hd : d=0
  · subst d; simp at bound; linarith
  · dsimp [δ] at bound
    field_simp at bound
    nlinarith [pow_pos (show (0:ℝ)<d by exact_mod_cast Nat.pos_of_ne_zero hd) 4]

/-- Rejection probability bound for a bounded sample mean. It only uses its
expectation, so the finite outcomes can have any joint law. -/
theorem rejectionProbability {Ω : Type*} [Fintype Ω] (p X : Ω → ℝ)
    (nonneg : ∀ o, 0≤p o) (total : ∑ o,p o=1) (bounded : ∀ o, |X o| ≤ 1)
    (target δ : ℝ) (unit : |target|≤1) (hδ : 0≤δ) :
    |(∑ o,p o*X o)-target| ≤ δ + 2*∑ o, (if δ < |X o-target| then p o else 0) := by
  have rewriteMean : (∑ o,p o*X o)-target = ∑ o,p o*(X o-target) := by
    simp [mul_sub,Finset.sum_sub_distrib,← Finset.sum_mul,total]
  rw [rewriteMean]
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  calc
    _ ≤ ∑ o, (p o*δ + 2*(if δ < |X o-target| then p o else 0)) := by
      apply Finset.sum_le_sum; intro o _
      rw [abs_mul,abs_of_nonneg (nonneg o)]
      split_ifs with bad
      · have h : |X o-target| ≤ 2 := (abs_sub _ _).trans (by linarith [bounded o,unit])
        nlinarith [mul_le_mul_of_nonneg_left h (nonneg o),mul_nonneg (nonneg o) hδ]
      · have := mul_le_mul_of_nonneg_left (le_of_not_gt bad) (nonneg o); linarith
    _ = _ := by rw [Finset.sum_add_distrib,← Finset.sum_mul,← Finset.mul_sum,total,one_mul]

end FQChem.Complexity.MarginalVerification
