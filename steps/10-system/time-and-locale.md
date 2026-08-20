# Time, locale and keyboard

The clock right for where I am, the keyboard US, everything `en_US.UTF-8`. Same
desired-state idea as the package steps: both OS installers ask these questions, so on a
machine I just installed this is usually a no-op. Check it anyway — a machine that came
from someone else, or one imaged from a template, is where this actually bites.

Timezone is the one that genuinely varies per machine. `Europe/Athens` is right for the
ones I sit in front of; a server somewhere else may want UTC. Ask if it isn't obvious.

## Omarchy / Arch

```sh
sudo timedatectl set-timezone Europe/Athens
sudo localectl set-locale LANG=en_US.UTF-8
sudo localectl set-keymap us
sudo localectl set-x11-keymap us pc105
```

`set-locale` only works for a locale that's been generated — the Arch installer does that
for whatever you picked. If `localectl list-locales` doesn't list it, uncomment the line in
`/etc/locale.gen` and run `sudo locale-gen` first.

**The keyboard knob is `localectl`, not a Hyprland setting.** Omarchy derives Hyprland's
layout from `/etc/vconsole.conf` — `default/hypr/input.lua` reads `XKBLAYOUT` out of it at
config load and feeds it to `hl.config`, adding a `us,` prefix when the layout is one that
can't type Latin letters (otherwise the SUPER bindings stop firing). So setting the console
keymap is what moves the desktop, and hand-writing `kb_layout` into `~/.config/hypr/input.lua`
would fight that logic rather than replace it. The running compositor keeps the old layout
until the config reloads.

Time sync is on by default (`systemd-timesyncd`); `timedatectl` reports it.

## macOS

```sh
sudo systemsetup -settimezone Europe/Athens
```

Language, region and input sources live in System Settings > General > Language & Region and
> Keyboard > Input Sources. The `defaults` keys behind them (`AppleLocale`,
`AppleEnabledInputSources`) are an awkward plist to write by hand for a once-per-machine
setting, and US English is what a Mac I buy ships with — so read them, and only if one is
wrong, fix it in the GUI:

```sh
defaults read -g AppleLocale        # expect en_US
defaults read -g AppleLanguages     # expect (en-US)
```

Reasoned, not yet run on a Mac.

## Knowing it's done

```sh
timedatectl && localectl              # Linux: timezone, NTP, LANG, keymaps in one shot
date && systemsetup -gettimezone      # macOS (the second needs sudo)
```

The lie to watch for is the **desktop vs the system** split: `localectl` can report `us`
while the Hyprland session is still running the layout it read at login, and `date` in an
old shell can be right while a long-running app holds the previous timezone. Type something
and look at the clock in the bar; that's the reading that matters.
