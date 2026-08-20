---
step: 1password-signin
applies:
  display: headed
check:
  all: op whoami
---

# Sign in to 1Password

Root of trust. Nothing downstream that needs a secret can run until this is done.

## Install it

- Arch / Omarchy: `yay -S 1password 1password-cli`
- macOS: `brew install --cask 1password` and `brew install 1password-cli`

## Hand it to Pavlos

I can't do this part — GUI app, account password, second factor.

> Open 1Password, sign in to **my.1password.com** (pvinis@gmail.com), complete 2FA, then
> Settings > Developer > enable **"Integrate with 1Password CLI"**. Tell me when done.

Work account (leanscaper.1password.com) is a separate sign-in. Ask whether this machine
needs it.

## Reading the check

`op whoami` prints account URL and email when usable. `account is not signed in` means the
CLI knows the account but has no session — app locked or integration off. Ask for an
unlock; don't reinstall.

## Where the frontmatter lies

`applies: display: headed` says *skip on headless*. That's wrong — on headless the step
still applies, it just has a **different procedure** (service account token, or
`op account add` + `op signin`). "Applies / doesn't apply" is a boolean, and this is a
branch. Either `applies` grows a third value, or the headless variant becomes its own step.
