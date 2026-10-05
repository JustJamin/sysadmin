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
- [ ] k3s updates are manual (not covered by unattended-upgrades) — re-run `curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=stable sh -` periodically
- [ ] Registry garbage collection — old home_state image layers accumulate in `registry-data`; deletes are disabled by default (revisit if disk use grows)
- [ ] Tailscale polish (Tailscale SSH, MagicDNS)

## home_state dependencies
Host setup needed by `~/repo/home_state` (BLE sensor boards → Postgres). That project is blocked on these. Added 2026-10-04.
- [x] Add jamin to `dialout`, so the XIAO ESP32-C6 on `/dev/ttyACM0` can be flashed without root. Run `sudo usermod -aG dialout jamin`, then log out and back in. (home_state step 1)
- [x] apt build deps for ESP-IDF: `git wget flex bison gperf python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0` (home_state step 1)
- [x] ESP-IDF toolchain v6.1, target esp32c6 (2026-10-04). It's a user-level install in `~/esp/esp-idf` and `~/.espressif` and needs no sudo. (home_state step 1)
- [x] Docker + Compose — Debian docker.io 26.1.5 + compose 2.26.1; daemon.json default bind 127.0.0.1 (2026-10-04; LAN bind test passed) (home_state step 4)
- [x] k3s single-node — v1.36.5+k3s1, traefik + servicelb disabled, `local-path` default SC (2026-10-04; PVC + DNS test passed) (home_state step 5)
- [x] Local image registry for k3s — `registry:2` on 127.0.0.1:5000, restart unless-stopped, volume `registry-data`, via `scripts/run-local-registry.sh` (2026-10-04; k3s pulled `localhost:5000/...` over plain HTTP with no registries.yaml needed) (home_state step 5)
- [ ] Investigate AR3012 Bluetooth adapter USB resets. Around 2026-10-04 20:46 UTC it re-enumerated on USB (bus 1 device 13 → 34) and BlueZ recreated hci0.
  - Check `sudo dmesg -T | grep -iE "btusb|usb 1-1.3|hci0"` and `sudo journalctl -u bluetooth`.
  - Suspects: USB autosuspend (`btusb enable_autosuspend=0`) or AR3012 firmware.
  - home_state's scanner now restarts itself after 120 s without adverts, so this is no longer an outage, but the root cause is still unknown.
  - Recurring: it reset again at ~2026-10-04 23:49 UTC (device 34 → 46). The scanner watchdog restarted it after 2 min 12 s, losing ~26 readings.

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
