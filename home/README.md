# home/

Snapshots of config files, mirroring their path under `$HOME`. So `home/.gitconfig` maps to
`~/.gitconfig`, `home/.config/mise/config.toml` maps to `~/.config/mise/config.toml`, and so on.

This is just a **captured snapshot** for now. How it gets applied to a machine (symlink, copy, or
fold into chezmoi) is still being decided, see [../docs/dotfiles-sync.md](../docs/dotfiles-sync.md).
Tool-agnostic on purpose so any of those can consume it later.

## What's here (config for the tools we install)

| Path | Tool | Notes |
|------|------|-------|
| `.gitconfig` | git | user, signing key, `init.defaultBranch=main`, alias |
| `.config/git/ignore` | git | global gitignore |
| `.config/gh/config.yml` | gh | prefs + `co` alias only |
| `.config/mise/config.toml` | mise | global tools + trusted paths |
| `.config/thefuck/settings.py` | thefuck | all defaults (kept for completeness) |

## Deliberately NOT captured

- **`~/.config/gh/hosts.yml`** — holds the GitHub auth token. Secret. Git-ignored. Recreate on a
  new machine with `gh auth login`.
- **neovim** — no `~/.config/nvim` exists on this machine yet.
- **zoxide / fzf / direnv** — no standalone config; they're wired up via shell init, which lives in
  the fish config (out of scope for now).
- **mas** — stateless (uses the signed-in App Store account).
