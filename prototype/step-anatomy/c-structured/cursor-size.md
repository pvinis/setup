---
step: cursor-size
summary: Pointer scaled 1.5x above each platform's stock size
applies:
  display: headed
platforms:
  macos:
    check: defaults read com.apple.universalaccess mouseDriverCursorSize
    expect: "1.5"
    apply: defaults write com.apple.universalaccess mouseDriverCursorSize -float 1.5
    after: Log out and back in.
    gui: System Settings > Accessibility > Display > Pointer > Pointer size
  omarchy:
    check: printenv XCURSOR_SIZE
    expect: "36"
    apply:
      - append_to: ~/.config/hypr/looknfeel.lua
        content: |
          hl.env("XCURSOR_SIZE", "36")
          hl.env("HYPRCURSOR_SIZE", "36")
      - run: gsettings set org.gnome.desktop.interface cursor-size 36
    after: Restart Hyprland.
---

# Cursor size

Everything actionable is in the frontmatter; this body is commentary only.

**What the schema already can't hold.** `expect: "1.5"` vs `expect: "36"` are the same
intent in different units (a multiplier vs pixels, 24 * 1.5 = 36). The schema stores two
magic numbers and loses the "1.5x of stock" that generates both — so a third platform means
a human works the arithmetic out again, and nothing catches it if they get it wrong.

**`append_to` is not idempotent.** Run this twice and `looknfeel.lua` has the block twice.
Making it safe means the schema grows `match:` / `replace:` / `unless_present:`, which is
sed with extra steps.

**`check` is vantage-dependent.** Over ssh `XCURSOR_SIZE` is unset even when the step is
done, so a bare `expect` reports a false negative. Needs a `check_requires: local-session`
or similar.
