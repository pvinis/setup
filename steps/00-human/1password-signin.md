# Sign in to 1Password

1Password is the root of trust: the GPG key, tokens, and anything else with a secret in it
come out of here, so nothing downstream that needs a secret can run until this is done.

## Install it

- Arch / Omarchy: `yay -S 1password 1password-cli`
- macOS: `brew install --cask 1password` and `brew install 1password-cli`

## Hand it to Pavlos

I can't do this part — GUI app, account password, second factor.

> Open 1Password, sign in to the **my.1password.com** account (pvinis@gmail.com), and
> complete 2FA. Then in Settings > Developer, turn on **"Integrate with 1Password CLI"**.
> Tell me when that's done.

Then re-run the check below. The work account is a separate sign-in — ask whether this
machine needs it, don't assume either way.

## Knowing it's done

```sh
op whoami
```

Prints the account URL and email when it's genuinely usable. Two failures look similar and
mean opposite things:

- **`account is not signed in`** — the CLI knows the account but has no session. The app is
  locked, or the CLI integration is off. Ask for an unlock; don't reinstall anything.
- **`op account list` prints nothing** — the CLI has never been told about the account at
  all. That's the real never-ran state.
