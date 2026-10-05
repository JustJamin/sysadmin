#!/bin/sh
# Stop k3s crash loop caused by kubelet graceful-shutdown args (2026-10-05):
# show the error, remove the kubelet-arg block from config.yaml, restart k3s, wait for Ready.
# Run with: sudo sh ~/repo/sysadmin/scripts/k3s-fix-crashloop.sh
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
CFG=/etc/rancher/k3s/config.yaml

echo "=== k3s errors since 17:40:"
journalctl -u k3s --since 17:40 --no-pager \
  | grep -iE 'shutdown|inhibit|logind|fatal|level=error' | tail -15 || true

cp -p "$CFG" "$CFG.bak-crashloop"
sed -i '/^kubelet-arg:/,$d' "$CFG"
echo "=== config.yaml now:"; cat "$CFG"

systemctl restart k3s
i=0
until k3s kubectl get nodes 2>/dev/null | grep -q ' Ready'; do
  i=$((i+1)); [ "$i" -le 36 ] || { echo "not Ready after 3 min" >&2; exit 1; }
  sleep 5
done
sleep 30
echo "=== k3s: $(systemctl is-active k3s), restarts=$(systemctl show k3s -p NRestarts --value)"
etckeeper commit "k3s: remove kubelet graceful-shutdown args (crash loop)" || true
