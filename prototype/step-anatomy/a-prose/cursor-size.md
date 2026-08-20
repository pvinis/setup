# Cursor size

Make the mouse pointer a bit bigger than stock. Comfort thing — the default pointer is too
small for me on every machine I've used.

Skip this entirely on a headless machine. There's no pointer.

## macOS

Pointer size is a **multiplier**, 1.0 (stock) to 4.0 (huge). I want **1.5**.

```sh
defaults write com.apple.universalaccess mouseDriverCursorSize -float 1.5
```

Already done if `defaults read com.apple.universalaccess mouseDriverCursorSize` prints
`1.5`. If the key is missing entirely, macOS is sitting at its 1.0 default and this step
has never run.

Log out and back in afterwards — some apps keep the old cursor until then.

In the GUI this is System Settings > Accessibility > Display > Pointer > Pointer size.

## Omarchy (Hyprland)

Here the size is in **pixels**, not a multiplier, and Omarchy's stock value is 24
(set in `/usr/share/omarchy/default/hypr/envs.lua`). 1.5x of that is **36**.

Don't edit the Omarchy defaults — they're package-owned and an update will overwrite them.
Put the override in `~/.config/hypr/looknfeel.lua`, which `hyprland.lua` requires *after*
the defaults:

```lua
hl.env("XCURSOR_SIZE", "36")
hl.env("HYPRCURSOR_SIZE", "36")
```

GTK apps read their own setting, so set that too:

```sh
gsettings set org.gnome.desktop.interface cursor-size 36
```

Already done if `echo $XCURSOR_SIZE` prints 36 **inside a Hyprland session**. It won't over
plain ssh — that env var only exists in the compositor's session, so don't read a missing
value as "not done" if you're not on the machine's own display.
