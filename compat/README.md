# Earlier imports

The original `FormalQChem.Theorems.*` and `FormalQChem.Proofs.*` modules forward to the current topic files. Lake builds these compatibility imports alongside the library.

If your code used a chapter path ending in `.Theorems` or `.Proofs`, import its family to get the same declarations. For example, replace `FormalQChem.StatePrep.VariationalOptimization.DMRG.Proofs` with `FormalQChem.StatePrep.VariationalOptimization`. For a narrower import, use the specific topic, in this case `FormalQChem.StatePrep.VariationalOptimization.TensorNetworks.DMRG`. Each chapter index links to the current topic files.
