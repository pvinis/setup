# Xcode Command Line Tools

**macOS only.** The compiler toolchain and `git`, and the thing Homebrew refuses to install
without. Nothing else on a Mac happens until this is done, so it's the agent's **first move
there** — before packages, before anything that shells out to `git`.

Deliberately not part of the bootstrap ([#9](https://github.com/pvinis/setup/issues/9)):
`mise` and `claude` are release binaries that need no compiler, so the agent comes up first
and this becomes work it drives rather than a ten-minute wait at the top of the README.

This is the step that's **mostly automatic with one human beat in the middle**. It stays here
rather than in `00-human/` — the agent runs the command, waits, and verifies; I only click a
button. `00-human/` is for the steps that are human end to end.

## Do it

```sh
xcode-select --install
```

A GUI dialog appears — that's the beat:

> A macOS dialog just opened: **Install Command Line Tools**. Click **Install**, then
> **Agree** to the licence. It's a few hundred MB, so it'll take a while.

Then wait it out rather than guessing:

```sh
until xcode-select -p >/dev/null 2>&1; do sleep 5; done
```

If the dialog says the software "can't be found on the server" — which happens after a
macOS upgrade — the tools are downloadable from
<https://developer.apple.com/download/all/> instead, signed in with my Apple ID.

Full Xcode from the App Store is **not** this and isn't needed.

## Knowing it's done

```sh
xcode-select -p && clang --version && git --version
```

Run all three. `xcode-select -p` alone only proves a developer directory is *configured*:
after a macOS upgrade, or a half-finished install, it can print a path whose contents are
gone, and the first `git` you run then re-opens the install dialog in the agent's face.
Actually invoking `clang` and `git` is the check you can't be wrong about.

Never-ran is unmistakable:

```
xcode-select: error: unable to get active developer directory
```

Anything that shells out to `git` — including the agent — triggers the same dialog by
accident, which is exactly why this runs first and deliberately.
