"""Prepare the upstream proof sources for Lean 4.36's module system."""
from pathlib import Path
import re
import subprocess
import sys
import tempfile


def write_changed(path: Path, content: str) -> None:
    if path.is_file() and path.read_text() == content:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as file:
        file.write(content)
    Path(file.name).replace(path)


def prepare(upstream: Path, destination: Path) -> None:
    imports = re.compile(r"^import ((?:AaronsonAmbainis|Mathlib)(?:\.[\w.]+)?)[ \t]*\n?$", re.M)
    sources = {}

    def collect(module: str) -> None:
        if module in sources:
            return
        path = Path(*module.split(".")).with_suffix(".lean")
        source = (upstream / path).read_text()
        sources[module] = path
        for imported in imports.findall(source):
            if imported.startswith("AaronsonAmbainis."):
                collect(imported)

    collect("AaronsonAmbainis.Main")
    top = destination / "AaronsonAmbainisPort.lean"
    root_text = "module\n\npublic import AaronsonAmbainisPort.Main\n"
    write_changed(top, root_text)
    patch = Path(__file__).with_name("lean-4.36.patch").resolve()
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        for path in sources.values():
            (work / path).parent.mkdir(parents=True, exist_ok=True)
            (work / path).write_bytes((upstream / path).read_bytes())
        subprocess.run(["git", "apply", str(patch)], cwd=work, check=True)
        for path in sources.values():
            text = (work / path).read_text()
            # Only the module headers change mechanically. The theorem names stay intact.
            lines = text.splitlines(keepends=True)
            last_import = max(i for i, line in enumerate(lines) if imports.fullmatch(line))
            for index in range(last_import + 1):
                if imports.fullmatch(lines[index]):
                    lines[index] = lines[index].replace("import ", "public import ", 1).replace(
                        "import AaronsonAmbainis.", "import AaronsonAmbainisPort."
                    )
            notice = (
                f"-- Generated from {path.as_posix()}, copyright 2026 David Turturean (Apache-2.0).\n"
                "-- FormalQChem adapted this file for Lean 4.36. See lean-4.36.patch and NOTICE.\n"
            )
            content = notice + "module\n\n" + "".join(lines[:last_import + 1])
            content += "\n@[expose] public section\n" + "".join(lines[last_import + 1:])
            out = destination / "AaronsonAmbainisPort" / path.relative_to("AaronsonAmbainis")
            write_changed(out, content)


if __name__ == "__main__":
    prepare(Path(sys.argv[1]), Path(sys.argv[2]))
