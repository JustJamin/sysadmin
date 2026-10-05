# Machine facts — sysadmin project copy

- Host: lenovo (Lenovo IdeaPad Z500)
- OS: Debian 13 (trixie), kernel 6.12.107+deb13-amd64
- CPU: Intel i5-3210M @ 2.50GHz, 4 cores
- RAM: 5.7Gi total, ~5.0Gi available
- Disk: 910GB root (/dev/sda2), ~862GB free
- Swap: 5.9Gi
- Tailscale: 100.79.164.117 (lenovo)
- SSH: key-only (password + root login disabled, AllowUsers jamin) via /etc/ssh/sshd_config.d/10-hardening.conf; one key in authorized_keys = Termius on phone (SHA256:bMBcakii…)
- Access: Tailscale + Termius from phone
- Firewall: ufw — deny incoming/routed, allow outgoing; allow all in on tailscale0 + 41641/udp. LAN (192.168.0.18) cannot reach SSH.
- Updates: unattended-upgrades — Debian-Security + Tailscale daily (~06:00); auto-reboot 04:00 when required. Point releases + Node.js manual (`sudo apt update && sudo apt upgrade`).
- Docker: docker.io 26.1.5 + compose 2.26.1 + buildx (Debian). /etc/docker/daemon.json: published ports default to 127.0.0.1, log-driver local. jamin in docker group (root-equivalent).
- k3s: v1.36.5+k3s1 single node (own containerd). /etc/rancher/k3s/config.yaml: traefik + servicelb disabled, NodePorts on 127.0.0.1 + 100.79.164.117 only. Default SC local-path. Pods 10.42/16, services 10.43/16 (ufw-allowed). API :6443 tailnet/localhost only. kubectl as jamin via ~/.kube/config (KUBECONFIG in ~/.bashrc).
- Registry: Docker container `registry` (registry:2) on 127.0.0.1:5000, volume `registry-data`, restart unless-stopped. k3s pulls `localhost:5000/...` over HTTP (no registries.yaml).
- Bluetooth: AR3012 (0cf3:3004, hci0, USB 1-1.3) — USB autosuspend disabled (`/etc/modprobe.d/btusb-no-autosuspend.conf`) after USB resets.
- Lid: close is ignored (AC + battery) via /etc/systemd/logind.conf.d/10-lid-ignore.conf
- /etc: tracked by etckeeper (local git in /etc/.git, root-only, NO remote — contains secrets); daily etckeeper.timer + apt hooks
- Console: blanks after 60s idle (consoleblank=60 via /etc/default/grub.d/console-blank.cfg)

Source: ~/notes/MACHINE.md
