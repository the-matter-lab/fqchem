# Theorem dependencies

Open [the theorem atlas](https://fqchem.matterlab.ca/) to see the complete directed graph. Colored points include checked declarations, isolated results and imported prerequisites. Red points are sourced literature results awaiting a Lean proof. Click a point or search by theorem or method to highlight its incoming and outgoing arrows. Zoom in to see names, select a chapter to see its results and their immediate neighbors in other chapters, or share the address of a selected theorem. For example, explore the [VMC variational bound](https://fqchem.matterlab.ca/#FQChem.StatePrep.VariationalOptimization.VariationalMonteCarlo.variationalBound).

For offline use, download the [standalone atlas](https://raw.githubusercontent.com/the-matter-lab/fqchem/atlas/docs/theorems/index.html) and open it in a browser.

- [fqchem theorem graphs by module](https://github.com/the-matter-lab/fqchem/blob/atlas/docs/theorems/library.md)
- [Qatlib integration theorem graphs by module](https://github.com/the-matter-lab/fqchem/blob/atlas/docs/theorems/kitaev.md)
- [Scope and references for the complexity results](../../FQChem/Complexity/README.md)

## Papers and outstanding proofs

The [paper index](https://github.com/the-matter-lab/fqchem/blob/atlas/docs/theorems/papers.md) lists each original reference once. Select any result to read its scope, see its source, and follow the paper link. The inspector distinguishes an original result, a specialization, a derived consequence and a supporting lemma. A supporting lemma can have been written specifically for the Lean proof. Its citation identifies the construction it supports.

Select [Needs proof](https://fqchem.matterlab.ca/#needs-proof) for the red nodes. Each identifies either a result proved in the cited paper or a hypothesis proposed there, with the paper locator and assumptions. The [unproven collection](../../FQChem/Unproven/) defines conjectures as Lean propositions. A red node links to its formal statement when one is available. Related checked steps have their own inspector links. Pinned links under “Existing Lean work” record the scope of relevant outside proofs. A literature target that acquires a checked theorem can keep its shared URL as an alias for that declaration. Dependency arrows are reserved for references that Lean extracted from checked declarations. The [review survey](Surveys.md) records how the literature was selected.

## Reading the graph

Position groups results by library chapter, with imported prerequisites in their own group. Orange marks classical computing methods, blue marks quantum computing methods, and sage marks general theory. These are editorial method-family labels. For example, VMC is classical, VQE is quantum, and the Rayleigh–Ritz principle they share is general. The inspector gives the family in text. Node size increases with the number of directly displayed dependents.

An arrow A → B means that Lean's elaborated statement or proof of B uses A. A solid edge is a direct constant reference. A dashed edge passes through local definitions or compiler-generated helpers before reaching A. Each path stops at its first source theorem. Private source lemmas and theorems with no edges are included. A module import or a shared scientific topic creates no edge. Core Lean and Mathlib are outside the graph, and imported Aaronson–Ambainis and Qatlib theorems used at the boundary link to their pinned sources.

For example, VMC’s variational bound uses both the Born-average identity and Rayleigh–Ritz. In dynamics, the lower bound for the two-orbital simulator uses the quantum query polynomial and the exact parity readout. The Lean source links below every module diagram give the hypotheses and conclusions.

## Rebuilding

Build and audit the main library from the repository root.

```sh
lake exe cache get
lake build
lake env lean test/Audit.lean
```

To regenerate the atlas, build the [Qatlib integration](../../integrations/qatlib/), then run these from the repository root.

```sh
python3 scripts/theorem_graph/generate.py
python3 scripts/theorem_graph/generate.py --project kitaev
python3 scripts/theorem_graph/literature.py
```

Pass `--check` to either extraction command to check previously generated files against the compiled proofs. The extractor obtains names, source ranges, and constant references from Lean and checks that each written theorem and lemma has a node. Its counts differ from an environment-wide axiom audit, which also sees compiler-generated theorem declarations.

Open `docs/theorems/index.html` after extraction to browse locally. To export a single HTML file, run `python3 scripts/theorem_graph/export_site.py > /tmp/fqchem-index.html` in a clean source checkout after generating both graphs. Source links are pinned to the checkout’s revision.

## Publication

Every push to `main` triggers both Lean builds, axiom audits and dependency extractions. After both pass, the [Lean workflow](../../.github/workflows/lean.yml) publishes the generated module diagrams, graph data and standalone HTML to the [atlas branch](https://github.com/the-matter-lab/fqchem/tree/atlas/docs/theorems). Its first parent is the exact source revision. Paper attribution is validated against the compiled graph. For a new theorem, an original DOI or arXiv citation of the form `[paper title](https://doi.org/...)` in its Lean docstring supplies a source on that same push. Until the scope is reviewed the inspector labels it “Source cited in Lean · comparison pending.” Reviewed mappings live in [the statement audits](catalog/reviews/) and publication references and open claims live in [the bibliography](catalog/). Authors can add a theorem and push its Lean source without generating or committing graph files.

The Clawderon launch agent checks the publication branch every minute and on login. It sends each new verified site to the Clawtilde Mac Mini over SSH, checks its checksum at the origin and over public HTTPS, and records the deployed revision. If the laptop is offline, it catches up to the latest published graph when it reconnects. A failed proof build leaves the last published graph online. See the [deployment worker](../../scripts/theorem_graph/deploy.sh).

## Axiom audit

Open [Axioms and assumptions](https://fqchem.matterlab.ca/#axioms) for the current findings, the Born-rule example and the scope of both builds. The audit enumerates declarations by the module that defined them, including private declarations and definitions. It rejects a local axiom even when nothing uses it. Lean’s `collectAxioms` checks transitive dependencies against `propext`, `Classical.choice` and `Quot.sound`; this also rejects a dependency on `sorryAx`. Each dependency is checked as far as it is used by an audited declaration. The locally adapted Aaronson–Ambainis port is also checked in full.

After building both projects, run these commands from the repository root. They write the two coverage reports used by the explorer. CI runs the audits before publishing the atlas.

```sh
python3 scripts/theorem_graph/audit_axioms.py
python3 scripts/theorem_graph/audit_axioms.py --project kitaev
```
