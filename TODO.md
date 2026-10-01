# sysadmin TODO — lenovo

Updated after every session. Oldest tasks first; current work at top.

## active
- [x] GitHub SSH auth — key generated + added to GitHub, `ssh -T git@github.com` now authenticates ("You've successfully authenticated")
  - [x] Create remote repo `JustJamin/sysadmin` on GitHub and add as origin
  - [x] Push local repo to origin (main branch)
- [ ] etckeeper — install and init (tracks /etc in git)
- [ ] SSH hardening — set `PasswordAuthentication no`, `PermitRootLogin no` (verify key login first!)
- [ ] ufw firewall — default deny incoming, SSH only from tailscale0 / 100.64.0.0/10
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

## blocked
- sudo requires password — some installs need `sudo`; resolve via `sudo -S` or add nopasswd for specific commands
