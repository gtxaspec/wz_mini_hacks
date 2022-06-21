#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <linux/videodev2.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <pthread.h>

struct frames_st {
  void *buf;
  size_t length;
};
typedef int (* framecb)(struct frames_st *);

static int (*real_local_sdk_video_set_encode_frame_callback)(int ch, void *callback);
static void *video_encode_cb = NULL;
static void *video_encode_cb1 = NULL;
static int VideoCaptureEnable = 0;
static int VideoCaptureEnable1 = 0;

char *VideoCapture(int fd, char *tokenPtr) {

  char *p = strtok_r(NULL, " \t\r\n", &tokenPtr);
  if(!p) return VideoCaptureEnable ? "on" : "off";
  if(!strcmp(p, "on")) {
    VideoCaptureEnable = 1;
    fprintf(stderr, "[command] video capture ch0 on\n", p);
    return "ok";
  }
  if(!strcmp(p, "on1")) {
    VideoCaptureEnable1 = 1;
    fprintf(stderr, "[command] video capture ch1 on\n", p);
    return "ok";
  }
  if(!strcmp(p, "off")) {
    VideoCaptureEnable = 0;
    fprintf(stderr, "[command] video capture ch0 off\n", p);
    return "ok";
  }
  if(!strcmp(p, "off1")) {
    VideoCaptureEnable1 = 0;
    fprintf(stderr, "[command] video capture ch1 off\n", p);
    return "ok";
  }
  return "error";
}

static uint32_t video_encode_capture(struct frames_st *frames) {

  static int firstEntry = 0;
  static int v4l2Fd = -1;

//primary stream 0
  if(!firstEntry) {
    firstEntry++;
    int err;


    char *v4l2_device_path = "/dev/video0";
    //Check for this file, which should only exist on the V2 cameras
    const char *productv2="/driver/sensor_jxf23.ko";

    if( access( productv2, F_OK ) != -1 ) {
    v4l2_device_path = "/dev/video6";
    fprintf(stderr, "[command] v4l2_device_path = %s\n", v4l2_device_path);
    } else {
    v4l2_device_path = "/dev/video1";
    fprintf(stderr, "[command] v4l2_device_path = %s\n", v4l2_device_path);
    }


    const char *productf="/configs/.product_db3";
    fprintf(stderr,"Opening V4L2 device: %s \n", v4l2_device_path);
    v4l2Fd = open(v4l2_device_path, O_WRONLY, 0777);
    if(v4l2Fd < 0) fprintf(stderr,"Failed to open V4L2 device: %s\n", v4l2_device_path);
    struct v4l2_format vid_format;
    memset(&vid_format, 0, sizeof(vid_format));
    vid_format.type = V4L2_BUF_TYPE_VIDEO_OUTPUT;

    if( access( productf, F_OK ) == 0 ) {
                /* doorbell resolution */
                printf("[command] video product 1728x1296");
                vid_format.fmt.pix.width = 1728;
                vid_format.fmt.pix.height = 1296;
    } else {
                /* v3 and panv2 res */
                printf("[command] video product 1920x1080");
                vid_format.fmt.pix.width = 1920;
                vid_format.fmt.pix.height = 1080;
    }

    vid_format.fmt.pix.pixelformat = V4L2_PIX_FMT_H264;
    vid_format.fmt.pix.sizeimage = 0;
    vid_format.fmt.pix.field = V4L2_FIELD_NONE;
    vid_format.fmt.pix.bytesperline = 0;
    vid_format.fmt.pix.colorspace = V4L2_PIX_FMT_YUV420;
    err = ioctl(v4l2Fd, VIDIOC_S_FMT, &vid_format);
    if(err < 0) fprintf(stderr,"Unable to set V4L2 device video format: %d\n", err);
    err = ioctl(v4l2Fd, VIDIOC_STREAMON, &vid_format);
    if(err < 0) fprintf(stderr,"Unable to perform VIDIOC_STREAMON: %d\n", err);
  }

  if( (v4l2Fd >= 0) && VideoCaptureEnable) {
    uint32_t *buf = frames->buf;
    int size = write(v4l2Fd, frames->buf, frames->length);
    if(size != frames->length) fprintf(stderr,"Stream write error: %s\n", size);
  }
  return ((framecb)video_encode_cb)(frames);
}

//secondary stream 1
static uint32_t video_encode_capture1(struct frames_st *frames) {

  static int firstEntry = 0;
  static int v4l2Fd = -1;

  if(!firstEntry) {
    firstEntry++;
    int err;

    char *v4l2_device_path = "/dev/video0";
    //Check for this file, which should only exist on the V2 cameras
    const char *productv2="/driver/sensor_jxf23.ko";

    if( access( productv2, F_OK ) != -1 ) {
    v4l2_device_path = "/dev/video7";
    fprintf(stderr, "[command] v4l2_device_path = %s\n", v4l2_device_path);
    } else {
    v4l2_device_path = "/dev/video2";
    fprintf(stderr, "[command] v4l2_device_path = %s\n", v4l2_device_path);
    }

    const char *productf="/configs/.product_db3";
    fprintf(stderr,"Opening V4L2 device: %s \n", v4l2_device_path);
    v4l2Fd = open(v4l2_device_path, O_WRONLY, 0777);
    if(v4l2Fd < 0) fprintf(stderr,"Failed to open V4L2 device: %s\n", v4l2_device_path);
    struct v4l2_format vid_format;
    memset(&vid_format, 0, sizeof(vid_format));
    vid_format.type = V4L2_BUF_TYPE_VIDEO_OUTPUT;

    if( access( productf, F_OK ) == 0 ) {
                /* doorbell resolution */
                printf("[command] video product 640x480");
                vid_format.fmt.pix.width = 640;
                vid_format.fmt.pix.height = 480;
    } else {
                /* v3 and panv2 res */
                printf("[command] video product 640x320");
                vid_format.fmt.pix.width = 640;
                vid_format.fmt.pix.height = 320;
    }

    vid_format.fmt.pix.pixelformat = V4L2_PIX_FMT_H264;
    vid_format.fmt.pix.sizeimage = 0;
    vid_format.fmt.pix.field = V4L2_FIELD_NONE;
    vid_format.fmt.pix.bytesperline = 0;
    vid_format.fmt.pix.colorspace = V4L2_PIX_FMT_YUV420;
    err = ioctl(v4l2Fd, VIDIOC_S_FMT, &vid_format);
    if(err < 0) fprintf(stderr,"Unable to set V4L2 device video format: %d\n", err);
    err = ioctl(v4l2Fd, VIDIOC_STREAMON, &vid_format);
    if(err < 0) fprintf(stderr,"Unable to perform VIDIOC_STREAMON: %d\n", err);
  }

  if( (v4l2Fd >= 0) && VideoCaptureEnable) {
    uint32_t *buf = frames->buf;
    int size = write(v4l2Fd, frames->buf, frames->length);
    if(size != frames->length) fprintf(stderr,"Stream write error: %s\n", size);
  }
  return ((framecb)video_encode_cb1)(frames);
}


int local_sdk_video_set_encode_frame_callback(int ch, void *callback) {

  fprintf(stderr, "local_sdk_video_set_encode_frame_callback streamChId=%d, callback=0x%x\n", ch, callback);
  static int ch_count = 0;

/* two callbacks for video stream 0 are typically detected, unknown what the difference is between them, but if they are both hooked, the app breaks. grab just one of them. */
  //stream 0
  if( (ch == 0) && ch_count == 2) {
    video_encode_cb = callback;
    fprintf(stderr,"enc func injection save video_encode_cb=0x%x\n", video_encode_cb);
    callback = video_encode_capture;
  } else if( (ch == 0) && ch_count == 3) {
    video_encode_cb = callback;
    fprintf(stderr,"RTSP FIRMWARE enc func injection save video_encode_cb=0x%x\n", video_encode_cb);
    callback = video_encode_capture;
  }
    fprintf(stderr,"ch count is %x\n", ch_count);

  //stream 1
  if( (ch == 1) && ch_count == 1) {
    video_encode_cb1 = callback;
    fprintf(stderr,"enc func injection save video_encode_cb=0x%x\n", video_encode_cb1);
    callback = video_encode_capture1;
  }

    ch_count=ch_count+1;

  return real_local_sdk_video_set_encode_frame_callback(ch, callback);
}

static void __attribute ((constructor)) video_callback_init(void) {

  real_local_sdk_video_set_encode_frame_callback = dlsym(dlopen("/system/lib/liblocalsdk.so", RTLD_LAZY), "local_sdk_video_set_encode_frame_callback");
}
