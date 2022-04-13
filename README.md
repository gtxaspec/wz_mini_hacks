# wz_mini_hacks
### v3 devices ONLY

Run the latest stable ( 4.36.8.32 ) firmware on your v3 cam and have root access to the device.  This is in early stages of testing, use CAUTION if you are unsure of what you are doing.  No support whatsoever is offered with this release.  
**Do not contact the manufacturer for information or support, they will not be able to assist you!**

### Related Projects:
* wz_mini_debian: run full debian in a chroot, on the v3!
* wz_mini_utils: various statically compiled binaries for use with the v3 (mipsel)


## Features

* No modification is done to the system. **_Zero!_**
* Custom kernel loads all required files from micro-sd card
* Easy uninstall, just remove files from micro-sd card, or don't use a micro-sd card at all!
* Add your own changes to run at boot into the script on the micro sd card located at /media/mmc/run_mmc.sh, mount nfs, run ping, whatever you want
* Ability to update to the latest stable or beta firmware, this mod should survive updates as long as the bootloader remains the same
* Ability to block remote AND app initiated firmware updates
* Works on ANY ( tested up to 4.36.8.32, even RTSP ) v3 firmware release
* DNS Spoofing or Telnet mod are *not* required prior to installation
* *NEW* Automated installer, put files on the micro sd card and wait for the unit to reboot
* PAN v2 Support coming soon
* Inspired by HclX and WyzeHacks, borrowed busybox and dropbearmulti from his v2 repo.  Bless you for all your work!  You are the master!

## Prerequisites

* Person
* Computer
* Micro-SD Card is required!

## Setup

1. git clone the repo or download the repo zip
2. copy all the files inside of SD_ROOT to your micro sd card

## Installation
1. Turn off the v3 camera
2. Insert the micro sd memory card into the v3 camera
3. Turn on the v3 camera
4. The camera will boot, then you may connect via the IP address of your device using SSH, port 22.  username is root password is WYom2020.  It may take a few minutes for the device to finish booting and connect to wifi, then launch the SSH server.  Be patient.

## Removal
1.  Delete the files you copied to the memory card.  The next time you boot the camera, you will return to stock firmware.

## Customization

Edit run_mmc.sh, this is a script stored on the micro sd card that is run when the camera boots.  You can change the hostname of the camera, mount NFS, add ping commands, anything you like.

To disable automatic firmware updates, edit run_mmc.sh on your micro sd card, un-comment the lines following:
```bash
#echo "Disable remote firmware upgrade, uncomment lines below to enable"
```
If a remote or app update is initiated, the camera will reboot due to the failure of the update.  The firmware update should not proceed again for some time, or at all again.

## Latest Updates

* 04-12-22: Updated, custom kernel loads all required items from micro sd card.  System modification no longer needed.
* 04-05-22:  Update readme to indicate that telnet mod nor DNS spoofing is required for installation, and add pre-requisites section.
* 04-02-22:  Update to automatic install method, remove manual install.  

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
