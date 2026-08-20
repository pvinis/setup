---
step: cursor-size
want: cursor at 1.5x the platform's stock size
check:
  macos: defaults read com.apple.universalaccess mouseDriverCursorSize
  omarchy: printenv XCURSOR_SIZE
---

# Cursor size

I want the pointer at **1.5x whatever the platform ships as stock**. That's the step. The
number you end up writing is *derived* per platform, not stored here — platforms express
cursor size in different units, and their stock values move.

## macOS

The setting already *is* a multiplier, 1.0 stock to 4.0 huge, so the intent is literal:
**1.5**.

```sh
defaults write com.apple.universalaccess mouseDriverCursorSize -float 1.5
```

Key missing entirely = macOS is at stock 1.0, so the step has never run. Log out and back
in afterwards; some apps hold the old cursor until then.

GUI: System Settings > Accessibility > Display > Pointer > Pointer size.

## Omarchy (Hyprland)

Pixels here, not a multiplier — so read the stock value and multiply it:

```sh
grep XCURSOR_SIZE /usr/share/omarchy/default/hypr/envs.lua
```

Stock was **24** when this was written, making 1.5x = **36**. Recompute rather than trusting
that number: Omarchy owns that file and an update can move it.

Don't edit the defaults; they're package-owned and an update overwrites them. Put the
override in `~/.config/hypr/looknfeel.lua`, which `hyprland.lua` requires *after* Omarchy's
defaults:

```lua
hl.env("XCURSOR_SIZE", "36")
hl.env("HYPRCURSOR_SIZE", "36")
```

GTK apps keep their own setting:
`gsettings set org.gnome.desktop.interface cursor-size 36`.

`check` only reads true inside a Hyprland session — over plain ssh `XCURSOR_SIZE` is unset
even when the step is done. Don't take that as "not done".
