module

public import FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticComparison
import Mathlib.Tactic

/-! # The subgraphs representation of the zero-field ferromagnet

Jerrum and Sinclair, [SIAM J. Comput. 22 (1993), Theorems 1 and 12](https://doi.org/10.1137/0222066).
For the unit ferromagnetic couplings of the Troyer–Wiese construction, the
high-temperature expansion is an exact identity at every inverse temperature.
The boundary of an edge subset records the sites of odd degree.
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
open IsingSign
variable {n : ℕ}

local instance : Std.Commutative Bool.xor := ⟨Bool.xor_comm⟩

def boundary (A : Finset (Spin n)) : Spin n :=
  fun i => A.fold Bool.xor false (fun e => e i)

theorem boundary_empty : boundary (∅ : Finset (Spin n)) = aligned n := by funext i; simp [boundary,aligned]

theorem boundary_insert {A : Finset (Spin n)} {e : Spin n} (h : e ∉ A) :
    boundary (insert e A) = exchange e (boundary A) := by
  funext i
  simp [boundary,exchange,Finset.fold_insert h]

abbrev χ (s e : Spin n) : ℝ := (character s e : ℤ)

private theorem characterProduct (s : Spin n) (A : Finset (Spin n)) :
    ∏ e ∈ A, χ s e = χ s (boundary A) := by
  induction A using Finset.induction_on with
  | empty => simp [boundary_empty,χ,character,aligned,bitCharacter]
  | @insert e A he ih =>
    rw [Finset.prod_insert he,ih,boundary_insert he]
    have localBit : ∀ a b c : Bool,
        bitCharacter a (b ^^ c) = bitCharacter a b * bitCharacter a c := by decide
    simp [χ,character,exchange,localBit, Finset.prod_mul_distrib]

private theorem orthogonal (a b : Spin n) :
    ∑ s, χ s a * χ s b = if a=b then (2:ℝ)^n else 0 := by
  have sym (x y : Spin n) : χ x y = χ y x := by
    simp [χ,character,bitCharacter,Bool.and_comm]
  have h := congrArg (fun M : Operator n => M a b) (walsh_square n)
  simp only [Matrix.mul_apply,walsh,Matrix.of_apply,Matrix.smul_apply,smul_eq_mul,Matrix.one_apply,
    mul_ite,mul_one,mul_zero] at h
  convert h using 1
  exact Finset.sum_congr rfl fun s _ => congrArg (χ s a * ·) (sym s b)

def sector (B : Finset (Spin n)) (x : ℝ) (d : Spin n) : ℝ :=
  ∑ A ∈ B.powerset, if boundary A = d then x^A.card else 0

def weight (g : Glass n) (β : ℝ) (s : Spin n) := Real.exp (-β*g.ferro.energy s)

def prefactor (g : Glass n) (β : ℝ) := (2:ℝ)^n * Real.cosh β^g.bonds.card

private theorem edgeFactor (β : ℝ) (s e : Spin n) :
    Real.exp (β*χ s e) = Real.cosh β*(1+Real.tanh β*χ s e) := by
  have h := abs_character s e
  have signs : χ s e = 1 ∨ χ s e = -1 := by
    by_cases h' : 0 ≤ character s e
    · left; dsimp [χ]; exact_mod_cast (abs_of_nonneg h').symm.trans h
    · right; rw [abs_of_neg (lt_of_not_ge h')] at h; dsimp [χ]; exact_mod_cast (by omega : character s e = -1)
  have cp := (Real.cosh_pos β).ne'
  rcases signs with h|h
  · rw [h, mul_one, mul_one, ← Real.cosh_add_sinh, Real.tanh_eq_sinh_div_cosh]; field_simp
  · rw [h, mul_neg_one, mul_neg_one, ← Real.cosh_sub_sinh, Real.tanh_eq_sinh_div_cosh]; field_simp; ring

private theorem boltzmannExpansion (g : Glass n) (β : ℝ) (s : Spin n) :
    weight g β s = Real.cosh β^g.bonds.card *
      ∑ A ∈ g.bonds.powerset, (Real.tanh β)^A.card * χ s (boundary A) := by
  have eng : (g.ferro.energy s:ℝ) = -∑ e ∈ g.bonds, χ s e := by
    simp [Glass.energy, Glass.ferro,Glass.coupling,χ]
  rw [weight,eng,neg_mul_neg,Finset.mul_sum,Real.exp_sum]
  simp_rw [edgeFactor]
  rw [Finset.prod_mul_distrib,Finset.prod_const,Finset.prod_one_add]
  congr 1
  apply Finset.sum_congr rfl
  intro A _
  rw [Finset.prod_mul_distrib,Finset.prod_const,characterProduct]

private theorem transform (g : Glass n) (β : ℝ) (d : Spin n) :
    ∑ s, χ s d * weight g β s = prefactor g β * sector g.bonds (Real.tanh β) d := by
  let x := Real.tanh β
  let c := Real.cosh β^g.bonds.card
  calc ∑ s, χ s d * weight g β s = c * ∑ s, ∑ A ∈ g.bonds.powerset,
         x^A.card * (χ s d * χ s (boundary A)) := by
         rw [Finset.mul_sum]
         apply Finset.sum_congr rfl
         intro s _
         rw [boltzmannExpansion, mul_left_comm,Finset.mul_sum]
         congr 1
         exact Finset.sum_congr rfl fun _ _ => by ring
       _ = c * ∑ A ∈ g.bonds.powerset, x^A.card * (if d = boundary A then (2:ℝ)^n else 0) := by
         rw [Finset.sum_comm]
         congr 1
         exact Finset.sum_congr rfl fun _ _ => by rw [← Finset.mul_sum,orthogonal]
       _ = _ := by
         change _ = (2^n*c) * ∑ A ∈ g.bonds.powerset, if boundary A=d then x^A.card else 0
         rw [mul_comm (2^n) c,mul_assoc,Finset.mul_sum (a := (2:ℝ)^n)]
         congr 1
         apply Finset.sum_congr rfl
         intro A _
         by_cases h : d=boundary A <;> simp [h,eq_comm, mul_comm, x]

/-- The physical Gibbs partition function is a known prefactor times the sum of
tanh(β)^|A| over even subgraphs. The formula also includes β=0. -/
theorem partitionExpansion (g : Glass n) (β : ℝ) :
    ∑ s, weight g β s = prefactor g β * sector g.bonds (Real.tanh β) (aligned n) := by
  simpa [χ,character,aligned,bitCharacter] using transform g β (aligned n)

/-- The total subgraph weight with any prescribed odd-vertex boundary is at most
the even-sector weight. This is the normalized Gibbs spin-product bound. -/
theorem sectorDomination (g : Glass n) (β : ℝ) (d : Spin n) :
    sector g.bonds (Real.tanh β) d ≤ sector g.bonds (Real.tanh β) (aligned n) := by
  have c : 0 < prefactor g β := by unfold prefactor; positivity
  apply (mul_le_mul_iff_right₀ c).mp
  rw [← transform, ← partitionExpansion]
  apply Finset.sum_le_sum
  intro s _
  have h : χ s d ≤ 1 := by dsimp [χ]; exact_mod_cast (abs_le.mp (abs_character s d).le).2
  exact mul_le_of_le_one_left (Real.exp_pos _).le h

theorem evenPositive (g : Glass n) (β : ℝ) :
    0 < sector g.bonds (Real.tanh β) (aligned n) := by
  have c : 0 < prefactor g β := by unfold prefactor; positivity
  apply (mul_pos_iff_of_pos_left c).mp
  rw [← partitionExpansion]
  exact Finset.sum_pos (fun i _ => Real.exp_pos _) Finset.univ_nonempty

/-- The negative of the exact quantum Gibbs energy is the sum of the physical
two-spin correlations, each equal to a boundary-sector ratio. -/
theorem energySectors (g : Glass n) (β : ℝ) :
    -g.ferro.quantumThermal β =
      (∑ e ∈ g.bonds, sector g.bonds (Real.tanh β) e) / sector g.bonds (Real.tanh β) (aligned n) := by
  rw [thermal_identity,Glass.classicalThermal,← neg_div,← Finset.sum_neg_distrib]
  change (∑ s, -((g.ferro.energy s:ℝ)*weight g β s)) / (∑ s, weight g β s) = _
  have sum (s : Spin n) : -((g.ferro.energy s:ℝ)*weight g β s) =
      ∑ e ∈ g.bonds, χ s e*weight g β s := by
    simp [Glass.energy,Glass.ferro,Glass.coupling,χ,Finset.sum_mul]
  simp_rw [sum]
  rw [Finset.sum_comm,partitionExpansion]
  simp_rw [transform]
  rw [← Finset.mul_sum, mul_div_mul_left]
  unfold prefactor; positivity

end FQChem.StatePrep.ImaginaryTimeProjection.FerromagneticSubgraphs
