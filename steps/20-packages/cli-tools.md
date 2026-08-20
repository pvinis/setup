# Command-line tools

The tools I expect to be there on any machine I sit down at. This is a list of what I want
**present**, not a list of what to install — on a distro that already ships most of it,
almost all of this is a no-op, and that's the list working correctly, not the list being
wrong.

Keep it that way. The moment this becomes "the things Omarchy doesn't have", it's a delta
against one distro and it's useless on the next one.

## Where a tool comes from

**mise owns runtimes and the agent CLIs** — node, bun, python, `claude`, `codex`. Everything
else comes from the system package manager.

The rule governs **installing**, not **checking**. If a tool is already on `PATH` from
somewhere else, the step is done — don't reinstall it from the "correct" source to make the
rule tidy. Omarchy, for one, installs `gh` through its own mise (see
`/usr/share/omarchy/install/user/mise.sh`); that satisfies "I want `gh`" perfectly well and
re-doing it through pacman would just mean two of them.

**If a tool doesn't obviously fall on one side, ask me.** The rule is a default, not a
decision procedure, and guessing wrong is how a machine ends up with two pythons.

On `python` specifically: the rule means *the python I develop against* comes from mise. It
is not a claim about the system copy — on Arch, `/usr/bin/python` is a dependency of gdb,
OBS and LibreOffice among others, and removing it is not on the table.

## The list

From mise:

- `node`, `bun` — runtimes
- `claude`, `codex` — the agents

From the system package manager:

- `git`, `neovim`
- `fzf`, `zoxide`, `jq`
- `gnupg`, `yt-dlp`

`1password-cli` belongs on this list by nature, but it is **installed by
[`../00-human/1password-signin.md`](../00-human/1password-signin.md)** and deliberately not
repeated here — it's the root of trust and has to land before anything that needs a secret.

This list is a deliberate core, not an inventory of either machine. Growing it happens one
package at a time, with a reason — not by dumping `pacman -Qqe` or `brew leaves` into it.

Several things on the old Mac list (`direnv`, `fish`, `thefuck`, `tree`, `wget`,
`diff-so-fancy`) aren't here and aren't on this Linux box either.
[#12](https://github.com/pvinis/setup/issues/12) asked whether that was drift or a decision
and settled it as a **decision**: I have been running this machine without them for its whole
life, which is a stronger answer than anything I'd have reasoned out. Absence from this list
is a verdict, not an oversight.

## Omarchy / Arch

`pacman -S --needed` for anything in the official or `omarchy` repos, `yay -S` for the AUR.
Omarchy ships `yay` already, so there's nothing to bootstrap; on a plain Arch install there
would be.

`--needed` is what makes it idempotent — without it pacman happily reinstalls.

## macOS

`brew install`. Homebrew itself is not here on a fresh machine; take the current command from
<https://brew.sh> rather than pasting one from memory, and remember `brew` won't be on `PATH`
in the shell that installed it until you run `brew shellenv`.

Note `mise` is already present at this point — the bootstrap in the README installed it to
get the agent running — so runtimes don't wait on Homebrew.

## Knowing it's done

Per tool, ask the only question that matters: is it on `PATH` and does it run?

```sh
for t in node bun claude codex git nvim fzf zoxide jq gpg yt-dlp; do
  printf '%-8s %s\n' "$t" "$(command -v "$t" || echo MISSING)"
done
```

Two ways that can lie:

- **A shell older than the install.** A tool installed into a mise or Homebrew shim
  directory won't appear in a shell whose `PATH` predates it. `hash -r`, or a fresh shell.
- **`command -v` on a mise shim proves the shim exists, not that the tool does.** `mise ls`
  is the honest check for anything mise owns; a shim for an uninstalled tool resolves fine
  and then fails on execution.

The never-ran state is unambiguous here: everything is missing at once.
