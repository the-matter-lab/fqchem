module

public import Mathlib.Algebra.MvPolynomial.CommRing
public import Mathlib.LinearAlgebra.Matrix.ConjTranspose
public import Mathlib.Analysis.Complex.Basic
import Mathlib.Tactic

/-!
# Polynomial method for finite quantum phase-query circuits

Amplitudes before the first query are fixed. Each call to a Boolean sign oracle
changes the phase of each addressed basis vector and can leave a reference
subspace untouched. An arbitrary input-independent complex unitary then mixes
the amplitudes. The probability of measuring a specified set of basis states
has a real polynomial representative of total degree at most twice the number
of queries, as in [Beals et al., Lemma 4.2](https://arxiv.org/abs/quant-ph/9802049).
-/

@[expose] public section
noncomputable section

namespace FormalQChem.Complexity.PhaseQuery

open scoped Matrix
open MvPolynomial

abbrev Bits (N : ℕ) := Fin N → Bool
abbrev Poly (N : ℕ) := MvPolynomial (Fin N) ℝ

def bitsReal {N : ℕ} (x : Bits N) (i : Fin N) : ℝ := if x i then 1 else 0

def phase {N : ℕ} (x : Bits N) : Option (Fin N) → ℝ
  | none => 1
  | some i => if x i then -1 else 1

def phasePolynomial {N : ℕ} : Option (Fin N) → Poly N
  | none => 1
  | some i => 1 - C 2 * X i

private theorem phase_eval {N : ℕ} (x : Bits N) (a : Option (Fin N)) :
    eval (bitsReal x) (phasePolynomial a) = phase x a := by
  cases a with
  | none => simp [phasePolynomial, phase]
  | some i => cases h : x i <;> norm_num [phasePolynomial, phase, bitsReal, h]

private theorem phase_degree {N : ℕ} (a : Option (Fin N)) : (phasePolynomial a).totalDegree ≤ 1 := by
  cases a with
  | none => simp [phasePolynomial]
  | some i =>
    exact (totalDegree_sub _ _).trans (max_le (by simp)
      ((totalDegree_mul _ _).trans (by simp)))

/-- A normalized initial state and an arbitrary fixed unitary after each phase query.
Each address `none` supplies a coherent bypass of the oracle. -/
inductive Circuit (N : ℕ) (B : Type*) [Fintype B] [DecidableEq B] : ℕ → Type _
  | prepare (ψ : B → ℂ) (normalized : ∑ b, Complex.normSq (ψ b) = 1) : Circuit N B 0
  | query {t : ℕ} (previous : Circuit N B t) (address : B → Option (Fin N))
      (gate : Matrix B B ℂ) (unitary : gateᴴ * gate = 1) : Circuit N B (t + 1)

variable {N t : ℕ} {B : Type*} [Fintype B] [DecidableEq B]

def amplitudes (x : Bits N) : {t : ℕ} → Circuit N B t → B → ℂ
  | _, .prepare ψ _ => ψ
  | _, .query previous address gate _ =>
    gate.mulVec (fun b ↦ (phase x (address b) : ℂ) * amplitudes x previous b)

omit [DecidableEq B] in
private theorem sqnorm_eq (a : B → ℂ) :
    ((∑ b, Complex.normSq (a b) : ℝ) : ℂ) = dotProduct (star a) a := by
  simp [dotProduct, Complex.normSq_eq_conj_mul_self]

private theorem unitary_preserves (U : Matrix B B ℂ) (hu : Uᴴ * U = 1) (a : B → ℂ) :
    ∑ b, Complex.normSq (U.mulVec a b) = ∑ b, Complex.normSq (a b) := by
  apply Complex.ofReal_injective
  rw [sqnorm_eq, sqnorm_eq, Matrix.star_mulVec, Matrix.dotProduct_mulVec, Matrix.vecMul_vecMul, hu,
    Matrix.vecMul_one]

theorem amplitudes_normalized (x : Bits N) (c : Circuit N B t) :
    ∑ b, Complex.normSq (amplitudes x c b) = 1 := by
  induction c with
  | prepare ψ normalized => exact normalized
  | query previous address gate hgate ih =>
    unfold amplitudes
    rw [unitary_preserves gate hgate, ← ih]
    apply Finset.sum_congr rfl
    intro b _
    cases ha : address b with
    | none => simp [phase]
    | some i => cases h : x i <;> simp [phase, h]

structure AmplitudePolynomial (N : ℕ) where
  re : Poly N
  im : Poly N

private def AmplitudePolynomial.value (p : AmplitudePolynomial N) (x : Bits N) : ℂ :=
  ⟨eval (bitsReal x) p.re, eval (bitsReal x) p.im⟩

private def AmplitudePolynomial.boundedDegree (p : AmplitudePolynomial N) (t : ℕ) : Prop :=
  p.re.totalDegree ≤ t ∧ p.im.totalDegree ≤ t

def phaseScale (address : Option (Fin N)) (p : AmplitudePolynomial N) :
    AmplitudePolynomial N := ⟨phasePolynomial address * p.re, phasePolynomial address * p.im⟩

private theorem phaseScale_value (a : Option (Fin N)) (p : AmplitudePolynomial N) (x : Bits N) :
    (phaseScale a p).value x = (phase x a : ℂ) * p.value x := by
  apply Complex.ext <;> simp [phaseScale, AmplitudePolynomial.value, phase_eval, Complex.mul_re,
    Complex.mul_im]

private theorem phaseScale_degree (a : Option (Fin N)) (p : AmplitudePolynomial N)
    (h : p.boundedDegree t) : (phaseScale a p).boundedDegree (t+1) := by
  obtain ⟨hr,hi⟩ := h
  exact ⟨(totalDegree_mul _ _).trans (by have := phase_degree a; omega),
    (totalDegree_mul _ _).trans (by have := phase_degree a; omega)⟩

def mix (gate : Matrix B B ℂ) (p : B → AmplitudePolynomial N) (j : B) :
    AmplitudePolynomial N :=
  ⟨∑ k, (C (gate j k).re * (p k).re - C (gate j k).im * (p k).im),
   ∑ k, (C (gate j k).re * (p k).im + C (gate j k).im * (p k).re)⟩

omit [DecidableEq B] in
private theorem mix_value (gate : Matrix B B ℂ) (p : B → AmplitudePolynomial N)
    (x : Bits N) (j : B) :
    (mix gate p j).value x = gate.mulVec (fun k ↦ (p k).value x) j := by
  apply Complex.ext <;> simp [mix, AmplitudePolynomial.value, Matrix.mulVec_apply_eq_sum,
    Complex.mul_re, Complex.mul_im]

omit [DecidableEq B] in
private theorem mix_degree (gate : Matrix B B ℂ) (p : B → AmplitudePolynomial N)
    (h : ∀ k, (p k).boundedDegree t) (j : B) : (mix gate p j).boundedDegree t := by
  have hc (r : ℝ) (a : Poly N) (ha : a.totalDegree ≤ t) : (C r * a).totalDegree ≤ t :=
    (totalDegree_mul _ _).trans (by simpa using ha)
  exact ⟨totalDegree_finsetSum_le fun k _ ↦ (totalDegree_sub _ _).trans
    (max_le (hc _ _ (h k).1) (hc _ _ (h k).2)),
    totalDegree_finsetSum_le fun k _ ↦ (totalDegree_add _ _).trans
      (max_le (hc _ _ (h k).2) (hc _ _ (h k).1))⟩

def polynomialAmplitudes : {t : ℕ} → Circuit N B t → B → AmplitudePolynomial N
  | _, .prepare ψ _ => fun b ↦ ⟨C (ψ b).re, C (ψ b).im⟩
  | _, .query previous address gate _ =>
    mix gate (fun b ↦ phaseScale (address b) (polynomialAmplitudes previous b))

private theorem amplitudes_value (c : Circuit N B t) (x : Bits N) (b : B) :
    (polynomialAmplitudes c b).value x = amplitudes x c b := by
  induction c generalizing b with
  | prepare ψ normalized => simp [polynomialAmplitudes, AmplitudePolynomial.value, amplitudes]
  | query previous address gate hgate ih =>
    simp only [polynomialAmplitudes, amplitudes, mix_value, phaseScale_value, ih]

private theorem amplitudes_degree (c : Circuit N B t) (b : B) :
    (polynomialAmplitudes c b).boundedDegree t := by
  induction c generalizing b with
  | prepare ψ normalized => simp [polynomialAmplitudes, AmplitudePolynomial.boundedDegree]
  | query previous address gate hgate ih =>
    exact mix_degree _ _ (fun k ↦ phaseScale_degree _ _ (ih k)) _

/-- Born probability of the event that the measured basis configuration is in `accept`. -/
def acceptance (c : Circuit N B t) (accept : Finset B) (x : Bits N) : ℝ :=
  ∑ b ∈ accept, Complex.normSq (amplitudes x c b)

def acceptancePolynomial (c : Circuit N B t) (accept : Finset B) : Poly N :=
  ∑ b ∈ accept, ((polynomialAmplitudes c b).re ^ 2 + (polynomialAmplitudes c b).im ^ 2)

/-- The acceptance polynomial represents the actual probability on every Boolean oracle. -/
theorem acceptancePolynomial_eval (c : Circuit N B t) (accept : Finset B) (x : Bits N) :
    eval (bitsReal x) (acceptancePolynomial c accept) = acceptance c accept x := by
  simp only [acceptancePolynomial, map_sum, map_add, map_pow, acceptance]
  apply Finset.sum_congr rfl
  intro b _
  rw [← amplitudes_value c x b]
  simp [AmplitudePolynomial.value, Complex.normSq_apply, pow_two]

/-- The polynomial-method degree bound follows from counting oracle calls. -/
theorem acceptancePolynomial_degree (c : Circuit N B t) (accept : Finset B) :
    (acceptancePolynomial c accept).totalDegree ≤ 2*t := by
  apply totalDegree_finsetSum_le
  intro b _
  obtain ⟨hr, hi⟩ := amplitudes_degree c b
  exact (totalDegree_add _ _).trans (max_le ((totalDegree_pow _ _).trans (by omega))
    ((totalDegree_pow _ _).trans (by omega)))

theorem acceptance_mem_unitInterval (c : Circuit N B t) (accept : Finset B) (x : Bits N) :
    0 ≤ acceptance c accept x ∧ acceptance c accept x ≤ 1 := by
  refine ⟨Finset.sum_nonneg (fun _ _ ↦ Complex.normSq_nonneg _), ?_⟩
  rw [← amplitudes_normalized x c]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) fun _ _ _ ↦ Complex.normSq_nonneg _

end FormalQChem.Complexity.PhaseQuery
