#!/bin/sh
# Install the sshd hardening drop-in (key-only, no root, AllowUsers jamin).
# Run with: sudo sh ~/repo/sysadmin/scripts/apply-ssh-hardening.sh
# Keep a SECOND ssh session open while running this; test a NEW login before closing it.
# Rollback: sudo rm /etc/ssh/sshd_config.d/10-hardening.conf && sudo systemctl reload ssh
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
REPO="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO/configs/etc/ssh/sshd_config.d/10-hardening.conf"
DST=/etc/ssh/sshd_config.d/10-hardening.conf

# Guard: never disable passwords unless jamin has at least one key.
grep -qE '^(ssh-|ecdsa-|sk-)' /home/jamin/.ssh/authorized_keys \
  || { echo "ABORT: no keys in /home/jamin/.ssh/authorized_keys" >&2; exit 1; }

install -Dm644 "$SRC" "$DST"

# Validate full config; roll back if invalid.
if ! /usr/sbin/sshd -t; then
  rm -f "$DST"; echo "ABORT: sshd -t failed, drop-in removed, nothing reloaded" >&2; exit 1
fi

echo "--- effective settings:"
/usr/sbin/sshd -T | grep -E '^(passwordauthentication|kbdinteractiveauthentication|permitrootlogin|pubkeyauthentication|authenticationmethods|allowusers|maxauthtries|logingracetime|x11forwarding|permitemptypasswords) '

systemctl reload ssh
echo "--- ssh: $(systemctl is-active ssh)"

etckeeper commit "ssh: key-only login, no root, AllowUsers jamin" || true
echo "--- done. Now open a NEW ssh session to confirm login still works."
