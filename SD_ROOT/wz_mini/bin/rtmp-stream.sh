#! /bin/sh

RTMP_LOG=/opt/wz_mini/log/rtmp.log

source /opt/wz_mini/wz_mini.conf

if [[ "$RTSP_PASSWORD" == "" ]]; then
        RTSP_PASSWORD=$(cat /opt/wz_mini/tmp/wlan0_mac)
fi

FFMPEG_BINARY="/opt/wz_mini/bin/ffmpeg"

TWITCH_URL="rtmp://live-ber.twitch.tv/app"
YOUTUBE_URL="rtmp://b.rtmp.youtube.com/live2"
FACEBOOK_URL="rtmps://live-api-s.facebook.com:443/rtmp"

VIDEO_SOURCE="rtsp://"$RTSP_LOGIN":"$RTSP_PASSWORD"@0.0.0.0:"$RTSP_PORT"/$RTMP_STREAM_FEED"

AUDIO_OPTIONS="-c:a libfdk_aac -afterburner 1 -channels 1 -b:a 128k -profile:a aac_he -ar 16000 -strict experimental"
VIDEO_OPTIONS="-c:v copy -coder 1 -pix_fmt yuv420p -g 30 -bf 0"

if [[ "$2" == "no_audio" ]]; then
        echo "NO_AUDIO: audio disabled on RTMP Stream."
        AUDIO_OPTIONS="-an"
fi

if [[ "$1" == "youtube" ]]; then
        echo "RTMP Streaming to: YouTube"
        STREAM_PROVIDER="$YOUTUBE_URL"
        KEY="$RTMP_STREAM_YOUTUBE_KEY"
elif [[ "$1" == "twitch" ]]; then
        echo "RTMP Streaming to: twitch"
        STREAM_PROVIDER="$TWITCH_URL"
        KEY="$RTMP_STREAM_TWITCH_KEY"
elif [[ "$1" == "facebook" ]]; then
        echo "RTMP Streaming to: facebook"
        STREAM_PROVIDER="$FACEBOOK_URL"
        KEY="$RTMP_STREAM_FACEBOOK_KEY"
else
	echo "Usage: rtmp-stream.sh <service> <no_audio>"
	echo ""
	echo "Available services:"
	echo "rtmp-stream.sh facebook"
	echo "rtmp-stream.sh twitch"
	echo "rtmp-stream.sh youtube"
	echo "rtmp-stream.sh <service> no_audio disables audio"
	echo ""
	echo "Update the script with your stream keys first."
	exit 0
fi

sync;echo 3 > /proc/sys/vm/drop_caches

echo "LOG FILE: $RTMP_LOG"

$FFMPEG_BINARY \
-rtsp_transport udp -y \
-i "$VIDEO_SOURCE" \
$VIDEO_OPTIONS $AUDIO_OPTIONS -aspect 16:9 -f flv "$STREAM_PROVIDER/$KEY" > $RTMP_LOG 2>&1 &
