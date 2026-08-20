# Name the machine

My machines are named after colours — `cyan`, `royal-purple`, `lavender`, `medium-blue`,
`hookers-green`. Pick one that isn't taken. The name ends up in shell prompts, on the
network, in 1Password item names and in `~/THIS-MACHINE.md`, so it wants to be short,
lowercase and hyphenated.

Do this **first among the things the agent can do alone**. Everything that records *which*
machine it is should be recording the real name rather than `archlinux` or
`Pavlos's MacBook Pro`, and renaming afterwards means chasing the copies.

## Ask me for the name

> Which colour is this machine? Taken so far: cyan, royal-purple, lavender, medium-blue,
> hookers-green. Anything lowercase-and-hyphenated that isn't on that list.

That's an ask, not a human step — I answer a question, the agent does the work.

## Omarchy / Arch

```sh
sudo hostnamectl set-hostname hookers-green
```

Nothing else to keep in sync. The usual Arch advice is to add the hostname to `/etc/hosts`
too, but Omarchy ships that file with `localhost` entries only and no hostname line, so
there's nothing there to edit and adding one is not required.

## macOS

macOS keeps **three** names and the GUI only sets one of them, so set all three by hand:

```sh
sudo scutil --set ComputerName  "hookers-green"   # what Finder and Sharing show
sudo scutil --set HostName      "hookers-green"   # the network / ssh name
sudo scutil --set LocalHostName "hookers-green"   # the Bonjour <name>.local name
sudo dscacheutil -flushcache
```

`LocalHostName` can't contain spaces; if a name ever does, hyphenate it there.

Reasoned from the old `setup2` script, not yet run on a Mac.

## Knowing it's done

```sh
hostnamectl --static          # Linux
scutil --get ComputerName && scutil --get HostName && scutil --get LocalHostName   # macOS
```

Two ways the check can lie:

- **The running shell keeps the old name.** `$HOSTNAME` was set when the shell started, and
  the prompt with it. A fresh shell is the honest reading; `hostnamectl --static` reads the
  file and is right immediately.
- **macOS renames only ComputerName** when you use System Settings > General > About > Name,
  leaving `LocalHostName` on the old value — so a machine can look renamed and still
  announce itself as `pavloss-macbook-pro.local`. Check all three, not one.

Never-ran looks like the installer's default: `archlinux` on Arch, `Pavlos's MacBook Pro`
(or `Mac`) on macOS.
