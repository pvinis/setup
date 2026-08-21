# Bar

The status bar along the **top**, carrying a clock I can read without stopping to parse it —
weekday and 24-hour time — plus, on a laptop, the battery as a **number** rather than a
picture of a battery.

What's *on* the bar isn't part of this. An ordered list of widgets is the value being the
file, which [`README.md`](../README.md) rules out of a step; this machine has three
third-party widgets in that list and the runbook deliberately doesn't know about them.

## macOS

| What I want | System Settings | Command |
| --- | --- | --- |
| Clock shows weekday, date, 24h time | Control Centre > Clock Options / Date & Time | `defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM  HH:mm"` |
| Battery percentage | Control Centre > Battery > Show percentage | `defaults write com.apple.menuextra.battery ShowPercent -boolean YES` |

**Two spaces before the time** in that format string, between `MMM` and `HH` — it's the
visual gap between date and time in the menu bar, not a typo to tidy up.

**Applying it now** is `killall SystemUIServer`, not `killall Dock`: the menu bar extras
live in that process and won't re-read either key until it restarts. The bar blinks out and
comes back within a second.

The battery key is inert on a desktop Mac with no battery. It's still worth writing — same
reasoning as the Magic Trackpad domain in [`input.md`](input.md).

## Omarchy (Hyprland)

| What I want | Where | Command |
| --- | --- | --- |
| Bar at the top | `~/.config/omarchy/shell.json`, `bar.position` | `omarchy bar position top` |
| Clock: weekday + 24h time | same file, the `omarchy.clock` widget | `omarchy bar set omarchy.clock format "dddd HH:mm"` |

Battery has no row: the Omarchy bar's power widget shows a percentage already, with nothing
to turn on.

**Both of these are already Omarchy's stock values**, so this section is a no-op on a fresh
install — which is the point of stating desired state rather than a delta. Run the commands
anyway; they're what makes the step true on a platform whose defaults move.

They're idempotent in **value** but not in **bytes**: each one pipes the whole file through a
normalising `jq` pass that sorts keys alphabetically, so running them on an already-correct
machine rewrites `shell.json` top to bottom and any byte-level comparison lights up. Nothing
changed — compare with `jq -S` on both sides, as the check below does, and it comes back
empty.

**Use the commands, don't hand-edit the file.** `~/.config/omarchy/shell.json` is a **shipped
copy** in the sense [`CONTEXT.md`](../../CONTEXT.md) gives the word — Omarchy copies it into
`~/.config` at install *with its full default contents*, and `omarchy refresh shell` copies
stock straight back over it. So a personal value written there is sitting in the path of the
next refresh, and there is **no override layer for it**: `~/.config/omarchy/shell.toml` is a
real override file (see [`terminal-font.md`](terminal-font.md)) but it only carries styling
tokens — font, spacing, colours — and cannot express bar position or a clock format.

The saving grace is that both values here *equal* stock, which buys the same check
`git-config.md` gets: if the diff against stock is empty, a refresh can never cost anything.

```sh
diff <(jq -S . ~/.config/omarchy/shell.json) \
     <(jq -S . /usr/share/omarchy/config/omarchy/shell.json)
```

On this machine that prints only the three extra widgets — the part that isn't a step
anyway. The day it prints a `position` or `format` line, this step has started carrying a
value a refresh would eat, and that's worth knowing before the refresh rather than after.

## Knowing it's done

**macOS.** Read the keys back:

```sh
defaults read com.apple.menuextra.clock DateFormat     # EEE d MMM  HH:mm
defaults read com.apple.menuextra.battery ShowPercent  # 1
```

Missing keys are the never-ran state: stock is time-only with no weekday, and no battery
percentage. Both `defaults read` calls exit non-zero there, which is the correct reading of
"still stock", not a failed check.

**Omarchy.** The shell watches `shell.json` and hot-reloads on save, so for once the file
and the running bar can't drift — reading the file is honest:

```sh
jq -r '.bar.position' ~/.config/omarchy/shell.json                              # top
jq -r '.bar.layout.center[] | select(.id=="omarchy.clock") | .format' \
  ~/.config/omarchy/shell.json                                                  # dddd HH:mm
```

Then look at the bar. The one way this check lies is a bar the shell failed to start at all:
the file reads perfectly and there's nothing on screen. The shell is a plain Quickshell
process started by the Hyprland session rather than a systemd unit, so
`pgrep -f 'quickshell.*omarchy'` is the confirmation — or just seeing the clock.
