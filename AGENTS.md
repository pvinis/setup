# AGENTS.md

Two readers, one file: an agent **setting up a machine**, and an agent **working on this repo**.

The runbook entry is here ([#7](https://github.com/pvinis/setup/issues/7)) — the catalogue below is the reading order. The rest of that entry (detect the OS, ask headed vs headless, remember the answers, plan-then-apply) is still to be written: [#22](https://github.com/pvinis/setup/issues/22).

## The runbook

Steps live in `steps/`; the format they follow is [`steps/README.md`](steps/README.md). Each step names its own prerequisites, so the list below is a reading order rather than a dependency graph. The `NN-` prefixes group by kind, human work first.

**`00-human/`** — walked with Pavlos before anything runs unattended

- [`1password-signin.md`](steps/00-human/1password-signin.md) — the root of trust
- [`app-store-signin.md`](steps/00-human/app-store-signin.md) — macOS; gates the App Store half of the apps step
- *app logins* — Beeper, browser, Obsidian: [#21](https://github.com/pvinis/setup/issues/21)
- *ssh key, gpg key, `gh auth login`* — [#5](https://github.com/pvinis/setup/issues/5)

**`10-system/`**

- [`hostname.md`](steps/10-system/hostname.md) — name it a colour
- [`time-and-locale.md`](steps/10-system/time-and-locale.md)
- [`xcode-command-line-tools.md`](steps/10-system/xcode-command-line-tools.md) — macOS; the first thing that happens there

**`20-packages/`**

- [`cli-tools.md`](steps/20-packages/cli-tools.md)
- [`apps.md`](steps/20-packages/apps.md)

**`30-desktop/`** — skipped wholesale on a headless machine

- [`cursor-size.md`](steps/30-desktop/cursor-size.md)
- [`appearance.md`](steps/30-desktop/appearance.md)
- *input, bar, dock, sound, displays, idle and lock, terminal font* — [#19](https://github.com/pvinis/setup/issues/19)

**`40-shell/`** — *shell config, git config*: [#20](https://github.com/pvinis/setup/issues/20)

## Working on the repo

### Issue tracker

GitHub Issues on `pvinis/setup`, via the `gh` CLI. The `/wayfinder` map and its tickets live there too. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles, default label names unchanged. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` and `docs/adr/` at the repo root. Neither exists yet; `/domain-modeling` creates them lazily. See `docs/agents/domain.md`.
