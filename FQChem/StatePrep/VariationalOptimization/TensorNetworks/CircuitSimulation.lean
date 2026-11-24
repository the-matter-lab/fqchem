module

public import FQChem.StatePrep.VariationalOptimization.TensorNetworks.CircuitUpdate
import Mathlib.Tactic

/-! # Simulation of nearest-neighbour gate sequences on a matrix-product chain

The simulator updates stored site tensors without ever forming the state vector.
The statement compares its amplitudes to dense gate action on every computational
basis string. Storage is counted in scalar coefficients and work in field operations
and exact equality probes. [Vidal (2003)](https://doi.org/10.1103/PhysRevLett.91.147902)
-/

@[expose] public section
namespace FQChem.Algorithms.MPSCircuit
open Matrix
variable {K : Type*} [Field K] [DecidableEq K]

/-- An n-site chain with external dimensions l and r. Internal dimensions vary by cut. -/
inductive Chain (K : Type*) : ℕ → ℕ → ℕ → Type _
  | nil (d : ℕ) : Chain K 0 d d
  | cons {n l m r : ℕ} (site : Site K l m) (rest : Chain K n m r) : Chain K (n+1) l r

def Bits : ℕ → Type
  | 0 => Unit
  | n+1 => Fin 2 × Bits n

def Chain.coefficient : {n l r : ℕ} → Chain K n l r → Bits n → Matrix (Fin l) (Fin r) K
  | _, _, _, .nil _, _ => 1
  | _, _, _, .cons A C, (i, x) => A i * C.coefficient x

def Chain.width : {n l r : ℕ} → Chain K n l r → ℕ
  | _, _, _, .nil d => d
  | _, l, _, .cons _ rest => max l rest.width

def Chain.stored : {n l r : ℕ} → Chain K n l r → ℕ
  | _,_,_, .nil _ => 0
  | _, l, _, .cons (m := m) _ rest => 2*l*m + rest.stored

omit [Field K] [DecidableEq K] in
theorem left_le_width {n l r : ℕ} (C : Chain K n l r) : l ≤ C.width := by
  cases C with
  | nil => exact le_rfl
  | cons => exact le_max_left ..

omit [Field K] [DecidableEq K] in
/-- The n stored physical sites require at most 2nχ² scalar coefficients. -/
theorem stored_le {n l r χ : ℕ} (C : Chain K n l r) (h : C.width ≤ χ) :
    C.stored ≤ 2*n*χ^2 := by
  induction C with
  | nil => simp [Chain.stored]
  | @cons n l m r A C ih =>
    obtain ⟨hl,hC⟩ := max_le_iff.mp h
    have hm := (left_le_width C).trans hC
    calc
      2*l*m + C.stored ≤ 2*χ*χ + 2*n*χ^2 := by gcongr; exact ih hC
      _ = _ := by ring

/-- A well-addressed adjacent gate. `there` advances its address by one site. -/
inductive Gate (K : Type*) : ℕ → Type _
  | here {n : ℕ} (matrix : Matrix Pair Pair K) : Gate K (n+2)
  | there {n : ℕ} (gate : Gate K n) : Gate K (n+1)

/-- Input bit string and corresponding coefficient of the dense gate action. -/
def Gate.input : {n : ℕ} → Gate K n → Bits n → Pair → K × Bits n
  | _, .here G, (i,j,x), s => (G (i,j) s, s.1, s.2, x)
  | _, .there g, (i,x), s => let (w,y) := g.input x s; (w,i,y)

def Gate.act {n : ℕ} (g : Gate K n) (v : Bits n → K) (x : Bits n) : K :=
  ∑ s : Pair, (g.input x s).1 * v (g.input x s).2

/-- One addressed update, with its arithmetic charge. -/
def advance : {n l r : ℕ} → Gate K n → Chain K n l r → Chain K n l r × ℕ
  | _, _, _, .here G, .cons A (.cons B rest) =>
    let q := applyPair G A B
    (.cons q.left (.cons q.right rest), q.work)
  | _, _, _, .there g, .cons A rest =>
    let (rest', work) := advance g rest
    (.cons A rest', work)

theorem advance_exact {n l r : ℕ} (g : Gate K n) (C : Chain K n l r) (x : Bits n)
    (a : Fin l) (b : Fin r) :
    (advance g C).1.coefficient x a b = g.act (fun z => C.coefficient z a b) x := by
  induction g generalizing l r with
  | here G =>
    cases C with | cons A tail =>
      cases tail with | cons B rest =>
        rcases x with ⟨i,j,x⟩
        let q := applyPair G A B
        let env := rest.coefficient x
        change (q.left i * (q.right j * env)) a b = ∑ s : Pair, G (i,j) s * (A s.1 * (B s.2 * env)) a b
        simp_rw [← Matrix.mul_assoc]
        have replace (v : Fin _) :
            (q.left i * q.right j) a v = ∑ s : Pair, G (i,j) s * (A s.1 * B s.2) a v :=
          pair_entry G A B i j a v
        rw [Matrix.mul_apply]
        simp_rw [replace, Finset.sum_mul]
        rw [Finset.sum_comm]
        apply Finset.sum_congr rfl
        intro s _
        rw [Matrix.mul_apply, Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro t _
        ring
  | there g ih =>
    cases C with | cons A rest =>
      rcases x with ⟨i,x⟩
      simp only [advance, Chain.coefficient, Gate.act, Gate.input, Matrix.mul_apply]
      simp_rw [ih, Gate.act, Finset.mul_sum]
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro s _
      apply Finset.sum_congr rfl
      intro t _
      ring

/-- Each addressed update charges cubic scalar work independently of the gate's position. -/
theorem advance_work {n l r χ : ℕ} (g : Gate K n) (C : Chain K n l r) (h : C.width ≤ χ) :
    (advance g C).2 ≤ 24*χ^3 + 40*χ^2 := by
  induction g generalizing l r with
  | here G =>
    cases C with | cons A tail =>
      cases tail with | cons B rest =>
        obtain ⟨hl,h'⟩ := max_le_iff.mp h
        obtain ⟨hm,h''⟩ := max_le_iff.mp h'
        exact pair_work G A B hl hm ((left_le_width rest).trans h'')
  | there g ih =>
    cases C with | cons A rest => exact ih rest (max_le_iff.mp h).2

def simulate {n l r : ℕ} : List (Gate K n) → Chain K n l r → Chain K n l r × ℕ
  | [], C => (C,0)
  | g :: gs, C =>
    let (D, w) := advance g C
    let (E, v) := simulate gs D
    (E,w+v)

def dense {n : ℕ} : List (Gate K n) → (Bits n → K) → Bits n → K
  | [], v => v
  | g :: gs, v => dense gs (g.act v)

/-- Execution gives the same coefficient as dense circuit evolution for every bit string. -/
theorem simulate_exact {n l r : ℕ} (gs : List (Gate K n)) (C : Chain K n l r) (x : Bits n)
    (a : Fin l) (b : Fin r) : (simulate gs C).1.coefficient x a b =
      dense gs (fun z => C.coefficient z a b) x := by
  induction gs generalizing C with
  | nil => rfl
  | cons g gs ih =>
    change (simulate gs (advance g C).1).1.coefficient x a b = _
    rw [ih]
    exact congrArg (fun v => dense gs v x) (funext fun z => advance_exact g C z a b)

def peakWidth {n l r : ℕ} : List (Gate K n) → Chain K n l r → ℕ
  | [], C => C.width
  | g :: gs, C => max C.width (peakWidth gs (advance g C).1)

/-- A G-gate trajectory of actual peak bond χ costs at most G(24χ³+40χ²) scalar operations. -/
theorem simulate_work {n l r χ : ℕ} (gs : List (Gate K n)) (C : Chain K n l r)
    (h : peakWidth gs C ≤ χ) : (simulate gs C).2 ≤ gs.length * (24*χ^3 + 40*χ^2) := by
  induction gs generalizing C with
  | nil => simp [simulate]
  | cons g gs ih =>
    obtain ⟨hc,hr⟩ := max_le_iff.mp h
    calc
      (advance g C).2 + (simulate gs (advance g C).1).2 ≤
          (24*χ^3+40*χ^2) + gs.length * (24*χ^3+40*χ^2) := Nat.add_le_add (advance_work g C hc) (ih _ hr)
      _ = (gs.length+1) * (24*χ^3+40*χ^2) := by ring

end FQChem.Algorithms.MPSCircuit
