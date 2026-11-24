# Simulating dynamics

Import this chapter with `import FQChem.Dynamics`.

## [Real-time propagation](RealTimePropagation)

- [The exponential of a bounded self-adjoint Hamiltonian generates unitary Schrödinger evolution with the real-time group law](RealTimePropagation/SchrodingerGroup.lean#L41). [Stone (1932)](https://doi.org/10.2307/1968538)
- **Wavepacket dynamics**. [Symmetric split steps preserve inner products](RealTimePropagation/SplitOperator.lean#L26). [Feit, Fleck & Steiger (1982)](https://doi.org/10.1016/0021-9991%2882%2990091-2)
- **Electron–nuclear dynamics**. [Stationarity of mechanical energy on a one-coordinate adiabatic trajectory](RealTimePropagation/BornOppenheimer.lean#L27). [Born & Oppenheimer (1927)](https://doi.org/10.1002/andp.19273892002)
- **State-vector propagation & typicality**. [Krylov projection reproduces all represented Hamiltonian moments on the seed](RealTimePropagation/KrylovPropagation.lean#L42). [Park & Light (1986)](https://doi.org/10.1063/1.451548)
- **Operator propagation**. [Exact two-term rotation of an anticommuting Pauli string](RealTimePropagation/HeisenbergPicture.lean#L38). [Begušić & Chan (2025)](https://doi.org/10.1103/PRXQuantum.6.020302)
- **Phase-space approximations**. [Internal ring-polymer springs exert zero net centroid force](RealTimePropagation/RingPolymer.lean#L26). [Craig & Manolopoulos (2004)](https://doi.org/10.1063/1.1777575)
- **Correlated real-time electronic structure**. [Norm conservation to first order in fixed-basis real-Hamiltonian TD-CI](RealTimePropagation/TimeDependentCI.lean#L28). [Krause, Klamroth & Saalfrank (2005)](https://doi.org/10.1063/1.1999636)
- **Time-dependent variational Monte Carlo**. [Positive semidefinite empirical tangent covariance for real log derivatives](RealTimePropagation/VariationalEvolution.lean#L38). [Carleo et al. (2012)](https://doi.org/10.1038/srep00243)
- **Real-time quantum Monte Carlo**. [Complex trajectory reweighting and mean-phase bound](RealTimePropagation/PathSampling.lean#L22). [Werner, Oka & Millis (2009)](https://doi.org/10.1103/PhysRevB.79.035320)
- **Short-time, cluster & hydrodynamic expansions**. [Finite linked-cluster subtraction as Möbius inversion](RealTimePropagation/ClusterExpansions.lean#L20). [Rigol, Bryant & Singh (2006)](https://doi.org/10.1103/PhysRevLett.97.187202)
- **Variational time evolution**. [An orthogonally projected tangent velocity minimizes the instantaneous residual](RealTimePropagation/VariationalEvolution.lean#L56). [McLachlan (1964)](https://doi.org/10.1080/00268976400100041)

- **Out-of-time-order correlators**. The four-point OTOC with a local Z probe is determined by the Pauli mass that anticommutes with Z. The two-copy swap readout and uniform identity/swap tails are also formalized. [Checked identities](RealTimePropagation/OutOfTimeOrder.lean) · [Lewis et al. (2026)](https://arxiv.org/abs/2611.24640)

## [Fault-tolerant digital algorithms](DigitalAlgorithms)

- **Digital Hamiltonian simulation**. [Noncommuting Lie–Trotter convergence for bounded generators](DigitalAlgorithms/LieTrotter.lean#L73) · [Exact multislice product formula for commuting terms](DigitalAlgorithms/CommutingTerms.lean#L18). [Trotter (1959)](https://doi.org/10.1090/S0002-9939-1959-0108732-6), [Lloyd (1996)](https://doi.org/10.1126/science.273.5278.1073)
- **Linear combinations of unitaries (LCU)**. The PREPARE–SELECT–unprepare circuit [block-encodes H/α](DigitalAlgorithms/LinearCombinationOfUnitaries.lean#L69) when its ancilla probabilities give the normalized term weights. For a unit input ψ the [postselection probability](DigitalAlgorithms/LinearCombinationOfUnitaries.lean#L81) is ‖Hψ‖²/α². [Berry et al. (2015)](https://doi.org/10.1103/PhysRevLett.114.090502)
- **Truncated Taylor simulation**. A [factorial one-segment truncation bound](DigitalAlgorithms/TruncatedTaylor.lean#L109) yields a [total operator-norm error bound](DigitalAlgorithms/TruncatedTaylor.lean#L116) for equal time segments and a bounded self-adjoint Hamiltonian. [Berry et al. (2015)](https://doi.org/10.1103/PhysRevLett.114.090502)
- **Qubitization**. For an orthogonal signal projector P and a Hermitian involution S, [the projected nth walk power](DigitalAlgorithms/Qubitization.lean#L100) implements the Chebyshev polynomial of the encoded Hamiltonian. This gives the [eigenphase relation](DigitalAlgorithms/Qubitization.lean#L150) and a [short-time error bound](DigitalAlgorithms/Qubitization.lean#L169) for a weighted combination of walk steps. [Low & Chuang (2019)](https://doi.org/10.22331/q-2019-07-12-163)

## [Reduced-state and open-system evolution](OpenSystems)

- [A Kraus channel preserves positive semidefiniteness in the presence of an arbitrary finite ancilla and preserves the joint trace under Kraus completeness](OpenSystems/Kraus.lean#L86). [Choi (1975)](https://doi.org/10.1016/0024-3795(75)90075-0)
- **Open quantum systems**. [Each Lindblad dissipator has zero trace](OpenSystems/TracePreservation.lean#L30). [Lindblad (1976)](https://doi.org/10.1007/BF01608499)
- **Open dynamics on quantum devices**. [Kraus completeness implies trace preservation of the channel](OpenSystems/TracePreservation.lean#L37). [Kraus (1971)](https://doi.org/10.1016/0003-4916%2871%2990108-4)

## [Learned surrogates of electronic structure](LearnedSurrogates.lean)

- **Learned potentials**. [Directional forces transform covariantly under energy-preserving isometries](LearnedSurrogates.lean#L28). [Chmiela et al. (2017)](https://doi.org/10.1126/sciadv.1603015)

For the term-query lower bound on two-orbital simulation and the influence of binary onsite potentials on readout, see [Complexity and limits](../Complexity/README.md).
