# Keychron battery widget

### this is small widget to display battery state of keychron M5 in wireless 2,4GHz mode
currently supported devices:
- keychron M5

### should work on any desktop which supports system tray

### provided by default for linux via appimage and for windows via an installer exe

## Installation

### Linux
Grab the `.AppImage` from the [latest release](../../releases/latest), mark it executable and run it.

### Windows
Download `KeychronBatteryWidget-Setup-<version>.exe` from the [latest release](../../releases/latest) and run it. During setup you can tick **"Start Keychron Battery Widget automatically when Windows starts"**, which drops a shortcut into your user Startup folder so the widget launches on every sign-in. You can disable it later via Task Manager → Startup apps, or by removing the shortcut from `shell:startup`.

## Building locally

### Linux AppImage
Handled by `build-scripts/AppImageBuilder.yml`; see the `build-appimage` job in `.github/workflows/main.yml` for the exact commands.

### Windows installer
Requires Python 3.11+ and [Inno Setup 6](https://jrsoftware.org/isinfo.php) on `PATH` (or at its default install location).
```
python -m pip install -r requirements.txt pyinstaller
pyinstaller --noconfirm --clean build-scripts/keychron_widget.spec
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" /DAppVersion=0.0.0-dev build-scripts\windows_installer.iss
```
The installer lands in `build-scripts/KeychronBatteryWidget-Setup-<version>.exe`.

## Releasing
Pushing a git tag (e.g. `git tag v1.2.3 && git push origin v1.2.3`) triggers the workflow to build both the Linux AppImage and the Windows installer, then publish a GitHub release with both artifacts attached.

For convenience there's `build-scripts/release.sh` which handles tagging and pushing for you:
```
build-scripts/release.sh                  # auto-bump patch from the latest v* tag
build-scripts/release.sh minor             # bump minor instead
build-scripts/release.sh v1.2.3            # set an explicit version
build-scripts/release.sh --dry-run minor   # preview without changing anything
build-scripts/release.sh -y -w patch       # skip prompt, stream the workflow via gh
```
On Windows run it from Git Bash. It refuses to run against a dirty tree and refuses to reuse an existing tag.

---------------------
if you'd like for your keychron mouse/keyboard to be supported then open an issue following bellow instruction

1. run lsusb find your device and copy it's ID, also note bus number and device number
1. install wireshark
1. run modprobe usbmon and then run wireshark in elevated privilages via sudo
1. start monitoring usb0 in wireshark, to acctually see what's going on use filter usb.dst ~ "<bus number>.<device number>" or usb.src ~ "<bus number>.<device number>" replace numbers with outputs from lsusb
1. open keychron app, find an event in wireshark which has report in the event name, screenshot it and copy its byte representation
1. open keychron app once more with different battery level.
1. run modprobe -r usbmon to disable usb monitoring


