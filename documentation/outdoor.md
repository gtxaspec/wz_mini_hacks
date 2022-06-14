## boot log:

```
Ver:20201017-Turret
od_cam Build:Mar 15 2022 05:01:34
----====>>>> come into od_cam:555(ms)
sensor name:gc2063
ERROR: serch the USER token failed!
ERROR: serch the USER token failed!
ERROR: serch the USER token failed!
!! The specified ScalingList is not allowed; it will be adjusted!!
!! The specified ScalingList is not allowed; it will be adjusted!!
[frame_pooling_thread--400 Channel:0 ]:585(ms)
[frame_pooling_thread--400 Channel:1 ]:683(ms)
----====>>>> first video frame time:697(ms)
[IMP_Encoder_GetStream--2150 Channel:0 ]:697(ms)
----====>>>> first video sub frame time:847(ms)
[IMP_Encoder_GetStream--2150 Channel:1 ]:847(ms)
open /sys/class/gpio/gpio60/direction error !
open /sys/class/gpio/gpio49/direction error !
----====>>>> first audio frame time:863(ms)
IVS Version:1.0.5 built: Sep  3 2020 14:15:52
ERROR: serch the WIFI token failed!
wakeupFlag : 0
cam_ev_init error:-1
ERROR: serch the USER token failed!
grid_info is not exist!
gridTempArray =ffff
gridTempArray =ffff
gridTempArray =ffff
gridTempArray =ffff
gridTempArray =ffff
gridTempArray =ffff
gridTempArray =ffff
gridTempArray =ffff
gridTempArray =ffff
gridTempFirstLine = 0
gridTempLastLine = 8
gridTempFirstRow = 0
gridTempLastRow = 15
binaryTempright = 0
binaryTempleft = 15
ZRT_POWER_WIFI:ZRT_Get_WIFI_Config error
ZRT_POWER_WIFI:ZRT_HL_Dual_Bind_TCP_sync Start
ZRT_CAM_DAEMON:[DUAL] TCP socket erro
>>>>>>>>>>>BATTERY_USAGE_EVENT_DROP old: 0, start: 1
Setting up swapspace version 1, size = 16773120 bytes
UUID=0df0afb8-3a67-464e-975b-e2a77add239c
write /sys/class/gpio/export error: Device or resource busy
z_cmd_disable_wdt()
CMD: head=c309, index=4012, index_n=bfed, end=55aa
resp:OK

WCO_V2 login: Not This File: /config/profiles/.reconnect.conf
Stream Cipher init time: 4703
[IMP_Encoder_GetStream--2150 Channel:2 ]:5064(ms)
Stream Cipher init success
check_pir: 0
check_time: 1
check_repower: 1
pir_sensitive: 128
mov_sensitive: 128
file_size_avg: 0KB trans_rate_avg: 0KB/S
alarm resolusion: 1080P
----====>>>> get first pir value:5108(ms)
Alarm analysis, moved frame num: 1, threshold num: 7
Alarm analysis not pass!
paracfg user has not inited
od_cam init done.
MCU Event Flag: 0 -> 0
firmware_version:4.48.4.124
hardware_version:0.0.0.2
hardware_ver2:D03F272EB7C9D03F272EB7C9F00A0000
[Real-time alarm] alarm start, get_alarm_video_flag: 0
Sleeping may corrupt here, So add log
_lostBeaconCount_statistics();
_lostBeaconCount_statistics quit
************* camera task: 0 -> 0 *************
notifyWyzeFlag = 0
go_sleep_immediately
mv: can't rename '/tmp/mnt/sdcard/Wyze_camera_log/wyze_camera_2*': No such file or directory
come into mcu check...
mcu version is right
[Real-time alarm] lower: 997, pir_min: 126, pir_max: 132, upper: 3098
[Real-time alarm] moved frame num: 57, threshold num: 7
[Real-time alarm] pir & moved filter pass, start alarm.
cond signa; done
[Real-time alarm]sleeping;quit
[pir_log] pir_up : 0  |  pir_max : 133  |  pir_min : 126 
alarm file(/tmp/alarm.info) is not find
alarm file(/tmp/alarm.info) is not find
sleep,wifi hasn't keep alive
export T31_FORCE_POWER gpio59
killall: zrt_app: no process killed
rmmod: remove 'bcmdhd': No such file or directory
killall: cat: no process killed
killall: logcat: no process killed
```


## update rootfs:

```
[sd_update.sh] ROOTFS updateing...
[sd_state_wait.sh] sd_update.sh is running, exit
SystemCall_Dbus_ReadWrite_Thread 520 read socket data failed exit this thread, ret:0 errno:0 (Success)
SystemCall_Dbus_ReadWrite_Thread 521 maybe client is close
[sd_update.sh] copy failed
rmmod: remove 'cywdhd': Device or resource busy
umount: proc busy - remounted read-only
Sent SIGTERM to all processesr
Sent SIGKILL to all processes
Requesting system reboot
[   27.797603] Restarting system.


U-Boot 2013.07 (Nov 14 2021 - 09:40:06)

Board: ISVP (Ingenic XBurst T31 SoC)
DRAM:  128 MiB
Top of RAM usable for U-Boot at: 84000000
Reserving 441k for U-Boot at: 83f90000
Reserving 32776k for malloc() at: 81f8e000
Reserving 32 Bytes for Board Info at: 81f8dfe0
Reserving 124 Bytes for Global Data at: 81f8df64
Reserving 128k for boot params() at: 81f6df64
Stack Pointer at: 81f6df48
Now running in RAM - U-Boot at: 83f90000
MMC:   msc: 0
the manufacturer c8
SF: Detected GD25Q128

*** Warning - bad CRC, using default environment

In:    serial
Out:   serial
Err:   serial
Net:   ====>PHY not found!Jz4775-9161
Hit any key to stop autoboot:  0 
the manufacturer c8
SF: Detected GD25Q128

--->probe spend 4 ms
SF: 2785280 bytes @ 0xa98000 Read: OK
--->read spend 894 ms
Wrong Image Format for bootm command
ERROR: can't get kernel image!
isvp_t31# 
```

kernel command line:

`console=ttyS1,115200n8 mem=80M@0x0 rmem=48M@0x5000000 root=/dev/ram0 rw rdinit=/linuxrc mtdparts=jz_sfc:256K(boot),352K(tag),5M(kernel),5M(rootfs),2720K(recovery),2304K(system),512k(config),16M@0(all) lpj=6955008 quiet`
