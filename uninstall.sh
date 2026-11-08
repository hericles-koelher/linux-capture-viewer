#!/usr/bin/env bash
set -euo pipefail
if (( EUID == 0 )); then echo "Run as your regular user." >&2; exit 1; fi
rm -f -- "$HOME/.local/bin/capture-viewer" "$HOME/.local/bin/capture-viewer-window" "$HOME/.local/share/applications/capture-viewer.desktop"
command -v update-desktop-database >/dev/null && update-desktop-database "$HOME/.local/share/applications"
echo "Launcher removed. Packages, user configuration and logs were preserved."
