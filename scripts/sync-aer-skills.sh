#!/usr/bin/env bash
# sync-aer-skills.sh
#
# Mirror the upstream AER-skills repository
# (brycewang-stanford/AER-skills) into the local vendored copy at
# skills/50-brycewang-aer-skills/, then report whether anything changed.
#
# Why a clone-and-rsync vendor instead of a git submodule:
#   AER-skills is a plugin repo with nested .claude-plugin/, skills/, docs/,
#   examples/, templates/. A submodule mounts the whole repo under a single
#   path and breaks the flat skills/NN-* discovery convention used elsewhere
#   in this repository. Vendoring keeps skills/50-brycewang-aer-skills/ as a
#   first-class peer of skills/00-*, skills/01-*, etc.
#
# Exit codes:
#   0 — no drift (local already matches upstream)
#   1 — drift applied (local was updated; caller should commit/PR)
#   2 — fetch error (network / git failure)

set -euo pipefail

UPSTREAM_REPO="https://github.com/brycewang-stanford/AER-skills.git"
LOCAL_DIR="skills/50-brycewang-aer-skills"

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

if [[ ! -d "$LOCAL_DIR" ]]; then
  echo "ERROR: $LOCAL_DIR not found (run from repo root)" >&2
  exit 2
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "ERROR: rsync required" >&2
  exit 2
fi

tmpdir="$(mktemp -d -t aer-skills-sync-XXXXXX)"
trap 'rm -rf "$tmpdir"' EXIT

if ! git clone --depth=1 --quiet "$UPSTREAM_REPO" "$tmpdir/AER-skills"; then
  echo "ERROR: failed to clone $UPSTREAM_REPO" >&2
  exit 2
fi

upstream_sha="$(git -C "$tmpdir/AER-skills" rev-parse HEAD)"

# Compute a content hash of the local mirror BEFORE rsync, to detect drift.
local_hash_before="$(find "$LOCAL_DIR" -type f \( ! -name '.DS_Store' \) -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 git hash-object \
  | git hash-object --stdin)"

rsync -a --delete \
  --exclude='.git' \
  --exclude='.gitignore' \
  --exclude='.DS_Store' \
  "$tmpdir/AER-skills/" "$LOCAL_DIR/"

local_hash_after="$(find "$LOCAL_DIR" -type f \( ! -name '.DS_Store' \) -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 git hash-object \
  | git hash-object --stdin)"

if [[ "$local_hash_before" == "$local_hash_after" ]]; then
  echo "[ok ] AER-skills in sync (upstream $upstream_sha)"
  exit 0
fi

echo "[upd] AER-skills updated to upstream $upstream_sha"
exit 1
