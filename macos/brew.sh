#!/usr/bin/env bash
#
# Homebrew: install brew itself if missing, then apply the Brewfile.
# Sourced by ../setup.sh, but also runnable on its own. Idempotent.

set -euo pipefail

# Allow running this module standalone (falls back to plain echo for the helpers).
type info >/dev/null 2>&1 || info() { printf '==> %s\n' "$*"; }
type ok   >/dev/null 2>&1 || ok()   { printf '  + %s\n' "$*"; }
type warn >/dev/null 2>&1 || warn() { printf '  ! %s\n' "$*"; }

# Repo root, resolved whether this file is sourced or executed directly.
BREW_REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Install Homebrew if it isn't there, then put it on PATH for the rest of this run.
# Official command, from https://brew.sh (re-check it there periodically).
ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    ok "Homebrew already installed"
  else
    info "Installing Homebrew (first run is interactive: may ask for sudo + RETURN)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Make brew available on PATH for the remainder of this script.
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"       # Intel
  fi
}

# Install everything listed in the Brewfile. `brew bundle` is idempotent: it skips
# anything already installed.
apply_brewfile() {
  local brewfile="$BREW_REPO_DIR/Brewfile"
  if [ ! -f "$brewfile" ]; then
    warn "No Brewfile at $brewfile, skipping"
    return
  fi
  info "Applying Brewfile"
  brew bundle --file="$brewfile"
  ok "Brewfile applied"
}

info "Homebrew: ensuring brew + packages"
ensure_homebrew
apply_brewfile
