# Linux Capture Viewer

A lightweight HDMI capture viewer for Linux Mint using FFplay for video and PipeWire for audio. No OBS required.

## Tested setup

- Linux Mint 22.3, Cinnamon on X11, PipeWire 1.0.5, FFmpeg 6.1.1.
- UltraSemi USB3 Video (USB ID `345f:2131`), connected over USB 3.
- 1920×1080 at 60 fps, uncompressed YUYV video.
- Stereo audio at 48 kHz through PipeWire, requesting 20 ms latency. This is a target, not a measurement of total latency.
- Capture modes exposed by this device do not include 2560×1440. Higher-resolution HDMI input acceptance has not been tested.

## Install

Clone this repository, enter its directory, then run:

```sh
./install.sh
```

Run as your regular user. The installer requests sudo for APT packages only. It installs FFmpeg, V4L2 utilities, PipeWire tools, audio utilities and window integration dependencies. Package installation can affect the system audio stack: this was designed for Mint with PipeWire already active. It does not explicitly change services, default audio devices, volumes or group memberships.

If all dependencies are already installed:

```sh
./install.sh --skip-deps
```

Open **Capture Viewer** from the application menu. Press **Q** or close the video window to stop both video and audio. Audio uses the default output selected when launching. Only one viewer instance is allowed per user.

The launcher detects a single UltraSemi USB3 Video device automatically, without a fixed device number, serial number or username. Connect the USB capture device and an active HDMI source before launching.

## Installed files

- `~/.local/bin/capture-viewer`
- `~/.local/bin/capture-viewer-window`
- `~/.local/share/applications/capture-viewer.desktop`
- Logs: `${XDG_CACHE_HOME:-~/.cache}/capture-viewer/`

Reinstalling replaces these application files. It does not delete personal configuration. The repository is not needed after installation.

## Other devices or multiple capture devices

Create `${XDG_CONFIG_HOME:-~/.config}/capture-viewer/config.sh` with the exact device paths/names:

```sh
video=/dev/v4l/by-id/usb-YOUR_DEVICE-video-index0
source=alsa_input.usb-YOUR_DEVICE.analog-stereo
```

This is a trusted shell configuration file executed as your user. Device formats remain fixed to the tested 1080p60 YUYV setup; change the viewer script if your device requires another format.

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
