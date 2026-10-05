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

- Dropped fail2ban from TODO: SSH unreachable from LAN/internet (ufw) and password auth off — revisit only if something is exposed publicly
- unattended-upgrades 2.12 via `scripts/apply-unattended-upgrades.sh`
  - `/etc/apt/apt.conf.d/20auto-upgrades` (daily lists + upgrade, autoclean 7d) and `52unattended-upgrades-local` (overrides; package's 50unattended-upgrades untouched)
  - Origins: `#clear` + Debian-Security (trixie-security) + Tailscale only — dry run confirmed "Allowed origins" = exactly these two, no errors
  - Auto-reboot 04:00 only if required; WithUsers=true (tty1 session is permanent)
  - Timers: apt-daily (~2x/day), apt-daily-upgrade (~06:00 + random delay)
  - Where to look: `sudo cat /var/log/unattended-upgrades/unattended-upgrades.log`; reboots: `journalctl -b -1 -n 50` / `last reboot`
  - Side effect: Tailscale auto-update restarts tailscaled → SSH drops for a few seconds
  - Pending: check log after first real run (2026-10-05)
  - Rollback: remove both files, `sudo apt purge unattended-upgrades`


- Added `## home_state dependencies` to TODO.md. These are host setup items for `~/repo/home_state`, which uses XIAO ESP32-C6 BLE boards, a scanner and Postgres:
  - dialout group (to flash the ESP32 on /dev/ttyACM0), apt build deps for ESP-IDF, the ESP-IDF toolchain (user-level, ~/esp), Docker + Compose, and single-node k3s
  - home_state's README marks itself as blocked on these items
- home_state step 1 host deps done:
  - jamin added to `dialout` (takes effect after re-login; until then, use `sg dialout -c ...`)
  - apt: flex bison gperf python3-pip python3-venv cmake ninja-build ccache libffi-dev dfu-util
  - ESP-IDF v6.1 cloned to `~/esp/esp-idf` (shallow), `./install.sh esp32c6` → tools in `~/.espressif`. Use it with `. ~/esp/esp-idf/export.sh`
  - Removal: `rm -rf ~/esp ~/.espressif`
- Docker via `scripts/install-docker.sh` (for home_state step 4)
  - Debian packages: docker.io 26.1.5+dfsg1-9+deb13u1, docker-compose 2.26.1-4, docker-buildx 0.13.1 — covered by Debian-Security unattended-upgrades
  - `/etc/docker/daemon.json`: `"ip": "127.0.0.1"` (default bind for published ports — they bypass ufw), `"log-driver": "local"`
  - jamin added to `docker` group (root-equivalent)
  - Verified: hello-world OK without sudo (new session); `-p 18080:80` bound to 127.0.0.1:18080 only — HTTP 200 on localhost, no answer on 192.168.0.18
  - Rollback: `sudo apt purge docker.io docker-compose docker-buildx && sudo rm -rf /etc/docker /var/lib/docker`
- k3s via `scripts/install-k3s.sh` (for home_state step 5)
  - v1.36.5+k3s1 (stable channel, get.k3s.io); own containerd 2.3.4, separate from Docker's
  - `/etc/rancher/k3s/config.yaml` installed before first start: kubeconfig 0600, `disable: [traefik, servicelb]`, kube-proxy `nodeport-addresses=127.0.0.1/32,100.79.164.117/32`
  - ufw: `allow from 10.42.0.0/16` (pods), `allow from 10.43.0.0/16` (services). 6443/10250 listen on * but are normal host ports → ufw blocks them from LAN
  - Verified: node Ready; coredns, local-path-provisioner, metrics-server Running; no traefik/svclb; all services ClusterIP
  - Verified: 1Gi local-path PVC Bound, pod wrote/read file, in-cluster DNS (10.43.0.10) resolved kubernetes.default; PV auto-deleted after cleanup
  - Memory after install: ~3.9 GiB available (k3s ≈ 0.5 GiB)
  - Gotcha: k3s's kubectl reads /etc/rancher/k3s/k3s.yaml (root-only) unless `KUBECONFIG` is set → added `export KUBECONFIG="$HOME/.kube/config"` to ~/.bashrc (script now does this too)
  - Not auto-updated — added TODO
  - Rollback: `sudo /usr/local/bin/k3s-uninstall.sh`; `sudo ufw delete allow from 10.42.0.0/16`; same for 10.43.0.0/16
- All home_state host dependencies now done (dialout, ESP-IDF deps + toolchain v6.1, Docker, k3s)

- Added TODO: local image registry (registry:2 on 127.0.0.1:5000) for home_state step 5, because k3s's containerd can't see Docker-built images. Chosen over running `sudo k3s ctr images import` on every build, and over GHCR.
- Local image registry for home_state k3s (step 5) via `scripts/run-local-registry.sh` (no sudo; idempotent)
  - `registry:2` container `registry`, `-p 127.0.0.1:5000:5000`, volume `registry-data`, `--restart unless-stopped`
  - Test: pushed busybox as `localhost:5000/registry-test:1`; k3s pod with that image + `imagePullPolicy: Always` pulled it ("Successfully pulled … in 512ms") and ran
  - registries.yaml NOT needed — k3s's containerd treats localhost registries as plain HTTP, and it runs in the host netns so localhost:5000 = this registry
  - Cleaned up: test pod deleted, registry recreated empty (deletes disabled by default)
  - Remove: `docker rm -f registry && docker volume rm registry-data`

- Added TODO: investigate AR3012 USB resets. On 2026-10-04 ~20:46 UTC the Bluetooth adapter re-enumerated on USB (device 13 → 34). BlueZ recreated hci0 and home_state's scanner stopped receiving adverts for ~11 min, until it was restarted. The scanner now exits after 120 s of silence so it gets restarted automatically. Root cause needs root to read dmesg/journal.

## 2026-10-05
- Health check (home_state): AR3012 Bluetooth adapter re-enumerated again at ~2026-10-04 23:49 UTC (USB device 34 → 46). It's the second time, so the problem is recurring. home_state's scanner watchdog recovered by itself in 2 min 12 s. Root cause still needs `sudo dmesg` / journal (see TODO).
- Added TODO: Tailscale HTTPS certs + `tailscale serve` (https://lenovo.tailc2dfa5.ts.net/ → 127.0.0.1:30304), so home_state v1.1.0 can provision BLE nodes from the phone with Web Bluetooth, which needs HTTPS.
