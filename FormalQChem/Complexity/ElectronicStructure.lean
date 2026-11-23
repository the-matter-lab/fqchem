module

public import FormalQChem.StatePrep.VariationalOptimization.VQE
public import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Tactic

/-!
# Dual-rail encoding at fixed electron number

A local Pauli string on spins is represented by number-conserving operators on
pairs of spin orbitals. A one-electron pair carries a qubit. Empty and doubly
occupied pairs are penalized. The energy estimates cover coherent superpositions
over the entire fixed-electron-number occupation basis.

* [Liu, Christandl & Verstraete, Quantum Computational Complexity of the N-Representability Problem (2007)](https://doi.org/10.1103/PhysRevLett.98.110503)
* [O'Gorman et al., Intractability of Electronic Structure in a Fixed Basis (2022)](https://doi.org/10.1103/PRXQuantum.3.020322) gives a separate reduction realizing physical electronic integrals in a supplied orbital basis.
-/

@[expose] public section
noncomputable section

namespace FormalQChem.Complexity.ElectronicStructure
open scoped ComplexConjugate

/-- Local occupations of an ordered pair of fermion modes. -/
inductive Rail where
  | empty | single (bit : Bool) | double
  deriving DecidableEq, Fintype

def Rail.count : Rail → ℕ
  | .empty => 0 | .single _ => 1 | .double => 2

/-- The two occupancy bits give the usual ordered Fock basis on a pair. -/
def Rail.bits : Rail ≃ Bool × Bool where
  toFun
    | .empty => (false, false) | .single false => (true, false)
    | .single true => (false, true) | .double => (true, true)
  invFun
    | (false, false) => .empty | (true, false) => .single false
    | (false, true) => .single true | (true, true) => .double
  left_inv r := by cases r <;> first | rfl | rename_i b; cases b <;> rfl
  right_inv r := by obtain ⟨a,b⟩ := r; cases a <;> cases b <;> rfl

abbrev Spin (n : ℕ) := Fin n → Bool
abbrev Occupation (n : ℕ) := {x : Fin n → Rail // ∑ i, (x i).count = n}
variable {n m : ℕ}

def encode (x : Spin n) : Occupation n :=
  ⟨fun i => .single (x i), by simp [Rail.count]⟩

def Rail.bit : Rail → Bool
  | .single b => b | _ => false

def Legal (x : Occupation n) : Prop := ∀ i, x.val i = .single ((x.val i).bit)

abbrev Leakage (n : ℕ) := {x : Occupation n // ¬Legal x}

theorem encode_legal (x : Spin n) : Legal (encode x) := fun _ => rfl

/-- Exactly n particles in 2n modes, with a disjoint split into the qubit
register and all remaining n-particle occupations. -/
def occupationBasis (n : ℕ) : Spin n ⊕ Leakage n ≃ Occupation n := by
  classical
  exact {
    toFun := Sum.elim encode Subtype.val
    invFun := fun x => if h : Legal x then .inl (fun i => (x.val i).bit) else .inr ⟨x, h⟩
    left_inv := by
      rintro (x | ⟨x, h⟩)
      · dsimp only [Sum.elim_inl]; rw [dite_eq_left (encode_legal x)]; rfl
      · dsimp only [Sum.elim_inr]; rw [dite_eq_right h]
    right_inv := by
      intro x
      dsimp only
      split <;> rename_i h
      · exact Subtype.ext (funext fun i => (h i).symm)
      · rfl }

def defects (x : Occupation n) : ℕ :=
  (Finset.univ.filter fun i => x.val i ≠ .single ((x.val i).bit)).card

theorem defects_zero_iff (x : Occupation n) : defects x = 0 ↔ Legal x := by
  simp [defects, Legal, Finset.filter_eq_empty_iff]

inductive Pauli where
  | I | X | Y | Z
  deriving DecidableEq

def Pauli.move : Pauli → Bool → Bool
  | .X, b | .Y, b => !b | _, b => b

/-- Row-indexed matrix coefficient of the conventional Pauli matrix. -/
def Pauli.phase : Pauli → Bool → ℂ
  | .Y, false => -Complex.I | .Y, true => Complex.I
  | .Z, true => -1 | _, _ => 1

def Pauli.railMove (p : Pauli) : Rail → Rail
  | .single b => .single (p.move b) | .empty => .empty | .double => .double

/-- In second quantization X and Y are intra-pair hoppings and Z is the
difference of mode occupations. All three annihilate the vacuum and double. -/
def Pauli.railPhase (p : Pauli) : Rail → ℂ
  | .single b => p.phase b | _ => if p = .I then 1 else 0

theorem Pauli.railMove_twice (p : Pauli) (r : Rail) :
    p.railMove (p.railMove r) = r := by
  cases r with
  | single b => cases p <;> cases b <;> rfl
  | _ => rfl

theorem Pauli.railMove_count (p : Pauli) (r : Rail) : (p.railMove r).count = r.count := by
  cases r <;> rfl

abbrev Word (n : ℕ) := Fin n → Pauli

def physicalMove (w : Word n) : Equiv.Perm (Occupation n) :=
  let f (x : Occupation n) : Occupation n := ⟨fun i => (w i).railMove (x.val i), by
    simpa only [Pauli.railMove_count] using x.property⟩
  have h (x) : f (f x) = x := Subtype.ext (funext fun i => Pauli.railMove_twice _ _)
  ⟨f, f, h, h⟩

def logicalMove (w : Word n) : Equiv.Perm (Spin n) :=
  let f (x : Spin n) : Spin n := fun i => (w i).move (x i)
  have h (x) : f (f x) = x := by
    funext i; dsimp [f]; cases w i <;> cases x i <;> rfl
  ⟨f, f, h, h⟩

theorem move_encode (w : Word n) (x : Spin n) :
    physicalMove w (encode x) = encode (logicalMove w x) := rfl

theorem physicalMove_legal (w : Word n) (x : Occupation n) :
    Legal (physicalMove w x) ↔ Legal x := by
  have f (y : Occupation n) (hy : Legal y) : Legal (physicalMove w y) := by
    intro i
    change (w i).railMove (y.val i) = .single (((w i).railMove (y.val i)).bit)
    rw [hy i]
    rfl
  exact ⟨fun hy => by simpa only [show physicalMove w (physicalMove w x) = x from
    (physicalMove w).left_inv x] using f _ hy, f x⟩

def leakageMove (w : Word n) : Equiv.Perm (Leakage n) :=
  let f (x : Leakage n) : Leakage n :=
    ⟨physicalMove w x.val, fun h => x.property ((physicalMove_legal w _).mp h)⟩
  have h (x) : f (f x) = x := Subtype.ext ((physicalMove w).left_inv x.val)
  ⟨f, f, h, h⟩

def physicalPhase (w : Word n) (x : Occupation n) := ∏ i, (w i).railPhase (x.val i)
def logicalPhase (w : Word n) (x : Spin n) := ∏ i, (w i).phase (x i)

theorem phase_encode (w : Word n) (x : Spin n) :
    physicalPhase w (encode x) = logicalPhase w x := rfl

private theorem physicalPhase_norm (w : Word n) (x : Occupation n) : ‖physicalPhase w x‖ ≤ 1 := by
  unfold physicalPhase
  rw [norm_prod]
  apply (Finset.prod_le_prod₀ (g := fun _ : Fin n => (1 : ℝ)) (fun _ _ => norm_nonneg _) ?_).trans_eq (by simp)
  intro i _
  generalize x.val i = r
  cases r with
  | single b => cases w i <;> cases b <;> simp [Pauli.railPhase, Pauli.phase]
  | _ => cases w i <;> simp [Pauli.railPhase]

def mass {α : Type*} [Fintype α] (ψ : α → ℂ) : ℝ := ∑ x, ‖ψ x‖ ^ 2

def expectation {α : Type*} [Fintype α] (move : Equiv.Perm α) (phase ψ : α → ℂ) : ℝ :=
  ∑ x, (conj (ψ x) * phase x * ψ (move x)).re

private theorem expectation_bound {α : Type*} [Fintype α] (e : Equiv.Perm α) (z ψ : α → ℂ)
    (hz : ∀ x, ‖z x‖ ≤ 1) : |expectation e z ψ| ≤ mass ψ := by
  calc
    _ ≤ ∑ x, |(conj (ψ x) * z x * ψ (e x)).re| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ x, (‖ψ x‖ ^ 2 + ‖ψ (e x)‖ ^ 2) / 2 := by
      apply Finset.sum_le_sum
      intro x _
      apply (Complex.abs_re_le_norm _).trans
      rw [norm_mul, norm_mul, Complex.norm_conj]
      calc
        ‖ψ x‖ * ‖z x‖ * ‖ψ (e x)‖ ≤ ‖ψ x‖ * 1 * ‖ψ (e x)‖ := by gcongr; exact hz x
        _ ≤ _ := by nlinarith [sq_nonneg (‖ψ x‖ - ‖ψ (e x)‖)]
    _ = _ := by
      rw [← Finset.sum_div, Finset.sum_add_distrib, Equiv.sum_comp e (fun x => ‖ψ x‖ ^ 2)]
      unfold mass; ring

noncomputable instance (n : ℕ) : Fintype (Leakage n) := Fintype.ofFinite _

def spinPart (ψ : Occupation n → ℂ) (x : Spin n) := ψ (encode x)
def leakagePart (ψ : Occupation n → ℂ) (x : Leakage n) := ψ x.val

private theorem splitSum (f : Occupation n → ℝ) :
    ∑ x, f x = (∑ x, f (encode x)) + ∑ x : Leakage n, f x.val := by
  rw [← Equiv.sum_comp (occupationBasis n) f, Fintype.sum_sum_type]
  rfl

theorem mass_split (ψ : Occupation n → ℂ) :
    mass ψ = mass (spinPart ψ) + mass (leakagePart ψ) := splitSum _

def spinEnergy (c : Fin m → ℝ) (w : Fin m → Word n) (ψ : Spin n → ℂ) : ℝ :=
  ∑ j, c j * expectation (logicalMove (w j)) (logicalPhase (w j)) ψ

def interactionEnergy (c : Fin m → ℝ) (w : Fin m → Word n) (ψ : Occupation n → ℂ) : ℝ :=
  ∑ j, c j * expectation (physicalMove (w j)) (physicalPhase (w j)) ψ

def penaltyEnergy (ψ : Occupation n → ℂ) : ℝ := ∑ x, (defects x : ℝ) * ‖ψ x‖ ^ 2

def fermionEnergy (c : Fin m → ℝ) (w : Fin m → Word n) (J : ℝ) (ψ : Occupation n → ℂ) : ℝ :=
  interactionEnergy c w ψ + J * penaltyEnergy ψ

def strength (c : Fin m → ℝ) : ℝ := ∑ j, |c j|

private theorem leakage_expectation (w : Word n) (ψ : Occupation n → ℂ) :
    expectation (physicalMove w) (physicalPhase w) ψ =
      expectation (logicalMove w) (logicalPhase w) (spinPart ψ) +
      expectation (leakageMove w) (fun x => physicalPhase w x.val) (leakagePart ψ) := splitSum _

theorem interactionError (c : Fin m → ℝ) (w : Fin m → Word n) (ψ : Occupation n → ℂ) :
    |interactionEnergy c w ψ - spinEnergy c w (spinPart ψ)| ≤ strength c * mass (leakagePart ψ) := by
  unfold interactionEnergy spinEnergy
  simp_rw [leakage_expectation, mul_add]
  rw [Finset.sum_add_distrib, add_sub_cancel_left, strength, Finset.sum_mul]
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  apply Finset.sum_le_sum
  intro j _
  rw [abs_mul]
  exact mul_le_mul_of_nonneg_left (expectation_bound _ _ _ (fun x => physicalPhase_norm _ x.val)) (abs_nonneg _)

theorem leakagePenalty (ψ : Occupation n → ℂ) : mass (leakagePart ψ) ≤ penaltyEnergy ψ := by
  rw [penaltyEnergy, splitSum]
  have zero (x : Spin n) : defects (encode x) = 0 := (defects_zero_iff _).mpr (encode_legal x)
  simp only [zero, Nat.cast_zero, zero_mul, Finset.sum_const_zero, zero_add]
  apply Finset.sum_le_sum
  intro x _
  have hx : 1 ≤ defects x.val := Nat.one_le_iff_ne_zero.mpr (fun h => x.property ((defects_zero_iff _).mp h))
  exact le_mul_of_one_le_left (sq_nonneg _) (by exact_mod_cast hx)

/-- Zero extension of a spin wave function to every fixed-n occupation. -/
def encodeState (ψ : Spin n → ℂ) (x : Occupation n) : ℂ :=
  Sum.elim ψ (fun _ => 0) ((occupationBasis n).symm x)

@[simp] theorem spinPart_encodeState (ψ : Spin n → ℂ) : spinPart (encodeState ψ) = ψ := by
  funext x
  change Sum.elim ψ _ ((occupationBasis n).symm ((occupationBasis n) (.inl x))) = ψ x
  rw [Equiv.symm_apply_apply]; rfl

@[simp] theorem leakagePart_encodeState (ψ : Spin n → ℂ) : leakagePart (encodeState ψ) = 0 := by
  funext x
  change Sum.elim ψ _ ((occupationBasis n).symm ((occupationBasis n) (.inr x))) = 0
  rw [Equiv.symm_apply_apply]; rfl

theorem encodeState_mass (ψ : Spin n → ℂ) : mass (encodeState ψ) = mass ψ := by
  rw [mass_split, spinPart_encodeState, leakagePart_encodeState]
  simp [mass]

theorem encodeState_energy (c : Fin m → ℝ) (w : Fin m → Word n) (J : ℝ) (ψ : Spin n → ℂ) :
    fermionEnergy c w J (encodeState ψ) = spinEnergy c w ψ := by
  have hi := interactionError c w (encodeState ψ)
  simp [mass] at hi
  have hp : penaltyEnergy (encodeState ψ) = 0 := by
    rw [penaltyEnergy, splitSum]
    have zero (x : Spin n) : defects (encode x) = 0 := (defects_zero_iff _).mpr (encode_legal x)
    have off (x : Leakage n) : encodeState ψ x.val = 0 := congrFun (leakagePart_encodeState ψ) x
    simp [zero, off]
  simpa [fermionEnergy, hp] using sub_eq_zero.mp hi

private theorem mass_nonneg {α : Type*} [Fintype α] (ψ : α → ℂ) : 0 ≤ mass ψ :=
  Finset.sum_nonneg (fun _ _ => sq_nonneg _)

/-- A homogeneous lower energy bound for all spin wave functions survives the
encoding whenever the penalty dominates the possible energy gain off the code. -/
theorem lowerBound_transfer (c : Fin m → ℝ) (w : Fin m → Word n) (J b : ℝ)
    (hJ : 0 ≤ J) (hsep : b + strength c ≤ J)
    (hspin : ∀ ψ, b * mass ψ ≤ spinEnergy c w ψ) (ψ : Occupation n → ℂ) :
    b * mass ψ ≤ fermionEnergy c w J ψ := by
  have h1 := (abs_le.mp (interactionError c w ψ)).1
  have h2 := mul_le_mul_of_nonneg_left (leakagePenalty ψ) hJ
  have h3 := mul_le_mul_of_nonneg_right hsep (mass_nonneg (leakagePart ψ))
  rw [mass_split, fermionEnergy]
  linarith [hspin (spinPart ψ)]

private theorem mass_scale {α : Type*} [Fintype α] (z : ℂ) (ψ : α → ℂ) :
    mass (fun x => z * ψ x) = ‖z‖ ^ 2 * mass ψ := by
  simp [mass, mul_pow, Finset.mul_sum]

private theorem expectation_scale {α : Type*} [Fintype α] (move : Equiv.Perm α)
    (phase ψ : α → ℂ) (z : ℂ) :
    expectation move phase (fun x => z * ψ x) = ‖z‖ ^ 2 * expectation move phase ψ := by
  unfold expectation
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x _
  rw [map_mul, show conj z * conj (ψ x) * phase x * (z * ψ (move x)) =
    (z * conj z) * (conj (ψ x) * phase x * ψ (move x)) by ring, Complex.mul_conj]
  simp only [Complex.mul_re, Complex.ofReal_re, Complex.ofReal_im, zero_mul, sub_zero, Complex.normSq_eq_norm_sq]

private theorem spinEnergy_scale (c : Fin m → ℝ) (w : Fin m → Word n) (ψ : Spin n → ℂ) (z : ℂ) :
    spinEnergy c w (fun x => z * ψ x) = ‖z‖ ^ 2 * spinEnergy c w ψ := by
  simp only [spinEnergy, expectation_scale, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

private theorem homogeneous_lower (c : Fin m → ℝ) (w : Fin m → Word n) (b : ℝ)
    (h : ∀ ψ, mass ψ = 1 → b ≤ spinEnergy c w ψ) (ψ : Spin n → ℂ) :
    b * mass ψ ≤ spinEnergy c w ψ := by
  by_cases hz : ψ = 0
  · subst ψ; simp [mass, spinEnergy, expectation]
  have hm : 0 < mass ψ := by
    obtain ⟨x, hx⟩ : ∃ x, ψ x ≠ 0 := by contrapose! hz; exact funext hz
    exact Finset.sum_pos' (fun _ _ => sq_nonneg _) ⟨x, Finset.mem_univ _, sq_pos_of_pos (norm_pos_iff.mpr hx)⟩
  let z : ℂ := (Real.sqrt (mass ψ) : ℂ)⁻¹
  have zm : ‖z‖ ^ 2 * mass ψ = 1 := by
    simp [z, Real.sq_sqrt hm.le, hm.ne']
  have hb := h (fun x => z * ψ x) ((mass_scale _ _).trans zm)
  rw [spinEnergy_scale] at hb
  calc
    b * mass ψ ≤ (‖z‖ ^ 2 * spinEnergy c w ψ) * mass ψ := mul_le_mul_of_nonneg_right hb hm.le
    _ = spinEnergy c w ψ := by linear_combination (spinEnergy c w ψ) * zm

/-- The yes and no energy promises use normalized amplitudes. The map preserves
the same thresholds, hence the entire inverse-polynomial decision gap. -/
theorem energyPromise_transfer (c : Fin m → ℝ) (w : Fin m → Word n) (J a b : ℝ)
    (hJ : 0 ≤ J) (hsep : b + strength c ≤ J) :
    ((∃ ψ, mass ψ = 1 ∧ spinEnergy c w ψ ≤ a) →
      ∃ φ, mass φ = 1 ∧ fermionEnergy c w J φ ≤ a) ∧
    ((∀ ψ, mass ψ = 1 → b ≤ spinEnergy c w ψ) →
      ∀ φ, mass φ = 1 → b ≤ fermionEnergy c w J φ) := by
  constructor
  · rintro ⟨ψ, hm, he⟩
    exact ⟨encodeState ψ, (encodeState_mass ψ).trans hm, (encodeState_energy c w J ψ).trans_le he⟩
  · intro h φ hφ
    simpa [hφ] using lowerBound_transfer c w J b hJ hsep (homogeneous_lower c w b h) φ

end FormalQChem.Complexity.ElectronicStructure
