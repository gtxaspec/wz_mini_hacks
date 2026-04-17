# wz_mini_hacks (USB Ethernet Focused)

This fork is intentionally scoped to one use case: running Wyze/Atomcam T20/T31 devices with a USB Ethernet adapter.

## What this fork keeps

- USB Ethernet adapter support (`ENABLE_USB_ETH`)
- Ethernet module auto-detect and optional manual module list
- Interface handoff so camera services continue to use `wlan0`
- Core boot/swap/firmware-intercept behavior needed for stable operation

## Configuration

Edit:

- `/opt/wz_mini/wz_mini.conf` on device
- `SD_ROOT/wz_mini/wz_mini.conf` in this repository

Primary settings:

- `ENABLE_USB_ETH="true"`
- `ENABLE_USB_ETH_MODULE_AUTODETECT="true"`
- `ENABLE_USB_ETH_MODULE_MANUAL=""` (comma-separated module names without `.ko` when needed)
- `USB_ETH_MAC_ADDR=""` (optional override)
- `CUSTOM_HOSTNAME="WCV3"` (optional hostname)

## Safety

Use at your own risk. Unsupported system modifications can brick devices.

## Additional docs

- `documentation/usb-ethernet.md`
