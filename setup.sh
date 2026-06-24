#!/usr/bin/env bash
#
# Entry point for setting up a machine.
#
# Idempotent: safe to run repeatedly. Each step checks the current state and
# only changes what needs changing.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- logging helpers (the step modules use these too) ---
info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*"; }

os="$(uname -s)"
info "Detected OS: $os"

case "$os" in
  Darwin)
    # shellcheck source=macos/brew.sh
    source "$REPO_DIR/macos/brew.sh"
    # shellcheck source=macos/defaults.sh
    source "$REPO_DIR/macos/defaults.sh"
    ;;
  Linux)
    warn "Linux setup is not implemented yet."
    ;;
  *)
    warn "Unsupported OS: $os"
    exit 1
    ;;
esac

ok "All done."
