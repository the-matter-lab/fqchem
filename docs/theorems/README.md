# Theorem dependencies

Open [the theorem atlas](https://fqchem.matterlab.ca/) to see the complete directed graph. Each point is a declaration, including isolated results and imported prerequisites. Click a point or search by theorem or method to highlight its incoming and outgoing arrows. Zoom in to see names, select a chapter to focus the map, or share the address of a selected theorem. For example, explore the [VMC variational bound](https://fqchem.matterlab.ca/#FQChem.StatePrep.VariationalOptimization.VariationalMonteCarlo.variationalBound).

For offline use, open [index.html](index.html) from a checkout with its adjacent scripts, stylesheet and font.

- [fqchem theorem graphs by module](library.md)
- [Kitaev integration theorem graphs by module](kitaev.md)
- [Scope and references for the complexity results](../../FQChem/Complexity/README.md)

## Reading the graph

Position groups results by library chapter, with imported prerequisites in their own group. Orange marks classical computing methods, blue marks quantum computing methods, and sage marks general theory. These are editorial method-family labels. For example, VMC is classical, VQE is quantum, and the Rayleigh–Ritz principle they share is general. The inspector gives the family in text. Node size increases with the number of directly displayed dependents.

An arrow A → B means that Lean's elaborated statement or proof of B uses A. A solid edge is a direct constant reference. A dashed edge passes through local definitions or compiler-generated helpers before reaching A. Each path stops at its first source theorem. Private source lemmas and theorems with no edges are included. A module import or a shared scientific topic creates no edge. Core Lean and Mathlib are outside the graph, and imported Aaronson–Ambainis and Qatlib theorems used at the boundary link to their pinned sources.

For example, VMC’s variational bound uses both the Born-average identity and Rayleigh–Ritz. In dynamics, the lower bound for the two-orbital simulator uses the quantum query polynomial and the exact parity readout. The Lean source links below every module diagram give the hypotheses and conclusions.

## Rebuilding

After building the main library and the [Kitaev integration](../../integrations/qatlib/), run these from the repository root.

```sh
python3 scripts/theorem_graph/generate.py
python3 scripts/theorem_graph/generate.py --project kitaev
```

Pass `--check` to either command to compare the committed graphs with the compiled proofs. The extractor obtains names, source ranges, and constant references from Lean and checks that each written theorem and lemma has a node. Its counts differ from an environment-wide axiom audit, which also sees compiler-generated theorem declarations.

To publish an update after committing the regenerated graphs, run `python3 scripts/theorem_graph/export_site.py > /tmp/fqchem-index.html` from the repository and deploy the resulting file as the site's `index.html`. It includes both graphs and links each local declaration to its line at the exported Git revision.
