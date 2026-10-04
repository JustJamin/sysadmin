#!/bin/sh
# Firewall for lenovo: deny all incoming except the tailnet (tailscale0) + Tailscale's UDP port.
# Run with: sudo sh ~/repo/sysadmin/scripts/apply-ufw.sh
# A dead-man timer disables ufw after 5 min unless cancelled:
#   sudo systemctl stop ufw-deadman.timer      (do this after a NEW ssh login works)
# Rollback any time: sudo ufw disable
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }

# Guard: the allow rule is interface-based; without tailscale0 we'd lock ourselves out.
ip link show tailscale0 >/dev/null 2>&1 \
  || { echo "ABORT: tailscale0 interface not found" >&2; exit 1; }

DEBIAN_FRONTEND=noninteractive apt-get install -y ufw
grep -q '^IPV6=yes' /etc/default/ufw || echo "WARNING: IPV6 not enabled in /etc/default/ufw" >&2

# Rules first (ufw is still inactive here; re-running is safe — duplicates are skipped).
ufw default deny incoming
ufw default allow outgoing
ufw default deny routed
ufw allow in on tailscale0 comment 'tailnet: ssh/sftp/taildrop/future'
ufw allow 41641/udp comment 'tailscale direct'

# Dead-man switch: auto-disable in 5 min unless cancelled.
systemctl stop ufw-deadman.timer 2>/dev/null || true
systemctl reset-failed ufw-deadman.service ufw-deadman.timer 2>/dev/null || true
systemd-run --unit=ufw-deadman --on-active=5m /usr/sbin/ufw disable

ufw --force enable

echo "--- ufw status:"
ufw status verbose
echo "--- dead-man timer:"
systemctl list-timers ufw-deadman.timer --no-pager | head -2

etckeeper commit "ufw: deny incoming except tailscale0 + 41641/udp" || true

cat <<'MSG'
--- NEXT (within 5 minutes):
  1. Open a NEW Termius session to lenovo.
  2. If it works:  sudo systemctl stop ufw-deadman.timer
  If you do nothing, ufw disables itself in 5 minutes.
MSG
