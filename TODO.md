# sysadmin TODO — lenovo

Updated after every session. Oldest tasks first; current work at top.

## active
- [ ] Figure out GitHub SSH auth — key added but `ssh -T git@github.com` denied (publickey)
  - no private key in ~/.ssh/id_*? (checked 2026-09-27)
  - regenerate ed25519 key with ssh-keygen, add public half to GitHub?
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

## blocked
- sudo requires password — some installs need `sudo`; resolve via `sudo -S` or add nopasswd for specific commands
- GitHub SSH key not working yet — see github.md
