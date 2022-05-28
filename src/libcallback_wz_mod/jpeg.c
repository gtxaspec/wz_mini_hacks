#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

struct channelConfigSt {
  uint dummy[4];
  int state;
  int encoder;
};
extern struct channelConfigSt *get_enc_chn_config(int ch);
extern int get_video_run_state(int ch);
extern void video_param_set_mutex_lock();
extern int IMP_Encoder_StartRecvPic(int ch);
extern int IMP_Encoder_PollingStream(int ch, int timeoutMSec);
extern int IMP_Encoder_GetStream(int ch, uint *stream, int);
extern int IMP_Encoder_ReleaseStream(int ch, int *stream);
extern int IMP_Encoder_StopRecvPic(int ch);
extern int save_jpeg(int fd, int *stream);
extern void video_param_set_mutex_unlock();
extern void CommandResponse(int fd, const char *res);

static const char *HttpResHeader = "Cache-Control: no-cache\nContent-Type: image/jpeg\n\n";
static const char *HttpErrorHeader = "Cache-Control: no-cache\nStatus: 503\n\n";
static pthread_mutex_t JpegDataMutex = PTHREAD_MUTEX_INITIALIZER;
static int JpegCaptureFd = -1;

char *JpegCapture(int fd, char *tokenPtr) {

  if(JpegCaptureFd >= 0) {
    fprintf(stderr, "[command] jpeg capture error %d %d\n", JpegCaptureFd, fd);
    write(fd, HttpErrorHeader, strlen(HttpErrorHeader));
    CommandResponse(fd, "error : jpeg capture error");
    return NULL;
  }
  JpegCaptureFd = fd;
  pthread_mutex_unlock(&JpegDataMutex);
  return NULL;
}

static int GetJpegData(int fd) {

  struct channelConfigSt *chConfig = get_enc_chn_config(0);
  if (!chConfig->state) {
    fprintf(stderr, "[command] jpeg err: ch0 is not enable jpeg!\n");
    return -1;
  }
  int state = get_video_run_state(0);
  if (state < 5) {
    fprintf(stderr, "[command] jpeg err: U should call 'video_run' before this func\n");
    return -1;
  }

  video_param_set_mutex_lock(1);
  int encoder = chConfig->encoder;
  int ret = 0;

  if(IMP_Encoder_StartRecvPic(encoder) < 0) {
    fprintf(stderr, "[command] jpeg err: IMP_Encoder_StartRecvPic(%d) failed\n", encoder);
    ret = -1;
    goto error1;
  }

  if(IMP_Encoder_PollingStream(encoder, 2000) < 0) {
    fprintf(stderr, "[command] jpeg err: Polling stream(chn%d) timeout\n", encoder);
    ret = -1;
    goto error2;
  }

  uint stream[17];
  memset(stream, 0, 60);
  if(IMP_Encoder_GetStream(encoder, stream, 1) < 0) {
    fprintf(stderr, "[command] jpeg err: IMP_Encoder_GetStream(chn%d) failed\n", encoder);
    ret = -1;
    goto error2;
  }

  write(JpegCaptureFd, HttpResHeader, strlen(HttpResHeader));
  if(save_jpeg(fd, stream) < 0) {
    fprintf(stderr, "[command] jpeg err: save_jpeg(%d) failed\n", fd);
    ret = -2;
  }
  IMP_Encoder_ReleaseStream(encoder, stream);

error2:
  if(IMP_Encoder_StopRecvPic(encoder) < 0) {
    fprintf(stderr, "[command] jpeg err: IMP_Encoder_StopRecvPic(chn%d) failed\n", encoder);
  }

error1:
  video_param_set_mutex_unlock(1);
  if(ret == -1) write(JpegCaptureFd, HttpErrorHeader, strlen(HttpErrorHeader));
  return ret;
}

static void *JpegCaptureThread() {

  while(1) {
    pthread_mutex_lock(&JpegDataMutex);
    if(JpegCaptureFd >= 0) {
      int res = GetJpegData(JpegCaptureFd);
      CommandResponse(JpegCaptureFd, res >= 0 ? "" : "error : buffer size error");
    }
    JpegCaptureFd = -1;
  }
}

static void __attribute ((constructor)) JpegInit(void) {

  pthread_mutex_lock(&JpegDataMutex);
  pthread_t thread;
  if(pthread_create(&thread, NULL, JpegCaptureThread, NULL)) {
    fprintf(stderr, "pthread_create error\n");
    pthread_mutex_unlock(&JpegDataMutex);
    return;
  }
}
