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

## How a later step asks for a secret

Nothing is fetched here. This step's whole output is *access* — after it, any later step that
needs a secret reads it at the moment it needs it, addressed as a single readable path:

```
op://Private/<item>/<field>
```

That form is the one thing worth keeping from the older repos, and what rotted tells you why.
`pvinis/dotfiles` went through three generations: git-crypt, then opaque item uuids, then
this. The uuid generation is the one that broke — stale references were indistinguishable
from working ones on sight, and some copies silently rendered literal garbage into files
rather than failing. A readable vault/item/field path can be eyeballed by a human or an agent
and found wrong.

**No secret is ever copied into this repo or into a file the runbook manages**, and there is
no restore list. The git-crypt era kept an inventory of files to decrypt onto a new machine
(`~/.npmrc`, `~/.aws/credentials`, `~/.config/hub`, an `.ask/` directory); none of them exist
on this machine, and each is a file whose value *is* its contents, which
[`../README.md`](../README.md) puts outside what a step can carry. So the chain of trust
stops here, at the vault being readable.

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

`op whoami` alone is the convenient proxy, not the authoritative source, and everything
downstream now hangs off this one check — it can pass while a read still fails, because being
signed in and having the vault shared to *this* account are different things. So prove the
vault is actually reachable:

```sh
op vault list
```

`Private` in the output means a later `op://Private/...` read has somewhere to resolve
against. That's a real authenticated call rather than a look at local session state.

Deliberately no named item here. A stronger canary would read one known field, but this repo
is public and the item titles are themselves worth not publishing — the same reason the work
tenant name came out of this file in
[#10](https://github.com/pvinis/setup/issues/10). Vault-level is as far as a public step
should go; if a read fails after this passes, it's a sharing problem on one item, and the
error says so.
