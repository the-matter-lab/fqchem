# Theorems by physical task

The chapters follow the [Cuántica outline](https://cuanti.ca/#/single). Each principle groups the methods that use it. In each source folder, `Theorems.lean` states the result and `Proofs.lean` proves it. The cited papers introduce the result or the method to which it applies.

## Preparing states

### [Variational optimization](FormalQChem/StatePrep/VariationalOptimization)

- [Rayleigh–Ritz gives the ground eigenvalue and a variational bound for every nonzero trial state](FormalQChem/StatePrep/VariationalOptimization/RayleighRitz/Proofs.lean#L34). [Ritz (1909)](https://doi.org/10.1515/crll.1909.135.1)
- [Given a gap Δ, a normalized trial state with energy error ε has ground-space population at least 1 − ε/Δ](FormalQChem/StatePrep/VariationalOptimization/Proofs.lean#L23). [Hangleiter et al. (2017)](https://doi.org/10.1088/2058-9565/2/1/015004)
- **Mean field**. [Slater determinant upper bound in the fermionic sector](FormalQChem/StatePrep/VariationalOptimization/FermionicAnsatz/Theorems.lean#L33) · [proof](FormalQChem/StatePrep/VariationalOptimization/FermionicAnsatz/Proofs.lean#L14). [Fock (1930)](https://doi.org/10.1007/BF01340294)
- **Quantum Monte Carlo**. [Variational trial-state local-energy estimator](FormalQChem/StatePrep/VariationalOptimization/MonteCarlo/Proofs.lean#L9). [McMillan (1965)](https://doi.org/10.1103/PhysRev.138.A442)
- **Tensor networks**. [MPS cut-rank bound](FormalQChem/StatePrep/VariationalOptimization/MatrixProductStates/Proofs.lean#L9) and [exact bond-D cut factorization](FormalQChem/StatePrep/VariationalOptimization/MatrixProductStates/Proofs.lean#L20) · [One-site DMRG update](FormalQChem/StatePrep/VariationalOptimization/DMRG/Proofs.lean#L33). [Vidal (2003)](https://doi.org/10.1103/PhysRevLett.91.147902), [White (1992)](https://doi.org/10.1103/PhysRevLett.69.2863)
- **Density functionals**. [Conditional continuum Hohenberg–Kohn uniqueness](FormalQChem/StatePrep/VariationalOptimization/DensityFunctionals/DFT/Proofs.lean#L168) and [Lieb variational principle](FormalQChem/StatePrep/VariationalOptimization/DensityFunctionals/DFT/Proofs.lean#L187), [3D one-body rigidity](FormalQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularHK/Proofs.lean#L12), and [conditional molecular HK](FormalQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularHK/Proofs.lean#L30) · [3D Coulomb constrained search on smooth trial states](FormalQChem/StatePrep/VariationalOptimization/DensityFunctionals/CoulombIntegrability/Proofs.lean#L64). [Hohenberg & Kohn (1964)](https://doi.org/10.1103/PhysRev.136.B864), [Lieb (1983)](https://doi.org/10.1002/qua.560240302), [Levy (1979)](https://doi.org/10.1073/pnas.76.12.6062)
- **Neural wavefunctions**. [Equivariant orbitals give an antisymmetric determinant network](FormalQChem/StatePrep/VariationalOptimization/FermionicAnsatz/Theorems.lean#L40) · [proof](FormalQChem/StatePrep/VariationalOptimization/FermionicAnsatz/Proofs.lean#L21). [Pfau et al. (2020)](https://doi.org/10.1103/PhysRevResearch.2.033429)
- **Classical excited states**. [Energy bound after orthogonality to all lower eigenstates](FormalQChem/StatePrep/VariationalOptimization/ExcitedStates/Theorems.lean#L13) · [proof](FormalQChem/StatePrep/VariationalOptimization/ExcitedStates/Proofs.lean#L16). [MacDonald (1933)](https://doi.org/10.1103/PhysRev.43.830)
- **Variational eigensolvers**. [Unitary VQE energy bound and exact reachable minimum](FormalQChem/StatePrep/VariationalOptimization/VQE/Theorems.lean#L23) · [proof](FormalQChem/StatePrep/VariationalOptimization/VQE/Proofs.lean#L24) · [Pauli energy reconstruction and finite-shot variance](FormalQChem/Properties/ResponseAndEstimation/VQEMeasurement/Theorems.lean#L29) · [measurement proofs](FormalQChem/Properties/ResponseAndEstimation/VQEMeasurement/Proofs.lean#L17). [Peruzzo et al. (2014)](https://doi.org/10.1038/ncomms5213)
- **Quantum excited states**. [Exact lower-state penalties recover the target energy](FormalQChem/StatePrep/VariationalOptimization/ExcitedStates/Theorems.lean#L20) · [proof](FormalQChem/StatePrep/VariationalOptimization/ExcitedStates/Proofs.lean#L24). [Higgott, Wang & Brierley (2019)](https://doi.org/10.22331/q-2019-07-01-156)

### [Imaginary-time projection and filtering](FormalQChem/StatePrep/ImaginaryTimeProjection)

- [With nonzero initial ground overlap and a spectral gap Δ, imaginary-time evolution suppresses the excited population at rate exp(−2Δτ)](FormalQChem/StatePrep/ImaginaryTimeProjection/Proofs.lean#L47). [The normalized energy converges to the ground energy](FormalQChem/StatePrep/ImaginaryTimeProjection/Proofs.lean#L91). [Anderson (1975)](https://doi.org/10.1063/1.431514), [Motta et al. (2020)](https://doi.org/10.1038/s41567-019-0704-4)
- [Repeated spectral filters suppress the excited-to-ground odds geometrically when squared gains contract relative to the ground-sector gain](FormalQChem/StatePrep/ImaginaryTimeProjection/Proofs.lean#L103). [Lin & Tong (2020)](https://doi.org/10.22331/q-2020-11-11-361)

### [Amplitude equations and perturbation theory](FormalQChem/StatePrep/PerturbationTheory)

- [In a finite orthonormal eigenbasis, the nondegenerate Rayleigh–Schrödinger coefficient equations determine the first-order state response and the first two energy corrections](FormalQChem/StatePrep/PerturbationTheory/Proofs.lean#L28). [Schrödinger (1926)](https://doi.org/10.1002/andp.19263851302)
- [The truncated eigenpair has an exact Schrödinger residual divisible by the cube of the perturbation parameter](FormalQChem/StatePrep/PerturbationTheory/Proofs.lean#L98). [Schrödinger (1926)](https://doi.org/10.1002/andp.19263851302)
- **Coupled cluster**. [Full exponential similarity and the reference eigen-equation](FormalQChem/StatePrep/PerturbationTheory/ElectronicStructure/Theorems.lean#L13) · [proof](FormalQChem/StatePrep/PerturbationTheory/ElectronicStructure/Proofs.lean#L10). [Čížek (1966)](https://doi.org/10.1063/1.1727484)
- **Multireference perturbation**. [Nonpositive second-order shift for positive external gaps](FormalQChem/StatePrep/PerturbationTheory/ElectronicStructure/Theorems.lean#L19) · [proof](FormalQChem/StatePrep/PerturbationTheory/ElectronicStructure/Proofs.lean#L27). [Andersson, Malmqvist & Roos (1992)](https://doi.org/10.1063/1.462209)

### [Subspace diagonalization](FormalQChem/StatePrep/SubspaceDiagonalization)

- [The projected eigenproblem is equivalent to orthogonality of the full residual to the trial space](FormalQChem/StatePrep/SubspaceDiagonalization/Proofs.lean#L13). [Ritz (1909)](https://doi.org/10.1515/crll.1909.135.1)
- [Poincaré separation bounds each ordered Ritz eigenvalue above and below by eigenvalues of the full Hermitian Hamiltonian](FormalQChem/StatePrep/SubspaceDiagonalization/Interlacing/Proofs.lean#L70). [MacDonald (1933)](https://doi.org/10.1103/PhysRev.43.830)
- **Configuration interaction**. [Nested determinant spaces lower the CI Ritz energy](FormalQChem/StatePrep/SubspaceDiagonalization/ConfigurationInteraction/Theorems.lean#L14) · [proof](FormalQChem/StatePrep/SubspaceDiagonalization/ConfigurationInteraction/Proofs.lean#L14). [Boys (1950)](https://doi.org/10.1098/rspa.1950.0036)
- **Krylov subspace diagonalization**. [Hamiltonian powers give monotone Ritz energies](FormalQChem/StatePrep/SubspaceDiagonalization/Krylov/Theorems.lean#L18) · [proof](FormalQChem/StatePrep/SubspaceDiagonalization/Krylov/Proofs.lean#L20). [Lanczos (1950)](https://doi.org/10.6028/jres.045.026)
- **Quantum Krylov subspaces**. [Monotone Ritz energies in unitary time-step spaces](FormalQChem/StatePrep/SubspaceDiagonalization/Krylov/Theorems.lean#L22) · [proof](FormalQChem/StatePrep/SubspaceDiagonalization/Krylov/Proofs.lean#L23). [Stair, Huang & Evangelista (2020)](https://doi.org/10.1021/acs.jctc.9b01125)
- **Sampled configuration diagonalization**. [Exactness when the sampled span contains a ground state](FormalQChem/StatePrep/SubspaceDiagonalization/ConfigurationInteraction/Theorems.lean#L21) · [proof](FormalQChem/StatePrep/SubspaceDiagonalization/ConfigurationInteraction/Proofs.lean#L20). [Robledo-Moreno et al. (2025)](https://doi.org/10.1126/sciadv.adu9991)

### [Adiabatic preparation and analog simulation](FormalQChem/StatePrep/AdiabaticPreparation)

- [Kato transport intertwines the moving spectral projectors](FormalQChem/StatePrep/AdiabaticPreparation/Proofs.lean#L90). [A bounded differentiable reduced resolvent correction gives an inverse-runtime leakage bound for an isolated level](FormalQChem/StatePrep/AdiabaticPreparation/Proofs.lean#L168). [For a smooth moving two-band model with fixed nonzero splitting, leakage tends to zero as runtime grows](FormalQChem/StatePrep/AdiabaticPreparation/Proofs.lean#L215). [Kato (1950)](https://doi.org/10.1143/JPSJ.5.435), [Avron & Elgart (1999)](https://doi.org/10.1007/s002200050620)
- **Analog quantum simulators**. [Ideal blockade ground configurations and maximum independent sets](FormalQChem/StatePrep/AdiabaticPreparation/RydbergBlockade/Proofs.lean#L9). [Pichler et al. (2018)](https://arxiv.org/abs/1808.10816)

## Simulating dynamics

### [Real-time propagation](FormalQChem/Dynamics/RealTimePropagation)

- [The exponential of a bounded self-adjoint Hamiltonian generates unitary Schrödinger evolution with the real-time group law](FormalQChem/Dynamics/RealTimePropagation/Proofs.lean#L14). [Stone (1932)](https://doi.org/10.2307/1968538)
- **Wavepacket dynamics**. [Symmetric split steps preserve inner products](FormalQChem/Dynamics/RealTimePropagation/Propagators/Theorems.lean#L19) · [proof](FormalQChem/Dynamics/RealTimePropagation/Propagators/Proofs.lean#L17). [Feit, Fleck & Steiger (1982)](https://doi.org/10.1016/0021-9991%2882%2990091-2)
- **Electron–nuclear dynamics**. [Stationarity of mechanical energy on a one-coordinate adiabatic trajectory](FormalQChem/Dynamics/RealTimePropagation/MolecularDynamics/Theorems.lean#L19) · [proof](FormalQChem/Dynamics/RealTimePropagation/MolecularDynamics/Proofs.lean#L17). [Born & Oppenheimer (1927)](https://doi.org/10.1002/andp.19273892002)
- **State-vector propagation & typicality**. [Krylov projection reproduces all represented Hamiltonian moments on the seed](FormalQChem/Dynamics/RealTimePropagation/Propagators/Theorems.lean#L32) · [proof](FormalQChem/Dynamics/RealTimePropagation/Propagators/Proofs.lean#L32). [Park & Light (1986)](https://doi.org/10.1063/1.451548)
- **Operator propagation**. [Exact two-term rotation of an anticommuting Pauli string](FormalQChem/Dynamics/RealTimePropagation/Propagators/Theorems.lean#L44) · [proof](FormalQChem/Dynamics/RealTimePropagation/Propagators/Proofs.lean#L52). [Begušić & Chan (2025)](https://doi.org/10.1103/PRXQuantum.6.020302)
- **Phase-space approximations**. [Internal ring-polymer springs exert zero net centroid force](FormalQChem/Dynamics/RealTimePropagation/MolecularDynamics/Theorems.lean#L26) · [proof](FormalQChem/Dynamics/RealTimePropagation/MolecularDynamics/Proofs.lean#L28). [Craig & Manolopoulos (2004)](https://doi.org/10.1063/1.1777575)
- **Correlated real-time electronic structure**. [Norm conservation to first order in fixed-basis real-Hamiltonian TD-CI](FormalQChem/Dynamics/RealTimePropagation/MolecularDynamics/Theorems.lean#L33) · [proof](FormalQChem/Dynamics/RealTimePropagation/MolecularDynamics/Proofs.lean#L35). [Krause, Klamroth & Saalfrank (2005)](https://doi.org/10.1063/1.1999636)
- **Time-dependent variational Monte Carlo**. [Positive semidefinite empirical tangent covariance for real log derivatives](FormalQChem/Dynamics/RealTimePropagation/VariationalEvolution/Theorems.lean#L20) · [proof](FormalQChem/Dynamics/RealTimePropagation/VariationalEvolution/Proofs.lean#L17). [Carleo et al. (2012)](https://doi.org/10.1038/srep00243)
- **Real-time quantum Monte Carlo**. [Complex trajectory reweighting and mean-phase bound](FormalQChem/Dynamics/RealTimePropagation/PathSampling/Proofs.lean#L9). [Werner, Oka & Millis (2009)](https://doi.org/10.1103/PhysRevB.79.035320)
- **Short-time, cluster & hydrodynamic expansions**. [Finite linked-cluster subtraction as Möbius inversion](FormalQChem/Dynamics/RealTimePropagation/ClusterExpansions/Proofs.lean#L9). [Rigol, Bryant & Singh (2006)](https://doi.org/10.1103/PhysRevLett.97.187202)
- **Variational time evolution**. [An orthogonally projected tangent velocity minimizes the instantaneous residual](FormalQChem/Dynamics/RealTimePropagation/VariationalEvolution/Theorems.lean#L29) · [proof](FormalQChem/Dynamics/RealTimePropagation/VariationalEvolution/Proofs.lean#L35). [McLachlan (1964)](https://doi.org/10.1080/00268976400100041)

### [Fault-tolerant digital algorithms](FormalQChem/Dynamics/DigitalAlgorithms)

- **Digital Hamiltonian simulation**. [Noncommuting Lie–Trotter convergence for bounded generators](FormalQChem/Dynamics/DigitalAlgorithms/LieTrotter/Theorems.lean#L24) · [proof](FormalQChem/Dynamics/DigitalAlgorithms/LieTrotter/Proofs.lean#L54) · [Exact multislice product formula for commuting terms](FormalQChem/Dynamics/DigitalAlgorithms/CommutingTerms/Proofs.lean#L9). [Trotter (1959)](https://doi.org/10.1090/S0002-9939-1959-0108732-6), [Lloyd (1996)](https://doi.org/10.1126/science.273.5278.1073)

### [Reduced-state and open-system evolution](FormalQChem/Dynamics/OpenSystems)

- [A Kraus channel preserves positive semidefiniteness in the presence of an arbitrary finite ancilla and preserves the joint trace under Kraus completeness](FormalQChem/Dynamics/OpenSystems/Kraus/Proofs.lean#L44). [Choi (1975)](https://doi.org/10.1016/0024-3795(75)90075-0)
- **Open quantum systems**. [Each Lindblad dissipator has zero trace](FormalQChem/Dynamics/OpenSystems/Theorems.lean#L19) · [proof](FormalQChem/Dynamics/OpenSystems/Proofs.lean#L18). [Lindblad (1976)](https://doi.org/10.1007/BF01608499)
- **Open dynamics on quantum devices**. [Kraus completeness implies trace preservation of the channel](FormalQChem/Dynamics/OpenSystems/Theorems.lean#L23) · [proof](FormalQChem/Dynamics/OpenSystems/Proofs.lean#L25). [Kraus (1971)](https://doi.org/10.1016/0003-4916%2871%2990108-4)

### [Learned surrogates of electronic structure](FormalQChem/Dynamics/LearnedSurrogates)

- **Learned potentials**. [Directional forces transform covariantly under energy-preserving isometries](FormalQChem/Dynamics/LearnedSurrogates/Theorems.lean#L20) · [proof](FormalQChem/Dynamics/LearnedSurrogates/Proofs.lean#L17). [Chmiela et al. (2017)](https://doi.org/10.1126/sciadv.1603015)

## Measuring properties

### [Projective, generalized, and weak measurements](FormalQChem/Properties/MeasurementTheory)

- [A complete Kraus measurement gives normalized Born probabilities](FormalQChem/Properties/MeasurementTheory/Proofs.lean#L13). [Repeating a projective measurement reproduces the outcome](FormalQChem/Properties/MeasurementTheory/Proofs.lean#L22). [An unsharp qubit measurement yields explicit outcome probabilities and posterior polarization](FormalQChem/Properties/MeasurementTheory/Proofs.lean#L40). [Born (1926)](https://doi.org/10.1007/BF01397477), [Lüders (1951)](https://doi.org/10.1002/andp.19504430510), [Oreshkov & Brun (2005)](https://doi.org/10.1103/PhysRevLett.95.110409)

### [Derivatives, response, and stochastic estimators](FormalQChem/Properties/ResponseAndEstimation)

- [Independent finite-shot VQE measurements give an unbiased energy estimator with a coefficient-dependent variance bound](FormalQChem/Properties/ResponseAndEstimation/VQEMeasurement/Proofs.lean#L68). [Peruzzo et al. (2014)](https://doi.org/10.1038/ncomms5213)
- **Classical property evaluation**. [Hellmann–Feynman derivative of a bounded-Hamiltonian eigenvalue](FormalQChem/Properties/ResponseAndEstimation/HellmannFeynman/Theorems.lean#L22) · [proof](FormalQChem/Properties/ResponseAndEstimation/HellmannFeynman/Proofs.lean#L17). [Feynman (1939)](https://doi.org/10.1103/PhysRev.56.340)
- **Imaginary-time spectral reconstruction**. [Exact discrete Laplace identification at known energies](FormalQChem/Properties/ResponseAndEstimation/SpectralReconstruction/Proofs.lean#L9). [Silver, Sivia & Gubernatis (1990)](https://doi.org/10.1103/PhysRevB.41.2380)

### [Quantum phase estimation](FormalQChem/Properties/PhaseEstimation)

- **Eigenphase estimation**. [Exact-grid phase readout](FormalQChem/Properties/PhaseEstimation/Proofs.lean#L9). [Abrams & Lloyd (1999)](https://doi.org/10.1103/PhysRevLett.83.5162)

### [Quantum linear-system algorithms](FormalQChem/Properties/LinearSystems)

- **Quantum linear-system algorithms**. [Exact HHL reciprocal eigenvalue weighting](FormalQChem/Properties/LinearSystems/Proofs.lean#L9). [Harrow, Hassidim & Lloyd (2009)](https://doi.org/10.1103/PhysRevLett.103.150502)
- **Quantum differential-equation algorithms**. [Dirichlet Poisson stencil and its nonzero sine eigenmodes](FormalQChem/Properties/LinearSystems/Proofs.lean#L16). [Cao et al. (2013)](https://doi.org/10.1088/1367-2630/15/1/013021)

## Multiscale methods · Choosing the layers

### [Partitions, boundaries, and double counting](FormalQChem/Multiscale/ChoosingLayers/Partitions)

- [Overlapping layers reconstruct a finite interaction energy by subtracting double-counted terms and restoring terms that cross the boundary](FormalQChem/Multiscale/ChoosingLayers/Partitions/Proofs.lean#L9). [Richard & Herbert (2012)](https://doi.org/10.1063/1.4742816)

### [Classical environments](FormalQChem/Multiscale/ChoosingLayers/ClassicalEnvironments)

- **QM/MM & layered models**. [Forces on an ONIOM energy surface](FormalQChem/Multiscale/ChoosingLayers/ClassicalEnvironments/Theorems.lean#L19) · [proof](FormalQChem/Multiscale/ChoosingLayers/ClassicalEnvironments/Proofs.lean#L13). [Svensson et al. (1996)](https://doi.org/10.1021/jp962071j)

### [Quantum environments](FormalQChem/Multiscale/ChoosingLayers/QuantumEnvironments)

- **Electronic embedding**. [Frozen-density upper bound and exactness for a compatible minimizing split](FormalQChem/Multiscale/ChoosingLayers/QuantumEnvironments/Theorems.lean#L27) · [proof](FormalQChem/Multiscale/ChoosingLayers/QuantumEnvironments/Proofs.lean#L17). [Wesołowski & Warshel (1993)](https://doi.org/10.1021/j100132a040)

### [Fragments and many-body expansions](FormalQChem/Multiscale/ChoosingLayers/Fragments)

- **Molecular fragmentation**. [Two-body reconstruction for pair-additive fragment energies](FormalQChem/Multiscale/ChoosingLayers/Fragments/Theorems.lean#L19) · [proof](FormalQChem/Multiscale/ChoosingLayers/Fragments/Proofs.lean#L13). [Kitaura et al. (1999)](https://doi.org/10.1016/S0009-2614(99)00874-X)

### [Learned environments](FormalQChem/Multiscale/ChoosingLayers/LearnedEnvironments)

- **Learned potentials & interfaces**. [Energy-gap error from two endpoint Δ-learning errors](FormalQChem/Multiscale/ChoosingLayers/LearnedEnvironments/Theorems.lean#L16) · [proof](FormalQChem/Multiscale/ChoosingLayers/LearnedEnvironments/Proofs.lean#L13). [Ramakrishnan et al. (2015)](https://doi.org/10.1021/acs.jctc.5b00099)

## Multiscale methods · Stitching solutions

### [Solvers inside the embedded problem](FormalQChem/Multiscale/StitchingSolutions/EmbeddedSolvers)

- [Feshbach reduction gives an equivalent active-space eigenproblem and reconstructs the environment amplitudes wherever the environment resolvent exists](FormalQChem/Multiscale/StitchingSolutions/EmbeddedSolvers/Proofs.lean#L8). [Feshbach (1958)](https://doi.org/10.1016/0003-4916(58)90007-1)

### [Properties of the whole system](FormalQChem/Multiscale/StitchingSolutions/Observables)

- **Ensemble free energies**. [Zwanzig free-energy perturbation identity for finite ensembles](FormalQChem/Multiscale/StitchingSolutions/Observables/Theorems.lean#L21) · [proof](FormalQChem/Multiscale/StitchingSolutions/Observables/Proofs.lean#L13). [Zwanzig (1954)](https://doi.org/10.1063/1.1740409)

### [Error propagation and validation across scales](FormalQChem/Multiscale/StitchingSolutions/ErrorPropagation)

- **Multiscale error control**. [Multiplicative rate uncertainty from an activation-barrier error](FormalQChem/Multiscale/StitchingSolutions/ErrorPropagation/Theorems.lean#L16) · [proof](FormalQChem/Multiscale/StitchingSolutions/ErrorPropagation/Proofs.lean#L13). [Eyring (1935)](https://doi.org/10.1063/1.1749604)
