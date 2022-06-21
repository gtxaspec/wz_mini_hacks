# Recycle Wyze v3 w/ broken WIFI
## Overview
This works around the problem described [here](https://www.reddit.com/r/wyzecam/comments/tqmm0h/deeper_dive_results_on_the_wyze_cam_v3_failures/) with the RTL8189 dieing in WyzeCams.  

## Prerequisites
* Person
* Cat
* Broken previously working WyzeCam 
* USB network supported by wz_mini_hacks (ethernet, gadget, RNDIS)

## Setup
1.  Follow instructions in README.md - configure one of the three network solutions ... I used gadget (ENABLE_USB_DIRECT) with a Raspberry Pi3.
1.  In wz_mini.conf set ENABLE_WZ_RECYCLE to true and set WZ_RECYCLE_MAC to the MAC address printed on the bottom of the camera
1.  Even if the camera has been reset, you should be able to re-setup with App now.

## Notes
*  I setup systemd bridge networking on the RaspberryPi - I already had [bridged wifi hotsport](https://www.raspberrypi.com/documentation/computers/configuration.html?msclkid=d9f409d1cf1211ec86ca2bcfa20cf79f#setting-up-a-bridged-wireless-access-point) setup and just added usb0 to the bridge similar to how ethernet already was as described in the instructions.
