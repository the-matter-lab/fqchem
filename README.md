# formal_qchem

Machine-checked quantum chemistry in Lean 4. Choose a physical task to browse its methods, proved results, and references. The chapters follow the [Cuántica outline](https://cuanti.ca/#/single).

| Chapter | What you’ll find |
| --- | --- |
| [State preparation](FormalQChem/StatePrep/) | Variational optimization, Monte Carlo projection, perturbation theory, subspace diagonalization, adiabatic and circuit preparation |
| [Dynamics](FormalQChem/Dynamics/) | Real-time propagation, product formulas, LCU, qubitization, open systems, and learned potentials |
| [Properties](FormalQChem/Properties/) | Measurements, response and estimators, phase estimation, and linear systems |
| [Multiscale methods](FormalQChem/Multiscale/) | Choosing layers and combining their solutions, from embedding and fragmentation to free energies and error bounds |

Each topic file contains its definitions, theorem statements, and proofs. For example, the variational principle is in [RayleighRitz.lean](FormalQChem/StatePrep/VariationalOptimization/RayleighRitz.lean). VQE uses it in the [same family](FormalQChem/StatePrep/VariationalOptimization/VQE.lean). Its finite-shot energy estimator is in [Properties](FormalQChem/Properties/ResponseAndEstimation/VQEMeasurement.lean).

## Using the library

Import a single method and check a result directly.

```lean
import FormalQChem.StatePrep.VariationalOptimization.RayleighRitz

#check FormalQChem.RayleighRitz.groundEnergyPrinciple
```

For wider coverage, import a family (`FormalQChem.StatePrep.VariationalOptimization`), a chapter (`FormalQChem.StatePrep`), or the whole library (`FormalQChem`). Earlier import paths are described in the [migration notes](compat/README.md).

## Building and checking the proofs

```sh
lake exe cache get
lake build
lake env lean test/Audit.lean
```

The audit checks that the library imports every scientific module and verifies the axiom dependencies of its theorems. The continuum DFT formalization adapts [Miguel Marques’s lean_dft](https://github.com/hyllios/lean_dft/tree/b9065256a6ddb1a7a4e1df3fbbf49a9a3fd546a4).
