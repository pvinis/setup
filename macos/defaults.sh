#!/usr/bin/env bash
#
# macOS preferences. Sourced by ../setup.sh, but also runnable on its own.
# Every function is idempotent.

set -euo pipefail

# Allow running this module standalone (falls back to plain echo for the helpers).
type info >/dev/null 2>&1 || info() { printf '==> %s\n' "$*"; }
type ok   >/dev/null 2>&1 || ok()   { printf '  + %s\n' "$*"; }
type warn >/dev/null 2>&1 || warn() { printf '  ! %s\n' "$*"; }

# Pointer size. macOS default is 1.0, which is a bit small for me; I like it at 1.5.
# System Settings > Accessibility > Display > Pointer > Pointer size.
# Key range is roughly 1.0 (normal) .. 4.0 (large).
macos_cursor_size() {
  local desired="1.5"
  local current
  current="$(defaults read com.apple.universalaccess mouseDriverCursorSize 2>/dev/null || echo "1.0")"

  if awk "BEGIN { exit !($current == $desired) }"; then
    ok "Cursor size already ${desired}x"
    return
  fi

  defaults write com.apple.universalaccess mouseDriverCursorSize -float "$desired"
  ok "Cursor size set to ${desired}x (was ${current})"
  warn "Log out and back in for the new cursor size to fully take effect."
}

info "macOS: applying preferences"
macos_cursor_size
