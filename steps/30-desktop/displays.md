# Displays

Everything on screen at a size I can actually read, which is the one setting in this group
with **no right answer to write down**. A 1920×1080 laptop panel and a 4K external want
opposite numbers, so this step *asks* rather than asserting — same reasoning that keeps
[`cursor-size.md`](cursor-size.md) from freezing `36`, except here even the derivation is
per-machine.

Two things this step deliberately doesn't own. The **arrangement** — which panel sits at
which position, at which resolution — is the value being the file, so it's out of scope and
stays hand-done. And **apparent text size** is a different knob with its own step: on
Omarchy that's `omarchy display text size`, which [`terminal-font.md`](terminal-font.md)
owns. Reach for that one first; scaling is the blunter instrument and it moves everything,
including things that were already the right size.

## The asks

Two questions, both per-machine, neither predicted by any platform fact:

- **How should this display be scaled?** Ask when there's any doubt. `1` is right for a
  1920×1080 panel; a HiDPI panel usually wants `2`, and the awkward middle wants a
  fractional value that costs sharpness in XWayland apps.
- **Which display is primary?** Only a question when there's more than one. There's a single
  built-in panel on `hookers-green`, so it goes unasked here and the answer is unrecorded —
  which is the correct state for an ask nobody has needed yet, not a gap.

Answers live in `~/THIS-MACHINE.md` like every other ask, and get shown back in the plan on
a re-run rather than asked again.

## Omarchy (Hyprland)

Two values, in `~/.config/hypr/monitors.lua`, and they are **not** the same knob:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

- `omarchy_monitor_scale` is the **compositor's** scale, handed to `hl.monitor`. It's what
  makes Wayland clients draw bigger.
- `omarchy_gdk_scale` is exported as the `GDK_SCALE` **environment variable**, which is how
  GTK apps that aren't scaling themselves — and XWayland — find out.

Stock is `2` and `"auto"`. This machine runs `1` and `1`: the built-in panel is 1920×1080,
and a scale of 2 would leave it drawing an effective 960×540. Read the stock values before
assuming, the way the cursor step does — Omarchy owns that file and an update can move them.

### This is the one hypr file where the defaults live in *my* copy

Worth a paragraph, because it inverts what the neighbouring steps rely on.
`~/.config/hypr/looknfeel.lua` and `input.lua` arrive as **all-commented templates**: the
real defaults sit in `/usr/share/omarchy/default/hypr/`, loaded first, and my file only ever
holds the delta. `omarchy refresh config` on one of those costs me my overrides and nothing
else.

`monitors.lua` has **no counterpart in `default/hypr/`**. The shipped copy carries live,
uncommented values and the `hl.env`/`hl.monitor` calls themselves — so it's a **shipped
copy** in [`CONTEXT.md`](../../CONTEXT.md)'s sense, and
`omarchy refresh config hypr/monitors.lua` silently restores `2` / `"auto"`. There's nowhere
else to put the scale, so this is a case of editing the copy knowingly rather than a seam to
find. Check the file after any refresh.

### `GDK_SCALE` is inert until the next login

Exactly the trap [`cursor-size.md`](cursor-size.md) documents, for exactly the same reason:
`hl.env` is applied by Hyprland at startup, and UWSM exports the variable into the systemd
and dbus environments once, at login. **`hyprctl reload` returns `ok` and does not move
it.** The compositor scale *does* reload — so a half-applied state is the normal outcome of
editing this file, with windows resized and GTK apps still scaling the old way.

Either log out and back in, or push it into the running session too:

```sh
systemctl --user set-environment GDK_SCALE=1
dbus-update-activation-environment --systemd GDK_SCALE=1
```

Pass the value explicitly, never the bare name — given `GDK_SCALE` alone,
`dbus-update-activation-environment` reads it from the calling shell, and a shell older than
the change writes the stale value straight back.

Apps already running keep the scale they launched with regardless; only new windows pick it
up.

For a one-off nudge without touching the file at all — trying a value before committing to
it — `omarchy hyprland monitor scaling <scale>` moves the focused monitor for this session
only.

## macOS

Scaling is a **resolution preset**, not a number: System Settings > Displays, the row of
"Larger Text … More Space" options. There's no stable `defaults` key worth writing — the
per-display preference is an opaque blob keyed by display UUID, which is precisely the "the
value *is* the file" case.

So on macOS this step is entirely its ask: pick the preset, and record the answer. Nothing
to apply, nothing to verify by command.

Not yet run on a Mac.

## Knowing it's done

**Omarchy.** Ask the compositor for the scale, and the session — not the shell — for the
environment variable:

```sh
hyprctl monitors | grep -E '^Monitor|scale:'      # scale: 1
systemctl --user show-environment | grep GDK_SCALE # GDK_SCALE=1
```

`printenv GDK_SCALE` is the wrong check for the same reason it's wrong next door: it reports
whatever the current shell inherited, so it shows the old value after a successful change
and the new one after a failed change.

The partial state is what to catch: `hyprctl monitors` reporting the new scale while
`show-environment` still holds the old `GDK_SCALE`. That's the file written and reloaded but
never logged out of, and it looks fine until a GTK app opens at the wrong size.
