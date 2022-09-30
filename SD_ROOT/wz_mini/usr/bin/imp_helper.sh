#!/bin/sh

#Run impdbg commands sequentially

set -x

export WZMINI_CFG=/opt/wz_mini/wz_mini.conf

[ -f $WZMINI_CFG ] && source $WZMINI_CFG

DELAY_BETWEEN=2
RE_RUN_DELAY=60

hi_res_monitor() {
	if [[ "$RTSP_HI_RES_ENABLED" != "true" ]] ; then
		return
	fi

	if [[ "$RTSP_HI_RES_ENC_PARAMETER" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			if [[ $RTSP_HI_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]] ; then
				/system/bin/impdbg --enc_rc_s 0:0:4:$RTSP_HI_RES_ENC_PARAMETER
				sleep $DELAY_BETWEEN
			else
				echo "Invalid encoder value $RTSP_HI_RES_ENC_PARAMETER"
			fi
		else
			if [[ $RTSP_HI_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]] ; then
				/system/bin/impdbg --enc_rc_s 0:44:4:$RTSP_HI_RES_ENC_PARAMETER
				sleep $DELAY_BETWEEN
			else
				echo "Invalid encoder value $RTSP_HI_RES_ENC_PARAMETER"
			fi
		fi
	fi

	if [[ "$RTSP_HI_RES_MAX_BITRATE" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			/system/bin/impdbg --enc_rc_s 0:28:4:$RTSP_HI_RES_MAX_BITRATE
			sleep $DELAY_BETWEEN
		else
			/system/bin/impdbg --enc_rc_s 0:52:4:$RTSP_HI_RES_MAX_BITRATE
			sleep $DELAY_BETWEEN
		fi
	fi

	if [[ "$RTSP_HI_RES_TARGET_BITRATE" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			echo "not supported on T20"
		else
			/system/bin/impdbg --enc_rc_s 0:48:4:$RTSP_HI_RES_TARGET_BITRATE
			sleep $DELAY_BETWEEN
		fi
	fi

	if [[ "$RTSP_HI_RES_FPS" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			/system/bin/impdbg --enc_rc_s 0:8:4:$RTSP_HI_RES_FPS
			sleep $DELAY_BETWEEN
		else
			/system/bin/impdbg --enc_rc_s 0:80:4:$RTSP_HI_RES_FPS
			sleep $DELAY_BETWEEN
		fi
	fi
}

low_res_monitor () {
	if [[ "$RTSP_LOW_RES_ENABLED" != "true" ]] ; then
		return
	fi

	if [[ "$RTSP_LOW_RES_ENC_PARAMETER" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			if [[ $RTSP_LOW_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]] ; then
				/system/bin/impdbg --enc_rc_s 1:0:4:$RTSP_LOW_RES_ENC_PARAMETER
				sleep $DELAY_BETWEEN
			else
				echo "Invalid encoder value $RTSP_LOW_RES_ENC_PARAMETER"
			fi
		else
			if [[ $RTSP_LOW_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]] ; then
				/system/bin/impdbg --enc_rc_s 1:44:4:$RTSP_LOW_RES_ENC_PARAMETER
				sleep $DELAY_BETWEEN
			else
				echo "Invalid encoder value $RTSP_LOW_RES_ENC_PARAMETER"
			fi
		fi
	fi

	if [[ "$RTSP_LOW_RES_MAX_BITRATE" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			/system/bin/impdbg --enc_rc_s 1:28:4:$RTSP_LOW_RES_MAX_BITRATE
			sleep $DELAY_BETWEEN
		else
			/system/bin/impdbg --enc_rc_s 1:52:4:$RTSP_LOW_RES_MAX_BITRATE
			sleep $DELAY_BETWEEN
		fi
	fi

	if [[ "$RTSP_LOW_RES_TARGET_BITRATE" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			echo "not supported on T20"
		else
			/system/bin/impdbg --enc_rc_s 1:48:4:$RTSP_LOW_RES_TARGET_BITRATE
			sleep $DELAY_BETWEEN
		fi
	fi

	if [[ "$RTSP_LOW_RES_FPS" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			/system/bin/impdbg --enc_rc_s 1:8:4:$RTSP_LOW_RES_FPS
			sleep $DELAY_BETWEEN
		else
			/system/bin/impdbg --enc_rc_s 1:80:4:$RTSP_LOW_RES_FPS
			sleep $DELAY_BETWEEN
		fi
	fi
}



if [[ "$1" == "-h" ]] ; then
	echo "Usage: $0 [-f]"
	echo "  Sets hardware encoder settings. Use -f to run once before quitting.."
	exit 0
fi

if [[ "$1" == "-f" ]] ; then
	hi_res_monitor
	low_res_monitor
	exit 0
fi

while true; do
	hi_res_monitor
	low_res_monitor

	echo "Restart imp_helper.sh, sleep for $RE_RUN_DELAY"
	sleep $RE_RUN_DELAY
done

