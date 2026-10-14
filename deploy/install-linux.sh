#!/bin/sh
# Run once per machine as root:
#   sudo ./install-linux.sh ./rustdesk.deb 'permanent-password' [id-server] [key] [relay-server]
# The package installs a systemd unit that starts at boot; this enables it and
# sets the permanent password used for unattended access.
set -eu

[ "$(id -u)" -eq 0 ] || { echo "Run as root." >&2; exit 1; }
[ $# -ge 2 ] || { echo "usage: $0 <package.deb> <password> [id-server] [key] [relay-server]" >&2; exit 1; }

pkg=$1; password=$2; id_server=${3:-}; key=${4:-}; relay=${5:-}

if command -v apt-get >/dev/null; then
    apt-get install -y "$pkg"
elif command -v dnf >/dev/null; then
    dnf install -y "$pkg"
else
    echo "Unsupported package manager." >&2; exit 1
fi

systemctl enable --now rustdesk
sleep 5
[ -z "$id_server" ] || rustdesk --option custom-rendezvous-server "$id_server"
[ -z "$key" ]       || rustdesk --option key "$key"
[ -z "$relay" ]     || rustdesk --option relay-server "$relay"
rustdesk --password "$password"
echo "Installed. This machine's ID: $(rustdesk --get-id)"
