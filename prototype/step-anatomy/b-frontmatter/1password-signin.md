---
step: 1password-signin
want: 1Password signed in, with the CLI integration live
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
> Settings > Developer > enable **"Integrate with 1Password CLI"**. Tell me when that's
> done.

Then re-run the check. The work account (leanscaper.1password.com) is a separate sign-in —
ask whether this machine needs it, don't assume either way.

## Reading the check

`op whoami` prints the account URL and email when it's genuinely usable.

- **`account is not signed in`** — the CLI knows the account but has no session. App locked,
  or the CLI integration is off. Ask for an unlock; don't reinstall anything.
- **`op account list` prints nothing** — the CLI has never been told about the account. That
  is the real never-ran state.
