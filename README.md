# wz_mini_hacks
### v3/PANv2 devices ONLY

Run whatever firmware you want on your cameras and have root access to the device.  This is in early stages of testing, use CAUTION if you are unsure of what you are doing.  No support whatsoever is offered with this release.  
**Do not contact the manufacturer for information or support, they will not be able to assist you!**

### Related Projects:
* wz_mini_debian: run full debian in a chroot, on the camera!
* wz_mini_utils: various statically compiled binaries for use with the camera (mipsel)


## Features

* No modification is done to the system. **_Zero!_**
* Custom kernel loads all required files from micro-sd card
* Wireguard, and ipv6 support enabled
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
* *NEW* Installation-Free!  Put files on the micro sd card and wait for the unit to boot!
* PAN v2 now supported

* Inspired by HclX and WyzeHacks!  Bless you for all your work!  You are the master!

## Coming Soon

* Enable tethering to android phones (RNDIS)

## Prerequisites

* Person
* Computer
* Micro-SD Card is required!

## Setup

1. git clone the repo or download the repo zip
2. copy all the files inside of SD_ROOT to your micro sd card

## Installation
1. Turn off the camera
2. Insert the micro sd memory card into the camera
3. Turn on the camera
4. The camera will boot, then you may connect via the IP address of your device using SSH, port 22.  username is root password is WYom2020.  It may take a few minutes for the device to finish booting and connect to wifi, then launch the SSH server.  Be patient.

## Removal
1.  Delete the files you copied to the memory card.  The next time you boot the camera, you will return to stock firmware.

## Customization

Edit run_mmc.sh, this is a script stored on the micro sd card that is run when the camera boots.  You can change the hostname of the camera, mount NFS, add ping commands, anything you like.

---
**DO NOT ENABLE FIRMWARE UPDATES, CURRENTLY THERE IS A BOOTLOADER BUG WHICH RESULTS IN A BROKEN SYSTEM.  currently set to true by default.**
To disable automatic firmware updates, edit run_mmc.sh in the wz_mini directory on your micro sd card,
change:
```
DISABLE_FW_UPGRADE="false"
```
to:

```
DISABLE_FW_UPGRADE="true"
```
If a remote or app update is initiated, the camera will reboot due to the failure of the update.  The firmware update should not proceed again for some time, or at all.

---

To enable USB Ethernet Adapter support,
change:
```
ENABLE_USB_ETH="false"
```
to:

```
ENABLE_USB_ETH="true"
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
to:

```
ENABLE_USB_DIRECT="true"
```
the next time you boot your camera, make sure your USB cable is connected to the router.  Remember, the camera has to be setup initially with Wi-Fi for this to work.  After setup, Wi-Fi is no longer needed.  Note that using USB Direct disables the onboard Wi-Fi.  Change the MAC Address if you desire via USB_DIRECT_MAC_ADDR variable.

Connectivity is supported using a direct USB connection only... this means a single cable from the camera, to a supported host (An OpenWRT router, for example) that supports the usb-cdc-ncm specification. (NCM, not ECM) If you have an OpenWrt based router, install the ```kmod-usb-net-cdc-ncm``` package.  The camera should automatically pull the IP from the router with most configurations.  You can also use any modern linux distro to provide internet to the camera, provided it supports CDC_NCM.  enjoy!

---


## Latest Updates

* 04-15-22:  Enable USB Direct functionality. Allows you to connect camera using a USB cable to a device supporting CDC_NCM devices to get an internet connection, no USB Ethernet Adapter required.  
* 04-14-22:  Fix kernel command line memory mappings, resolves stability issues
* 04-14-22:  Possible memory leak with some USB adapters used, added 128MB swap file and logic as workaround to prevent oom killing
* 04-13-22:  Firmware updates are disabled by default, there is a bug in the bootloader that corrupts the kernel partition requiring the re-flash of the camera if an update is processed and the memory card is removed before next boot.  The bootloader proceeds to copy the partitions and the system will not boot unless re-flashed.  pending investigation.
* 04-12-22:  Updated, custom kernel loads all required items from micro sd card.  System modification no longer needed.
* 04-05-22:  Update readme to indicate that telnet mod nor DNS spoofing is required for installation, and add pre-requisites section.
* 04-02-22:  Update to automatic install method, remove manual install.  

## BYO

Build your own!!

https://github.com/mnakada/atomcam_tools has a great repo with docker images which include kernel sources, config, and a whole bunch of other stuff.  Check it out.

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

Thanks for HclX for WyzeHacks! https://github.com/HclX/WyzeHacks/  
Thank you mnakada for his atomcam_tools fork! https://github.com/mnakada/atomcam_tools  
Thank you bakueikozo for his atomcam_tools repo! https://github.com/bakueikozo/atomcam_tools  
Thank you to virmaior for the atomcam_tools tip!
