# Machine facts — sysadmin project copy

- Host: lenovo (Lenovo IdeaPad Z500)
- OS: Debian 13 (trixie), kernel 6.12.107+deb13-amd64
- CPU: Intel i5-3210M @ 2.50GHz, 4 cores
- RAM: 5.7Gi total, ~5.0Gi available
- Disk: 910GB root (/dev/sda2), ~862GB free
- Swap: 5.9Gi
- Tailscale: 100.79.164.117 (lenovo)
- SSH: key auth works; password auth not confirmed disabled
- Access: Tailscale + Termius from phone
- Lid: close is ignored (AC + battery) via /etc/systemd/logind.conf.d/10-lid-ignore.conf
- Console: blanks after 60s idle (consoleblank=60 via /etc/default/grub.d/console-blank.cfg)

Source: ~/notes/MACHINE.md
