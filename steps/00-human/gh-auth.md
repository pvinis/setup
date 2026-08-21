# Sign in to GitHub

`gh` authenticated as **pvinis**, and git able to push over HTTPS without asking anyone for a
password. Everything this machine does with GitHub goes through that one token — there is no
SSH key and no signing key, deliberately (see below).

Needs `gh`, from [`../20-packages/cli-tools.md`](../20-packages/cli-tools.md). Needs nothing
else: `pvinis/setup` is public, so the clone that got you here required no credential at all.

## Hand it to Pavlos

Human end to end — a browser, an account password, a second factor. The agent can start the
command, but it cannot finish it, so this is a `00-human/` step rather than a step with a
human beat in it.

> Run `gh auth login`. Choose **GitHub.com**, **HTTPS**, and **authenticate in a browser**.
> It prints a one-time code — paste that into the browser page it opens, sign in, and
> authorise. Tell me when it's done.

Take the HTTPS option rather than SSH on purpose. This account has **no SSH keys registered
at all**, which is ten years of not needing one rather than an oversight, so the runbook
doesn't create one either.

## Repair the credential helper

`gh auth login` writes a credential helper into `~/.gitconfig` and writes it **wrong** — not
as a mistake you made, but as what the tool does when `gh` is mise-managed. It resolves `gh`
to a real path at the moment it runs:

```
[credential "https://github.com"]
	helper = 
	helper = !/home/pavlos/.local/share/mise/installs/gh/2.97.0/gh_2.97.0_linux_amd64/bin/gh auth git-credential
```

That absolute path points into a **versioned** install directory. The next `gh` upgrade moves
the binary out from under it and git silently loses its helper on every push — silently
because git treats a helper that fails to run as a helper with nothing to say, so you get a
username prompt instead of an error naming the cause.

So the step's job is to *correct* what the previous command just wrote, on every machine.
The fix is `!gh auth git-credential` — PATH-resolved, so it survives any version of `gh` in
any install location. Applied to both blocks, because `gh` writes `gist.github.com`
separately and it breaks the same way:

```sh
for host in github.com gist.github.com; do
  git config --global --unset-all "credential.https://$host.helper" '/' 2>/dev/null
  git config --global --get-all "credential.https://$host.helper" 2>/dev/null \
    | grep -qxF '!gh auth git-credential' \
    || git config --global --add "credential.https://$host.helper" '!gh auth git-credential'
done
```

**Leave the empty `helper = ` line above each one alone.** It isn't leftover junk — an empty
value is git's reset directive, clearing helpers inherited from earlier config files.
Dropping it changes which helpers run.

That's why the loop is shaped the way it is, and it's worth knowing why the two obvious
one-liners are both wrong, because both *look* like they work:

- **`--replace-all … '!/.*'`** — a value-pattern starting with `!` is git's **negation**
  operator, not a literal. It inverts to "values without a slash", which is the reset line,
  so it overwrites the reset directive and leaves the broken helper untouched. The exact
  opposite of the intent, and the config still looks plausible afterwards.
- **`--replace-all … '/'`** — correct the first time, then **adds a duplicate every time it
  finds nothing to replace**. Three runs of the step, three helpers. Steps get re-run, so
  that's a real outcome, not a hypothetical.

Hence: unset what matches, then add only if it isn't already there. Unsetting a pattern that
matches nothing exits non-zero and changes nothing, which is why it's swallowed.

## Knowing it's done

```sh
gh auth status
```

Reports the account, the protocol, and where the token lives. The never-ran state is
`You are not logged into any GitHub hosts`.

**The token is not in a file**, which matters when you go looking for it. On this machine
`gh auth status` reports it in the **keyring** (gnome-keyring here, Keychain on macOS) and
`~/.config/gh/hosts.yml` is 80 bytes of `git_protocol` and a username — no secret in it. The
2026-06 Mac snapshot calls that file secret and git-ignores it on that basis; on a keyring
machine that's simply not true any more.

Then prove the helper repair took, which is the check that can actually fail later:

```sh
git config --get-all credential.https://github.com.helper
```

Expect a blank line (the reset) then `!gh auth git-credential`. **Any absolute path in that
output is the defect back**, whether or not pushing works today — it works right up until the
next `gh` upgrade, so a passing push is not evidence.

The end-to-end check is a push to any repo you can write to; there's nothing to configure for
it beyond the above.

## Scopes

The login asks for what `gh` itself needs and the runbook adds nothing: `gist`, `read:org`,
`repo`, `workflow`. Notably **absent** are `admin:public_key`, `admin:gpg_key` and
`admin:ssh_signing_key` — a token that can register keys on the account is a token that can
grant a machine's access, and nothing in the runbook registers keys, so it doesn't ask for
the ability to. If you ever need one for a one-off, `gh auth refresh -h github.com -s <scope>`
adds it for that job rather than baking it into every machine.
