# wz_mini_hacks
### v3 devices ONLY

Run the latest stable ( 4.36.8.32 ) firmware on your v3 cam and have root access to the device.  This is in early stages of testing, use CAUTION if you are unsure of what you are doing.  No support whatsoever is offered with this release.

## Features

* Modifies /dev/mtd2, changes the unknown root password to WYom2020, adds a hook to /etc/init.d/rcS to run a script ( /media/mmc/run_mmc.sh ) from the micro sd card 30 seconds after the camera has booted successfully.  
* Flashes the latest firmware during installation ( 4.36.8.32, as of this writing )
* Enables SSH, telnet will be disabled after installation.
* Add your own changes to run at boot into the script on the micro sd card located at /media/mmc/run_mmc.sh, mount nfs, run ping, whatever you want.
* Ability to update to the latest stable or beta firmware, this mod should survive updates ( as long as the firmware update does not change /dev/mtd2.
* Ability to block remote AND app initiated firmware updates.
* An Internet connection is required to download and patch the files required for this to work.
* Inspired by HclX and WyzeHacks, borrowed busybox and dropbearmulti from his v2 repo.  Bless you for all your work!  You are the master!
* Works on ANY ( tested up to 4.36.8.32 ) v3 firmware relase
* *NEW* Automated installer, put files on the micro sd card and wait for the unit to reboot.



## Setup

1. git clone the repo, then run ./setup.sh compile to generate the files to be copied to your SD card
2. copy all the files inside of SD_ROOT to your micro sd card

On PC:
```bash
./setup.sh compile
```
To disable automatic firmware updates, edit run_mmc.sh on your micro sd card, un-comment the lines following:
```bash
#echo "Disable remote firmware upgrade, uncomment lines below to enable"
```

If a remote or app update is initiated, the camera will reboot due to the failure of the update.  The firmware update should not proceed again for some time, or at all again.

## Installation
1. Insert the micro sd memory card into the v3 camera
2. The installation will begin when the front led light blinks slowly between red and blue.
3. The installation will complete when the front led light blinks rapidly red and blue.
4. The camera will reboot, then you may connect via the IP address of your device using SSH, port 22.  username is root password is WYom2020.  It may take a few minutes for the device to finish booting and connect to wifi, then launch the SSH server.  Be patient.
## Customization

Edit run_mmc.sh, this is a script stored on the micro sd card that is run when the camera boots.  You can change the hostname of the camera, mount NFS, add ping commands, anything you like.


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
Thank you to everyone who is passionate about Wyze products for making the devices popular, and thank you to Wyze for producing them.  Sign up for CamPlus, show some love to the company.

Thanks for HclX for WyzeHacks!
Thank you bakueikozo for his atomcam_tools repo! https://github.com/bakueikozo/atomcam_tools
Thank you to virmaior for the atomcam_tools info!
