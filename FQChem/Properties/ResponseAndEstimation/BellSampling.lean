module

public import FQChem.Complexity.ElectronicStructurePauli
import all FQChem.Complexity.ElectronicStructurePauli
import Mathlib.Tactic

/-!
# Learning Pauli expectations from pairs of copies

Huang et al., *Quantum advantage in learning from experiments*, Appendix D.2
(https://doi.org/10.1126/science.abn7293). The same set of Bell measurements
on pairs of corresponding qubits estimates the squared expectation of any
subsequently specified Pauli string. The algebra holds for arbitrary matrices
and specializes to probabilities when the input is a density matrix.
-/

@[expose] public section
noncomputable section
namespace FQChem.Properties.BellSampling

open FQChem.Complexity.ElectronicStructure
open scoped ComplexConjugate

/-- Flip and phase bits label (|0,f⟩ + (-1)^z |1,1⊕f⟩)/√2. -/
abbrev Bell := Bool × Bool

def sign (b : Bool) : ℂ := if b then -1 else 1

/-- Computational-basis entry of the rank-one Bell projector. -/
def projector (b : Bell) (r u c v : Bool) : ℂ :=
  if u = (r ^^ b.1) ∧ v = (c ^^ b.1) then sign (b.2 && (r ^^ c)) / 2 else 0

/-- Eigenvalue of P ⊗ P in the measured Bell state. -/
def readout (p : Pauli) (b : Bell) : ℂ :=
  match p with
  | .I => 1
  | .X => sign b.2
  | .Y => -sign (b.1 ^^ b.2)
  | .Z => sign b.1

theorem bellResolution (p : Pauli) (r u c v : Bool) :
    ∑ b : Bell, projector b r u c v * readout p b = p.entry r c * p.entry u v := by
  cases p <;> cases r <;> cases u <;> cases c <;> cases v <;>
    norm_num [Fintype.sum_prod_type, Fintype.sum_bool, projector, readout, sign,
      Pauli.entry, Pauli.phase, Pauli.move, Complex.I_mul_I]

variable {n : ℕ}

/-- Trace of ρ⊗ρ against the product of the measured Bell projectors. -/
def bornWeight (ρ : Matrix (Spin n) (Spin n) ℂ) (b : Fin n → Bell) : ℂ :=
  ∑ x : Spin n × Spin n, ∑ y : Spin n × Spin n, (ρ x.1 y.1 * ρ x.2 y.2) *
    ∏ i, projector (b i) (y.1 i) (y.2 i) (x.1 i) (x.2 i)

/-- Appendix D: the product of the local Bell signs is unbiased for Tr(ρP)².
The measurement distribution is independent of the choice of P. -/
theorem squaredPauliExpectation (ρ : Matrix (Spin n) (Spin n) ℂ) (p : Word n) :
    ∑ b : Fin n → Bell, bornWeight ρ b * ∏ i, readout (p i) (b i) =
      (∑ x, ∑ y, ρ x y * wordEntry p y x) ^ 2 := by
  let g := fun (x y : Spin n) => ρ x y * wordEntry p y x
  calc
    _ = ∑ x : Spin n × Spin n, ∑ y : Spin n × Spin n, g x.1 y.1 * g x.2 y.2 := by
      simp only [bornWeight, Finset.sum_mul, mul_assoc, ← Finset.prod_mul_distrib]
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro x _
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro y _
      rw [← Finset.mul_sum, ← Finset.mul_sum, ← Fintype.prod_sum
        (fun (i : Fin n) (b : Bell) => projector b (y.1 i) (y.2 i) (x.1 i) (x.2 i) * readout (p i) b)]
      simp only [bellResolution, Finset.prod_mul_distrib, g, wordEntry]
      ring
    _ = ∑ x : Spin n × Spin n, (∑ y, g x.1 y) * (∑ y, g x.2 y) := by
      apply Finset.sum_congr rfl
      intro x _
      rw [Fintype.sum_prod_type, Finset.sum_mul_sum]
    _ = _ := by
      change _ = (∑ x, ∑ y, g x y) ^ 2
      rw [sq, Fintype.sum_prod_type]
      rw [Finset.sum_mul]
      apply Finset.sum_congr rfl
      intro x _
      rw [Finset.mul_sum]

/-- Huang et al., Appendix D.2.b, Eq. (D6). Hermiticity makes the Pauli
expectation real, so a Bell sign has mean equal to its squared magnitude.
For a density operator the weights on the left are the Born probabilities. -/
theorem magnitudeSquaredPauliExpectation (ρ : Matrix (Spin n) (Spin n) ℂ)
    (hρ : ρ.IsHermitian) (p : Word n) :
    ∑ b : Fin n → Bell, bornWeight ρ b * ∏ i, readout (p i) (b i) =
      ((‖∑ x, ∑ y, ρ x y * wordEntry p y x‖ ^ 2 : ℝ) : ℂ) := by
  let z := ∑ x, ∑ y, ρ x y * wordEntry p y x
  have hz : conj z = z := by
    change conj (∑ x, ∑ y, ρ x y * wordEntry p y x) = ∑ x, ∑ y, ρ x y * wordEntry p y x
    simp only [map_sum, map_mul, wordEntry_conj]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun y _ =>
      congrArg (· * wordEntry p y x) (hρ.apply x y)
  rw [squaredPauliExpectation]
  change z ^ 2 = ((‖z‖ ^ 2 : ℝ) : ℂ)
  rw [Complex.sq_norm, Complex.normSq_eq_conj_mul_self, hz, pow_two]

end FQChem.Properties.BellSampling
