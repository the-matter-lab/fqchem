"""Export freshly generated graphs and the committed explorer as one HTML file with revision-pinned source links."""

import base64
import json
from pathlib import Path
import subprocess
from urllib.parse import urljoin
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parents[2]
REPO = "the-matter-lab/fqchem"


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True)


def export():
    revision = git("rev-parse", "HEAD").strip()
    directory = "docs/theorems"
    base = f"https://github.com/{REPO}/blob/{revision}/{directory}/"

    def read(name):
        return git("show", f"{revision}:{directory}/{name}")

    html = read("index.html").replace('<meta charset="utf-8">',
        f'<meta charset="utf-8">\n  <meta name="fqchem-revision" content="{revision}">')
    font = subprocess.check_output(
        ["git", "show", f"{revision}:{directory}/fonts/stix-two-text-latin.woff2"], cwd=ROOT,
    )
    font_uri = "data:font/woff2;base64," + base64.b64encode(font).decode("ascii")
    css = read("atlas.css").replace("fonts/stix-two-text-latin.woff2", font_uri)
    html = html.replace('<link rel="stylesheet" href="atlas.css">',
                        f"<style>/* {read('fonts/OFL.txt')} */\n{css}</style>")
    html = html.replace('<script src="atlas.js"></script>', f"<script>{read('atlas.js')}</script>")
    literature = (ROOT / directory / "literature.js").read_text()
    tag = '<script src="literature.js"></script>'
    if html.count(tag) != 1:
        raise ValueError("Missing or duplicate literature script tag")
    html = html.replace(tag, f"<script>{literature}</script>")
    for name in ("library.js", "kitaev.js"):
        script = (ROOT / directory / name).read_text().strip()
        prefix = "addTheoremGraph("
        if not script.startswith(prefix) or not script.endswith(");"):
            raise ValueError(f"Unexpected graph format in {name}")
        nodes = json.loads(script[len(prefix):-2])
        for node in nodes:
            node["url"] = urljoin(base, node["url"])
        data = json.dumps(nodes, ensure_ascii=False, separators=(",", ":")).replace("<", r"\u003c")
        tag = f'<script src="{name}"></script>'
        if html.count(tag) != 1:
            raise ValueError(f"Missing or duplicate script tag for {name}")
        html = html.replace(tag, f"<script>addTheoremGraph({data});</script>")

    with urlopen(f"https://api.github.com/repos/{REPO}", timeout=15) as response:
        stars = json.load(response)["stargazers_count"]
    if type(stars) is not int or stars < 0:
        raise ValueError("Invalid GitHub star count")
    marker = '<span id="star-count"></span>'
    if html.count(marker) != 1:
        raise ValueError("Missing or duplicate repository star count")
    return html.replace(marker, f'<span id="star-count">{stars:,}</span>')


if __name__ == "__main__":
    print(export(), end="")
