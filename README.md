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

- **etckeeper** (not yet installed) — tracks /etc in git, auto-commits on apt. Preferred over manual /etc copies.
- **ufw** (not yet installed) — firewall; allow SSH only from Tailscale interface / 100.64.0.0/10.
- **fail2ban** (not yet installed) — brute-force defense.
- **restic** (not yet installed) — backups (NOT git). See ~/notes/SETUP.md.
- **GitHub account**: JustJamin — SSH key added, but `ssh -T git@github.com` still denied (publickey). See github.md.

---

## How to use this folder

1. Read TODO.md before starting a session (see what's open).
2. Do work; note results in LOG.md (date, what changed, what's blocked).
3. Update TODO.md (check off / move items / add new ones).
4. If a step breaks SSH access, document it here FIRST — don't assume you can recover remotely.
