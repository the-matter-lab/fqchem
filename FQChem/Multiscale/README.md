# Multiscale methods

Import this chapter with `import FQChem.Multiscale`.

## Choosing the layers

### [Partitions, boundaries, and double counting](ChoosingLayers/Partitions.lean)

- [Overlapping layers reconstruct a finite interaction energy by subtracting double-counted terms and restoring terms that cross the boundary](ChoosingLayers/Partitions.lean#L36). [Richard & Herbert (2012)](https://doi.org/10.1063/1.4742816)

### [Classical environments](ChoosingLayers/ClassicalEnvironments.lean)

- **QM/MM & layered models**. [Forces on an ONIOM energy surface](ChoosingLayers/ClassicalEnvironments.lean#L26). [Svensson et al. (1996)](https://doi.org/10.1021/jp962071j)

### [Quantum environments](ChoosingLayers/QuantumEnvironments.lean)

- **Electronic embedding**. [Frozen-density upper bound and exactness for a compatible minimizing split](ChoosingLayers/QuantumEnvironments.lean#L41). [Wesołowski & Warshel (1993)](https://doi.org/10.1021/j100132a040)
- [Frozen-density bound for the molecular Coulomb energy](ChoosingLayers/FrozenMolecularDensity.lean). The restricted infimum equals the molecular trial-space infimum if an admissible split attains it.

### [Fragments and many-body expansions](ChoosingLayers/Fragments.lean)

- **Molecular fragmentation**. [Two-body reconstruction for pair-additive fragment energies](ChoosingLayers/Fragments.lean#L27). [Kitaura et al. (1999)](https://doi.org/10.1016/S0009-2614(99)00874-X)

### [Learned environments](ChoosingLayers/LearnedEnvironments.lean)

- **Learned potentials & interfaces**. [Energy-gap error from two endpoint Δ-learning errors](ChoosingLayers/LearnedEnvironments.lean#L23). [Ramakrishnan et al. (2015)](https://doi.org/10.1021/acs.jctc.5b00099)

## Stitching solutions

### [Solvers inside the embedded problem](StitchingSolutions/EmbeddedSolvers.lean)

- [Feshbach reduction gives an equivalent active-space eigenproblem and reconstructs the environment amplitudes wherever the environment resolvent exists](StitchingSolutions/EmbeddedSolvers.lean#L30). [Feshbach (1958)](https://doi.org/10.1016/0003-4916(58)90007-1)

- [Imaginary-time QM solver on a layered energy surface](StitchingSolutions/LayeredQM.lean). At fixed nuclear geometry, the finite-time ONIOM energy inherits the model solver’s exponential error bound and converges to its ground-state ONIOM value.
- [Layered nuclear dynamics](StitchingSolutions/LayeredQM.lean#L61). For a smooth electronic eigenbranch, the Hellmann–Feynman derivative combines with the two MM forces. Newton motion under that force gives zero time derivative of total mechanical energy.

### [Properties of the whole system](StitchingSolutions/Observables.lean)

- **Ensemble free energies**. [Zwanzig free-energy perturbation identity for finite ensembles](StitchingSolutions/Observables.lean#L33). [Zwanzig (1954)](https://doi.org/10.1063/1.1740409)

### [Error propagation and validation across scales](StitchingSolutions/ErrorPropagation.lean)

- **Multiscale error control**. [Multiplicative rate uncertainty from an activation-barrier error](StitchingSolutions/ErrorPropagation.lean#L23). [Eyring (1935)](https://doi.org/10.1063/1.1749604)
