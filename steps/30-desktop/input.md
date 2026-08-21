# Input

Tap to click, and scrolling in the traditional direction — two fingers down scrolls *down*
the page — rather than the "natural" direction macOS ships. Both are trackpad habits I
notice within about ten seconds of using a machine that has them the other way.

## macOS

| What I want | System Settings | Command |
| --- | --- | --- |
| Tap to click | Trackpad > Point & Click > Tap to click | `defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1` |
| …same, for a Magic Trackpad | (same pane, external device) | `defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1` |
| Scrolling not "natural" | Trackpad > Scroll & Zoom > Natural scrolling **off** | `defaults write -g com.apple.swipescrolldirection -int 0` |

**Two domains for one setting.** `AppleMultitouchTrackpad` is the built-in trackpad;
`driver.AppleBluetoothMultitouch.trackpad` is a Magic Trackpad paired over Bluetooth. The
GUI shows one checkbox and writes whichever domain matches the device in front of it, so
writing only one leaves the other device tapping-disabled the first time it connects. Write
both, on every machine — the desktop that has no built-in trackpad today may get one paired
tomorrow, and the key costs nothing where no such device exists.

Log out and back in. These are read at login by the window server; unlike the appearance
keys there's no `killall` that reliably re-reads them.

## Omarchy (Hyprland)

**Both are already true, and neither is Omarchy's doing in the way you'd guess.** Nothing to
write — but the reason matters more than the no-op, because the obvious way to check is
wrong:

- `natural_scroll = false` is set explicitly in Omarchy's own defaults
  (`/usr/share/omarchy/default/hypr/input.lua`).
- `tap-to-click` is **Hyprland's** default. Nobody sets it — not Omarchy, not me — and it's
  been `true` the whole time.

So `~/.config/hypr/input.lua` here is byte-identical to the shipped template: every line
commented out. **Diffing my config against Omarchy's shows nothing, and concluding "this
isn't configured" would be wrong** — the intent is satisfied, just not by any file of mine.
That's the whole reason this section exists rather than being left out.

If a future machine wants either flipped, the override goes in `~/.config/hypr/input.lua`,
which `hyprland.lua` requires *after* Omarchy's defaults:

```lua
hl.config({
  input = {
    touchpad = {
      natural_scroll = false,
    },
  },
})
```

These are plain config values, not environment variables, so `hyprctl reload` applies them
— no logout, unlike [`cursor-size.md`](cursor-size.md) next door.

## Knowing it's done

**macOS.** Read all three keys back; `1`, `1`, `0`:

```sh
defaults read com.apple.AppleMultitouchTrackpad Clicking
defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking
defaults read -g com.apple.swipescrolldirection
```

A missing key is the never-ran state, not an error: stock macOS is tap-to-click **off** and
natural scrolling **on**, so absent means "still at the default I don't want".

**Omarchy.** Ask the compositor, never the file — the file is empty here even though the
settings are right:

```sh
hyprctl getoption input:touchpad:tap-to-click     # bool: true    / set: false
hyprctl getoption input:touchpad:natural_scroll   # bool: false   / set: true
```

**`getoption` prints a second line, `set:`, and it's the interesting one.** It says whether
anything configured the value or whether it's Hyprland's built-in default. Those two lines
above are the whole story of this section in four words: tap-to-click is `set: false`, a
default nobody wrote, and `natural_scroll` is `set: true`, written by Omarchy. Both land on
the value I want, by different routes — and only `set:` tells them apart.

Which also means **`set: false` is not a failure here**. On a machine where the intent were
*not* already the default, it would be.

`input:natural_scroll` (no `touchpad:`) is the *mouse* setting and is a separate knob; it's
also `false` here, which is the same intent for a device I don't use.
