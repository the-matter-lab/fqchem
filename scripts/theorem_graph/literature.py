"""Join both compiled graphs to reviewed sources and publish the paper index."""

import json
from pathlib import Path
import re
import subprocess
from urllib.parse import quote, unquote, urlsplit

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "docs" / "theorems"
CATALOG = OUT / "catalog"
REVIEWS = CATALOG / "reviews"
SITE = "https://fqchem.matterlab.ca/"
RELATIONS = {
    "paper-result": "Paper result", "specialization": "Special case",
    "derived": "Derived result", "supporting": "Supporting lemma",
    "source-note": "Source cited in Lean · comparison pending",
}
CHAPTERS = {"Complexity", "StatePrep", "Dynamics", "Properties", "Multiscale"}


def read_json(path):
    return json.loads(path.read_text())


def source_key(url):
    parts = urlsplit(url)
    if parts.scheme != "https" or not parts.hostname or parts.username or parts.password:
        raise ValueError(f"Expected a public HTTPS source URL: {url}")
    if parts.hostname == "doi.org":
        return "https://doi.org" + unquote(parts.path).lower()
    return url


def compiled_nodes():
    nodes = {}
    for project in ("library", "kitaev"):
        text = (OUT / f"{project}.js").read_text().strip()
        if not text.startswith("addTheoremGraph(") or not text.endswith(");"):
            raise ValueError(f"Invalid {project} graph")
        for node in json.loads(text[len("addTheoremGraph("):-2]):
            nodes.setdefault((node["module"], node["name"]), node)
    return nodes


def declaration_note(node):
    """A new theorem can supply its own paper in its Lean docstring on the same push."""
    if node["external"]:
        return None
    path, line = node["url"].rsplit("#L", 1)
    prefix = "\n".join((OUT / path).read_text().splitlines()[:int(line)-1])
    doc = re.search(r"/--((?:(?!-/).)*)-/\s*(?:@\[[^\]]+\]\s*)*$", prefix, re.S)
    if doc:
        # Markdown citation labels provide a useful title even for a new DOI.
        return re.findall(r"\[([^\]\n]+)\]\((https://(?:doi\.org|arxiv\.org/abs)/[^\s]+?)\)(?=[.,;\s]|$)", doc[1])
    return None


def assemble():
    nodes = compiled_nodes()
    papers = {}
    for url, record in read_json(CATALOG / "papers.json").items():
        key = source_key(url)
        if key in papers or not record.get("title") or not record.get("authors"):
            raise ValueError(f"Duplicate or incomplete bibliography entry: {url}")
        papers[key] = {**record, "url": url}

    def paper_ids(urls):
        refs = [source_key(url) for url in urls]
        if not refs or len(set(refs)) != len(refs) or any(p not in papers for p in refs):
            raise ValueError(f"Missing or duplicate bibliography reference: {urls}")
        return refs

    def validate_related(names, subject):
        for name in names:
            if sum(decl == name for _, decl in nodes) != 1:
                raise ValueError(f"Unknown or ambiguous checked result in {subject}: {name}")

    groups, assigned, aliases = [], {}, {}
    for path in sorted(REVIEWS.glob("*.json")):
        for entry in read_json(path):
            module = entry["module"]
            group = {k: entry[k] for k in ("scope", "relation")}
            if not group["scope"].strip() or group["relation"] not in RELATIONS:
                raise ValueError(f"Invalid review for {module} in {path}")
            group["papers"] = paper_ids(entry["papers"])
            if entry.get("related"):
                validate_related(entry["related"], module)
                group["related"] = entry["related"]
            for short in entry["names"]:
                hits = [key for key in nodes if key[0] == module and
                        (key[1] == short or key[1].rsplit(".", 1)[-1] == short)]
                if len(hits) != 1 or hits[0] in assigned:
                    raise ValueError(f"Stale, ambiguous or duplicate review: {module}/{short}")
                assigned[hits[0]] = len(groups)
            for alias, name in entry.get("aliases", {}).items():
                if (not re.fullmatch(r"paper/[a-z0-9-]+", alias) or alias in aliases
                        or assigned.get((module, name)) != len(groups)):
                    raise ValueError(f"Invalid resolved literature target {alias} in {module}")
                aliases[alias] = f"{module}/{name}"
            groups.append(group)

    for key in sorted(nodes.keys() - assigned.keys()):
        citations = declaration_note(nodes[key])
        if not citations:
            raise ValueError(f"Missing original source for {key}. Cite a DOI or arXiv paper in the "
                             "Lean theorem docstring or add a reviewed catalog entry.")
        refs = []
        for label, url in citations:
            pid = source_key(url)
            papers.setdefault(pid, {"title": label, "authors": "", "url": url})
            if pid not in refs:
                refs.append(pid)
        assigned[key] = len(groups)
        groups.append({"papers": refs, "relation": "source-note",
                       "scope": "This declaration cites the paper in its Lean docstring. Its correspondence to the published result awaits review."})

    targets = read_json(CATALOG / "targets.json")
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    seen = set()
    for target in targets:
        identifier = target["id"]
        if (not re.fullmatch(r"[a-z0-9-]+", identifier) or identifier in seen or "paper/"+identifier in aliases
                or target["status"] not in {"published", "hypothesis"}
                or target["chapter"] not in CHAPTERS or not target["scope"] or not target["locator"]):
            raise ValueError(f"Invalid literature target: {identifier}")
        target["papers"] = paper_ids(target["papers"])
        validate_related(target["related"], identifier)
        if statement := target.get("statement"):
            if target["status"] != "hypothesis" or not re.fullmatch(
                    r"FQChem\.Unproven(?:\.[A-Za-z_]\w*){2,}", statement):
                raise ValueError(f"Invalid conjecture name for {identifier}: {statement}")
            *module, name = statement.split(".")
            path = Path(*module).with_suffix(".lean")
            lines = (ROOT / path).read_text().splitlines()
            hits = [i for i, line in enumerate(lines, 1) if re.match(rf"^def {name}\b", line)]
            if len(hits) != 1:
                raise ValueError(f"Missing or ambiguous conjecture definition: {statement}")
            target["statementUrl"] = f"https://github.com/the-matter-lab/fqchem/blob/{revision}/{path}#L{hits[0]}"
        for ref in target.get("upstream", []):
            if not ref["label"].strip() or not re.fullmatch(
                    r"https://github\.com/[\w.-]+/[\w.-]+/blob/[0-9a-f]{40}/[^\s]+\.lean#L\d+(?:-L\d+)?", ref["url"]):
                raise ValueError(f"Unpinned Lean reference in {identifier}: {ref}")
        seen.add(identifier)
    used = {p for entry in [*groups, *targets] for p in entry["papers"]}
    if used != papers.keys():
        raise ValueError(f"Unreferenced papers: {papers.keys() - used}")
    return {
        "papers": papers, "groups": groups, "relations": RELATIONS,
        "byNode": {f"{m}/{n}": i for (m, n), i in sorted(assigned.items())},
        "targets": targets, "aliases": aliases,
    }


def markdown(data):
    published = sum(t["status"] == "published" for t in data["targets"])
    hypotheses = sum(t["status"] == "hypothesis" for t in data["targets"])
    lines = ["# Papers and theorem statements", "",
             f"{len(data['papers'])} distinct primary references · {len(data['byNode'])} Lean declarations · "
             f"{published} published results with incomplete formalizations · {hypotheses} literature {'hypothesis' if hypotheses == 1 else 'hypotheses'}.", "",
             "[Interactive theorem atlas](https://fqchem.matterlab.ca/) · "
             "[Review selection and coverage](https://github.com/the-matter-lab/fqchem/blob/main/docs/theorems/Surveys.md)", ""]
    for pid, paper in sorted(data["papers"].items(), key=lambda i: (i[1]["authors"], i[1]["title"])):
        title = paper["title"]
        url = paper["url"].replace("(", "%28").replace(")", "%29")
        lines += [f"## {paper['authors']} · [{title}]({url})", ""]
        for i, group in enumerate(data["groups"]):
            if pid in group["papers"]:
                links = []
                for key, idx in data["byNode"].items():
                    if idx == i:
                        name = key.split("/", 1)[1].rsplit(".", 1)[-1]
                        links.append(f"[{name}]({SITE}#{quote(key, safe='./')})")
                lines.append(f"- **{RELATIONS[group['relation']]}**. {group['scope']} {' · '.join(links)}")
                if group.get("related"):
                    related = [f"[{name.rsplit('.', 1)[-1]}]({SITE}#{quote(name)})" for name in group["related"]]
                    lines.append(f"  - **Related checked results**. {' · '.join(related)}")
        for target in data["targets"]:
            if pid in target["papers"]:
                status = "Proof in the literature" if target["status"] == "published" else "Literature hypothesis"
                lines.append(f"- **{status} · needs Lean proof**. [{target['title']}]({SITE}#paper/{target['id']}). "
                             f"{target['locator']}. {target['scope']}")
                if target.get("statementUrl"):
                    lines.append(f"  - [Formal statement in Lean]({target['statementUrl']})")
                if target.get("remaining"):
                    lines.append(f"  - **Remaining Lean proof**. {target['remaining']}")
                for ref in target.get("upstream", []):
                    lines.append(f"  - [{ref['label']}]({ref['url']})")
        lines.append("")
    return "\n".join(lines)


def main():
    data = assemble()
    js = json.dumps(data, ensure_ascii=False, separators=(",", ":")).replace("<", r"\u003c")
    (OUT / "literature.js").write_text(f"const atlasLiterature = {js};\n")
    (OUT / "papers.md").write_text(markdown(data))
    print(f"Linked {len(data['byNode'])} checked declarations and {len(data['targets'])} literature "
          f"targets to {len(data['papers'])} distinct original references.")


if __name__ == "__main__":
    main()
