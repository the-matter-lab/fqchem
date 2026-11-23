# Kitaev's circuit-to-Hamiltonian construction

This package checks a circuit-to-ground-energy reduction against Qatlib under Lean 4.35.0. From a quantum verification circuit it produces a bit string encoding a Hermitian five-local Hamiltonian with rational coefficients and rational energy thresholds. The gate alphabet is H, X, T, T† and CNOT. The encoding stores the real and imaginary parts of local entries as dyadic integers with a shared denominator. [Lean statements](FormalQChemKitaev.lean) · [Pinned Qatlib construction](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompleteness.lean)

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

## Complexity claims in the literature and in Lean

Kitaev, Shen and Vyalyi prove QMA-completeness of the five-local Hamiltonian problem under polynomial-time reductions. Kempe, Kitaev and Regev prove QMA-completeness for two-local qubit Hamiltonians. Here the checked map outputs five-local terms. Its witness-free specialization applies to amplified decision circuits of the kind used for BQP. A polynomial-time classical solution to a classically compiled BQP-hard problem would put BQP in P. A polynomial-time quantum solution to a QMA-hard problem would put QMA in BQP. The intractability conclusions require separations of the corresponding classes. [Kitaev, Shen & Vyalyi, §14.4](https://doi.org/10.1090/gsm/047) · [Kempe, Kitaev & Regev](https://arxiv.org/abs/quant-ph/0406180)

| Piece of the class-level argument | Status at the pinned revisions |
| --- | --- |
| Circuit-to-energy implication, locality, precision and bit-string output | Checked here. The starting object is a finite `QmaHistoryCircuit` with explicit completeness and soundness promises. Every output local table is tied to the matrix whose variational energy is bounded. [Upstream energy theorem](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessNormalized.lean) |
| Generation and classical bit time | Qatlib defines a finite-control TM0 generator on unary input. `uniformBqpGeneratorValid` ties its output tape to the **input circuit** and bounds its runtime, width and gate count. The separate `QmaVerifier.sizeBound` bounds gate count. A proof that a polynomial-time machine emits our full **output Hamiltonian**, including its dyadic arithmetic and wire indexing, remains open in this integration. [TM0 generator](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LocalMachine/LocalTransport/UniformBqpDefs.lean) · [Verifier definition](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/QmaCompleteness/HistoryHam/QmaCompletenessDefs.lean) |
| Amplification from the usual 2/3 versus 1/3 promise | Marriott and Watrous prove exponential error reduction with polynomial overhead. Qatlib proves a record-probability law and resource bounds for an alternating-measurement verifier. Applying that compiler to produce the finite unitary history circuit with the required acceptance thresholds is a separate formalization step. [Marriott & Watrous](https://arxiv.org/abs/cs/0506068) · [Qatlib amplification compiler](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Concepts/LocalMachine/LocalTransport/MwUniformVerifierCompiler.lean) |
| Standard polynomial-time QMA-completeness statement | Lean ATLAS has a two-local bit-string statement `local_hamiltonian_qma_complete` marked `theorem_wanted`. It explicitly requires `IsPolyTime` for the reduction. This integration proves the energy reduction and the bounds above. Class-level hardness and QMA membership remain outside those statements. [ATLAS statement and proof status](https://deicyde.github.io/atlas-lean/roadmap/TheoryOfComputation/randomized-and-quantum-complexity/local-hamiltonian-problem/index.html) |

## Build

From the repository root, run the following commands with Elan's `lake` on your path. The nested manifest pins Qatlib, Mathlib and Physlib. The root package and this integration use different Lean toolchains.

```sh
cd integrations/qatlib
lake exe cache get
lake build
```

The CI audit checks the transitive axiom dependencies of every declaration defined in the integration, including private declarations. It also checks that the audit imports every integration source module. Run both checks from this directory.

```sh
lake env lean test/Audit.lean
python3 ../../scripts/theorem_graph/generate.py --project kitaev --check
```

Qatlib Contributors supplied the unary-clock construction, the rounded dyadic Hamiltonian, its locality, its norm bounds and the accepting/rejecting history-state estimates. The dependency is pinned to commit `f76f71a7c5cd19a31c251d0feeab09c75a758d69`. Its Apache 2.0 source is imported by Lake. [Qatlib license](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/LICENSE) · [Completeness and soundness contract](https://github.com/quantum-atlas-ai/qatlib/blob/f76f71a7c5cd19a31c251d0feeab09c75a758d69/Qatlib/Papers/LocalHam06/MainResults/QmaCompletenessNormalized.lean)
