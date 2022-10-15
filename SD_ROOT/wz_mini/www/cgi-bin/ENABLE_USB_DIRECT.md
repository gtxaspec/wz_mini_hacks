the next time you boot your camera, make sure your USB cable is connected to the router. Note that using USB Direct disables the onboard Wi-Fi. Change the MAC Address if you desire via USB_DIRECT_MAC_ADDR variable.

Connectivity is supported using a direct USB connection only... this means a single cable from the camera, to a supported host (An OpenWRT router, for example) that supports the usb-cdc-ncm specification. (NCM, not ECM) If you have an OpenWrt based router, install the kmod-usb-net-cdc-ncm package. The camera should automatically pull the IP from the router with most configurations. You can also use any modern linux distro to provide internet to the camera, provided it supports CDC_NCM. enjoy!

Note: In my testing, the micro-usb cables included with the various cameras do not pass data, so they will not work. Make sure you have a micro-usb cable that passes data!
