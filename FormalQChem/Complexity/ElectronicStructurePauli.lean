module

public import FormalQChem.Complexity.ElectronicStructureOperators
public import Mathlib.LinearAlgebra.Matrix.Hermitian
import Mathlib.Tactic

/-! # Local Hermitian matrices as real Pauli sums

Matrix coefficients are expanded on the supplied local support. The resulting
description has four words per site in that support, hence 4^k terms per
k-local matrix. The analysis uses the computational basis in both directions. -/

@[expose] public section
noncomputable section
namespace FormalQChem.Complexity.ElectronicStructure
open scoped ComplexConjugate
variable {k n : ℕ}

def Pauli.index : Pauli ≃ Fin 4 where
  toFun | .I => 0 | .X => 1 | .Y => 2 | .Z => 3
  invFun i := ![.I, .X, .Y, .Z] i
  left_inv p := by cases p <;> rfl
  right_inv i := by fin_cases i <;> rfl

instance : Fintype Pauli := Fintype.ofEquiv (Fin 4) Pauli.index.symm

def Pauli.entry (p : Pauli) (x y : Bool) : ℂ := if y = p.move x then p.phase x else 0

private theorem pauliEntry_conj (p : Pauli) (x y : Bool) :
    conj (p.entry x y) = p.entry y x := by
  cases p <;> cases x <;> cases y <;> simp [Pauli.entry, Pauli.move, Pauli.phase]

private theorem spinResolution (r c x y : Bool) :
    ∑ p : Pauli, conj (p.entry r c) / 2 * p.entry x y =
      (if r = x ∧ c = y then 1 else 0) := by
  rw [← Equiv.sum_comp Pauli.index.symm (fun p => _)]
  cases r <;> cases c <;> cases x <;> cases y <;>
    norm_num [Fin.sum_univ_four, Pauli.index, Pauli.entry, Pauli.move, Pauli.phase] <;> ring_nf <;> norm_num [Complex.I_sq]

def wordEntry (p : Word k) (x y : Spin k) : ℂ := ∏ i, (p i).entry (x i) (y i)

theorem wordEntry_eq (p : Word k) (x y : Spin k) : wordEntry p x y =
    if y = logicalMove p x then logicalPhase p x else 0 := by
  simp only [wordEntry, Pauli.entry, Fintype.prod_ite_zero, logicalPhase]
  congr 1
  exact propext (funext_iff).symm

private theorem wordEntry_conj (p : Word k) (x y : Spin k) :
    conj (wordEntry p x y) = wordEntry p y x := by
  simp [wordEntry, map_prod, pauliEntry_conj]

def dualEntry (p : Word k) (r c : Spin k) : ℂ := ∏ i, conj ((p i).entry (r i) (c i)) / 2

theorem pauliResolution (r c x y : Spin k) :
    ∑ p : Word k, dualEntry p r c * wordEntry p x y =
      (if r = x ∧ c = y then 1 else 0) := by
  simp only [dualEntry, wordEntry, ← Finset.prod_mul_distrib]
  rw [← Fintype.prod_sum (fun i (p : Pauli) => conj (p.entry (r i) (c i)) / 2 * p.entry (x i) (y i))]
  simp only [spinResolution, Fintype.prod_ite_zero, Finset.prod_const_one]
  congr 1
  exact propext (by simp [funext_iff, forall_and])

def pauliCoefficient (K : Matrix (Spin k) (Spin k) ℂ) (p : Word k) : ℂ :=
  ∑ r, ∑ c, K r c * dualEntry p r c

/-- Complex Pauli expansion for arbitrary matrices on the local support. -/
theorem pauliExpansion (K : Matrix (Spin k) (Spin k) ℂ) (x y : Spin k) :
    ∑ p, pauliCoefficient K p * wordEntry p x y = K x y := by
  classical
  simp only [pauliCoefficient, Finset.sum_mul]
  rw [Finset.sum_comm]
  calc
    _ = ∑ r, ∑ c, K r c * ∑ p, dualEntry p r c * wordEntry p x y := by
      apply Finset.sum_congr rfl
      intro r _
      rw [Finset.sum_comm]
      simp only [Finset.mul_sum, mul_assoc]
    _ = _ := by simp [pauliResolution, ite_and, mul_ite]

private theorem dualEntry_conj (p : Word k) (r c : Spin k) :
    conj (dualEntry p r c) = dualEntry p c r := by
  simp only [dualEntry, map_prod, map_div₀, map_ofNat, pauliEntry_conj]

theorem pauliCoefficient_real (K : Matrix (Spin k) (Spin k) ℂ) (h : K.IsHermitian) (p : Word k) :
    ((pauliCoefficient K p).re : ℂ) = pauliCoefficient K p := by
  apply Complex.conj_eq_iff_re.mp
  simp only [pauliCoefficient, map_sum, map_mul, dualEntry_conj]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro r _
  apply Finset.sum_congr rfl
  intro c _
  rw [show conj (K c r) = K r c from congrFun (congrFun h.eq r) c]

/-- There are precisely 4^k candidate words for one local term. Hermitian
input gives a real coefficient for each, including terms with Pauli Y. -/
theorem localHermitianExpansion (K : Matrix (Spin k) (Spin k) ℂ) (h : K.IsHermitian) :
    Fintype.card (Word k) = 4 ^ k ∧
    ∀ x y, ∑ p, ((pauliCoefficient K p).re : ℂ) * wordEntry p x y = K x y := by
  constructor
  · simp [Word, Fintype.card_congr Pauli.index]
  · intro x y
    simpa only [pauliCoefficient_real K h] using pauliExpansion K x y


/-- Extend a word by identities on all unselected qubits. -/
def extendWord (wire : Fin k ↪ Fin n) (p : Word k) : Word n :=
  Function.extend wire p (fun _ => .I)

def untouched (wire : Fin k ↪ Fin n) (x y : Spin n) : ℂ :=
  ∏ i ∈ (Finset.univ.map wire)ᶜ, Pauli.I.entry (x i) (y i)

/-- Unselected coordinates contribute the identity kernel. -/
theorem untouched_eq (wire : Fin k ↪ Fin n) (x y : Spin n) : untouched wire x y =
    if ∀ i ∉ Finset.univ.map wire, y i = x i then 1 else 0 := by
  classical
  unfold untouched
  by_cases h : ∀ i ∉ Finset.univ.map wire, y i = x i
  · rw [ite_eq_left h]
    exact Finset.prod_eq_one fun i hi => by simp [Pauli.entry, Pauli.move, Pauli.phase, h i (Finset.mem_compl.mp hi)]
  · rw [ite_eq_right h]
    push Not at h
    obtain ⟨i, hi, hne⟩ := h
    exact Finset.prod_eq_zero (Finset.mem_compl.mpr hi) (by simp [Pauli.entry, Pauli.move, hne])

theorem extendWord_entry (wire : Fin k ↪ Fin n) (p : Word k) (x y : Spin n) :
    wordEntry (extendWord wire p) x y = wordEntry p (x ∘ wire) (y ∘ wire) * untouched wire x y := by
  classical
  unfold wordEntry untouched
  rw [← (Finset.univ.map wire).prod_mul_prod_compl (fun i => (extendWord wire p i).entry (x i) (y i)),
    Finset.prod_map]
  congr 1
  · simp [extendWord, wire.injective.extend_apply]
  · apply Finset.prod_congr rfl
    intro i hi
    have h : ¬∃ j, wire j = i := by simpa using hi
    rw [extendWord, Function.extend_apply' _ _ _ h]

theorem extendWord_support (wire : Fin k ↪ Fin n) (p : Word k) :
    (support (extendWord wire p)).card ≤ k := by
  classical
  have hs : support (extendWord wire p) ⊆ Finset.univ.map wire := by
    intro i hi
    by_contra h
    have h' : ¬∃ j, wire j = i := by simpa using h
    have h'' : extendWord wire p i = .I := Function.extend_apply' _ _ _ h'
    simp [support, h''] at hi
  simpa using Finset.card_le_card hs

/-- A finite input table on k specified wires, and its exact embedding as
the identity on the other n−k coordinates. -/
structure LocalTerm (n : ℕ) where
  arity : ℕ
  wire : Fin arity ↪ Fin n
  table : Matrix (Spin arity) (Spin arity) ℂ
  hermitian : table.IsHermitian

def LocalTerm.kernel (t : LocalTerm n) : Matrix (Spin n) (Spin n) ℂ :=
  fun x y => t.table (x ∘ t.wire) (y ∘ t.wire) * untouched t.wire x y

variable {m : ℕ}

abbrev ExpansionIndex (t : Fin m → LocalTerm n) := Σ j, Word (t j).arity

def expansionIndex (t : Fin m → LocalTerm n) := (Fintype.equivFin (ExpansionIndex t)).symm

def localCoefficients (t : Fin m → LocalTerm n) (u : Fin (Fintype.card (ExpansionIndex t))) : ℝ :=
  let ⟨j, p⟩ := expansionIndex t u
  (pauliCoefficient (t j).table p).re

def localWords (t : Fin m → LocalTerm n) (u : Fin (Fintype.card (ExpansionIndex t))) : Word n :=
  let ⟨j, p⟩ := expansionIndex t u
  extendWord (t j).wire p

private theorem localTerm_expansion (t : LocalTerm n) (x y : Spin n) :
    (∑ p, ((pauliCoefficient t.table p).re : ℂ) * wordEntry (extendWord t.wire p) x y) =
      t.kernel x y := by
  simp only [extendWord_entry, ← mul_assoc, ← Finset.sum_mul, pauliCoefficient_real _ t.hermitian,
    LocalTerm.kernel]
  exact congrArg (· * untouched t.wire x y) (pauliExpansion t.table (x ∘ t.wire) (y ∘ t.wire))

/-- Exact expansion of the sum of local tables into the spin kernel accepted
by the fixed-particle dual-rail encoding. -/
theorem localExpansion_kernel (t : Fin m → LocalTerm n) :
    spinKernel (localCoefficients t) (localWords t) = ∑ j, (t j).kernel := by
  ext x y
  change ∑ u, ((localCoefficients t u : ℝ) : ℂ) *
    (if y = logicalMove (localWords t u) x then logicalPhase (localWords t u) x else 0) = _
  simp only [← wordEntry_eq, Matrix.sum_apply]
  let f (u : ExpansionIndex t) := ((pauliCoefficient (t u.1).table u.2).re : ℂ) *
    wordEntry (extendWord (t u.1).wire u.2) x y
  change (∑ u, f (expansionIndex t u)) = _
  rw [Equiv.sum_comp, Fintype.sum_sigma]
  apply Finset.sum_congr rfl
  intro j _
  exact localTerm_expansion (t j) x y

theorem localExpansion_size (t : Fin m → LocalTerm n) (k : ℕ) (h : ∀ j, (t j).arity ≤ k) :
    Fintype.card (ExpansionIndex t) ≤ m*4^k ∧ ∀ u, (support (localWords t u)).card ≤ k := by
  constructor
  · simp only [ExpansionIndex, Fintype.card_sigma, Word, Fintype.card_fun, Fintype.card_fin,
      Fintype.card_congr Pauli.index]
    simpa using Finset.sum_le_sum (s := Finset.univ) (fun j _ => Nat.pow_le_pow_right (by decide : 0 < 4) (h j))
  · intro u
    exact (extendWord_support _ _).trans (h (expansionIndex t u).1)

/-- Composition for arbitrary local Hermitian input tables, preserving both
ground-energy promises at exactly the original thresholds. -/
theorem localHamiltonian_to_fixedParticle (t : Fin m → LocalTerm n) (J a b : ℝ)
    (hJ : 0 ≤ J) (hsep : b + strength (localCoefficients t) ≤ J) :
    ((∃ ψ, mass ψ = 1 ∧ matrixExpectation (∑ j, (t j).kernel) ψ ≤ a) →
      ∃ φ, mass φ = 1 ∧ fermionEnergy (localCoefficients t) (localWords t) J φ ≤ a) ∧
    ((∀ ψ, mass ψ = 1 → b ≤ matrixExpectation (∑ j, (t j).kernel) ψ) →
      ∀ φ, mass φ = 1 → b ≤ fermionEnergy (localCoefficients t) (localWords t) J φ) := by
  simpa only [← localExpansion_kernel t, spinKernel_expectation] using
    energyPromise_transfer (localCoefficients t) (localWords t) J a b hJ hsep


private theorem entry_norm_le_one (p : Pauli) (r c : Bool) : ‖p.entry r c‖ ≤ 1 := by
  cases p <;> cases r <;> cases c <;> simp [Pauli.entry, Pauli.move, Pauli.phase]

private theorem dualEntry_norm (p : Word k) (r c : Spin k) : ‖dualEntry p r c‖ ≤ 1 := by
  rw [dualEntry, norm_prod]
  apply (Finset.prod_le_prod₀ (g := fun _ : Fin k => (1 : ℝ)) (fun _ _ => norm_nonneg _) ?_).trans_eq (by simp)
  intro i _
  rw [norm_div, Complex.norm_conj]
  norm_num
  linarith [entry_norm_le_one (p i) (r i) (c i)]

/-- A simple bound for the encoded penalty in terms of the supplied local
matrix entries. For fixed k the factor multiplying m B is constant. -/
theorem localExpansion_strength (t : Fin m → LocalTerm n) (k : ℕ) (B : ℝ)
    (hk : ∀ j, (t j).arity ≤ k) (hB : 0 ≤ B) (h : ∀ j r c, ‖(t j).table r c‖ ≤ B) :
    strength (localCoefficients t) ≤ (m * 4^k : ℕ) * ((2^k : ℝ) * (2^k * B)) := by
  have bound (j : Fin m) (p : Word (t j).arity) : ‖pauliCoefficient (t j).table p‖ ≤
      (2^k : ℝ) * (2^k * B) := by
    have hc : (2 : ℝ)^(t j).arity ≤ 2^k := by exact_mod_cast Nat.pow_le_pow_right (by decide : 0 < 2) (hk j)
    calc
      _ ≤ ∑ r, ∑ c, B := by
        apply (norm_sum_le _ _).trans
        apply Finset.sum_le_sum
        intro r _
        apply (norm_sum_le _ _).trans
        apply Finset.sum_le_sum
        intro c _
        rw [norm_mul]
        exact (mul_le_mul (h j r c) (dualEntry_norm p r c) (norm_nonneg _) hB).trans_eq (mul_one _)
      _ = (2:ℝ)^(t j).arity * (2^(t j).arity * B) := by simp [Spin]
      _ ≤ _ := by gcongr
  have each (u) : |localCoefficients t u| ≤ (2^k : ℝ) * (2^k * B) :=
    (Complex.abs_re_le_norm _).trans (bound _ (expansionIndex t u).2)
  calc
    _ ≤ ∑ u : Fin (Fintype.card (ExpansionIndex t)), (2^k : ℝ) * (2^k * B) :=
      Finset.sum_le_sum (fun u _ => each u)
    _ = (Fintype.card (ExpansionIndex t) : ℝ) * (2^k * (2^k * B)) := by rw [Finset.sum_const]; simp
    _ ≤ _ := mul_le_mul_of_nonneg_right (by exact_mod_cast (localExpansion_size t k hk).1) (by positivity)

end FormalQChem.Complexity.ElectronicStructure
