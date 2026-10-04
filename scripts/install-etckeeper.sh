#!/bin/sh
# Install etckeeper: tracks /etc in a local git repo (/etc/.git), auto-commits
# around every apt run and daily. Debian's postinst does `etckeeper init` + first commit.
# Run with: sudo sh ~/repo/sysadmin/scripts/install-etckeeper.sh
#
# NOTE: /etc/.git contains /etc/shadow, SSH host keys etc. — never add a remote / push it.
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }

DEBIAN_FRONTEND=noninteractive apt-get install -y etckeeper

# Give root's commits in /etc a stable identity (repo-local, not global).
git -C /etc config user.name "root (lenovo)"
git -C /etc config user.email "root@lenovo"

# Catch anything the initial commit missed (no-op if clean).
etckeeper commit "etckeeper: post-install snapshot" || true

echo "--- VCS:";            grep '^VCS=' /etc/etckeeper/etckeeper.conf
echo "--- /etc/.git perms:"; stat -c '%A %U:%G %n' /etc/.git
echo "--- remotes (should be empty):"; git -C /etc remote -v
echo "--- log:";            git -C /etc log --oneline -5
echo "--- status:";         git -C /etc status --short | head -20
echo "--- daily timer:";    systemctl is-enabled etckeeper.timer 2>/dev/null || echo "(no timer; cron.daily used)"
