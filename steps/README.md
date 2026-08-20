# Steps

A step is a **markdown file**. No frontmatter, no schema — prose the agent reads and acts
on. Everything below is convention, not syntax: there's nothing to parse, and nothing that
can drift out of sync with the text beside it.

Settled in [#6](https://github.com/pvinis/setup/issues/6) by writing two steps three ways
and reacting to them.

## What counts as one step

**One step is one intent, spanning platforms.** Not one setting, and not one platform's pile
of settings. `appearance.md` covers dark mode, accent colour and window borders because
"dark everything, purple accents" is the thing I'd say out loud; it has a macOS section and
an Omarchy section, and each carries the knobs that platform expresses it with.

A step per *setting* doesn't scale — a dozen macOS `defaults` become a dozen files repeating
the same apply-and-verify prose. A step per *platform* (`macos-defaults.md`) is worse: it
has exactly one `##` section for its whole life, which makes the platform mechanism below
dead weight and leaves the Linux equivalent of "dock size" homeless.

**A knob earns its own file when its apply-or-verify story is its own.** Cursor size on
Hyprland is a page about UWSM and stale environments, so it's a file. Tap-to-click is a line,
so it's a row in a table. When a step covers several knobs, a **table with the GUI location
per row** is the shape — that's how the settings were found (change it in the GUI, diff
`defaults read` before and after) and how I check one by hand later.

**A step that only one platform has is fine.** `dock.md` is macOS-only because Omarchy has no
dock; one `##` section is the applicability declaration working, not the bucket problem
above.

## Steps carry values, not files

A step says what I want in a sentence and checks it: *the pointer at 1.5x stock*, *Iosevka
at 11 in whichever terminal is installed*, *screensaver at 150s*. Some configuration has no
such sentence — a 120-entry ordered widget list, twenty lines of tool preferences, a
browser's preferences blob. There the value **is** the file, and copying files around is the
dotfiles problem, which this repo deliberately doesn't solve.

So: **if I can state it and the agent can check it, it's a step. If the honest answer is
"the contents of this file", it isn't** — the step stops at installing or enabling the
thing, and the file waits for the dotfiles effort. This line runs *through* individual
config files, not around them: the idle timings and clock format in `shell.json` are steps;
the bar layout in the same file is not.

## Anatomy

**Open with the intent.** What I want, not what to type — *"the pointer at 1.5x whatever the
platform ships as stock"*. This is the durable part of a step; the commands and values rot
around it.

**Don't freeze derived values.** Platforms diverge in *units*, not just syntax: macOS
pointer size is a multiplier (1.5), Omarchy is pixels over a stock of 24 (so 36). Write the
intent and how to derive it — read the stock, multiply — with today's number as a worked
example rather than the source of truth.

**One `##` section per platform.** `## macOS`, `## Omarchy (Hyprland)`. A section existing
means the step applies there; no section means it doesn't. A step that's the same everywhere
just has no platform sections.

**Say how to know it's already done**, in prose, command inline. Include what the never-ran
state looks like when that isn't obvious — a missing macOS default key means stock 1.0, not
an error — and any way the check can lie.

**Check the authoritative source, not a convenient proxy.** This is the one that actually
bit us: the cursor step originally verified with `printenv`, which reports whatever the
current shell inherited, so it showed the old value after a successful change and would have
shown the new one after a failed change. Reading the session's real environment
(`systemctl --user show-environment`) would have caught the failure on the first try.
A check you can't be wrong about is worth more than a short one.

**A step is not done when the file is written.** Config that only loads at login, or a
daemon that needs a reload, means the persistent change and the running system have
diverged. Say which one the check reads, and give the command that applies it *now* if there
is one.

**Point at package-owned files rather than editing them.** Which file the override belongs
in, and why that one and not the other, is worth a sentence.

**Name your prerequisites**, in prose, if the step has any. Steps declare what they need
rather than being sequenced by the index ([#7](https://github.com/pvinis/setup/issues/7)) —
and with no frontmatter, that declaration is a sentence like any other.

## Groups and ordering

Sequence comes from each step's declared prerequisites, not from the directory names. The
`NN-` prefixes group by *kind* and give a readable sorted listing — with human work sorting
first, which is also the order it has to run in. That's all they do; a step is never
"after" another because of its number.

## Human steps go in `00-human/`

Steps only I can do — GUI apps, account passwords, second factors — aren't a flag on a step.
They're their own group, walked with me **first**, before the agent runs anything
unattended. The chain of trust ([#5](https://github.com/pvinis/setup/issues/5)) puts them
first anyway: no signing, cloning, or secret-fetching until they're done.

Write the ask as a **blockquote** addressed to me, carrying everything I need to act —
which account, which settings pane — then say what to re-check afterwards.

**A human beat in the middle doesn't make it a human step.** `xcode-select --install` opens a
dialog I have to click and then takes ten minutes; the agent still runs the command, waits,
and verifies. That step lives with its own kind and carries the blockquote inline. `00-human/`
is for steps that are human end to end.

An **ask** isn't a human step either — the runbook asking which colour to name the machine is
a question with an answer, not work only I can do.

## Scripts

No mechanism yet. Neither of the first two steps earned one, and machinery gets added when
a step demands it, not before.

## Not settled here

- **Headless** is deliberately out for now. When it returns it returns as another platform
  section, not a separate axis.
