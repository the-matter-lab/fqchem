module

public import Mathlib.LinearAlgebra.Matrix.Symmetric
public import Mathlib.Data.EReal.Operations
import Mathlib.Tactic

/-!
# Importance-sampled diffusion Monte Carlo on a finite configuration space

The Green kernel acts on terminal observables by summing over the next configuration.
A positive guide changes the transition probabilities. The branching factor restores
the original propagation exactly in expectation. The second part proves the lattice
fixed-node upper bound by accounting for each removed hopping matrix element.

* [Umrigar, Nightingale & Runge (1993)](https://doi.org/10.1063/1.465195)
* [ten Haaf et al. (1995)](https://doi.org/10.1103/PhysRevB.51.13039)
-/

@[expose] public section
noncomputable section
namespace FQChem.StatePrep.ImaginaryTimeProjection.DiffusionMonteCarlo

variable {n : ℕ}

def branching (G : Matrix (Fin n) (Fin n) ℝ) (g : Fin n → ℝ) (i : Fin n) :=
  G.mulVec g i / g i

def transition (G : Matrix (Fin n) (Fin n) ℝ) (g : Fin n → ℝ) (i j : Fin n) :=
  G i j * g j / G.mulVec g i

/-- The guide-transformed diffusion kernel has nonnegative entries and unit row sums. -/
theorem transitionMarkov (G : Matrix (Fin n) (Fin n) ℝ) (g : Fin n → ℝ)
    (hG : ∀ i j, 0 ≤ G i j) (hg : ∀ i, 0 < g i) (hstep : ∀ i, 0 < G.mulVec g i) (i : Fin n) :
    (∀ j, 0 ≤ transition G g i j) ∧ ∑ j, transition G g i j = 1 ∧ 0 < branching G g i := by
  refine ⟨fun j => div_nonneg (mul_nonneg (hG i j) (hg j).le) (hstep i).le, ?_,
    div_pos (hstep i) (hg i)⟩
  unfold transition
  rw [← Finset.sum_div]
  exact div_self (hstep i).ne'

/-- Probability of a path times its accumulated branching weights and terminal observable. -/
def pathContribution (P : Fin n → Fin n → ℝ) (b f : Fin n → ℝ) :
    (k : ℕ) → Fin n → (Fin k → Fin n) → ℝ
  | 0, i, _ => f i
  | k+1, i, path => b i * P i (path 0) *
    pathContribution P b f k (path 0) (fun t => path t.succ)

/-- Finite Feynman–Kac formula. Starting at i, the weighted guided path expectation
is the original k-step kernel applied to g f and divided by the initial guide. -/
theorem guidedFeynmanKac (G : Matrix (Fin n) (Fin n) ℝ) (g f : Fin n → ℝ)
    (hg : ∀ i, 0 < g i) (hstep : ∀ i, 0 < G.mulVec g i) (k : ℕ) (i : Fin n) :
    (G^k).mulVec (fun j => g j * f j) i =
      g i * ∑ path : Fin k → Fin n,
        pathContribution (transition G g) (branching G g) f k i path := by
  induction k generalizing i with
  | zero => simp [pathContribution]
  | succ k ih =>
    rw [pow_succ', ← Matrix.mulVec_mulVec, ← (Fin.consEquiv (fun _ : Fin (k+1) => Fin n)).sum_comp,
      Fintype.sum_prod_type, Finset.mul_sum]
    change (∑ j, G i j * (G^k).mulVec (fun j => g j * f j) j) = _
    apply Finset.sum_congr rfl
    intro j _
    simp only [ih, Fin.consEquiv_apply, pathContribution, Fin.cons_zero, Fin.cons_succ, ← Finset.mul_sum]
    unfold branching transition
    field_simp [(hstep i).ne', (hg i).ne']

/-- A guide eigenvector makes branching constant across configurations. -/
theorem constantBranchingIff (G : Matrix (Fin n) (Fin n) ℝ) (g : Fin n → ℝ)
    (hg : ∀ i, g i ≠ 0) (c : ℝ) :
    (∀ i, branching G g i = c) ↔ G.mulVec g = c • g := by
  simp only [branching, funext_iff, Pi.smul_apply, smul_eq_mul, div_eq_iff (hg _)]

/-- For a symmetric kernel and positive exact guide, the Markov chain has g² as
an unnormalized stationary distribution. This is detailed balance at each edge. -/
theorem exactGuideStationarity (G : Matrix (Fin n) (Fin n) ℝ) (g : Fin n → ℝ)
    (hG : G.IsSymm) (hg : ∀ i, 0 < g i) (hstep : ∀ i, 0 < G.mulVec g i)
    (hpositive : ∀ i j, 0 ≤ G i j) (c : ℝ) (eigen : G.mulVec g = c • g) :
    (∀ i j, g i^2 * transition G g i j = g j^2 * transition G g j i) ∧
    ∀ j, (∑ i, g i^2 * transition G g i j) = g j^2 := by
  have action (i : Fin n) : G.mulVec g i = c * g i := congrFun eigen i
  have balance (i j : Fin n) : g i^2 * transition G g i j = g j^2 * transition G g j i := by
    have hc : c ≠ 0 := by
      intro h
      have := hstep i
      rw [action, h, zero_mul] at this
      exact lt_irrefl _ this
    simp only [transition, action, hG.apply j i]
    field_simp [hc, (hg i).ne', (hg j).ne']
  refine ⟨balance, fun j => ?_⟩
  calc
    _ = ∑ i, g j^2 * transition G g j i := Finset.sum_congr rfl fun i _ => balance i j
    _ = _ := by rw [← Finset.mul_sum, (transitionMarkov G g hpositive hg hstep j).2.1, mul_one]

/-- An Euler imaginary-time kernel branches according to the guide's local energy. -/
theorem branchingLocalEnergy (H : Matrix (Fin n) (Fin n) ℝ) (g : Fin n → ℝ)
    (τ reference : ℝ) (i : Fin n) (hi : g i ≠ 0) :
    branching ((1 + τ * reference) • (1 : Matrix (Fin n) (Fin n) ℝ) - τ • H) g i =
      1 - τ * (H.mulVec g i / g i - reference) := by
  simp only [branching, Matrix.sub_mulVec, Matrix.smul_mulVec, Matrix.one_mulVec, Pi.sub_apply,
    Pi.smul_apply, smul_eq_mul]
  field_simp
  ring

/-- Each unordered hopping pair is listed once. The data parametrize a real symmetric Hamiltonian. -/
abbrev Edge (n : ℕ) := {p : Fin n × Fin n // p.1 < p.2}

structure LatticeHamiltonian (n : ℕ) where
  diagonal : Fin n → ℝ
  hopping : Edge n → ℝ

variable (H : LatticeHamiltonian n) (g x : Fin n → ℝ)

def quadraticEnergy :=
  (∑ i, H.diagonal i * x i ^ 2) + ∑ p, 2 * H.hopping p * x p.val.1 * x p.val.2

def signFlip (p : Edge n) : Prop := 0 < H.hopping p * g p.val.1 * g p.val.2

/-- Hoppings with a sign conflict are removed. Each removed hopping contributes
guide-ratio-dependent corrections to the two diagonal entries. -/
def fixedNodeEnergy :=
  (∑ i, H.diagonal i * x i ^ 2) + ∑ p : Edge n,
    if 0 < H.hopping p * g p.val.1 * g p.val.2 then
      H.hopping p * (g p.val.2 / g p.val.1 * x p.val.1 ^ 2 + g p.val.1 / g p.val.2 * x p.val.2 ^ 2)
    else 2 * H.hopping p * x p.val.1 * x p.val.2

def edgePenalty (p : Edge n) :=
  if 0 < H.hopping p * g p.val.1 * g p.val.2 then
    (H.hopping p * g p.val.1 * g p.val.2) * (x p.val.1 / g p.val.1 - x p.val.2 / g p.val.2)^2
  else 0

/-- Exact sum-of-squares decomposition of the fixed-node energy shift. -/
theorem fixedNodeShift (hg : ∀ i, g i ≠ 0) :
    fixedNodeEnergy H g x = quadraticEnergy H x + ∑ p, edgePenalty H g x p := by
  unfold fixedNodeEnergy quadraticEnergy
  rw [add_assoc, ← Finset.sum_add_distrib]
  congr 1
  apply Finset.sum_congr rfl
  intro p _
  unfold edgePenalty
  split_ifs
  · field_simp [hg]
    ring
  · ring

private theorem penalty_nonneg (p : Edge n) : 0 ≤ edgePenalty H g x p := by
  unfold edgePenalty
  split_ifs with h
  · exact mul_nonneg h.le (sq_nonneg _)
  · exact le_rfl

/-- Equality of the quadratic forms requires the normalized amplitudes x/g
to agree across every removed hopping. -/
theorem fixedNodeEqualityIff (hg : ∀ i, g i ≠ 0) :
    fixedNodeEnergy H g x = quadraticEnergy H x ↔
      ∀ p, signFlip H g p → x p.val.1 / g p.val.1 = x p.val.2 / g p.val.2 := by
  rw [fixedNodeShift H g x hg, add_eq_left,
    Finset.sum_eq_zero_iff_of_nonneg (fun p _ => penalty_nonneg H g x p)]
  constructor
  · intro h p hp
    have hz := h p (Finset.mem_univ _)
    have pos : 0 < H.hopping p * g p.val.1 * g p.val.2 := hp
    simp only [edgePenalty, pos, ↓reduceIte] at hz
    exact sub_eq_zero.mp ((pow_eq_zero_iff (by decide : 2 ≠ 0)).mp
      ((mul_eq_zero.mp hz).resolve_left pos.ne'))
  · intro h p _
    by_cases hp : signFlip H g p
    · simp [edgePenalty, show 0 < H.hopping p * g p.val.1 * g p.val.2 from hp, h p hp]
    · simp [edgePenalty, signFlip] at hp ⊢
      simp [hp.not_gt]

/-- Ground energy as the infimum over normalized real configuration vectors. -/
def variationalGround (Q : (Fin n → ℝ) → ℝ) : EReal :=
  ⨅ u : {u : Fin n → ℝ // ∑ i, u i^2 = 1}, (Q u.val : EReal)

/-- The lattice fixed-node energy is a variational upper bound for the physical ground energy. -/
theorem fixedNodeUpperBound (hg : ∀ i, g i ≠ 0) :
    variationalGround (quadraticEnergy H) ≤ variationalGround (fixedNodeEnergy H g) := by
  apply iInf_mono
  intro u
  apply EReal.coe_le_coe_iff.mpr
  rw [fixedNodeShift H g u.val hg]
  exact le_add_of_nonneg_right (Finset.sum_nonneg fun p _ => penalty_nonneg H g u.val p)

/-- A normalized physical ground state with matching ratios on every sign-flip
edge certifies equality of both variational ground energies. -/
theorem exactFixedNode (hg : ∀ i, g i ≠ 0) (norm : ∑ i, x i^2 = 1)
    (ground : variationalGround (quadraticEnergy H) = (quadraticEnergy H x : EReal))
    (matchRatios : ∀ p, signFlip H g p → x p.val.1 / g p.val.1 = x p.val.2 / g p.val.2) :
    variationalGround (fixedNodeEnergy H g) = variationalGround (quadraticEnergy H) := by
  apply le_antisymm _ (fixedNodeUpperBound H g hg)
  rw [ground, ← (fixedNodeEqualityIff H g x hg).mpr matchRatios]
  exact iInf_le (fun u : {u : Fin n → ℝ // ∑ i, u i^2 = 1} => (fixedNodeEnergy H g u.val : EReal))
    ⟨x, norm⟩

/-- Taking the normalized physical ground state itself as guide makes the
finite-lattice fixed-node upper bound exact. -/
theorem exactGuideGroundEnergy (hg : ∀ i, g i ≠ 0) (norm : ∑ i, g i^2 = 1)
    (ground : variationalGround (quadraticEnergy H) = (quadraticEnergy H g : EReal)) :
    variationalGround (fixedNodeEnergy H g) = variationalGround (quadraticEnergy H) :=
  exactFixedNode H g g hg norm ground (fun p _ => by simp [hg])

end FQChem.StatePrep.ImaginaryTimeProjection.DiffusionMonteCarlo
