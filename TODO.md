# sysadmin TODO — lenovo

Updated after every session. Oldest tasks first; current work at top.

## active
- [x] GitHub SSH auth — key generated + added to GitHub, `ssh -T git@github.com` now authenticates ("You've successfully authenticated")
  - [x] Create remote repo `JustJamin/sysadmin` on GitHub and add as origin
  - [x] Push local repo to origin (main branch)
- [ ] Backup SSH key from a second device (phone is currently the only key)
- [ ] fail2ban for sshd
- [ ] unattended-upgrades (security only)
- [ ] restic local repo + systemd timer
- [ ] offsite backup backend (B2 / S3 / rsync.net)
- [ ] restore test from backup
- [ ] dashboard / monitoring seed (disk, mem, journal)
- [ ] Tailscale polish (Tailscale SSH, MagicDNS)

## done
- [x] Baseline audit — full machine snapshot 2026-09-26
- [x] Create ~/repo/sysadmin project folder + README.md
- [x] Create ~/notes/ (MACHINE.md, SETUP.md, README.md)
- [x] Install git (2.47.3)
- [x] GitHub SSH key working — `ssh -T` authenticates as JustJamin
- [x] Laptop runs with lid shut — logind drop-in (lid ignored on AC + battery), console blanks after 60s (2026-10-01; lid test passed — SSH stayed connected)
- [x] etckeeper — installed 1.18.22, /etc in local git (2026-10-04)
- [x] SSH hardening — key-only, no root, AllowUsers jamin (2026-10-04; new login + password-denied tests passed)
- [x] ufw firewall — deny incoming; allow all on tailscale0 + 41641/udp (2026-10-04; new session + direct tailscale ping OK)

## blocked
- sudo requires password — some installs need `sudo`; resolve via `sudo -S` or add nopasswd for specific commands
