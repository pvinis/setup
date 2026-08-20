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

### Persist it

Don't edit Omarchy's defaults — they're package-owned and an update overwrites them. Put the
override in `~/.config/hypr/looknfeel.lua`, which `hyprland.lua` requires *after* the
defaults:

```lua
hl.env("XCURSOR_SIZE", "36")
hl.env("HYPRCURSOR_SIZE", "36")
```

GTK apps keep their own setting, and this one does take effect immediately:

```sh
gsettings set org.gnome.desktop.interface cursor-size 36
```

### That config is inert until the next login, and `hyprctl reload` will not help

The session runs under **UWSM**, which exports `XCURSOR_SIZE`/`HYPRCURSOR_SIZE` into the
systemd and dbus environments exactly once, at login — see `UWSM_FINALIZE_VARNAMES` in the
compositor's environ. Hyprland applies `env` only at startup too. So `hyprctl reload`
returns `ok` and changes nothing about the cursor.

Either log out and back in, or apply to the running session as well:

```sh
hyprctl setcursor Adwaita 36
systemctl --user set-environment XCURSOR_SIZE=36 HYPRCURSOR_SIZE=36
dbus-update-activation-environment --systemd XCURSOR_SIZE=36 HYPRCURSOR_SIZE=36
```

Two traps in those three lines:

- **The theme name is derived, not fixed.** `XCURSOR_THEME` is unset here and the `default`
  icon theme merely inherits Adwaita, which is why `Adwaita` is the name that works. No
  hyprcursor themes are installed, so Hyprland is on the XCursor fallback path. Check what
  the session actually uses before assuming.
- **Pass the values explicitly to `dbus-update-activation-environment`.** Given bare
  variable names it reads them from the calling shell — and if that shell predates the
  change, it silently writes the old value back over the new one.

### Knowing it's done

```sh
systemctl --user show-environment | grep -E '^(X|HYPR)CURSOR_SIZE'
```

That is the session's authoritative environment. **`printenv` is not**: any shell older than
the change reports the stale value, including the one the agent is running in, which makes a
finished step look unfinished and an unfinished one look done. Confirm by looking at the
cursor.
