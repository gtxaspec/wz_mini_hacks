#!/bin/sh

#Run impdbg commands sequentially

set -x

export WZMINI_CFG=/opt/wz_mini/wz_mini.conf

[ -f $WZMINI_CFG ] && source $WZMINI_CFG

DELAY_BETWEEN=2
RE_RUN_DELAY=60

rm -f /opt/wz_mini/tmp/impdbg.out

impdbg --enc_info > /opt/wz_mini/tmp/impdbg.out

CH0_RC=$(cat /opt/wz_mini/tmp/impdbg.out | sed -n '/GROUP 0/,/STOP/p' | grep "rcMode =" | sed 's/(.*//' | sed 's,.*\(.\{1\}\)$,\1,')
CH0_TGT_BIT=$(cat /opt/wz_mini/tmp/impdbg.out | sed -n '/GROUP 0/,/STOP/p' | grep TargetBitRate | sed 's/(.*//' | sed 's,.*\(.\{4\}\)$,\1,')
CH0_MAX_BIT=$(cat /opt/wz_mini/tmp/impdbg.out | sed -n '/GROUP 0/,/STOP/p' | grep MaxBitRate | sed 's/(.*//' | sed 's,.*\(.\{4\}\)$,\1,')
CH0_FPS=$(cat /opt/wz_mini/tmp/impdbg.out | sed -n '/GROUP 0/,/STOP/p' | grep frmRateNum | sed 's/(.*//' | sed 's,.*\(.\{2\}\)$,\1,')

CH1_RC=$(cat /opt/wz_mini/tmp/impdbg.out | sed -n '/GROUP 1/,/STOP/p' | grep "rcMode =" | sed 's/(.*//' | sed 's,.*\(.\{1\}\)$,\1,')
CH1_TGT_BIT=$(cat /opt/wz_mini/tmp/impdbg.out | sed -n '/GROUP 1/,/STOP/p' | grep TargetBitRate | sed 's/(.*//' | sed 's,.*\(.\{4\}\)$,\1,')
CH1_MAX_BIT=$(cat /opt/wz_mini/tmp/impdbg.out | sed -n '/GROUP 1/,/STOP/p' | grep MaxBitRate | sed 's/(.*//' | sed 's,.*\(.\{4\}\)$,\1,')
CH1_FPS=$(cat /opt/wz_mini/tmp/impdbg.out | sed -n '/GROUP 1/,/STOP/p' | grep frmRateNum | sed 's/(.*//' | sed 's,.*\(.\{2\}\)$,\1,')

rm -f /opt/wz_mini/tmp/impdbg.out

hi_res_monitor() {
	if [[ "$RTSP_HI_RES_ENABLED" != "true" ]] ; then
		return
	fi

	if [[ "$RTSP_HI_RES_ENC_PARAMETER" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			if [[ $RTSP_HI_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]] ; then
				if [[ $RTSP_HI_RES_ENC_PARAMETER != "$CH0_RC" ]] ; then
					echo "Setting RTSP_HI_RES_ENC_PARAMETER T20"
					/system/bin/impdbg --enc_rc_s 0:0:4:$RTSP_HI_RES_ENC_PARAMETER
					sleep $DELAY_BETWEEN
				else
					echo "No change to RTSP_HI_RES_ENC_PARAMETER"
				fi
			else
				echo "Invalid encoder value $RTSP_HI_RES_ENC_PARAMETER"
			fi
		else
			if [[ $RTSP_HI_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]] ; then
				if [[ $RTSP_HI_RES_ENC_PARAMETER != "$CH0_RC" ]] ; then
					echo "Setting RTSP_HI_RES_ENC_PARAMETER"
					/system/bin/impdbg --enc_rc_s 0:44:4:$RTSP_HI_RES_ENC_PARAMETER
					sleep $DELAY_BETWEEN
				else
					echo "No change to RTSP_HI_RES_ENC_PARAMETER"
				fi
			else
				echo "Invalid encoder value $RTSP_HI_RES_ENC_PARAMETER"
			fi
		fi
	fi

	if [[ "$RTSP_HI_RES_MAX_BITRATE" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			if [[ $RTSP_HI_RES_MAX_BITRATE != "$CH0_MAX_BIT" ]] ; then
				echo "Setting RTSP_HI_RES_MAX_BITRATE T20"
				/system/bin/impdbg --enc_rc_s 0:28:4:$RTSP_HI_RES_MAX_BITRATE
				sleep $DELAY_BETWEEN
			else
				echo "No change to RTSP_HI_RES_MAX_BITRATE T20"
			fi
		else
			if [[ $RTSP_HI_RES_MAX_BITRATE != "$CH0_MAX_BIT" ]] ; then
				echo "Setting RTSP_HI_RES_MAX_BITRATE"
				/system/bin/impdbg --enc_rc_s 0:52:4:$RTSP_HI_RES_MAX_BITRATE
				sleep $DELAY_BETWEEN
			else
				echo "No change to RTSP_HI_RES_MAX_BITRATE"
			fi
		fi
	fi

	if [[ "$RTSP_HI_RES_TARGET_BITRATE" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			echo "not supported on T20"
		else
			if [[ $RTSP_HI_RES_TARGET_BITRATE != "$CH0_TGT_BIT" ]] ; then
				echo "Setting RTSP_HI_RES_TARGET_BITRATE"
				/system/bin/impdbg --enc_rc_s 0:48:4:$RTSP_HI_RES_TARGET_BITRATE
				sleep $DELAY_BETWEEN
			else
				echo "No change to RTSP_HI_RES_TARGET_BITRATE"
			fi
		fi
	fi

	if [[ "$RTSP_HI_RES_FPS" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			if [[ $RTSP_HI_RES_FPS != "$CH0_FPS" ]] ; then
				echo "Setting RTSP_HI_RES_FPS T20"
				/system/bin/impdbg --enc_rc_s 0:8:4:$RTSP_HI_RES_FPS
				sleep $DELAY_BETWEEN
			else
				echo "No change to RTSP_HI_RES_FPS T20"
			fi
		else
			if [[ $RTSP_HI_RES_FPS != "$CH0_FPS" ]] ; then
				echo "Setting RTSP_HI_RES_FPS"
				/system/bin/impdbg --enc_rc_s 0:80:4:$RTSP_HI_RES_FPS
				sleep $DELAY_BETWEEN
			else
				echo "No change to RTSP_HI_RES_FPS"
			fi
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
				if [[ $RTSP_LOW_RES_ENC_PARAMETER != "$CH1_RC" ]] ; then
					echo "Setting RTSP_LOW_RES_ENC_PARAMETER T20"
					/system/bin/impdbg --enc_rc_s 1:0:4:$RTSP_LOW_RES_ENC_PARAMETER
					sleep $DELAY_BETWEEN
				else
					echo "No change to RTSP_LOW_RES_ENC_PARAMETER T20"
				fi
			else
				echo "Invalid encoder value $RTSP_LOW_RES_ENC_PARAMETER"
			fi
		else
			if [[ $RTSP_LOW_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]] ; then
				if [[ $RTSP_LOW_RES_ENC_PARAMETER != "$CH1_RC" ]] ; then
					echo "Setting RTSP_LOW_RES_ENC_PARAMETER"
					/system/bin/impdbg --enc_rc_s 1:44:4:$RTSP_LOW_RES_ENC_PARAMETER
					sleep $DELAY_BETWEEN
				else
					echo "No change to RTSP_LOW_RES_ENC_PARAMETER"
				fi
			else
				echo "Invalid encoder value $RTSP_LOW_RES_ENC_PARAMETER"
			fi
		fi
	fi

	if [[ "$RTSP_LOW_RES_MAX_BITRATE" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			if [[ $RTSP_LOW_RES_MAX_BITRATE != "$CH1_MAX_BIT" ]] ; then
				echo "Setting RTSP_LOW_RES_MAX_BITRATE T20"
				/system/bin/impdbg --enc_rc_s 1:28:4:$RTSP_LOW_RES_MAX_BITRATE
				sleep $DELAY_BETWEEN
			else
				echo "No change to RTSP_LOW_RES_MAX_BITRATE T20"
			fi
		else
			if [[ $RTSP_LOW_RES_MAX_BITRATE != "$CH1_MAX_BIT" ]] ; then
				echo "Setting RTSP_LOW_RES_MAX_BITRATE"
				/system/bin/impdbg --enc_rc_s 1:52:4:$RTSP_LOW_RES_MAX_BITRATE
				sleep $DELAY_BETWEEN
			else
				echo "No change to RTSP_LOW_RES_MAX_BITRATE"
			fi
		fi
	fi

	if [[ "$RTSP_LOW_RES_TARGET_BITRATE" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			echo "Not supported on T20"
		else
			if [[ $RTSP_LOW_RES_TARGET_BITRATE != "$CH1_TGT_BIT" ]] ; then
				echo "Setting RTSP_LOW_RES_TARGET_BITRATE"
				/system/bin/impdbg --enc_rc_s 1:48:4:$RTSP_LOW_RES_TARGET_BITRATE
				sleep $DELAY_BETWEEN
			else
				echo "No change to RTSP_LOW_RES_TARGET_BITRATE"
			fi
		fi
	fi

	if [[ "$RTSP_LOW_RES_FPS" != "" ]] ; then
		if [ -f /opt/wz_mini/tmp/.T20 ] ; then
			if [[ $RTSP_LOW_RES_FPS != "$CH1_FPS" ]] ; then
				echo "Setting RTSP_LOW_RES_FPS T20"
				/system/bin/impdbg --enc_rc_s 1:8:4:$RTSP_LOW_RES_FPS
				sleep $DELAY_BETWEEN
			else
				echo "No change to RTSP_LOW_RES_FPS T20"
			fi
		else
			if [[ $RTSP_LOW_RES_FPS != "$CH1_FPS" ]] ; then
				echo "Setting RTSP_LOW_RES_FPS"
				/system/bin/impdbg --enc_rc_s 1:80:4:$RTSP_LOW_RES_FPS
				sleep $DELAY_BETWEEN
			else
				echo "No change to RTSP_LOW_RES_FPS"
			fi
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
