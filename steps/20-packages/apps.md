# Apps and fonts

The graphical things — apps I click on, and the font everything renders in. Same
desired-state idea as [`cli-tools.md`](cli-tools.md): this says what I want present, and most
of it may already be there.

Separate from the CLI tools for two reasons that have nothing to do with which package
manager ships them. These need a display, so they're the part of the runbook that a headless
machine skips wholesale. And on macOS some of them come from the App Store, which means a
signed-in Apple account — a human beat that no command-line tool needs.

Split by nature, not by channel: `1password-cli` is distributed as a Homebrew *cask* on
macOS but works fine over ssh, so it lives with the CLI tools, not here.

## The list

- **1Password** — installed by
  [`../00-human/1password-signin.md`](../00-human/1password-signin.md), which has to run
  first anyway. Not repeated here.
- **Syncthing** — file sync.
- **Beeper** — one client for all the chat networks.
- **Helium** — browser.
- **Voxtype** — push-to-talk voice-to-text. **Linux only**; it has no macOS build, so there's
  nothing to install there. If I want the same thing on a Mac it'll be a different app, and
  that's a fresh decision rather than a translation of this line.
- **OBS Studio** — screen recording. Omarchy ships it, so it's already here; that is not the
  same as it being unwanted, and on a Mac nothing would install it.
- **Iosevka, Nerd Font build** — the terminal font.

**A package the platform already ships is still a package I want.** Omarchy's base manifest
carries `obsidian`, `chromium` and `obs-studio`, so none of them appear in a diff of this
machine against that manifest — and a list built from such a diff drops them silently. That's
the delta thinking this step opens by warning against, and it's an easy trap because the
delta *looks* right on the machine it was built on. The test is whether I want it on a fresh
Mac, not whether it's missing here.

**Chromium is the exception, and it isn't really an app.** Omarchy uses it as the fallback
browser for web apps (`omarchy-launch-webapp`), the default in `mimeapps.list`, and the
backing for picture-in-picture and part of the menu. Platform infrastructure that happens to
be a browser, so it isn't a choice this list gets to make.

**Not wanted, despite being installed:** Obsidian. Omarchy ships it and I don't use it.
Written down because the *absence* of a decision already caused one — a login step got
drafted for it on the assumption it was wanted. A negative earns a line here only when the
positive was previously assumed; this is not the start of an inventory of everything Omarchy
ships that I don't use. And nothing here *uninstalls* it: a step that removes an OS-shipped
package is a fight re-fought on every update, so if I want it gone from a machine that's a
one-off by hand.

Installing Syncthing is not the same as running it: it ships a user service that is **not
enabled by default**, and it's currently installed-but-disabled on `hookers-green`. Decide
deliberately whether this machine should sync, then `systemctl --user enable --now syncthing`
if so. A missing service is not a failed install.

On the font: this box has the **Nerd Font** build, which is patched with extra glyphs that
prompts and file managers use. The 2026-06 Mac list has plain `font-iosevka`, which is a
genuinely different package — not a naming difference. Resolve which one I actually want
when there's a Mac in front of us rather than guessing now.

Everything else from the old Mac Brewfile — 62 casks including whole sections named "try"
and "random silly ones" — was walked in
[#12](https://github.com/pvinis/setup/issues/12) and **does not come over**. Every
cross-platform entry there had already been rejected by simply not being installed on this
machine; what remains is macOS-only (`raycast`, `bartender`, `fantastical`, `arq`,
`rectangle-pro`…) and can't be judged without a Mac in front of me, so it waits for one
rather than being guessed at now.

## Omarchy / Arch

All of these are packages like any other: `pacman -S --needed` for the repos, `yay -S` for
the AUR. Beeper, Helium and Voxtype are AUR `-bin` packages (prebuilt, no compile).

1Password comes from Omarchy's own repo rather than the AUR, which is worth knowing before
reaching for `yay`.

There is no separate "app store" concept here, and nothing to sign in to.

## macOS

`brew install --cask` for most of it, `brew install --cask font-iosevka…` for the font.

For anything the App Store distributes and Homebrew doesn't, use **`mas`** — it's a Homebrew
formula (`brew install mas`) that drives the App Store from the command line, so it isn't a
separate mechanism to learn, just another `brew`-installed tool. Two apps genuinely need it,
because Apple ships them nowhere else:

- TestFlight — `mas install 899247664`
- Transporter — `mas install 1450874784`

Those numeric ids are the App Store's identity for an app, not a version, so they're safe to
write down.

**Prefer a cask wherever both exist.** `mas` is the fallback for App Store exclusives, not a
general channel — it needs a signed-in account and it can't install anything the account
hasn't "purchased", including free apps.

**Prerequisite:** `mas` needs the App Store signed in —
[`../00-human/app-store-signin.md`](../00-human/app-store-signin.md). Skip that and `mas
install` fails on apps that were never associated with the account, while quietly succeeding
on ones that were, which makes for a confusing half-done state.

## Knowing it's done

Ask whether the app is installed, in whatever way the platform actually answers that:

- **Arch**: `pacman -Qq <name>` exits non-zero when it isn't there. `pacman -Qqe` alone
  won't do — a package pulled in as a dependency is still installed.
- **macOS**: `brew list --cask <name>`, and `mas list` for the App Store ones.

For the font, don't check the package — check that the system can see it, since a font can be
installed into a location nothing scans:

```sh
fc-list | grep -i iosevka
```

Never-ran looks like everything missing at once. The state worth catching is the partial one:
the AUR packages installed but the App Store ones absent, which is what an unsigned-in Mac
produces.
