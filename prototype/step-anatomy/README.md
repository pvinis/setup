# Prototype: what is a step file?

Throwaway. Answers [#6](https://github.com/pvinis/setup/issues/6) — the anatomy of a runbook
step — and nothing here is meant to survive as-is.

Same **two steps** written three ways, so the shapes can be read side by side:

- **cursor size** — pure automation, diverges hard across platforms
- **1Password sign-in** — irreducibly human, and the agent can only verify it

The three variants sit on one axis, *prose ← → structure*:

| | frontmatter | body | thesis |
|---|---|---|---|
| [`a-prose/`](a-prose) | none | everything | the agent reads and judges; minimal wins |
| [`b-frontmatter/`](b-frontmatter) | `applies` + `check` | how-to, per-OS | structure only where the agent **branches** |
| [`c-structured/`](c-structured) | everything | commentary | repeatable, machine-checkable |

## What writing them actually turned up

Not predictions — these came out of writing the two steps against this machine.

1. **Platforms diverge in units, not just syntax.** macOS pointer size is a multiplier
   (1.0–4.0, want 1.5); Omarchy is pixels (`XCURSOR_SIZE`, stock 24, want 36). Nothing
   templates one into the other. The step's durable content is the *intent* ("1.5x of
   stock") and each platform's recipe is written out longhand.

2. **"Where it applies" is not a boolean.** Cursor size genuinely doesn't exist headless.
   1Password sign-in still applies headless — it's a *different procedure* (service account
   token instead of desktop integration). One field can't carry skip-vs-branch.

3. **A check can be wrong from the wrong vantage point.** `XCURSOR_SIZE` is unset over ssh
   even when the step is done, because it only exists in the compositor's session. A bare
   command-plus-expected-value reports a confident false negative.

4. **Two steps produced two disjoint schemas.** `apply`/`expect`/`after`/`gui` for the
   cursor; `install`/`human`/`confirm`/`diagnose` for the sign-in. No field is shared but
   `check`. Variant C is where you can watch this happen.

5. **The most valuable sentence in the 1Password step doesn't fit in a field.** `op whoami`
   saying *"not signed in"* and `op account list` printing nothing look like the same
   failure and mean opposite things — unlock the app vs the step never ran. That's a
   paragraph, and encoding it as `diagnose:` made it worse.

6. **Package-owned defaults need saying out loud.** Omarchy ships `envs.lua` under
   `/usr/share`, updates overwrite it, and the override belongs in a `~/.config` file loaded
   afterwards. "Which file do I edit and why that one" is prose in every variant.

## Machine facts these were written against

`hookers-green`, 2026-08-20: Omarchy 4.0.0, `XCURSOR_SIZE`/`HYPRCURSOR_SIZE` both 24,
`gsettings` cursor-size 24, `~/.config/hypr/` overrides loaded from `hyprland.lua` after
Omarchy's defaults. `op` 2.35.0 installed with **two** accounts configured (personal
`my.1password.com`, work `leanscaper.1password.com`) but **not signed in**. No GPG secret
key and no `user.signingkey` — this machine has never signed a commit.
