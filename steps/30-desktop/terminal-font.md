# Terminal font

Iosevka in the terminal, at a size that's comfortable on this panel. One intent, and the
most spread-out step in the group: **four config files, two font families, and a size that
isn't a terminal setting at all.**

**Prerequisite: the font has to be installed.** That's [`apps.md`](../20-packages/apps.md)'s
job — `ttf-iosevka-nerd` on Arch — and it's where the plain-vs-Nerd-Font package divergence
is already written down. Every value below is a family *name*: nothing here installs
anything, and a name that doesn't resolve fails silently, falling back to whatever
fontconfig picks next rather than erroring.

Colours are not part of this. Each terminal config *imports* the theme file that
[`appearance.md`](appearance.md) switches, so the two steps own different lines of the same
file and never collide.

## Two families, on purpose

The Nerd Font patcher ships three widths of Iosevka and I use two of them:

- **`Iosevka Nerd Font Mono`** — single-cell metrics. This is what every terminal pins by
  name, because a terminal grid wants every glyph one cell wide.
- **`Iosevka Nerd Font`** — the dual-width build. This is what the generic **`monospace`**
  alias resolves to, so the Omarchy bar, Qt apps and anything else asking for "monospace"
  get full-size wifi and volume glyphs instead of icons squeezed into one cell.

That split lives in `~/.config/fontconfig/fonts.conf` — a genuine **override file**,
loaded after the package-owned default, and one Omarchy never copies over:

```xml
<match target="pattern">
  <test name="family" qual="any"><string>monospace</string></test>
  <test name="family" qual="all" compare="not_eq"><string>Iosevka Nerd Font Mono</string></test>
  <edit name="family" mode="prepend_first" binding="strong"><string>Iosevka Nerd Font</string></edit>
</match>
```

**The second test is load-bearing and not obvious.** fontconfig's system config appends the
generic `monospace` family to the pattern of *any* monospaced font, so the first test alone
also matches the terminals' explicit `Iosevka Nerd Font Mono` request and hijacks it back to
the dual-width build — cells twice as wide as they should be. Skipping any pattern that
already names Mono is what keeps the terminals intact.

## Size is one knob for the whole desktop, not a terminal setting

Omarchy drives shell text, GTK text and terminal text from a single number, and the terminal
point size is **derived** from it:

```sh
omarchy display text size 15
```

That one command writes three things, anchored so that 12px is stock:

| What | Where | How it's derived from 15px |
| --- | --- | --- |
| Shell base size | `~/.config/omarchy/shell.toml`, `[font] base-size` | the value itself — `15` |
| Terminal point size | every terminal config that exists | `round(px × 9 / 12)` → **11** |
| GTK text scaling | `org.gnome.desktop.interface text-scaling-factor` | quantised so the 11pt interface font lands whole → **1.2727** |

**So don't write `11` anywhere.** It's today's worked example, the same way `36` is in
[`cursor-size.md`](cursor-size.md); the value I actually hold is 15px, and the 9/12 anchor
is Omarchy's to move. Setting a terminal's size by hand is how the three drift apart.

`shell.toml` is the one file in `~/.config/omarchy/` that's a real override — absent by
default, watched for changes, layered on top of the active theme so it survives theme
switches. That's the opposite of `shell.json` next door in [`bar.md`](bar.md).

## The family is the other command, and it has two traps

```sh
omarchy font set "Iosevka Nerd Font Mono"
```

It writes the family into all four terminal configs *and* regenerates
`~/.config/fontconfig/fonts.conf`. Both traps are in that second half:

- **It resets foot to size 9.** The size is hardcoded in the script — it rewrites foot's
  whole `font=` line as `font=<family>:size=9` rather than editing the family in place. The
  other three terminals keep their size. So running it undoes the size step, for one
  terminal only, which is exactly the kind of half-change that reads as fine.
- **It overwrites the Mono/non-Mono split above**, replacing `fonts.conf` with a plain
  single-family version. The bar goes back to squeezed glyphs.

So after ever running it: re-run `omarchy display text size 15`, and restore `fonts.conf`.
The file carries a comment saying so; leave that comment there. On a machine that's already
right, don't run it at all — the family is already in every config.

## Which terminals

Set the font in **every terminal config that exists**, and don't install a terminal in order
to configure one. Those aren't the same test, and on this machine they disagree: only
`foot` is installed, while all four configs are present because Omarchy ships copies of them
regardless. Omarchy's own commands take the same line — they check for the file, not the
binary — so three of these four files are correct and inert, ready if the terminal ever
arrives.

| Terminal | Config | Family line | Size line |
| --- | --- | --- | --- |
| foot *(installed here)* | `~/.config/foot/foot.ini` | `font=Iosevka Nerd Font Mono:size=11` | same line |
| alacritty | `~/.config/alacritty/alacritty.toml` | `[font]` `normal`/`bold`/`italic` `family` | `size = 11` |
| kitty | `~/.config/kitty/kitty.conf` | `font_family Iosevka Nerd Font Mono` | `font_size 11.0` |
| ghostty | `~/.config/ghostty/config` | `font-family = "Iosevka Nerd Font Mono"` | `font-size = 11` |

All four are **shipped copies**: Omarchy installs them with full default contents, so
`omarchy refresh config foot/foot.ini` restores JetBrainsMono at 9. Nothing overrides them
from outside, so the copy is where the value has to live — knowingly, and worth re-checking
after a refresh.

**A written config isn't a running terminal.** kitty and ghostty reload on a signal
(`pkill -USR1 kitty`, `pkill -SIGUSR2 ghostty`) and Omarchy's commands send those for you.
**foot has no reload signal at all** — a running foot keeps its startup font until it's
closed, and only new windows pick the change up. `omarchy display text size` notices this and
posts a notification saying to restart foot; that notification is the step telling you it
isn't finished.

## macOS

The three cross-platform terminals read the **same paths** on macOS —
`~/.config/ghostty/config`, `~/.config/kitty/kitty.conf`,
`~/.config/alacritty/alacritty.toml` — so the family and size lines above transfer verbatim.
What doesn't transfer is everything around them: no Omarchy ships or refreshes those files,
so they're plain files I own outright, and there's no `omarchy display text size`, so the
point size is written directly instead of derived. Terminal.app and iTerm are `defaults`
keys and aren't captured; I don't use them.

**The font package is the gotcha, and it's a real divergence, not a naming one.** The
2026-06 Mac list has plain `font-iosevka`, which is *not* this font: no Nerd Font glyphs, and
no family called `Iosevka Nerd Font Mono` for these configs to resolve. The Mac wants the
patched build to match. Parked with the other Mac-blocked items in the map's fog.

Not yet run on a Mac.

## Knowing it's done

**Omarchy.** One command reports all three halves of the size knob:

```sh
omarchy display text size
# text size: 15 px
# gtk text-scaling-factor: 1.2726999999999999
# terminal font: 11 pt
```

The GTK factor prints with a float's worth of noise; it's the quantised `14/11`, not a value
anyone typed.

Then the family, per installed terminal — grep the config, since there's no command that
reports it:

```sh
grep '^font=' ~/.config/foot/foot.ini    # font=Iosevka Nerd Font Mono:size=11
```

And the alias the bar resolves, which is the *other* family on purpose:

```sh
fc-match monospace          # IosevkaNerdFont-Regular.ttf: "Iosevka Nerd Font" "Regular"
```

**`omarchy font current` is the check that lies here.** It's `fc-match monospace` with the
family extracted, so on this machine it prints `Iosevka Nerd Font` — correct for the bar,
and wrong as a reading of what the terminals run. Anyone checking the terminal font with it
sees a family no terminal is using and concludes the step failed. Read the terminal config
for the terminal, and `fc-match` for the bar; they are supposed to differ by that one word.

The other partial state: `omarchy display text size` reporting 11pt while the foot window
you're reading it in is still drawing at the old size. That's the missing reload, not a
failed write — open a new window.
