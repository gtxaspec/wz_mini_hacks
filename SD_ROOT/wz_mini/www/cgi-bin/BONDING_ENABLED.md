Network Interface Bonding Support

BONDING_ENABLED="false"
BONDING_PRIMARY_INTERFACE="eth0"
BONDING_SECONDARY_INTERFACE="wlan0"
BONDING_LINK_MONITORING_FREQ_MS="100"
BONDING_DOWN_DELAY_MS="5000"
BONDING_UP_DELAY_MS="5000"
Bonding description is best described here: https://wiki.debian.org/Bonding#Configuration_-_Example_2_.28.22Laptop-Mode.22.29:

("Laptop-Mode")

Tie cable and wireless network interfaces (RJ45/WLAN) together to define a single, virtual (i.e. bonding) network interface (e.g. bond0). As long as the network cable is connected, its interface (e.g. eth0) is used for the network traffic. If you pull the RJ45-plug, ifenslave switches over to the wireless interface (e.g. wlan0) transparently, without any loss of network packages. After reconnecting the network cable, ifenslave switches back to eth0 ("failover mode"). From the outside (=network) view it doesn't matter which interface is active. The bonding device presents its own software-defined (i.e. virtual) MAC address, different from the hardware defined MACs of eth0 or wlan0. The dhcp server will use this MAC to assign an ip address to the bond0 device. So the computer has one unique ip address under which it can be identified. Without bonding each interface would have its own ip address. Currenly supported with ethernet adapters and usb-direct mode.

BONDING_PRIMARY_INTERFACE Specifies the interface that should be the primary. Typically "eth0".

BONDING_SECONDARY_INTERFACE Specifies the interface that should be the secondary. Typically "wlan0".

BONDING_LINK_MONITORING_FREQ_MS Specifies the MII link monitoring frequency in milliseconds. This determines how often the link state of each slave is inspected for link failures.

BONDING_DOWN_DELAY_MS Specifies the time, in milliseconds, to wait before disabling a slave after a link failure has been detected. This option is only valid for the miimon link monitor. The downdelay value should be a multiple of the miimon value; if not, it will be rounded down to the nearest multiple.

BONDING_UP_DELAY_MS Specifies the time, in milliseconds, to wait before enabling a slave after a link recovery has been detected. This option is only valid for the miimon link monitor. The updelay value should be a multiple of the miimon value; if not, it will be rounded down to the nearest multiple.
