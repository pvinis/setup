# mac-snapshot-2026-06

Config files captured from the **Mac** on 2026-06-25, mirroring their path under `$HOME`
(`.gitconfig` -> `~/.gitconfig`, `.config/mise/config.toml` -> `~/.config/mise/config.toml`).

**Nothing applies these.** They are a photograph, kept to the side as a memory-jogger for what was
configured on that machine. They are *not* a desired-state declaration, and the runbook does not
read them. Moved here from `home/` by
[Which repo becomes the home: setup, setup2, or a fresh start?](https://github.com/pvinis/setup/issues/2);
whether they get reworked into step data, renamed, or deleted is deliberately still open.

## Known to be stale / wrong for `hookers-green` (Omarchy)

Checked 2026-08-20. The snapshot disagrees with the live Linux machine in ways that matter, which is
exactly why it isn't treated as truth:

| Thing | Snapshot (Mac) | `hookers-green` (Omarchy) |
|---|---|---|
| git config path | `~/.gitconfig` | `~/.config/git/config` (XDG) |
| `init.defaultBranch` | `main` | `master` |
| aliases | one set | a different set |
| `commit.gpgsign` | on, with a hardcoded signing key | absent |
| `gh` credential helper | — | hardcoded absolute mise install path |
| mise config | Mac tool set | diverges |

Which side of each divergence is the *intended* state is an open question for the runbook, not
something this directory answers.

## What's here

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
- **neovim** — no `~/.config/nvim` existed on that machine.
- **zoxide / fzf / direnv** — no standalone config; wired up via shell init, which lives in the fish
  config.
- **mas** — stateless (uses the signed-in App Store account).
