#!/bin/sh

set -x 

. /opt/wz_mini/www/cgi-bin/shared.cgi
test_area_access car


echo "HTTP/1.1 200"
echo -e "Content-type: text/html\n\n"
echo ""

read POST_STRING

SPEED=$(echo $POST_STRING | sed 's/.*speed=//;s/\&.*//')
ACTION=$(echo $POST_STRING | sed 's/.*action=//;s/\&.*//')
SLEEP_TIME=$(echo $POST_STRING | sed 's/.*sleep_time=//;s/\&.*//')

echo "raw post string: $POST_STRING"
echo "speed: $SPEED"
echo "action: $ACTION"
echo "sleep: $SLEEP_TIME"

if [ "$ACTION" = "forward" ]; then

	if [ "$SPEED" = "slow" ]; then
		echo "slow"
	        echo -ne "\xaa\x55\x43\x06\x29\x80\xca\x00\x02\xbb" > /dev/ttyUSB0
	else
		echo "forward"
		echo -ne "\xaa\x55\x43\x06\x29\x80\xe3\x00\x02\xd4" > /dev/ttyUSB0
	fi

	sleep $SLEEP_TIME
	echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0

elif [ "$ACTION" = "reverse" ]; then
		echo "reverse"
                echo -ne "\xaa\x55\x43\x06\x29\x80\x36\x00\x02\x27" > /dev/ttyUSB0

		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$ACTION" = "left" ]; then
		echo "left"
	        echo -ne "\xaa\x55\x43\x06\x29\x76\x81\x00\x02\x68" > /dev/ttyUSB0

		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$ACTION" = "right" ]; then
		echo "right"
	        echo -ne "\xaa\x55\x43\x06\x29\x8a\x81\x00\x02\x7c" > /dev/ttyUSB0

		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$ACTION" = "forward_left" ]; then
		echo "left_forward"
                echo -ne "\xaa\x55\x43\x06\x29\x76\xe3\x00\x02\xca" > /dev/ttyUSB0

		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$ACTION" = "forward_right" ]; then
		echo "right_forward"
                echo -ne "\xaa\x55\x43\x06\x29\x8a\xe3\x00\x02\xde" > /dev/ttyUSB0

		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$ACTION" = "reverse_left" ]; then
		echo "left_reverse"
                echo -ne "\xaa\x55\x43\x06\x29\x76\x36\x00\x02\x1d" > /dev/ttyUSB0
		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$ACTION" = "reverse_right" ]; then
		echo "right_reverse"
                echo -ne "\xaa\x55\x43\x06\x29\x8a\x36\x00\x02\x31" > /dev/ttyUSB0
		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$ACTION" = "all_stop" ]; then
		echo "all stop"
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$ACTION" = "headlight_on" ]; then
		echo "headlight_on"
		echo -ne "\xaa\x55\x43\x04\x1e\x01\x01\x65" > /dev/ttyUSB0
elif [ "$ACTION" = "headlight_off" ]; then
		echo "headlight_off"
		echo -ne "\xaa\x55\x43\x04\x1e\x02\x01\x66" > /dev/ttyUSB0
elif [ "$ACTION" = "irled_on" ]; then
		echo "irled_on"
		cmd irled on > /dev/null		
elif [ "$ACTION" = "irled_off" ]; then
		echo "irled_off"
		cmd irled off > /dev/null
elif [ "$ACTION" = "honk" ]; then
		echo "honk"
	        /opt/wz_mini/bin/cmd aplay /opt/wz_mini/usr/share/audio/honk.wav 70 > /dev/null 2>&1 &


else
	echo "no input"
fi
