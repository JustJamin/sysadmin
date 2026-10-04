#!/bin/sh
# Automatic security updates: Debian security + Tailscale, auto-reboot 04:00 if required.
# Run with: sudo sh ~/repo/sysadmin/scripts/apply-unattended-upgrades.sh
# Rollback: sudo rm /etc/apt/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/52unattended-upgrades-local
#           && sudo apt purge unattended-upgrades
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
REPO="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$REPO/configs/etc/apt/apt.conf.d"

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades

install -m644 "$CONF/20auto-upgrades"               /etc/apt/apt.conf.d/20auto-upgrades
install -m644 "$CONF/52unattended-upgrades-local"   /etc/apt/apt.conf.d/52unattended-upgrades-local

echo "--- effective apt config:"
apt-config dump | grep -E '^(APT::Periodic::|Unattended-Upgrade::(Origins-Pattern|Automatic-Reboot))'

echo "--- dry run:"
unattended-upgrade --dry-run --debug 2>&1 \
  | grep -E 'Allowed origins|Packages that will be upgraded|No packages found|ERROR|error' || true

echo "--- timers:"
systemctl list-timers 'apt-daily*' --no-pager | head -3

etckeeper commit "apt: unattended-upgrades (security + tailscale, reboot 04:00)" || true
