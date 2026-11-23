# formal_qchem

Lean 4 statements and proofs for quantum chemistry, organized by physical task. The [theorem catalog](METHODS.md) groups methods under the principles in the [Cuántica outline](https://cuanti.ca/#/single) and links to the original papers.

## Preparing states

- [Variational optimization](FormalQChem/StatePrep/VariationalOptimization/) — Rayleigh–Ritz, energy and ground-state fidelity, density functionals, Hartree–Fock, MPS/DMRG, and VQE. [Ritz (1909)](https://doi.org/10.1515/crll.1909.135.1) · [Hohenberg & Kohn (1964)](https://doi.org/10.1103/PhysRev.136.B864)
- [Imaginary-time projection and filtering](FormalQChem/StatePrep/ImaginaryTimeProjection/) — ground-space fidelity and energy convergence for a finite gapped spectrum with nonzero initial ground overlap. [Anderson (1975)](https://doi.org/10.1063/1.431514)
- [Amplitude equations and perturbation theory](FormalQChem/StatePrep/PerturbationTheory/) — the coupled-cluster similarity transform and nondegenerate Rayleigh–Schrödinger coefficients through second order. [Schrödinger (1926)](https://doi.org/10.1002/andp.19263851302)
- [Subspace diagonalization](FormalQChem/StatePrep/SubspaceDiagonalization/) — Ritz eigenvalue interlacing, residual orthogonality, selected CI, and classical and quantum Krylov spaces. [Ritz (1909)](https://doi.org/10.1515/crll.1909.135.1) · [Lanczos (1950)](https://doi.org/10.6028/jres.045.026)
- [Adiabatic preparation and analog simulation](FormalQChem/StatePrep/AdiabaticPreparation/) — Kato transport, quantitative leakage bounds under explicit spectral and regularity hypotheses, and Rydberg blockade. [Kato (1950)](https://doi.org/10.1143/JPSJ.5.435)

## Dynamics, properties, and multiscale methods

- [Simulating dynamics](FormalQChem/Dynamics/) — unitary propagation, digital product formulas, open systems, and learned force models. [Stone (1932)](https://doi.org/10.2307/1968538) · [Trotter (1959)](https://doi.org/10.1090/S0002-9939-1959-0108732-6)
- [Measuring properties](FormalQChem/Properties/) — projective and weak measurements, derivatives and estimators, phase estimation, and quantum linear systems. [Lüders (1951)](https://doi.org/10.1002/andp.19504430510) · [Feynman (1939)](https://doi.org/10.1103/PhysRev.56.340)
- [Multiscale methods](FormalQChem/Multiscale/) — overlapping layers, embedding, fragmentation, learned environments, free energies, and error propagation. [Feshbach (1958)](https://doi.org/10.1016/0003-4916%2858%2990007-1) · [Zwanzig (1954)](https://doi.org/10.1063/1.1740409)

Import the library with `import FormalQChem`, or a chapter with, for example, `import FormalQChem.StatePrep`. Look for `Theorems.lean` and `Proofs.lean` together in each topic folder. The abstract DFT proofs are adapted from [Miguel Marques’s lean_dft](https://github.com/hyllios/lean_dft/tree/b9065256a6ddb1a7a4e1df3fbbf49a9a3fd546a4).

```sh
lake exe cache get
lake build
lake env lean Audit.lean
```
