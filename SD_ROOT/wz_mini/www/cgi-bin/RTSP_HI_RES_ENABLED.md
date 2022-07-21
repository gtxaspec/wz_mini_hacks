RTSP streaming: The RTSP server supports the two video streams provided by the camera, 1080p/360p (1296p/480p for the DB3). You can choose to enable a single stream of your choice, or both. Audio is also available. Set your login credentials here, server listening port, and the stream bitrate. (ENC_PARAMETER variable accepts numbers only. 0=FIXQP, 1=CBR, 2=VBR, 4=CAPPED VBR, 8=CAPPED QUALITY. Currently only 2, 4, and 8 are working)

RTSP_LOGIN="admin"
RTSP_PASSWORD=""
RTSP_PORT="8554"

RTSP_HI_RES_ENABLED="true"
RTSP_HI_RES_ENABLE_AUDIO="true"
RTSP_HI_RES_MAX_BITRATE="2048"
RTSP_HI_RES_TARGET_BITRATE="1024"
RTSP_HI_RES_ENC_PARAMETER="2"
RTSP_HI_RES_FPS="15"

RTSP_LOW_RES_ENABLED="false"
RTSP_LOW_RES_ENABLE_AUDIO="false"
RTSP_LOW_RES_MAX_BITRATE=""
RTSP_LOW_RES_TARGET_BITRATE=""
RTSP_LOW_RES_ENC_PARAMETER=""
RTSP_LOW_RES_FPS=""

the singular stream will be located at rtsp://login:password@IP_ADDRESS:8554/unicast multiple streams are located at rtsp://login:password@IP_ADDRESS:8554/video1_unicast and rtsp://login:password@IP_ADDRESS:8554/video2_unicast

Note: If you don't set the password, the password will be set to the unique MAC address of the camera, in all uppercase, including the colons... for example:. AA:BB:CC:00:11:22. It's typically printed on the camera. Higher video bitrates may overload your Wi-Fi connection, so a wired connection is recommended.

Huge credit to @mnakada for his libcallback library: https://github.com/mnakada/atomcam_tools
