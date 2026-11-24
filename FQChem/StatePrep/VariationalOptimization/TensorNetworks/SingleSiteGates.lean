module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.GateRouting
public import Mathlib.LinearAlgebra.Matrix.Kronecker
import Mathlib.Tactic

/-! # Embedding one-qubit gates into the routed simulator -/

@[expose] public section
namespace FQChem.Algorithms.MPSCircuit.Routing
open Matrix
open scoped Kronecker
variable {K : Type*} [Field K]

/-- A single valid wire position in the register. -/
inductive Wire : ℕ → Type
  | first {k : ℕ} : Wire (k+1)
  | later {k : ℕ} (p : Wire k) : Wire (k+1)

def Wire.window : {n : ℕ} → Wire n → Bits n → Fin 2 → Fin 2 × Bits n
  | _, .first, (i,x), j => (i,j,x)
  | _, .later p, (i,x), j => let (b,y) := p.window x j; (b,i,y)

def Wire.act {n : ℕ} (p : Wire n) (U : Matrix (Fin 2) (Fin 2) K) (v : Bits n → K) (x : Bits n) :=
  ∑ j, U (p.window x j).1 j * v (p.window x j).2

def embedLeft (U : Matrix (Fin 2) (Fin 2) K) := U ⊗ₖ (1 : Matrix (Fin 2) (Fin 2) K)
def embedRight (U : Matrix (Fin 2) (Fin 2) K) := (1 : Matrix (Fin 2) (Fin 2) K) ⊗ₖ U

/-- A singleton register needs only its two amplitudes and an ordinary matrix-vector product. -/
theorem oneWire {v : Bits 1 → K} (U : Matrix (Fin 2) (Fin 2) K) (i : Fin 2) :
    Wire.first.act U v (i,()) = (U *ᵥ fun j => v (j,())) i := rfl

/-- Evaluate an entire one-wire circuit by storing the current pair of amplitudes.
Each gate computes two length-two dot products, charged eight scalar operations. -/
def oneWireRun : List (Matrix (Fin 2) (Fin 2) K) → (Fin 2 → K) → (Fin 2 → K) × ℕ
  | [], v => (v, 0)
  | U :: gs, v =>
    let next := MPSElimination.table fun i => (U *ᵥ v) i
    let out := oneWireRun gs next
    (out.1, 8 + out.2)

theorem oneWireCircuit (gs : List (Matrix (Fin 2) (Fin 2) K)) (v : Fin 2 → K) :
    (oneWireRun gs v).1 = gs.foldl (fun u U => U *ᵥ u) v ∧ (oneWireRun gs v).2 = 8*gs.length := by
  induction gs generalizing v with
  | nil => simp [oneWireRun]
  | cons U gs ih =>
    have eq : MPSElimination.table (fun i => (U *ᵥ v) i) = U *ᵥ v := by funext i; exact MPSElimination.table_apply ..
    simp [oneWireRun, eq, (ih (U *ᵥ v)).1, (ih (U *ᵥ v)).2, Nat.mul_add, Nat.add_comm]

/-- On larger registers use the adjacent pair containing the target. At the right boundary
the other qubit precedes it. The unused qubit is acted on by the identity. -/
def Wire.encoded (U : Matrix (Fin 2) (Fin 2) K) : {k : ℕ} → Wire (k+2) →
    Address (k+2) × Matrix Pair Pair K
  | _, .first => (.first .near, embedLeft U)
  | 0, .later .first => (.first .near, embedRight U)
  | k+1, .later p =>
    let (a,G) := p.encoded (k := k) U
    (.later a, G)

private theorem embedLeft_act {k : ℕ} (U : Matrix (Fin 2) (Fin 2) K) (v : Bits (k+2) → K)
    (i j : Fin 2) (x : Bits k) :
    (Address.first .near).act (embedLeft U) v (i,j,x) = ∑ a, U i a * v (a,j,x) := by
  simp [Address.act, Address.window, Distance.window, embedLeft,
    Fintype.sum_prod_type, Matrix.one_apply]

private theorem embedRight_act {k : ℕ} (U : Matrix (Fin 2) (Fin 2) K) (v : Bits (k+2) → K)
    (i j : Fin 2) (x : Bits k) :
    (Address.first .near).act (embedRight U) v (i,j,x) = ∑ a, U j a * v (i,a,x) := by
  simp [Address.act, Address.window, Distance.window, embedRight,
    Fintype.sum_prod_type, Matrix.one_apply]

/-- The dense addressed-pair semantics of the compiled gate equal the one-wire action. -/
theorem Wire.encoded_exact {k : ℕ} (p : Wire (k+2)) (U : Matrix (Fin 2) (Fin 2) K)
    (v : Bits (k+2) → K) (x : Bits (k+2)) :
    (p.encoded U).1.act (p.encoded U).2 v x = p.act U v x := by
  induction k with
  | zero =>
    cases p with
    | first => exact embedLeft_act U v x.1 x.2.1 x.2.2
    | later p =>
      cases p with
      | first => exact embedRight_act U v x.1 x.2.1 x.2.2
      | later p => nomatch p
  | succ k ih =>
    cases p with
    | first => exact embedLeft_act U v x.1 x.2.1 x.2.2
    | later p =>
      rcases x with ⟨i,x⟩
      simpa [Wire.encoded, Address.act, Address.window, Wire.act, Wire.window] using ih p (fun y => v (i,y)) x

/-- Unitarity or any given inverse of the 2×2 gate supplies an inverse of the 4×4 embedding. -/
theorem Wire.encoded_inverse {k : ℕ} (p : Wire (k+2)) (U V : Matrix (Fin 2) (Fin 2) K)
    (h : V*U = 1) : (p.encoded V).2 * (p.encoded U).2 = 1 := by
  have hl : embedLeft V * embedLeft U = 1 := by
    simp [embedLeft, ← Matrix.mul_kronecker_mul, h]
  have hr : embedRight V * embedRight U = 1 := by
    simp [embedRight, ← Matrix.mul_kronecker_mul, h]
  induction k with
  | zero =>
    cases p with
    | first => exact hl
    | later p =>
      cases p with
      | first => exact hr
      | later p => nomatch p
  | succ k ih =>
    cases p with
    | first => exact hl
    | later p => exact ih p

end FQChem.Algorithms.MPSCircuit.Routing
