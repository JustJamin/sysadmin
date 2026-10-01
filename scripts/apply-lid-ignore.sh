#!/bin/sh
# Keep lenovo running with the lid shut + blank the console after 60s.
# Run with: sudo sh ~/repo/sysadmin/scripts/apply-lid-ignore.sh
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
REPO="$(cd "$(dirname "$0")/.." && pwd)"

install -Dm644 "$REPO/configs/etc/systemd/logind.conf.d/10-lid-ignore.conf" /etc/systemd/logind.conf.d/10-lid-ignore.conf
install -Dm644 "$REPO/configs/etc/default/grub.d/console-blank.cfg" /etc/default/grub.d/console-blank.cfg

systemctl reload systemd-logind || systemctl restart systemd-logind
update-grub
setterm --blank 1 --term linux </dev/tty1 >/dev/tty1 || true

echo "--- logind lid settings:"
busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager \
  HandleLidSwitch HandleLidSwitchExternalPower HandleLidSwitchDocked
echo "--- grub:"
grep -c consoleblank=60 /boot/grub/grub.cfg
