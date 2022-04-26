# wz_mini_hacks
### v3/PANv2 devices ONLY

Run whatever firmware you want on your v3/PANv2 and have root access to the device.  This is in early stages of testing, use CAUTION if you are unsure of what you are doing.  No support whatsoever is offered with this release.  

**Do not contact the manufacturer for information or support, they will not be able to assist or advise you!**

## Important matters related to security
Using this project can potentially expose your device to the open internet depending on the configuration of your network.  You alone are reponsible for the configuration and security of your network, make sure you are aware of the risks involved before using.

## Related Projects:
* wz_mini_debian: run full debian in a chroot, on the camera!
* wz_mini_utils: various statically compiled binaries for use with the camera (mipsel)


## Features

* No modification is done to the device filesystem. **_Zero!_**
* Custom kernel loads all required files from micro-sd card at boot time
* Wireguard and IPv6 support enabled
* Supports the following USB Ethernet adapters: 
  * ASIX AX88xxx Based USB 2.0 Ethernet Adapters
  * ASIX AX88179/178A USB 3.0/2.0 to Gigabit Ethernet
  * Realtek RTL8152 Based USB 2.0 Ethernet Adapters
* USB gadget support, connect the camera directly to a supported router to get an internet connection, no USB Ethernet Adapter required, using USB CDC_NCM.
* Easy uninstall, just remove files from micro-sd card, or don't use a micro-sd card at all!
* Add your own changes to run at boot into the script on the micro sd card located at /media/mmc/run_mmc.sh, mount nfs, run ping, whatever you want
* Ability to update to the latest stable or beta firmware, this mod should survive updates as long as the bootloader remains the same
* Ability to block remote AND app initiated firmware updates
* Works on ANY firmware release (so far!)
* DNS Spoofing or Telnet mod are *not* required prior to installation
* RTSP Server included, stream video and or audio over LAN

* Inspired by HclX and WyzeHacks!  Bless you for all your work!  You are the master!

## Coming Soon

* Enable tethering to android phones (RNDIS)

## How you can help!
* RTSP Server: Live view in the app doesn't work when set to "HD" or "SD", need to check libcallback sources to see why this happens, if you can help with this, check it out.
* Vertical Tilt on the PANv2 doesn't work properly.  Only does this on the modified kernel.  Need investigation why this happens.

## Prerequisites

* Person
* Computer
* 256MB or larger Micro-SD Card is required!

## What Works / What Doesn't Work
* Everything works except:

  1. v3/Pan V2: RTSP support is experimental and has several drawbacks:
     - Live view in the app only works at 360p
     - Recording to microsd card doesn't work properly
     - RTSP playback only works properly via VLC
  2. PAN v2:
     -  Tilt (Vertical) only works at motor speed 9

## Setup

1. git clone the repo or download the repo zip
2. copy all the files inside of SD_ROOT to your micro sd card
3. __SSH is enabled, but is secured using public key authentication for security.  Edit the file ```wz_mini/etc/ssh/authorized_keys``` and enter your public key here.  If you need a simple guide, [how to use public key authentication](https://averagelinuxuser.com/how-to-use-public-key-authentication/)__

## Installation
1. Turn off the camera
2. Insert the micro sd memory card into the camera
3. Turn on the camera
4. The camera will proceed to boot, then you may connect via the IP address of your device using SSH, port 22.  The username is root.  It may take a few minutes for the device to finish booting and connect to Wi-Fi, then launch the SSH server.  Be patient.
5. You may also login via the serial console, password is WYom2020

## Removal
1.  Delete the files you copied to the memory card, or remove the memory card all together.  The next time you boot the camera, you will return to stock firmware.

## Customization

Edit run_mmc.sh, this is a script stored on the micro sd card that is run when the camera boots.  You can change the hostname of the camera, mount NFS, add ping commands, anything you like.

---
Wireguard support is compiled into the kernel.  Use the command ```wg``` to setup.  See [https://www.wireguard.com/quickstart/](https://www.wireguard.com/quickstart/) for more info.

---
To disable automatic firmware updates, edit run_mmc.sh in the wz_mini directory on your micro sd card,
change:
```
DISABLE_FW_UPGRADE="false"
```

If a remote or app update is initiated, the camera will reboot due to the failure of the update.  The firmware update should not proceed again for some time, or at all.  

When a firmware update is initiated, due to a bootloader bug, we intercept the update process and flash it manually.  This should now result in a successful update, if it doesn't, please restore the unit's firmware manually using demo_wcv3.bin on the micro sd card.

---

To enable USB Ethernet Adapter support,
change:
```
ENABLE_USB_ETH="false"
```

the next time you boot your camera, make sure your USB Ethernet Adapter is connected to the camera and ethernet.  The camera has to be setup initially with Wi-Fi for this to work.  After setup, Wi-Fi is no longer needed, as long as you are using the USB Ethernet Adapter.  Note that using USB Ethernet disables the onboard Wi-Fi.

---

To enable USB Direct Support:

1. In "wz_mini" folder, there is another folder called "USB_DIRECT". Copy the file inside, named "factory_t31_ZMC6tiIDQN_USBDIRECT" to the root of your memory card and rename it to "factory_t31_ZMC6tiIDQN".  This special kernel is required to enable USB Direct, the standard kernel does not work. 

2. Edit run_mmc.sh:

change:
```
ENABLE_USB_DIRECT="false"
```

the next time you boot your camera, make sure your USB cable is connected to the router.  Remember, the camera has to be setup initially with Wi-Fi for this to work.  After setup, Wi-Fi is no longer needed.  Note that using USB Direct disables the onboard Wi-Fi.  Change the MAC Address if you desire via USB_DIRECT_MAC_ADDR variable.

Connectivity is supported using a direct USB connection only... this means a single cable from the camera, to a supported host (An OpenWRT router, for example) that supports the usb-cdc-ncm specification. (NCM, not ECM) If you have an OpenWrt based router, install the ```kmod-usb-net-cdc-ncm``` package.  The camera should automatically pull the IP from the router with most configurations.  You can also use any modern linux distro to provide internet to the camera, provided it supports CDC_NCM.  enjoy!

---
When USB Direct connectivity is enabled, the camera will be unable to communicate with accessories.  To enable remote spotlight accessory support, enable the following variable and set the IP Address of the host as follows:
```
REMOTE_SPOTLIGHT="true"
REMOTE_SPOTLIGHT_HOST="0.0.0.0"
```

Then, run the following command on the host where the spotlight is attached to:

```
socat TCP4-LISTEN:9000,reuseaddr,fork /dev/ttyUSB0,raw,echo=0
```

Change ```/dev/ttyUSB0``` to whatever path your spotlight enumerated to if necessary.  The camera will now be able to control the spotlight.

---
__WARNING: RTSP support is experimental and I consider it to be broken.  Use it only if you know what you are doing!  The outdated stock RTSP firmware works much better at the moment.__

To enable RTSP streaming, change the following lines, you can choose to enable or disable audio.  Set your login credentials here, you can also change the port the server listens on.

```
RTSP_ENABLED="false"
RTSP_ENABLE_AUDIO="false"
RTSP_LOGIN="admin"
RTSP_PASSWORD=""
RTSP_PORT="8554"
```
the stream will be located at ```rtsp://login:password@IP_ADDRESS:8554/unicast```

Note:  If you don't set the password, then the password will be the unique MAC address of the camera, in all uppercase, including the colons... for example:. AA:BB:CC:00:11:22.  It's typically printed on the camera.  VLC seems to work fine for playback, ffmpeg and others have severe artifacts in the stream during playback.  Huge credit to @mnakada for his libcallback library: [https://github.com/mnakada/atomcam_tools](https://github.com/mnakada/atomcam_tools)

__WARNING__:  If using the wyze app to view the live stream, viewing in "HD" or "SD" will not work.  Select 360p to view the live stram in the app.  Recording to micro sd is also broken.

---

## Latest Updates

* 04-26-22:  Add customizable PATH hook in v3_init.sh, and add audioplay_t31 binary for playing audio files before iCamera loads.
* 04-21-22:  Add authentication to rtsp server.  use default password as unique device mac address.
* 04-21-22:  Updated dropbear ssh, enabled public key authentication, disable password auth.
* 04-21-22:  wz_mini/tmp folder was missing in git, preventing the camera from booting. Fixed.
* 04-21-22:  Workaround for bootloader F/W upgrade bug, F/W blocking is now disabled by default.
* 04-19-22:  Add RTSP Server functionality
* 04-17-22:  Add remote spotlight accessory capability
* 04-15-22:  Enable USB Direct functionality. Allows you to connect camera using a USB cable to a device supporting CDC_NCM devices to get an internet connection, no USB Ethernet Adapter required.  
* 04-14-22:  Fix kernel command line memory mappings, resolves stability issues
* 04-14-22:  Possible memory leak with some USB adapters used, added 128MB swap file and logic as workaround to prevent oom killing
* 04-13-22:  Firmware updates are disabled by default, there is a bug in the bootloader that corrupts the kernel partition requiring the re-flash of the camera if an update is processed and the memory card is removed before next boot.  The bootloader proceeds to copy the partitions and the system will not boot unless re-flashed.  pending investigation.
* 04-12-22:  Updated, custom kernel loads all required items from micro sd card.  System modification no longer needed.
* 04-05-22:  Update readme to indicate that telnet mod nor DNS spoofing is required for installation, and add per-requisites section.
* 04-02-22:  Update to automatic install method, remove manual install.  

## BYO

Build your own!!at the moment

[https://github.com/mnakada/atomcam_tools](https://github.com/mnakada/atomcam_tools) has a great repo with docker images which include kernel sources, config, and a whole bunch of other stuff.  Check it out.

## WARNING
```
AS WITH ANY UNSUPPORTED SYSTEM MODIFICATIONS, USING THIS MAY LEAD TO A DEVICE BRICK
IF YOU DON'T KNOW WHAT YOU ARE DOING ( HAVEN'T BRICKED MY DEVICE YET! ) PLEASE
BE AWARE THAT NO ONE ON THE INTERNET IS RESPONSIBLE FOR ANY DAMAGE TO YOUR
UNIT. ANY PROBLEMS WILL BE CONSIDERED USER ERROR OR ACTS OF WHATEVER GOD YOU BELIEVE IN.
USE AT YOUR OWN RISK. NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED. 
DO NOT USE THIS SOFTWARE IF YOU ARE NOT CONFIDENT IN RESTORING YOUR DEVICE FROM A FAILED STATE.
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Thank You
Thank you to everyone who is passionate about Wyze products for making the devices popular, and thank you to Wyze for producing them.  Sign up for CamPlus, show some love and support to the company.

Thanks for HclX for WyzeHacks! [https://github.com/HclX/WyzeHacks/](https://github.com/HclX/WyzeHacks/)

Thank you mnakada for his atomcam_tools fork! [https://github.com/mnakada/atomcam_tools](https://github.com/mnakada/atomcam_tools)

Thank you bakueikozo for his atomcam_tools repo! [https://github.com/bakueikozo/atomcam_tools](https://github.com/bakueikozo/atomcam_tools)
 
Thank you to virmaior for the atomcam_tools tip!
