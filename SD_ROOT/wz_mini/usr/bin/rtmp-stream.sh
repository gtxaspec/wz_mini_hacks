#! /bin/sh

source /opt/wz_mini/wz_mini.conf

if [[ "$RTSP_PASSWORD" == "" ]]; then
        RTSP_PASSWORD=$(cat /opt/wz_mini/tmp/wlan0_mac)
fi

FFMPEG_BINARY="/opt/wz_mini/bin/ffmpeg"

TWITCH_URL="rtmp://live-ber.twitch.tv/app"
YOUTUBE_URL="rtmp://b.rtmp.youtube.com/live2"
FACEBOOK_URL="rtmps://live-api-s.facebook.com:443/rtmp"

#######################################
######ENTER YOUR STREAM KEYS HERE######
YOUTUBE_KEY=""
TWITCH_KEY=""
FACEBOOK_KEY=""
#######################################
#######################################

#V3: 1080p=video1 360p=video2
#V2: 1080p=video6 360p=video7

RTSP_STREAM="video1_unicast"

VIDEO_SOURCE="rtsp://"$RTSP_LOGIN":"$RTSP_PASSWORD"@0.0.0.0:"$RTSP_PORT"/$RTSP_STREAM"
AUDIO="-c:a libfdk_aac -afterburner 1 -channels 1 -b:a 256k -profile:a aac_he -ar 16000 -strict experimental"

if [[ "$2" == "no_audio" ]]; then
        echo NOAUDIO
        AUDIO="-an"
fi

if [[ "$1" == "youtube" ]]; then
        echo "youtube"
        STREAM_PROVIDER="$YOUTUBE_URL"
        KEY="$YOUTUBE_KEY"
elif [[ "$1" == "twitch" ]]; then
        echo "twitch"
        STREAM_PROVIDER="$TWITCH_URL"
        KEY="$TWITCH_KEY"
elif [[ "$1" == "facebook" ]]; then
        echo "facebook"
        STREAM_PROVIDER="$FACEBOOK_URL"
        KEY="$FACEBOOK_KEY"
else
echo "Usage:"
echo "rtmp facebook"
echo "rtmp twitch"
echo "rtmp youtube"
echo "Update the script with your stream keys first"
exit 0
fi

sync;echo 3 > /proc/sys/vm/drop_caches

$FFMPEG_BINARY \
-rtsp_transport udp -y \
-i "$VIDEO_SOURCE" \
-c:v copy -coder 1 -pix_fmt yuv420p -g 30 -bf 0 $AUDIO -aspect 16:9 -f flv "$STREAM_PROVIDER/$KEY"
