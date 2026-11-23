module

public import Mathlib.Analysis.InnerProductSpace.Adjoint
public import Mathlib.Analysis.Complex.Basic

/-!
# Measurements of pure states

A finite-outcome instrument is described by one Kraus map per outcome. The norm
of a branch gives its Born weight, and conditioning divides the branch by this norm.
The probability interpretation is due to [Born (1926)](https://doi.org/10.1007/BF01397477).
The projective state update follows [Lüders (1951)](https://doi.org/10.1002/andp.19504430510).
The two-outcome qubit filter is the diagonal weak-measurement construction of
[Oreshkov and Brun (2005)](https://doi.org/10.1103/PhysRevLett.95.110409).
-/

@[expose] public section
noncomputable section
namespace FormalQChem.Properties.MeasurementTheory

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E] [CompleteSpace E]
variable {ι : Type*} [Fintype ι]

def probability (K : E →L[ℂ] E) (ψ : E) := ‖K ψ‖ ^ 2

def posterior (K : E →L[ℂ] E) (ψ : E) : E := ((‖K ψ‖ : ℂ)⁻¹) • K ψ

/-- A complete Kraus family gives a probability distribution for every normalized state. -/
def BornCompleteness (K : ι → E →L[ℂ] E) : Prop :=
  (∑ i, (K i).adjoint.comp (K i)) = ContinuousLinearMap.id ℂ E →
    ∀ ψ : E, ‖ψ‖ = 1 → (∀ i, 0 ≤ probability (K i) ψ) ∧ ∑ i, probability (K i) ψ = 1

/-- Mutually orthogonal idempotent projectors give certain repeat measurement
of any outcome with positive probability, including outcomes of rank greater than one. -/
def ProjectiveRepeatability [DecidableEq ι] (P : ι → E →L[ℂ] E) : Prop :=
  (∀ i j, (P j).comp (P i) = if i = j then P i else 0) →
    ∀ ψ i, 0 < probability (P i) ψ → ‖posterior (P i) ψ‖ = 1 ∧
      ∀ j, probability (P j) (posterior (P i) ψ) = if i = j then 1 else 0

/-- Diagonal positive Kraus branch for an unsharp qubit Z measurement of signed
strength η. Opposite outcomes use η and -η, respectively. -/
def weakBranch (η : ℝ) (a b : ℂ) : ℂ × ℂ :=
  ((Real.sqrt ((1 + η) / 2) : ℂ) * a, (Real.sqrt ((1 - η) / 2) : ℂ) * b)

def branchMass (v : ℂ × ℂ) := Complex.normSq v.1 + Complex.normSq v.2

def branchZ (v : ℂ × ℂ) := (Complex.normSq v.1 - Complex.normSq v.2) / branchMass v

/-- Outcome statistics and conditional polarization for a diagonal unsharp
qubit measurement. η=0 gives the uninformative limit and η=1 the sharp Z limit. -/
def UnsharpQubit : Prop :=
  ∀ (a b : ℂ) (η : ℝ), Complex.normSq a + Complex.normSq b = 1 → -1 ≤ η → η ≤ 1 →
    let z := Complex.normSq a - Complex.normSq b
    let pos := weakBranch η a b
    branchMass pos = (1 + η * z) / 2 ∧
    branchMass pos + branchMass (weakBranch (-η) a b) = 1 ∧
    (0 < branchMass pos → branchZ pos = (z + η) / (1 + η * z))

end FormalQChem.Properties.MeasurementTheory
