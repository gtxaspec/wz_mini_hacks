#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <tinyalsa/pcm.h>

struct frames_st {
  void *buf;
  size_t length;
};
typedef int (* framecb)(struct frames_st *);

static uint32_t (*real_local_sdk_audio_set_pcm_frame_callback)(int ch, void *callback);
static void *audio_pcm_cb = NULL;
static int AudioCaptureEnable = 0;

static void *audio_pcm_cb1 = NULL;
static int AudioCaptureEnable1 = 0;

char *AudioCapture(int fd, char *tokenPtr) {

  char *p = strtok_r(NULL, " \t\r\n", &tokenPtr);
  if(!p) return AudioCaptureEnable ? "on" : "off";
  if(!strcmp(p, "on")) {
    AudioCaptureEnable = 1;
    fprintf(stderr, "[command] audio capute on\n", p);
    return "ok";
  }
  if(!strcmp(p, "on1")) {
    AudioCaptureEnable1 = 1;
    fprintf(stderr, "[command] audio capute on\n", p);
    return "ok";
  }
  if(!strcmp(p, "off")) {
    AudioCaptureEnable = 0;
    fprintf(stderr, "[command] audio capute off\n", p);
    return "ok";
  }
  if(!strcmp(p, "off1")) {
    AudioCaptureEnable1 = 0;
    fprintf(stderr, "[command] audio capute off\n", p);
    return "ok";
  }
  return "error";
}

//channel 0
static uint32_t audio_pcm_capture(struct frames_st *frames) {

  static struct pcm *pcm = NULL;
  static int firstEntry = 0;
  uint32_t *buf = frames->buf;

  static int snd_rate = 16000;
  const char *productv2="/driver/sensor_jxf23.ko";

    //Change sample rate to 8000 if we are a V2 Camera
    if( access( productv2, F_OK ) == 0 ) {
      snd_rate = 8000;
      }


  if(!firstEntry) {
    firstEntry++;
    unsigned int card = 0;
    unsigned int device = 1;
    int flags = PCM_OUT | PCM_MMAP;
    const struct pcm_config config = {
      .channels = 1,
      .rate = snd_rate,
      .format = PCM_FORMAT_S16_LE,
      .period_size = 128,
      .period_count = 8,
      .start_threshold = 320,
      .silence_threshold = 0,
      .silence_size = 0,
      .stop_threshold = 320 * 4
    };
    pcm = pcm_open(card, device, flags, &config);
    if(pcm == NULL) {
        fprintf(stderr, "failed to allocate memory for PCM CH0\n");
    } else if(!pcm_is_ready(pcm)) {
      pcm_close(pcm);
      fprintf(stderr, "failed to open PCM CH0\n");
    }
  }

  if(pcm && AudioCaptureEnable) {
    int avail = pcm_mmap_avail(pcm);
    int delay = pcm_get_delay(pcm);
    int ready = pcm_is_ready(pcm);
    int err = pcm_writei(pcm, buf, pcm_bytes_to_frames(pcm, frames->length));
    if(err < 0) fprintf(stderr, "pcm_writei err=%d\n", err);
  }
  return ((framecb)audio_pcm_cb)(frames);
}

//channel1
static uint32_t audio_pcm_capture1(struct frames_st *frames) {

  static struct pcm *pcm = NULL;
  static int firstEntry = 0;
  uint32_t *buf = frames->buf;

  if(!firstEntry) {
    firstEntry++;
    unsigned int card = 0;
    unsigned int device = 0;
    int flags = PCM_OUT | PCM_MMAP;
    const struct pcm_config config = {
      .channels = 1,
      .rate = 8000,
      .format = PCM_FORMAT_S16_LE,
      .period_size = 128,
      .period_count = 8,
      .start_threshold = 320,
      .silence_threshold = 0,
      .silence_size = 0,
      .stop_threshold = 320 * 4
    };
    pcm = pcm_open(card, device, flags, &config);
    if(pcm == NULL) {
        fprintf(stderr, "failed to allocate memory for PCM CH1\n");
    } else if(!pcm_is_ready(pcm)) {
      pcm_close(pcm);
      fprintf(stderr, "failed to open PCM CH1\n");
    }
  }

  if(pcm && AudioCaptureEnable1) {
    int avail = pcm_mmap_avail(pcm);
    int delay = pcm_get_delay(pcm);
    int ready = pcm_is_ready(pcm);
    int err = pcm_writei(pcm, buf, pcm_bytes_to_frames(pcm, frames->length));
    if(err < 0) fprintf(stderr, "pcm_writei err=%d\n", err);
  }
  return ((framecb)audio_pcm_cb1)(frames);
}

uint32_t local_sdk_audio_set_pcm_frame_callback(int ch, void *callback) {

  fprintf(stderr, "local_sdk_audio_set_pcm_frame_callback streamChId=%d, callback=0x%x\n", ch, callback);

  static int ch_count = 0;

  if( (ch == 0) && ch_count == 0) {
    audio_pcm_cb = callback;
    fprintf(stderr,"enc func injection CH0 save audio_pcm_cb=0x%x\n", audio_pcm_cb);
    callback = audio_pcm_capture;
  }

  if( (ch == 1) && ch_count == 1) {
    audio_pcm_cb1 = callback;
    fprintf(stderr,"enc func injection CH1 save audio_pcm_cb=0x%x\n", audio_pcm_cb1);
    callback = audio_pcm_capture1;
  }

//if V2 here, we have to latch on to the same callback as CH0, since the V2's only have one audio callback
 const char *productv2="/driver/sensor_jxf23.ko";
 if( access( productv2, F_OK ) == 0 ) {
  if( (ch == 0) && ch_count == 1) {
    audio_pcm_cb1 = callback;
    fprintf(stderr,"enc func injection CH0 second callback for V2 save audio_pcm_cb=0x%x\n", audio_pcm_cb1);
    callback = audio_pcm_capture1;
  }
}
  ch_count=ch_count+1;

  return real_local_sdk_audio_set_pcm_frame_callback(ch, callback);
}

static void __attribute ((constructor)) audio_callback_init(void) {

  real_local_sdk_audio_set_pcm_frame_callback = dlsym(dlopen("/system/lib/liblocalsdk.so", RTLD_LAZY), "local_sdk_audio_set_pcm_frame_callback");
}
