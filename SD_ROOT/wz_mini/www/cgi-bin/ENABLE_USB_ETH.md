USB Ethernet Adapter support:

ENABLE_USB_ETH="true"
ENABLE_USB_ETH_MODULE_AUTODETECT="true"
ENABLE_USB_ETH_MODULE_MANUAL=""
To have the Ethernet NIC be auto-detected and loaded automatically, set the ENABLE_USB_ETH_MODULE_AUTODETECT value to true.

To load a specific USB Ethernet NIC driver, set ENABLE_USB_ETH_MODULE_MANUAL to one of the following: asix, ax88179_178a, cdc_ether, r8152

NOTE: There is a possibility of a conflict between Ethernet NIC adapters that report themselves as PCI ID '0bda:8152'. (Realtek 8152 and CDC Ethernet) Since the 8152 is Realtek's product, that driver will be the one used for products that report that PCI ID. If you happen to have a CDC Ethernet product that uses that specific PCI ID, please set the ENABLE_USB_ETH_MODULE_AUTODETECT option to false, and set ENABLE_USB_ETH_MODULE_MANUAL to "cdc_ether"

The next time you boot your camera, make sure your USB Ethernet Adapter is connected to the camera and ethernet. The camera has to be setup initially with Wi-Fi for this to work. After setup, Wi-Fi is no longer needed, as long as you are using the USB Ethernet Adapter. Note that using USB Ethernet disables the onboard Wi-Fi.

