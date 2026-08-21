# Idle and lock

Leave the machine alone and the screensaver comes up at **2½ minutes**; leave it another 2½
and it **locks**, at 5 minutes total. Two numbers, and the gap between them is the point —
the screensaver is the warning that the lock is coming, so it has to land first and with
enough room to notice.

## Omarchy (Hyprland)

Both live in `~/.config/omarchy/shell.json`, in seconds since idle began:

```json
"idle": {
  "screensaver": 150,
  "lock": 300
}
```

**Both are Omarchy's stock values**, so this is a no-op on a fresh install — stated as
desired state anyway, because the numbers are what I want and not merely what I was given.

There's **no `omarchy` command for the timings**, unlike the bar next door: `omarchy bar
position` and `omarchy bar set` cover their half of this file, but idle is a hand-edit, and
that's what the shell's own docs prescribe. `omarchy toggle idle` looks like the CLI for
this and isn't — see below.

The same shipped-copy caveat applies as in [`bar.md`](bar.md): `shell.json` is copied into
`~/.config` with its full default contents and `omarchy refresh shell` copies stock back over
it, with no override layer able to express these keys. Because both values equal stock, a
refresh currently costs nothing here — the diff in `bar.md` is the check that stays true.

The shell watches the file and hot-reloads on save, so there's nothing to restart and no
window where the file and the running session disagree.

## macOS

Applies, but **the values aren't captured**. The Mac these were photographed from is gone,
`scripts/macos.sh` in `pvinis/dotfiles` never covered idle or lock, and the modern keys moved
out from under `com.apple.screensaver` into System Settings > Lock Screen — so writing
commands here would mean inventing them and calling reasoning a capture.

This section exists to say the step *does* apply on macOS. When there's a Mac in front of
me, capture it the way [`appearance.md`](appearance.md) describes: `defaults read > a`,
change "Start Screen Saver when inactive" and "Require password after screen saver begins"
in the GUI, `defaults read > b`, `diff a b`. Then the two rows land here and this paragraph
goes away. Tracked with the other Mac-blocked items in the map's fog.

## Knowing it's done

**Omarchy.** The file is honest, because the shell hot-reloads it:

```sh
jq '.idle' ~/.config/omarchy/shell.json    # { "screensaver": 150, "lock": 300 }
```

**The way this check lies is worth more than the check.** `omarchy toggle idle` flips a
stay-awake override that lives entirely outside this file — it drops a marker at
`~/.local/state/omarchy/indicators/stay-awake` — and while that marker exists the timings
above are correct and *nothing idles at all*. A machine left deliberately awake for a long
build reads as perfectly configured and never locks. So check both:

```sh
omarchy toggle idle status    # {"enabled":false,...} — false means idle behaves normally
```

`enabled: true` there means stay-awake is on, which is the opposite of what the word
suggests at a glance. Confirm properly by leaving the machine alone and watching, or accept
the two readings together.

**macOS.** Nothing to check until the values above exist.
