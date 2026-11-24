module

public import Qatlib.Papers.QPowerSimon97.StandardModel.InfiniteOracle

/-!
# A single Simon oracle with adaptive queries across lengths

The label at each width records whether the oracle has a nonzero hidden period.
Programs see only the function values. Different widths share one fixed oracle.
-/

@[expose] public section
noncomputable section

namespace FQChem.Complexity.SimonOracleMachines

open Qatlib.Concepts.PauliClifford.ExactRank
open Qatlib.Foundations.PureStateMath
open Qatlib.Papers.QPowerSimon97.Recovery
open Qatlib.Papers.QPowerSimon97.StandardDefs
open Qatlib.Concepts.AEMeanReadout.LocalAEBackend.CostedLaw
open Qatlib.Concepts.LinearLearning.ConcisePipeline.CostedLaw
open scoped ENNReal

abbrev Entry (n : ℕ) := Bool × (BooleanVec n → BooleanVec n)
abbrev Oracle := (n : ℕ) → Entry n

/-- A deterministic transcript of at most q adaptive queries at widths up to W.
Randomness is modelled by sampling a transcript tree before execution. -/
inductive Tree (W : ℕ) : ℕ → Type
  | halt {q : ℕ} (answer : Bool) : Tree W q
  | ask {q : ℕ} (w : ℕ) (hw : w ≤ W) (x : BooleanVec w)
      (next : BooleanVec w → Tree W q) : Tree W (q+1)

namespace Tree

variable {W q : ℕ}

def output (O : Oracle) : {q : ℕ} → Tree W q → Bool
  | _, .halt b => b
  | _, .ask w _ x next => output O (next ((O w).2 x))

/-- Queries away from n can be answered using the given fixed background oracle. -/
def restrict (n : ℕ) (O : Oracle) : {q : ℕ} → Tree W q → SimonQueryTree n
  | _, .halt b => .halt b
  | _, .ask w _ x next =>
    if h : n = w then
      .ask (h.symm ▸ x) (fun y => restrict n O (next (h ▸ y)))
    else restrict n O (next ((O w).2 x))

theorem restrictBound (n : ℕ) (O : Oracle) (t : Tree W q) :
    (t.restrict n O).maxQueries ≤ q := by
  induction t with
  | halt => simp [restrict, SimonQueryTree.maxQueries]
  | @ask q w hw x next ih =>
    by_cases h : n = w
    · subst w
      simp only [restrict]
      exact Nat.add_le_add_left (Finset.sup_le fun y _ => ih y) 1 |>.trans_eq (Nat.add_comm 1 q)
    · simpa only [restrict, dite_eq_right h] using (ih ((O w).2 x)).trans (Nat.le_succ q)

theorem restrictOutput (n : ℕ) (O : Oracle) (e : Entry n) (t : Tree W q) :
    (SimonQueryTree.run e.2 (t.restrict n O)).1 = t.output (Function.update O n e) := by
  induction t with
  | halt => rfl
  | ask w _ x next ih =>
    by_cases h : n = w
    · subst w
      simpa [restrict, SimonQueryTree.run, output] using
        ih (e.2 x)
    · simpa only [restrict, dite_eq_right h, output, Function.update_of_ne (Ne.symm h)] using
        ih ((O w).2 x)

theorem outputCongr (O O' : Oracle) (eq : ∀ w ≤ W, O w = O' w) (t : Tree W q) :
    t.output O = t.output O' := by
  induction t with
  | halt => rfl
  | ask w hw x next ih => simpa only [output, eq w hw] using ih ((O' w).2 x)

/-- Probability of correctly predicting the label at the input width. -/
def success (P : PMF (Tree W q)) (O : Oracle) (n : ℕ) : ℝ≥0∞ :=
  expectation P fun t => if t.output O = (O n).1 then 1 else 0

theorem successCongr (P : PMF (Tree W q)) (O O' : Oracle) (n : ℕ)
    (label : (O n).1 = (O' n).1) (eq : ∀ w ≤ W, O w = O' w) :
    success P O n = success P O' n := by
  apply expectation_congr
  intro t
  rw [outputCongr _ _ eq, label]

/-- A single hard promised width even when the program can query any fixed background. -/
theorem existsHardAt (P : PMF (Tree W q)) (O : Oracle) (n : ℕ) (hn : 64 ≤ n)
    (budget : (q : ℝ) ≤ (2 : ℝ) ^ ((n : ℝ)/4)) :
    ∃ e : Entry n, simonGoodDraw n e ∧ success P (Function.update O n e) n < ENNReal.ofReal (2/3) := by
  let f := fun t : Tree W q => t.restrict n O
  have bounded : SimonQueryTree.bounded (P.map f) q := by
    intro τ hτ
    have hm : (P.map f) τ ≠ 0 := by
      intro hz
      simp [hz] at hτ
    obtain ⟨t, _, rfl⟩ := (PMF.mem_support_map_iff f P τ).mp (((P.map f).mem_support_iff τ).mpr hm)
    exact restrictBound n O t
  obtain ⟨e, hg, hl⟩ := exists_good_low n hn q budget _ bounded
  refine ⟨e, hg, ?_⟩
  simpa only [SimonQueryTree.guessMass, expectation_map, f, restrictOutput, success,
    Function.update_self] using hl

end Tree

/-- Every countable collection of randomized adaptive algorithms with at most
2^(n/4) queries and an arbitrary finite width budget per machine and input has
one common separating oracle. The quantum procedure succeeds at every n ≥ 64.
Each classical algorithm fails with probability greater than 1/3 infinitely often.
At each diagonal stage all query widths reachable at earlier stages stay fixed. -/
theorem oracleSeparation (W Q : ℕ → ℕ → ℕ) (P : (m n : ℕ) → PMF (Tree (W m n) (Q m n)))
    (budget : ∀ m n, (Q m n : ℝ) ≤ (2 : ℝ) ^ ((n : ℝ)/4)) :
    ∃ O : Oracle, (∀ n, simonGoodDraw n (O n)) ∧
      (∀ n ≥ 64, ENNReal.ofReal (7/8) ≤ simonQuantumSuccess n (2*n) n (O n)) ∧
      ∀ m N, ∃ n ≥ N, Tree.success (P m n) O n < ENNReal.ofReal (2/3) := by
  classical
  let idx (k : ℕ) := (Nat.unpair k).1
  let width : ℕ → ℕ := Nat.rec 64 (fun k w => max w (W (idx k) w) + 1)
  have grow (k) : width k < width (k+1) := Nat.lt_succ_of_le (le_max_left _ _)
  have beyond (k) : W (idx k) (width k) < width (k+1) := Nat.lt_succ_of_le (le_max_right _ _)
  have mono : StrictMono width := strictMono_nat_of_lt_succ grow
  have large (k) : 64 ≤ width k := mono.monotone (Nat.zero_le k)
  let hard (k : ℕ) (O : Oracle) := (Tree.existsHardAt (P (idx k) (width k)) O (width k)
    (large k) (budget _ _)).choose
  have spec (k : ℕ) (O : Oracle) := (Tree.existsHardAt (P (idx k) (width k)) O (width k)
    (large k) (budget _ _)).choose_spec
  let stages : ℕ → Oracle := Nat.rec (fun _ => (false, id))
    (fun k S => Function.update S (width k) (hard k S))
  have step (k) : stages (k+1) = Function.update (stages k) (width k) (hard k (stages k)) := rfl
  have good (k : ℕ) : ∀ n, simonGoodDraw n (stages k n) := by
    induction k with
    | zero => exact fun _ => Or.inl ⟨rfl, Function.injective_id⟩
    | succ k ih =>
      intro n
      rw [step k]
      rcases eq_or_ne n (width k) with h | h
      · subst n
        rw [Function.update_self]
        exact (spec k (stages k)).1
      · rw [Function.update_of_ne h]
        exact ih n
  have stable (j k n : ℕ) (lj : j ≤ k) (lo : n < width j) : stages k n = stages j n := by
    induction k, lj using Nat.le_induction with
    | base => rfl
    | succ k jk ih =>
      simpa only [step k, Function.update_of_ne (lo.trans_le (mono.monotone jk)).ne] using ih
  let O : Oracle := fun n => stages (n+1) n
  have finalAt (j n) (hn : n < width j) : O n = stages j n := by
    let r := max j (n+1)
    have later : n < width (n+1) := lt_of_lt_of_le (Nat.lt_succ_self n) (mono.id_le (n+1))
    exact (stable (n+1) r n (le_max_right _ _) later).symm.trans (stable j r n (le_max_left _ _) hn)
  refine ⟨O, fun n => good (n+1) n, fun n hn => simonQuantumSuccess_good n hn _ (good (n+1) n), ?_⟩
  intro m N
  obtain ⟨k, hk, hm⟩ := exists_length_of_index m N
  change idx k = m at hm
  refine ⟨width k, hk.trans (mono.id_le k), ?_⟩
  subst m
  rw [Tree.successCongr _ O (stages (k+1)) (width k)
    (congrArg Prod.fst (finalAt (k+1) (width k) (grow k))) (fun w hw => finalAt (k+1) w (hw.trans_lt (beyond k)))]
  exact (spec k (stages k)).2

end FQChem.Complexity.SimonOracleMachines
