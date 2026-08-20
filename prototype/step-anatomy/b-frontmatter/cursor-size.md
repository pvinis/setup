---
step: cursor-size
applies:
  display: headed
check:
  macos: defaults read com.apple.universalaccess mouseDriverCursorSize   # want 1.5
  omarchy: printenv XCURSOR_SIZE                                         # want 36
---

# Cursor size

Make the mouse pointer a bit bigger than stock. Comfort thing.

The frontmatter is only the two things you need to *decide* with: whether this machine gets
the step at all, and whether it's already satisfied. Everything about actually doing it is
below, in prose, because it needs judgement.

## macOS

Pointer size is a **multiplier**, 1.0 (stock) to 4.0 (huge). I want **1.5**.

```sh
defaults write com.apple.universalaccess mouseDriverCursorSize -float 1.5
```

If the key is missing entirely, macOS is at its 1.0 default — the step has never run. Log
out and back in afterwards; some apps hold the old cursor until then.

GUI location: System Settings > Accessibility > Display > Pointer > Pointer size.

## Omarchy (Hyprland)

Pixels here, not a multiplier. Omarchy's stock is 24, so 1.5x is **36**.

Don't edit `/usr/share/omarchy/default/hypr/envs.lua` — package-owned, an update overwrites
it. Put the override in `~/.config/hypr/looknfeel.lua`, required *after* the defaults:

```lua
hl.env("XCURSOR_SIZE", "36")
hl.env("HYPRCURSOR_SIZE", "36")
```

GTK apps keep their own setting: `gsettings set org.gnome.desktop.interface cursor-size 36`.

The `check` only works inside a Hyprland session — over plain ssh `XCURSOR_SIZE` is unset
even when the step is done. A check that can be wrong from the wrong vantage point is a
thing the frontmatter can't express.
