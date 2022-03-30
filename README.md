# wz_mini_hacks

Run the latest stable firmware on your v3 cam and have root access to the device.  This is in early stages of testing, use CAUTION if you are unsure of what you are doing.  No support whatsoever is offered with this release.

## Features

* Modifies /dev/mtd2, changes the unknown root password to WYom2020, adds a hook to /etc/init.d/rcS to run a script ( /media/mmc/run_mmc.sh ) from the micro sd card 30 seconds after the camera has booted successfully.  
* Flashes the latest firmware during installation ( 4.36.8.32, as of this writing )
* Enables SSH, telnet will be disabled after installation.
* Add your own changes to run at boot into the script on the micro sd card located at /media/mmc/run_mmc.sh, mount nfs, run ping, whatever you want.
* Ability to update to the latest stable or beta firmware, this mod should survive updates ( as long as the firmware update does not change /dev/mtd2. Future versions of this mod may block updates if desired )
* Inspired by HclX and WyzeHacks, borrowed busybox and dropbearmulti from his v2 repo.  Bless you for all your work!



## Setup

1. Flash your v3 to 4.36.0.280, then use wyze hacks to get telnet running on your device.
2. git clone the repo, then run ./setup.sh compile to generate the files to be copied to your SD card
3. copy all the files inside of SD_ROOT to your micro sd card, then put the card in your v3.
4. telnet to your device, then cd to /media/mmc
5. run ./wz_mini_installer.sh, this will flash the modified partitions and enable ssh.
6. The camera will reboot, then connect via the IP address of your device using SSH, port 22.  username is root password is WYom2020.

On PC:
```bash
./setup.sh compile
```
On Device:
```bash
cd /media/mmc
./wz_mini_installer.sh
```

## WARNING
```
AS WITH ANY UNSUPPORTED SYSTEM MODIFICATIONS, USING THIS MAY LEAD TO A DEVICE BRICK
IF YOU DON'T KNOW WHAT YOU ARE DOING ( HAVEN'T BRICKED MY DEVICE YET! ) PLEASE
BE AWARE THAT NO ONE ON THE INTERNET IS RESPONSIBLE FOR ANY DAMAGE TO YOUR
UNIT. ANY PROBLEMS WILL BE CONSIDERED USER ERROR OR ACTS OF WHATEVER GOD YOU BELIEVE IN.
DO NOT USE THIS SOFTWARE IF YOU ARE NOT CONFIDENT IN RESTORING YOUR DEVICE FROM A FAILED STATE.
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

