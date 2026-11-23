# formal_qchem

Lean 4 theorems for quantum chemistry. The [method catalog](METHODS.md) lists a checked result and primary literature for each of the 40 families in [Cuántica](https://cuanti.ca/#/all).

- **Density functional theory.** Ground-state density determines the potential up to a constant under explicit analytic hypotheses. The Lieb functional recovers the variational energy. For the 3D molecular Coulomb model, the constrained-search identity holds on normalized smooth, compactly supported, antisymmetric trial states. Molecular uniqueness assumes a common form domain, separation, and almost-everywhere nonvanishing of one ground state. [Hohenberg–Kohn (1964)](https://doi.org/10.1103/PhysRev.136.B864) · [Levy (1979)](https://doi.org/10.1073/pnas.76.12.6062) · [Lieb (1983)](https://doi.org/10.1002/qua.560240302)
- **Variational electronic structure.** Rayleigh–Ritz bounds, Slater determinant trial energies, and improvement under configuration-space enlargement. [Ritz (1909)](https://doi.org/10.1515/crll.1909.135.1) · [Fock (1930)](https://doi.org/10.1007/BF01340294)
- **MPS and DMRG.** An MPS bond bounds the coefficient-matrix rank across its cut. A matrix of rank at most the bond dimension admits an exact factorization across that cut. Optimizing one DMRG site can only lower or preserve the energy. [White (1992)](https://doi.org/10.1103/PhysRevLett.69.2863) · [Vidal (2003)](https://doi.org/10.1103/PhysRevLett.91.147902)
- **VQE.** A reachable ground eigenstate attains the exact circuit minimum. Independent Pauli measurements give an unbiased energy estimator with a finite-shot variance bound. [Peruzzo et al. (2014)](https://doi.org/10.1038/ncomms5213)
- **Forces and evolution.** Hellmann–Feynman along a differentiable eigenbranch and Lie–Trotter convergence for bounded noncommuting generators. [Feynman (1939)](https://doi.org/10.1103/PhysRev.56.340) · [Trotter (1959)](https://doi.org/10.1090/S0002-9939-1959-0108732-6)
- **Multiscale chemistry.** Frozen-density variational bounds, ONIOM forces, and the finite-ensemble free-energy perturbation identity. [Wesołowski & Warshel (1993)](https://doi.org/10.1021/j100132a040) · [Svensson et al. (1996)](https://doi.org/10.1021/jp962071j) · [Zwanzig (1954)](https://doi.org/10.1063/1.1740409)

Read the [statements](FormalQChem/Theorems/) and [proofs](FormalQChem/Proofs/), or use `import FormalQChem`. The abstract DFT proofs are adapted from [Miguel Marques’s lean_dft](https://github.com/hyllios/lean_dft/tree/b9065256a6ddb1a7a4e1df3fbbf49a9a3fd546a4).

Build and audit with [Elan](https://lean-lang.org/install/).

```sh
lake exe cache get
lake build
lake env lean Audit.lean
```
