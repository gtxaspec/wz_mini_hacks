#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

extern void local_sdk_speaker_set_pa_mode(int mode);
extern void local_sdk_speaker_set_ap_mode(int mode);
extern void local_sdk_speaker_clean_buf_data();
extern void local_sdk_speaker_set_volume(int volume);
extern int local_sdk_speaker_feed_pcm_data(unsigned char *buf, int size);
extern void local_sdk_speaker_finish_buf_data();
extern void CommandResponse(int fd, const char *res);

static pthread_mutex_t AudioPlayMutex = PTHREAD_MUTEX_INITIALIZER;
static int AudioPlayFd = -1;
static char waveFile[256];
static int Volume = 0;

int PlayPCM(char *file, int vol) {

  static const int waveHeaderLength = 44;
  static const int bufLength = 640;
  unsigned char buf[bufLength];
  const unsigned char cmp[] = {
    0x52, 0x49, 0x46, 0x46, 0x00, 0x00, 0x00, 0x00, 0x57, 0x41, 0x56, 0x45, 0x66, 0x6d, 0x74, 0x20,
    0x10, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x40, 0x1f, 0x00, 0x00, 0x80, 0x3e, 0x00, 0x00,
    0x02, 0x00, 0x10, 0x00, 0x64, 0x61, 0x74, 0x61
  };

  fprintf(stderr, "[command] aplay: file:%s\n", file);
  FILE *fp = fopen(file, "rb");
  if(fp == NULL) {
    fprintf(stderr, "[command] aplay err: fopen %s failed!\n", file);
    return -1;
  } else {
    size_t size = fread(buf, 1, waveHeaderLength, fp);
    if(size != waveHeaderLength) {
      fprintf(stderr, "[command] aplay err: header size error\n");
    }
    buf[4] = buf[5] = buf[6] = buf[7] = 0;
    if(memcmp(buf, cmp, waveHeaderLength - 4)) {
      fprintf(stderr, "[command] aplay err: header error\n");
    }
    local_sdk_speaker_clean_buf_data();
    local_sdk_speaker_set_volume(vol);

 if(!local_sdk_speaker_set_pa_mode) {
    local_sdk_speaker_set_ap_mode(3);
      fprintf(stderr, "[command] aplay: set ap mode 3\n");
  }

 if(!local_sdk_speaker_set_ap_mode) {
    local_sdk_speaker_set_pa_mode(3);
      fprintf(stderr, "[command] aplay: set pa mode 3\n");
  }



    while(!feof(fp)) {
      size = fread(buf, 1, bufLength, fp);
      if (size <= 0) break;
      while(local_sdk_speaker_feed_pcm_data(buf, size)) usleep(100 * 1000);
    }
    fclose(fp);
    usleep(2 * 1000 * 1000);
    local_sdk_speaker_finish_buf_data();
    local_sdk_speaker_set_volume(0);

 if(!local_sdk_speaker_set_pa_mode) {
    local_sdk_speaker_set_ap_mode(0);
  }
 if(!local_sdk_speaker_set_ap_mode) {
    local_sdk_speaker_set_pa_mode(0);
  }

  }
  fprintf(stderr, "[command] aplay: finish\n");
  return 0;
}

static void *AudioPlayThread() {

  while(1) {
    pthread_mutex_lock(&AudioPlayMutex);
    if(AudioPlayFd >= 0) {
      int res = PlayPCM(waveFile, Volume);
      CommandResponse(AudioPlayFd, res ? "error" : "ok");
    }
    AudioPlayFd = -1;
  }
}

char *AudioPlay(int fd, char *tokenPtr) {

  if(AudioPlayFd >= 0) {
    fprintf(stderr, "[command] aplay err: Previous file is still playing. %d %d\n", AudioPlayFd, fd);
    return "error";
  }

  char *p = strtok_r(NULL, " \t\r\n", &tokenPtr);
  if(!p) {
    fprintf(stderr, "[command] aplay err: usage : aplay <wave file> [<volume>]\n");
    return "error";
  }
  strncpy(waveFile, p, 255);

  p = strtok_r(NULL, " \t\r\n", &tokenPtr);
  Volume = 40;
  if(p) Volume = atoi(p);

  AudioPlayFd = fd;
  pthread_mutex_unlock(&AudioPlayMutex);
  return NULL;
}

static void __attribute ((constructor)) AudioPlayInit(void) {

  pthread_mutex_lock(&AudioPlayMutex);
  pthread_t thread;
  if(pthread_create(&thread, NULL, AudioPlayThread, NULL)) {
    fprintf(stderr, "pthread_create error\n");
    pthread_mutex_unlock(&AudioPlayMutex);
    return;
  }
}
