# Aaronson–Ambainis proof dependency

fqchem uses David Turturean’s Apache-2.0 Lean proof at commit
`2a6ceaef872ae993708950f951989134084b851a`. The upstream public theorems
use Lean and Mathlib 4.33. This package compiles their source with the same
Lean and Mathlib 4.36.0-rc2 environment as the chemistry application.
[Upstream declarations](https://github.com/physical-superintelligence/aaronson-ambainis/blob/2a6ceaef872ae993708950f951989134084b851a/AaronsonAmbainis/Main.lean)

From the repository root, run

```sh
lake build FQChem.Complexity.AaronsonAmbainis
```

Lake fetches the pinned repository and invokes `prepare.py` using Python 3
and Git. It reads the transitive imports of upstream `AaronsonAmbainis.Main`,
applies the tracked compatibility patch to a temporary copy and writes modern
module headers. The generated sources are under `.lake/ported` in this package.
For each module `AaronsonAmbainisPort.X`, the upstream module is
`AaronsonAmbainis.X`. The chemistry proofs use
`AaronsonAmbainis.aaronson_ambainis` and
`AaronsonAmbainis.aaronson_ambainis_explicit`.
[Compatibility patch](lean-4.36.patch) · [Upstream attribution](NOTICE) · [License](LICENSE)
