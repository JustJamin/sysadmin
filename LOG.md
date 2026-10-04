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

## 2026-10-04
- etckeeper installed (1.18.22-2) via `scripts/install-etckeeper.sh`
  - VCS=git; `/etc/.git` is `drwx------ root:root`; first commit `654c60e Initial commit`
  - No remotes — /etc repo must stay local (contains /etc/shadow, SSH host private keys)
  - Repo-local identity: `root (lenovo) <root@lenovo>`
  - etckeeper.timer enabled (daily ~08:14) + apt pre/post hooks
  - Useful: `sudo git -C /etc log --oneline`, `sudo git -C /etc status -s`, `sudo etckeeper commit "msg"` after manual /etc edits
- README: fixed stale etckeeper + GitHub status lines- SSH hardening via `scripts/apply-ssh-hardening.sh`
  - Pre-check: journal showed all logins over last 7 days were `Accepted publickey` with Termius key SHA256:bMBcakii… (matches only key in authorized_keys)
  - Drop-in `/etc/ssh/sshd_config.d/10-hardening.conf`: PasswordAuthentication no, KbdInteractiveAuthentication no, PermitRootLogin no, PermitEmptyPasswords no, AuthenticationMethods publickey, AllowUsers jamin, MaxAuthTries 3, LoginGraceTime 30, X11Forwarding no
  - `sshd -t` passed; `systemctl reload ssh`; etckeeper committed
  - Verified: new Termius login works; `ssh -o PubkeyAuthentication=no jamin@localhost` → `Permission denied (publickey)`
  - Undo: `sudo rm /etc/ssh/sshd_config.d/10-hardening.conf && sudo systemctl reload ssh`
  - Note: sshd still listens on 0.0.0.0:22 — restrict to Tailscale with ufw (next)
  - Risk: phone is the only key — consider a backup key from a second device
- ufw firewall via `scripts/apply-ufw.sh`
  - Rules: default deny incoming + routed, allow outgoing; `allow in on tailscale0` (all ports — SSH/SFTP/Taildrop/future services); `allow 41641/udp` (Tailscale direct)
  - Applied with 5-min dead-man timer (`systemd-run --unit=ufw-deadman ... ufw disable`); new Termius session worked, timer stopped
  - Verified: ENABLED=yes in /etc/ufw/ufw.conf; `tailscale ping poco-f7-ultra` → direct via 192.168.0.35 (not DERP)
  - Not yet tested: LAN SSH to 192.168.0.18 blocked (phone with Tailscale off); `sudo apt update` still works
  - Rollback: `sudo ufw disable`
  - Adding a new tailnet device: no firewall change needed; add its SSH key to ~/.ssh/authorized_keys

