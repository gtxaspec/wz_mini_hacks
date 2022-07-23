#!/bin/sh

#Run impdbg commands sequentially

set -x

export WZMINI_CFG=/opt/wz_mini/wz_mini.conf

[ -f $WZMINI_CFG ] && source $WZMINI_CFG

DELAY_BETWEEN=2
RE_RUN_DELAY=45
PARM=1

hi_res_monitor() {
if [[ "$RTSP_HI_RES_ENABLED" == "true" ]]; then

       if [[ "$RTSP_HI_RES_ENC_PARAMETER" != "" ]]; then
                if [ -f /opt/wz_mini/tmp/.T20 ]; then
                        if [[ $RTSP_HI_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]]; then
                                /system/bin/impdbg --enc_rc_s 0:0:4:$RTSP_HI_RES_ENC_PARAMETER
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                        else
                                echo "Invalid encoder value"
                        fi
                else
                        if [[ $RTSP_HI_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]]; then
                                /system/bin/impdbg --enc_rc_s 0:44:4:$RTSP_HI_RES_ENC_PARAMETER
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                        else
                                echo "Invalid encoder value"
                        fi
                fi
        fi

        if [[ "$RTSP_HI_RES_MAX_BITRATE" != "" ]]; then
                if [ -f /opt/wz_mini/tmp/.T20 ]; then
                        /system/bin/impdbg --enc_rc_s 0:28:4:$RTSP_HI_RES_MAX_BITRATE
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                else
                        /system/bin/impdbg --enc_rc_s 0:52:4:$RTSP_HI_RES_MAX_BITRATE
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                fi
        fi

        if [[ "$RTSP_HI_RES_TARGET_BITRATE" != "" ]]; then
                if [ -f /opt/wz_mini/tmp/.T20 ]; then
                        echo "not supported on T20"
                else
                        /system/bin/impdbg --enc_rc_s 0:48:4:$RTSP_HI_RES_TARGET_BITRATE
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                fi
        fi

        if [[ "$RTSP_HI_RES_FPS" != "" ]]; then
                if [ -f /opt/wz_mini/tmp/.T20 ]; then
                        /system/bin/impdbg --enc_rc_s 0:8:4:$RTSP_HI_RES_FPS
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                else
                        /system/bin/impdbg --enc_rc_s 0:80:4:$RTSP_HI_RES_FPS
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                fi
        fi

	if [ $PARM == 1 ]; then
	echo "No Hi-Res imp variables enabled, check Low-Res"
	fi

	low_res_monitor
else
	echo "Hi-Res RTSP not enabled"
	low_res_monitor
fi
}

low_res_monitor () {
if [[ "$RTSP_LOW_RES_ENABLED" == "true" ]]; then

        if [[ "$RTSP_LOW_RES_ENC_PARAMETER" != "" ]]; then
                if [ -f /opt/wz_mini/tmp/.T20 ]; then
                        if [[ $RTSP_LOW_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]]; then
                                /system/bin/impdbg --enc_rc_s 1:0:4:$RTSP_LOW_RES_ENC_PARAMETER
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                        else
                                echo "Invalid encoder value"
                        fi
                else
                        if [[ $RTSP_LOW_RES_ENC_PARAMETER =~ "^[0|1|2|4|8]$" ]]; then
                                /system/bin/impdbg --enc_rc_s 1:44:4:$RTSP_LOW_RES_ENC_PARAMETER
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                        else
                                echo "Invalid encoder value"
                        fi
                fi
        fi

        if [[ "$RTSP_LOW_RES_MAX_BITRATE" != "" ]]; then
                if [ -f /opt/wz_mini/tmp/.T20 ]; then
                        /system/bin/impdbg --enc_rc_s 1:28:4:$RTSP_LOW_RES_MAX_BITRATE
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                else
                        /system/bin/impdbg --enc_rc_s 1:52:4:$RTSP_LOW_RES_MAX_BITRATE
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                fi
        fi

        if [[ "$RTSP_LOW_RES_TARGET_BITRATE" != "" ]]; then
                if [ -f /opt/wz_mini/tmp/.T20 ]; then
                        echo "not supported on T20"
                else
                        /system/bin/impdbg --enc_rc_s 1:48:4:$RTSP_LOW_RES_TARGET_BITRATE
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                fi
        fi

        if [[ "$RTSP_LOW_RES_FPS" != "" ]]; then
                if [ -f /opt/wz_mini/tmp/.T20 ]; then
                        /system/bin/impdbg --enc_rc_s 1:8:4:$RTSP_LOW_RES_FPS
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                else
                        /system/bin/impdbg --enc_rc_s 1:80:4:$RTSP_LOW_RES_FPS
				sleep $DELAY_BETWEEN
				PARM=$((PARM+1))
                fi
        fi

	if [ $PARM == 1 ]; then
	echo "No Low-Res imp variables enabled, exit"
	break
	fi
else
	echo "Low-Res RTSP not enabled"
	if [[ "$RTSP_HI_RES_ENABLED" == "true" ]] && [ $PARM -gt 1 ]; then
		hi_res_monitor
	else
		break
	fi
fi
}

while true; do
	hi_res_monitor
	echo "Restart imp_helper.sh, sleep for $RE_RUN_DELAY"
	sleep $RE_RUN_DELAY
done
