"""Rebuild the theorem dependency explorer from Lean's compiled declarations."""

import argparse
import json
from collections import Counter, defaultdict
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
DEST = ROOT / "docs" / "theorems"
PROJECTS = {
    "library": (ROOT, "FQChem"),
    "kitaev": (ROOT / "integrations" / "qatlib", "FQChemKitaev"),
}
DECLARATION = re.compile(
    r"^\s*(?:@\[[^\]]+\]\s*)*(?:(?:private|public|protected|nonrec|noncomputable)\s+)*"
    r"(?:theorem|lemma)\s+([\w.']+)"
)


def module_file(module):
    return Path(*module.split(".")).with_suffix(".lean")


def extract(project, modules):
    imports = "".join(f"import all {name}\n" for name in modules)
    extractor = Path(__file__).with_name("Extract.lean").read_text()
    with tempfile.TemporaryDirectory() as temp:
        source = Path(temp) / "ExtractGraph.lean"
        source.write_text("module\n" + imports + extractor)
        output = subprocess.run(
            ["lake", "env", "lean", str(source)], cwd=project, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False,
        )
    rows = {}
    for line in output.stdout.splitlines():
        if line.startswith('{"'):
            row = json.loads(line)
            rows[row["id"]] = row
        else:
            print(line, file=sys.stderr)
    if output.returncode or not rows:
        raise SystemExit("Lean extraction failed. Build the project before extracting its graph.")
    return rows


def upstream_link(project, row):
    module = row["module"]
    package = module.split(".")[0]
    if package == "AaronsonAmbainisPort":
        package = "AaronsonAmbainis"
        module = module.replace("AaronsonAmbainisPort.", "AaronsonAmbainis.", 1)
    origin = project / ".lake" / "packages" / package / module_file(module)
    # Check the pinned source. Public .olean facets can expose a theorem as an
    # axiom, generated equation lemmas have no source, and port headers shift lines.
    candidates = [i for i, line in enumerate(origin.read_text().splitlines(), 1)
                  if (m := DECLARATION.match(line)) and row["name"].endswith("." + m[1])]
    if not candidates:
        return None
    number = row["line"] if row["line"] in candidates else candidates[0] if len(candidates) == 1 else None
    manifest = json.loads((project / "lake-manifest.json").read_text())
    for entry in manifest["packages"]:
        if entry["name"].lower().replace("-", "") == package.lower():
            url = f'{entry["url"].removesuffix(".git")}/blob/{entry["rev"]}/{module_file(module)}'
            return url + (f"#L{number}" if number else "")
    raise ValueError(f"No pinned source for {module}")


def select_theorems(rows, sources, project):
    """Use Lean's source ranges, then verify coverage against the written declarations."""
    locations = {}
    scanned = dict(sources)
    if project != ROOT:
        # Source modules shared across Lake toolchains refer to one scientific result.
        for row in rows.values():
            module = row["module"]
            path = ROOT / module_file(module)
            if module.startswith("FQChem.") and path.is_file():
                scanned[module] = path
    for module, path in scanned.items():
        for number, line in enumerate(path.read_text().splitlines(), start=1):
            match = DECLARATION.match(line)
            if match:
                locations[module, number] = match[1]
    nodes = {}
    found = set()
    for key, row in rows.items():
        if not row["theorem"]:
            continue
        module, number = row["module"], row["line"]
        where = module, number
        external = row.get("external", False)
        if external:
            link = upstream_link(project, row)
            if link is None:
                continue
        elif where in locations and row["name"].endswith("." + locations[where]):
            link = Path(os.path.relpath(scanned[module], DEST)).as_posix() + f"#L{number}"
            found.add(where)
        else:
            continue
        nodes[key] = {
            "name": row["name"], "module": module, "url": link,
            "private": key.startswith("_private."), "external": external,
        }
        if module in scanned and module not in sources:
            nodes[key]["shared"] = True
    missing = sorted(where for where in locations if where[0] in sources and where not in found)
    if missing:
        raise SystemExit(f"Missing source theorems in compiled declarations: {missing}")
    return nodes


def project_dependencies(key, rows, boundary):
    """Stop each reference chain at its first named theorem, collapsing local helpers."""
    immediate = set(rows[key]["refs"])
    stack = list(immediate)
    visited = {key}
    result = {}
    while stack:
        other = stack.pop()
        if other in visited:
            continue
        visited.add(other)
        if other in boundary:
            result[other] = "direct" if other in immediate else "via"
        else:
            stack.extend(rows[other]["refs"])
    return result


def graph(rows, nodes):
    # External nodes belong in the graph when reached from an authored local theorem.
    edges = {key: project_dependencies(key, rows, nodes) for key in nodes if not nodes[key]["external"] and not nodes[key].get("shared")}
    included = set(edges).union(*(set(v) for v in edges.values()))
    ordered = sorted(included, key=lambda k: (nodes[k]["module"], nodes[k]["name"], k))
    ids = {key: i for i, key in enumerate(ordered)}
    return [
        dict(nodes[k], deps=sorted([ids[target], kind] for target, kind in edges.get(k, {}).items()))
        for k in ordered
    ]


def markdown(nodes, title):
    """One GitHub-renderable diagram per source module, including isolated nodes."""
    modules = defaultdict(list)
    for i, n in enumerate(nodes):
        if not n["external"] and not n.get("shared"):
            modules[n["module"]].append(i)
    counts = Counter("upstream" if n["external"] else "shared" if n.get("shared") else "project" for n in nodes)
    edges = sum(len(n["deps"]) for n in nodes)
    lines = [
        f"# {title} theorem graph", "",
        f'{counts["project"]} source theorems and lemmas · {counts["shared"]} shared library prerequisites · {counts["upstream"]} upstream theorem nodes · {edges} dependency edges.',
        "", "Arrows point from prerequisite to result. Dashed arrows pass through local definitions or "
        "compiler-generated helpers. Each diagram includes the prerequisites used by its module. "
        "The links below each diagram open the Lean declarations.", "",
        "[Graph guide and interactive explorer](README.md)", "",
    ]
    for module, members in sorted(modules.items()):
        lines.extend([f"## {module}", "", "```mermaid", "flowchart LR"])
        visible = set(members) | {j for i in members for j, _ in nodes[i]["deps"]}
        def label(i):
            n = nodes[i]
            short = n["name"].split(".")[-1]
            return f'{n["module"].split(".")[-1]}.{short}' if i not in members else short
        for i in sorted(visible):
            lines.append(f'  n{i}["{label(i)}"]')
        for i in members:
            for j, kind in nodes[i]["deps"]:
                lines.append(f"  n{j} {'-->' if kind == 'direct' else '-.->'} n{i}")
        lines += ["```", ""]
        lines.extend(f'- [{label(i)}]({nodes[i]["url"]})' + (" (private)" if nodes[i]["private"] else "")
                     for i in sorted(visible))
        lines.append("")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", choices=PROJECTS, default="library")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    project, prefix = PROJECTS[args.project]
    paths = [project / (prefix + ".lean"), *sorted((project / prefix).rglob("*.lean"))]
    sources = {".".join(p.relative_to(project).with_suffix("").parts): p for p in paths}
    imports = list(sources)
    if project != ROOT:
        # Load the private facets for shared modules as well. In particular this
        # preserves their source theorem identities on the older toolchain.
        deps = subprocess.check_output(
            ["lake", "--json", "query", f"+{prefix}:transImports"], cwd=project, text=True,
        )
        imports.extend(m for m in json.loads(deps) if m.startswith("FQChem."))
    imports = sorted(set(imports))
    rows = extract(project, imports)
    nodes = graph(rows, select_theorems(rows, sources, project))
    data = json.dumps(nodes, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    outputs = {
        f"{args.project}.js": f"addTheoremGraph({data});\n",
        f"{args.project}.md": markdown(nodes, "fqchem" if args.project == "library" else "Kitaev integration"),
    }
    for name, content in outputs.items():
        path = DEST / name
        if args.check:
            if not path.exists() or path.read_text() != content:
                raise SystemExit(f"Stale {path.relative_to(ROOT)}. Run {Path(__file__).name} --project {args.project}.")
        else:
            path.write_text(content)
    print(f'{args.project}: {len(nodes)} nodes, {sum(len(n["deps"]) for n in nodes)} edges')


if __name__ == "__main__":
    main()
