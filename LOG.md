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

## 2026-10-05
- AR3012 USB resets (home_state): suspected USB autosuspend
  - Before: `btusb enable_autosuspend=Y`; `/sys/bus/usb/devices/1-1.3/power/control=auto`, `autosuspend_delay_ms=2000`, `runtime_suspended_time=120060` ms (so it was suspending). powertop.service disabled, no tlp, no udev power rules.
  - bluetoothd log: hci0 destroyed/recreated at 21:46 and 00:49 BST (= the 20:46 / 23:49 UTC resets in TODO). dmesg ring buffer had already wrapped (8 days uptime) — kernel-side evidence via `sudo journalctl -k --since -2d | grep -iE 'usb 1-1|btusb|bluetooth'`
  - Fix via `scripts/fix-bt-autosuspend.sh` (live, no btusb reload — scanner unaffected): `enable_autosuspend=N`, `power/control=on`, `/etc/modprobe.d/btusb-no-autosuspend.conf`; etckeeper committed
  - Verified after: param N, control=on, status active, devnum 46, runtime_suspended_time unchanged at 120060
  - Undo: remove the modprobe.d file; `echo Y | sudo tee /sys/module/btusb/parameters/enable_autosuspend`
- Tailscale HTTPS for home_state provisioning dashboard (Web Bluetooth needs a secure context)
  - User enabled HTTPS Certificates in admin console (name now in public CT logs, as noted in TODO)
  - `scripts/enable-tailscale-serve.sh`: `tailscale serve --bg --https=443 http://127.0.0.1:30304` (dash-fastapi-sse NodePort); config persists in tailscaled
  - Verified: HTTP 200 with valid cert (CN=lenovo.tailc2dfa5.ts.net, Let's Encrypt YE1, until 2027-01-03, auto-renewed); serve status "tailnet only"; 192.168.0.18:443 no answer
  - Script's self-test failed with "Could not resolve host" — lenovo's resolv.conf uses ISP DNS, not MagicDNS. Script now uses `curl --resolve …:100.79.164.117`. MagicDNS-on-lenovo noted under Tailscale polish TODO.
  - Undo: `sudo tailscale serve --https=443 off`
- AR3012 resets under load: two more USB re-enumerations (46 → 48 → 50) during home_state OTA bench tests over hci0, one coinciding with a link supervision timeout mid-transfer. Added the evidence and options (autosuspend off, dmesg, BT 5 dongle) to the TODO.
- Move prep (lenovo moving to new Wi-Fi "Morrison"):
  - `scripts/setup-wifi-networks.sh`: /etc/network/interfaces now uses `wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf` (root 600, hashed PSKs) with VM1429985 + Morrison; old file at `/etc/network/interfaces.pre-wifi-roam`. Takes effect at next boot — NOT yet tested.
  - k3s.service.d/10-after-docker.conf installed (After/Wants=docker.service) — verified in `systemctl show k3s -p After`
  - `scripts/check-boot.sh` (no sudo) — baseline pre-reboot: only expected FAILs (ufw.service inactive since enabled live; consoleblank not on cmdline yet)
- INCIDENT 17:40–17:44 BST: k3s crash-looped (23+ restarts) after `prepare-for-move.sh` added `kubelet-arg: shutdown-grace-period=60s / shutdown-grace-period-critical-pods=10s`
  - Error: `kubelet exited: failed to parse kubelet flag: unknown flag: --shutdown-grace-period` — these are KubeletConfiguration-file-only fields in k8s 1.36, not CLI flags
  - Impact: API server flapping; pods kept running (KillMode=process), dashboard NodePort stayed 200, no pod restarts
  - Fix: `scripts/k3s-fix-crashloop.sh` removed the kubelet-arg block (backup `/etc/rancher/k3s/config.yaml.bak-crashloop`), restarted → stable since 17:44:53, NRestarts=0
  - Also: prepare-for-move.sh's ordering check used `grep -x` on `After=docker.service …` (first token) → false failure + early exit under set -e; fixed with `--value`
  - Graceful shutdown still TODO: needs a KubeletConfiguration drop-in (k3s kubelet --config-dir=/var/lib/rancher/k3s/agent/etc/kubelet.conf.d) + logind InhibitDelayMaxSec ≥ 60s
  - Lesson: long pasted one-liners wrap in Termius and break — use scripts- k3s settings moved to home_state (user decision): `~/repo/home_state/deploy/k3s/` (merged ae0f57e) — config.yaml, kubelet-graceful-shutdown.conf (KubeletConfiguration drop-in → /var/lib/rancher/k3s/agent/etc/kubelet.conf.d/50-graceful-shutdown.conf), logind-inhibit-delay.conf (InhibitDelayMaxSec=90), k3s-after-docker.conf, apply.sh (auto-removes kubelet drop-in if k3s crash-loops)
  - Removed sysadmin copies (configs/etc/rancher/k3s/config.yaml, k3s.service.d drop-in) and prepare-for-move.sh; install-k3s.sh now reads config.yaml from home_state

- k3s graceful shutdown, attempt 2 (home_state deploy/k3s/apply.sh): kubelet now has shutdownGracePeriod 1m0s / critical 10s, k3s stable (restarts=0), After=docker.service OK
  - BUT logind InhibitDelayMaxUSec = 30s → no kubelet inhibitor. Cause: unattended-upgrades ships `/usr/lib/systemd/logind.conf.d/unattended-upgrades-logind-maxdelay.conf` (InhibitDelayMaxSec=30); logind merges /etc + /usr/lib drop-ins in filename order, last wins, so "u…" beat our 20-inhibit-delay (90) and kubelet's own 99-kubelet.conf (60)
  - Fix (home_state b8652d6): install ours as `/etc/systemd/logind.conf.d/zz-k3s-inhibit-delay.conf`; apply.sh removes the old 20- file. Check merged config with `systemd-analyze cat-config systemd/logind.conf`
  - Attempt 2 verified after zz- rename: InhibitDelayMaxUSec=90s, kubelet holds "delay" shutdown inhibitor, shutdownGracePeriod 1m0s, restarts=0- Test reboot at home 17:58 → up 17:59:50 BST, kernel 6.12.111 (installed by unattended-upgrades, first boot into it)
  - Shutdown took ~1 min (kubelet graceful shutdown); postgres log: "database system was shut down at 16:58:38 UTC" — clean, no crash recovery
  - Wi-Fi came up on new wpa-conf setup (VM1429985, wpa_state COMPLETED); ufw.service active, consoleblank=60 on cmdline (both first proven at boot)
  - All services/settings OK. Registry up before pods (no ImagePullBackOff)
  - Pods stopped by graceful shutdown remain as Completed/Error until deleted (k8s behaviour) — deleted with `kubectl delete pods -A --field-selector=status.phase==Failed` / `==Succeeded`; check-boot.sh now ignores them and prints a note
  - Grafana Ready only after ~8 min: its data volume is emptyDir → 813 DB migrations on every start (home_state matter, not host)
  - check-boot.sh fixes: /usr/sbin/wpa_cli (not on jamin's PATH)

