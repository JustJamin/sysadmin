#!/bin/sh
# After a reboot (or at the new location): check everything came back. No sudo needed.
# Run: sh ~/repo/sysadmin/scripts/check-boot.sh
export KUBECONFIG="$HOME/.kube/config"
ok() { printf '  OK    %s\n' "$*"; }; bad() { printf '  FAIL  %s\n' "$*"; FAILS=$((FAILS+1)); }
FAILS=0

echo "== boot";    uptime; echo "  booted: $(uptime -s)"
echo "== network"
IP4=$(ip -4 -br addr show wlp3s0 | awk '{print $3}'); [ -n "$IP4" ] && ok "wlp3s0 $IP4" || bad "wlp3s0 has no IPv4"
SSID=$(wpa_cli -i wlp3s0 status 2>/dev/null | sed -n 's/^ssid=//p'); echo "  wifi:  ${SSID:-unknown}"
tailscale status --self --peers=false 2>/dev/null | head -1 | grep -q 100.79.164.117 && ok "tailscale up (100.79.164.117)" || bad "tailscale not up"

echo "== services"
for u in ssh tailscaled ufw docker containerd k3s bluetooth; do
  [ "$(systemctl is-active $u)" = active ] && ok "$u" || bad "$u is $(systemctl is-active $u)"
done
grep -q '^ENABLED=yes' /etc/ufw/ufw.conf && ok "ufw ENABLED=yes" || bad "ufw not enabled"

echo "== settings"
[ "$(cat /sys/module/btusb/parameters/enable_autosuspend)" = N ] && ok "btusb autosuspend off" || bad "btusb autosuspend on"
grep -q consoleblank=60 /proc/cmdline && ok "consoleblank=60 on cmdline" || bad "consoleblank not on cmdline"
[ "$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager HandleLidSwitch)" = 's "ignore"' ] && ok "lid ignored" || bad "lid not ignored"

echo "== containers / k3s"
docker inspect -f '{{.State.Running}}' registry 2>/dev/null | grep -q true && ok "registry container running" || bad "registry not running"
curl -fsS -m 5 http://127.0.0.1:5000/v2/ >/dev/null && ok "registry answers :5000" || bad "registry not answering"
kubectl get nodes --no-headers 2>/dev/null | grep -q ' Ready' && ok "node Ready" || bad "node not Ready"
NOTREADY=$(kubectl get pods -A --no-headers 2>/dev/null | awk '{split($3,a,"/"); if ($4!="Completed" && (a[1]!=a[2] || $4!="Running")) print $1"/"$2" "$3" "$4}')
[ -z "$NOTREADY" ] && ok "all pods Ready" || { bad "pods not ready:"; echo "$NOTREADY" | sed 's/^/        /'; }
PGLOG=$(kubectl -n home-state logs postgres-0 2>/dev/null | grep -E 'database system was (shut down|interrupted|not properly shut down)' | tail -1)
echo "  postgres last start: ${PGLOG:-n/a}"
CODE=$(curl -s -m 15 -o /dev/null -w '%{http_code}' --resolve lenovo.tailc2dfa5.ts.net:443:100.79.164.117 https://lenovo.tailc2dfa5.ts.net/)
[ "$CODE" = 200 ] && ok "https://lenovo.tailc2dfa5.ts.net/ 200" || bad "dashboard HTTPS -> $CODE"

echo "== result: $FAILS failure(s)"
[ "$FAILS" -eq 0 ]
