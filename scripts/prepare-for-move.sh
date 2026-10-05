#!/bin/sh
# Make shutdown/boot clean for k3s workloads:
#  - (graceful node shutdown: NOT via kubelet-arg — crash-looped k3s 2026-10-05, see LOG)
#  - k3s starts after docker (local registry must be up for image pulls)
# Restarts k3s once; running pods are not killed (KillMode=process).
# Run with: sudo sh ~/repo/sysadmin/scripts/prepare-for-move.sh
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
REPO="$(cd "$(dirname "$0")/.." && pwd)"

install -Dm644 "$REPO/configs/etc/rancher/k3s/config.yaml" /etc/rancher/k3s/config.yaml
install -Dm644 "$REPO/configs/etc/systemd/system/k3s.service.d/10-after-docker.conf" \
  /etc/systemd/system/k3s.service.d/10-after-docker.conf
systemctl daemon-reload
systemctl restart k3s

echo "--- waiting for node Ready..."
i=0
until k3s kubectl get nodes 2>/dev/null | grep -q ' Ready'; do
  i=$((i+1)); [ "$i" -le 36 ] || { echo "node not Ready after 3 min — journalctl -u k3s" >&2; exit 1; }
  sleep 5
done
sleep 10   # give kubelet time to register its shutdown inhibitor

echo "--- k3s ordering:"; systemctl show k3s -p After --value --no-pager | tr ' ' '\n' | grep -x docker.service || echo "WARNING: docker.service not in After="
echo "--- shutdown inhibitor (expect kubelet, delay):"; systemd-inhibit --list --no-pager | grep -i kubelet || echo "WARNING: no kubelet inhibitor yet"
echo "--- logind delay max:"; busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager InhibitDelayMaxUSec
echo "--- pods:"; k3s kubectl get pods -A --no-headers | awk '{print $1, $2, $3, $4}'
etckeeper commit "k3s: graceful node shutdown 60s; start after docker" || true
