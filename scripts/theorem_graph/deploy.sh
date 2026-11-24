#!/bin/bash
# Installed on Clawderon. launchd serializes invocations and retries after sleep.
set -euo pipefail
umask 077
export GIT_TERMINAL_PROMPT=0
repo=https://github.com/the-matter-lab/fqchem.git
state=/srv/services/fqchem-atlas
cd "$state"
ref=$(git ls-remote --heads "$repo" refs/heads/atlas)
[[ -n "$ref" ]] || exit 0
published=${ref%%[[:space:]]*}
if [[ -f last-publication && "$(cat last-publication)" == "$published" ]]; then exit 0; fi

# Read the HTML as data from a verified Git object. No checkout or build runs
# under the local account that has SSH access to the web host.
tmp=$(mktemp -d "$state/build.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
git init -q --bare "$tmp/git"
git --git-dir="$tmp/git" fetch -q --depth=1 "$repo" refs/heads/atlas
published=$(git --git-dir="$tmp/git" rev-parse FETCH_HEAD)
source_sha=$(git --git-dir="$tmp/git" cat-file -p "$published" | sed -n 's/^parent //p' | head -1)
[[ "$source_sha" =~ ^[0-9a-f]{40}$ ]]
git --git-dir="$tmp/git" show "$published:docs/theorems/index.html" > "$tmp/index.html"
grep -Fq "<meta name=\"fqchem-revision\" content=\"$source_sha\">" "$tmp/index.html"
digest=$(shasum -a 256 "$tmp/index.html" | cut -d' ' -f1)
target=https://fqchem.matterlab.ca/
ssh -o BatchMode=yes -o ConnectTimeout=10 -o ServerAliveInterval=15 -o ServerAliveCountMax=3 clawtilde "digest=$digest
$(cat <<'REMOTE'
set -eu
umask 077
state=/srv/services/matterlab-pages/fqchem-deploy
site=/srv/http/matterlab-pages/fqchem/index.html
mkdir -p "$state"
stage=$(mktemp "$state/index.XXXXXX")
trap 'rm -f "$stage"' EXIT
cat > "$stage"
actual=$(shasum -a 256 "$stage" | cut -d' ' -f1)
[ "$actual" = "$digest" ]
if ! cmp -s "$stage" "$site"; then
  if [ -f "$site" ]; then
    cp "$site" "$state/previous.tmp"
    mv -f "$state/previous.tmp" "$state/previous.html"
  fi
  chmod 644 "$stage"
  mv -f "$stage" "$site"
fi
curl -fsS --max-time 15 -H 'Host: fqchem.matterlab.ca' http://127.0.0.1:8808/ > "$stage"
actual=$(shasum -a 256 "$stage" | cut -d' ' -f1)
[ "$actual" = "$digest" ]
REMOTE
)" < "$tmp/index.html"

curl -fsS --compressed --max-time 30 --retry 2 "${target}?revision=$source_sha" > "$tmp/public.html"
cmp "$tmp/index.html" "$tmp/public.html"
printf '%s\n' "$published" > "$tmp/revision"
mv -f "$tmp/revision" last-publication
printf '%s deployed %s to %s (sha256 %s)\n' "$(date -u +%FT%TZ)" "$source_sha" "$target" "$digest"
