# fqchem

fqchem is a Lean 4 library of machine-checked theorems for quantum chemistry. Trace the proofs in the [theorem dependency graph](https://fqchem.matterlab.ca/).

[State preparation](FQChem/StatePrep/) · [Dynamics](FQChem/Dynamics/) · [Properties](FQChem/Properties/) · [Multiscale methods](FQChem/Multiscale/) · [Complexity](FQChem/Complexity/)

## Selected proofs

| Paper | Lean result |
| --- | --- |
| [Ritz (1909)](https://doi.org/10.1515/crll.1909.135.1) | [Rayleigh–Ritz minimum](FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L59) |
| [Hohenberg & Kohn (1964)](https://doi.org/10.1103/PhysRev.136.B864) | [Conditional molecular potential uniqueness](FQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularHohenbergKohn.lean#L84) |
| [McMillan (1965)](https://doi.org/10.1103/PhysRev.138.A442) | [VMC energy bound](FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L77) |
| [Hirsch (1983)](https://doi.org/10.1103/PhysRevB.28.4059) | [Discrete Hubbard–Stratonovich identity](FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L68) |
| [Vidal (2003)](https://doi.org/10.1103/PhysRevLett.91.147902) | [MPS cut factorization](FQChem/StatePrep/VariationalOptimization/TensorNetworks/MatrixProductStates.lean#L41) |
| [Peruzzo et al. (2014)](https://doi.org/10.1038/ncomms5213) | [VQE minimum for reachable ground states](FQChem/StatePrep/VariationalOptimization/VQE.lean#L38) |
| [Low & Chuang (2019)](https://doi.org/10.22331/q-2019-07-12-163) | [Hamiltonian simulation by qubitization](integrations/qatlib/FQChemQatlib/Dynamics/LowChuangAllDimensions.lean#L141) |
| [Lüders (1951)](https://doi.org/10.1002/andp.19504430510) | [Projective measurement repeatability](FQChem/Properties/MeasurementTheory.lean#L78) |
| [Svensson et al. (1996)](https://doi.org/10.1021/jp962071j) | [ONIOM forces](FQChem/Multiscale/ChoosingLayers/ClassicalEnvironments.lean#L26) |
| [Beals et al. (2001)](https://arxiv.org/abs/quant-ph/9802049) | [Quantum query polynomial degree bound](FQChem/Complexity/AaronsonAmbainisQuery.lean#L180) |

[Full paper and proof index](https://github.com/the-matter-lab/fqchem/blob/atlas/docs/theorems/papers.md) · [Outstanding proofs](https://fqchem.matterlab.ca/#needs-proof)

## Use the library

Use the [release toolchain](https://github.com/the-matter-lab/fqchem/blob/v0.1.0/lean-toolchain), add this to `lakefile.toml`, and write `import FQChem` in your Lean file.

```toml
[[require]]
name = "fqchem"
git = "https://github.com/the-matter-lab/fqchem.git"
rev = "v0.1.0"
```

To build and audit a checkout, run these commands from the repository root. The [Qatlib integration](integrations/qatlib/) builds separately.

```sh
lake exe cache get
lake build
lake env lean test/Audit.lean
```

The continuum DFT proofs build on [Miguel Marques’s lean_dft](https://github.com/hyllios/lean_dft/tree/b9065256a6ddb1a7a4e1df3fbbf49a9a3fd546a4). The influence bounds build on [Turturean’s Aaronson–Ambainis formalization](https://github.com/physical-superintelligence/aaronson-ambainis/tree/2a6ceaef872ae993708950f951989134084b851a).
