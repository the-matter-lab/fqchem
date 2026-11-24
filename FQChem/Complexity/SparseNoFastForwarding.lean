module

public import FQChem.Complexity.SparseParityQueries
public import FQChem.Complexity.SparseParityNorm
public import Mathlib.Analysis.Matrix.Spectrum
import Mathlib.Tactic

/-!
# Sparse-oracle no-fast-forwarding

For the two-track Hamiltonians of [Berry et al., Theorem 3](https://doi.org/10.1007/s00220-006-0150-x),
bounded trace-distance error on just the initial endpoint requires at least N/4
queries at scaled time πN/2. A simulator may keep any finite auxiliary register and
discard it. The trace norm of a Hermitian difference is the sum of its absolute
eigenvalues.
-/

@[expose] public section
noncomputable section
namespace FQChem.Complexity.SparseNoFastForwarding
open FQChem.Complexity FQChem.Complexity.SparseParityPath FQChem.Complexity.SparseParityQueries
open Matrix NormedSpace
open scoped Matrix.Norms.L2Operator ComplexConjugate
variable {N : ℕ} {W : Type*} [Fintype W]

/-- Half the trace norm of a Hermitian difference of density matrices. -/
def traceDistance {ι : Type*} [Fintype ι] [DecidableEq ι] {A : Matrix ι ι ℂ}
    (h : A.IsHermitian) : ℝ := (∑ k, |h.eigenvalues k|) / 2

private theorem diagonal_bound {ι : Type*} [Fintype ι] [DecidableEq ι] {A : Matrix ι ι ℂ}
    (h : A.IsHermitian) (h0 : A.trace = 0) (i : ι) : |(A i i).re| ≤ traceDistance h := by
  have hS : ∑ k, h.eigenvalues k = 0 := by
    apply Complex.ofReal_injective
    push_cast
    exact h.trace_eq_sum_eigenvalues.symm.trans h0
  have μbound (k : ι) : |h.eigenvalues k| ≤ traceDistance h := by
    have he := Finset.sum_erase_add Finset.univ h.eigenvalues (Finset.mem_univ k)
    rw [hS] at he
    have neg : ∑ j ∈ Finset.univ.erase k, h.eigenvalues j = - h.eigenvalues k := by linarith
    have habs := Finset.abs_sum_le_sum_abs h.eigenvalues (Finset.univ.erase k)
    rw [neg, abs_neg] at habs
    have sum := Finset.sum_erase_add Finset.univ (fun j => |h.eigenvalues j|) (Finset.mem_univ k)
    dsimp [traceDistance]
    linarith
  have norm_bound : ‖A‖ ≤ traceDistance h := by
    conv_lhs => rw [h.spectral_theorem]
    rw [Unitary.conjStarAlgAut_apply, ← Unitary.coe_star, CStarRing.norm_mul_coe_unitary,
      CStarRing.norm_coe_unitary_mul, Matrix.l2_opNorm_diagonal]
    apply (pi_norm_le_iff_of_nonneg (by unfold traceDistance; positivity)).mpr
    intro k
    simpa [Function.comp_def,Complex.norm_real,Real.norm_eq_abs] using μbound k
  let e : EuclideanSpace ℂ ι := EuclideanSpace.single i 1
  have b := A.l2_opNorm_mulVec e
  have c := PiLp.norm_apply_le (WithLp.toLp 2 (A.mulVec (Pi.single i 1))) i
  calc |(A i i).re| ≤ ‖A i i‖ := Complex.abs_re_le_norm _
    _ ≤ ‖WithLp.toLp 2 (A.mulVec (Pi.single i 1))‖ := by simpa [Matrix.mulVec_single_one] using c
    _ ≤ ‖A‖ := by simpa [e, EuclideanSpace.single] using b
    _ ≤ traceDistance h := norm_bound

/-- The physical state after discarding the simulator's auxiliary register. -/
def reduced (ψ : Vertex N × W → ℂ) : Matrix (Vertex N) (Vertex N) ℂ :=
  Matrix.of fun i j => ∑ a, ψ (i,a) * conj (ψ (j,a))

private theorem reduced_hermitian (ψ : Vertex N × W → ℂ) : (reduced ψ).IsHermitian := by
  ext i j
  simp [reduced,mul_comm]

private theorem trace_reduced (ψ : Vertex N × W → ℂ) :
    (reduced ψ).trace = ((∑ a, Complex.normSq (ψ a) : ℝ) : ℂ) := by
  simp [reduced, Matrix.trace, Fintype.sum_prod_type, Complex.normSq_eq_conj_mul_self, mul_comm]

/-- Exact physical output, including the phase of the endpoint ket. -/
theorem evolved_state (x : Fin N → Bool) (i : Vertex N) :
    exp ((-(Real.pi:ℂ)*Complex.I) • crossed x) i (0,false) =
      if i = (Fin.last N,prefixParity x N) then (-Complex.I)^N else 0 := by
  rw [evolution_lifts]
  change (if (i.2 ^^ prefixParity x i.1) = (false ^^ prefixParity x 0) then
    exp ((-(Real.pi:ℂ)*Complex.I) • path N) i.1 0 else 0) = _
  rw [SpinPathEvolution.evolution_column]
  rcases i with ⟨j,b⟩
  by_cases h : j = Fin.last N
  · subst j
    cases b <;> cases hx : prefixParity x N <;> simp [SpinPathEvolution.wave,
      SpinPathEvolution.coeff, prefixParity, hx]
  · have hj : N-j.val ≠ 0 := by
      have := j.isLt
      intro zero
      apply h
      exact Fin.ext (by simp; omega)
    simp [h,hj,SpinPathEvolution.wave]

def ideal (x : Fin N → Bool) : Matrix (Vertex N) (Vertex N) ℂ :=
  Matrix.single (Fin.last N, prefixParity x N) (Fin.last N, prefixParity x N) 1

/-- The ideal density matrix is precisely the outer product of the actual evolved ket. -/
theorem evolved_density (x : Fin N → Bool) :
    let φ := fun i => exp ((-(Real.pi:ℂ)*Complex.I) • crossed x) i (0,false)
    Matrix.vecMulVec φ (star φ) = ideal x := by
  intro φ
  ext i j
  simp only [φ, Matrix.vecMulVec_apply, Pi.star_apply, evolved_state]
  by_cases hi : i = (Fin.last N,prefixParity x N) <;> by_cases hj : j = (Fin.last N,prefixParity x N)
  all_goals simp [hi,hj,ideal,Matrix.single,← mul_pow]
  all_goals grind

theorem difference_hermitian (ψ : Vertex N × W → ℂ) (x : Fin N → Bool) :
    (reduced ψ - ideal x).IsHermitian := by
  apply (reduced_hermitian ψ).sub
  simp [ideal, Matrix.IsHermitian]

private theorem readout (ψ : Vertex N × W → ℂ) (j : Vertex N) :
    (reduced ψ j j).re = ∑ k, Complex.normSq (ψ (j,k)) := by
  change (∑ k, ψ (j,k) * conj (ψ (j,k))).re = _
  simp [Complex.mul_conj]

/-- Any coherent whole-row-query circuit that, after discarding arbitrary finite
workspace, simulates the output density to trace distance ≤ 1/4 requires at least N/4
queries. The Hamiltonians have at most two entries per row and scaled time πN/2. -/
theorem no_fast_forwarding [DecidableEq W] {q : ℕ} (c : RowCircuit N (Vertex N × W) q)
    (accurate : ∀ x : Fin N → Bool,
      traceDistance (difference_hermitian (amplitudes x c) x) ≤ 1/4) :
    (∀ x : Fin N → Bool, (∀ i, (Finset.univ.filter (fun j => crossed x i j ≠ 0)).card ≤ 2) ∧
      ‖crossed x‖ * Real.pi = Real.pi*N/2) ∧ N ≤ 4*q := by
  constructor
  · intro x
    refine ⟨twoSparse x, ?_⟩
    rw [SparseParityNorm.spectral_norm]
    ring
  · let j : Vertex N := (Fin.last N, true)
    let out : Finset (Vertex N × W) := ({j} : Finset (Vertex N)) ×ˢ Finset.univ
    apply parity_query_lower_bound c out
    intro x
    obtain ⟨compiled,hc⟩ := compile c
    have normalized := PhaseQuery.amplitudes_normalized x compiled
    rw [hc] at normalized
    have tr : (reduced (amplitudes x c) - ideal x).trace = 0 := by
      rw [Matrix.trace_sub, trace_reduced, normalized, ideal, Matrix.trace_single_eq_same]
      simp
    have close := (diagonal_bound (difference_hermitian (amplitudes x c) x) tr j).trans (accurate x)
    have eval : accept c out x = (reduced (amplitudes x c) j j).re := by
      rw [readout, accept]
      simp [out]
    rw [eval]
    simp only [Matrix.sub_apply, Complex.sub_re] at close
    cases hx : prefixParity x N <;> simpa [ideal, Matrix.single, j, hx] using close.trans_lt (by norm_num : (1:ℝ)/4 < 1/2)

end FQChem.Complexity.SparseNoFastForwarding
