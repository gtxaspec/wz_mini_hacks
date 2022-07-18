#!/bin/sh

SLEEP_TIME=0.1

read POST_STRING

if [ "$POST_STRING" = "forward" ]; then
		echo "forward"
                echo -ne "\xaa\x55\x43\x06\x29\x80\xe3\x00\x02\xd4" > /dev/ttyUSB0
		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$POST_STRING" = "reverse" ]; then
		echo "reverse"
                echo -ne "\xaa\x55\x43\x06\x29\x80\x36\x00\x02\x27" > /dev/ttyUSB0
		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$POST_STRING" = "left" ]; then
		echo "left"
	        echo -ne "\xaa\x55\x43\x06\x29\x76\x81\x00\x02\x68" > /dev/ttyUSB0
		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$POST_STRING" = "right" ]; then
		echo "right"
	        echo -ne "\xaa\x55\x43\x06\x29\x8a\x81\x00\x02\x7c" > /dev/ttyUSB0
		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$POST_STRING" = "forward_left" ]; then
		echo "left_forward"
                echo -ne "\xaa\x55\x43\x06\x29\x76\xe3\x00\x02\xca" > /dev/ttyUSB0
		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$POST_STRING" = "forward_right" ]; then
		echo "right_forward"
                echo -ne "\xaa\x55\x43\x06\x29\x8a\xe3\x00\x02\xde" > /dev/ttyUSB0
		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$POST_STRING" = "reverse_left" ]; then
		echo "left_reverse"
                echo -ne "\xaa\x55\x43\x06\x29\x76\x36\x00\x02\x1d" > /dev/ttyUSB0
		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$POST_STRING" = "reverse_right" ]; then
		echo "right_reverse"
                echo -ne "\xaa\x55\x43\x06\x29\x8a\x36\x00\x02\x31" > /dev/ttyUSB0
		sleep $SLEEP_TIME
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$POST_STRING" = "all_stop" ]; then
		echo "all stop"
	        echo -ne "\xaa\x55\x43\x06\x29\x80\x80\x00\x02\x71" > /dev/ttyUSB0
elif [ "$POST_STRING" = "headlight" ]; then
		echo "headlight"
		headlight
elif [ "$POST_STRING" = "irled" ]; then
		echo "irled"
		irled
elif [ "$POST_STRING" = "honk" ]; then
		echo "honk"
	        /opt/wz_mini/bin/cmd aplay /opt/wz_mini/usr/share/audio/honk.wav 70 > /dev/null 2>&1 &


else
	echo "no input"
fi
