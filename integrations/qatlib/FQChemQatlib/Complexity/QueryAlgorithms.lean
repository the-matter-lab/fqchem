module

public import Qatlib.Papers.QPowerSimon97.Recovery.Theorem32Paper
public import Qatlib.Papers.QPowerSimon97.StandardModel.InfiniteOracle
public import Qatlib.Papers.ShorFactoring97.OrderRecovery.SourceWindowDecode
public import Qatlib.Concepts.PeriodSampling.FactorAlgorithm.ResidueFactoringAlgorithmShor

/-!
# Simon's oracle separation and Shor's order finding

The proofs and their query models are from the pinned Qatlib dependency.
Simon uses Boolean vector spaces and classical randomized query trees. The
two-sample order decoder uses independent modular-order phase readouts.
-/

@[expose] public section
noncomputable section

namespace FQChem.Complexity.QueryAlgorithms

open Qatlib.Foundations.PureStateMath
open Qatlib.Concepts.PauliClifford.ExactRank
open Qatlib.Concepts.WalshMoment.Forrelation
open Qatlib.Concepts.HspRecovery.ReductionCore
open Qatlib.Papers.QPowerSimon97.Recovery
open Qatlib.Papers.QPowerSimon97.StandardDefs
open Qatlib.Papers.ShorFactoring97.OrderRecovery
open Qatlib.Concepts.PeriodSampling.OrderRecovery
open Qatlib.Concepts.PeriodSampling.FactorAlgorithm
open scoped BigOperators

/-- Simon's promised mask is recovered with zero error, almost-sure termination,
and finite expected sample, query and decoding costs. -/
theorem simonMaskRecovery (n : ℕ) (R : Type) [AddCommGroup R] [Fintype R] [DecidableEq R]
    (f : BooleanVec n → R) (mask : Reg n) (queryTime : ℕ → ℕ)
    (promise : BooleanSimonPromise f (regBooleanEquiv n mask)) :
    Theorem32Conclusion n R f mask queryTime :=
  simonTheorem32 n R f mask queryTime promise

/-- Simon's Theorem 3.3 for the random permutation versus two-to-one oracle law. -/
theorem simonClassicalQueryBound (n : ℕ) (hn : 1 ≤ n) (q : ℕ)
    (budget : (q : ℝ) ≤ (2 : ℝ) ^ ((n : ℝ) / 4))
    (P : PMF (SimonQueryTree n)) (bounded : SimonQueryTree.bounded P q) :
    simonOracleGuessMass P ≤ ENNReal.ofReal (1 / 2 + (2 : ℝ) ^ (-(n : ℝ) / 2)) :=
  simonTheorem33RealBudget n hn q budget P bounded

/-- A single oracle family separates the quantum procedure from any given
countable collection of randomized query-tree families with the stated budget. -/
theorem simonOracleFamilySeparation (q : ℕ → ℕ)
    (budget : ∀ n, (q n : ℝ) ≤ (2 : ℝ) ^ ((n : ℝ) / 4))
    (P : (m n : ℕ) → PMF (SimonQueryTree n))
    (bounded : ∀ m n, SimonQueryTree.bounded (P m n) (q n)) :
    ∃ oracle : (n : ℕ) → Bool × (BooleanVec n → BooleanVec n),
      simonQuantumDecides oracle ∧ ∀ m, ¬ simonClassicalDecides oracle P m :=
  simon_infiniteOracle_separation q budget P bounded

/-- At Shor's power-of-two clock, a readout in the half-bin around a reduced
fraction uniquely determines that fraction for the bounded scan decoder. -/
theorem shorWindowRecovery (N t r c d : ℕ) (hN : 0 < N) (hr : 0 < r)
    (hrN : r ≤ N - 1) (coprime : Nat.Coprime d r) (hdr : d < r)
    (clock : N ^ 2 ≤ 2 ^ t)
    (window : 2 * |(r : ℤ) * c - (d : ℤ) * ((2 ^ t : ℕ) : ℤ)| ≤ (r : ℤ)) :
    (sourceRationalDecode (N - 1) (2 ^ t) c).1 = some (d, r) ∧
      (sourceRationalDecode (N - 1) (2 ^ t) c).2 ≤ (N - 1) * ((N - 1) + 1) / 2 :=
  source_clock_residue_window_actual_decoder_recovery N t r c d hN hr hrN coprime hdr clock window

/-- Two independent modular-order phase readouts recover the order with an
explicit constant probability using a least-common-multiple decoder. -/
theorem shorTwoSampleOrder (N M : ℕ) [NeZero N] (a : (ZMod N)ˣ) (hM : 0 < M)
    (hN : 1 < N) (hr : 1 < orderOf a) (clock : 2 * N ^ 2 < M) :
    (∑ yz ∈ Finset.univ.filter (fun yz : Fin M × Fin M =>
      (pairLCMOrderDecode N M a yz).1 = some (orderOf a)),
      (modularOrderLaw N M a hM).prob yz.1 * (modularOrderLaw N M a hM).prob yz.2) ≥
        (8 / Real.pi ^ 2) ^ 2 / 4 :=
  pair_lcm_order_actual_fresh_success_bound N M a hM hN hr clock

/-- Soundness and repeated-attempt success of Qatlib's residue-sampling
factoring program, including its classical preprocessing and order decoder. -/
theorem shorFactoringSuccess : ResidueFactoringAlgorithm := residueFactoringAlgorithm

end FQChem.Complexity.QueryAlgorithms
