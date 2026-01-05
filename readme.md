# Keychron battery widget

### this is small widget to display battery state of keychron M5 in wireless 2,4GHz mode
currently supported devices:
- keychron M5

### should work on any desktop which supports system tray

### provided by default for linux via appimage, should work on windows but will require manual compile to exe

---------------------
if you'd like for your keychron mouse/keyboard to be supported then open an issue following bellow instruction

1. run lsusb find your device and copy it's ID, also note bus number and device number
1. install wireshark
1. run modprobe usbmon and then run wireshark in elevated privilages via sudo
1. start monitoring usb0 in wireshark, to acctually see what's going on use filter usb.dst ~ "<bus number>.<device number>" or usb.src ~ "<bus number>.<device number>" replace numbers with outputs from lsusb
1. open keychron app, find an event in wireshark which has report in the event name, screenshot it and copy its byte representation
1. open keychron app once more with different battery level.
1. run modprobe -r usbmon to disable usb monitoring


