module

public import FormalQChem.Complexity.AaronsonAmbainisQuery
public import Mathlib.Analysis.Normed.Algebra.MatrixExponential
public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
public import Mathlib.Analysis.SpecialFunctions.Exponential
import Mathlib.Tactic

/-!
# Phase queries as diagonal one-electron Hamiltonian evolution

A site whose Boolean potential is on has energy π in units with ℏ = 1.
One unit of real-time evolution gives a minus sign precisely at those sites.
Query-independent unitaries can mix the orbitals between such potential pulses.
The final Born measurement gives the probability of occupation of a chosen
orbital subspace. A two-orbital calculation gives an explicit interference
experiment with positive input variance.
-/

@[expose] public section
noncomputable section

namespace FormalQChem.Complexity.PhaseQuery

open scoped Matrix
variable {N t : ℕ} {B : Type*} [Fintype B] [DecidableEq B]

/-- Binary local potential; a reference orbital with address `none` has zero energy. -/
def siteEnergy (x : Bits N) : Option (Fin N) → ℝ
  | none => 0
  | some j => if x j then Real.pi else 0

def onsiteHamiltonian (address : B → Option (Fin N)) (x : Bits N) : Matrix B B ℂ :=
  Matrix.diagonal fun b ↦ (siteEnergy x (address b) : ℂ)

omit [Fintype B] in
theorem onsiteHamiltonian_isHermitian (address : B → Option (Fin N)) (x : Bits N) :
    (onsiteHamiltonian address x).IsHermitian := by
  simp [onsiteHamiltonian, Matrix.IsHermitian, Matrix.diagonal_conjTranspose]

/-- The sign query is exactly the unit-time Schrödinger propagator for this potential. -/
theorem onsite_evolution (address : B → Option (Fin N)) (x : Bits N) :
    NormedSpace.exp ((-Complex.I) • onsiteHamiltonian address x) =
    Matrix.diagonal (fun b ↦ (phase x (address b) : ℂ)) := by
  rw [onsiteHamiltonian, ← Matrix.diagonal_smul, Matrix.exp_diagonal]
  congr 1
  funext b
  rw [Pi.coe_exp, ← Complex.exp_eq_exp_ℂ, Pi.smul_apply, smul_eq_mul]
  cases a : address b with
  | none => simp [siteEnergy, phase]
  | some j =>
    cases h : x j <;> simp [siteEnergy, h, phase, mul_comm Complex.I, Complex.exp_neg_pi_mul_I]

/-- Physical amplitudes under alternating onsite pulses and orbital mixing. -/
def orbitalEvolution (x : Bits N) : {t : ℕ} → Circuit N B t → B → ℂ
  | _, .prepare ψ _ => ψ
  | _, .query prior address gate _ =>
    gate.mulVec ((NormedSpace.exp ((-Complex.I) • onsiteHamiltonian address x)).mulVec
      (orbitalEvolution x prior))

theorem orbitalEvolution_eq (c : Circuit N B t) (x : Bits N) :
    orbitalEvolution x c = amplitudes x c := by
  induction c with
  | prepare ψ _ => rfl
  | query prior address gate hgate ih =>
    simp only [orbitalEvolution, onsite_evolution, ih, amplitudes]
    congr 1
    funext b
    exact Matrix.mulVec_diagonal _ _ _

def orbitalPopulation (c : Circuit N B t) (orbitals : Finset B) (x : Bits N) : ℝ :=
  ∑ b ∈ orbitals, Complex.normSq (orbitalEvolution x c b)

theorem orbitalPopulation_eq (c : Circuit N B t) (orbitals : Finset B) (x : Bits N) :
    orbitalPopulation c orbitals x = acceptance c orbitals x := by
  simp [orbitalPopulation, acceptance, orbitalEvolution_eq]

def halfAmplitude : ℝ := 1 / Real.sqrt 2

private theorem halfAmplitude_sq : halfAmplitude * halfAmplitude = 1 / 2 := by
  simp [halfAmplitude, ← sq, Real.sq_sqrt]

/-- Bonding one-electron state over the left and right localized orbitals. -/
def bondingState (_ : Bool) : ℂ := (halfAmplitude : ℂ)

theorem bondingNormalized : ∑ b, Complex.normSq (bondingState b) = 1 := by
  simp [bondingState, Complex.normSq_apply, halfAmplitude_sq]

/-- Rows resolve the bonding and antibonding superpositions. -/
def bondingReadout : Matrix Bool Bool ℂ := fun a b ↦
  if a && b then -(halfAmplitude : ℂ) else (halfAmplitude : ℂ)

theorem bondingReadout_unitary : (bondingReadout : Matrix Bool Bool ℂ)ᴴ * bondingReadout = 1 := by
  have hc : (halfAmplitude : ℂ) * halfAmplitude = 1 / 2 := by
    rw [← Complex.ofReal_mul, halfAmplitude_sq]
    norm_num
  ext i j
  cases i <;> cases j <;> norm_num [bondingReadout, Matrix.mul_apply, Fintype.sum_bool,
    Matrix.conjTranspose_apply, Matrix.one_apply, hc]

/-- A local pulse on the right orbital followed by a bonding/antibonding measurement. -/
def twoOrbitalProbe : Circuit 1 Bool 1 :=
  .query (.prepare bondingState bondingNormalized)
    (fun right ↦ if right then some 0 else none) bondingReadout bondingReadout_unitary

theorem antibondingPopulation (x : Bits 1) :
    orbitalPopulation twoOrbitalProbe {true} x = if x 0 then 1 else 0 := by
  rw [orbitalPopulation_eq]
  have hc : (halfAmplitude : ℂ) * halfAmplitude = 1 / 2 := by
    rw [← Complex.ofReal_mul, halfAmplitude_sq]
    norm_num
  cases h : x 0 <;>
    norm_num [acceptance, amplitudes, twoOrbitalProbe, bondingReadout, bondingState,
      Matrix.mulVec_apply_eq_sum, Fintype.sum_bool, phase, h, hc]

end FormalQChem.Complexity.PhaseQuery
