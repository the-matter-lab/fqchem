module

public import FQChem.Complexity.SpinPathEvolution
public import FQChem.Complexity.OrbitalSimulation
public import Mathlib.LinearAlgebra.Matrix.Kronecker
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic

/-!
# Coherent queries to the crossed sparse path

An answer consists of the two edge-crossing bits in a row of the Berry et al.
path. The row index determines the weights and level indices. In the character
basis of the two XOR-answer bits a query multiplies each amplitude by the
product of the requested signs. The compiler below implements this entire row
lookup with at most two ordinary input-bit phase queries.
-/

@[expose] public section
noncomputable section

namespace FQChem.Complexity.SparseParityQueries

open FQChem.Complexity PhaseQuery SparseParityPath
open scoped Matrix
variable {N : ℕ} {B : Type*} [Fintype B] [DecidableEq B]

/-- For a particular basis address choose the row level and the two character
bits of the XOR answer register. Empty incident edges contribute phase one. -/
structure Address (N : ℕ) where
  level : Level N
  left : Bool
  right : Bool

def left (a : Address N) : Option (Fin N) :=
  if a.left then if h : 0 < a.level.val then some ⟨a.level.val - 1, by have := a.level.isLt; omega⟩
    else none else none

def right (a : Address N) : Option (Fin N) :=
  if a.right then if h : a.level.val < N then some ⟨a.level.val,h⟩ else none else none

/-- Independently chosen Fourier characters multiply on the two-bit XOR group. -/
def character (mask value : Bool × Bool) : ℝ :=
  OrbitalSimulation.bitSign ((mask.1 && value.1) ^^ (mask.2 && value.2))

theorem xor_character (mask response delta : Bool × Bool) :
    character mask (response.1 ^^ delta.1,response.2 ^^ delta.2) =
      character mask response * character mask delta := by
  rcases mask with ⟨a,b⟩; rcases response with ⟨u,v⟩; rcases delta with ⟨p,q⟩
  cases a <;> cases b <;> cases u <;> cases v <;> cases p <;> cases q <;> norm_num [character, OrbitalSimulation.bitSign]

def response (x : Bits N) (j : Level N) : Bool × Bool :=
  (if j.val = 0 then false else bit x (j.val-1),bit x j)

/-- Decode the two adjacent crossings into the actual weighted matrix entries. -/
def decodeRow (r : Vertex N) (d : Bool × Bool) (c : Vertex N) : ℂ :=
  if r.1.val+1 = c.1.val then
    if c.2 = (r.2 ^^ d.2) then weight N r.1 else 0
  else if c.1.val+1 = r.1.val then
    if r.2 = (c.2 ^^ d.1) then weight N c.1 else 0
  else 0

theorem response_decodes (x : Bits N) (r : Vertex N) :
    decodeRow r (response x r.1) = crossed x r := by
  funext c
  by_cases h : c.1.val + 1 = r.1.val
  · have hz : r.1.val ≠ 0 := by omega
    have hp : r.1.val-1 = c.1.val := by omega
    simp [decodeRow,response,crossed,h,hz,hp]
  · simp [decodeRow,response,crossed,h]

abbrev Answer := Bool × Bool

def xor (b d : Answer) : Answer := (b.1 ^^ d.1, b.2 ^^ d.2)

/-- Computational-basis lookup adds the two incident bits by reversible XOR. -/
def translate (d : Answer) : Matrix Answer Answer ℂ :=
  Matrix.of fun a b => if a = xor b d then 1 else 0

/-- The normalized Walsh transform of the two-bit answer register. -/
def walsh : Matrix Answer Answer ℂ := Matrix.of fun a b => (character a b : ℂ) / 2

private theorem walsh_adjoint : walshᴴ = walsh := by
  ext ⟨a,b⟩ ⟨u,v⟩
  cases a <;> cases b <;> cases u <;> cases v <;>
    norm_num [walsh, character, OrbitalSimulation.bitSign, Matrix.conjTranspose_apply]

private theorem walsh_square : walsh * walsh = 1 := by
  have symmetric (a b : Answer) : character a b = character b a := by
    simp only [character, Bool.and_comm]
  have characterSum (d : Answer) : (∑ k : Answer, (character k d : ℂ)) =
      if d = (false, false) then 4 else 0 := by
    rcases d with ⟨u, v⟩
    simp only [Fintype.sum_prod_type, Fintype.sum_bool]
    cases u <;> cases v <;> norm_num [character, OrbitalSimulation.bitSign]
  ext a b
  simp only [Matrix.mul_apply, walsh, Matrix.of_apply, Matrix.one_apply, div_mul_div_comm]
  simp_rw [symmetric a, ← Complex.ofReal_mul, ← xor_character]
  rw [← Finset.sum_div, characterSum]
  have zero : (a.1 ^^ b.1, a.2 ^^ b.2) = (false, false) ↔ a = b := by
    simp [Prod.ext_iff]
  simp only [zero]
  split <;> norm_num

/-- The fixed two-bit Walsh gate converts the usual reversible row response
to the oracle used by the query compiler, with no calls to the input. -/
theorem walsh_lookup (d : Answer) :
    walsh * Matrix.diagonal (fun a : Answer => (character a d : ℂ)) * walsh = translate d := by
  have intertwine : Matrix.diagonal (fun a : Answer => (character a d : ℂ)) * walsh =
      walsh * translate d := by
    ext a b
    rw [Matrix.diagonal_mul, Matrix.mul_apply]
    simp only [walsh, translate, Matrix.of_apply, mul_ite, mul_one, mul_zero,
      Finset.sum_ite_eq', Finset.mem_univ, ite_true]
    rw [xor, xor_character, Complex.ofReal_mul, ← mul_div_assoc, mul_comm (character a d : ℂ)]
  rw [Matrix.mul_assoc, intertwine, ← Matrix.mul_assoc, walsh_square, Matrix.one_mul]

theorem row_character (x : Bits N) (a : Address N) :
    character (a.left,a.right) (response x a.level) = phase x (left a) * phase x (right a) := by
  rcases a with ⟨j,l,r⟩
  by_cases zero : j.val = 0 <;> by_cases last : j.val < N
  all_goals
    have front : 0 < j.val ↔ j.val ≠ 0 := Nat.pos_iff_ne_zero
    have prev : j.val ≠ 0 → j.val - 1 < N := by have := j.isLt; omega
    cases l <;> cases r <;>
      simp [left,right,character,response,bit,front,zero,last,prev,phase,OrbitalSimulation.bitSign] <;>
      split_ifs <;> simp_all

/-- A query returns both incident crossing bits in the Fourier basis of the
answer register. The address and both masks may be coherently controlled.
Arbitrary input-independent unitaries are allowed between complete row reads. -/
inductive RowCircuit (N : ℕ) (B : Type*) [Fintype B] [DecidableEq B] : ℕ → Type _
  | prepare (ψ : B → ℂ) (unit : ∑ b, Complex.normSq (ψ b) = 1) : RowCircuit N B 0
  | query {q : ℕ} (previous : RowCircuit N B q) (address : B → Address N)
      (gate : Matrix B B ℂ) (unit : gateᴴ * gate = 1) : RowCircuit N B (q+1)

def amplitudes (x : Bits N) : {q : ℕ} → RowCircuit N B q → B → ℂ
  | _, .prepare ψ _ => ψ
  | _, .query prev addr gate _ => gate.mulVec (fun b =>
      (character ((addr b).left,(addr b).right) (response x (addr b).level) : ℂ) * amplitudes x prev b)

/-- Compile one row read into two bit reads with the identity unitary
between them. Equality is for every input and the full complex amplitude vector. -/
theorem compile {q : ℕ} (r : RowCircuit N B q) :
    ∃ c : Circuit N B (2*q), ∀ x, PhaseQuery.amplitudes x c = amplitudes x r := by
  induction r with
  | prepare ψ unit => exact ⟨.prepare ψ unit, fun _ => rfl⟩
  | @query q previous addr gate unit ih =>
    obtain ⟨c,hc⟩ := ih
    rw [show 2*(q+1) = 2*q+1+1 by omega]
    refine ⟨.query (.query c (fun b => left (addr b)) 1 (by simp)) (fun b => right (addr b)) gate unit, ?_⟩
    intro x
    simp only [PhaseQuery.amplitudes, amplitudes, Matrix.one_mulVec, hc, row_character, Complex.ofReal_mul]
    congr 1
    funext b
    ring

private theorem unitary_product (U V : Matrix B B ℂ) (hU : Uᴴ*U = 1) (hV : Vᴴ*V = 1) :
    (U*V)ᴴ*(U*V) = 1 := by
  rw [Matrix.conjTranspose_mul, Matrix.mul_assoc, ← Matrix.mul_assoc Uᴴ U V, hU, Matrix.one_mul, hV]

/-- A fixed unitary can act on any intermediate state without making a row query. -/
private theorem apply_gate {q : ℕ} (r : RowCircuit N B q) (U : Matrix B B ℂ) (hu : Uᴴ*U = 1) :
    ∃ s : RowCircuit N B q, ∀ x, amplitudes x s = U.mulVec (amplitudes x r) := by
  cases r with
  | prepare ψ hψ =>
    let tmp : PhaseQuery.Circuit N B 1 :=
      .query (.prepare ψ hψ) (fun _ => none) U hu
    have h := PhaseQuery.amplitudes_normalized (fun _ => false) tmp
    simp only [tmp,PhaseQuery.amplitudes,phase,Complex.ofReal_one,one_mul] at h
    exact ⟨.prepare (U.mulVec ψ) h,fun _ => rfl⟩
  | query prev addr V hV =>
    refine ⟨.query prev addr (U*V) (unitary_product U V hu hV), ?_⟩
    intro x
    simp only [amplitudes,Matrix.mulVec_mulVec]

section ConventionalOracle
variable {K : Type*} [Fintype K] [DecidableEq K]

/-- The usual sparse-row XOR oracle in the computational basis. Each coherent address k
has its own level and arbitrary additional workspace. -/
def rowXor (level : K → Level N) (x : Bits N) : Matrix (Answer × K) (Answer × K) ℂ :=
  Matrix.blockDiagonal fun k => translate (response x (level k))

private def changeBasis (K : Type*) [DecidableEq K] : Matrix (Answer × K) (Answer × K) ℂ :=
  Matrix.blockDiagonal fun _ => walsh

private theorem basis_unitary : (changeBasis K)ᴴ * changeBasis K = 1 := by
  simp only [changeBasis,Matrix.blockDiagonal_conjTranspose,walsh_adjoint,← Matrix.blockDiagonal_mul,
    walsh_square]
  exact Matrix.blockDiagonal_one

private theorem coherent_lookup (level : K → Level N) (x : Bits N) :
    changeBasis K * Matrix.diagonal (fun b : Answer × K => (character b.1 (response x (level b.2)) : ℂ)) *
        changeBasis K = rowXor level x := by
  let d (k : K) (a : Answer) := (character a (response x (level k)) : ℂ)
  rw [show Matrix.diagonal (fun b : Answer × K => (character b.1 (response x (level b.2)) : ℂ)) =
      Matrix.blockDiagonal (fun k => Matrix.diagonal (d k)) from (Matrix.blockDiagonal_diagonal d).symm]
  simp only [changeBasis, ← Matrix.blockDiagonal_mul, d, walsh_lookup, rowXor]

/-- One ordinary reversible XOR row read in the computational basis compiles to
one row call in the phase basis, with the same amplitudes on every input. -/
theorem xor_step {q : ℕ} (r : RowCircuit N (Answer × K) q) (level : K → Level N)
    (gate : Matrix (Answer × K) (Answer × K) ℂ) (unit : gateᴴ*gate = 1) :
    ∃ s : RowCircuit N (Answer × K) (q+1),
      ∀ x, amplitudes x s = (gate * rowXor level x).mulVec (amplitudes x r) := by
  obtain ⟨prepared,h⟩ := apply_gate r (changeBasis K) basis_unitary
  refine ⟨.query prepared (fun b => ⟨level b.2,b.1.1,b.1.2⟩) (gate * changeBasis K)
    (unitary_product gate _ unit basis_unitary), ?_⟩
  intro x
  let D := Matrix.diagonal (fun b : Answer × K => (character b.1 (response x (level b.2)) : ℂ))
  have hw := coherent_lookup level x
  change changeBasis K * D * changeBasis K = rowXor level x at hw
  rw [amplitudes,h]
  have diag (v : Answer × K → ℂ) :
      (fun b : Answer × K => (character b.1 (response x (level b.2)) : ℂ) * v b) = D.mulVec v := by
    funext b
    simp [D, Matrix.mulVec_diagonal]
  rw [diag, Matrix.mulVec_mulVec, Matrix.mulVec_mulVec, ← hw]
  rw [Matrix.mul_assoc, Matrix.mul_assoc, Matrix.mul_assoc]

end ConventionalOracle

def accept {q : ℕ} (r : RowCircuit N B q) (outcome : Finset B) (x : Bits N) : ℝ :=
  ∑ b ∈ outcome, Complex.normSq (amplitudes x r b)

private theorem sign_prefixParity (x : Bits N) (j : ℕ) :
    OrbitalSimulation.bitSign (prefixParity x j) =
      ∏ k ∈ Finset.range j, OrbitalSimulation.bitSign (bit x k) := by
  induction j with
  | zero => simp [prefixParity, OrbitalSimulation.bitSign]
  | succ j ih =>
    rw [Finset.prod_range_succ, ← ih, prefixParity]
    cases prefixParity x j <;> cases bit x j <;> norm_num [OrbitalSimulation.bitSign]

private theorem parity_eq (x : Bits N) : OrbitalSimulation.parity x =
    OrbitalSimulation.bitSign (prefixParity x N) := by
  rw [sign_prefixParity, ← Fin.prod_univ_eq_prod_range]
  simp [OrbitalSimulation.parity, bit]

/-- Reading the parity at the far end with uniform probability error < 1/2
requires at least N/4 full row queries, each giving both incident crossing bits. -/
theorem parity_query_lower_bound {q : ℕ} (r : RowCircuit N B q) (outcome : Finset B)
    (accurate : ∀ x, |accept r outcome x - (if prefixParity x N then 1 else 0)| < 1/2) :
    N ≤ 4*q := by
  by_cases hN : 0 < N
  · obtain ⟨c,hc⟩ := compile r
    have h := OrbitalSimulation.simulation_query_lower_bound c outcome (by
      intro x
      have p : OrbitalSimulation.population x = (if prefixParity x N then 1 else 0) := by
        rw [OrbitalSimulation.population_parity hN, parity_eq]
        cases prefixParity x N <;> norm_num [OrbitalSimulation.bitSign]
      simpa only [PhaseQuery.acceptance, hc, p, accept] using accurate x)
    omega
  · omega

/-- A positive separation between the two parity classes suffices, even when
the endpoint signal is exponentially small. Centering the acceptance
polynomial at the threshold preserves its degree. -/
theorem separatedParity {q : ℕ} (r : RowCircuit N B q) (outcome : Finset B) (threshold : ℝ)
    (separated : ∀ x, if prefixParity x N then threshold < accept r outcome x
      else accept r outcome x < threshold) : N ≤ 4*q := by
  by_contra! short
  obtain ⟨c,hc⟩ := compile r
  let p := MvPolynomial.C threshold - PhaseQuery.acceptancePolynomial c outcome
  have degree : p.totalDegree < N := by
    apply (MvPolynomial.totalDegree_sub _ _).trans_lt
    rw [MvPolynomial.totalDegree_C]
    exact max_lt (by omega) ((PhaseQuery.acceptancePolynomial_degree c outcome).trans_lt (by omega))
  have positive (x : Bits N) : 0 < OrbitalSimulation.parity x * MvPolynomial.eval (bitsReal x) p := by
    rw [parity_eq]
    simp only [p,map_sub,MvPolynomial.eval_C,PhaseQuery.acceptancePolynomial_eval,
      PhaseQuery.acceptance, hc]
    have hx := separated x
    cases h : prefixParity x N <;> simp_all [OrbitalSimulation.bitSign,accept]
  exact (Finset.sum_pos (fun x _ => positive x) Finset.univ_nonempty).ne'
    (OrbitalSimulation.parity_orthogonal p degree)

/-- The query-cost step in Berry et al., Theorem 3, at time π. The simulated
quantity is the actual Born probability at the far endpoint of track true. -/
theorem endpoint_query_lower_bound
    {q : ℕ} (r : RowCircuit N B q) (outcome : Finset B)
    (accurate : ∀ x, |accept r outcome x -
      ‖NormedSpace.exp ((-(Real.pi : ℂ) * Complex.I) • crossed x) (Fin.last N,true) (0,false)‖^2| ≤ 1/4) :
    N ≤ 4*q := by
  apply parity_query_lower_bound r outcome
  intro x
  have h := accurate x
  rw [endpoint_amplitude] at h
  cases hb : prefixParity x N
  · simp only [hb, Bool.true_eq_false, ↓reduceIte, norm_zero, ne_eq, OfNat.ofNat_ne_zero,
      not_false_eq_true, zero_pow, Bool.false_eq_true] at h ⊢
    linarith
  · simp only [hb, ↓reduceIte, SpinPathEvolution.perfect_transfer] at h
    norm_num at h ⊢
    linarith

end FQChem.Complexity.SparseParityQueries
