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

Already done if `defaults read com.apple.universalaccess mouseDriverCursorSize` prints
`1.5`. If the key is missing entirely, macOS is sitting at its stock 1.0 and this has never
run — that's not an error.

Log out and back in afterwards; some apps hold the old cursor until then.

In the GUI: System Settings > Accessibility > Display > Pointer > Pointer size.

## Omarchy (Hyprland)

Pixels here, not a multiplier — so read the stock value and multiply it:

```sh
grep XCURSOR_SIZE /usr/share/omarchy/default/hypr/envs.lua
```

Stock was **24** when this was written, making 1.5x = **36**. Recompute rather than trusting
that number; Omarchy owns that file and an update can move it.

Don't edit Omarchy's defaults — they're package-owned and an update overwrites them. Put the
override in `~/.config/hypr/looknfeel.lua`, which `hyprland.lua` requires *after* the
defaults:

```lua
hl.env("XCURSOR_SIZE", "36")
hl.env("HYPRCURSOR_SIZE", "36")
```

GTK apps keep their own setting:

```sh
gsettings set org.gnome.desktop.interface cursor-size 36
```

Already done if `printenv XCURSOR_SIZE` prints 36 **inside a Hyprland session**. It won't
over plain ssh — that variable only exists in the compositor's session, so a missing value
from the wrong vantage point isn't "not done".
