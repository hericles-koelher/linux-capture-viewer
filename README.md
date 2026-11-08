# Linux Capture Viewer

A configuration and desktop launcher that makes it easier to view video and listen to audio from USB capture cards on Linux Mint.

This repository provides installation scripts, a tested FFplay/PipeWire configuration, and Cinnamon desktop integration. FFplay displays the video; PipeWire routes the audio to your speakers or headphones. The launcher starts and stops them together, so you can monitor a USB capture card without opening OBS.

## Project scope

The project is a convenience setup around existing tools, not a standalone video player, capture driver, or recording application. FFmpeg/FFplay, PipeWire and the other dependencies are installed from the system package repositories and remain separate projects under their own licenses.

The launcher discovers V4L2 video capture nodes, filters out metadata-only nodes, and asks you to choose a device and one of its advertised format/resolution/frame-rate combinations. Audio is optional and can be disabled. Preferences are stored as JSON under your XDG configuration directory.

## Requirements and tested setup

- Linux Mint 22.3, Cinnamon on X11, with PipeWire active; tested with PipeWire 1.0.5 and FFmpeg 6.1.1.
- UltraSemi USB3 Video (USB ID `345f:2131`), connected over USB 3.
- 1920×1080 at 60 fps, uncompressed YUYV video.
- Stereo audio at 48 kHz through PipeWire, requesting 20 ms latency. This is a target, not a measurement of total latency.
- Capture modes exposed by this device do not include 2560×1440. Higher-resolution HDMI input acceptance has not been tested.

The installer targets Linux Mint, Ubuntu, and Debian systems using APT. Package names and availability can vary on other Debian/Ubuntu versions. Other Linux distributions are not supported by the installer.

## Install

Run these commands as your regular user:

```sh
sudo apt update
sudo apt install -y git
git clone https://github.com/hericles-koelher/linux-capture-viewer.git
cd linux-capture-viewer
./install.sh
```

The installer requests sudo for APT packages only. It installs the dependencies listed below, then places the app under `~/.local` and adds **Capture Viewer** to the application menu. PipeWire should already be active in the desktop session. The installer does not explicitly change services, default audio devices, volumes or group memberships.

### Optional: install dependencies manually

If you prefer to install the dependencies yourself, use the exact package list from the installer:

```sh
sudo apt update
sudo apt install -y ffmpeg v4l-utils pipewire pipewire-bin pipewire-pulse pulseaudio-utils python3 python3-gi gir1.2-gtk-3.0 libx11-6 wmctrl zenity libnotify-bin util-linux desktop-file-utils
./install.sh --skip-deps
```

The packages provide:

- `ffmpeg`: FFplay video playback.
- `v4l-utils`: V4L2 device and mode discovery.
- `pipewire`, `pipewire-bin`, `pipewire-pulse`, `pulseaudio-utils`: PipeWire audio routing and PulseAudio-compatible commands.
- `python3`, `python3-gi`, `gir1.2-gtk-3.0`: the GTK settings window.
- `libx11-6`, `wmctrl`: X11 window handling.
- `zenity`, `libnotify-bin`: dialogs and desktop notifications.
- `util-linux`: `flock` instance locking.
- `desktop-file-utils`: desktop entry validation and menu database update.

If all dependencies are already installed:

```sh
./install.sh --skip-deps
```

Open **Capture Viewer** from the application menu. Each launch opens one settings window with your previous choices prefilled: video device, format, resolution, frame rate, and optional audio source. Cancel closes the window without starting playback or changing saved settings. **Start** saves the selected settings and begins playback. Press **Q** or close the video window to stop playback. Audio uses the current default output. Only one viewer instance is allowed per user. To open settings from a terminal, use `~/.local/bin/capture-viewer --configure`.

## Installed files

- `~/.local/bin/capture-viewer`
- `~/.local/bin/capture-viewer-config`
- `~/.local/bin/capture-viewer-window`
- `~/.local/share/applications/capture-viewer.desktop`
- Logs: `${XDG_CACHE_HOME:-~/.cache}/capture-viewer/`

Reinstalling replaces these application files. It does not delete personal configuration. The repository is not needed after installation.

## Other devices or multiple capture devices

Configuration is saved at `${XDG_CONFIG_HOME:-~/.config}/capture-viewer/config.json`. Video nodes prefer a stable `/dev/v4l/by-id` path when available. The tested UltraSemi mode (1920x1080, 60 fps, YUYV) appears first when supported, but the selected device's advertised modes determine the available choices. The app handles a generic subset of mapped FourCC formats, discrete resolutions and frame intervals; it cannot guarantee compatibility with every USB capture card. The 2K mode limitation above applies to the tested card only.

Find identifiers and supported modes with:

```sh
v4l2-ctl --list-devices
v4l2-ctl -d /dev/video2 --list-formats-ext
pactl list short sources
pactl info
```

Use the actual capture video node rather than assuming `/dev/video2`.

## Troubleshooting

- Device missing: check `lsusb`, reconnect USB, try a direct USB 3 port and a data-capable cable.
- Video busy: close OBS or another application using the same device.
- No sound: check that the HDMI source sends audio, that PipeWire is active and that the selected output is audible. The viewer does not change mute or volume settings.
- Window title/icon integration uses X11, GTK's existing `camera-video` theme icon and WM_CLASS matching for Cinnamon. Wayland integration has not been tested.
- An occasional startup frame warning is possible. For persistent corruption or stuttering, check USB bandwidth and the logs.

## Uninstall

Close the viewer and run:

```sh
./uninstall.sh
```

Only application files are removed. System packages, logs and optional configuration remain.

## Validation

The original playback configuration was tested successfully with the actual capture device. Installer syntax and isolated user-file installation/removal are checked separately. Full installation on a second computer has not yet been tested.

## License

The scripts and documentation in this repository are licensed under the [MIT License](LICENSE).

FFmpeg/FFplay, PipeWire and other system dependencies are separate projects covered by their respective licenses. This repository does not redistribute their binaries.
