---
step: 1password-signin
summary: Sign in to 1Password and enable the CLI integration
applies:
  display: headed
platforms:
  arch:
    install: yay -S 1password 1password-cli
  macos:
    install: brew install --cask 1password && brew install 1password-cli
human:
  blocking: true
  prompt: |
    Open 1Password, sign in to my.1password.com (pvinis@gmail.com), complete 2FA,
    then Settings > Developer > enable "Integrate with 1Password CLI".
  confirm: Tell me when that's done.
check:
  run: op whoami
  expect_nonempty: true
  diagnose:
    "account is not signed in": App locked or CLI integration off. Ask for an unlock.
    "": CLI has never been told about the account. Run op account add.
---

# Sign in to 1Password

Root of trust. Commentary only; the frontmatter is the step.

**Every field here is new.** `install`, `human`, `confirm`, `expect_nonempty`, `diagnose` —
none of them existed for the cursor step, and none of the cursor step's fields (`apply`,
`expect`, `after`, `gui`) fit here. Two steps, two disjoint schemas. A schema that grows a
field per step isn't a schema.

**`applies: display: headed` is a lie**, same as in variant B: headless doesn't skip this,
it does it differently (service account token, or `op account add` + `op signin`).

**The interesting part won't fit in a field.** `op whoami` failing with *"not signed in"* vs
`op account list` coming back empty look like the same failure and mean opposite things —
one is "unlock the app", the other is "the step never ran". `diagnose:` is me trying to
encode a paragraph as a lookup table, and it reads worse than the paragraph.

**`human.prompt` is the whole step**, and it's a blob of prose wearing a YAML hat.
