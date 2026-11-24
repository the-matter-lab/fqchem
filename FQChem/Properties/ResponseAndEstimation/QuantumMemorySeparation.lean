module

public import FQChem.Properties.ResponseAndEstimation.AdaptivePauliPrediction
public import FQChem.Properties.ResponseAndEstimation.BellConfidence
import Mathlib.Tactic

/-! # Quantum memory advantage for predicting an observable after measurement

Huang et al., Theorem 1 and Supplementary Theorem 6. The upper and lower bounds
concern the same hidden-Pauli states, one-quarter additive error and four-fifths
success. The upper protocol measures pairs of copies before learning the word.
[Original paper](https://doi.org/10.1126/science.abn7293)
-/

@[expose] public section
noncomputable section

namespace FQChem.Properties.QuantumMemorySeparation

open MeasureTheory FQChem.Complexity.ElectronicStructure FQChem.Dynamics.OTOC
open FQChem.Properties.PauliPrediction FQChem.Properties.AdaptivePauliPrediction
open scoped Classical ComplexOrder

variable {n : ℕ}

/-- Theorem 1 (Supplementary Theorem 6). With 2048 pair measurements the Bell estimator
meets the promised accuracy for every state in the hard prior, including biases 0 and ±0.9.
A randomized adaptive single-copy procedure achieving the same average accuracy on the
published prior must measure at least 20(2ⁿ+1)/27 copies. -/
theorem separation {R α : Type*} [MeasurableSpace R] [Fintype α] (ν : Measure R) [IsProbabilityMeasure ν]
    {T : ℕ} (hn : 0 < n) (Q : R → Experiment α n T) (predict : R → (Fin T → α) → Word n → ℝ)
    (hf : Integrable (fun s => failure (Q s) (predict s)) ν) :
    (∀ (p : Word n) (hp : p ∈ nonidentity n) (a : ℝ) (ha : |a| ≤ 1),
      (BellConfidence.records (BellConfidence.hiddenState p hp a ha) 2048).real
        {v | 1/4 < |Real.sqrt (max 0 (BellConfidence.mean p v)) - abs a|} ≤ 1/5) ∧
    ((∫ s, failure (Q s) (predict s) ∂ν) ≤ 1/5 → (20/27:ℝ) * (dimension n + 1) ≤ T) := by
  constructor
  · intro p hp a ha
    simpa only [BellConfidence.hiddenMagnitude p p hp hp a ha, ite_true, eq_self] using
      BellConfidence.predictMagnitude (BellConfidence.hiddenState p hp a ha) p
  · exact randomizedCopyLowerBound ν hn Q predict hf

end FQChem.Properties.QuantumMemorySeparation
