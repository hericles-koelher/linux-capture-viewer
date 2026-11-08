#!/usr/bin/env bash
set -euo pipefail
if (( EUID == 0 )); then
    echo "Run as your regular user. sudo is used only for system packages." >&2
    exit 1
fi
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
case "${1:-}" in
    --skip-deps) ;;
    "")
        command -v apt-get >/dev/null || { echo "This installer requires Linux Mint/Ubuntu/Debian." >&2; exit 1; }
        sudo apt-get update
        sudo apt-get install -y ffmpeg v4l-utils pipewire pipewire-bin pipewire-pulse pulseaudio-utils python3 python3-gi gir1.2-gtk-3.0 libx11-6 wmctrl zenity libnotify-bin util-linux desktop-file-utils
        ;;
    *) echo "Usage: ./install.sh [--skip-deps]" >&2; exit 1 ;;
esac
for tool in ffplay v4l2-ctl pactl pw-loopback python3 wmctrl flock desktop-file-validate; do
    command -v "$tool" >/dev/null || { echo "Missing dependency: $tool" >&2; exit 1; }
done
/usr/bin/python3 -c 'import gi, ctypes; gi.require_version("Gtk", "3.0"); from gi.repository import Gtk; ctypes.CDLL("libX11.so.6")'
bindir="$HOME/.local/bin"
apps="$HOME/.local/share/applications"
mkdir -p "$bindir" "$apps"
install -m 755 "$root/bin/capture-viewer" "$bindir/capture-viewer"
install -m 755 "$root/bin/capture-viewer-window" "$bindir/capture-viewer-window"
# Escape the executable path using desktop entry Exec syntax.
/usr/bin/python3 - "$bindir/capture-viewer" "$apps/capture-viewer.desktop" <<'PYDESKTOP'
import sys
from pathlib import Path
exe = sys.argv[1].replace('\\', '\\\\').replace('"', '\\"').replace('`', '\\`').replace('$', '\\$').replace('%', '%%')
Path(sys.argv[2]).write_text(f'''[Desktop Entry]
Type=Application
Name=Capture Viewer
Comment=1080p 60 fps video and low-latency audio
Exec="{exe}"
Icon=camera-video
Terminal=false
Categories=AudioVideo;Video;
Keywords=HDMI;capture;FFplay;UltraSemi;
StartupNotify=false
StartupWMClass=capture-viewer
''')
PYDESKTOP
desktop-file-validate "$apps/capture-viewer.desktop"
update-desktop-database "$apps"
echo "Installed. Find Capture Viewer in the application menu."
if ! pactl info 2>/dev/null | grep -qi pipewire; then
    echo "Warning: PipeWire is not active in this session. Log out and back in, then check pactl info."
fi
