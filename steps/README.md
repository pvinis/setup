# Steps

A step is a **markdown file**. No frontmatter, no schema — prose the agent reads and acts
on. Everything below is convention, not syntax: there's nothing to parse, and nothing that
can drift out of sync with the text beside it.

Settled in [#6](https://github.com/pvinis/setup/issues/6) by writing two steps three ways
and reacting to them.

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
an error — and any way the check can lie. `XCURSOR_SIZE` reads as unset over ssh even when
the step is done.

**Point at package-owned files rather than editing them.** Which file the override belongs
in, and why that one and not the other, is worth a sentence.

## Human steps go in `00-human/`

Steps only I can do — GUI apps, account passwords, second factors — aren't a flag on a step.
They're their own group, walked with me **first**, before the agent runs anything
unattended. The chain of trust ([#5](https://github.com/pvinis/setup/issues/5)) puts them
first anyway: no signing, cloning, or secret-fetching until they're done.

Write the ask as a **blockquote** addressed to me, carrying everything I need to act —
which account, which settings pane — then say what to re-check afterwards.

## Scripts

No mechanism yet. Neither of the first two steps earned one, and machinery gets added when
a step demands it, not before.

## Not settled here

- **Ordering beyond "human first."** The `NN-` prefixes are a placeholder.
- **A step that's mostly automatic with one human beat in the middle** has no home yet.
  `gh auth login` is the obvious case: the agent can run it, but a browser and a second
  factor happen in the middle.
- **Headless** is deliberately out for now. When it returns it returns as another platform
  section, not a separate axis.
