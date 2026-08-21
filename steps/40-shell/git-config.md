# Git config

The git behaviour I want: rebase on pull, upstream set on first push, diffs I can read,
conflict resolutions remembered, `main` for new repos, and one alias of my own. Same
desired-state idea as the package steps — state what I want, and let it be a no-op wherever
the platform already provides it.

**Identity is two rows of the table below**, and not a step of its own. Name and email are
values I can state and check like any other, and neither is a secret; they land in the same
file the seam below establishes, which is why getting that seam right comes first. The
credential helper is *not* here — `gh auth login` writes it, so
[`../00-human/gh-auth.md`](../00-human/gh-auth.md) owns repairing it.

**Commits are not signed, and that's a decision.** The 2026-06 Mac signed with a hardcoded
GPG key; this machine never has, and every commit in this repo is unsigned. The runbook
records the negative rather than leaving the positive to be assumed again — no signing key,
no `commit.gpgsign`, nothing to import, and nothing anywhere in the chain of trust waiting on
gpg. (The GitHub account still carries 13 unrevoked GPG keys from years of per-machine keys.
Pruning them is account hygiene, not something you do on a new machine, so it isn't here.)

Both settled in [#5](https://github.com/pvinis/setup/issues/5).

Needs git, from [`../20-packages/cli-tools.md`](../20-packages/cli-tools.md).

## The seam: `~/.gitconfig` is mine

Git reads **two** user-level files — `~/.gitconfig` and `~/.config/git/config` — and
`~/.gitconfig` wins on single-valued settings, while multi-valued ones like aliases merge
across both. So personal values go in `~/.gitconfig`, whatever the platform ships stays
where the platform put it, and neither has to know about the other.

This is the same shape as [`shell-config.md`](shell-config.md) next door — mine layered over
theirs — but it's arrived at the hard way, because git's platform file is a *copy* rather
than something mine sources.

**The trap:** with no `~/.gitconfig` present, `git config --global …` writes into
`~/.config/git/config` instead. Creating the file is what redirects every later `--global`
write; until it exists, the command that looks like it's editing your config is editing the
platform's.

The captured Mac used `~/.gitconfig` and this machine uses `~/.config/git/config`, which
looked like a divergence to resolve. It isn't. They're two layers, and the personal one is
`~/.gitconfig` on both.

## What I want

Written to `~/.gitconfig` on macOS; on Omarchy all but the first three arrive stock, so read
them back rather than writing them again. Identity is in the first three for the obvious
reason — no platform ships it.

| What I want | Setting |
| --- | --- |
| commits attributed to me | `user.name = Pavlos Vinieratos`, `user.email = pvinis@gmail.com` |
| `main` for new repos | `init.defaultBranch = main` |
| undo the last commit, keep the changes staged | `alias.boc = reset --soft HEAD~1` |
| rebase on pull, never a merge bubble | `pull.rebase = true` |
| upstream set for me on first push | `push.autoSetupRemote = true` |
| diffs that survive moved code | `diff.algorithm = histogram`, `diff.colorMoved = plain`, `diff.mnemonicPrefix = true` |
| the diff in front of me while writing the message | `commit.verbose = true` |
| columns when the terminal has room | `column.ui = auto` |
| branches newest-first, tags in version order | `branch.sort = -committerdate`, `tag.sort = -version:refname` |
| conflict resolutions remembered and reapplied | `rerere.enabled = true`, `rerere.autoupdate = true` |
| short aliases | `alias.co/br/ci/st` |

`init.defaultBranch` is the one to watch. Omarchy ships `master`; that's *Omarchy's* default,
not a preference of mine, and asserting `main` over it is most of what this step does on that
platform.

## Omarchy

Omarchy ships `/usr/share/omarchy/config/git/config` and **copies** it to
`~/.config/git/config` at install. Nothing sources anything, and
`omarchy-refresh-config git/config` re-copies stock over your version (saving
`.bak.<epoch>` beside it). So personal values written there sit in the path of the next
refresh, and stock improvements never reach a file you've edited.

The whole Omarchy job is therefore: put the personal settings in `~/.gitconfig`, and leave
the copy **exactly as shipped**.

```sh
git config --global user.name 'Pavlos Vinieratos'
git config --global user.email 'pvinis@gmail.com'
git config --global init.defaultBranch main
git config --global alias.boc 'reset --soft HEAD~1'
```

They all land in `~/.gitconfig` — but only once it exists, so create it first (an empty
`touch ~/.gitconfig` is enough) or write the file directly. On a machine where `--global`
has already been run without it, the values are in the copy and need moving out, not just
setting.

## macOS

No platform layer at all: `~/.gitconfig` is simply *the* config, and it carries the whole
table above rather than a delta. Nothing to leave alone, nothing that gets refreshed.

Reasoned, not yet run on a Mac.

## Per-client config

Client-specific settings — a different email, a different signing key for one org's repos —
go here rather than becoming a machine-level thing, because a client engagement starts and
ends on a different clock than a machine does. The mechanism is `includeIf` keyed on the
**remote URL**:

```
[includeIf "hasconfig:remote.*.url:https://github.com/SomeOrg/*"]
	path = ~/.config/git/config-someorg
```

**Keyed on the remote, never on the hostname.** That's the durable part: it follows the
repo, so it's right on every machine at once with nothing to render or parameterise, and it
degrades cleanly — a machine without the included file just doesn't include it. An older
attempt keyed the same idea on hostname through a chezmoi template, hardcoded two hosts with
no else branch, and rendered *empty* on a third machine without saying so.

No client block is asserted. There's no client on this machine, and writing one would be
inventing state; this section is here so the next one has a shape to arrive into.

## Knowing it's done

```sh
git config --get user.email                  # pvinis@gmail.com
git config --get init.defaultBranch          # main
git config --get-regexp '^alias\.'           # boc, plus whatever the platform ships
git config --get commit.gpgsign              # nothing, and that's the intended state
```

The `gpgsign` line is the one whose *empty* output is the pass. An unset value here means
unsigned commits, which is what was decided; if it ever comes back set, something restored a
config from the Mac era.

On Omarchy there's a second check, and it's the one that proves the seam holds:

```sh
diff ~/.config/git/config /usr/share/omarchy/config/git/config   # no output
```

Byte-identical to stock means `omarchy-refresh-config git/config` is a genuine no-op that
can never cost anything. Any output is personal config that has drifted into the refreshable
file.

**The lie to watch for:** `git config --get` and `--list` report the *merged* result, so
everything reads correct even when every value is piled in the file that gets overwritten.
The check that can't be wrong names the file:

```sh
git config --list --show-origin | grep -E 'defaultbranch|alias\.boc'
```

Expect `init.defaultbranch` **twice** on Omarchy — `master` from the copy, then `main` from
`~/.gitconfig`. Two lines is the layering working, not a conflict; the later file wins.
