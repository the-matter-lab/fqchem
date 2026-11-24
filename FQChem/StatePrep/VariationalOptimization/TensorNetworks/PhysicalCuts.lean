module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.CircuitSimulation

/-! # Physical coefficient matrices at contiguous cuts of a qubit state -/

@[expose] public section
namespace FQChem.Algorithms.MPSCircuit
variable {K : Type*} [Field K]

instance bitsFintype : (n : ℕ) → Fintype (Bits n)
  | 0 => (inferInstance : Fintype Unit)
  | n+1 => letI := bitsFintype n; (inferInstance : Fintype (Fin 2 × Bits n))

/-- An intrinsic Schmidt-rank bound. At each cut, prior physical bits index the rows
and the remaining bits index the columns. No available MPS representation enters this
definition. The endpoint indices allow rectangular boundary conditions. -/
def CutBound (χ : ℕ) {r : ℕ} : {n : ℕ} → {X : Type*} → [Fintype X] →
    (X → Bits n → Fin r → K) → Prop
  | 0, _, _, v => (Matrix.of fun x (z : Bits 0 × Fin r) => v x z.1 z.2).rank ≤ χ
  | n+1, X, _, v =>
    (Matrix.of fun x (z : Bits (n+1) × Fin r) => v x z.1 z.2).rank ≤ χ ∧
    CutBound χ (n := n) (X := X × Fin 2) (fun p y b => v p.1 (p.2,y) b)

def PhysicalCuts {n : ℕ} (v : Bits n → K) (χ : ℕ) :=
  CutBound χ (n := n) (X := Fin 1) (r := 1) (fun _ x _ => v x)

end FQChem.Algorithms.MPSCircuit
