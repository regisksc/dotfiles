#!/usr/bin/env bash
# sync.sh — update repo with latest machine state
#
# Usage:
#   ./sync.sh              Backup + scan + prompt for commit
#   ./sync.sh --no-commit  Backup + scan only (skip git)
#   ./sync.sh --only CATEGORY  Sync only one category (e.g., --only ai)

set -Eeuo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_ROOT

# Load install.sh functions
source "${DOTFILES_ROOT}/install.sh" --no-op 2>/dev/null || true

# Parse args
NO_COMMIT=false
ONLY_CATEGORY=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-commit) NO_COMMIT=true; shift ;;
    --only)      ONLY_CATEGORY="$2"; export ONLY_CATEGORY; shift 2 ;;
    -h|--help)   _show_help; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

_show_help() {
  sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//g'
}

echo "=== Syncing machine state → repo ==="
echo

# Run backup + sync
./install.sh sync ${ONLY_CATEGORY:+--only "$ONLY_CATEGORY"}
echo

if [[ "$NO_COMMIT" == true ]]; then
  echo "Skipping git (--no-commit). Review: git diff"
  exit 0
fi

# Show diff and prompt for commit
echo "=== Changes detected ==="
git diff --stat
echo

read -r -p "Commit these changes? [y/N] " ans
if [[ ! "$ans" =~ ^[Yy]$ ]]; then
  echo "Skipped. Review: git diff"
  exit 0
fi

# Get commit message
read -r -p "Commit message (default: 'backup: sync machine state'): " msg
msg="${msg:-backup: sync machine state}"

git add -A
git commit -m "$msg"
git push

echo
echo "✓ Synced and pushed to origin"
