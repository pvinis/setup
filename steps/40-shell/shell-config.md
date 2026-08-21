# Shell config

Anything I add to my shell — aliases, exports, functions — lives **below** the line that
loads the platform's own config, so an OS update never eats it. Today that's exactly one
alias, and the thinness is the point: this step is here so the seam is ready and named, not
because there's volume to manage.

The alias points at `claude`, installed by [`../20-packages/cli-tools.md`](../20-packages/cli-tools.md).
It doesn't need it to exist, so there's no ordering constraint — a dangling alias is
harmless.

## Omarchy (bash)

`~/.bashrc` **sources** Omarchy's config rather than copying it:

```sh
source "$OMARCHY_PATH/default/bash/rc"
```

which in turn pulls in `envs`, `shell`, `aliases`, `functions`, `init` and an `inputrc`
binding. Personal config goes after that line — Omarchy writes the invitation into the stock
file itself (*"Add your own exports, aliases, and functions here"*), so this is recognising a
seam the platform offers, not inventing one.

That sourcing is also why the block is safe. `~/.bashrc` is **not** under
`/usr/share/omarchy/config/`, so `omarchy-refresh-config` cannot reach it, and
`omarchy-refresh-shell` is about `omarchy/shell.json` (the bar) despite the name. Updates
flow through the sourced file underneath, leaving anything below the line alone. This is the
opposite of [`git-config.md`](git-config.md) next door, where the platform's file is a
*copy* and personal values in it are in the path of the next refresh — worth reading the two
together once.

Today's contents, in full:

```sh
alias ac='claude'
```

## macOS (fish)

**Unwritten — waits for a Mac.** The Mac ran fish, and that config was never captured: not in
[`reference/mac-snapshot-2026-06/`](../../reference/mac-snapshot-2026-06/) (its README says
so outright), not in `setup2`, not anywhere. So there is no source material to write this
from, and reconstructing it from memory would be inventing state.

The shape to work out when a Mac appears: fish's own file is `~/.config/fish/config.fish`,
and the question is whether anything platform-owned sits under it the way Omarchy's `rc`
does — if nothing does, the seam is trivial and this section is two lines.

The runbook does **not** assert a shell. Omarchy is bash and wired deep into it; the Mac was
fish; each platform keeps what it has.

## Knowing it's done

Check the file and a fresh shell, because they can disagree in both directions — an alias
typed at a prompt is real but unwritten, and one written to the file is absent from every
shell already open:

```sh
grep -n 'default/bash/rc\|alias ac' ~/.bashrc   # the source line, then the alias, in that order
bash -ic 'type ac'                              # ac is aliased to `claude'
```

The line numbers are the part that matters, and they're the reason to grep rather than just
run `type`. `type ac` passes whether the alias sits above or below the source line — but
above it, anything Omarchy defines under the same name overrides mine, and it does so
silently, on an update I didn't make. Nothing collides today; the ordering is what keeps it
that way.
