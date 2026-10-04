#!/bin/sh
# Docker + Compose from Debian packages (security updates via unattended-upgrades).
# Run with: sudo sh ~/repo/sysadmin/scripts/install-docker.sh
# Then open a NEW ssh session so the docker group applies.
# NOTE: published ports bypass ufw — daemon.json makes them bind 127.0.0.1 by default.
# Rollback: sudo apt purge docker.io docker-compose docker-buildx && sudo rm -rf /etc/docker /var/lib/docker
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
REPO="$(cd "$(dirname "$0")/.." && pwd)"

install -Dm644 "$REPO/configs/etc/docker/daemon.json" /etc/docker/daemon.json

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io docker-compose docker-buildx

# docker group = root-equivalent; acceptable on this single-user box.
usermod -aG docker jamin
systemctl restart docker

echo "--- versions:"; docker --version; docker compose version; docker buildx version
echo "--- daemon config:"; docker info --format 'logging={{.LoggingDriver}}'; cat /etc/docker/daemon.json
echo "--- docker: $(systemctl is-active docker) / $(systemctl is-enabled docker)"
etckeeper commit "docker: docker.io + compose, default bind 127.0.0.1" || true
echo "--- done. Open a NEW ssh session, then: docker run --rm hello-world"
