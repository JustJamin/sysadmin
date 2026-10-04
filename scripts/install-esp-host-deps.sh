#!/bin/sh
# home_state step 1 host deps: serial access for flashing + apt build deps for ESP-IDF.
# Run with: sudo sh ~/repo/sysadmin/scripts/install-esp-host-deps.sh
# Afterwards LOG OUT and back in (new SSH session) for the dialout group to apply.
# ESP-IDF itself is a user-level install (~/esp/esp-idf, ~/.espressif) — no sudo, done separately.
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }

# Serial access to /dev/ttyACM0 (XIAO ESP32-C6 USB JTAG/serial) without root.
usermod -aG dialout jamin

# ESP-IDF prerequisites (Espressif's Debian list).
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  git wget flex bison gperf python3 python3-pip python3-venv \
  cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0

echo "--- jamin groups (dialout applies after re-login):"; id -nG jamin
echo "--- versions:"; cmake --version | head -1; ninja --version; python3 --version
etckeeper commit "home_state: jamin -> dialout; ESP-IDF build deps" || true
echo "--- done. Open a NEW ssh session, then run: id -nG   (should include dialout)"
