# sysadmin project — lenovo (Debian 13 / trixie)

Working directory for this machine's system administration.
All setup for SSH hardening, firewall (ufw), etckeeper, GitHub sync, and any monitoring will live here.

Started: 2026-09-27
Host: lenovo (Lenovo IdeaPad Z500, i5-3210M, 5.7G RAM)
Access: Tailscale → phone/Termius (do NOT break SSH to this box)

---

## Directory layout (this folder)

sysadmin/
  README.md       <- this file (project overview)
  TODO.md         <- running list / checklist (update after every session)
  LOG.md          <- dated entry per session (what changed, why, what still open)
  MACHINE.md      <- hard facts (copied from ~/notes/MACHINE.md for self-containment)
  github.md       <- GitHub / SSH / git remote notes (key status, repo URL, blocked steps)
  archive/        <- copies of configs before changes (etckeeper does this automatically too)

---

## Tools / choices

- **etckeeper** (installed 2026-10-04) — tracks /etc in git, auto-commits on apt + daily. Local only: never add a remote (shadow, SSH host keys).
- **ufw** (enabled 2026-10-04) — deny incoming; allow everything on `tailscale0` (any tailnet device) + 41641/udp. Access control = Tailscale device approval/ACLs + SSH keys.
- **fail2ban** (not yet installed) — brute-force defense.
- **restic** (not yet installed) — backups (NOT git). See ~/notes/SETUP.md.
- **GitHub account**: JustJamin — SSH auth works; this repo pushes to `git@github.com:JustJamin/sysadmin.git`. See github.md.

---

## How to use this folder

1. Read TODO.md before starting a session (see what's open).
2. Do work; note results in LOG.md (date, what changed, what's blocked).
3. Update TODO.md (check off / move items / add new ones).
4. Commit after every change (small, focused commits) and push to origin (`git push`) regularly — at least at the end of each task.
5. If a step breaks SSH access, document it here FIRST — don't assume you can recover remotely.
