# setup

My machine setup. The thing I point a fresh machine, or an AI agent, at to get into a working state.

## What this is

When I'm on a new machine, I tell Claude (or another agent) to read this repo and start setting
things up. The goal is an **idempotent** setup: run it as many times as you like, it converges the
machine toward the state I want and never makes a mess doing it.

Right now it's small (just a bit of macOS config). It'll grow.

## Usage

```sh
git clone https://github.com/pvinis/setup.git
cd setup
./setup.sh
```

`setup.sh` detects the OS (macOS / Linux) and runs the matching steps. Everything is safe to re-run.

## For an AI agent setting up a new machine

- Read this README and `setup.sh` first to understand the structure.
- Run `./setup.sh` to apply the current setup. It's idempotent, so just run it.
- Each step is small and self-describing. Prefer adding a new small, idempotent step over one big
  bespoke script.
- Don't apply anything destructive or irreversible without asking me first.

## Related repos (being consolidated here)

These are older / parallel attempts at keeping my dotfiles. The plan is to fold what matters into
this repo over time. For now, they're still the source of truth:

- [pvinis/dotfiles](https://github.com/pvinis/dotfiles) — dotfiles, managed by chezmoi
- [pvinis/home](https://github.com/pvinis/home) — another dotfiles attempt

(There's also [pvinis/machez](https://github.com/pvinis/machez), an earlier stub.)

## Roadmap / TODO

- [ ] Decide on a dotfiles sync strategy, see [docs/dotfiles-sync.md](docs/dotfiles-sync.md)
      (investigating mackup vs chezmoi vs syncthing).
- [ ] Migrate dotfiles from the repos above into here.
- [ ] Grow the Brewfile from the top 10 to the full leaf list.
- [ ] Add casks (apps) to the Brewfile (~109 currently installed).
- [ ] Flesh out Linux setup (Homebrew also runs on Linux, so the Brewfile can be shared).
- [ ] More macOS defaults.

## Layout

```
setup.sh          # entry point: detects OS, runs the right steps
Brewfile          # Homebrew package manifest (applied with `brew bundle`)
macos/            # macOS-specific steps
  brew.sh         # install Homebrew if missing, then apply the Brewfile
  defaults.sh     # macOS system/app preferences (idempotent `defaults` writes)
docs/             # notes & decisions
  dotfiles-sync.md
```

## Homebrew

`macos/brew.sh` installs Homebrew (official command from <https://brew.sh>) if it isn't already
there, then runs `brew bundle` against the `Brewfile`. The Brewfile currently holds a curated top
10; the rest of my current leaves are listed commented-out so growing it is just uncommenting.
