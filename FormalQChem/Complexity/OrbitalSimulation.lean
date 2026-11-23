module

public import FormalQChem.Complexity.AaronsonAmbainisOrbitals

/-! # A term-query lower bound for simulating a two-orbital Hamiltonian

N Boolean terms set a single onsite energy between 0 and π. At time N a
bonding/antibonding readout of its propagator reveals their parity. A quantum
circuit with phase-query access to individual input bits therefore needs at
least N/2 queries even to approximate this one population with error < 1/2.
The access model matters: an oracle for the *summed* energy supplies different
information. See [Beals et al.](https://arxiv.org/abs/quant-ph/9802049) for the
polynomial method and [Berry et al.](https://arxiv.org/abs/quant-ph/0508139)
for a no-fast-forwarding theorem in the sparse-matrix oracle model. -/

@[expose] public section
noncomputable section

namespace FormalQChem.Complexity.OrbitalSimulation

open FormalQChem.Complexity.PhaseQuery
open scoped Matrix
variable {N : ℕ}

def bitSign (b : Bool) : ℝ := if b then -1 else 1

def parity (x : Bits N) : ℝ := ∏ i, bitSign (x i)

private theorem parity_cases (x : Bits N) : parity x = 1 ∨ parity x = -1 := by
  have h : |parity x| = 1 := by
    simp [parity, Finset.abs_prod, bitSign, apply_ite abs]
  exact (abs_eq (by norm_num : (0 : ℝ) ≤ 1)).mp h

/-- Every degree < N polynomial has zero correlation with parity on the uniform cube. -/
theorem parity_orthogonal (p : Poly N) (h : p.totalDegree < N) :
    ∑ x : Bits N, parity x * MvPolynomial.eval (bitsReal x) p = 0 := by
  simp only [MvPolynomial.eval_eq', Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_eq_zero
  intro d hd
  obtain ⟨i, hi⟩ := p.exists_degree_lt 1 (by simpa using h) hd
  have zeroPower : d i = 0 := by omega
  let f := fun j (b : Bool) => bitSign b * (if b then (1 : ℝ) else 0) ^ d j
  have point (x : Bits N) : parity x * (p.coeff d * ∏ j, bitsReal x j ^ d j) =
      p.coeff d * ∏ j, f j (x j) := by
    simp only [parity, f, bitsReal, Finset.prod_mul_distrib]
    ring
  simp_rw [point]
  rw [← Finset.mul_sum, ← Fintype.prod_sum]
  suffices (∏ j, ∑ b, f j b) = 0 by rw [this, mul_zero]
  apply Finset.prod_eq_zero (Finset.mem_univ i)
  simp [f, zeroPower, bitSign]

/-- The onsite energy is an average of N binary potential terms. -/
def onsite (x : Bits N) : ℝ := (∑ i, siteEnergy x (some i)) / N

theorem onsite_bounds (x : Bits N) : 0 ≤ onsite x ∧ onsite x ≤ Real.pi := by
  have pos (i : Fin N) : 0 ≤ siteEnergy x (some i) := by
    dsimp [siteEnergy]; split <;> positivity
  refine ⟨div_nonneg (Finset.sum_nonneg fun i _ => pos i) (Nat.cast_nonneg N), ?_⟩
  by_cases h : N = 0
  · simp [onsite, h, Real.pi_pos.le]
  · apply (div_le_iff₀ (by exact_mod_cast Nat.pos_of_ne_zero h : (0 : ℝ) < N)).mpr
    have hi (i : Fin N) : siteEnergy x (some i) ≤ Real.pi := by
      dsimp [siteEnergy]; split <;> first | rfl | exact Real.pi_pos.le
    simpa [mul_comm] using Finset.sum_le_sum (s := Finset.univ) (fun i _ => hi i)

def hamiltonian (x : Bits N) : Matrix Bool Bool ℂ :=
  Matrix.diagonal fun right => if right then (onsite x : ℂ) else 0

theorem hermitian (x : Bits N) : (hamiltonian x).IsHermitian := by
  simp [hamiltonian, Matrix.IsHermitian, Matrix.diagonal_conjTranspose, apply_ite]

def propagator (x : Bits N) := NormedSpace.exp ((-(N : ℂ) * Complex.I) • hamiltonian x)

/-- Exact evolution through time N. The right orbital acquires the parity phase. -/
theorem evolution {N : ℕ} (hN : 0 < N) (x : Bits N) :
    propagator x = Matrix.diagonal (fun right => if right then (parity x : ℂ) else 1) := by
  rw [propagator, hamiltonian, ← Matrix.diagonal_smul, Matrix.exp_diagonal]
  congr 1
  funext b
  rw [Pi.coe_exp, ← Complex.exp_eq_exp_ℂ, Pi.smul_apply, smul_eq_mul]
  cases b
  · simp
  · simp only [ite_true]
    have hn : (N : ℂ) ≠ 0 := by exact_mod_cast hN.ne'
    have ht : -(N : ℂ) * Complex.I * (onsite x : ℂ) =
        ∑ i, (-Complex.I) * (siteEnergy x (some i) : ℂ) := by
      simp only [onsite, Complex.ofReal_div, Complex.ofReal_natCast, Complex.ofReal_sum, ← Finset.mul_sum]
      field_simp
    rw [ht, Complex.exp_sum]
    simp only [parity, Complex.ofReal_prod]
    apply Finset.prod_congr rfl
    intro i _
    cases hi : x i <;> simp [siteEnergy, hi, bitSign, neg_mul, mul_comm Complex.I, Complex.exp_neg]

/-- Antibonding output probability after evolving the bonding state. -/
def population (x : Bits N) : ℝ :=
  Complex.normSq ((bondingReadout.mulVec ((propagator x).mulVec bondingState)) true)

theorem population_parity (hN : 0 < N) (x : Bits N) : population x = (1 - parity x) / 2 := by
  have hhalf : (halfAmplitude : ℂ) * halfAmplitude = 1 / 2 := by
    rw [← Complex.ofReal_mul]
    have : halfAmplitude * halfAmplitude = 1 / 2 := by simp [halfAmplitude, ← sq, Real.sq_sqrt]
    norm_num [this]
  rw [population, evolution hN x]
  rcases parity_cases x with h | h <;>
    norm_num [h, Matrix.mulVec_diagonal, Matrix.mulVec_apply_eq_sum, Fintype.sum_bool,
      bondingReadout, bondingState, hhalf]

/-- In the term-phase-query model, bounded-error simulation of this population
through physical time N needs at least N/2 calls to the input oracle. -/
theorem simulation_query_lower_bound {B : Type*} [Fintype B] [DecidableEq B]
    {T : ℕ} (c : Circuit N B T) (outcome : Finset B)
    (accurate : ∀ x, |acceptance c outcome x - population x| < 1/2) : N ≤ 2*T := by
  by_contra! h
  have hN : 0 < N := by omega
  let p := acceptancePolynomial c outcome
  let q : Poly N := 1 - 2 * p
  have deg : q.totalDegree < N := by
    apply lt_of_le_of_lt (MvPolynomial.totalDegree_sub _ _) _
    simp only [MvPolynomial.totalDegree_one, zero_le, max_eq_right]
    have hp := acceptancePolynomial_degree c outcome
    have hc : (2 : Poly N).totalDegree = 0 := by
      simpa only [map_ofNat] using (MvPolynomial.totalDegree_C (σ := Fin N) (2 : ℝ))
    exact (MvPolynomial.totalDegree_mul _ _).trans_lt (by simpa [hc] using hp.trans_lt h)
  have hz := parity_orthogonal q deg
  have positive (x : Bits N) : 0 < parity x * MvPolynomial.eval (bitsReal x) q := by
    have bound := accurate x
    rw [population_parity hN] at bound
    simp only [q, map_sub, map_one, map_mul, map_ofNat, p, acceptancePolynomial_eval]
    rcases parity_cases x with eq | eq <;> rw [eq] at bound ⊢ <;> rcases abs_lt.mp bound with ⟨lo, hi⟩ <;> linarith
  exact (ne_of_gt (Finset.sum_pos (fun x _ => positive x) Finset.univ_nonempty)) hz

end FormalQChem.Complexity.OrbitalSimulation
