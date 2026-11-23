module

public import Mathlib.Analysis.SpecialFunctions.Arcosh
public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
public import Mathlib.LinearAlgebra.ExteriorPower.Pairing
import Mathlib.Tactic

/-!
# Auxiliary-field quantum Monte Carlo

The repulsive, particle–hole symmetric Hubbard interaction has an exact discrete
spin-field decomposition on each imaginary-time slice. Independent fields at
different sites give the finite-lattice transformation. For a supplied finite
one-body decomposition, an unconstrained walk over field histories gives the
exact power of the supplied step. The exterior power propagates occupied orbitals
and its dual pairing evaluates each walker's Slater overlap by a determinant.

* [Hirsch, Discrete Hubbard–Stratonovich transformation (1983)](https://doi.org/10.1103/PhysRevB.28.4059)
* [Sugiyama & Koonin, Auxiliary field Monte-Carlo for quantum many-body ground states (1986)](https://doi.org/10.1016/0003-4916(86)90107-7)
* [Zhang & Krakauer, Quantum Monte Carlo method using phase-free random walks with Slater determinants (2003)](https://doi.org/10.1103/PhysRevLett.90.136401)
-/

@[expose] public section
noncomputable section

namespace FormalQChem.StatePrep.ImaginaryTimeProjection.AFQMC

def occupation (b : Bool) : ℝ := if b then 1 else 0

/-- x is Δτ U. Each of the two fields has equal sampling probability. -/
def hirschBranch (x γ : ℝ) (up down field : Bool) : ℝ :=
  Real.exp (-x/4) / 2 * Real.exp ((if field then γ else -γ) *
    (occupation up - occupation down))

def hubbardFactor (x : ℝ) (up down : Bool) :=
  Real.exp (-x * (occupation up - 1/2) * (occupation down - 1/2))

/-- The spin-field parameter is real and nonnegative for every repulsive step. -/
theorem realHirschParameter {x : ℝ} (hx : 0 ≤ x) :
    ∃ γ : ℝ, 0 ≤ γ ∧ Real.cosh γ = Real.exp (x/2) := by
  have h : 1 ≤ Real.exp (x/2) := Real.one_le_exp (by positivity)
  exact ⟨_, Real.arcosh_nonneg h, Real.cosh_arcosh h⟩

theorem hirschLocal {x γ : ℝ} (hγ : Real.cosh γ = Real.exp (x/2)) (up down : Bool) :
    hubbardFactor x up down = ∑ s, hirschBranch x γ up down s := by
  let d := occupation up - occupation down
  have havg : (∑ s, hirschBranch x γ up down s) = Real.exp (-x/4) * Real.cosh (γ*d) := by
    simp only [Fintype.sum_bool, hirschBranch, Bool.false_eq_true, ite_false, ite_true, d,
      Real.cosh_eq, neg_mul]
    ring
  rw [havg]
  cases up <;> cases down <;>
    norm_num [hubbardFactor, d, occupation, hγ, Real.cosh_neg] <;>
    (try rw [← Real.exp_add]) <;> congr 1 <;> ring

/-- For a fixed field the two spin orbitals propagate independently, with opposite
one-body couplings. Their product and the configuration-independent weight give the branch. -/
theorem spinOrbitalFactorization (x γ : ℝ) (up down field : Bool) :
    let h := if field then γ else -γ
    hirschBranch x γ up down field = Real.exp (-x/4) / 2 *
      (if up then Real.exp h else 1) * (if down then Real.exp (-h) else 1) := by
  dsimp only
  cases up <;> cases down <;>
    simp [hirschBranch, occupation, mul_assoc, ← Real.exp_add]

/-- The many-site spin field gives the diagonal interaction propagator on every
occupation configuration. Each field factor contains its own factor of 1/2. -/
theorem hirschLattice {sites : ℕ} {x γ : ℝ} (hγ : Real.cosh γ = Real.exp (x/2))
    (up down : Fin sites → Bool) :
    (∏ i, hubbardFactor x (up i) (down i)) =
      ∑ field : Fin sites → Bool, ∏ i, hirschBranch x γ (up i) (down i) (field i) := by
  simp_rw [hirschLocal hγ]
  exact Fintype.prod_sum _

/-- A time-ordered product, with slice zero acting last on the input state. -/
def historyProduct {σ A : Type*} [Monoid A] (B : σ → A) :
    (k : ℕ) → (Fin k → σ) → A
  | 0, _ => 1
  | k+1, path => B (path 0) * historyProduct B k (fun j => path j.succ)

/-- The finite path sum expands an arbitrary noncommuting field-summed step.
Any kinetic/interaction splitting error belongs to the choice of this step. -/
theorem fieldHistoryExpansion {σ A : Type*} [Fintype σ] [Semiring A] (B : σ → A) (k : ℕ) :
    (∑ s, B s) ^ k = ∑ path : Fin k → σ, historyProduct B k path := by
  induction k with
  | zero => simp [historyProduct]
  | succ k ih =>
    rw [pow_succ', ih, Finset.sum_mul,
      ← (Fin.consEquiv (fun _ : Fin (k+1) => σ)).sum_comp, Fintype.sum_prod_type]
    simp [historyProduct, Finset.mul_sum]

abbrev OccupationConfig (sites : ℕ) := (Fin sites → Bool) × (Fin sites → Bool)

def interactionStep {sites : ℕ} (x : ℝ) : Matrix (OccupationConfig sites) (OccupationConfig sites) ℂ :=
  Matrix.diagonal fun c => ((∏ i, hubbardFactor x (c.1 i) (c.2 i) : ℝ) : ℂ)

def fieldStep {sites : ℕ} (x γ : ℝ) (field : Fin sites → Bool) :
    Matrix (OccupationConfig sites) (OccupationConfig sites) ℂ :=
  Matrix.diagonal fun c => ((∏ i, hirschBranch x γ (c.1 i) (c.2 i) (field i) : ℝ) : ℂ)

/-- In the full occupation basis, insert a supplied kinetic step between successive
Hubbard interaction steps. All time-slice and site fields are summed independently. -/
theorem hubbardFreeProjection {sites : ℕ} {x γ : ℝ} (hγ : Real.cosh γ = Real.exp (x/2))
    (T : Matrix (OccupationConfig sites) (OccupationConfig sites) ℂ) (k : ℕ) :
    (T * interactionStep x)^k = ∑ path : Fin k → Fin sites → Bool,
      historyProduct (fun field => T * fieldStep x γ field) k path := by
  have hs : interactionStep (sites := sites) x = ∑ field, fieldStep x γ field := by
    ext a b
    by_cases h : a = b
    · subst b
      simp only [interactionStep, fieldStep, Matrix.sum_apply, Matrix.diagonal_apply_eq,
        hirschLattice hγ, Complex.ofReal_sum]
    · simp [interactionStep, fieldStep, Matrix.sum_apply, Matrix.diagonal_apply_ne _ h]
  rw [hs, Matrix.mul_sum, fieldHistoryExpansion]

variable {σ V : Type*} [Fintype σ] [AddCommGroup V] [Module ℂ V]

/-- Branch evolution of an n-electron determinant is the exterior lift of a
one-particle map, multiplied by the complex scalar field weight. -/
def determinantStep (n : ℕ) (w : σ → ℂ) (B : σ → Module.End ℂ V) :=
  ∑ s, w s • exteriorPower.map n (B s)

omit [Fintype σ] in
theorem slaterHistory {n : ℕ} (w : σ → ℂ) (B : σ → Module.End ℂ V)
    (orbitals : Fin n → V) (k : ℕ) (path : Fin k → σ) :
    historyProduct (fun s => w s • exteriorPower.map n (B s)) k path
        (exteriorPower.ιMulti ℂ n orbitals) =
      (∏ t, w (path t)) • exteriorPower.ιMulti ℂ n
        (fun j => historyProduct B k path (orbitals j)) := by
  induction k with
  | zero => simp [historyProduct]
  | succ k ih =>
    simp only [historyProduct, Module.End.mul_apply, ih, LinearMap.smul_apply, map_smul,
      exteriorPower.map_apply_ιMulti, Fin.prod_univ_succ, Function.comp_def, smul_smul]
    rw [mul_comm]

/-- Exact free projection of an initial Slater determinant by a finite auxiliary-field
step. Complex field weights are allowed, so phase cancellation is retained in the sum. -/
theorem freeProjection {n : ℕ} (w : σ → ℂ) (B : σ → Module.End ℂ V)
    (orbitals : Fin n → V) (k : ℕ) :
    (determinantStep n w B ^ k) (exteriorPower.ιMulti ℂ n orbitals) =
      ∑ path : Fin k → σ, (∏ t, w (path t)) • exteriorPower.ιMulti ℂ n
        (fun j => historyProduct B k path (orbitals j)) := by
  simp only [determinantStep, fieldHistoryExpansion, LinearMap.sum_apply, slaterHistory]

/-- Trial-bra overlap in the field walk is the weighted sum of single-particle
overlap determinants. The trial orbitals are represented by their linear bras. -/
theorem projectedOverlap {n : ℕ} (w : σ → ℂ) (B : σ → Module.End ℂ V)
    (orbitals : Fin n → V) (bras : Fin n → Module.Dual ℂ V) (k : ℕ) :
    exteriorPower.pairingDual ℂ V n (exteriorPower.ιMulti ℂ n bras)
        ((determinantStep n w B ^ k) (exteriorPower.ιMulti ℂ n orbitals)) =
      ∑ path : Fin k → σ, (∏ t, w (path t)) *
        Matrix.det (Matrix.of fun i j => bras j (historyProduct B k path (orbitals i))) := by
  simp [freeProjection, exteriorPower.pairingDual_ιMulti_ιMulti]

/-- A trial bra's mixed energy on a single walker or a superposition of walkers. -/
def mixedEnergy (trial : Module.Dual ℂ V) (H : Module.End ℂ V) (v : V) : ℂ :=
  trial (H v) / trial v

/-- For walkers with nonzero trial overlap, importance weighting the local energies
recovers the mixed energy of their coherent sum. The combined trial overlap must
also be nonzero for the normalized estimator. -/
theorem mixedEstimator (trial : Module.Dual ℂ V) (H : Module.End ℂ V)
    (w : σ → ℂ) (v : σ → V) (overlap : ∀ s, trial (v s) ≠ 0)
    (total : (∑ s, w s * trial (v s)) ≠ 0) :
    ∑ s, ((w s * trial (v s)) / (∑ j, w j * trial (v j))) * mixedEnergy trial H (v s) =
      mixedEnergy trial H (∑ s, w s • v s) := by
  simp only [mixedEnergy, map_sum, map_smul, smul_eq_mul]
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro s _
  field_simp [overlap s, total]

/-- An exact left eigenstate as trial bra gives the same local energy for every
walker of nonzero overlap. -/
theorem exactTrialLocalEnergy (trial : Module.Dual ℂ V) (H : Module.End ℂ V)
    (energy : ℂ) (leftEigen : ∀ v, trial (H v) = energy * trial v)
    (v : V) (overlap : trial v ≠ 0) : mixedEnergy trial H v = energy := by
  rw [mixedEnergy, leftEigen, mul_div_cancel_right₀ _ overlap]

/-- The phaseless overlap-angle constraint multiplies a positive walker weight
by this factor, where θ is the change in phase of its trial overlap. -/
def cosineConstraint (θ : ℝ) : ℝ := max 0 (Real.cos θ)

/-- Relative weight loss from the cosine constraint alone along one path.
The comparison holds the other importance and branching factors fixed. -/
theorem phaselessWeightLoss (angles : σ → ℝ) :
    0 ≤ 1 - ∏ s, cosineConstraint (angles s) ∧
    1 - ∏ s, cosineConstraint (angles s) ≤ (∑ s, angles s ^ 2) / 2 := by
  classical
  have nonneg (s : σ) : 0 ≤ cosineConstraint (angles s) := le_max_left ..
  have cap (s : σ) : cosineConstraint (angles s) ≤ 1 := max_le zero_le_one (Real.cos_le_one _)
  have productCap (u : Finset σ) : ∏ s ∈ u, cosineConstraint (angles s) ≤ 1 :=
    Finset.prod_le_one₀ (fun s _ ↦ nonneg s) (fun s _ ↦ cap s)
  refine ⟨sub_nonneg.mpr (productCap _), ?_⟩
  suffices bound : ∀ u : Finset σ, 1 - ∏ s ∈ u, cosineConstraint (angles s) ≤
      (∑ s ∈ u, angles s ^ 2) / 2 from bound _
  intro u
  induction u using Finset.induction_on with
  | empty => simp
  | insert j u fresh ih =>
    rw [Finset.prod_insert fresh, Finset.sum_insert fresh]
    have h := mul_le_mul_of_nonneg_right (productCap u) (sub_nonneg.mpr (cap j))
    have hj : 1 - angles j ^ 2 / 2 ≤ cosineConstraint (angles j) :=
      Real.one_sub_sq_div_two_le_cos.trans (le_max_right ..)
    nlinarith only [ih, h, hj]

end FormalQChem.StatePrep.ImaginaryTimeProjection.AFQMC
