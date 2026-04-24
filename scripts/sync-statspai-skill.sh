#!/usr/bin/env bash
# sync-statspai-skill.sh
#
# Pull SKILL.md and README.md from the upstream StatsPAI repository
# (brycewang-stanford/StatsPAI:StatsPAI_skill/) into the local mirror at
# skills/00-StatsPAI_skill/, then report whether anything changed.
#
# Why a script instead of a git submodule:
#   git submodule operates at whole-repo granularity and cannot mount a
#   subdirectory. A sparse-checkout submodule would also place SKILL.md at
#   skills/00-StatsPAI_skill/StatsPAI_skill/SKILL.md, breaking the skill
#   auto-discovery path. This script mirrors the upstream subtree byte-for-byte
#   and is invoked weekly by .github/workflows/sync-statspai-skill.yml.
#
# Exit codes:
#   0 — no drift (local already matches upstream)
#   1 — drift applied (local was updated; caller should commit/PR)
#   2 — fetch error (network / API failure)

set -euo pipefail

UPSTREAM_REPO="brycewang-stanford/StatsPAI"
UPSTREAM_PATH="StatsPAI_skill"
LOCAL_DIR="skills/00-StatsPAI_skill"
FILES=("SKILL.md" "README.md")

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

if [[ ! -d "$LOCAL_DIR" ]]; then
  echo "ERROR: $LOCAL_DIR not found (run from repo root)" >&2
  exit 2
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh CLI required (https://cli.github.com)" >&2
  exit 2
fi

drift=0
for f in "${FILES[@]}"; do
  remote_sha=$(gh api "repos/${UPSTREAM_REPO}/contents/${UPSTREAM_PATH}/${f}" --jq .sha 2>/dev/null) || {
    echo "ERROR: failed to fetch ${UPSTREAM_REPO}:${UPSTREAM_PATH}/${f}" >&2
    exit 2
  }
  local_path="${LOCAL_DIR}/${f}"
  local_sha=""
  [[ -f "$local_path" ]] && local_sha=$(git hash-object "$local_path")

  if [[ "$local_sha" == "$remote_sha" ]]; then
    echo "[ok ] ${f}  in sync ($remote_sha)"
    continue
  fi

  url=$(gh api "repos/${UPSTREAM_REPO}/contents/${UPSTREAM_PATH}/${f}" --jq .download_url)
  curl -sfL "$url" -o "${local_path}.new"
  mv "${local_path}.new" "$local_path"
  echo "[upd] ${f}  ${local_sha:-<absent>} -> ${remote_sha}"
  drift=1
done

exit $drift
