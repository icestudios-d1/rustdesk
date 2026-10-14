#!/bin/sh
# Run once per machine as root, with the app already copied to /Applications:
#   sudo ./install-macos.sh 'permanent-password' [id-server] [key] [relay-server]
# macOS still needs a person to grant Screen Recording, Accessibility and
# Input Monitoring once (System Settings > Privacy & Security); no script can
# do that. After that the launch daemon starts the agent at boot.
set -eu

[ "$(id -u)" -eq 0 ] || { echo "Run as root." >&2; exit 1; }
[ $# -ge 1 ] || { echo "usage: $0 <password> [id-server] [key] [relay-server]" >&2; exit 1; }

password=$1; id_server=${2:-}; key=${3:-}; relay=${4:-}
bin=$(ls -d /Applications/*.app 2>/dev/null | grep -i rustdesk | head -n1)/Contents/MacOS/RustDesk
[ -x "$bin" ] || { echo "RustDesk app not found in /Applications." >&2; exit 1; }

"$bin" --install-service
sleep 5
[ -z "$id_server" ] || "$bin" --option custom-rendezvous-server "$id_server"
[ -z "$key" ]       || "$bin" --option key "$key"
[ -z "$relay" ]     || "$bin" --option relay-server "$relay"
"$bin" --password "$password"
echo "Installed. This machine's ID: $("$bin" --get-id)"
