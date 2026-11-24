module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.CircuitSimulation
import Mathlib.Tactic

/-! # Readout of a simulated MPS circuit

Contraction of single-site observables against an open-boundary MPS computes
the final Born expectation. [Vidal (2003), paragraph before Theorem 1](https://doi.org/10.1103/PhysRevLett.91.147902).
-/

@[expose] public section
namespace FQChem.Algorithms.MPSCircuit
open Matrix MPSElimination
variable {K : Type*} [Field K] [StarRing K]
open scoped Matrix

/-- Interleaving a bra and a ket bit at every physical position. -/
def Pattern : ℕ → Type
  | 0 => Unit
  | n+1 => Pair × Pattern n

instance patternFintype : (n : ℕ) → Fintype (Pattern n)
  | 0 => (inferInstance : Fintype Unit)
  | n+1 => letI := patternFintype n; (inferInstance : Fintype (Pair × Pattern n))

def bra : {n : ℕ} → Pattern n → Bits n
  | 0, _ => ()
  | _+1, (s,p) => (s.1, bra p)

def ket : {n : ℕ} → Pattern n → Bits n
  | 0, _ => ()
  | _+1, (s,p) => (s.2, ket p)

/-- Each bra/ket pair occurs once in the product-observable contraction. -/
def patternEquiv : (n : ℕ) → Pattern n ≃ Bits n × Bits n
  | 0 => { toFun := fun _ => ((),()), invFun := fun _ => (), left_inv := by rintro ⟨⟩; rfl,
           right_inv := by rintro ⟨⟨⟩,⟨⟩⟩; rfl }
  | n+1 =>
    { toFun := fun (s,p) => ((s.1, (patternEquiv n p).1), (s.2, (patternEquiv n p).2))
      invFun := fun ((i,x),(j,y)) => ((i,j),(patternEquiv n).symm (x,y))
      left_inv := by rintro ⟨⟨i,j⟩,p⟩; dsimp; rw [Equiv.symm_apply_apply]
      right_inv := by rintro ⟨⟨i,x⟩,⟨j,y⟩⟩; simp }

theorem pattern_bits {n : ℕ} (p : Pattern n) : patternEquiv n p = (bra p, ket p) := by
  induction n with
  | zero => rfl
  | succ n ih => rcases p with ⟨⟨i,j⟩,p⟩; simp [patternEquiv, ih, ket, bra]

abbrev Observable (K : Type*) (n : ℕ) := Fin n → Matrix (Fin 2) (Fin 2) K

def productEntry : {n : ℕ} → Observable K n → Pattern n → K
  | 0, _, _ => 1
  | _+1, O, (s,p) => O 0 s.1 s.2 * productEntry (Fin.tail O) p

def mulTable {l m r : ℕ} (A : Matrix (Fin l) (Fin m) K) (B : Matrix (Fin m) (Fin r) K) :=
  Matrix.of (table fun i => table fun j => ∑ t, A i t * B t j)

omit [StarRing K] in
theorem mulTable_eq {l m r : ℕ} (A : Matrix (Fin l) (Fin m) K) (B : Matrix (Fin m) (Fin r) K) :
    mulTable A B = A * B := by
  ext i j
  rw [Matrix.mul_apply]; simp [mulTable]

def localTransfer {l m : ℕ} (A : Site K l m) (O : Matrix (Fin 2) (Fin 2) K)
    (S : Matrix (Fin m) (Fin m) K) :=
  let values := table fun z : Fin 4 =>
    let s : Pair := finProdFinEquiv.symm z
    mulTable (mulTable (A s.2) S) (A s.1)ᴴ
  Matrix.of (table fun i : Fin l => table fun j : Fin l =>
    ∑ s : Pair, O s.1 s.2 * values (finProdFinEquiv s) i j)

theorem localTransfer_eq {l m : ℕ} (A : Site K l m) (O : Matrix (Fin 2) (Fin 2) K)
    (S : Matrix (Fin m) (Fin m) K) :
    localTransfer A O S = ∑ s : Pair, O s.1 s.2 • (A s.2 * S * (A s.1)ᴴ) := by
  ext i j
  simp only [localTransfer, Matrix.of_apply, table_apply, Equiv.symm_apply_apply, mulTable_eq,
    Matrix.sum_apply, Matrix.smul_apply, smul_eq_mul]

/-- Right-to-left contraction of the product observable. -/
def readout : {n l r : ℕ} → Chain K n l r → Observable K n →
    Matrix (Fin r) (Fin r) K → Matrix (Fin l) (Fin l) K
  | _,_,_, .nil _, _, E => E
  | _,_,_, .cons A C, O, E => localTransfer A (O 0) (readout C (Fin.tail O) E)

/-- Sum over all pairs of basis strings, with their product-observable matrix elements. -/
theorem readout_exact {n l r : ℕ} (C : Chain K n l r) (O : Observable K n)
    (E : Matrix (Fin r) (Fin r) K) :
    readout C O E = ∑ p : Pattern n, productEntry O p •
      (C.coefficient (ket p) * E * (C.coefficient (bra p))ᴴ) := by
  induction C with
  | nil d =>
    change E = ∑ _ : Unit, (1 : K) • ((1 : Matrix (Fin d) (Fin d) K) * E * (1 : Matrix (Fin d) (Fin d) K)ᴴ)
    simp
  | @cons n l m r A C ih =>
    rw [readout, localTransfer_eq, ih]
    change _ = ∑ p : Pair × Pattern n, productEntry O p •
      ((Chain.cons A C).coefficient (ket p) * E * ((Chain.cons A C).coefficient (bra p))ᴴ)
    conv_rhs => rw [Fintype.sum_prod_type]
    apply Finset.sum_congr rfl
    intro s _
    simp only [Matrix.mul_sum, Matrix.sum_mul, Finset.smul_sum, Matrix.mul_smul, Matrix.smul_mul,
      smul_smul, productEntry, Chain.coefficient, ket, bra, Matrix.conjTranspose_mul, Matrix.mul_assoc]

/-- Work charged to the dense tables, including scalar conjugations made in the second
matrix multiply. Each selected matrix element is evaluated by a finite dot product. -/
def readoutWork : {n l r : ℕ} → Chain K n l r → ℕ
  | _,_,_, .nil _ => 0
  | _,l,_, .cons (m := m) _ C => 8*l*m^2 + 12*l^2*m + 8*l^2 + readoutWork C

omit [Field K] [StarRing K] in
theorem readout_work {n l r χ : ℕ} (C : Chain K n l r) (h : C.width ≤ χ) :
    readoutWork C ≤ n * (20*χ^3 + 8*χ^2) := by
  induction C with
  | nil => simp [readoutWork]
  | @cons n l m r A C ih =>
    obtain ⟨hl,hc⟩ := max_le_iff.mp h
    have hm := (left_le_width C).trans hc
    calc
      8*l*m^2 + 12*l^2*m + 8*l^2 + readoutWork C ≤
          8*χ*χ^2 + 12*χ^2*χ + 8*χ^2 + n*(20*χ^3+8*χ^2) := by gcongr; exact ih hc
      _ = (n+1)*(20*χ^3+8*χ^2) := by ring

end FQChem.Algorithms.MPSCircuit
