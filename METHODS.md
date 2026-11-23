# Method theorems

One row per family in the [Cuántica method atlas](https://cuanti.ca/#/all). The links identify the exact result checked in Lean. The papers introduce the theorem, method, or physical model from which the stated consequence follows.

## Classical electronic structure and dynamics

| Method family | Checked result | Primary literature |
| --- | --- | --- |
| Mean field | [Slater determinant upper bound in the fermionic sector](FormalQChem/Theorems/VariationalMethods.lean#L39) · [proof](FormalQChem/Proofs/VariationalMethods.lean#L16) | [Fock (1930)](https://doi.org/10.1007/BF01340294) |
| Configuration interaction | [Nested determinant spaces lower the CI Ritz energy](FormalQChem/Theorems/VariationalMethods.lean#L45) · [proof](FormalQChem/Proofs/VariationalMethods.lean#L23) | [Boys (1950)](https://doi.org/10.1098/rspa.1950.0036) |
| Krylov subspace diagonalization | [Hamiltonian powers give monotone Ritz energies](FormalQChem/Theorems/VariationalMethods.lean#L55) · [proof](FormalQChem/Proofs/VariationalMethods.lean#L35) | [Lanczos (1950)](https://doi.org/10.6028/jres.045.026) |
| Coupled cluster | [Full exponential similarity and the reference eigen-equation](FormalQChem/Theorems/VariationalMethods.lean#L64) · [proof](FormalQChem/Proofs/VariationalMethods.lean#L41) | [Čížek (1966)](https://doi.org/10.1063/1.1727484) |
| Quantum Monte Carlo | [Variational trial-state local-energy estimator](FormalQChem/Proofs/QuantumAlgorithms.lean#L11) | [McMillan (1965)](https://doi.org/10.1103/PhysRev.138.A442) |
| Tensor networks | [MPS cut-rank bound](FormalQChem/Proofs/QuantumAlgorithms.lean#L20) and [exact bond-D cut factorization](FormalQChem/Proofs/QuantumAlgorithms.lean#L31) · [One-site DMRG update](FormalQChem/Proofs/DMRG.lean#L33) | [Vidal (2003)](https://doi.org/10.1103/PhysRevLett.91.147902), [White (1992)](https://doi.org/10.1103/PhysRevLett.69.2863) |
| Density functionals | [Conditional continuum Hohenberg–Kohn uniqueness](FormalQChem/Proofs/DFT.lean#L168) and [Lieb variational principle](FormalQChem/Proofs/DFT.lean#L187), [3D one-body rigidity](FormalQChem/Proofs/MolecularHK.lean#L12), and [conditional molecular HK](FormalQChem/Proofs/MolecularHK.lean#L30) · [3D Coulomb constrained search on smooth trial states](FormalQChem/Proofs/CoulombIntegrability.lean#L64) | [Hohenberg & Kohn (1964)](https://doi.org/10.1103/PhysRev.136.B864), [Lieb (1983)](https://doi.org/10.1002/qua.560240302), [Levy (1979)](https://doi.org/10.1073/pnas.76.12.6062) |
| Multireference perturbation | [Nonpositive second-order shift for positive external gaps](FormalQChem/Theorems/VariationalMethods.lean#L70) · [proof](FormalQChem/Proofs/VariationalMethods.lean#L58) | [Andersson, Malmqvist & Roos (1992)](https://doi.org/10.1063/1.462209) |
| Wavepacket dynamics | [Symmetric split steps preserve inner products](FormalQChem/Theorems/Dynamics.lean#L21) · [proof](FormalQChem/Proofs/Dynamics.lean#L17) | [Feit, Fleck & Steiger (1982)](https://doi.org/10.1016/0021-9991%2882%2990091-2) |
| Electron–nuclear dynamics | [Stationarity of mechanical energy on a one-coordinate adiabatic trajectory](FormalQChem/Theorems/Dynamics.lean#L62) · [proof](FormalQChem/Proofs/Dynamics.lean#L75) | [Born & Oppenheimer (1927)](https://doi.org/10.1002/andp.19273892002) |
| Open quantum systems | [Each Lindblad dissipator has zero trace](FormalQChem/Theorems/Dynamics.lean#L53) · [proof](FormalQChem/Proofs/Dynamics.lean#L61) | [Lindblad (1976)](https://doi.org/10.1007/BF01608499) |
| Neural wavefunctions | [Equivariant orbitals give an antisymmetric determinant network](FormalQChem/Theorems/VariationalMethods.lean#L75) · [proof](FormalQChem/Proofs/VariationalMethods.lean#L64) | [Pfau et al. (2020)](https://doi.org/10.1103/PhysRevResearch.2.033429) |
| Learned potentials | [Directional forces transform covariantly under energy-preserving isometries](FormalQChem/Theorems/Dynamics.lean#L70) · [proof](FormalQChem/Proofs/Dynamics.lean#L86) | [Chmiela et al. (2017)](https://doi.org/10.1126/sciadv.1603015) |
| State-vector propagation & typicality | [Krylov projection reproduces all represented Hamiltonian moments on the seed](FormalQChem/Theorems/Dynamics.lean#L34) · [proof](FormalQChem/Proofs/Dynamics.lean#L32) | [Park & Light (1986)](https://doi.org/10.1063/1.451548) |
| Operator propagation | [Exact two-term rotation of an anticommuting Pauli string](FormalQChem/Theorems/Dynamics.lean#L46) · [proof](FormalQChem/Proofs/Dynamics.lean#L52) | [Begušić & Chan (2025)](https://doi.org/10.1103/PRXQuantum.6.020302) |
| Classical property evaluation | [Hellmann–Feynman derivative of a bounded-Hamiltonian eigenvalue](FormalQChem/Theorems/HellmannFeynman.lean#L22) · [proof](FormalQChem/Proofs/HellmannFeynman.lean#L17) | [Feynman (1939)](https://doi.org/10.1103/PhysRev.56.340) |
| Imaginary-time spectral reconstruction | [Exact discrete Laplace identification at known energies](FormalQChem/Proofs/QuantumAlgorithms.lean#L53) | [Silver, Sivia & Gubernatis (1990)](https://doi.org/10.1103/PhysRevB.41.2380) |
| Classical excited states | [Energy bound after orthogonality to all lower eigenstates](FormalQChem/Theorems/VariationalMethods.lean#L83) · [proof](FormalQChem/Proofs/VariationalMethods.lean#L79) | [MacDonald (1933)](https://doi.org/10.1103/PhysRev.43.830) |
| Phase-space approximations | [Internal ring-polymer springs exert zero net centroid force](FormalQChem/Theorems/Dynamics.lean#L77) · [proof](FormalQChem/Proofs/Dynamics.lean#L96) | [Craig & Manolopoulos (2004)](https://doi.org/10.1063/1.1777575) |
| Correlated real-time electronic structure | [Norm conservation to first order in fixed-basis real-Hamiltonian TD-CI](FormalQChem/Theorems/Dynamics.lean#L84) · [proof](FormalQChem/Proofs/Dynamics.lean#L103) | [Krause, Klamroth & Saalfrank (2005)](https://doi.org/10.1063/1.1999636) |
| Time-dependent variational Monte Carlo | [Positive semidefinite empirical tangent covariance for real log derivatives](FormalQChem/Theorems/Dynamics.lean#L92) · [proof](FormalQChem/Proofs/Dynamics.lean#L111) | [Carleo et al. (2012)](https://doi.org/10.1038/srep00243) |
| Real-time quantum Monte Carlo | [Complex trajectory reweighting and mean-phase bound](FormalQChem/Proofs/QuantumAlgorithms.lean#L66) | [Werner, Oka & Millis (2009)](https://doi.org/10.1103/PhysRevB.79.035320) |
| Short-time, cluster & hydrodynamic expansions | [Finite linked-cluster subtraction as Möbius inversion](FormalQChem/Proofs/QuantumAlgorithms.lean#L79) | [Rigol, Bryant & Singh (2006)](https://doi.org/10.1103/PhysRevLett.97.187202) |

## Quantum algorithms

| Method family | Checked result | Primary literature |
| --- | --- | --- |
| Variational eigensolvers | [Unitary VQE energy bound and exact reachable minimum](FormalQChem/Theorems/VariationalMethods.lean#L97) · [proof](FormalQChem/Proofs/VariationalMethods.lean#L97) · [Pauli energy reconstruction and finite-shot variance](FormalQChem/Theorems/VQEMeasurement.lean#L29) · [measurement proofs](FormalQChem/Proofs/VQEMeasurement.lean#L17) | [Peruzzo et al. (2014)](https://doi.org/10.1038/ncomms5213) |
| Eigenphase estimation | [Exact-grid phase readout](FormalQChem/Proofs/QuantumAlgorithms.lean#L86) | [Abrams & Lloyd (1999)](https://doi.org/10.1103/PhysRevLett.83.5162) |
| Analog quantum simulators | [Ideal blockade ground configurations and maximum independent sets](FormalQChem/Proofs/QuantumAlgorithms.lean#L93) | [Pichler et al. (2018)](https://arxiv.org/abs/1808.10816) |
| Quantum Krylov subspaces | [Monotone Ritz energies in unitary time-step spaces](FormalQChem/Theorems/VariationalMethods.lean#L59) · [proof](FormalQChem/Proofs/VariationalMethods.lean#L38) | [Stair, Huang & Evangelista (2020)](https://doi.org/10.1021/acs.jctc.9b01125) |
| Sampled configuration diagonalization | [Exactness when the sampled span contains a ground state](FormalQChem/Theorems/VariationalMethods.lean#L103) · [proof](FormalQChem/Proofs/VariationalMethods.lean#L104) | [Robledo-Moreno et al. (2025)](https://doi.org/10.1126/sciadv.adu9991) |
| Digital Hamiltonian simulation | [Noncommuting Lie–Trotter convergence for bounded generators](FormalQChem/Theorems/ProductFormula.lean#L24) · [proof](FormalQChem/Proofs/ProductFormula.lean#L54) · [Exact multislice product formula for commuting terms](FormalQChem/Proofs/QuantumAlgorithms.lean#L116) | [Trotter (1959)](https://doi.org/10.1090/S0002-9939-1959-0108732-6), [Lloyd (1996)](https://doi.org/10.1126/science.273.5278.1073) |
| Variational time evolution | [An orthogonally projected tangent velocity minimizes the instantaneous residual](FormalQChem/Theorems/Dynamics.lean#L101) · [proof](FormalQChem/Proofs/Dynamics.lean#L129) | [McLachlan (1964)](https://doi.org/10.1080/00268976400100041) |
| Quantum linear-system algorithms | [Exact HHL reciprocal eigenvalue weighting](FormalQChem/Proofs/QuantumAlgorithms.lean#L120) | [Harrow, Hassidim & Lloyd (2009)](https://doi.org/10.1103/PhysRevLett.103.150502) |
| Quantum differential-equation algorithms | [Dirichlet Poisson stencil and its nonzero sine eigenmodes](FormalQChem/Proofs/QuantumAlgorithms.lean#L127) | [Cao et al. (2013)](https://doi.org/10.1088/1367-2630/15/1/013021) |
| Open dynamics on quantum devices | [Kraus completeness implies trace preservation of the channel](FormalQChem/Theorems/Dynamics.lean#L57) · [proof](FormalQChem/Proofs/Dynamics.lean#L68) | [Kraus (1971)](https://doi.org/10.1016/0003-4916%2871%2990108-4) |
| Quantum excited states | [Exact lower-state penalties recover the target energy](FormalQChem/Theorems/VariationalMethods.lean#L111) · [proof](FormalQChem/Proofs/VariationalMethods.lean#L112) | [Higgott, Wang & Brierley (2019)](https://doi.org/10.22331/q-2019-07-01-156) |

## Multiscale methods

| Method family | Checked result | Primary literature |
| --- | --- | --- |
| QM/MM & layered models | [Forces on an ONIOM energy surface](FormalQChem/Theorems/Multiscale.lean#L22) · [proof](FormalQChem/Proofs/Multiscale.lean#L11) | [Svensson et al. (1996)](https://doi.org/10.1021/jp962071j) |
| Electronic embedding | [Frozen-density upper bound and exactness for a compatible minimizing split](FormalQChem/Theorems/Multiscale.lean#L40) · [proof](FormalQChem/Proofs/Multiscale.lean#L22) | [Wesołowski & Warshel (1993)](https://doi.org/10.1021/j100132a040) |
| Molecular fragmentation | [Two-body reconstruction for pair-additive fragment energies](FormalQChem/Theorems/Multiscale.lean#L53) · [proof](FormalQChem/Proofs/Multiscale.lean#L31) | [Kitaura et al. (1999)](https://doi.org/10.1016/S0009-2614(99)00874-X) |
| Learned potentials & interfaces | [Energy-gap error from two endpoint Δ-learning errors](FormalQChem/Theorems/Multiscale.lean#L61) · [proof](FormalQChem/Proofs/Multiscale.lean#L42) | [Ramakrishnan et al. (2015)](https://doi.org/10.1021/acs.jctc.5b00099) |
| Ensemble free energies | [Zwanzig free-energy perturbation identity for finite ensembles](FormalQChem/Theorems/Multiscale.lean#L73) · [proof](FormalQChem/Proofs/Multiscale.lean#L49) | [Zwanzig (1954)](https://doi.org/10.1063/1.1740409) |
| Multiscale error control | [Multiplicative rate uncertainty from an activation-barrier error](FormalQChem/Theorems/Multiscale.lean#L79) · [proof](FormalQChem/Proofs/Multiscale.lean#L64) | [Eyring (1935)](https://doi.org/10.1063/1.1749604) |
