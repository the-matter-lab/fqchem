# Theorem dependencies

Browse the diagrams directly on GitHub, or open [the interactive explorer](index.html) in a browser from a checkout. Search by theorem, method or family and select a result to trace its prerequisites and the results that use it. The explorer works offline with its accompanying data files.

- [fqchem theorem graphs by module](library.md)
- [Kitaev integration theorem graphs by module](kitaev.md)
- [Scope and references for the complexity results](../../FQChem/Complexity/README.md)

## Reading the graph

An arrow A → B means that Lean's elaborated statement or proof of B uses A. A solid edge is a direct constant reference. A dashed edge passes through local definitions or compiler-generated helpers before reaching A. Each path stops at its first source theorem. Private source lemmas and theorems with no edges are included. A module import or a shared scientific topic creates no edge. Core Lean and Mathlib are outside the graph, and imported Aaronson–Ambainis and Qatlib theorems used at the boundary link to their pinned sources.

For example, VMC’s variational bound uses both the Born-average identity and Rayleigh–Ritz. In dynamics, the lower bound for the two-orbital simulator uses the quantum query polynomial and the exact parity readout. The Lean source links below every module diagram give the hypotheses and conclusions.

## Rebuilding

After building the main library and the [Kitaev integration](../../integrations/qatlib/), run these from the repository root.

```sh
python3 scripts/theorem_graph/generate.py
python3 scripts/theorem_graph/generate.py --project kitaev
```

Pass `--check` to either command to compare the committed graphs with the compiled proofs. The extractor obtains names, source ranges, and constant references from Lean and checks that each written theorem and lemma has a node. Its counts differ from an environment-wide axiom audit, which also sees compiler-generated theorem declarations.
