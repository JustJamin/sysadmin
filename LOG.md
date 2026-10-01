# sysadmin LOG — lenovo

## 2026-09-27

### Session start — project folder created

- Created `~/repo/sysadmin/` (project dir for sysadmin work)
- Files created: README.md, TODO.md, LOG.md, MACHINE.md, github.md
- git installed (2.47.3) — confirmed
- No etckeeper, ufw, fail2ban, restic yet
- Tailscale working (100.79.164.117)
- SSH key auth works; password auth not confirmed disabled yet
- Firewall: none (no ufw, no nftables)

## 2026-09-26 — Day 6 (partial)

- Created `~/notes/` with MACHINE.md, SETUP.md, README.md
- Git installed (user did `sudo apt-get install -y git` after earlier failure)
- GitHub account `JustJamin`; lenovo SSH key added to GitHub — but `ssh -T` still `Permission denied (publickey)`
- No private key found in `~/.ssh/id_*` — key may not exist or may be named differently
- User said: do not fight with git right now; notes live as plain local files

## 2026-10-01
- Added "laptop runs with lid shut" to TODO (active)
- User asked for SSH key generation for GitHub — paused pending clarification
- Created GitHub repo `JustJamin/sysadmin`, added as origin, pushed main
- New rule: commit after every change, push regularly (README step 4)
- Lid shut no longer suspends:
  - `/etc/systemd/logind.conf.d/10-lid-ignore.conf` — HandleLidSwitch / HandleLidSwitchExternalPower / HandleLidSwitchDocked = ignore (was: suspend)
  - `/etc/default/grub.d/console-blank.cfg` — adds `consoleblank=60` to kernel cmdline; `update-grub` run; tty1 blanking set to 1 min live via setterm
  - Repo copies in `configs/`; installer `scripts/apply-lid-ignore.sh` (run with sudo from a real terminal — `!` in Claude has no tty for the sudo password)
  - Verified: logind reports `ignore` x3; grub.cfg contains consoleblank=60
  - Lid test PASSED: closed lid while SSH'd in from phone, session stayed connected
  - Pending: confirm consoleblank=60 in /sys after next reboot
  - Undo: delete both drop-ins, `sudo systemctl reload systemd-logind`, `sudo update-grub`
