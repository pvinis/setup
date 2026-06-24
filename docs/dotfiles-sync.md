# Dotfiles sync — investigation (TODO)

Goal: one reliable, idempotent way to keep dotfiles in sync across machines, and fold the existing
repos into this `setup` repo.

## Current state

A few parallel attempts, none of them the clear winner yet:

- [pvinis/dotfiles](https://github.com/pvinis/dotfiles) — managed by **chezmoi**, uses 1Password
  templating for secrets (e.g. `HOMEBREW_GITHUB_API_TOKEN`).
- [pvinis/home](https://github.com/pvinis/home) — "another try to keep my dotfiles".
- [pvinis/machez](https://github.com/pvinis/machez) — earlier stub.

## Options to evaluate

### chezmoi
- Templating + secret management (1Password, etc.), per-machine differences. `chezmoi apply` is
  idempotent by design.
- Already partly set up in `pvinis/dotfiles`.
- Cons: another tool / DSL to learn; state lives in chezmoi's source dir.

### mackup
- Syncs *application* settings by symlinking them into a storage dir (Dropbox / iCloud / etc.).
- Simple, lots of app support out of the box.
- Cons: less control; app-support backends have changed / broken over time. Fork:
  [pvinis/mackup](https://github.com/pvinis/mackup).

### syncthing
- Continuous, real-time file sync between machines, no cloud middleman.
- Good for "always in sync" rather than "apply on demand".
- Cons: conflict handling for config files; runs a daemon; not a "set up once" model. More of a
  complement (sync the chezmoi source dir or a dotfiles dir) than a manager on its own.

## Rough direction (not decided)

- chezmoi as the *manager* (templating + secrets + idempotent apply), possibly with syncthing to
  keep the source dir live across machines. mackup maybe only for apps chezmoi can't easily
  template.
- Once decided, migrate `dotfiles` / `home` into this repo (or have `setup.sh` bootstrap chezmoi).

Nothing here is final, revisit before committing to one.
