If a remote or app update is initiated, the camera will reboot due to the failure of the update. The firmware update should not proceed again for some time, or at all.

When a firmware update is initiated, due to a bootloader issue (bug?), we intercept the update process and flash it manually. This should now result in a successful update, if it doesn't, please restore the unit's firmware manually using demo_wcv3.bin on the micro sd card.

