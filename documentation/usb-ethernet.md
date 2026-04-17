# USB Ethernet Setup

This repository supports USB Ethernet adapters as the primary network path.

## Required config

Set in `/opt/wz_mini/wz_mini.conf`:

```sh
ENABLE_USB_ETH="true"
ENABLE_USB_ETH_MODULE_AUTODETECT="true"
ENABLE_USB_ETH_MODULE_MANUAL=""
USB_ETH_MAC_ADDR=""
```

## Adapter detection

When auto-detect is enabled, known ASIX, AX88179/178A, Realtek RTL8152, and CDC Ethernet adapters are detected and their matching drivers are loaded.

If your adapter is not in the auto-detect list, set `ENABLE_USB_ETH_MODULE_MANUAL` to a comma-separated list of module names (without `.ko`), for example:

```sh
ENABLE_USB_ETH_MODULE_MANUAL="cdc_ncm"
```

## Interface behavior

After USB Ethernet comes up, the scripts remap interfaces so the camera stack continues to use `wlan0` while traffic is carried over the alternate interface.

## Notes

- Use a USB OTG/data-capable cable and a compatible adapter.
- Optional: set `USB_ETH_MAC_ADDR` to force a stable MAC address.
