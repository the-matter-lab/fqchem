# Qatlib integration

In this Lean 4.35 project, `import FQChemQatlib` loads the results below and the Kitaev reduction. Each graph node links to the original publication and each upstream proof to the pinned Qatlib revision.

| Result | Lean module |
| --- | --- |
| Arbitrary Hermitian observables under a finite, informationally complete unitary measurement ensemble. The shared-record median and variance-based sample bound are explicit. | [Classical shadows](FQChemQatlib/Properties/ClassicalShadows.lean) |
| Finite counter Born probabilities in amplitude estimation, including the nearest-window and general-window guarantees. | [Amplitude estimation](FQChemQatlib/Properties/AmplitudeEstimation.lean) |
| Exact odd and even projected-unitary singular-value transformations with constructive phase existence for admissible positive-degree polynomials. | [Singular-value transformation](FQChemQatlib/Dynamics/SingularValueTransformation.lean) |
| Hamiltonian simulation from block encodings on finite registers and from sparse position and entry oracles. | [Block-encoding circuit and resources](FQChemQatlib/Dynamics/LowChuangReadout.lean) · [Sparse query simulation](FQChemQatlib/Dynamics/LowChuangSparseOracle.lean) |
| Signed HHL inversion with finite off-grid phase precision and a bound on the normalized, uncomputed solution branch. | [Sine-clock solution](FQChemQatlib/Properties/SignedSineUncompute.lean) |
| Simon mask recovery, the finite classical query bound, and order-recovery and factoring success guarantees under the stated sampling and cost models. | [Query algorithms](FQChemQatlib/Complexity/QueryAlgorithms.lean) |

## Kitaev's circuit-to-Hamiltonian construction

This package checks a circuit-to-ground-energy reduction against Qatlib under Lean 4.35.0. From a quantum verification circuit it produces a bit string encoding a Hermitian five-local Hamiltonian with rational coefficients and rational energy thresholds. The gate alphabet is H, X, T, T† and CNOT. The encoding stores the real and imaginary parts of local entries as dyadic integers with a shared denominator. [History Hamiltonian](FQChemKitaev/HistoryHamiltonian.lean) · [Pinned Qatlib construction](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompleteness.lean)

## What Lean proves

Let a circuit have `T` gates and `n` work qubits, and put `s = T + n + 65`. Define the variational ground energy as the infimum of the real energy expectation over all normalized states. This includes states with illegal unary clocks.

| Lean theorem | Result |
| --- | --- |
| `verifier_reduction` | If some legal normalized witness is accepted with probability at least `1 − 1/(2¹⁴(T+65)²)`, the encoded ground energy is at most `1/D`. If all legal normalized witnesses are accepted with probability at most `1/4`, the ground energy is at least `2/D`. The bit string includes the positive integer `D`. |
| `resources`, `promiseGap` | Each term acts on at most five qubits and has operator norm at most one. The gap between the energy thresholds is at least `1/(2¹³ · 130 · s⁴)`. |
| `reduction_length`, `serialize_injective` | The complete bit string uniquely identifies its Hamiltonian and rational thresholds. It has at most `2 · 2¹³ · 130 · s⁴ + 3 + 2,000,000 · s³` bits. |
| `termDescriptors_correct`, `termDescriptors_count`, `scalarEntries_bound` | The term generator emits one descriptor per padded gate, one per initialized wire, an output descriptor, and one per ordered clock pair. Its local tables equal those of the semantic reduction. Each table requires at most 2,048 real and imaginary integer entries in total. |
| `estimate_decides` | A ground-energy estimate accurate to one third of the proved lower bound on the promise gap decides the verifier's YES/NO promise by comparison with the midpoint. |
| `preparation_and_measurement_decide` | Preparing a normalized state within one fifth of that lower bound in energy and measuring its energy within another fifth also decides the promise. |
| `witnessFree_groundEnergy` | With every work wire initialized, the YES and NO conclusions follow directly from the acceptance probability of the all-zero input. The proof establishes that every legal normalized input differs from that ket only by a global phase. |
| `Amplify.word_accept`, `Amplify.repeat_accept`, `Amplify.repeat_reject` | A legal all-zero-input circuit with `T` gates, `n` wires and acceptance probability `p` is compiled into three independent copies plus a 45-gate majority readout. The new circuit uses exactly `3T+45` gates and `3n+1` wires and accepts with probability `3p²−2p³`. Iterating the compiler gives a proved recurrence for both kinds of decision error. [Finite gate compiler](FQChemKitaev/Amplify.lean) |

For an ordinary bounded-error decision circuit, the coherent amplifier clones and rewires the gate list on three disjoint registers per round. The chosen logarithmic depth meets the energy precision of the final circuit while keeping its size cubic in the initial padded size. The reduction starts from acceptance at least 2/3 or at most 1/3. [Amplification](FQChemKitaev/Amplify.lean) · [Depth and resource proof](FQChemKitaev/AmplificationBounds.lean) · [Bounded-error reduction](FQChemKitaev/BoundedErrorReduction.lean)

`BoundedErrorReduction.transducer_correct` starts with a serialized decision circuit. It amplifies the gate word, emits a binary list of local term templates, and proves that those bits decode to the five-local Hamiltonian and the two rational cutoffs used in the energy proof. `transducer_time` bounds this entire computation by a polynomial in the input bit length, counting unary-register and immutable list-cell operations. `transducer_promise_gap` gives an inverse-polynomial separation in the original circuit size. [End-to-end theorems](FQChemKitaev/BoundedErrorReduction.lean) · [Costed amplifier](FQChemKitaev/AmplifierCost.lean) · [Term compiler and decoder](FQChemKitaev/Compiler.lean)

## Complexity claims in the literature and in Lean

Kitaev, Shen and Vyalyi prove QMA-completeness of the five-local Hamiltonian problem under polynomial-time reductions. Kempe, Kitaev and Regev prove QMA-completeness for two-local qubit Hamiltonians. Here the checked map outputs five-local terms. The finite-gate construction in this package takes the ordinary 2/3 versus 1/3 BQP decision promise to ground energy with an inverse-polynomial gap. A polynomial-time classical solution to a classically compiled BQP-hard problem would put BQP in P. A polynomial-time quantum solution to a QMA-hard problem would put QMA in BQP. The intractability conclusions require separations of the corresponding classes. [Kitaev, Shen & Vyalyi, §14.4](https://doi.org/10.1090/gsm/047) · [Kempe, Kitaev & Regev](https://arxiv.org/abs/quant-ph/0406180)

| Piece of the class-level argument | Status at the pinned revisions |
| --- | --- |
| Circuit-to-energy implication, locality, precision and bit-string output | Checked here. The starting object is a finite `QmaHistoryCircuit` with explicit completeness and soundness promises. Every output local table is tied to the matrix whose variational energy is bounded. [Upstream energy theorem](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessNormalized.lean) |
| Generation and classical bit time | Qatlib defines a finite-control TM0 generator on unary input. `uniformBqpGeneratorValid` ties its output tape to the **input circuit** and bounds its runtime, width and gate count. The separate `QmaVerifier.sizeBound` bounds gate count. The five-local template compiler has a polynomial bit-list cost bound, and the dyadic gate-table scalars have a quadratic bitwise algorithm at the requested precision. A TM0 simulation of the template compiler and an end-to-end clock for serializing expanded dense tables remain open. [Dyadic coefficient algorithm](FQChemKitaev/DyadicCoefficients.lean) [TM0 generator](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LocalMachine/LocalTransport/UniformBqpDefs.lean) · [Verifier definition](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean) |
| Amplification from the usual 2/3 versus 1/3 promise | Marriott and Watrous prove exponential error reduction with polynomial overhead. Qatlib proves a record-probability law and resource bounds for an alternating-measurement verifier. For witness-free inputs, `Amplify.word_accept` implements coherent majority with three independent register copies. For witness-bearing verifiers, a malicious prover may entangle the copies. The transfer from a general bounded-error QMA verifier to the amplified unitary history circuit remains a separate formalization step. [Marriott & Watrous](https://arxiv.org/abs/cs/0506068) · [Qatlib amplification compiler](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LocalMachine/LocalTransport/MwUniformVerifierCompiler.lean) |
| Uniformly generated basis-input circuits | A clocked Qatlib generator emits a legal finite gate word for each input length. The checked X-gate loader prepares any supplied basis input, and the generated circuit’s own acceptance probability implies the fixed-particle energy bounds at the standard bounded-error thresholds after amplification. The construction size obeys the generator’s polynomial word and width bounds. [UniformCircuits.lean](FQChemKitaev/UniformCircuits.lean) · [Bounded-error endpoint](FQChemKitaev/BoundedErrorReduction.lean) |
| Standard polynomial-time QMA-completeness statement | Lean ATLAS has a two-local bit-string statement `local_hamiltonian_qma_complete` marked `theorem_wanted`. It explicitly requires `IsPolyTime` for the reduction. This integration proves the energy reduction and the bounds above. Class-level hardness and QMA membership remain outside those statements. Its propositions and encoding definitions are public. The `theorem_wanted` command registers a private `ProofWanted` placeholder. The class theorem itself cannot be imported as a proof. [Pinned ATLAS source](https://github.com/DeicYde/atlas-lean/blob/bbef716f89863df0205ca6a4cbb8512e5c894d09/WantedExt/Complexity/KeyTheorems/LocalHamiltonianQMAWanted.lean#L182) · [Batteries elaborator](https://github.com/leanprover-community/batteries/blob/66e469188fe07963e5cf666c7d4433f45b8131c5/Batteries/Util/ProofWanted.lean#L639) |

## Build

From the repository root, run the following commands with Elan's `lake` on your path. The nested manifest pins Qatlib, Mathlib and Physlib. The root package and this integration use different Lean toolchains.

```sh
cd integrations/qatlib
lake exe cache get
lake build
```

The CI audit checks the transitive axiom dependencies of every declaration defined in the integration, including private declarations. It also checks that the audit imports every integration source module. Run the audit and graph extraction from this directory. Downstream Lean code can import just the reduction with `import FQChemKitaev`.

```sh
lake env lean test/Audit.lean
python3 ../../scripts/theorem_graph/generate.py --project kitaev
```

Qatlib Contributors supplied the unary-clock construction, the rounded dyadic Hamiltonian, its locality, its norm bounds and the accepting/rejecting history-state estimates. The dependency is pinned to commit `f76f71a7c5cd19a31c251d0feeab09c75a758d69`. Its Apache 2.0 source is imported by Lake. [Qatlib license](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/LICENSE) · [Completeness and soundness contract](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessNormalized.lean)
