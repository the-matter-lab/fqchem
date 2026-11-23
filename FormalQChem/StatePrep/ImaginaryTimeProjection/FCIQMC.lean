module

public import Mathlib.Data.Matrix.Mul
public import Mathlib.Algebra.Order.Floor.Ring
public import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Mathlib.Tactic

/-!
# Full configuration interaction quantum Monte Carlo

In a finite real determinant basis, each signed walker proposes a destination,
stochastically rounds its importance-weighted spawn, and samples a diagonal
death or cloning increment. The expected signed population after this step is
the fixed-shift Euler update of the CI coefficients. Pair annihilation preserves
the signed population for each realized configuration. The transition allows
every connected spawn and uses a fixed shift throughout.

* [Booth, Thom & Alavi, Fermion Monte Carlo without fixed nodes (2009)](https://doi.org/10.1063/1.3193710)
-/

@[expose] public section
noncomputable section
namespace FormalQChem.StatePrep.ImaginaryTimeProjection.FCIQMC

/-- Two-point rounding to neighboring integers, also for negative target increments. -/
def rounded (z : ℝ) (up : Bool) : ℤ := ⌊z⌋ + if up then 1 else 0

def roundingMass (z : ℝ) (up : Bool) : ℝ := if up then Int.fract z else 1 - Int.fract z

theorem roundingMass_nonneg (z : ℝ) (up : Bool) : 0 ≤ roundingMass z up := by
  cases up
  · exact sub_nonneg.mpr (Int.fract_lt_one z).le
  · exact Int.fract_nonneg z

@[simp] theorem roundingMass_sum (z : ℝ) : ∑ up, roundingMass z up = 1 := by
  simp [roundingMass]

/-- Stochastic rounding is unbiased for every real signed increment. -/
theorem roundingFirstMoment (z : ℝ) : ∑ up, roundingMass z up * (rounded z up : ℝ) = z := by
  simp [roundingMass, rounded, Int.fract, -Int.self_sub_floor]
  ring

variable {D : Type*} [Fintype D] [DecidableEq D]

/-- Row `source` supplies the proposal probabilities. Zero proposal probabilities
are allowed on disconnected edges. A proposal to the source produces no spawn. -/
structure Proposal (H : Matrix D D ℝ) where
  prob : D → D → ℝ
  nonneg : ∀ j k, 0 ≤ prob j k
  normalized : ∀ j, ∑ k, prob j k = 1
  support : ∀ j k, k ≠ j → H k j ≠ 0 → prob j k ≠ 0

structure Walker (D : Type*) where
  site : D
  positive : Bool

def Walker.sign (w : Walker D) : ℤ := if w.positive then 1 else -1

/-- The selected determinant and the two Bernoulli rounding decisions. -/
abbrev Outcome (D : Type*) := D × Bool × Bool

def siteIndicator (i j : D) : ℤ := if i = j then 1 else 0

def spawnTarget (H : Matrix D D ℝ) (q : Proposal H) (τ : ℝ) (w : Walker D) (k : D) : ℝ :=
  if k = w.site then 0 else -τ * H k w.site * w.sign / q.prob w.site k

def diagonalTarget (H : Matrix D D ℝ) (τ shift : ℝ) (w : Walker D) : ℝ :=
  -τ * (H w.site w.site - shift) * w.sign

def outcomeMass (H : Matrix D D ℝ) (q : Proposal H) (τ shift : ℝ)
    (w : Walker D) (o : Outcome D) : ℝ :=
  q.prob w.site o.1 * roundingMass (spawnTarget H q τ w o.1) o.2.1 *
    roundingMass (diagonalTarget H τ shift w) o.2.2

/-- Net signed integer walkers at determinant `i` after one parent is updated. -/
def nextCount (H : Matrix D D ℝ) (q : Proposal H) (τ shift : ℝ)
    (w : Walker D) (o : Outcome D) (i : D) : ℤ :=
  siteIndicator i w.site * (w.sign + rounded (diagonalTarget H τ shift w) o.2.2) +
    siteIndicator i o.1 * rounded (spawnTarget H q τ w o.1) o.2.1

theorem outcomeMass_nonneg (H : Matrix D D ℝ) (q : Proposal H) (τ shift : ℝ)
    (w : Walker D) (o : Outcome D) : 0 ≤ outcomeMass H q τ shift w o :=
  mul_nonneg (mul_nonneg (q.nonneg ..) (roundingMass_nonneg ..)) (roundingMass_nonneg ..)

@[simp] theorem outcomeMass_sum (H : Matrix D D ℝ) (q : Proposal H) (τ shift : ℝ)
    (w : Walker D) : ∑ o, outcomeMass H q τ shift w o = 1 := by
  simp only [Fintype.sum_prod_type, outcomeMass, ← Finset.mul_sum, roundingMass_sum, mul_one,
    q.normalized]

/-- The fixed-shift Euler propagator `I - τ(H - shift I)`. -/
def euler (H : Matrix D D ℝ) (τ shift : ℝ) : Matrix D D ℝ :=
  (1 + τ * shift) • (1 : Matrix D D ℝ) - τ • H

private theorem roundedCounts (p z d : ℝ) (a b s : ℤ) :
    (∑ r, ∑ u, p * roundingMass z r * roundingMass d u *
      ((a * (s + rounded d u) + b * rounded z r : ℤ) : ℝ)) =
      p * ((a : ℝ) * (s + d) + b * z) := by
  simp [rounded, roundingMass, Int.fract, -Int.self_sub_floor]
  ring

/-- Expectation over the actual integer spawning and diagonal outcomes of one signed walker. -/
theorem walkerFirstMoment (H : Matrix D D ℝ) (q : Proposal H) (τ shift : ℝ)
    (w : Walker D) (i : D) :
    ∑ o, outcomeMass H q τ shift w o * (nextCount H q τ shift w o i : ℝ) =
      euler H τ shift i w.site * w.sign := by
  simp only [Fintype.sum_prod_type, outcomeMass, nextCount, roundedCounts]
  let stay := (siteIndicator i w.site : ℝ) * (w.sign + diagonalTarget H τ shift w)
  let hop := if i = w.site then 0 else -τ * H i w.site * w.sign
  calc
    _ = ∑ k, (q.prob w.site k * stay + if i = k then hop else 0) := by
      apply Finset.sum_congr rfl
      intro k _
      change q.prob w.site k * (stay + _) = _
      rw [mul_add]
      congr 1
      by_cases hik : i = k
      · subst k
        by_cases hself : i = w.site
        · simp [hop, spawnTarget, hself]
        · by_cases hzero : H i w.site = 0
          · simp [hop, spawnTarget, hself, hzero]
          · simp [hop, spawnTarget, hself, siteIndicator]
            field_simp [q.support _ _ hself hzero]
      · simp [siteIndicator, hik]
    _ = _ := by
      rw [Finset.sum_add_distrib, ← Finset.sum_mul, q.normalized]
      simp only [one_mul, Finset.sum_ite_eq, Finset.mem_univ, ite_true]
      simp only [stay, hop, siteIndicator, euler, Matrix.sub_apply, Matrix.smul_apply,
        smul_eq_mul, Matrix.one_apply, diagonalTarget]
      split_ifs with h
      · subst i
        push_cast
        ring
      · push_cast
        ring

/-- Cancel positive/negative pairs at one determinant. -/
def annihilate (positive negative : ℕ) : ℕ × ℕ :=
  (positive - min positive negative, negative - min positive negative)

/-- Annihilation preserves the signed coefficient and leaves at most one sign present. -/
theorem annihilationPreserves (positive negative : ℕ) :
    ((annihilate positive negative).1 : ℤ) - (annihilate positive negative).2 =
      (positive : ℤ) - negative ∧
    ((annihilate positive negative).1 = 0 ∨ (annihilate positive negative).2 = 0) := by
  unfold annihilate
  simp only
  omega

private theorem productMarginal {W O : Type*} [Fintype W] [DecidableEq W] [Fintype O]
    (p : W → O → ℝ) (hp : ∀ w, ∑ o, p w o = 1) (w : W) (f : O → ℝ) :
    (∑ draw : W → O, (∏ u, p u (draw u)) * f (draw w)) = ∑ o, p w o * f o := by
  classical
  let term (u : W) (o : O) := p u o * if u = w then f o else 1
  calc
    _ = ∑ draw : W → O, ∏ u, term u (draw u) := by
      simp only [term, Finset.prod_mul_distrib, Fintype.prod_ite_eq']
    _ = ∏ u, ∑ o, term u o := (Fintype.prod_sum term).symm
    _ = _ := by
      have hterm (u : W) : ∑ o, term u o = if u = w then ∑ o, p w o * f o else 1 := by
        by_cases hu : u = w <;> simp [term, hu, hp]
      simp [hterm]

variable {W : Type*} [Fintype W] [DecidableEq W]

/-- Integer coefficient vector of the parent population in the determinant basis. -/
def signedPopulation (walkers : W → Walker D) (i : D) : ℤ :=
  ∑ w, siteIndicator i (walkers w).site * (walkers w).sign

/-- The independent proposal/rounding law on simultaneous outcomes for every parent. -/
def populationMass (H : Matrix D D ℝ) (q : Proposal H) (τ shift : ℝ) (walkers : W → Walker D)
    (draw : W → Outcome D) : ℝ := ∏ w, outcomeMass H q τ shift (walkers w) (draw w)

theorem populationMass_probability (H : Matrix D D ℝ) (q : Proposal H) (τ shift : ℝ)
    (walkers : W → Walker D) :
    (∀ draw, 0 ≤ populationMass H q τ shift walkers draw) ∧
    (∑ draw, populationMass H q τ shift walkers draw) = 1 := by
  classical
  refine ⟨fun draw ↦ Finset.prod_nonneg (fun w _ ↦ outcomeMass_nonneg ..), ?_⟩
  simp [populationMass, ← Fintype.prod_sum]

/-- One unconstrained fixed-shift FCIQMC step is an unbiased realization of the
discrete imaginary-time CI equation, for any finite population of signed parents. -/
theorem populationFirstMoment (H : Matrix D D ℝ) (q : Proposal H) (τ shift : ℝ)
    (walkers : W → Walker D) (i : D) :
    (∑ draw, populationMass H q τ shift walkers draw *
      ((∑ w, nextCount H q τ shift (walkers w) (draw w) i : ℤ) : ℝ)) =
    (euler H τ shift).mulVec (fun j ↦ (signedPopulation walkers j : ℝ)) i := by
  classical
  have marginal (w : W) :
      (∑ draw, populationMass H q τ shift walkers draw *
        (nextCount H q τ shift (walkers w) (draw w) i : ℝ)) =
      euler H τ shift i (walkers w).site * (walkers w).sign :=
    (productMarginal (fun u ↦ outcomeMass H q τ shift (walkers u))
      (fun u ↦ outcomeMass_sum H q τ shift (walkers u)) w
      (fun o ↦ (nextCount H q τ shift (walkers w) o i : ℝ))).trans
      (walkerFirstMoment H q τ shift (walkers w) i)
  simp only [Int.cast_sum, Finset.mul_sum]
  rw [Finset.sum_comm]
  simp only [marginal]
  rw [Matrix.mulVec_apply_eq_sum]
  simp only [signedPopulation, Int.cast_sum, Int.cast_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro w _
  simp [siteIndicator, apply_ite]

/-- Resolve all signed arrivals into counts of positive and negative survivors. -/
def survivors (arrivals : W → ℤ) : ℕ × ℕ :=
  annihilate (∑ w, (arrivals w).toNat) (∑ w, (-arrivals w).toNat)

omit [DecidableEq W] in
/-- For every realized spawn/death configuration, local annihilation gives exactly
the net signed count used in the population first-moment theorem. -/
theorem survivorsSignedCount (arrivals : W → ℤ) :
    ((survivors arrivals).1 : ℤ) - (survivors arrivals).2 = ∑ w, arrivals w := by
  unfold survivors
  rw [(annihilationPreserves _ _).1, Nat.cast_sum, Nat.cast_sum, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro w _
  omega

end FormalQChem.StatePrep.ImaginaryTimeProjection.FCIQMC
