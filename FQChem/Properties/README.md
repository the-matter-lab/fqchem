# Measuring properties

Import this chapter with `import FQChem.Properties`.

## N-representability of reduced density matrices

- **One-particle density matrix.** In a finite spin-orbital basis, an ensemble of exactly N electrons realizes a matrix if and only if its natural occupations lie in [0,1] and sum to N. [Lean proof](NRepresentability/Coleman.lean#L128) · [Coleman (1963), §9](https://doi.org/10.1103/RevModPhys.35.668)
- **Two-particle density matrix.** The library proves convexity, nesting in particle number, Pauli exclusion, and the energy variational principle for trace-one pair densities. [Lean proofs](../Complexity/FermionicMarginals.lean) · [Liu, Christandl & Verstraete (2007)](https://doi.org/10.1103/PhysRevLett.98.110503)

## [Projective, generalized, and weak measurements](MeasurementTheory.lean)

- [A complete Kraus measurement gives normalized Born probabilities](MeasurementTheory.lean#L69). [Repeating a projective measurement reproduces the outcome](MeasurementTheory.lean#L78). [An unsharp qubit measurement yields explicit outcome probabilities and posterior polarization](MeasurementTheory.lean#L96). [Born (1926)](https://doi.org/10.1007/BF01397477), [Lüders (1951)](https://doi.org/10.1002/andp.19504430510), [Oreshkov & Brun (2005)](https://doi.org/10.1103/PhysRevLett.95.110409)

## [Derivatives, response, and stochastic estimators](ResponseAndEstimation)

- [Independent finite-shot VQE measurements give an unbiased energy estimator with a coefficient-dependent variance bound](ResponseAndEstimation/VQEMeasurement.lean#L118). [Peruzzo et al. (2014)](https://doi.org/10.1038/ncomms5213)
- **Classical property evaluation**. [Hellmann–Feynman derivative of a bounded-Hamiltonian eigenvalue](ResponseAndEstimation/HellmannFeynman.lean#L39). [Feynman (1939)](https://doi.org/10.1103/PhysRev.56.340)
- **Imaginary-time spectral reconstruction**. [Exact discrete Laplace identification at known energies](ResponseAndEstimation/SpectralReconstruction.lean#L21). [Silver, Sivia & Gubernatis (1990)](https://doi.org/10.1103/PhysRevB.41.2380)
- **Classical shadows**. Local Pauli measurements give an unbiased estimate with second moment 3ᵏ for a weight-k Pauli string. Independent blocks of the same measurement records yield simultaneous predictions at prescribed confidence. [Single-shot moments](ResponseAndEstimation/ClassicalShadows.lean) · [Prediction guarantee](ResponseAndEstimation/ShadowPrediction.lean) · [Huang, Kueng & Preskill (2020)](https://doi.org/10.1038/s41567-020-0932-7)
- **Learning with two copies**. The product of signs from local Bell measurements estimates the squared magnitude of a Pauli expectation. [Bell estimator](ResponseAndEstimation/BellSampling.lean) · [Huang et al. (2022)](https://doi.org/10.1126/science.abn7293)

## [Quantum phase estimation](PhaseEstimation.lean)

- **Eigenphase estimation**. [Exact-grid phase readout](PhaseEstimation.lean#L17). [Abrams & Lloyd (1999)](https://doi.org/10.1103/PhysRevLett.83.5162)

## [Quantum linear-system algorithms](LinearSystems)

- **Quantum linear-system algorithms**. [Exact HHL reciprocal eigenvalue weighting](LinearSystems/HHL.lean#L18). [Harrow, Hassidim & Lloyd (2009)](https://doi.org/10.1103/PhysRevLett.103.150502)
- **Quantum differential-equation algorithms**. [Dirichlet Poisson stencil and its nonzero sine eigenmodes](LinearSystems/DirichletPoisson.lean#L20). [Cao et al. (2013)](https://doi.org/10.1088/1367-2630/15/1/013021)
