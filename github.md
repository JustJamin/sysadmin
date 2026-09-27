# GitHub / SSH notes — lenovo

## Account
- GitHub: **JustJamin**
- lenovo SSH key added to GitHub account keys

## Problem
`ssh -T git@github.com` → `Permission denied (publickey)`

## What was checked
- `~/.ssh/authorized_keys` has one key (81 bytes) — used for machine SSH, not GitHub necessarily
- No private key found in `~/.ssh/id_*` — no `id_ed25519`, `id_rsa`, etc.
- `gh` CLI not installed
- git 2.47.3 installed

## Likely cause
The key on GitHub is not the key lenovo is trying to use — or no private key exists on the machine at all (GitHub only has the public half, machine never generated the pair).

## Fix options (pick one)
1. `ssh-keygen -t ed25519 -C "lenovo" -f ~/.ssh/id_ed25519` → copy public key to GitHub (`ssh-copy-id` doesn't work for GitHub; manually paste `id_ed25519.pub` content into GitHub SSH keys)
2. If a key already exists somewhere, find it with `sudo find / -name 'id_*' 2>/dev/null`

## After fix
- `ssh -T git@github.com` should reply "You've successfully authenticated"
- Then create remote repo `JustJamin/notes` and push (or push sysadmin logs later)
- Use SSH URLs for remotes (`git@github.com:JustJamin/notes.git`)

## Status
BLOCKED — waiting on user decision (or fresh key generation). Do not force.
