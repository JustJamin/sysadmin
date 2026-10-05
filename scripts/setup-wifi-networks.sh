#!/bin/sh
# Move Wi-Fi config from inline wpa-ssid/wpa-psk to wpa_supplicant.conf holding BOTH the current
# network and a new one, so lenovo connects at either location.
# You type the NEW network's name/password at the prompt (hidden); PSKs are stored hashed.
# Does NOT restart networking (would drop SSH) — takes effect at next boot.
# Run with: sudo sh ~/repo/sysadmin/scripts/setup-wifi-networks.sh
# Rollback (from keyboard): sudo cp /etc/network/interfaces.pre-wifi-roam /etc/network/interfaces && sudo reboot
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
REPO="$(cd "$(dirname "$0")/.." && pwd)"
IFACES=/etc/network/interfaces
CONF=/etc/wpa_supplicant/wpa_supplicant.conf

# Current network from the inline config (or from the backup if re-running).
SRC=$IFACES; [ -f "$IFACES.pre-wifi-roam" ] && SRC="$IFACES.pre-wifi-roam"
CUR_SSID=$(sed -n 's/^[[:space:]]*wpa-ssid[[:space:]]\{1,\}//p' "$SRC" | head -1)
CUR_PSK=$(sed -n 's/^[[:space:]]*wpa-psk[[:space:]]\{1,\}//p' "$SRC" | head -1)
[ -n "$CUR_SSID" ] && [ -n "$CUR_PSK" ] || { echo "ABORT: no wpa-ssid/wpa-psk in $SRC" >&2; exit 1; }
echo "Current network: $CUR_SSID"

# psk block: 64 hex chars = already a hashed PSK; otherwise hash the passphrase.
psk_line() { # $1 ssid, $2 passphrase-or-hex
  if printf '%s' "$2" | grep -Eq '^[0-9a-fA-F]{64}$'; then printf '\tpsk=%s\n' "$2"
  else wpa_passphrase "$1" "$2" | sed -n 's/^[[:space:]]*psk=\([0-9a-f]\{64\}\)$/\tpsk=\1/p'; fi
}

printf 'NEW Wi-Fi network name (SSID): '; read -r NEW_SSID
[ -n "$NEW_SSID" ] || { echo "ABORT: empty SSID" >&2; exit 1; }
stty -echo; printf 'Password for %s (hidden): ' "$NEW_SSID"; read -r NEW_PASS; stty echo; echo
[ "${#NEW_PASS}" -ge 8 ] && [ "${#NEW_PASS}" -le 63 ] || { echo "ABORT: WPA passphrase must be 8-63 chars" >&2; exit 1; }

CUR_PSK_LINE=$(psk_line "$CUR_SSID" "$CUR_PSK")
NEW_PSK_LINE=$(psk_line "$NEW_SSID" "$NEW_PASS")
[ -n "$CUR_PSK_LINE" ] && [ -n "$NEW_PSK_LINE" ] || { echo "ABORT: could not build PSK" >&2; exit 1; }

umask 077
TMP=$(mktemp)
cat > "$TMP" <<CONF
# lenovo Wi-Fi networks (written by sysadmin/scripts/setup-wifi-networks.sh). PSKs are hashed.
ctrl_interface=DIR=/run/wpa_supplicant GROUP=netdev
update_config=0

network={
	ssid="$CUR_SSID"
$CUR_PSK_LINE
	scan_ssid=1
}

network={
	ssid="$NEW_SSID"
$NEW_PSK_LINE
	scan_ssid=1
}
CONF
install -m600 -o root -g root "$TMP" "$CONF"; rm -f "$TMP"

[ -f "$IFACES.pre-wifi-roam" ] || cp -p "$IFACES" "$IFACES.pre-wifi-roam"
install -m600 -o root -g root "$REPO/configs/etc/network/interfaces" "$IFACES"

echo "--- $CONF (PSKs hidden):"; sed -E 's/(psk=).*/\1<hashed>/' "$CONF"
echo "--- $IFACES wlp3s0 stanza:"; sed -n '/iface wlp3s0/,$p' "$IFACES"
etckeeper commit "wifi: wpa_supplicant.conf with current + new network" || true
echo "--- done. Takes effect at next boot (test reboot at home first)."
echo "    Rollback from keyboard: sudo cp $IFACES.pre-wifi-roam $IFACES && sudo reboot"
