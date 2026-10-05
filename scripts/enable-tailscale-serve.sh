#!/bin/sh
# Tailnet-only HTTPS for home_state's provisioning dashboard (Web Bluetooth needs a secure context):
#   https://lenovo.tailc2dfa5.ts.net/  ->  http://127.0.0.1:30304 (k3s NodePort, dash-fastapi-sse)
# Prereq: HTTPS Certificates enabled in Tailscale admin console (DNS page).
# Run with: sudo sh ~/repo/sysadmin/scripts/enable-tailscale-serve.sh
# Undo: sudo tailscale serve --https=443 off
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }

if ! tailscale status --json | grep -q '"CertDomains": \['; then
  echo "ABORT: HTTPS certificates not enabled for this tailnet." >&2
  echo "Enable at https://login.tailscale.com/admin/dns -> HTTPS Certificates, then re-run." >&2
  exit 1
fi

curl -fsS -o /dev/null http://127.0.0.1:30304/ \
  || { echo "ABORT: nothing answering on 127.0.0.1:30304" >&2; exit 1; }

# serve config is stored by tailscaled and survives reboots.
tailscale serve --bg --https=443 http://127.0.0.1:30304

echo "--- serve status:"; tailscale serve status
echo "--- https test (first request may take a few seconds while the cert is issued):"
curl -sS -m 60 -o /dev/null -w "https://lenovo.tailc2dfa5.ts.net/ -> HTTP %{http_code}\n" https://lenovo.tailc2dfa5.ts.net/
