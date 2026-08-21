# Sound

The alert sound is **Funk**, at **half volume** — audible enough to notice, quiet enough not
to make me jump when a dialog appears while music is playing. Alert volume is its own level,
independent of the output volume, which is why it can be pinned like this at all.

**macOS only.** Not because Linux is silent, but because there's no equivalent *value* to
state: Omarchy exposes no single alert-sound knob, its stock terminal configs already
silence the bell (`enable_audio_bell no`), and the freedesktop sound theme underneath is a
directory of oga files rather than a setting. Nothing here would be a sentence I could
check, so — by the values-not-files rule in [`README.md`](../README.md) — there's no Omarchy
section to write.

## macOS

| What I want | System Settings | Command |
| --- | --- | --- |
| Alert sound: Funk | Sound > Sound Effects > Alert sound | `defaults write -g com.apple.sound.beep.sound -string "/System/Library/Sounds/Funk.aiff"` |
| Alert volume 0.5 | Sound > Sound Effects > Alert volume | `defaults write -g com.apple.sound.beep.volume -float 0.5` |

**The sound is a path, not a name.** The GUI shows "Funk" in a list; the key holds
`/System/Library/Sounds/Funk.aiff`. Writing the bare string `Funk` sets a value macOS won't
resolve and the alert falls back to silence — a failure that looks exactly like a volume of
zero. A custom sound dropped in `~/Library/Sounds` is the same key with a different path.

**Half is 0.5 on a 0–1 float**, not a 0–100 percentage. It's also not the output volume:
turning the speakers up doesn't move this, and muting the alert here leaves music playing.

**Applying it now**: log out, or relaunch the app you want it in. Both keys live in
`NSGlobalDomain`, which apps read at launch, so already-running apps keep the old alert
until they restart. There's no `killall` that covers this the way `killall Dock` covers
[`dock.md`](dock.md).

## Knowing it's done

```sh
defaults read -g com.apple.sound.beep.sound   # /System/Library/Sounds/Funk.aiff
defaults read -g com.apple.sound.beep.volume  # 0.5
```

Both keys are **absent on a stock machine**, whose alert sound is whatever macOS ships as
the default that release, at full alert volume — so `defaults read` exiting non-zero is the
never-ran state and reads as "still stock".

The way this check lies: it reads the stored preference, not what you'd hear. An alert
volume of 0.5 sounds like nothing at all if the output device is muted or the alert-sound
file has been replaced with a path that doesn't exist. The honest confirmation is to trigger
a beep and listen.

Both values are captured from the Mac via `scripts/macos.sh` in `pvinis/dotfiles`; the notes
around them are reasoned and not re-run on a Mac.
