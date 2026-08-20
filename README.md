# setup

My machine setup. The thing I point a fresh machine, or an AI agent, at to get into a working state.

## What this is

When I'm on a new machine, I tell Claude (or another agent) to read this repo and start setting
things up. The goal is an **idempotent** setup: run it as many times as you like, it converges the
machine toward the state I want and never makes a mess doing it.

Right now it's small — a handful of steps under [`steps/`](steps/). It'll grow.

## Bootstrap: a brand-new machine

Getting from a bare machine to **an agent that can be typed at**. That's all this does. The agent
clones this repo itself and finds its own way in, so there's nothing to download or `cd` into by
hand.

**Omarchy** — nothing to install. It already ships `git`, `curl`, `mise` and the agents themselves
(its own `install/user/mise.sh` installs `claude`, `codex`, `gemini` and friends). Open a terminal:

```sh
claude
```

**macOS** — nothing is installed yet, so install `mise` and let it fetch the agent. Xcode Command
Line Tools are **not** needed to get this far: `mise` is a static binary and `claude` comes down as
a release binary, so neither wants a compiler. CLT is the agent's first job, not yours.

```sh
curl https://mise.run | sh
~/.local/bin/mise use -g claude
~/.local/bin/mise x claude -- claude
```

Absolute paths on purpose — they work in the terminal already open, with no PATH setup and no
restart.

**Then, on either OS**, it asks you to log in. The login lives in 1Password, and on a bare machine
that means signing in to 1Password **in a browser** first — the app and CLI come later, as
[`steps/00-human/1password-signin.md`](steps/00-human/1password-signin.md). Once the agent answers,
say:

> set up this machine with `gh pvinis/setup`

That line is the entire handoff, and it works from any directory.

## For an AI agent setting up a new machine

**Read [`AGENTS.md`](AGENTS.md).** That's the entry point — the rules of engagement and the step
catalogue. This README is for the human; it exists to point you there.

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
- [ ] Grow the package list one package at a time, with a reason for each
      (see [#12](https://github.com/pvinis/setup/issues/12)).
- [ ] More desktop settings steps.

## Layout

```
AGENTS.md         # the agent's entry point: rules + step catalogue
steps/            # the runbook: one markdown file per step (see steps/README.md)
  00-human/       # steps only I can do, walked first
  20-packages/    # tools, apps and fonts
  30-desktop/     # desktop / UI settings
reference/        # captured config snapshots, kept aside; nothing applies them
docs/             # notes & decisions
  dotfiles-sync.md
```

## Reference snapshots (`reference/`)

`reference/mac-snapshot-2026-06/` holds config captured from the Mac on 2026-06-25, mirroring each
file's path under `$HOME`. **Nothing applies it** — it's a photograph kept as a memory-jogger, and
it already diverges from this Linux machine (git config path, default branch, aliases, signing).
See [reference/mac-snapshot-2026-06/README.md](reference/mac-snapshot-2026-06/README.md).

