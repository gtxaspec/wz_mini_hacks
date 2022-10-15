# wz_mini_hacks
### v2/car/PANv1/v3/PANv2 devices ONLY

Run whatever firmware you want on your v2/car/PANv1/v3/PANv2 and have root access to the device.  This is in early stages of testing, use CAUTION if you are unsure of what you are doing.  No support whatsoever is offered with this release.  

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
* Works on ANY firmware release up to 4.36.9.139 (DO NOT UPGRADE BEYOND THIS FW IF YOU WANT RTSP or any `cmd` FEATURES!)
  * Compatability is not guaranteed with really old firmware versions!
  * Update to the latest stable or beta firmware, this mod should still work!
  * Block remote or app initiated firmware updates
  * DNS Spoofing or Telnet mod are *not* required prior to installation
* Wireguard and IPv6 support enabled
* Supports the following USB Ethernet adapters: 
  * ASIX AX88xxx Based USB 2.0 Ethernet Adapters
  * ASIX AX88179/178A USB 3.0/2.0 to Gigabit Ethernet
  * Realtek RTL8152 Based USB 2.0 Ethernet Adapters
  * CDC-Ether Based Adapters
* USB gadget support, connect the camera directly to a supported router to get an internet connection, no USB Ethernet Adapter required, using USB CDC_NCM.
* Custom script support included
* RTSP Server included, stream video and or audio over LAN
* Tether your camera directly to android phones using USB via RNDIS support
* USB Mass storage enabled, mount USB SSD/HDD/flash drives
* CIFS Supported
* iptables included
* Play .wav audio files using "cmd aplay \<path-to-file\> \<vol\>" command.  Supported .wav files may be generated using ffmpeg as well::
 ```
 ffmpeg -i in.wav -acodec pcm_s16le -ac 1 -ar 16000 out.wav
 ```
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

## Setup v2/PanV1

1. git clone the repo or download the repo zip
2. perform a fresh format on your micro-sd card, using fat-32 ( this is a hard requirement, the bootloader does not support ex-fat or ext, and thus will not load wz_mini ), DOS partition map type, volume name does not matter.
3. Run `compile_image.sh` using linux, wait for the script to finish.
   - PANv1: Run `compile_image.sh pan` using linux, wait for the script to finish.
4. Copy all the files inside of SD_ROOT to your micro sd card
5. Copy the generated `demo.bin` to root of your micro sd card
6. __SSH is enabled, but is secured using public key authentication for security.  Edit the file ```wz_mini/etc/ssh/authorized_keys``` and enter your public key here.  If you need a simple guide, [how to use public key authentication](https://averagelinuxuser.com/how-to-use-public-key-authentication/)__

## Installation v2/PanV1

1. Insert the micro sd memory card into the camera
2. Hold down reset button while powering unit on.  This is the standard manual firmware restore procedure.
3. Wait for camera to flash the latest modified firmware, and reboot, do not remove the micro sd card.
4. The camera will proceed to boot, then you may connect via the IP address of your device using SSH, port 22.  The username is root.  It may take a few minutes for the device to finish booting and connect to Wi-Fi, then launch the SSH server.  **Be patient.**  *You should hear audio prompts from the camera once it has booted successfully.*
5. If you have a car, you will now need to convert the camera to the car firmware.  Use the car app to do this.  After the conversion is complete, wz_mini remains active.
5. You may also login via the serial console, password is WYom2020

## Removal
1.  Delete the files you copied to the memory card, or remove the memory card all together.  The next time you boot the camera, you will return to stock firmware.

## Customization

Edit `wz_mini.conf`, this is stored on the micro sd card inside the wz_mini folder, and loads the configuration variables when the camera boots.  You can change the hostname of the camera, add a path to a script to mount NFS, add ping commands, anything you like.

---

### Wireguard:
*Support is available as a kernel module*

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

### Disable automatic firmware updates:

```
DISABLE_FW_UPGRADE="true"
```

If a remote or app update is initiated, the camera will reboot due to the failure of the update.  The firmware update should not proceed again for some time, or at all.  

When a firmware update is initiated, due to a bootloader issue (bug?), we intercept the update process and flash it manually.  This should now result in a successful update, if it doesn't, please restore the unit's firmware manually using demo_wcv3.bin on the micro sd card.

---

### USB Ethernet Adapter:

```
ENABLE_USB_ETH="true"
ENABLE_USB_ETH_MODULE_AUTODETECT="true"
ENABLE_USB_ETH_MODULE_MANUAL=""
```

To have the Ethernet NIC be auto-detected and loaded automatically, set the ENABLE_USB_ETH_MODULE_AUTODETECT value to true.

To load a specific USB Ethernet NIC driver, set ENABLE_USB_ETH_MODULE_MANUAL to one of the following:
asix, ax88179_178a, cdc_ether, r8152

**NOTE:** There is a possibility of a conflict between Ethernet NIC adapters that report themselves as PCI ID '0bda:8152'.  (Realtek 8152 and CDC Ethernet)
Since the 8152 is Realtek's product, that driver will be the one used for products that report that PCI ID.
If you happen to have a CDC Ethernet product that uses that specific PCI ID, please set `ENABLE_USB_ETH_MODULE_AUTODETECT="false"` and set `ENABLE_USB_ETH_MODULE_MANUAL="cdc_ether"`

The next time you boot your camera, make sure your USB Ethernet Adapter is connected to the camera and ethernet.  Note that using USB Ethernet disables the onboard Wi-Fi.

---

### Network Interface Bonding:

```
BONDING_ENABLED="false"
BONDING_PRIMARY_INTERFACE="eth0"
BONDING_SECONDARY_INTERFACE="wlan0"
BONDING_LINK_MONITORING_FREQ_MS="100"
BONDING_DOWN_DELAY_MS="5000"
BONDING_UP_DELAY_MS="5000"
```

Bonding description is best described here:
https://wiki.debian.org/Bonding#Configuration_-_Example_2_.28.22Laptop-Mode.22.29:

("Laptop-Mode")

Tie cable and wireless network interfaces (RJ45/WLAN) together to define a single, virtual (i.e. bonding) network interface (e.g. bond0).
As long as the network cable is connected, its interface (e.g. eth0) is used for the network traffic. If you pull the RJ45-plug, ifenslave switches over to the wireless interface (e.g. wlan0) transparently, without any loss of network packages.
After reconnecting the network cable, ifenslave switches back to eth0 ("failover mode").
From the outside (=network) view it doesn't matter which interface is active. The bonding device presents its own software-defined (i.e. virtual) MAC address, different from the hardware defined MACs of eth0 or wlan0.
The dhcp server will use this MAC to assign an ip address to the bond0 device. So the computer has one unique ip address under which it can be identified. Without bonding each interface would have its own ip address. 
Currenly supported with ethernet adapters and usb-direct mode.

**BONDING_PRIMARY_INTERFACE**
Specifies the interface that should be the primary.  Typically "eth0".

**BONDING_SECONDARY_INTERFACE**
Specifies the interface that should be the secondary.  Typically "wlan0".

**BONDING_LINK_MONITORING_FREQ_MS**
Specifies the MII link monitoring frequency in milliseconds. This determines how often the link state of each slave is inspected for link failures.

**BONDING_DOWN_DELAY_MS**
Specifies the time, in milliseconds, to wait before disabling a slave after a link failure has been detected. This option is only valid for the miimon link monitor. The downdelay value should be a multiple of the miimon value; if not, it will be rounded down to the nearest multiple.

**BONDING_UP_DELAY_MS**
Specifies the time, in milliseconds, to wait before enabling a slave after a link recovery has been detected. This option is only valid for the miimon link monitor. The updelay value should be a multiple of the miimon value; if not, it will be rounded down to the nearest multiple.

---

### USB Direct:

```
ENABLE_USB_DIRECT="true"
```

the next time you boot your camera, make sure your USB cable is connected to the router.  Note that using USB Direct disables the onboard Wi-Fi.  Change the MAC Address if you desire via USB_DIRECT_MAC_ADDR variable.

Connectivity is supported using a direct USB connection only... this means a single cable from the camera, to a supported host (An OpenWRT router, for example) that supports the usb-cdc-ncm specification. (NCM, not ECM) If you have an OpenWrt based router, install the ```kmod-usb-net-cdc-ncm``` package.  The camera should automatically pull the IP from the router with most configurations.  You can also use any modern linux distro to provide internet to the camera, provided it supports CDC_NCM.  enjoy!

Note: In my testing, the micro-usb cables included with the various cameras do not pass data, so they will not work.  Make sure you have a micro-usb cable that passes data!

---

### Remote Accessories:

When USB Direct connectivity is enabled, the camera will be unable to communicate with accessories.  To enable remote usb accessory support, enable the following variable and set the IP Address of the host as follows:

Scenario:  Spotlight accessory needs to be located away from the camera, yet we desire spotlight control from within the app and camera.  Plug the Spotlight into the nearby router running linux.  Configure variables as below on camera, and run socat on the router.  The app will now detect the spotlight accessory, just as if it was plugged in to the camera directly!


```
REMOTE_SPOTLIGHT="true"
REMOTE_SPOTLIGHT_HOST="0.0.0.0"
```

Then, run the following command on the host where the spotlight is attached to:

```
socat TCP4-LISTEN:9000,reuseaddr,fork /dev/ttyUSB0,raw,echo=0
```

Change ```/dev/ttyUSB0``` to whatever path your accessory enumerated to if necessary.  The camera will now be able to control the usb accessory.

---

### USB Mass Storage Support:

```
ENABLE_USB_STORAGE="true"
```
**If you would like to mount an EXT3/4 filesystem** make sure to enable ext4 support:

```
ENABLE_EXT4="true"
```

---

**CIFS is now supported**.

```
ENABLE_CIFS="true"
```

---

### iptables:
*ipv4 and ipv6 available*

```
ENABLE_IPTABLES="true"
```

---

### NFSv4

```
ENABLE_NFSv4="true"
```

---

### RTSP streaming:
The RTSP server supports up to two video streams provided by the camera, 1080p/360p (1296p/480p for the DB3 [DoorBell3]).  You can choose to enable a single stream of your choice (HI or LOW), or both.  Audio is also available.  If you do not have `RTSP_AUTH_DISABLE="true"` **MAKE SURE TO SET** your login credentials!
#### NOTES
- `ENC_PARAMETER` accepts numbers only.  0=FIXQP, 1=CBR, 2=VBR, 4=CAPPED VBR, 8=CAPPED QUALITY.  **Currently only 2, 4, and 8 are working**
- V2 and V3 endpoints are not the same!

```
RTSP_LOGIN="admin"
RTSP_PASSWORD=""
RTSP_PORT="8554"

RTSP_HI_RES_ENABLED="true"
RTSP_HI_RES_ENABLE_AUDIO="true"
RTSP_HI_RES_MAX_BITRATE="2048"
RTSP_HI_RES_TARGET_BITRATE="1024"
RTSP_HI_RES_ENC_PARAMETER="2"
RTSP_HI_RES_FPS=""

RTSP_LOW_RES_ENABLED="false"
RTSP_LOW_RES_ENABLE_AUDIO="false"
RTSP_LOW_RES_MAX_BITRATE=""
RTSP_LOW_RES_TARGET_BITRATE=""
RTSP_LOW_RES_ENC_PARAMETER=""
RTSP_LOW_RES_FPS=""

RTSP_AUTH_DISABLE="false"

```

#### Single Stream
the singular stream will be located at ```rtsp://login:password@IP_ADDRESS:8554/unicast```

#### Multiple Streams
multiple streams are located at 

- **V3** - ```rtsp://login:password@IP_ADDRESS:8554/video1_unicast``` and ```rtsp://login:password@IP_ADDRESS:8554/video2_unicast```
- **V2** - ```rtsp://login:password@IP_ADDRESS:8554/video6_unicast``` and ```rtsp://login:password@IP_ADDRESS:8554/video7_unicast```


You may disable authentication by setting `RTSP_AUTH_DISABLE="true"`

Setting the FPS is not required unless you want to change the default device settings (20 day/15 night FPS for V3, 15 day/10 night FPS for V2).

Note:  If you don't set the password, the password will be set to the unique MAC address of the camera, in all uppercase, including the colons... for example:. AA:BB:CC:00:11:22.  It's typically printed on the camera.  Higher video bitrates may overload your Wi-Fi connection, so a wired connection is recommended.

Huge credit to @mnakada for his libcallback library: [https://github.com/mnakada/atomcam_tools](https://github.com/mnakada/atomcam_tools)

---

### mp4_write:

```
ENABLE_MP4_WRITE="true"
```

Forces the camera to skip writing files to /tmp, and write them directly to your storage medium or network mount, prevents trashing.  Normally videos are written to /tmp then moved using `mv`, which can overload camera and or remote network connections. Useful for NFS/CIFS remote video storage.

---

### USB Video Class (UVC) Web Camera
Use as a WebCam for your PC is supported.  I have tested with Windows 10, Linux, and Android TV, and it appears as a Generic HD Camera.  Audio is supported.  This mode disables all other functionality, and only works as a USB Web Camera for your PC.  Experimental.  Note that the cables typically included with the camera do not data, use a known working micro-usb cable which supports data.

Supported modes: MJPG,Video 360p/720p/1080p

```
WEB_CAM_ENABLE="true"
WEB_CAM_BIT_RATE="8000"
WEB_CAM_FPS_RATE="25"
```

---

### Run a custom script:

```
CUSTOM_SCRIPT_PATH=""
```

**Note:** any executable files placed in `wz_mini/etc/rc.local.d` will be automatically run at boot time, irregardless of the custom script variable specified in the configuration.

---

### RTMP Streaming:

```
RTMP_STREAM_ENABLED="true"
RTMP_STREAM_FEED="video1_unicast"
RTMP_STREAM_SERVICE="youtube"
RTMP_STREAM_DISABLE_AUDIO="false"
RTMP_STREAM_YOUTUBE_KEY="xxx-xxx-xxx-xxx"
RTMP_STREAM_TWITCH_KEY=""
RTMP_STREAM_FACEBOOK_KEY=""
```

Live stream DIRECTLY from the camera's local RTSP server to: `youtube` / `twitch` / `facebook` live.  Audio must be enabled in the RTSP section of the configuration for this to work.  

---

### IMP_CONTROL:
**Only available when RTSP server is enabled, values are reset to default upon reboot.**
Tune various audio and video parameters supported by IMP.

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

### Upgrade wz_mini over the air:

`upgrade-run.sh`

This script will upgrade wz_mini over the air.  It will backup `wz_mini.conf`, any files stored in `wz_mini/etc/configs`, ssh keys, and wireguard configs.  It will download the latest master version, extract it, reboot into upgrade mode, perform the upgrade, then reboot to the updated system.

If there are any line differences between the old `wz_mini.conf` and the new release, the script will preserve the current config in place.  Note that this means any missing or additional lines.  It is recommended to download the latest wz_mini.conf from github, if there are any major changes to the file, copy the new one to your system first, set your parameteres, save the file, then perform the upgrade.

**NOTE:** if you are upgrading a V2 camera from a release older than 06-16-22, you must manually download the upgrade-run.sh script from this repo and place it in `wz_mini/bin/upgrade-run.sh`, then run it from there !

---

### FPS Drop during NightVision:
```
NIGHT_DROP_DISABLE="true"
```

Stop the camera from dropping the frame rate during nightvision.

---

### WiFi Drivers (ADVANCED!!!):
 **Disable only if you know what you are doing.**
 
```
ENABLE_RTL8189FS_DRIVER="true"
ENABLE_ATBM603X_DRIVER="true"
```

**Enabled by default.**  These options control the WiFi Drivers.  V2/V3 use the 8189fs.ko driver, and certain v3 models and all currently shipping pan v2 models use the atbm603x driver.  These are required for operation of wz_mini, and disabling these will lead to a system crash, due to an updated kernel.  This change was required to support full iptables and connection tracking operation, since they are not supported on the really outdated factory drivers.  My testing shows better stability and performance.

---
### Disable Motor Controls:
```
DISABLE_MOTOR="true"
```

Disable the movement capability on motorized devices.  You will no longer be able to move the device from the mobile app, or command line.  Best used to convert a motorized unit to fixed

---

### File System Check/Repair:
```
ENABLE_FSCK_ON_BOOT="true"
```

run fsck.vfat on boot.  This runs fsck.vfat, the FAT disk repair utility on the micro sd card, automatically repairing most issues, including corruption.  Increases boot time.  During the repair process, the LEDs on the camera will flash RED-off-BLUE-off-PURPLE-off to inform the user the repair program is running.  Once the program has completed, the LED will switch to RED, resuming the normal boot process.

---

### Car Driver:
```
ENABLE_CAR_DRIVER="true"
```

Loads the appropriate driver for the car to function.  On devices other than a V2 with the car firmware, the car may be controlled via `car_control.sh` on the command line.  experimental!

`car_control.sh` defaults to high speed
`car_control.sh low_speed` low speed
`car_control constant` direction is constant, car keeps moving the direction you select without holding down any keys.
`car_control.sh constant low_speed` like above, but in low speed

---

### Local DNS resolver
 *May fix DNS Flooding*
```
ENABLE_LOCAL_DNS="true"
```

Enables `dnsmasq`, a lightweight, local, caching DNS server on the camera.  Fixes potential DNS flooding on the local network.  Upstream DNS servers may be specified in `wz_mini/etc/resolv.dnsmasq`

---
### Web Server:
```
WEB_SERVER_ENABLED="true"
```

Enables the local webserver, for configuration, car control, or to retreive an image snapshot via a web browser.  Available at : `http://<Camera IP>/`  Thank you @virmaior!

---

 ### SYSLOG:
```
ENABLE_SYSLOG_SAVE="true"
```

Save the syslog to the `logs/` directory

---
### Cron
```
ENABLE_CRONTAB="true"
```

Enable crontab.  Located at `wz_mini/etc/cron/root`

---
### Self-Hosted / Isolated Mode
```
ENABLE_SELFHOSTED_MODE="true"
```

When enabled, the `iCamera` program will be patched to work nicely in a self-hosted environment. This can be reverted by setting the value to `false` and rebooting. Intended for advanced users only! Do not enable if you use the Wyze App. Disabled by default.

Normally, the firmware will restart the network interface periodically when it is unable to reach Wyze's servers which results in intermittent network drops. For advanced users that intend to run the Wyze Cam without internet access or on a controlled network, this option will patch the `iCamera` process to function without the Wyze servers.

Feature supported on:
* Wyze Cam v3 firmware: 4.36.9.139, 4.61.0.1
* Wyze Cam v2 firmware: 4.9.8.1002

---

## Latest Updates

* 09-27-22:  Add self_hosted iCamera patch by @kohrar, fix config backup script, add ntp client on boot.
* 08-07-22:  Updated init.d scripts.  Added syslog save feature.  Fixed orientation issue on T31 devices in webcam mode.  Added crontab support.
* 07-25-22:  Add dnsmasq local dns option in configuration to prevent dns flooding on local networks.  Added web server capability for configuration and car control.
* 07-14-22:  Add car compatability with normally unsupported devices.
* 07-13-22:  Includes latest build of libcallback, better RTSP video and audio performance: fixed broken audio caused by motor_stop on T20 devices, fixed waitMotion errors. `cmd jpeg` currently still broken on T20 devices,  updated scripts to account for changed.  Some usage of `cmd` has changes, please see command output.  Kernel & modules updated to prepare for H265 support on T31.
* 07-08-22:  Added support for multiple custom scripts, simply create scripts ending in .sh in wz_mini/etc/rc.local.d. You can prefix them with numbers to order execution if desired.
* 07-08-22:  Updated T31 Kernel & Modules, added cp210x serial kernel module to support car.  Add motor disable, fsck on boot. Disable debug logging for wifi drivers to prevent log spam, improved method of setting imp variables, fixed soundcard issues in the kernel, revert libcallback to account for this change.
* 06-24-22:  BIG UPGRADE!  Updated & improved WiFi Drivers - 8189fs and 6032i - Drivers work across all supported camera models.  This update requires you to copy over a new wz_mini.conf before upgrading!  Drivers required for operation, do not disable!  Updated upgrade-run.sh script to prevent broken boot during a rare corrupted file situation.  Added connection bonding, for network fail-over support.  
* 06-19-22:  Fixed no rtsp video when wz_mini is used with the old stock rtsp firmware.
* 06-18-22:  Added night drop feature preventing fps drop during nightvision.  Upgrade script can now work unattended.  Add -F0 flag to rtsp server.
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
