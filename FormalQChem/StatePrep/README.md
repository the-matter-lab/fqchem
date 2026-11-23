# Preparing states

Import this chapter with `import FormalQChem.StatePrep`.

## [Variational optimization](VariationalOptimization)

- [Rayleigh–Ritz gives the ground eigenvalue and a variational bound for every nonzero trial state](VariationalOptimization/RayleighRitz.lean#L59). [Ritz (1909)](https://doi.org/10.1515/crll.1909.135.1)
- [Given a gap Δ, a normalized trial state with energy error ε has ground-space population at least 1 − ε/Δ](VariationalOptimization/GapCertificate.lean#L48). [Hangleiter et al. (2017)](https://doi.org/10.1088/2058-9565/2/1/015004)
- **Mean field**. [Slater determinant upper bound in the fermionic sector](VariationalOptimization/FermionicAnsatz.lean#L47). [Fock (1930)](https://doi.org/10.1007/BF01340294)
- **Quantum Monte Carlo**. [Variational trial-state local-energy estimator](VariationalOptimization/VariationalMonteCarlo.lean#L19). [McMillan (1965)](https://doi.org/10.1103/PhysRev.138.A442)
- **Tensor networks**. [MPS cut-rank bound](VariationalOptimization/TensorNetworks/MatrixProductStates.lean#L30) and [exact bond-D cut factorization](VariationalOptimization/TensorNetworks/MatrixProductStates.lean#L41) · [One-site DMRG update](VariationalOptimization/TensorNetworks/DMRG.lean#L86). [Vidal (2003)](https://doi.org/10.1103/PhysRevLett.91.147902), [White (1992)](https://doi.org/10.1103/PhysRevLett.69.2863)
- **Density functionals**. [Conditional continuum Hohenberg–Kohn uniqueness](VariationalOptimization/DensityFunctionals/Continuum.lean#L254) and [Lieb variational principle](VariationalOptimization/DensityFunctionals/Continuum.lean#L273), [3D one-body rigidity](VariationalOptimization/DensityFunctionals/MolecularHohenbergKohn.lean#L66), and [conditional molecular HK](VariationalOptimization/DensityFunctionals/MolecularHohenbergKohn.lean#L84) · [3D Coulomb constrained search on smooth trial states](VariationalOptimization/DensityFunctionals/CoulombIntegrability.lean#L88). [Hohenberg & Kohn (1964)](https://doi.org/10.1103/PhysRev.136.B864), [Lieb (1983)](https://doi.org/10.1002/qua.560240302), [Levy (1979)](https://doi.org/10.1073/pnas.76.12.6062)
- **Neural wavefunctions**. [Equivariant orbitals give an antisymmetric determinant network](VariationalOptimization/FermionicAnsatz.lean#L54). [Pfau et al. (2020)](https://doi.org/10.1103/PhysRevResearch.2.033429)
- **Classical excited states**. [Energy bound after orthogonality to all lower eigenstates](VariationalOptimization/ExcitedStates.lean#L31). [MacDonald (1933)](https://doi.org/10.1103/PhysRev.43.830)
- **Variational eigensolvers**. [Unitary VQE energy bound and exact reachable minimum](VariationalOptimization/VQE.lean#L38) · [Pauli energy reconstruction and finite-shot variance](../Properties/ResponseAndEstimation/VQEMeasurement.lean#L67). [Peruzzo et al. (2014)](https://doi.org/10.1038/ncomms5213)
- **Quantum excited states**. [Exact lower-state penalties recover the target energy](VariationalOptimization/ExcitedStates.lean#L39). [Higgott, Wang & Brierley (2019)](https://doi.org/10.22331/q-2019-07-01-156)

## [Imaginary-time projection and filtering](ImaginaryTimeProjection)

- [With nonzero initial ground overlap and a spectral gap Δ, imaginary-time evolution suppresses the excited population at rate exp(−2Δτ)](ImaginaryTimeProjection/GroundStateProjection.lean#L106). [The normalized energy converges to the ground energy](ImaginaryTimeProjection/GroundStateProjection.lean#L150). [Anderson (1975)](https://doi.org/10.1063/1.431514), [Motta et al. (2020)](https://doi.org/10.1038/s41567-019-0704-4)
- [Repeated spectral filters suppress the excited-to-ground odds geometrically when squared gains contract relative to the ground-sector gain](ImaginaryTimeProjection/SpectralFiltering.lean#L45). [Lin & Tong (2020)](https://doi.org/10.22331/q-2020-11-11-361)

## [Amplitude equations and perturbation theory](PerturbationTheory)

- [In a finite orthonormal eigenbasis, the nondegenerate Rayleigh–Schrödinger coefficient equations determine the first-order state response and the first two energy corrections](PerturbationTheory/RayleighSchrodinger.lean#L95). [Schrödinger (1926)](https://doi.org/10.1002/andp.19263851302)
- [The truncated eigenpair has an exact Schrödinger residual divisible by the cube of the perturbation parameter](PerturbationTheory/RayleighSchrodinger.lean#L165). [Schrödinger (1926)](https://doi.org/10.1002/andp.19263851302)
- **Coupled cluster**. [Full exponential similarity and the reference eigen-equation](PerturbationTheory/CoupledCluster.lean#L18). [Čížek (1966)](https://doi.org/10.1063/1.1727484)
- **Multireference perturbation**. [Nonpositive second-order shift for positive external gaps](PerturbationTheory/Multireference.lean#L17). [Andersson, Malmqvist & Roos (1992)](https://doi.org/10.1063/1.462209)

## [Subspace diagonalization](SubspaceDiagonalization)

- [The projected eigenproblem is equivalent to orthogonality of the full residual to the trial space](SubspaceDiagonalization/RitzGalerkin.lean#L32). [Ritz (1909)](https://doi.org/10.1515/crll.1909.135.1)
- [Poincaré separation bounds each ordered Ritz eigenvalue above and below by eigenvalues of the full Hermitian Hamiltonian](SubspaceDiagonalization/Interlacing.lean#L97). [MacDonald (1933)](https://doi.org/10.1103/PhysRev.43.830)
- **Configuration interaction**. [Nested determinant spaces lower the CI Ritz energy](SubspaceDiagonalization/ConfigurationInteraction.lean#L27). [Boys (1950)](https://doi.org/10.1098/rspa.1950.0036)
- **Krylov subspace diagonalization**. [Hamiltonian powers give monotone Ritz energies](SubspaceDiagonalization/Krylov.lean#L32). [Lanczos (1950)](https://doi.org/10.6028/jres.045.026)
- **Quantum Krylov subspaces**. [Monotone Ritz energies in unitary time-step spaces](SubspaceDiagonalization/Krylov.lean#L35). [Stair, Huang & Evangelista (2020)](https://doi.org/10.1021/acs.jctc.9b01125)
- **Sampled configuration diagonalization**. [Exactness when the sampled span contains a ground state](SubspaceDiagonalization/ConfigurationInteraction.lean#L33). [Robledo-Moreno et al. (2025)](https://doi.org/10.1126/sciadv.adu9991)

## [Adiabatic preparation and analog simulation](AdiabaticPreparation)

- [Kato transport intertwines the moving spectral projectors](AdiabaticPreparation/AdiabaticTheorem.lean#L186). [A bounded differentiable reduced resolvent correction gives an inverse-runtime leakage bound for an isolated level](AdiabaticPreparation/AdiabaticTheorem.lean#L264). [For a smooth moving two-band model with fixed nonzero splitting, leakage tends to zero as runtime grows](AdiabaticPreparation/AdiabaticTheorem.lean#L311). [Kato (1950)](https://doi.org/10.1143/JPSJ.5.435), [Avron & Elgart (1999)](https://doi.org/10.1007/s002200050620)
- **Analog quantum simulators**. [Ideal blockade ground configurations and maximum independent sets](AdiabaticPreparation/RydbergBlockade.lean#L28). [Pichler et al. (2018)](https://arxiv.org/abs/1808.10816)
