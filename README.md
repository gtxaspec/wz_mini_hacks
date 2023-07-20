# wz_mini_hacks
### Ingenic based T20/T31 based devices only!

Run whatever firmware you want on your camera and have root access to the device.  Use CAUTION if you are unsure of what you are doing.  Permanent damage is possible to your device.  No support whatsoever is offered with this release.  

**Do not contact any manufacturer for information or support, they will not be able to assist or advise you!**

## Important matters related to security

Using this project can potentially expose your device to the open internet depending on the configuration of your network.  You alone are responsible for the configuration and security of your network, make sure you are aware of the risks involved before using.

## Features

* No hardware modifications needed to the device!
* Easy uninstall, just remove files from micro-sd card, or don't use a micro-sd card at all!
* Compatability is not guaranteed with really old firmware versions!
* Update to the latest stable or beta firmware, this mod should still work! (most features, see the wiki: [Firmware Support] (https://github.com/gtxaspec/wz_mini_hacks/wiki/Firmware-Support)
* Block remote or app initiated firmware updates
* DNS Spoofing or Telnet mod are *not* required prior to installation
* RTSP Streaming Support:
  * v4l2rtspserver
  * go2rtc
* RTMP Streaming - Stream live video from the camera to your favorite service, youtube, twitch, or facebook live.
* Networking: 
  * Wireguard, IPv6, CIFS/Samba and iptables support enabled
  * Tether your camera directly to android phones using USB via RNDIS support
  * USB gadget support, connect the camera directly to a supported router to get an internet connection, no USB Ethernet Adapter required, using USB CDC_NCM.
* Supports the following USB Ethernet adapters: 
  * ASIX AX88xxx Based USB 2.0 Ethernet Adapters
  * ASIX AX88179/178A USB 3.0/2.0 to Gigabit Ethernet
  * Realtek RTL8152 Based USB 2.0 Ethernet Adapters
  * CDC-Ether Based Adapters
* USB Mass storage enabled, mount USB SSD/HDD/flash drives
* Play audio to the camera speaker from files or streaming audio!
* WebCam Mode - Use your camera as a spare UVC USB Web Camera on your PC or AndroidTV!
* Custom boot script support included

## How you can help!

* Vertical Tilt on the PANv2 doesn't work properly.  Only does this on the modified kernel.  Need investigation why this happens.

## Why?

* Most things in life relate to cats somehow.  I started this project to track the local feral cat population in my neighborhood using cameras.

## Prerequisites

* Person
* Cat ( for emotional support during setup )
* Computer
* 256MB or larger Micro-SD Card is required!
* Higher class Micro-SD cards will ensure better performance

## Setup / Configuration / Installation

#### Visit the [Installation & Setup](https://github.com/gtxaspec/wz_mini_hacks/wiki/Setup-&-Installation) section of the [Wiki](https://github.com/gtxaspec/wz_mini_hacks/wiki) for details!

## What Works / What Doesn't Work

* Everything works except:

  1. PAN v2:
     -  Tilt (Vertical) only works at motor speed 9

## HELP! SOMETHING DOESN'T DOESN'T WORK

* If you need assistance, or have general questions, feel free to visit the [Discussions](https://github.com/gtxaspec/wz_mini_hacks/discussions) area!  There are folks always willing to help out.

---

## Latest Updates

* 07-19-23:  update go2rtc to master version, replace socat with ser2net server for remote accessories, fix setting FPS in config, fix usb direct, add set mac address for usb ethernet adapters, cloud config backups now visible on sd card root.
* 07-13-23:  Updated README, updated wiki, updated ffmpeg build with musl and cpu optimizations.
* 07-12-23:  Fixed RTSP urls for v2 camera's in web config, set config modification in web server to read-only, set lib-opus as default in go2rtc config
* 07-11-23:  Support 30fps. Add new go2rtc server support for rtsp/hls/webrtc/etc. go2rtc fixed audio in tinycam app. Make video parameters, bitrate, rcmode, and fps independent of rtsp server settings.  fixed various init scripts.  Recommend to start from a fresh install.

## BYO

Build your own!!

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

Inspired by HclX, bakueikozo, and mnakada!

Thank you to everyone who is passionate about Wyze products for making the devices popular, and thank you to Wyze for producing them.  Sign up for CamPlus, show some love and support to the company.

Thanks for HclX for WyzeHacks! [https://github.com/HclX/WyzeHacks/](https://github.com/HclX/WyzeHacks/)

Thank you mnakada for his atomcam_tools fork! [https://github.com/mnakada/atomcam_tools](https://github.com/mnakada/atomcam_tools)

Thank you bakueikozo for his atomcam_tools repo! [https://github.com/bakueikozo/atomcam_tools](https://github.com/bakueikozo/atomcam_tools)
 
Thank you to virmaior for the atomcam_tools tip!
