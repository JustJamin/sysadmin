#!/bin/sh
# Single-node k3s (stable channel), traefik + servicelb disabled, NodePorts on localhost + tailnet only.
# Run with: sudo sh ~/repo/sysadmin/scripts/install-k3s.sh
# Rollback: sudo /usr/local/bin/k3s-uninstall.sh
#           sudo ufw delete allow from 10.42.0.0/16 && sudo ufw delete allow from 10.43.0.0/16
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
REPO="$(cd "$(dirname "$0")/.." && pwd)"

# Config first so k3s's first start uses it.
install -Dm644 "$REPO/configs/etc/rancher/k3s/config.yaml" /etc/rancher/k3s/config.yaml

# Pods/services must reach the API server + DNS on the host (k3s docs). 6443 stays tailnet/localhost only.
ufw allow from 10.42.0.0/16 comment 'k3s pods'
ufw allow from 10.43.0.0/16 comment 'k3s services'

curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=stable sh -

# kubectl for jamin without sudo.
install -d -m700 -o jamin -g jamin /home/jamin/.kube
install -m600 -o jamin -g jamin /etc/rancher/k3s/k3s.yaml /home/jamin/.kube/config

echo "--- waiting for node Ready (up to 3 min)..."
i=0
until k3s kubectl get nodes 2>/dev/null | grep -q ' Ready'; do
  i=$((i+1)); [ "$i" -le 36 ] || { echo "node not Ready after 3 min — check: journalctl -u k3s" >&2; exit 1; }
  sleep 5
done

echo "--- version:"; k3s --version | head -1
echo "--- nodes:";   k3s kubectl get nodes -o wide
echo "--- pods:";    k3s kubectl get pods -A
echo "--- ufw:";     ufw status | grep -E '10\.4[23]\.0\.0'
etckeeper commit "k3s: single node, traefik+servicelb disabled; ufw allow pod/service CIDRs" || true
echo "--- done. As jamin: kubectl get nodes"
