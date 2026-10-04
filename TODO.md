# sysadmin TODO — lenovo

Updated after every session. Oldest tasks first; current work at top.

## active
- [x] GitHub SSH auth — key generated + added to GitHub, `ssh -T git@github.com` now authenticates ("You've successfully authenticated")
  - [x] Create remote repo `JustJamin/sysadmin` on GitHub and add as origin
  - [x] Push local repo to origin (main branch)
- [ ] Backup SSH key from a second device (phone is currently the only key)
- [ ] restic local repo + systemd timer
- [ ] offsite backup backend (B2 / S3 / rsync.net)
- [ ] restore test from backup
- [ ] dashboard / monitoring seed (disk, mem, journal)
- [ ] Tailscale polish (Tailscale SSH, MagicDNS)

## home_state dependencies
Host setup needed by `~/repo/home_state` (BLE sensor boards → Postgres). That project is blocked on these. Added 2026-10-04.
- [ ] Add jamin to `dialout`, so the XIAO ESP32-C6 on `/dev/ttyACM0` can be flashed without root. Run `sudo usermod -aG dialout jamin`, then log out and back in. (home_state step 1)
- [ ] apt build deps for ESP-IDF: `git wget flex bison gperf python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0` (home_state step 1)
- [ ] ESP-IDF toolchain, latest stable, target esp32c6. It's a user-level install in `~/esp/esp-idf` and `~/.espressif` and needs no sudo. (home_state step 1)
- [ ] Docker + Compose. Published ports bypass ufw, so bind services to 127.0.0.1. (home_state step 4)
- [ ] k3s single-node with the `local-path` storage class (home_state step 5)

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
- [x] unattended-upgrades — Debian security + Tailscale, auto-reboot 04:00 if required (2026-10-04)

## blocked
- sudo requires password — some installs need `sudo`; resolve via `sudo -S` or add nopasswd for specific commands
