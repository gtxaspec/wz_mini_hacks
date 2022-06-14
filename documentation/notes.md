wz_mini notes for atomcam
---

take a RAW snapshot (v2 only)

`impdbg --save_pic /tmp/output.nv12 --pic_type NV12`

convert to jpg:

`ffmpeg -loglevel quiet -y -f rawvideo -pixel_format nv12 -s 1920x1080 -i /tmp/output.nv12 -vf fps=1 /media/mmc/output.jpg`

---
take a RAW snapshot (v3 only)

`echo saveraw 1 > /proc/jz/isp/isp-w02`

convert to tiff:

download: https://github.com/jdthomas/bayer2rgb

`bayer2rgb --input /tmp/snap0.raw --output=/media/mmc/record/snap0.tiff --width=1920 --height=1080 --bpp=16 --first=RGGB --method=BILINEAR --tiff`

---
libcallback command utility `cmd` :

```
welcome to: cmd <arg>

arg can be:
jpeg (will dump raw jpeg to stdout with http headers, trim first 2 lines to get a jpg image)
video on or off (channel 0)
video on1 or off1 (channel 1)
audio on or off (channel 0)
audio on1 or off1 (channel 1)
move (for pan / swing models)
waitMotion <timeout>
irled on or off
aplay <file path> <volume 1-100>
mp4write on or off
```
---
GPIO: 

v3:

```
gpio_request lable = wifi_enable_gpio gpio = 57
gpio_request lable = yellow_gpio gpio = 38
gpio_request lable = blue_gpio gpio = 39
gpio_request lable = night_gpio gpio = 49
gpio_request lable = 850_light_gpio gpio = 47
gpio_request lable = SPK_able_gpio gpio = 63
gpio_request lable = TF_en_gpio gpio = 50
gpio_request lable = TF_cd_gpio gpio = 59
gpio_request lable = SD_able_gpio gpio = 48
gpio_request lable = wifi_enable_gpio gpio = 57
```
```
May 13 13:22:38 iCamera: [sdk,0205]dbg: Pin(39)  Lvl(1)  Dir(out)
May 13 13:22:38 iCamera: [sdk,0205]dbg: Pin(38)  Lvl(0)  Dir(out)
May 13 13:22:38 iCamera: [sdk,0205]dbg: Pin(52)  Lvl(0)  Dir(out)
May 13 13:22:38 iCamera: [sdk,0205]dbg: Pin(53)  Lvl(0)  Dir(out)
May 13 13:22:38 iCamera: [sdk,0205]dbg: Pin(47)  Lvl(0)  Dir(out)
May 13 13:22:38 iCamera: [sdk,0205]dbg: Pin(51)  Lvl(1)  Dir(in)
May 13 13:22:38 iCamera: [sdk,0205]dbg: Pin(50)  Lvl(0)  Dir(in)
May 13 13:22:38 iCamera: [sdk,0205]dbg: Pin(62)  Lvl(0)  Dir(in)
```

v2:

```
misc_init_r before change the wifi_enable_gpio
gpio_request lable = wifi_enable_gpio gpio = 62
misc_init_r after gpio_request the wifi_enable_gpio ret is 62
misc_init_r after change the wifi_enable_gpio ret is 0
misc_init_r before change the yellow_gpio
gpio_request lable = yellow_gpio gpio = 38
misc_init_r after gpio_request the yellow_gpio ret is 38
misc_init_r after change the yellow_gpio ret is 0
misc_init_r before change the blue_gpio
gpio_request lable = blue_gpio gpio = 39
misc_init_r after gpio_request the blue_gpio ret is 39
misc_init_r after change the blue_gpio ret is 1
gpio_request lable = night_gpio gpio = 81
misc_init_r after gpio_request the night_gpio ret is 81
misc_init_r after change the night_gpio ret is 0
gpio_request lable = night_gpio gpio = 25
misc_init_r after gpio_request the night_gpio ret is 25
misc_init_r after change the night_gpio ret is 0
gpio_request lable = night_gpio gpio = 49
misc_init_r after gpio_request the night_gpio ret is 49
misc_init_r after change the night_gpio ret is 0
gpio_request lable = USB_able_gpio gpio = 47
misc_init_r after gpio_request the USB_able_gpio ret is 47
misc_init_r after change the USB_able_gpio ret is 0
gpio_request lable = TF_able_gpio gpio = 43
misc_init_r after gpio_request the TF_able_gpio ret is 43
misc_init_r after change the TF_able_gpio ret is 1
gpio_request lable = SPK_able_gpio gpio = 63
misc_init_r after gpio_request the SPK_able_gpio ret is 63
misc_init_r after change the SPK_able_gpio ret is 0
gpio_request lable = SD_able_gpio gpio = 48
misc_init_r after gpio_request the SD_able_gpio ret is 48
misc_init_r after change the SD_able_gpio ret is 0
misc_init_r before change the wifi_enable_gpio
gpio_request lable = wifi_enable_gpio gpio = 62
misc_init_r after gpio_request the wifi_enable_gpio ret is 62
misc_init_r after change the wifi_enable_gpio ret is 1
```
```
Feb 20 02:19:27 iCamera: [SDK-GPIO]dbg: Pin(39)  Lvl(1)  Dir(out)
Feb 20 02:19:27 iCamera: [SDK-GPIO]dbg: Pin(38)  Lvl(0)  Dir(out)
Feb 20 02:19:27 iCamera: [SDK-GPIO]dbg: Pin(26)  Lvl(0)  Dir(out)
Feb 20 02:19:27 iCamera: [SDK-GPIO]dbg: Pin(25)  Lvl(0)  Dir(out)
Feb 20 02:19:27 iCamera: [SDK-GPIO]dbg: Pin(47)  Lvl(1)  Dir(out)
Feb 20 02:19:27 iCamera: [SDK-GPIO]dbg: Pin(48)  Lvl(0)  Dir(out)
Feb 20 02:19:27 iCamera: [SDK-GPIO]dbg: Pin(46)  Lvl(1)  Dir(in)
Feb 20 02:19:27 iCamera: [SDK-GPIO]dbg: Pin(43)  Lvl(0)  Dir(in)
```

---

kernel command line:

v3:

`console=ttyS1,115200n8 mem=99M@0x0 rmem=29M@0x6300000 init=/linuxrc rootfstype=squashfs root=/dev/mtdblock2 rw mtdparts=jz_sfc:256K(boot),1984K(kernel),3904K(rootfs),3904K(app),1984K(kback),3904K(aback),384K(cfg),64K(para)`

panv2:

`console=ttyS1,115200n8 mem=96M@0x0 rmem=32M@0x6000000 init=/linuxrc rootfstype=squashfs root=/dev/mtdblock2 rw mtdparts=jz_sfc:256K(boot),1984K(kernel),3904K(rootfs),3904K(app),1984K(kback),3904K(aback),384K(cfg),64K(para)`

v2:

`console=ttyS1,115200n8 mem=104M@0x0 ispmem=8M@0x6800000 rmem=16M@0x7000000 init=/linuxrc rootfstype=squashfs root=/dev/mtdblock2 rw mtdparts=jz_sfc:256k(boot),2048k(kernel),3392k(root),640k(driver),4736k(appfs),2048k(backupk),640k(backupd),2048k(backupa),256k(config),256k(para),-(flag)`

---

v3 accessory:

Spotlight serial:

high brightness:
`echo -ne "\xaa\x55\x43\x05\x16\xff\x07\x02\x63" > /dev/ttyUSB0`

low brightness:
`echo -ne "\xaa\x55\x43\x05\x16\x33\x07\x01\x97" > /dev/ttyUSB0`

off:
`echo -ne "\xaa\x55\x43\x05\x16\x00\x07\x01\x64" > /dev/ttyUSB0`

---

USB 2.0 DWC controller:

v2:
set host mode: 

`devmem 0x10000040 32 0x0b000096`

set device mode: 

`devmem 0x10000040 32 0x0b800096`

`devmem 0x13500000 32 0x001100cc`

`echo connect > /sys/devices/platform/jz-dwc2/dwc2/udc/dwc2/soft_connect`


v3:

set host mode:

`devmem 0x10000040 32 0x0b000096`

set device mode:

`devmem 0x13500000 32 0x001100cc`

`devmem 0x10000040 32 0x0b000FFF`

---
libIMP debug:

`impdbg`
```
usage: impdbg --option [args]
	--enc_info          		get encoder info
	--enc_rc_s chn:offset:size:data		set encoder rc
	--fs_info           		get frame source info
	--save_pic [path]   		save pic data 
	--pic_type [RAW/NV12/YUYV422/UYVY422/RGB565BE]		save pic type
	--system_info       		get system info
```

v3:

`--enc_info`
```
GROUP 0
	CHANNEL 0    1920x 1080     START H264 tf:786        df:3          encdur:39264, encodingFrameCnt:783,endencodeFrameCnt=783,endrelaseFrameCnt=783,Fps:20.01,Bitrate:838.09
-------------------------------------------------
ch->index = 0
ch->releaseFrmNum = 0
ch->releaseFrmDen = 0
chnAttr->encAttr->eProfile = 77(0x4d) offset:size = 0:4
chnAttr->encAttr->uLevel = 41(0x29) offset:size = 4:1
chnAttr->encAttr->uTier = 0(0x0) offset:size = 5:1
chnAttr->encAttr->uWidth = 1920(0x780) offset:size = 6:2
chnAttr->encAttr->uHeight = 1080(0x438) offset:size = 8:2
chnAttr->encAttr->ePicFormat = 392(0x188) offset:size = 12:4
chnAttr->encAttr->eEncOptions = 294952(0x48028) offset:size = 16:4
chnAttr->encAttr->eEncTools = 156(0x9c) offset:size = 20:4
chnAttr->rcAttr->rcMode = 8(0x8) offset:size = 44:4
chnAttr->rcAttr->CappedQuality->uTargetBitRate = 720(0x2d0) offset:size = 48:4
chnAttr->rcAttr->CappedQuality->uMaxBitRate = 960(0x3c0) offset:size = 52:4
chnAttr->rcAttr->CappedQuality->iInitialQP = -1(0xffffffff) offset:size = 56:2
chnAttr->rcAttr->CappedQuality->iMinQP = 23(0x17) offset:size = 58:2
chnAttr->rcAttr->CappedQuality->iMaxQP = 51(0x33) offset:size = 60:2
chnAttr->rcAttr->CappedQuality->iIPDelta = 3(0x3) offset:size = 62:2
chnAttr->rcAttr->CappedQuality->iPBDelta = 3(0x3) offset:size = 64:2
chnAttr->rcAttr->CappedQuality->eRcOptions = 1(0x1) offset:size = 68:4
chnAttr->rcAttr->CappedQuality->uMaxPictureSize = 1920(0x780) offset:size = 72:4
chnAttr->rcAttr->CappedQuality->uMaxPSNR = 48(0x30) offset:size = 76:2
chnAttr->rcAttr->outFrmRate->frmRateNum = 20(0x14) offset:size = 80:4
chnAttr->rcAttr->outFrmRate->frmRateDen = 1(0x1) offset:size = 84:4
chnAttr->gopAttr->uGopCtrlMode = 2(0x2) offset:size = 88:4
chnAttr->gopAttr->uGopLength = 40(0x28) offset:size = 92:2
chnAttr->gopAttr->uNotifyUserLTInter = 0(0x0) offset:size = 94:1
chnAttr->gopAttr->uMaxSameSenceCnt = 1(0x1) offset:size = 96:4
chnAttr->gopAttr->bEnableLT = 0(0x0) offset:size = 100:1
chnAttr->gopAttr->uFreqLT = 0(0x0) offset:size = 104:4
chnAttr->gopAttr->bLTRC = 0(0x0) offset:size = 108:1
	CHANNEL 4    1920x 1080      STOP JPEG tf:0          df:0          encdur:39436, encodingFrameCnt:0,endencodeFrameCnt=0,endrelaseFrameCnt=0,Fps:0.00,Bitrate:0.00
-------------------------------------------------
ch->index = 4
ch->releaseFrmNum = 0
ch->releaseFrmDen = 0
chnAttr->encAttr->eProfile = 67108864(0x4000000) offset:size = 0:4
chnAttr->encAttr->uLevel = 0(0x0) offset:size = 4:1
chnAttr->encAttr->uTier = 0(0x0) offset:size = 5:1
chnAttr->encAttr->uWidth = 1920(0x780) offset:size = 6:2
chnAttr->encAttr->uHeight = 1080(0x438) offset:size = 8:2
chnAttr->encAttr->ePicFormat = 392(0x188) offset:size = 12:4
chnAttr->encAttr->eEncOptions = 294952(0x48028) offset:size = 16:4
chnAttr->encAttr->eEncTools = 156(0x9c) offset:size = 20:4
chnAttr->rcAttr->rcMode = 0(0x0) offset:size = 44:4
chnAttr->rcAttr->FixQP->iInitialQP = 32(0x20) offset:size = 48:2
chnAttr->rcAttr->outFrmRate->frmRateNum = 20(0x14) offset:size = 80:4
chnAttr->rcAttr->outFrmRate->frmRateDen = 1(0x1) offset:size = 84:4
chnAttr->gopAttr->uGopCtrlMode = 2(0x2) offset:size = 88:4
chnAttr->gopAttr->uGopLength = 40(0x28) offset:size = 92:2
chnAttr->gopAttr->uNotifyUserLTInter = 0(0x0) offset:size = 94:1
chnAttr->gopAttr->uMaxSameSenceCnt = 1(0x1) offset:size = 96:4
chnAttr->gopAttr->bEnableLT = 0(0x0) offset:size = 100:1
chnAttr->gopAttr->uFreqLT = 0(0x0) offset:size = 104:4
chnAttr->gopAttr->bLTRC = 0(0x0) offset:size = 108:1
GROUP 1
	CHANNEL 1     640x  360     START H264 tf:786        df:2          encdur:39270, encodingFrameCnt:784,endencodeFrameCnt=784,endrelaseFrameCnt=784,Fps:20.02,Bitrate:161.93
-------------------------------------------------
ch->index = 1
ch->releaseFrmNum = 0
ch->releaseFrmDen = 0
chnAttr->encAttr->eProfile = 77(0x4d) offset:size = 0:4
chnAttr->encAttr->uLevel = 50(0x32) offset:size = 4:1
chnAttr->encAttr->uTier = 0(0x0) offset:size = 5:1
chnAttr->encAttr->uWidth = 640(0x280) offset:size = 6:2
chnAttr->encAttr->uHeight = 360(0x168) offset:size = 8:2
chnAttr->encAttr->ePicFormat = 392(0x188) offset:size = 12:4
chnAttr->encAttr->eEncOptions = 294952(0x48028) offset:size = 16:4
chnAttr->encAttr->eEncTools = 156(0x9c) offset:size = 20:4
chnAttr->rcAttr->rcMode = 8(0x8) offset:size = 44:4
chnAttr->rcAttr->CappedQuality->uTargetBitRate = 180(0xb4) offset:size = 48:4
chnAttr->rcAttr->CappedQuality->uMaxBitRate = 240(0xf0) offset:size = 52:4
chnAttr->rcAttr->CappedQuality->iInitialQP = -1(0xffffffff) offset:size = 56:2
chnAttr->rcAttr->CappedQuality->iMinQP = 23(0x17) offset:size = 58:2
chnAttr->rcAttr->CappedQuality->iMaxQP = 51(0x33) offset:size = 60:2
chnAttr->rcAttr->CappedQuality->iIPDelta = 3(0x3) offset:size = 62:2
chnAttr->rcAttr->CappedQuality->iPBDelta = 3(0x3) offset:size = 64:2
chnAttr->rcAttr->CappedQuality->eRcOptions = 1(0x1) offset:size = 68:4
chnAttr->rcAttr->CappedQuality->uMaxPictureSize = 640(0x280) offset:size = 72:4
chnAttr->rcAttr->CappedQuality->uMaxPSNR = 48(0x30) offset:size = 76:2
chnAttr->rcAttr->outFrmRate->frmRateNum = 20(0x14) offset:size = 80:4
chnAttr->rcAttr->outFrmRate->frmRateDen = 1(0x1) offset:size = 84:4
chnAttr->gopAttr->uGopCtrlMode = 2(0x2) offset:size = 88:4
chnAttr->gopAttr->uGopLength = 40(0x28) offset:size = 92:2
chnAttr->gopAttr->uNotifyUserLTInter = 0(0x0) offset:size = 94:1
chnAttr->gopAttr->uMaxSameSenceCnt = 1(0x1) offset:size = 96:4
chnAttr->gopAttr->bEnableLT = 0(0x0) offset:size = 100:1
chnAttr->gopAttr->uFreqLT = 0(0x0) offset:size = 104:4
chnAttr->gopAttr->bLTRC = 0(0x0) offset:size = 108:1
	CHANNEL 5     640x  360      STOP JPEG tf:39         df:1          encdur:30426, encodingFrameCnt:38,endencodeFrameCnt=38,endrelaseFrameCnt=38,Fps:1.18,Bitrate:157.51
-------------------------------------------------
ch->index = 5
ch->releaseFrmNum = 0
ch->releaseFrmDen = 0
chnAttr->encAttr->eProfile = 67108864(0x4000000) offset:size = 0:4
chnAttr->encAttr->uLevel = 0(0x0) offset:size = 4:1
chnAttr->encAttr->uTier = 0(0x0) offset:size = 5:1
chnAttr->encAttr->uWidth = 640(0x280) offset:size = 6:2
chnAttr->encAttr->uHeight = 360(0x168) offset:size = 8:2
chnAttr->encAttr->ePicFormat = 392(0x188) offset:size = 12:4
chnAttr->encAttr->eEncOptions = 294952(0x48028) offset:size = 16:4
chnAttr->encAttr->eEncTools = 156(0x9c) offset:size = 20:4
chnAttr->rcAttr->rcMode = 0(0x0) offset:size = 44:4
chnAttr->rcAttr->FixQP->iInitialQP = 32(0x20) offset:size = 48:2
chnAttr->rcAttr->outFrmRate->frmRateNum = 20(0x14) offset:size = 80:4
chnAttr->rcAttr->outFrmRate->frmRateDen = 1(0x1) offset:size = 84:4
chnAttr->gopAttr->uGopCtrlMode = 2(0x2) offset:size = 88:4
chnAttr->gopAttr->uGopLength = 40(0x28) offset:size = 92:2
chnAttr->gopAttr->uNotifyUserLTInter = 0(0x0) offset:size = 94:1
chnAttr->gopAttr->uMaxSameSenceCnt = 1(0x1) offset:size = 96:4
chnAttr->gopAttr->bEnableLT = 0(0x0) offset:size = 100:1
chnAttr->gopAttr->uFreqLT = 0(0x0) offset:size = 104:4
chnAttr->gopAttr->bLTRC = 0(0x0) offset:size = 108:1

```
`--fs_info`

```
CHANNEL(0)
	  INFO	 1920x 1080	     RUN 	20/ 1(fps) 	    NV12 
	  CROP	     DIS	left(0)	top(0)	width(1920)	height(1080)
	SCALER 	     DIS 	width(1920) 	height(1080)
CHANNEL(1)
	  INFO	  640x  360	     RUN 	20/ 1(fps) 	    NV12 
	  CROP	     DIS	left(0)	top(0)	width(1920)	height(1080)
	SCALER 	      EN 	width(640) 	height(360)
CHANNEL(2)
	  INFO	 1280x  720	    OPEN 	20/ 1(fps) 	    NV12 
	  CROP	     DIS	left(0)	top(0)	width(1920)	height(1080)
	SCALER 	      EN 	width(1280) 	height(720)
```
`--system_info`
```tree item: 3
Framesource-0        update_cnt=7205(qframecnt=7207, dqframecnt=7205, sem_msg_cnt=16, sem_cnt=0)
OSD-0                update_cnt=7205(sem_msg_cnt=16, sem_cnt=0)
Encoder-0            update_cnt=7205(sem_msg_cnt=16, sem_cnt=0)
---Framesource-0-----OSD-0-------------Encoder-0
tree item: 4
Framesource-1        update_cnt=7205(qframecnt=7208, dqframecnt=7205, sem_msg_cnt=16, sem_cnt=0)
IVS-0                update_cnt=7205(sem_msg_cnt=16, sem_cnt=0)
OSD-1                update_cnt=7205(sem_msg_cnt=16, sem_cnt=0)
Encoder-1            update_cnt=7205(sem_msg_cnt=16, sem_cnt=0)
---Framesource-1-----IVS-0-------------OSD-1-------------Encoder-1
tree item: 1
Framesource-2        update_cnt=0(qframecnt=0, dqframecnt=0, sem_msg_cnt=16, sem_cnt=0)
---Framesource-2
```
---

audio info:

v3:

```
May 13 13:22:39 iCamera: [sdk,0269]dbg: (local_sdk_speaker_set_parameters) sampleRate   :16000
May 13 13:22:39 iCamera: [sdk,0270]dbg: (local_sdk_speaker_set_parameters) trackType    :1
May 13 13:22:39 iCamera: [sdk,0271]dbg: (local_sdk_speaker_set_parameters) gain         :28
May 13 13:22:39 iCamera: [sdk,0272]dbg: (local_sdk_speaker_set_parameters) volume       :60
May 13 13:22:39 iCamera: [sdk,0273]dbg: (local_sdk_speaker_set_parameters) pcmBufSize   :1280
May 13 13:22:39 iCamera: [sdk,0274]dbg: (local_sdk_speaker_set_parameters) cacheSec     :1
May 13 13:22:39 iCamera: [sdk,0275]dbg: (local_sdk_speaker_set_parameters) paMode       :3
May 13 13:22:39 iCamera: [sdk,0276]dbg: (local_sdk_speaker_set_parameters) paAutoDisable:1
```
```
I/sdkspeaker.c(  232): samplerate	:16000
I/sdkspeaker.c(  232): bitwidth		:16
I/sdkspeaker.c(  232): soundmode	:1
I/sdkspeaker.c(  232): frmNum		:35
I/sdkspeaker.c(  232): numPerFrm	:640
I/sdkspeaker.c(  232): chnCnt		:1
```

```
I/ai      (  232): AI Enable: 1
I/ao      (  232): AO Enable: 0
I/ai      (  232): AI Enable Chn: 1-0
I/ai      (  232): EXIT AI Enable Chn: 1-0
I/ai      (  232): AI Set Gain: 31
I/ai      (  232): AI Set Vol: 90
I/ai      (  232): AI AGC ENABLE: targetLevelDbfs = 4, compressionGaindB = 10, limiterEnable =1
I/ai      (  232): AI HPF Enable
I/ai      (  232): HPF version is: Ingenic High Pass Filter 1.1.0
I/ao      (  232): AO Ch Enable: 0:0
I/ao      (  232): EXIT AO Ch Enable: 0:0
I/ao      (  232): AO Set Vol: 60
I/ao      (  232): AO Get Vol: 60
I/ao      (  232): AO HPF ENABLE
I/ao      (  232): HPF version is: Ingenic High Pass Filter 1.1.0
I/ao      (  232): AO Get Gain: 28
I/ao      (  232): AO Get Gain: 28
```

