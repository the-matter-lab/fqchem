# fqchem

fqchem is a Lean 4 library of machine-checked theorems for quantum chemistry. Its five chapters group proofs by the physical task and method. The [paper index](#papers-and-proved-results) links each reference to its Lean results.

| Chapter | What you’ll find |
| --- | --- |
| [State preparation](FQChem/StatePrep/) | Variational optimization, Monte Carlo projection, perturbation theory, subspace diagonalization, adiabatic and circuit preparation |
| [Dynamics](FQChem/Dynamics/) | Real-time propagation, product formulas, LCU, qubitization, open systems, and learned potentials |
| [Properties](FQChem/Properties/) | Measurements, response and estimators, phase estimation, and linear systems |
| [Multiscale methods](FQChem/Multiscale/) | Choosing layers and combining their solutions, from embedding and fragmentation to free energies and error bounds |
| [Complexity and limits](FQChem/Complexity/) | Query lower bounds for ground-state preparation and orbital simulation, Aaronson–Ambainis influence, the Kitaev reduction, and fixed-particle encoding |

Explore the [interactive theorem dependency graph](https://fqchem.matterlab.ca/) to trace a result through its prerequisites or find the theorems that use it. The atlas is rebuilt from both Lean projects after each successful push to `main`. The [graph guide](docs/theorems/README.md) explains the arrows and links to diagrams by module.

Each topic file contains its definitions, theorem statements, and proofs. For example, the variational principle is in [RayleighRitz.lean](FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean). VQE uses it in the [same family](FQChem/StatePrep/VariationalOptimization/VQE.lean). Its finite-shot energy estimator is in [Properties](FQChem/Properties/ResponseAndEstimation/VQEMeasurement.lean).

## Using the library

To use v0.1.0 from another Lean project, use the toolchain in [lean-toolchain](lean-toolchain) and add this dependency to your `lakefile.toml`.

```toml
[[require]]
name = "fqchem"
git = "https://github.com/the-matter-lab/fqchem.git"
rev = "v0.1.0"
```

Import the full library with `import FQChem`. To load a single method, import its topic module.

```lean
import FQChem.StatePrep.VariationalOptimization.RayleighRitz

#check FQChem.RayleighRitz.groundEnergyPrinciple
```

For wider coverage, import a family (`FQChem.StatePrep.VariationalOptimization`), a chapter (`FQChem.StatePrep`), or the whole library (`FQChem`).

## Building and checking the proofs

```sh
lake exe cache get
lake build
lake env lean test/Audit.lean
```

The [Kitaev integration](integrations/qatlib/) has its own pinned Lean 4.35 build. The main library uses Lean 4.36 and builds its [Aaronson–Ambainis dependency](integrations/aaronson-ambainis/) through Lake.

The audit checks that the library imports every scientific module and verifies the axiom dependencies of its theorems. The continuum DFT formalization adapts [Miguel Marques’s lean_dft](https://github.com/hyllios/lean_dft/tree/b9065256a6ddb1a7a4e1df3fbbf49a9a3fd546a4).

## Papers and proved results

The right column links to the exact Lean declarations. Some entries formalize a paper’s central theorem. Others prove a finite-dimensional case, an estimator identity, or a step of the published algorithm. The links give the hypotheses for each result.

### State preparation

| Paper | Result proved in Lean |
| --- | --- |
| Ritz (1909), [Über eine neue Methode zur Lösung gewisser Variationsprobleme der mathematischen Physik](https://doi.org/10.1515/crll.1909.135.1) | [Rayleigh–Ritz minimum for a finite-dimensional self-adjoint Hamiltonian](FQChem/StatePrep/VariationalOptimization/RayleighRitz.lean#L59) · [Galerkin residual orthogonality](FQChem/StatePrep/SubspaceDiagonalization/RitzGalerkin.lean#L32) |
| Hangleiter et al. (2017), [Direct certification of a class of quantum simulations](https://doi.org/10.1088/2058-9565/2/1/015004) | [Ground-space population from energy error and a spectral gap](FQChem/StatePrep/VariationalOptimization/GapCertificate.lean#L48) |
| Fock (1930), [Näherungsmethode zur Lösung des quantenmechanischen Mehrkörperproblems](https://doi.org/10.1007/BF01340294) | [Variational upper bound in the Slater determinant sector](FQChem/StatePrep/VariationalOptimization/FermionicAnsatz.lean#L47) |
| McMillan (1965), [Ground State of Liquid He⁴](https://doi.org/10.1103/PhysRev.138.A442) | [Born-weighted local energy equals the trial expectation](FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L66) · [Normalized VMC energy upper bound](FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L77) |
| Assaraf & Caffarel (2003), [Zero-Variance Zero-Bias Principle for Observables in Quantum Monte Carlo: Application to Forces](https://arxiv.org/abs/physics/0310035) | [Local-energy variance and the residual at wavefunction nodes](FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L95) |
| Metropolis et al. (1953), [Equation of State Calculations by Fast Computing Machines](https://doi.org/10.1063/1.1699114) | [Metropolis stationarity for the Born distribution under symmetric proposals](FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L186) |
| Sorella (2005), [Wave function optimization in the variational Monte Carlo method](https://arxiv.org/abs/cond-mat/0502553) | [VMC energy gradient for a differentiable real trial family with full support](FQChem/StatePrep/VariationalOptimization/VariationalMonteCarlo.lean#L209) |
| Vidal (2003), [Efficient Classical Simulation of Slightly Entangled Quantum Computations](https://doi.org/10.1103/PhysRevLett.91.147902) | [MPS bond dimension bounds the cut rank](FQChem/StatePrep/VariationalOptimization/TensorNetworks/MatrixProductStates.lean#L30) · [Exact cut factorization at sufficient bond dimension](FQChem/StatePrep/VariationalOptimization/TensorNetworks/MatrixProductStates.lean#L41) |
| White (1992), [Density matrix formulation for quantum renormalization groups](https://doi.org/10.1103/PhysRevLett.69.2863) | [One-site variational DMRG update](FQChem/StatePrep/VariationalOptimization/TensorNetworks/DMRG.lean#L86) |
| Hohenberg & Kohn (1964), [Inhomogeneous Electron Gas](https://doi.org/10.1103/PhysRev.136.B864) | [Continuum potential uniqueness under separation, rigidity and nonvanishing hypotheses](FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L254) · [3D one-body rigidity](FQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularHohenbergKohn.lean#L66) · [Conditional molecular Hohenberg–Kohn uniqueness](FQChem/StatePrep/VariationalOptimization/DensityFunctionals/MolecularHohenbergKohn.lean#L84) |
| Lieb (1983), [Density functionals for coulomb systems](https://doi.org/10.1002/qua.560240302) | [Variational energy identity for the Lieb functional](FQChem/StatePrep/VariationalOptimization/DensityFunctionals/Continuum.lean#L273) |
| Levy (1979), [Universal variational functionals of electron densities, first-order density matrices, and natural spin-orbitals and solution of the v-representability problem](https://doi.org/10.1073/pnas.76.12.6062) | [3D Coulomb constrained search over smooth trial states](FQChem/StatePrep/VariationalOptimization/DensityFunctionals/CoulombIntegrability.lean#L88) |
| Pfau et al. (2020), [Ab initio solution of the many-electron Schrödinger equation with deep neural networks](https://doi.org/10.1103/PhysRevResearch.2.033429) | [Antisymmetry of a determinant built from equivariant orbitals](FQChem/StatePrep/VariationalOptimization/FermionicAnsatz.lean#L54) |
| MacDonald (1933), [Successive Approximations by the Rayleigh-Ritz Variation Method](https://doi.org/10.1103/PhysRev.43.830) | [Excited-energy bound under orthogonality to the lower eigenspaces](FQChem/StatePrep/VariationalOptimization/ExcitedStates.lean#L31) · [Ordered Ritz interlacing for a Hermitian compression](FQChem/StatePrep/SubspaceDiagonalization/Interlacing.lean#L97) |
| Peruzzo et al. (2014), [A variational eigenvalue solver on a photonic quantum processor](https://doi.org/10.1038/ncomms5213) | [VQE attains the ground energy when the ansatz reaches a ground state](FQChem/StatePrep/VariationalOptimization/VQE.lean#L38) · [Pauli energy reconstruction](FQChem/Properties/ResponseAndEstimation/VQEMeasurement.lean#L67) · [Unbiased independent-shot estimator and variance bound](FQChem/Properties/ResponseAndEstimation/VQEMeasurement.lean#L118) |
| Higgott, Wang & Brierley (2019), [Variational Quantum Computation of Excited States](https://doi.org/10.22331/q-2019-07-01-156) | [Exact deflation with lower-eigenstate penalties](FQChem/StatePrep/VariationalOptimization/ExcitedStates.lean#L39) |
| Anderson (1975), [A random-walk simulation of the Schrödinger equation: H₃⁺](https://doi.org/10.1063/1.431514) | [Imaginary-time suppression of excited weight with a gap and nonzero ground overlap](FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L106) · [Convergence of the normalized imaginary-time energy](FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L150) |
| Motta et al. (2020), [Determining eigenstates and thermal states on a quantum computer using quantum imaginary time evolution](https://doi.org/10.1038/s41567-019-0704-4) | [Imaginary-time suppression of excited weight with a gap and nonzero ground overlap](FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L106) · [Convergence of the normalized imaginary-time energy](FQChem/StatePrep/ImaginaryTimeProjection/GroundStateProjection.lean#L150) |
| Lin & Tong (2020), [Optimal polynomial based quantum eigenstate filtering with application to solving quantum linear systems](https://doi.org/10.22331/q-2020-11-11-361) | [Geometric suppression of excited-to-ground odds under a spectral gain bound](FQChem/StatePrep/ImaginaryTimeProjection/SpectralFiltering.lean#L45) |
| Hirsch (1983), [Discrete Hubbard-Stratonovich transformation for fermion lattice models](https://doi.org/10.1103/PhysRevB.28.4059) | [Discrete spin-field decoupling of the finite Hubbard interaction](FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L68) |
| Hubbard (1959), [Calculation of Partition Functions](https://doi.org/10.1103/PhysRevLett.3.77) | [Gaussian auxiliary-field identity for a finite Hermitian channel](FQChem/StatePrep/ImaginaryTimeProjection/GaussianAuxiliaryField.lean#L46) |
| Trotter (1959), [On the product of semi-groups of operators](https://doi.org/10.1090/S0002-9939-1959-0108732-6) | [Continuum time-step limit of the finite Hubbard field sum](FQChem/StatePrep/ImaginaryTimeProjection/HubbardProjection.lean#L78) · [Lie–Trotter convergence for bounded noncommuting generators](FQChem/Dynamics/DigitalAlgorithms/LieTrotter.lean#L73) |
| Sugiyama & Koonin (1986), [Auxiliary field Monte-Carlo for quantum many-body ground states](https://doi.org/10.1016/0003-4916%2886%2990107-7) | [Free projection as a weighted sum of Slater walkers](FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L139) · [Determinant formula for trial overlaps](FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L148) |
| Zhang & Krakauer (2003), [Quantum Monte Carlo Method using Phase-Free Random Walks with Slater Determinants](https://doi.org/10.1103/PhysRevLett.90.136401) | [Importance-weighted mixed energy with nonzero overlaps](FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L163) · [Pathwise cosine-projection weight-loss bound at fixed remaining weights](FQChem/StatePrep/ImaginaryTimeProjection/AFQMC.lean#L187) |
| Troyer and Wiese (2005), [Computational Complexity and Fundamental Limitations to Fermionic Quantum Monte Carlo Simulations](https://doi.org/10.1103/PhysRevLett.94.170201) | [Exponential independent-sample cost on an explicit signed product family](FQChem/StatePrep/ImaginaryTimeProjection/SignProblem.lean#L96) |
| Booth, Thom & Alavi (2009), [Fermion Monte Carlo without fixed nodes: A game of life, death, and annihilation in Slater determinant space](https://doi.org/10.1063/1.3193710) | [Expected FCIQMC spawning and death reproduce the discrete CI update](FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L184) · [Annihilation preserves signed populations](FQChem/StatePrep/ImaginaryTimeProjection/FCIQMC.lean#L142) |
| Umrigar et al. (1993), [A diffusion Monte Carlo algorithm with very small time-step errors](https://doi.org/10.1063/1.465195) | [Finite-state guided Feynman–Kac identity](FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L50) |
| ten Haaf et al. (1995), [Proof for an upper bound in fixed-node Monte Carlo for lattice fermions](https://doi.org/10.1103/PhysRevB.51.13039) | [Lattice fixed-node upper bound](FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L176) · [Equality condition for the lattice bound](FQChem/StatePrep/ImaginaryTimeProjection/DiffusionMonteCarlo.lean#L186) |
| Abrams & Lloyd (1999), [Quantum Algorithm Providing Exponential Speed Increase for Finding Eigenvalues and Eigenvectors](https://doi.org/10.1103/PhysRevLett.83.5162) | [Exact-grid ground-sector postselection without phase aliasing](FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L122) · [Finite-resolution success and fidelity with separated phases](FQChem/StatePrep/ImaginaryTimeProjection/PhaseEstimationFilter.lean#L137) · [Exact-grid phase readout](FQChem/Properties/PhaseEstimation.lean#L17) |
| Schrödinger (1926), [Quantisierung als Eigenwertproblem](https://doi.org/10.1002/andp.19263851302) | [First-order eigenstate and first two nondegenerate energy corrections](FQChem/StatePrep/PerturbationTheory/RayleighSchrodinger.lean#L95) · [Cubic residual of the truncated eigenpair](FQChem/StatePrep/PerturbationTheory/RayleighSchrodinger.lean#L165) |
| Čížek (1966), [On the Correlation Problem in Atomic and Molecular Systems. Calculation of Wavefunction Components in Ursell-Type Expansion Using Quantum-Field Theoretical Methods](https://doi.org/10.1063/1.1727484) | [Full exponential similarity transform and reference eigen-equation](FQChem/StatePrep/PerturbationTheory/CoupledCluster.lean#L18) |
| Andersson, Malmqvist & Roos (1992), [Second-order perturbation theory with a complete active space self-consistent field reference function](https://doi.org/10.1063/1.462209) | [Nonpositive second-order shift with positive external gaps](FQChem/StatePrep/PerturbationTheory/Multireference.lean#L17) |
| Boys (1950), [Electronic wave functions - I. A general method of calculation for the stationary states of any molecular system](https://doi.org/10.1098/rspa.1950.0036) | [Monotonicity of CI energy in nested determinant spaces](FQChem/StatePrep/SubspaceDiagonalization/ConfigurationInteraction.lean#L27) |
| Lanczos (1950), [An iteration method for the solution of the eigenvalue problem of linear differential and integral operators](https://doi.org/10.6028/jres.045.026) | [Monotone Ritz energies in Hamiltonian Krylov spaces](FQChem/StatePrep/SubspaceDiagonalization/Krylov.lean#L32) |
| Stair, Huang & Evangelista (2020), [A Multireference Quantum Krylov Algorithm for Strongly Correlated Electrons](https://doi.org/10.1021/acs.jctc.9b01125) | [Monotone Ritz energies in unitary time-step spaces](FQChem/StatePrep/SubspaceDiagonalization/Krylov.lean#L35) |
| Robledo-Moreno et al. (2025), [Chemistry beyond the scale of exact diagonalization on a quantum-centric supercomputer](https://doi.org/10.1126/sciadv.adu9991) | [Exact Ritz energy when the sampled span contains a ground state](FQChem/StatePrep/SubspaceDiagonalization/ConfigurationInteraction.lean#L33) |
| Kato (1950), [On the Adiabatic Theorem of Quantum Mechanics](https://doi.org/10.1143/JPSJ.5.435) | [Kato transport intertwines the moving projectors](FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L186) · [Vanishing leakage for a smooth two-band model with fixed splitting](FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L311) |
| Avron & Elgart (1999), [Adiabatic Theorem without a Gap Condition](https://doi.org/10.1007/s002200050620) | [Inverse-runtime leakage under the bounded correction hypotheses](FQChem/StatePrep/AdiabaticPreparation/AdiabaticTheorem.lean#L264) |
| Pichler et al. (2018), [Quantum Optimization for Maximum Independent Set Using Rydberg Atom Arrays](https://arxiv.org/abs/1808.10816) | [Ideal blockade ground configurations are maximum independent sets at sufficient penalty](FQChem/StatePrep/AdiabaticPreparation/RydbergBlockade.lean#L28) |
| Möttönen et al. (2005), [Transformation of quantum states using uniformly controlled rotations](https://arxiv.org/abs/quant-ph/0407010) | [Exact preparation of normalized complex n-qubit amplitudes](FQChem/StatePrep/CircuitPreparation/ControlledRotations.lean#L122) · [Prefix-controlled rotation count](FQChem/StatePrep/CircuitPreparation/ControlledRotations.lean#L113) |
| Brassard et al. (2002), [Quantum amplitude amplification and estimation](https://doi.org/10.1090/conm/305/05215) | [Two-reflection success law](FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L110) · [Success after rounding the iteration count](FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L117) · [Inverse-square-root query bound for known starting success](FQChem/StatePrep/CircuitPreparation/AmplitudeAmplification.lean#L138) |
| Jiang et al. (2018), [Quantum Algorithms to Simulate Many-Body Physics of Correlated Fermions](https://doi.org/10.1103/PhysRevApplied.9.044036) | [Exact Slater preparation with number-conserving one- and two-mode gates and unrestricted connectivity](FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L247) · [Occupation amplitudes as minors](FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L71) |
| Galerkin (1915), [Series in some questions of elastic equilibrium of rods and plates](https://www.mathnet.ru/PresentFiles/29594/galerkin_150_bubnov_galerkin_method.pdf) | [Galerkin residual orthogonality](FQChem/StatePrep/SubspaceDiagonalization/RitzGalerkin.lean#L32) |
| Kivlichan et al. (2018), [Quantum Simulation of Electronic Structure with Linear Depth and Connectivity](https://doi.org/10.1103/PhysRevLett.120.110501) | [Exact Slater preparation with number-conserving one- and two-mode gates and unrestricted connectivity](FQChem/StatePrep/CircuitPreparation/SlaterDeterminants.lean#L247) |

### Dynamics

| Paper | Result proved in Lean |
| --- | --- |
| Stone (1932), [On One-Parameter Unitary Groups in Hilbert Space](https://doi.org/10.2307/1968538) | [Unitary Schrödinger group for bounded self-adjoint generators](FQChem/Dynamics/RealTimePropagation/SchrodingerGroup.lean#L41) |
| Feit, Fleck & Steiger (1982), [Solution of the Schrödinger equation by a spectral method](https://doi.org/10.1016/0021-9991%2882%2990091-2) | [Symmetric split steps preserve inner products](FQChem/Dynamics/RealTimePropagation/SplitOperator.lean#L26) |
| Born & Oppenheimer (1927), [Zur Quantentheorie der Molekeln](https://doi.org/10.1002/andp.19273892002) | [Mechanical-energy stationarity on a one-coordinate adiabatic trajectory](FQChem/Dynamics/RealTimePropagation/BornOppenheimer.lean#L27) |
| Park & Light (1986), [Unitary quantum time evolution by iterative Lanczos reduction](https://doi.org/10.1063/1.451548) | [Reproduction of represented Hamiltonian moments on a Krylov seed](FQChem/Dynamics/RealTimePropagation/KrylovPropagation.lean#L42) |
| Begušić & Chan (2025), [Real-Time Operator Evolution in Two and Three Dimensions via Sparse Pauli Dynamics](https://doi.org/10.1103/PRXQuantum.6.020302) | [Two-term evolution of an anticommuting Pauli string](FQChem/Dynamics/RealTimePropagation/HeisenbergPicture.lean#L38) |
| Craig & Manolopoulos (2004), [Quantum statistics and classical mechanics: Real time correlation functions from ring polymer molecular dynamics](https://doi.org/10.1063/1.1777575) | [Zero net centroid force from the internal ring springs](FQChem/Dynamics/RealTimePropagation/RingPolymer.lean#L26) |
| Krause, Klamroth & Saalfrank (2005), [Time-dependent configuration-interaction calculations of laser-pulse-driven many-electron dynamics: Controlled dipole switching in lithium cyanide](https://doi.org/10.1063/1.1999636) | [First-order norm conservation for fixed-basis real-Hamiltonian TD-CI](FQChem/Dynamics/RealTimePropagation/TimeDependentCI.lean#L28) |
| Carleo et al. (2012), [Localization and Glassy Dynamics Of Many-Body Quantum Systems](https://doi.org/10.1038/srep00243) | [Positive semidefinite sampled tangent covariance for real log derivatives](FQChem/Dynamics/RealTimePropagation/VariationalEvolution.lean#L38) |
| Werner, Oka & Millis (2009), [Diagrammatic Monte Carlo simulation of nonequilibrium systems](https://doi.org/10.1103/PhysRevB.79.035320) | [Complex trajectory reweighting and the mean-phase bound](FQChem/Dynamics/RealTimePropagation/PathSampling.lean#L22) |
| Rigol, Bryant & Singh (2006), [Numerical Linked-Cluster Approach to Quantum Lattice Models](https://doi.org/10.1103/PhysRevLett.97.187202) | [Finite linked-cluster subtraction by Möbius inversion](FQChem/Dynamics/RealTimePropagation/ClusterExpansions.lean#L20) |
| McLachlan (1964), [A variational solution of the time-dependent Schrodinger equation](https://doi.org/10.1080/00268976400100041) | [Orthogonal tangent projection minimizes the instantaneous residual](FQChem/Dynamics/RealTimePropagation/VariationalEvolution.lean#L56) |
| Lloyd (1996), [Universal Quantum Simulators](https://doi.org/10.1126/science.273.5278.1073) | [Exact product formula for commuting terms](FQChem/Dynamics/DigitalAlgorithms/CommutingTerms.lean#L18) |
| Berry et al. (2015), [Simulating Hamiltonian Dynamics with a Truncated Taylor Series](https://doi.org/10.1103/PhysRevLett.114.090502) | [PREPARE–SELECT block encoding of a weighted unitary sum](FQChem/Dynamics/DigitalAlgorithms/LinearCombinationOfUnitaries.lean#L69) · [Postselection probability](FQChem/Dynamics/DigitalAlgorithms/LinearCombinationOfUnitaries.lean#L81) · [Factorial Taylor remainder](FQChem/Dynamics/DigitalAlgorithms/TruncatedTaylor.lean#L109) · [Segmented operator-norm error bound](FQChem/Dynamics/DigitalAlgorithms/TruncatedTaylor.lean#L116) |
| Low & Chuang (2019), [Hamiltonian Simulation by Qubitization](https://doi.org/10.22331/q-2019-07-12-163) | [Chebyshev polynomial of the block-encoded Hamiltonian](FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L100) · [Walk eigenphase relation](FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L150) · [Short-time simulation bound](FQChem/Dynamics/DigitalAlgorithms/Qubitization.lean#L169) |
| Choi (1975), [Completely positive linear maps on complex matrices](https://doi.org/10.1016/0024-3795(75)90075-0) | [Kraus positivity and trace preservation with a finite ancilla](FQChem/Dynamics/OpenSystems/Kraus.lean#L86) |
| Lindblad (1976), [On the generators of quantum dynamical semigroups](https://doi.org/10.1007/BF01608499) | [Zero trace of each Lindblad dissipator](FQChem/Dynamics/OpenSystems/TracePreservation.lean#L30) |
| Kraus (1971), [General state changes in quantum theory](https://doi.org/10.1016/0003-4916%2871%2990108-4) | [Trace preservation under Kraus completeness](FQChem/Dynamics/OpenSystems/TracePreservation.lean#L37) |
| Chmiela et al. (2017), [Machine learning of accurate energy-conserving molecular force fields](https://doi.org/10.1126/sciadv.1603015) | [Force covariance under energy-preserving isometries](FQChem/Dynamics/LearnedSurrogates.lean#L28) |

### Properties

| Paper | Result proved in Lean |
| --- | --- |
| Born (1926), [Zur Quantenmechanik der Stoßvorgänge](https://doi.org/10.1007/BF01397477) | [Probability normalization for a complete Kraus measurement](FQChem/Properties/MeasurementTheory.lean#L69) |
| Lüders (1951), [Über die Zustandsänderung durch den Meßprozeß](https://doi.org/10.1002/andp.19504430510) | [Repeatability of a projective measurement](FQChem/Properties/MeasurementTheory.lean#L78) |
| Oreshkov & Brun (2005), [Weak Measurements Are Universal](https://doi.org/10.1103/PhysRevLett.95.110409) | [Explicit unsharp qubit probabilities and posterior polarization](FQChem/Properties/MeasurementTheory.lean#L96) |
| Feynman (1939), [Forces in Molecules](https://doi.org/10.1103/PhysRev.56.340) | [Derivative of a differentiable bounded-Hamiltonian eigenpair](FQChem/Properties/ResponseAndEstimation/HellmannFeynman.lean#L39) |
| Silver, Sivia & Gubernatis (1990), [Maximum-entropy method for analytic continuation of quantum Monte Carlo data](https://doi.org/10.1103/PhysRevB.41.2380) | [Discrete Laplace identification at known energies](FQChem/Properties/ResponseAndEstimation/SpectralReconstruction.lean#L21) |
| Harrow, Hassidim & Lloyd (2009), [Quantum Algorithm for Linear Systems of Equations](https://doi.org/10.1103/PhysRevLett.103.150502) | [Reciprocal eigenvalue weighting for exact HHL inversion](FQChem/Properties/LinearSystems/HHL.lean#L18) |
| Cao et al. (2013), [Quantum algorithm and circuit design solving the Poisson equation](https://doi.org/10.1088/1367-2630/15/1/013021) | [Sine eigenmodes of the Dirichlet Poisson stencil](FQChem/Properties/LinearSystems/DirichletPoisson.lean#L20) |

### Multiscale methods

| Paper | Result proved in Lean |
| --- | --- |
| Richard & Herbert (2012), [A generalized many-body expansion and a unified view of fragment-based methods in electronic structure theory](https://doi.org/10.1063/1.4742816) | [Overlap subtraction and crossing terms in finite interaction energies](FQChem/Multiscale/ChoosingLayers/Partitions.lean#L36) |
| Svensson et al. (1996), [ONIOM: A Multilayered Integrated MO + MM Method for Geometry Optimizations and Single Point Energy Predictions. A Test for Diels−Alder Reactions and Pt(P(t-Bu)3)2 + H2 Oxidative Addition](https://doi.org/10.1021/jp962071j) | [Forces from a subtractive ONIOM energy surface](FQChem/Multiscale/ChoosingLayers/ClassicalEnvironments.lean#L26) |
| Wesołowski & Warshel (1993), [Frozen density functional approach for ab initio calculations of solvated molecules](https://doi.org/10.1021/j100132a040) | [Frozen-density variational bound and exactness for a compatible minimizing split](FQChem/Multiscale/ChoosingLayers/QuantumEnvironments.lean#L41) |
| Kitaura et al. (1999), [Fragment molecular orbital method: an approximate computational method for large molecules](https://doi.org/10.1016/S0009-2614(99)00874-X) | [Two-body reconstruction for pair-additive fragment energies](FQChem/Multiscale/ChoosingLayers/Fragments.lean#L27) |
| Ramakrishnan et al. (2015), [Big Data Meets Quantum Chemistry Approximations: The Δ-Machine Learning Approach](https://doi.org/10.1021/acs.jctc.5b00099) | [Energy-gap error from two endpoint Δ-learning errors](FQChem/Multiscale/ChoosingLayers/LearnedEnvironments.lean#L23) |
| Feshbach (1958), [Unified theory of nuclear reactions](https://doi.org/10.1016/0003-4916(58)90007-1) | [Active-space eigenproblem and environment reconstruction assuming a resolvent](FQChem/Multiscale/StitchingSolutions/EmbeddedSolvers.lean#L30) |
| Zwanzig (1954), [High-Temperature Equation of State by a Perturbation Method. I. Nonpolar Gases](https://doi.org/10.1063/1.1740409) | [Free-energy perturbation identity for a finite ensemble](FQChem/Multiscale/StitchingSolutions/Observables.lean#L33) |
| Eyring (1935), [The Activated Complex in Chemical Reactions](https://doi.org/10.1063/1.1749604) | [Multiplicative rate bound from an activation-barrier error](FQChem/Multiscale/StitchingSolutions/ErrorPropagation.lean#L23) |

### Complexity and limits

| Paper | Result proved in Lean |
| --- | --- |
| Bennett et al. (1997), [Strengths and Weaknesses of Quantum Computing](https://arxiv.org/abs/quant-ph/9701001) | [Hybrid query lower bound for a hidden ground space among orthonormal candidates](FQChem/Complexity/GroundStateSearch.lean#L154) |
| Beals et al. (2001), [Quantum Lower Bounds by Polynomials](https://arxiv.org/abs/quant-ph/9802049) | [T-query Born probability has polynomial degree at most 2T](FQChem/Complexity/AaronsonAmbainisQuery.lean#L173) · [Parity application requiring at least N/2 individual term queries for a two-orbital population](FQChem/Complexity/OrbitalSimulation.lean#L113) |
| Aaronson & Ambainis (2014), [The Need for Structure in Quantum Speedups](https://doi.org/10.4086/toc.2014.v010a006) | [Influential input for varying orbital populations under binary onsite pulses](FQChem/Complexity/AaronsonAmbainis.lean#L51) using [Turturean’s Lean proof of the influence conjecture](https://github.com/physical-superintelligence/aaronson-ambainis/tree/2a6ceaef872ae993708950f951989134084b851a) |
| Kitaev, Shen & Vyalyi (2002), [Classical and Quantum Computation](https://doi.org/10.1090/gsm/047) | [Bounded-error decision circuit to five-local ground-energy thresholds](integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L116) · [Polynomial bit-list compiler cost](integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L101) · [Inverse-polynomial promise gap](integrations/qatlib/FQChemKitaev/BoundedErrorReduction.lean#L130) |
| Liu, Christandl & Verstraete (2007), [Quantum Computational Complexity of the N-Representability Problem: QMA Complete](https://doi.org/10.1103/PhysRevLett.98.110503) | [Dual-rail fixed-particle encoding preserves the local-Hamiltonian energy promise](FQChem/Complexity/ElectronicStructurePauli.lean#L209) |
