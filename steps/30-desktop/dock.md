# Dock

A small dock, out of the way on the **right** edge, and the top-right corner of the screen
throws every window aside to show the desktop.

**macOS only.** Omarchy has no dock and nothing playing the part of one — Hyprland's
workspaces are how I get between windows there, and there's no surface to shrink or move.
The single `##` section below *is* the applicability declaration; there's nothing missing
here.

## macOS

| What I want | System Settings | Command |
| --- | --- | --- |
| Dock size 24 | Desktop & Dock > Size | `defaults write com.apple.dock tilesize -int 24` |
| Dock on the right | Desktop & Dock > Position on screen | `defaults write com.apple.dock orientation -string right` |
| Top-right corner → Desktop | Desktop & Dock > Hot Corners… | `defaults write com.apple.dock wvous-tr-corner -int 4` |
| …with no modifier key held | (same sheet) | `defaults write com.apple.dock wvous-tr-modifier -int 0` |

**Hot corners are in the dock's domain even though the GUI files them elsewhere** — they sit
under Mission Control in older macOS and behind a button in Desktop & Dock now, but every
one of them is a `com.apple.dock` key. That's why they're in this step and not a step of
their own: same domain, same `killall`, one intent's worth of clicking.

`wvous-tr-corner` is an enum, and **`4` is "Desktop"**, not a size or an index — the numbers
are not guessable, so change it in the GUI and diff `defaults read` if a different action is
ever wanted. `wvous-tr-modifier 0` means the corner fires on hover alone; a non-zero value
there is a modifier-key bitmask, and leaving it unset is *not* the same as zero — an
unwritten modifier can leave the corner armed but inert.

**Applying it now**: `killall Dock`. The dock relaunches immediately and reads all four keys
on the way up. Size and position are visible instantly; the hot corner needs the pointer
taken to the corner to confirm.

`tilesize` is the *resting* size. If dock magnification is ever turned on, the icons still
grow past 24 on hover — that's `largesize` and a separate setting this step doesn't touch.

## Knowing it's done

```sh
defaults read com.apple.dock tilesize        # 24
defaults read com.apple.dock orientation     # right
defaults read com.apple.dock wvous-tr-corner # 4
defaults read com.apple.dock wvous-tr-modifier # 0
```

Never-ran states make `defaults read` exit non-zero rather than print a default, so a
missing key here reads as "still stock" and not as a broken check: stock `orientation` is
`bottom`, stock `tilesize` is larger than 24 (the exact number has moved between releases,
so read it rather than expecting one), and both `wvous-tr` keys are simply absent, meaning
no hot corner is assigned.

The check that can lie is `orientation`: the dock also moves if it's dragged by its divider,
and that writes the same key — so a correct reading always matches the screen. It's the
opposite case to watch for, a key written while the Dock was never restarted, which
`killall Dock` settles.

The four values are captured — they come from the Mac, via `scripts/macos.sh` in
`pvinis/dotfiles`. The notes around them are reasoned and haven't been re-run on a Mac.
