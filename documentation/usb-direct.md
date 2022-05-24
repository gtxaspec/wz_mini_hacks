# wz_mini_hacks -> USB Direct Implementation

There's a lot of confusing information about usb direct. There are several different standards and several different arrangements you can find information about:

This is *ethernet over usb* -- not *usb over ethernet* and not *an ethernet adapter over usb*.

## On the Device

set:
```
ENABLE_USB_DIRECT="true"
```

make sure that `ENABLE_USB_ETH="false"` and `ENABLE_USB_RNDIS="false"` as you can't use them all at once.

I also strongly recommend setting 

```
USB_DIRECT_MAC_ADDR="02:FF:FF:FF:FF:01"
```
for each device both to avoid conflicts and to be able to assign ip addresses.


## The Cable

The cable supplied with the wyze v3 is a power-only cable. It will not work for USB DIRECT because it doesn't have the data lines


## On Your Host

I'm using Raspbian "Buster" but much of what I'm writing will apply to most modern linux distributions.

When you plug in a usb direct NCM device, it will create a **network.** Assuming you have no other usb-based networks, it will be usb0. 

Since it is a **network**, the host will have a *host ip* and the wyze cam will be accessible via its *client ip*.

If you don't set any options beforehand, the *host ip* will be a private ip (169.254.xxx.xxx/16). **In other words, you won't be able to access the camera**.

### One-Camera Setup

To resolve this for *one camera*, you need to give the network interface:
1. a static *host ip* address
2. an ip range for the network
3. assign an ip address for the *client ip*.


#### One-Camera with /etc/network/interfaces

if you are using /etc/network/interfaces, this looks like:

```
allow-hotplug usb0
auto usb0
iface usb0 inet manual
        address 192.168.9.1
        netmask 255.255.255.0
```

and then for dnsmasq.conf:
```
interface=usb0
dhcp-range=usb0,192.168.5.2,192.168.5.255,255.255.255.0,24h
dhcp-host=usb0,02:FF:FF:FF:FF:01,192.168.5.101
```

#### One-Camera with dhcpcd.conf / dnsmasq.conf
if you are using /etc/dhcpcd.conf, this looks like:
```
interface usb0
        static ip_address=192.168.5.1/24
        nohook wpa_supplicant
```
in conjunction with /etc/dnsmasq.conf :

```
interface=usb0
dhcp-range=usb0,192.168.5.2,192.168.5.255,255.255.255.0,24h
dhcp-host=usb0,02:FF:FF:FF:FF:01,192.168.5.101
```

after that, restart dhcdpcd and dnsmasq and connect your wyze v3 and it should work.

#### One-camera with systemd-networkd

(Unfortunately I don't have a system with this configuration).

### Multiple-Camera Setup

Since each usb direct device will create its own **network interface**, if you use the above solution for multiple cameras, you're going to wind up with quite a few different networks that can't see each other.

WORSE: Depending on the order in which you turn on the usb direct devices, they will be assigned to different **network interfaces**. E.g.,
 * On Monday: Camera 1 turns on first = usb0; Camera 2 turns on second = usb1 ...
 * On Tuesday: Camera 2 turns on first = usb0; Camera 2 turns on second = usb2 ...

This will break the dhcp behavior above and make your cameras inaccessible. You could play whack-a-mole by setting up assignments for each camera in each subnet and then trying them all ...

The solution is to bridge together all of your usb direct devices so they appear as a single subnet. This will make it so that all *client ip* addresses are visible in the same subnet and can be assigned using the same dhcp-range.

#### Multiple Camera bridge setup systemd-networkd

I think this is also possible using systemd-networkd using for instance: https://forums.raspberrypi.com/viewtopic.php?t=298451

The systemd-networkd solution has the added bonus of being less lengthy since you can use wildcards

#### Multiple Camera bridge setup : dhcpcd.conf , dnsmasq.conf , /etc/network/interfaces
In my case, I was wary to switch to networkd since my pi is already running a few other network related items.

As far as I can tell, this cannot be done using *only* dhcpcd.conf because the usb direct interfaces hotplug.


First, Install bridging or make sure its installed



Second, start the bridge:

```
$ brctl addbr br0
$ ip link add name br0 type bridge
$ ip link set dev br0 up
```

Third, edit /etc/dhcpcd.conf:

```
denyinterfaces br0 usb0 usb1 usb2 usb3 usb4 usb5 usb6

interface br0
        static ip_address=192.168.9.1/24
        nohook wpa_supplicant

```
Deny interfaces tells dhcpcd not to control those items.


Fourth, add network interfaces to the  /etc/network/interfaces system

In my case, I had to put them in a different file /etc/network/interfaces.d/10-bridge.conf to avoid a check that dhcpcd does:
```
auto br0
iface br0 inet static
        address 192.168.9.1
        netmask 255.255.255.0
        bridge_ports usb0 usb1 usb2 usb3 usb4 usb5 usb6

allow-hotplug usb0
allow-hotplug usb1
allow-hotplug usb2
allow-hotplug usb3
allow-hotplug usb4
allow-hotplug usb5
allow-hotplug usb6

auto usb0
iface usb0 inet manual
        address 192.168.9.10
        netmask 255.255.255.0
        up ifconfig usb0 up
        up brctl addif br0 usb0

auto usb1
iface usb1 inet manual
        address 192.168.9.11
        netmask 255.255.255.0
        up ifconfig usb1 up
        up brctl addif br0 usb1

auto usb2
iface usb2 inet manual
        address 192.168.9.12
        netmask 255.255.255.0
        up ifconfig usb2 up
        up brctl addif br0 usb2

auto usb3
iface usb3 inet manual
        address 192.168.9.13
        netmask 255.255.255.0
        up ifconfig usb3 up
        up brctl addif br0 usb3

auto usb4
iface usb4 inet manual
        address 192.168.9.14
        netmask 255.255.255.0
        up ifconfig usb4 up
        up brctl addif br0 usb4


auto usb5
iface usb5 inet manual
        address 192.168.9.15
        netmask 255.255.255.0
        up ifconfig usb5 up
        up brctl addif br0 usb5

auto usb6
iface usb6 inet manual
        address 192.168.9.16
        netmask 255.255.255.0
        up ifconfig usb6 up
        up brctl addif br0 usb6


```

Fifth,

dnsmasq.conf:

```
interface=br0
dhcp-range=br0,192.168.9.2,192.168.9.255,255.255.255.0,24h
dhcp-host=br0,02:FF:FF:FF:FF:01,192.168.9.101
dhcp-host=br0,02:FF:FF:FF:FF:02,192.168.9.102
dhcp-host=br0,02:FF:FF:FF:FF:03,192.168.9.103
dhcp-host=br0,02:FF:FF:FF:FF:04,192.168.9.104
dhcp-host=br0,02:FF:FF:FF:FF:05,192.168.9.105
dhcp-host=br0,02:FF:FF:FF:FF:06,192.168.9.106
dhcp-host=br0,02:FF:FF:FF:FF:07,192.168.9.107


```
**interface** tells dnsmasq what network interface to monitor
**dhcp-range** tells it what range it assigns over
**dhcp-host** tells what interface / what mac address gets what ip address (apparently in *very* old version of dnsmasq you could not set the interface at the beginning)

Finally, restart dhcpcd and dnsmasq and turn on your usb direct device

You should be able to access the cameras at 192.168.9.101 -  192.168.9.107

(you would need to modify /etc/network/interfaces and dnsmasq.conf to expand past 7 cameras )




