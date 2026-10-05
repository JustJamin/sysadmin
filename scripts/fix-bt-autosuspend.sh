#!/bin/sh
# Stop USB autosuspend on the AR3012 Bluetooth adapter (suspected cause of USB resets).
# Applies live WITHOUT reloading btusb (scanner keeps running) + persists via modprobe.d.
# Run with: sudo sh ~/repo/sysadmin/scripts/fix-bt-autosuspend.sh
# Undo: sudo rm /etc/modprobe.d/btusb-no-autosuspend.conf; echo Y | sudo tee /sys/module/btusb/parameters/enable_autosuspend
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
REPO="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== evidence: kernel log (btusb / usb 1-1.3 / hci0)"
dmesg -T | grep -iE 'btusb|usb 1-1\.3|hci0|bluetooth' | tail -30 || true
echo "=== evidence: bluetooth service log"
journalctl -u bluetooth --since -2d --no-pager | tail -20 || true

# 1. Persist for future boots.
install -Dm644 "$REPO/configs/etc/modprobe.d/btusb-no-autosuspend.conf" /etc/modprobe.d/btusb-no-autosuspend.conf

# 2. Live: future btusb probes (e.g. after a re-enumeration) won't enable autosuspend.
echo N > /sys/module/btusb/parameters/enable_autosuspend

# 3. Live: keep the current AR3012 powered.
found=0
for d in /sys/bus/usb/devices/*; do
  [ -f "$d/idVendor" ] || continue
  if [ "$(cat "$d/idVendor")" = 0cf3 ] && [ "$(cat "$d/idProduct")" = 3004 ]; then
    echo on > "$d/power/control"; found=1
    echo "=== $d: control=$(cat "$d/power/control") status=$(cat "$d/power/runtime_status")"
  fi
done
[ "$found" = 1 ] || echo "WARNING: AR3012 (0cf3:3004) not found on USB" >&2

echo "=== btusb enable_autosuspend=$(cat /sys/module/btusb/parameters/enable_autosuspend)"
etckeeper commit "btusb: disable USB autosuspend (AR3012 resets)" || true
