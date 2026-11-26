"""Check all compiled declarations, including private helpers and the adapted upstream port."""

import argparse
import json
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SITE = ROOT / "docs/theorems"
QATLIB = ROOT / "integrations/qatlib"


def sources(base, root):
    files = [base / (root + ".lean"), *sorted((base / root).rglob("*.lean"))]
    if not all(f.is_file() for f in files):
        raise ValueError(
            f"Missing sources for {root}. Build the project before auditing."
        )
    return {".".join(f.relative_to(base).with_suffix("").parts) for f in files}


def check(project, modules, legacy=False):
    # Legacy ForShor modules use ordinary imports. Modern Lean needs each private facet.
    names = sorted(modules)
    header = "" if legacy else "module\n"
    header += "".join(f"import {'' if legacy else 'all '}{m}\n" for m in names)
    meta = "" if legacy else "public meta "
    header += f"{meta}import Lean.Elab.Command\n{meta}import Lean.Util.CollectAxioms\n"
    header += (
        "private def auditModules : Array Lean.Name := #["
        + ", ".join("`" + m for m in names)
        + "]\n"
    )
    with tempfile.TemporaryDirectory() as temp:
        path = Path(temp) / "Audit.lean"
        path.write_text(
            header + Path(__file__).with_name("AuditAxioms.lean").read_text()
        )
        result = subprocess.run(
            ["lake", "env", "lean", str(path)],
            cwd=project,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
    rows = []
    for line in result.stdout.splitlines():
        if line.startswith("FQCHEM_AUDIT "):
            rows.append(json.loads(line.removeprefix("FQCHEM_AUDIT ")))
        else:
            print(line, flush=True)
    if result.returncode or sorted(r["module"] for r in rows) != names:
        raise SystemExit("The kernel audit did not pass for every source module.")
    return rows


def imported(project, root):
    output = subprocess.check_output(
        ["lake", "--json", "query", "+" + root + ":transImports"], cwd=project
    )
    return set(json.loads(output)) | {root}


def check_tracked_sources(project, modules):
    files = subprocess.check_output(["git", "ls-files", "-z", "--", "*.lean"], cwd=ROOT)
    covered = set()
    for module in modules:
        base = {
            "FQChem": ROOT,
            "FQChemForShor": ROOT / "integrations/forshor",
            "AaronsonAmbainisPort": ROOT
            / "integrations/aaronson-ambainis/.lake/ported",
        }.get(module.split(".")[0], project)
        covered.add(base.joinpath(*module.split(".")).with_suffix(".lean"))
    for raw in files.decode().split("\0"):
        if not raw:
            continue
        path = Path(raw)
        integration_test = path.parts[0] == "integrations" and path.parts[2:3] == (
            "test",
        )
        if (
            path.name == "lakefile.lean"
            or path.parts[0] in ("scripts", "test")
            or integration_test
        ):
            continue
        belongs_to_qatlib = path.parts[:2] == ("integrations", "qatlib")
        if belongs_to_qatlib == (project == QATLIB) and ROOT / path not in covered:
            raise SystemExit(f"Tracked Lean library source missing from audit: {path}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", choices=["library", "kitaev"], default="library")
    args = parser.parse_args()
    if args.project == "library":
        project = ROOT
        # The core imports Port.Main directly. Compile the standalone port entry point too.
        subprocess.run(
            ["lake", "build", "AaronsonAmbainisPort"],
            cwd=ROOT,
            check=True,
            stdout=subprocess.DEVNULL,
        )
        core = sources(ROOT, "FQChem")
        port = sources(
            ROOT / "integrations/aaronson-ambainis/.lake/ported", "AaronsonAmbainisPort"
        )
        bridge = sources(ROOT / "integrations/forshor", "FQChemForShor")
        roots = (
            imported(ROOT, "FQChem")
            | imported(ROOT, "FQChemForShor")
            | imported(ROOT, "AaronsonAmbainisPort")
        )
        groups = {
            "Core library": core,
            "ForShor integration": bridge,
            "Aaronson–Ambainis port": port,
        }
        passes = [(core | port, False), (bridge, True)]
    else:
        project = QATLIB
        roots = imported(QATLIB, "FQChemQatlib") | imported(QATLIB, "FQChemKitaev")
        shared = {m for m in roots if m.startswith("FQChem.")}
        groups = {
            "Qatlib integration": sources(QATLIB, "FQChemQatlib"),
            "Kitaev integration": sources(QATLIB, "FQChemKitaev"),
            "Shared core on Qatlib's toolchain": shared,
        }
        passes = [(set.union(*groups.values()), False)]
    owned = set.union(*groups.values())
    check_tracked_sources(project, owned)
    if missing := owned - roots:
        raise SystemExit(f"Library entry points do not import {sorted(missing)}")
    rows = [r for modules, legacy in passes for r in check(project, modules, legacy)]
    for row in rows:
        row["group"] = next(
            g for g, modules in groups.items() if row["module"] in modules
        )
    order = {group: i for i, group in enumerate(groups)}
    rows.sort(key=lambda row: (order[row["group"]], row["module"]))
    revision = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True
    ).strip()
    report = {
        "revision": revision,
        "toolchain": (project / "lean-toolchain").read_text().strip(),
        "modules": rows,
    }
    path = SITE / f"{args.project}-axioms.js"
    payload = json.dumps(report, ensure_ascii=False, separators=(",", ":"))
    path.write_text(f"addAxiomReport({payload});\n")
    print(
        f"{args.project}: checked {sum(r['declarations'] for r in rows)} declarations in {len(rows)} modules."
    )


if __name__ == "__main__":
    main()
