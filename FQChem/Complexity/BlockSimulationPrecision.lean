module

public import FQChem.Complexity.SparseSimulationPrecision
import Mathlib.Tactic

/-! # A time–precision lower bound with a block-encoding oracle

A uniform superposition over N input signs compresses a diagonal phase oracle
to their mean. The parity Fourier coefficient of the resulting evolution is
exactly (−i sin(t/N))ᴺ. Fewer than N oracle queries give zero for this
coefficient, even with arbitrary input-independent unitaries and work registers.
This yields the factorial-cutoff lower bound in the model of
[Low and Chuang, Theorem 1](https://doi.org/10.22331/q-2019-07-12-163).
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.BlockSimulationPrecision

open PhaseQuery OrbitalSimulation Matrix
open scoped ComplexConjugate

variable {N q : ℕ} {B : Type*} [Fintype B] [DecidableEq B]

def signal (x : Bits N) : ℝ := (∑ i,bitSign (x i)) / N

def oracle (x : Bits N) : Matrix (Fin N) (Fin N) ℂ :=
  Matrix.diagonal fun i => (bitSign (x i) : ℂ)

def frame (N : ℕ) : Fin N → ℂ := fun _ => (Real.sqrt N : ℂ)⁻¹

/-- Each oracle query or its inverse applies a single input sign. The
compression in a fixed unit vector is the real one-dimensional Hamiltonian. -/
theorem blockEncoding (x : Bits N) (hn : 0<N) :
    (oracle x)ᴴ * oracle x = 1 ∧ star (frame N) ⬝ᵥ frame N = 1 ∧
      star (frame N) ⬝ᵥ ((oracle x) *ᵥ frame N) = (signal x : ℂ) := by
  have pos : (0:ℝ)<N := by exact_mod_cast hn
  have sq : (Real.sqrt N : ℂ)*(Real.sqrt N : ℂ) = N := by
    exact_mod_cast Real.mul_self_sqrt pos.le
  have coeff : (Real.sqrt N : ℂ)⁻¹*(Real.sqrt N : ℂ)⁻¹ = (N:ℂ)⁻¹ := by
    rw [← mul_inv, sq]
  constructor
  · simp only [oracle,diagonal_conjTranspose,diagonal_mul_diagonal,← diagonal_one]
    congr 1
    funext i; cases h : x i <;> simp [bitSign,h]
  constructor
  · simp [frame,dotProduct, coeff,hn.ne']
  · simp only [oracle,Matrix.mulVec_diagonal,dotProduct,frame,Pi.star_apply,star_inv₀,
      RCLike.star_def,Complex.conj_ofReal]
    simp only [signal,Complex.ofReal_sum,div_eq_mul_inv,
      Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro i _
    push_cast; rw [← coeff]; ring

def evolution (t : ℝ) (x : Bits N) : ℂ := Complex.exp (-Complex.I*t*(signal x : ℝ))

/-- Unnormalized parity Fourier coefficient of the ideal evolution. -/
theorem parityCoefficient (t : ℝ) :
    ∑ x : Bits N, (parity x : ℂ)*evolution t x = (-2*Complex.I*Real.sin (t/N))^N := by
  let f := fun (b : Bool) => (bitSign b : ℂ)*Complex.exp
    (-Complex.I * ((t/N:ℝ):ℂ) * (bitSign b : ℂ))
  have term (x : Bits N) : (parity x : ℂ)*evolution t x = ∏ i, f (x i) := by
    simp only [parity,evolution,signal,Complex.ofReal_div,Complex.ofReal_sum,
      Complex.ofReal_natCast,Complex.ofReal_prod,f,Finset.prod_mul_distrib,← Complex.exp_sum,
      ← Finset.mul_sum]
    congr 2
    ring
  simp_rw [term]
  rw [← Fintype.prod_sum]
  have factor : ∑ b, f b = -2*Complex.I*Real.sin (t/N) := by
    rw [Fintype.sum_bool]
    simp only [f,bitSign,Bool.false_eq_true,ite_false,ite_true,Complex.ofReal_one,Complex.ofReal_neg,
      mul_one,mul_neg,neg_one_mul,one_mul,Complex.ofReal_sin,Complex.sin]
    ring_nf
    simp [Complex.I_sq]
  simp only [factor,Finset.prod_const,Finset.card_univ,Fintype.card_fin]

private theorem zeroCoefficient (r : Circuit N B q) (v : B → ℂ) (few : q<N) :
    ∑ x : Bits N, (parity x : ℂ)*(star v ⬝ᵥ amplitudes x r) = 0 := by
  simp only [dotProduct,Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_eq_zero
  intro b _
  obtain ⟨u,w,hu,hw,eval⟩ := amplitudePolynomials r b
  have zero : (∑ x : Bits N,(parity x : ℂ)*amplitudes x r b) = 0 := by
    apply Complex.ext
    · simpa [Complex.mul_re,eval] using parity_orthogonal u (hu.trans_lt few)
    · simpa [Complex.mul_im,eval] using parity_orthogonal w (hw.trans_lt few)
  simp_rw [mul_left_comm (parity _ : ℂ)]
  rw [← Finset.mul_sum,zero,mul_zero]

/-- Uniform approximation of the compressed evolution amplitude to ε with
fewer than N controlled sign-oracle queries forces |sin(t/N)|ᴺ ≤ ε. -/
theorem precisionBarrier (r : Circuit N B q) (v : B → ℂ) (t ε : ℝ) (few : q<N)
    (accurate : ∀ x, ‖evolution t x - star v ⬝ᵥ amplitudes x r‖ ≤ ε) :
    |Real.sin (t/N)|^N ≤ ε := by
  have err (x : Bits N) : ‖(parity x:ℂ)*(evolution t x - star v ⬝ᵥ amplitudes x r)‖ ≤ ε := by
    simpa [norm_mul,parity,Finset.abs_prod,bitSign,apply_ite abs] using accurate x
  have total := norm_sum_le_of_le Finset.univ fun x _ => err x
  simp only [mul_sub,Finset.sum_sub_distrib,zeroCoefficient r v few,sub_zero,parityCoefficient,
    Finset.sum_const,Finset.card_univ,Fintype.card_pi,Fintype.card_bool,Finset.prod_const,
    Fintype.card_fin,nsmul_eq_mul] at total
  have scale : (0:ℝ)<2^N := by positivity
  apply le_of_mul_le_mul_left (a:= (2:ℝ)^N) _ scale
  simpa [norm_pow, norm_mul, -Complex.ofReal_sin, Complex.norm_real,Real.norm_eq_abs,mul_pow] using total

/-- With q calls to the supplied block encoding, the least admissible
positive factorial cutoff at time budget τ is bounded by 8(q+1). The
algorithm may use any fixed normalized input, work space, and output frame. -/
theorem worstCaseBlockCutoff (q : ℕ) (τ ε : ℝ) (hτ : 0≤τ) (hε : ε<1)
    (algorithm : ∀ (n : ℕ), 0<n → ∀ t : ℝ, 0≤t → t≤τ →
      ∃ (w : ℕ) (r : Circuit n (Fin w) q) (v : Fin w → ℂ),
      ∀ x, ‖evolution t x - star v ⬝ᵥ amplitudes x r‖ ≤ ε) :
    ∃ m : ℕ, 0<m ∧ m≤8*(q+1) ∧ 4*(τ/2)^m/m.factorial ≤ ε := by
  let n := q+1
  have hn : 0<n := Nat.succ_pos _
  have hn' : (0:ℝ)<n := by exact_mod_cast hn
  have few : q<n := Nat.lt_succ_self _
  have beforeTransfer : τ ≤ Real.pi*n/2 := by
    by_contra! later
    obtain ⟨_,r,v,h⟩ := algorithm n hn (Real.pi*n/2) (by positivity) later.le
    have b := precisionBarrier r v _ _ few h
    rw [show Real.pi*n/2/n=Real.pi/2 by field_simp,Real.sin_pi_div_two,abs_one,one_pow] at b
    linarith
  obtain ⟨_,r,v,h⟩ := algorithm n hn τ hτ le_rfl
  have bound := precisionBarrier r v _ _ few h
  have pos := pow_nonneg (abs_nonneg (Real.sin (τ/n))) n
  have sqBound := pow_le_pow_of_le_one (abs_nonneg _) (Real.abs_sin_le_one (τ/n)) (show n ≤ 2*n by omega)
  exact ⟨8*n,by omega,le_rfl,SparseSimulationPrecision.cutoffFromSignal hn τ ε hτ beforeTransfer
    (by linarith [sqBound.trans bound])⟩

end FQChem.Complexity.BlockSimulationPrecision
