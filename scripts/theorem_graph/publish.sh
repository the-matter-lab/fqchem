#!/usr/bin/env bash
# Run in the Actions checkout after both audited graph artifacts arrive.
set -eu
out=docs/theorems
python3 scripts/theorem_graph/export_site.py > "$RUNNER_TEMP/fqchem.html"
mv "$RUNNER_TEMP/fqchem.html" "$out/index.html"
git add -f "$out/index.html" "$out"/{library,kitaev}.{js,md}

# Keep the source snapshot as first parent and fast-forward the publication
# branch. The source branch and its history belong to library contributors.
parents=(-p "$GITHUB_SHA")
previous=$(git ls-remote --heads origin refs/heads/atlas)
if [[ -n "$previous" ]]; then
  git fetch --depth=1 origin refs/heads/atlas
  parents+=(-p "$(git rev-parse FETCH_HEAD)")
fi
main=$(git ls-remote --exit-code origin refs/heads/main)
if [[ "${main%%[[:space:]]*}" != "$GITHUB_SHA" ]]; then
  echo "A newer main revision is queued."
  exit 0
fi
git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
publication=$(git commit-tree "$(git write-tree)" "${parents[@]}" -m "Publish theorem atlas for $GITHUB_SHA")
git push origin "$publication:refs/heads/atlas"
