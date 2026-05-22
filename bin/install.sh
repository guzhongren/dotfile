#!/bin/bash
set -euo pipefail

# Thin wrapper — delegates to the staged install script.
# Kept for backward compatibility with raw URL bookmarks and CI.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "${REPO_ROOT}/scripts/install.sh" "$@"
