# Sign in to 1Password

1Password is the root of trust. The GPG key, tokens, and anything else with a secret in it
come out of here, so nothing downstream that needs a secret can run until this is done.

Needs a desktop with a browser. On a headless machine this doesn't apply as written — see
the bottom.

## Install it

- Arch / Omarchy: `yay -S 1password 1password-cli`
- macOS: `brew install --cask 1password` and `brew install 1password-cli`

## Then hand it to Pavlos

I can't do this part. It's a GUI app, an account password, and a second factor.

> Open 1Password, sign in to the **my.1password.com** account (pvinis@gmail.com), and
> complete 2FA. Then in Settings > Developer, turn on **"Integrate with 1Password CLI"**.
> Tell me when that's done.

The work account (leanscaper.1password.com) is a separate sign-in. Ask whether this machine
needs it — don't assume either way.

## Check

```sh
op whoami
```

Prints the account URL and email when it's genuinely usable. Two failures that look similar
and aren't:

- **`account is not signed in`** — the CLI knows the account but has no session. This is
  what you get when the desktop integration is off, or the app is just locked. Ask Pavlos
  to unlock rather than reinstalling anything.
- **`op account list` prints nothing** — the CLI has never been told about the account at
  all. That's the real "step hasn't run" state.

## Headless

Deliberately unsolved. There's no desktop app to integrate with, so it's either a service
account token or `op account add` plus an `op signin` every session. Don't guess — ask.
