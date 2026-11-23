module

public import Mathlib.Analysis.Matrix.PosDef
public import Mathlib.LinearAlgebra.Matrix.Trace

/-!
# Operator-sum quantum channels

The ancilla extension acts on every system block of the joint matrix, including
off-diagonal ancilla coherences. References are [Kraus (1971)](https://doi.org/10.1016/0003-4916(71)90108-4)
and [Choi (1975)](https://doi.org/10.1016/0024-3795(75)90075-0).
-/

@[expose] public section
noncomputable section
namespace FormalQChem.Dynamics.OpenSystems.Kraus

open scoped Matrix ComplexOrder

variable {d k : ℕ}

def operation (K : Fin k → Matrix (Fin d) (Fin d) ℂ) (ρ : Matrix (Fin d) (Fin d) ℂ) :=
  ∑ i, K i * ρ * (K i)ᴴ

/-- Matrix amplification idₐ ⊗ Φ, expressed by applying Φ to each system block. -/
def amplify (a : ℕ) (Φ : Matrix (Fin d) (Fin d) ℂ → Matrix (Fin d) (Fin d) ℂ)
    (ρ : Matrix (Fin a × Fin d) (Fin a × Fin d) ℂ) : Matrix (Fin a × Fin d) (Fin a × Fin d) ℂ :=
  Matrix.of fun r c => Φ (ρ.submatrix (Prod.mk r.1) (Prod.mk c.1)) r.2 c.2

def ComplexLinearity (K : Fin k → Matrix (Fin d) (Fin d) ℂ) : Prop :=
  ∀ (c : ℂ) ρ σ, operation K (c • ρ + σ) = c • operation K ρ + operation K σ

def CompletePositivity (K : Fin k → Matrix (Fin d) (Fin d) ℂ) : Prop :=
  ∀ a ρ, Matrix.PosSemidef ρ → Matrix.PosSemidef (amplify a (operation K) ρ)

def TracePreservation (K : Fin k → Matrix (Fin d) (Fin d) ℂ) : Prop :=
  (∑ i, (K i)ᴴ * K i) = 1 → ∀ ρ, Matrix.trace (operation K ρ) = Matrix.trace ρ

/-- A trace-one positive matrix remains a density matrix under the local operation,
even for entangled inputs and an arbitrary finite ancilla. -/
def JointDensityPreservation (K : Fin k → Matrix (Fin d) (Fin d) ℂ) : Prop :=
  (∑ i, (K i)ᴴ * K i) = 1 → ∀ a ρ, Matrix.PosSemidef ρ → Matrix.trace ρ = 1 →
    Matrix.PosSemidef (amplify a (operation K) ρ) ∧ Matrix.trace (amplify a (operation K) ρ) = 1

end FormalQChem.Dynamics.OpenSystems.Kraus
