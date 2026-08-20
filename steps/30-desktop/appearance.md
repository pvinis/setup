# Appearance

Dark everything, purple accents, a dense UI. One intent, several knobs — so unlike
[`cursor-size.md`](cursor-size.md) this step carries a **table** rather than a paragraph per
setting. Each row is one thing I'd notice missing, with the GUI location beside it so I can
check or change it by hand without going looking.

## macOS

| What I want | System Settings | Command |
| --- | --- | --- |
| Dark appearance | Appearance > Appearance | see below — not a `defaults write` |
| Accent colour purple | Appearance > Accent colour | `defaults write -g AppleAccentColor -int 5` |
| Highlight colour purple | Appearance > Highlight colour | `defaults write -g AppleHighlightColor -string "0.968627 0.831373 1.000000 Purple"` |
| Small sidebar icons | Appearance > Sidebar icon size | `defaults write -g NSTableViewDefaultSizeMode -int 1` |

(Pre-Ventura these lived under System Preferences > General; the keys didn't move.)

**Dark mode is the odd one.** `AppleInterfaceStyle` exists as a key, but writing it leaves
running apps light until they relaunch. Flipping it the way the GUI does notifies everyone:

```sh
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'
```

**Adding a row later**: how these were found in the first place, and how the next one gets
found — `defaults read > a`, change the setting in the GUI, `defaults read > b`, `diff a b`.
The diff names the domain and key; the GUI pane you were just in names the column beside it.

**Applying it now.** Accent and highlight reach newly drawn UI immediately; an app that's
already running keeps the old highlight until it's relaunched. `killall Finder Dock` covers
what's actually visible. Don't blanket-`killall cfprefsd` — `defaults write` goes *through*
that daemon, and killing it is only relevant when a plist was edited behind its back.

## Omarchy (Hyprland)

| What I want | Where | Command |
| --- | --- | --- |
| Tokyo Night theme | Omarchy's own theme system | `omarchy theme set "Tokyo Night"` |
| No gaps, thin border | `~/.config/hypr/looknfeel.lua` | `gaps_in = 0`, `gaps_out = 0`, `border_size = 1` |

The theme is one command and it repaints everything — terminals, editor, bar, backgrounds —
by swapping the symlink at `~/.local/state/omarchy/current/theme`, which each config
*imports*. That's why it doesn't collide with the terminal font: `alacritty.toml` imports
the theme file and declares the font itself, so the two steps own different lines.

Gaps and borders are an override, so they go in `~/.config/hypr/looknfeel.lua` — loaded
after Omarchy's package-owned defaults, which an update would overwrite:

```lua
hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 1,
  },
})
```

Unlike the cursor size next door, these are plain config values rather than environment
variables, so **`hyprctl reload` really does apply them** — no logout needed.

## Knowing it's done

**macOS.** Read the keys back:

```sh
defaults read -g AppleAccentColor          # 5
defaults read -g AppleInterfaceStyle       # Dark
```

Both never-ran states are *errors*, not zeros: a missing `AppleAccentColor` means stock
blue, and `AppleInterfaceStyle` **doesn't exist at all in light mode** — `defaults read`
exits non-zero and that is the correct reading of "light", not a failure to check.

**Omarchy.** Ask the compositor, not the file, since the file may be newer than the session:

```sh
omarchy theme current                      # Tokyo Night
hyprctl getoption general:gaps_in          # css gap data: 0 0 0 0
hyprctl getoption general:border_size      # int: 1
```

A partial state is the one worth catching here — the lua written but never reloaded, so the
config says 0 and the screen still has gaps.
