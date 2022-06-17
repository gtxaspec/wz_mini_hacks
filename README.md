# wz_mini_hacks
### v2/v3/PANv2 devices ONLY

Run whatever firmware you want on your v2/v3/PANv2 and have root access to the device.  This is in early stages of testing, use CAUTION if you are unsure of what you are doing.  No support whatsoever is offered with this release.  

**Do not contact the manufacturer for information or support, they will not be able to assist or advise you!**

## Important matters related to security
Using this project can potentially expose your device to the open internet depending on the configuration of your network.  You alone are responsible for the configuration and security of your network, make sure you are aware of the risks involved before using.

## Related Projects:
* wz_mini_debian: run full debian in a chroot, on the camera! (coming soon)
* ~~wz_mini_utils: various statically compiled binaries for use with the camera (mipsel)~~ (deprecated, all utils now located in wz_mini/bin)

## Features

* No modification is done to the device filesystem. **_Zero!_** (T31 only)
* Custom kernel loads all required files from micro-sd card at boot time
* Easy uninstall, just remove files from micro-sd card, or don't use a micro-sd card at all!
* Works on ANY firmware release (so far!)
  * Update to the latest stable or beta firmware, this mod should still work!
  * Block remote or app initiated firmware updates
  * DNS Spoofing or Telnet mod are *not* required prior to installation
* Wireguard and IPv6 support enabled
* Supports the following USB Ethernet adapters: 
  * ASIX AX88xxx Based USB 2.0 Ethernet Adapters
  * ASIX AX88179/178A USB 3.0/2.0 to Gigabit Ethernet
  * Realtek RTL8152 Based USB 2.0 Ethernet Adapters
* USB gadget support, connect the camera directly to a supported router to get an internet connection, no USB Ethernet Adapter required, using USB CDC_NCM.
* Custom script support included
* RTSP Server included, stream video and or audio over LAN
* Tether your camera directly to android phones using USB via RNDIS support
* USB Mass storage enabled, mount USB SSD/HDD/flash drives
* CIFS Supported
* iptables included
* Play .wav audio files using "cmd aplay <file> <vol>" command
* WebCam Mode - Use your camera as a spare UVC USB Web Camera on your PC or AndroidTV!
* RTMP Streaming - Stream live video from the camera to your favorite service, youtube, twitch, or facebook live.

## Coming Soon
* onvif - maybe
* overlayfs support

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

## What Works / What Doesn't Work
* Everything works except:

  1. PAN v2:
     -  Tilt (Vertical) only works at motor speed 9

## HELP! SOMETHING DOESN'T DOESN'T WORK

* If you need assistance, or have general questions, feel free to visit the [Discussions](https://github.com/gtxaspec/wz_mini_hacks/discussions) area!  There are folks always willing to help out.

## Setup v3/PANv2

1. git clone the repo or download the repo zip
2. perform a fresh format on your micro-sd card, using fat-32 ( this is a hard requirement, the bootloader does not support ex-fat or ext, and thus will not load wz_mini ), DOS partition map type, volume name does not matter.
3. copy all the files inside of SD_ROOT to your micro sd card
4. __SSH is enabled, but is secured using public key authentication for security.  Edit the file ```wz_mini/etc/ssh/authorized_keys``` and enter your public key here.  If you need a simple guide, [how to use public key authentication](https://averagelinuxuser.com/how-to-use-public-key-authentication/)__

## Installation v3/PANv2

1. Turn off the camera
2. Insert the micro sd memory card into the camera
3. Turn on the camera
4. The camera will proceed to boot, then you may connect via the IP address of your device using SSH, port 22.  The username is root.  It may take a few minutes for the device to finish booting and connect to Wi-Fi, then launch the SSH server.  Be patient.
5. You may also login via the serial console, password is WYom2020

## Setup v2

1. git clone the repo or download the repo zip
2. perform a fresh format on your micro-sd card, using fat-32 ( this is a hard requirement, the bootloader does not support ex-fat or ext, and thus will not load wz_mini ), DOS partition map type, volume name does not matter.
3. Run `compile_image.sh` using linux, wait for the script to finish.
4. Copy all the files inside of SD_ROOT to your micro sd card
5. Copy the generated `demo.bin` to root of your micro sd card
6. __SSH is enabled, but is secured using public key authentication for security.  Edit the file ```wz_mini/etc/ssh/authorized_keys``` and enter your public key here.  If you need a simple guide, [how to use public key authentication](https://averagelinuxuser.com/how-to-use-public-key-authentication/)__

## Installation v2

1. Insert the micro sd memory card into the camera
2. Hold down reset button while powering unit on.  This is the standard manual firmware restore procedure.
3. Wait for camera to flash the latest modified firmware, and reboot, do not remove the micro sd card.
4. The camera will proceed to boot, then you may connect via the IP address of your device using SSH, port 22.  The username is root.  It may take a few minutes for the device to finish booting and connect to Wi-Fi, then launch the SSH server.  Be patient.  You should hear audio prompts from the camera once it has booted successfully.
5. You may also login via the serial console, password is WYom2020

## Removal
1.  Delete the files you copied to the memory card, or remove the memory card all together.  The next time you boot the camera, you will return to stock firmware.

## Customization

Edit wz_mini.conf, this is stored on the micro sd card inside the wz_mini folder, and loads the configuration variables when the camera boots.  You can change the hostname of the camera, add a path to a script to mount NFS, add ping commands, anything you like.

---

Wireguard support is available as a kernel module:

```
ENABLE_WIREGUARD="true"
```

Use the command ```wg``` to setup.  See [https://www.wireguard.com/quickstart/](https://www.wireguard.com/quickstart/) for more info.

Some users have asked about tailscale support, I have tested and it works.  See the issue #30 for further information.

Example setup:
```
ENABLE_WIREGUARD="true"
WIREGUARD_IPV4="192.168.2.101/32"
WIREGUARD_PEER_ENDPOINT="x.x.x.x:51820"
WIREGUARD_PEER_PUBLIC_KEY="INSERT_PEER_PUBLIC_KEY_HERE"
WIREGUARD_PEER_ALLOWED_IPS="192.168.2.0/24"
WIREGUARD_PEER_KEEP_ALIVE="25"
```

To retrieve the public key that you'll need to add the peer to your wireguard endpoint:
1. Use SSH to log in
2. `wg`

---

Disable automatic firmware updates:

```
DISABLE_FW_UPGRADE="true"
```

If a remote or app update is initiated, the camera will reboot due to the failure of the update.  The firmware update should not proceed again for some time, or at all.  

When a firmware update is initiated, due to a bootloader issue (bug?), we intercept the update process and flash it manually.  This should now result in a successful update, if it doesn't, please restore the unit's firmware manually using demo_wcv3.bin on the micro sd card.

---

USB Ethernet Adapter support:

```
ENABLE_USB_ETH="true"
ENABLE_USB_ETH_MODULES="asix,r8152,cdc_ether"
```

available modules: asix, ax88179_178a, cdc_ether, r8152

the next time you boot your camera, make sure your USB Ethernet Adapter is connected to the camera and ethernet.  The camera has to be setup initially with Wi-Fi for this to work.  After setup, Wi-Fi is no longer needed, as long as you are using the USB Ethernet Adapter.  Note that using USB Ethernet disables the onboard Wi-Fi.  Specify the driver you need for your specific USB Ethernet adapter. asix is listed by default.

---

USB Direct Support:

```
ENABLE_USB_DIRECT="true"
```

the next time you boot your camera, make sure your USB cable is connected to the router.  Remember, the camera has to be setup initially with Wi-Fi for this to work.  After setup, Wi-Fi is no longer needed.  Note that using USB Direct disables the onboard Wi-Fi.  Change the MAC Address if you desire via USB_DIRECT_MAC_ADDR variable.

Connectivity is supported using a direct USB connection only... this means a single cable from the camera, to a supported host (An OpenWRT router, for example) that supports the usb-cdc-ncm specification. (NCM, not ECM) If you have an OpenWrt based router, install the ```kmod-usb-net-cdc-ncm``` package.  The camera should automatically pull the IP from the router with most configurations.  You can also use any modern linux distro to provide internet to the camera, provided it supports CDC_NCM.  enjoy!

Note: In my testing, the micro-usb cables included with the various cameras do not pass data, so they will not work.  Make sure you have a micro-usb cable that passes data!

---

Remote Accessories:

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

USB Mass Storage Support:

```
ENABLE_USB_STORAGE="true"
```
If you would like to mount an EXT3/4 filesystem, also change:

```
ENABLE_EXT4="true"
```

---

CIFS is now supported:

```
ENABLE_CIFS="true"
```

---

iptables (ipv4 and ipv6) is available:

```
ENABLE_IPTABLES="true"
```

---

NFSv4 support is available:

```
ENABLE_NFSv4="true"
```

---
RTSP streaming:
The RTSP server supports the two video streams provided by the camera, 1080p/360p (1296p/480p for the DB3).  You can choose to enable a single stream of your choice, or both.  Audio is also available.  Set your login credentials here, server listening port, and the stream bitrate.
(ENC_PARAMETER variable accepts numbers only.  0=FIXQP, 1=CBR, 2=VBR, 4=CAPPED VBR, 8=CAPPED QUALITY.  Currently only 2, 4, and 8 are working)

```
RTSP_LOGIN="admin"
RTSP_PASSWORD=""
RTSP_PORT="8554"

RTSP_HI_RES_ENABLED="true"
RTSP_HI_RES_ENABLE_AUDIO="true"
RTSP_HI_RES_MAX_BITRATE="2048"
RTSP_HI_RES_TARGET_BITRATE="1024"
RTSP_HI_RES_ENC_PARAMETER="2"
RTSP_HI_RES_FPS="15"

RTSP_LOW_RES_ENABLED="false"
RTSP_LOW_RES_ENABLE_AUDIO="false"
RTSP_LOW_RES_MAX_BITRATE=""
RTSP_LOW_RES_TARGET_BITRATE=""
RTSP_LOW_RES_ENC_PARAMETER=""
RTSP_LOW_RES_FPS=""

```
the singular stream will be located at ```rtsp://login:password@IP_ADDRESS:8554/unicast```
multiple streams are located at ```rtsp://login:password@IP_ADDRESS:8554/video1_unicast``` and ```rtsp://login:password@IP_ADDRESS:8554/video2_unicast```

Note:  If you don't set the password, the password will be set to the unique MAC address of the camera, in all uppercase, including the colons... for example:. AA:BB:CC:00:11:22.  It's typically printed on the camera.  Higher video bitrates may overload your Wi-Fi connection, so a wired connection is recommended.

Huge credit to @mnakada for his libcallback library: [https://github.com/mnakada/atomcam_tools](https://github.com/mnakada/atomcam_tools)

---

mp4_write:

```
ENABLE_MP4_WRITE="false"
```

Forces the camera to skip writing files to /tmp, and write them directly to your storage medium or network mount, prevents trashing.  Normally videos are written to /tmp then moved using `mv`, which can overload camera and or remote network connections. Useful for NFS/CIFS remote video storage.

---

Use as a USB Video Class (UVC) Web Camera for your PC is supported.  I have tested with Windows 10, Linux, and Android TV, and it appears as a Generic HD Camera.  Audio is supported.  This mode disables all other functionality, and only works as a USB Web Camera for your PC.  Experimental.  Note that the cables typically included with the camera do not data, use a known working micro-usb cable which supports data.

Supported modes: MJPG,Video 360p/720p/1080p

```
WEB_CAM_ENABLE="true"
WEB_CAM_BIT_RATE="8000"
WEB_CAM_FPS_RATE="25"
```

---

Run a custom script:

```
CUSTOM_SCRIPT_PATH=""
```

---

RTMP Streaming:

```
RTMP_STREAM_ENABLED="true"
RTMP_STREAM_FEED="video1_unicast"
RMTP_STREAM_SERVICE="youtube"
RTMP_STREAM_DISABLE_AUDIO="false"
RTMP_STREAM_YOUTUBE_KEY="xxx-xxx-xxx-xxx"
RTMP_STREAM_TWITCH_KEY=""
RTMP_STREAM_FACEBOOK_KEY=""
```

Live stream DIRECTLY from the camera's local RTSP server to: `youtube` / `twitch` / `facebook` live.  Audio must be enabled in the RTSP section of the configuration for this to work.  

---

IMP_CONTROL:  Tune various audio and video parameters supported by IMP.  Only available when RTSP server is enabled, values are reset to default upon reboot.

`cmd imp_control <command> <value>`

| function name  | Value | Description |
| ------------- | ------------- | ----------- |
| __AUDIO__|
| agc_on  | <none>  | Enable Automatic Gain Control |
| agc_off  | <none>  | Disable Automatic Gain Control |
| hpf_on  | <none>  | Enable High Pass Filter |
| hpf_off  | <none>  | Disable High Pass Filter |
| ns_on | <none>  | Enable Noise Supression |
| ns_off  | <none>  | Disable Noise Supression |
| aec_on  | <none>  | Enable Automatic Echo Cancellation |
| aec_off  | <none>  | Disable Automatic Echo Cancellation |
| ai_vol  | -30 to 120  | Audio Input Volume |
| ai_gain  | 0 to 31  | Audio Input Gain |
| alc_gain  | 0 to 7  | Automatic Level Control Gain |
| ao_gain | 0 to 31  | Audio Output Gain |
| ao_vol | -30 to 120 | Audio Output Volume |
| ------------- | ------------- | ----------- |
| __VIDEO__ |
| flip_mirror | <none>  | Mirror Image |
| flip_vertical | <none>  | Flip Vertical |
| flip_horizontal | <none>  | Flip Horizontal |
| flip_normal | <none>  | Normal Image |
| tune_contrast | -128 to 128  | Contrast Control |
| tune_brightness | -128 to 128 | Brightness Control |
| tune_sharpness | -128 to 128 | Sharpness Control |
| tune_saturation | -128 to 128 | Saturation Control |
| tune_aecomp | 0 to 255 | Auto Exposure Target |
| tune_aeitmax | 0 to 10000 | Auto Exposure Maxiumum (no v2) |
| tune_dpc_strength | -128 to 128 | DPC Strength (no v2) |
| tune_drc_strength | -128 to 128 | DRC Strength (no v2) |
| tune_hilightdepress | 0 to 10 | Glare Supression |
| tune_temper | -128 to 128 | 3D Noise reduction strength |
| tune_sinter | -128 to 128 | 2D Noise reduction strength |
| tune_again | 0 to 99999 | Set sensor A-Gain maximum |
| tune_dgain | see notes | Maximum D-Gain set by the ISP |
| tune_backlightcomp | -1 to 3500 | Backlight Compensation? (undocumented, no v2) |
| tune_dps | 50 to 150 | Set DPC intensity (v2 only) |

tune_dgain: 0 means 1x, 32 means 2x, and so on 

need help:
change framerate dynamically up to 30fps
change audio hz frequency dynamically up to 44100
change audio format from g711
move OSD to user specified region
white balance adjustment
enable wide dynamic range support
exposure value support

---

```
ENABLE_RTL8189FS_DRIVER="false"
```

Use a newer version of the driver for the RTL8189FTV on v2/v3.  May result in better wireless connection/performance. Experimental.

---

Upgrade wz_mini over the air:

`upgrade-run.sh`

This script will upgrade wz_mini over the air.  It will backup `wz_mini.conf`, any files stored in `wz_mini/etc/configs`, ssh keys, and wireguard configs.  It will download the latest master version, extract it, reboot into upgrade mode, perform the upgrade, then reboot to the updated system.

If there are any line differences between the old `wz_mini.conf` and the new release, the script will preserve the current config in place.  Note that this means any missing or additional lines.  It is recommended to download the latest wz_mini.conf from github, if there are any major changes to the file, copy the new one to your system first, set your parameteres, save the file, then perform the upgrade.

NOTE: if you are upgrading a V2 camera from a release older than 06-16-22, you must manually download the upgrade-run.sh script from this repo and place it in `wz_mini/bin/upgrade-run.sh`, then run it from there !
---

## Latest Updates

* 06-17-22:  Fix custom hostname not being set.  Note: The hostname variable has CHANGED!  You will need to update your `wz_mini.conf` file.
* 06-16-22:  Simplified the camera model detection method throughout wz_mini.
* 06-16-22:  fix scp client bug, allow user modifications to app_init, updated initramfs script, moved upgrade-run to PATH, revised kernel module paths, added ENABLE_RTL8189FS_DRIVER option for v2/v3, updated kernels for v2/v3. ( NOTE: this is a major upgrade, file names for the init scripts have changed, if you are upgrading the V2, do not use the upgrade-run.sh script, please manually update )
* 06-14-22:  Updated v4l2rtspserver, fixes to prevent rare low memory situations and RTSP server crashes, fixed intermittant failed RTSP HD stream, script logic updates.
* 06-12-22:  Added additional audio variables for tuning in libcallback, various bug fixes in wz_user.  Added `gather_wz_logs.sh` script for users to share debug logs.
* 06-07-22:  Added support to tune IMP video and audio options in libcallback.
* 06-04-22:  updated v2 kernel with fix for webcam mode on v2 camera's, working well now.  Updated RTMP streaming.
* 05-31-22:  added kernel and initramfs configs to src dir, fixed old logs deleted on boot, save dmesg to log folder, upgrade script fixes, user selectable usb ethernet kernel modules in config.
* 05-27-22:  update `rtmp-stream.sh`, update various system binaries.
* 05-25-22:  usb direct mode and rndis are now supported on the v2 camera
* 05-25-22:  add experimental youtube/twitch/facebook live steam rtmp support in `wz_mini/usr/bin/rtmp-stream.sh`
* 05-24-22:  add `wz_mini.conf` to replace `run_mmc.sh`, all configuration variables are now stored in this file, scripting logic now in wz_user.sh inside init.d folder. add support for user to add a custom script to run on boot.
* 05-23-22:  added simple wireguard startup configuration.
* 05-22-22:  added fps variable for rtsp server, thanks @claudobahn.
* 05-22-22:  Update wz_mini scripts and libraries to support v2 camera.  experimental.
* 05-20-22:  updated to latest libcallback including mp4write, bug fixes: usb direct mac addr, usb webcam mode bad variable.
* 05-18-22:  Added PC Web Camera functionality, changed RTSP server, when you use enable more than one stream, they share the port and use different paths.
* 05-15-22:  fixed rtsp audio for low-res rtsp stream, patched libcallback sources for audio channel 1.
* 05-15-22:  patched libcallback to support both video streams from the camera.  Added support for them in run_mmc.sh.
* 05-14-22:  Added ability to specify RTSP bitrate parameters.  Note that changing bitrate in the mobile app will briefly reset the bitrate for the RTSP stream.
* 05-14-22:  Update v4l2rtspserver, tinyalsa, alsa-lib.  Patch busybox for older official FW's failing to run scripts, fix choppy/static audio in libcallback
* 05-09-22:  fix bug in run_mmc.sh that did not store the wlan mac when using a wired usb or ethernet connection for the rtsp server
* 05-09-22:  update libcallback sources with patch to fix rtsp across multiple firmware versions for all devices (v3/panv2/db)
* 05-08-22:  update libcallback sources with patch to enable pan v2 rtsp functionality.
* 05-08-22:  Include iptables and NFSv4 kernel modules, enable swap ON by default.
* 05-07-22:  RTSP Server fixed, ported latest full libcallback from @mnakada with modifications.
* 05-01-22:  Removed dropbearmulti, replaced with individual binaries.  dropbear dbclient dropbearkey dropbearconvert scp now included.
* 04-30-22:  Recompiled uClibc with LD_DEBUG enabled. Enable in v3_post.sh, for debugging.
* 04-30-22:  Move built-in kernel stuff to modules, usb_direct kernel no longer needed, modules now included. Added usb-storage support for usb hdd/ssd/flash drive, cifs support, and rndis support for tethering camera directly to a mobile device.
* 04-26-22:  Add customization of PATH  via hook in v3_init.sh, and add audioplay_t31 binary for playing audio files before iCamera loads.
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
* 04-05-22:  Update readme to indicate that telnet mod nor DNS spoofing is required for installation, and add pre-requisites section.
* 04-02-22:  Update to automatic install method, remove manual install.

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
