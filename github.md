# GitHub / SSH notes — lenovo

## Account
- GitHub: **JustJamin**
- lenovo SSH key added to GitHub account keys

## Problem
Fixed — private key existed; public half now added to GitHub

## What was checked
- `~/.ssh/authorized_keys` has one key (81 bytes) — used for machine SSH, not GitHub necessarily
- `~/.ssh/id_ed25519` (411 bytes) + `id_ed25519.pub` — key pair EXISTS, generated 2026-09-27
  - Comment: `lenovo-sysadmin`
  - Public: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlXo8qDXB6voXEb8ucEVPuM/qCqFkTsvqcw/ZrqJ2g2`
- `gh` CLI not installed
- git 2.47.3 installed

## Likely cause
The key on GitHub was not the key lenovo was trying to use — or GitHub only had a stale public half. Machine already had the pair; just needed the public half pasted into GitHub SSH keys.

## Fix options (pick one)
1. `ssh-keygen -t ed25519 -C "lenovo" -f ~/.ssh/id_ed25519` → copy public key to GitHub (`ssh-copy-id` doesn't work for GitHub; manually paste `id_ed25519.pub` content into GitHub SSH keys)
2. If a key already exists somewhere, find it with `sudo find / -name 'id_*' 2>/dev/null`

## After fix
- `ssh -T git@github.com` should reply "You've successfully authenticated"
- Then create remote repo `JustJamin/notes` and push (or push sysadmin logs later)
- Use SSH URLs for remotes (`git@github.com:JustJamin/notes.git`)

## Status
DONE — `ssh -T git@github.com` authenticates as JustJamin (exit 1 = success for -T).

## Action (next step)
1. Create GitHub repo(s): `JustJamin/sysadmin` (and `JustJamin/notes` if desired)
2. Add remote: `git remote add origin git@github.com:JustJamin/sysadmin.git`
3. Push: `git push -u origin main`
