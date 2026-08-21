# Setup

The runbook an agent works through on a fresh machine. The vocabulary here is about **where a
value goes** on a platform someone else already configured — the question every step ends up
asking, and the one that has been answered inconsistently until it was named.

## Language

### How a platform's config relates to mine

Three shapes, and which one a file has decides where personal values are allowed to live.

**Sourced layer**:
The platform's file stays package-owned and mine *reads* it — `~/.bashrc` sourcing
`$OMARCHY_PATH/default/bash/rc`. Updates flow through underneath; anything below the source
line is untouched forever.
_Avoid_: include, import

**Override file**:
A file the platform loads *after* its own defaults, existing to be written by me —
`~/.config/hypr/looknfeel.lua`. The defaults stay where they are and I state only the delta.
_Avoid_: user config, local config

**Shipped copy**:
The platform copies its file into my home once at install and can re-copy it over mine later
— `~/.config/git/config`, replaced by `omarchy-refresh-config git/config`. It looks like
mine and isn't: my edits are in the path of the next refresh, and the platform's improvements
never reach a file I've touched.
_Avoid_: default config, stock config (those name the *source*, not the copy)

**The rule:** never put personal values in a shipped copy. Find or make a file the platform
doesn't own — for git that's `~/.gitconfig`, which git reads alongside the copy and which
wins.

### Steps

**Step**:
One intent, spanning platforms, as a markdown file under `steps/`. Format in
[`steps/README.md`](steps/README.md).
_Avoid_: task, script, recipe

**Ask**:
A question the runbook puts to me because no platform fact predicts the answer — timezone,
headed or headless. Not a step, and not human work.
_Avoid_: prompt, input

**Human step**:
Work only I can do, end to end — a password, a second factor, a GUI login. Its own group,
`steps/00-human/`, walked first. A human beat *inside* an otherwise agent-run step doesn't
make it one.
_Avoid_: manual step, interactive step

**Desired state**:
What I want present, stated without reference to what any one platform ships — so a step is
free to be a no-op where the platform already provides it. The opposite of a delta against a
particular machine.
_Avoid_: manifest, delta, diff
