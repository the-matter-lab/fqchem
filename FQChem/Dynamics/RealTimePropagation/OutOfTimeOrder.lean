module

public import FQChem.Complexity.ElectronicStructurePauli
public import Mathlib.LinearAlgebra.Matrix.Trace
public import Mathlib.LinearAlgebra.UnitaryGroup
public import Mathlib.LinearAlgebra.Matrix.Permutation
import Mathlib.Tactic

/-!
# First-order infinite-temperature out-of-time-order correlators

Lewis, Mele, de Wolf, McClean and Abbas, arXiv:2611.24640, Appendix D,
equations (D.7)–(D.8). With a Z probe on site j, precisely the words carrying
X or Y there contribute to the anticommuting Pauli weight.
-/

@[expose] public section
noncomputable section

namespace FQChem.Dynamics.OTOC
open FQChem.Complexity.ElectronicStructure
open Matrix
open scoped ComplexConjugate

variable {n : ℕ}
abbrev Operator (n : ℕ) := Matrix (Spin n) (Spin n) ℂ

def wordMatrix (p : Word n) : Operator n := Matrix.of (wordEntry p)

/-- Infinite-temperature first-order OTOC of the already-evolved butterfly K and probe M. -/
def firstOrder (K M : Operator n) : ℂ := ((K * M) ^ 2).trace / 2 ^ n

def zProbe (j : Fin n) : Operator n :=
  diagonal fun x => if x j then -1 else 1

def flips (p : Pauli) : Bool := p == .X || p == .Y

private theorem dualEntry_trace (p : Word n) (x y : Spin n) :
    dualEntry p x y = wordEntry p y x / 2 ^ n := by
  simp [dualEntry, wordEntry, pauliEntry_conj, Finset.prod_div_distrib]

/-- The library's coefficient is the normalized trace pairing with a Pauli word. -/
theorem traceCoefficient (K : Operator n) (p : Word n) :
    (K * wordMatrix p).trace / 2 ^ n = pauliCoefficient K p := by
  simp only [Matrix.trace, Matrix.diag_apply, Matrix.mul_apply, pauliCoefficient,
    dualEntry_trace, Finset.sum_div, mul_div_assoc]
  rfl

private theorem expansion (K : Operator n) :
    K = ∑ p : Word n, pauliCoefficient K p • (wordMatrix p) := by
  ext x y
  simp only [Matrix.sum_apply, Matrix.smul_apply, smul_eq_mul]
  exact (pauliExpansion K x y).symm

/-- Conjugating by the local probe preserves a word with I or Z at j and
reverses the sign of a word with X or Y at j. -/
theorem zConjugation (j : Fin n) (p : Word n) :
    zProbe j * wordMatrix p * zProbe j =
      (if flips (p j) then (-1 : ℂ) else 1) • (wordMatrix p) := by
  ext x y
  simp only [zProbe, Matrix.diagonal_mul, Matrix.mul_diagonal, Matrix.smul_apply,
    smul_eq_mul]
  change _ * wordEntry p x y * _ = _ * wordEntry p x y
  rw [wordEntry_eq]
  by_cases hy : y = logicalMove p x
  · subst y
    cases hp : p j <;> cases hx : x j <;>
      simp [logicalMove, hp, hx, flips, Pauli.move]
  · simp [hy]

private theorem traceExpansion (K : Operator n) (c : Word n → ℂ) :
    (K * (∑ p : Word n, c p • wordMatrix p : Operator n)).trace / 2 ^ n =
      ∑ p, c p * pauliCoefficient K p := by
  simp only [Matrix.mul_sum, Matrix.mul_smul, Matrix.trace_sum, Matrix.trace_smul,
    smul_eq_mul, Finset.sum_div, mul_div_assoc, traceCoefficient]

/-- Parseval for a Hermitian involutory butterfly, including any unitarily
evolved Pauli. The real squared coefficients are its squared Pauli weights. -/
theorem butterflyMass (K : Operator n) (h : K.IsHermitian) (hK : K * K = 1) :
    ∑ p, (pauliCoefficient K p).re ^ 2 = 1 := by
  have hc := traceExpansion K (pauliCoefficient K)
  rw [← expansion K, hK] at hc
  have hdim : Fintype.card (Spin n) = 2 ^ n := by simp [Spin]
  simp [Matrix.trace_one, hdim] at hc
  apply Complex.ofReal_injective
  push_cast
  simpa [pow_two, pauliCoefficient_real K h] using hc.symm

/-- Equation (D.8) of Lewis et al.: the exact normalized four-point trace is
one minus twice the Pauli weight that anticommutes with the probe. -/
theorem firstOrder_eq_anticommutingMass (K : Operator n) (j : Fin n)
    (h : K.IsHermitian) (hK : K * K = 1) :
    firstOrder K (zProbe j) =
      1 - 2 * ((∑ p : Word n with flips (p j), (pauliCoefficient K p).re ^ 2 : ℝ) : ℂ) := by
  let c := pauliCoefficient K
  let s := fun p : Word n => if flips (p j) then (-1 : ℂ) else 1
  have conjugated : zProbe j * K * zProbe j =
      ∑ p : Word n, (c p * s p) • (wordMatrix p) := by
    conv_lhs => rw [expansion K]
    simp only [Matrix.mul_sum, Matrix.sum_mul, Matrix.mul_smul, Matrix.smul_mul,
      zConjugation, smul_smul, c, s]
  unfold firstOrder
  rw [pow_two, Matrix.mul_assoc, ← Matrix.mul_assoc (zProbe j), conjugated, traceExpansion]
  have mass : (∑ p, c p ^ 2) = 1 := by
    have := congrArg Complex.ofReal (butterflyMass K h hK)
    simpa [c, pauliCoefficient_real K h] using this
  push_cast
  simp only [pauliCoefficient_real K h, Finset.sum_filter]
  rw [← mass]
  simp only [Finset.mul_sum, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro p _
  by_cases hf : flips (p j) <;> simp [s, hf, c] <;> ring

/-- Omitting words from the final anticommuting-weight sum overestimates the
exact correlator by twice their discarded squared weight. -/
theorem discardedWeightError (K : Operator n) (j : Fin n) (keep : Finset (Word n))
    (h : K.IsHermitian) (hK : K * K = 1) :
    let anti := Finset.univ.filter fun p : Word n => flips (p j)
    (1 - 2 * ∑ p ∈ anti.filter (· ∈ keep), (pauliCoefficient K p).re ^ 2)
      - (firstOrder K (zProbe j)).re =
        2 * ∑ p ∈ anti.filter (· ∉ keep), (pauliCoefficient K p).re ^ 2 := by
  intro anti
  rw [firstOrder_eq_anticommutingMass K j h hK]
  simp only [Complex.sub_re, Complex.one_re, Complex.mul_re, Complex.ofReal_re,
    Complex.ofReal_im, mul_zero, sub_zero, Complex.re_ofNat]
  have split := Finset.sum_filter_add_sum_filter_not anti (· ∈ keep)
    (fun p => (pauliCoefficient K p).re ^ 2)
  dsimp only [anti] at split ⊢
  linarith

section TwoCopies

open scoped Kronecker
variable {ι : Type*} [Fintype ι] [DecidableEq ι]
def swapCopies (ι : Type*) [DecidableEq ι] : Matrix (ι × ι) (ι × ι) ℂ :=
  (Equiv.prodComm ι ι).toPEquiv.toMatrix

/-- Contracting two copies with the flip gives the trace of their product. -/
theorem swapTrace (A B : Matrix ι ι ℂ) :
    ((A ⊗ₖ B) * swapCopies ι).trace = (A * B).trace := by
  simp [swapCopies, PEquiv.mul_toMatrix_toPEquiv, Matrix.trace,
    Fintype.sum_prod_type, Matrix.mul_apply]

/-- Equation (III.2), the two-copy readout used by window propagation. -/
theorem twoCopyReadout {n : ℕ} (K M : Operator n) :
    firstOrder K M = (((K ⊗ₖ K) * (M ⊗ₖ M)) *
      swapCopies (FQChem.Complexity.ElectronicStructure.Spin n)).trace / 2 ^ n := by
  rw [← Matrix.mul_kronecker_mul, swapTrace]
  simp only [firstOrder, pow_two]

/-- Fact 1. The global flip and the identity are fixed by conjugation by
two identical unitaries, including each gate acting on the invariant tails. -/
theorem invariantTails (U : unitaryGroup ι ℂ) :
    let V := U.val ⊗ₖ U.val
    Vᴴ * (1 : Matrix (ι × ι) (ι × ι) ℂ) * V = 1 ∧
      Vᴴ * swapCopies ι * V = swapCopies ι := by
  intro V
  have unit : Vᴴ * V = 1 := (kronecker_mem_unitary U.property U.property).1
  have comm : swapCopies ι * V = V * swapCopies ι := by
    ext ⟨r,s⟩ ⟨a,b⟩
    simp [V, swapCopies, PEquiv.toMatrix_toPEquiv_mul,
      PEquiv.mul_toMatrix_toPEquiv, mul_comm]
  exact ⟨by simpa using unit, by rw [Matrix.mul_assoc,comm,← Matrix.mul_assoc,unit,one_mul]⟩
end TwoCopies

end FQChem.Dynamics.OTOC
