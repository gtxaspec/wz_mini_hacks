# wz_mini_hacks

Run the latest firmware on your v3 cam and have root on the device.  this is in early stages of testing, use CAUTION if you are unsure of what you are doing.  No support whatsoever is offered with this release.

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
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

