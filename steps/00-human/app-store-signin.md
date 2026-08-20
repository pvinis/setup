# Sign in to the App Store

**macOS only.** Nothing on Linux needs this, and a headless Mac doesn't either.

`mas` can only install apps the signed-in Apple account already has — including free ones,
which still have to have been "got" once. So this gates the App Store half of
[`../20-packages/apps.md`](../20-packages/apps.md), and nothing else.

Needs [`1password-signin.md`](1password-signin.md) done first: the Apple account password
lives in 1Password.

## Hand it to Pavlos

GUI app, Apple ID password, second factor — I can't do any of it.

> Open the **App Store** app and sign in with my Apple ID. If it prompts for 2FA and the
> trusted device is a phone rather than this machine, you'll need that to hand.
> Tell me when you're in.

## Knowing it's done

```sh
mas account
```

Prints the signed-in Apple ID. The failure modes read very differently:

- **`Not signed in`** — the real never-ran state.
- **`mas: command not found`** — `mas` itself isn't installed yet. That's the apps step's
  job, not a sign-in problem; don't send me to the App Store over it.

On recent macOS versions `mas account` has been known to fail even when signed in, because
Apple removed the private API it used. If it errors rather than reporting a status, confirm
by eye in App Store > account menu, and treat a successful `mas list` as the real signal.
