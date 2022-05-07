#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <string.h>
#include <sys/time.h>
#include <pthread.h>
#include <errno.h>
#include <math.h>

extern void CommandResponse(int fd, const char *res);
extern int local_sdk_motor_get_position(float *step,float *angle);
extern int MotorFd;
extern struct timeval MotorLastMovedTime;

struct RectInfoSt {
  int left;
  int right;
  int top;
  int bottom;
  int dummy1;
  int dummt2;
};

static int (*original_local_sdk_video_osd_update_rect)(int ch, int display, struct RectInfoSt *rectInfo);
static int WaitMotionFd = -1;
static int Timeout = -1;
static pthread_mutex_t WaitMotionMutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t WaitMotionCond = PTHREAD_COND_INITIALIZER;

char *WaitMotion(int fd, char *tokenPtr) {

  if(WaitMotionFd >= 0) {
    fprintf(stderr, "[command] wait motion error %d %d\n", WaitMotionFd, fd);
    return "error : wait motion error";
  }
  char *p = strtok_r(NULL, " \t\r\n", &tokenPtr);
  Timeout = p ? atoi(p) : 0;
  if(Timeout < 10) {
    fprintf(stderr, "[command] wait motion timeout error timeout = %d\n", Timeout);
    return "error : wait motion timeout value error";
  }

  WaitMotionFd = fd;
  pthread_mutex_unlock(&WaitMotionMutex);
  return NULL;
}

int local_sdk_video_osd_update_rect(int ch, int display, struct RectInfoSt *rectInfo) {

  if((WaitMotionFd >= 0) && (MotorFd <= 0) && !ch) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    timersub(&tv, &MotorLastMovedTime, &tv);
    if(tv.tv_sec || (tv.tv_usec >= 500000)) {
      if(display) {
        float pan; // 0-355
        float tilt; // 0-180
        int ret = local_sdk_motor_get_position(&pan, &tilt);
        static char waitMotionResBuf[256];
        if(!ret) {
          pan += (rectInfo->left + rectInfo->right - 320 * 2) * 85 / (2 * 640);
          if(pan < 0.0) pan = 0.0;
          if(pan > 355.0) pan = 355;
          tilt -= (rectInfo->top + rectInfo->bottom - 180 * 2) * 55 / (2 * 360);
          if(tilt < 45.0) tilt = 45.0;
          if(tilt > 180.0) tilt = 180.0;
          sprintf(waitMotionResBuf, "detect %d %d %d %d %d %d\n",
            rectInfo->left, rectInfo->right, rectInfo->top, rectInfo->bottom, lroundf(pan), lroundf(tilt));
        } else {
          sprintf(waitMotionResBuf, "detect %d %d %d %d - -\n",
            rectInfo->left, rectInfo->right, rectInfo->top, rectInfo->bottom);
        }
        CommandResponse(WaitMotionFd, waitMotionResBuf);
      } else {
        CommandResponse(WaitMotionFd, "clear\n");
      }
      pthread_cond_signal(&WaitMotionCond);
    }
  }
  return original_local_sdk_video_osd_update_rect(ch, display, rectInfo);
}

static void *WaitMotionThread() {

  while(1) {
    pthread_mutex_lock(&WaitMotionMutex);
    if(WaitMotionFd >= 0) {
      struct timeval now;
      struct timespec timeout;
      gettimeofday(&now, NULL);
      timeout.tv_sec = now.tv_sec + Timeout;
      timeout.tv_nsec = now.tv_usec * 1000;
      int ret = pthread_cond_timedwait(&WaitMotionCond, &WaitMotionMutex, &timeout);
      if(ret == ETIMEDOUT) CommandResponse(WaitMotionFd, "timeout\n");
    }
    WaitMotionFd = -1;
  }
}

static void __attribute ((constructor)) osd_rect_hook_init(void) {

  original_local_sdk_video_osd_update_rect = dlsym(dlopen ("/system/lib/liblocalsdk.so", RTLD_LAZY), "local_sdk_video_osd_update_rect");

  pthread_mutex_lock(&WaitMotionMutex);
  pthread_t thread;
  if(pthread_create(&thread, NULL, WaitMotionThread, NULL)) {
    fprintf(stderr, "pthread_create error\n");
    pthread_mutex_unlock(&WaitMotionMutex);
    return;
  }
}
