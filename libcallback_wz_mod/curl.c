#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

typedef void CURL;
typedef int CURLcode;
typedef long long curl_off_t;
typedef enum {
  HTTPREQ_NONE,
  HTTPREQ_GET,
  HTTPREQ_POST,
  HTTPREQ_POST_FORM,
  HTTPREQ_POST_MIME,
  HTTPREQ_PUT,
  HTTPREQ_HEAD,
  HTTPREQ_OPTIONS,
  HTTPREQ_LAST
} Curl_HttpReq;

static const int CURL_OK = 0;
const char *methods[] = {
  "NONE", "GET", "POST", "POST_FORM", "POST_MIME", "PUT", "HEAD", "OPTIONS", "LAST", ""
};
static const char *AlarmPath = "/device/v1/alarm/add";
static const char *DummyRes = "{\"ts\":1641390551000,\"code\":\"1\",\"msg\":\"\",\"data\":{\"alarm_file_list\":[{\"file_type\":1,\"file_suffix\":\"jpg\",\"file_url\":\"https://localhost/hoge.jpg\",\"encryption_algorithm\":0,\"encryption_password\":\"\"},{\"file_type\":2,\"file_suffix\":\"mp4\",\"file_url\":\"https://localhost/fuga.mp4\",\"encryption_algorithm\":0,\"encryption_password\":\"\"}]}}";
static const char *DummyHost = "https://localhost/";

typedef int (*curl_seek_callback)(void *instream, int offset, int origin);
typedef int (*curl_write_callback)(char *buffer, int size, int nitems, void *outstream);

struct SessionHandle {
  unsigned char padding0[1392];
  unsigned char padding1[16];
  void *out; // offset 1392 + 16
  unsigned char padding2[40];
  void *postfields; // offset 1392 + 60
  unsigned char padding3[8];
  curl_off_t postfieldsize; // offset offset 1392 + 72
  unsigned char padding4[8];
  curl_write_callback fwrite_func; // offset 1392 + 88
  unsigned char padding5[568];
  Curl_HttpReq httpreq; // offset 1392 + 660
  unsigned char padding6[664];
  char *url; // offset 2720 + 0
  unsigned char padding7[16];
  unsigned char padding8[988];
  int httpcode; // offset 3728 + 0
};

static CURLcode (*original_curl_easy_perform)(CURL *curl);
static int curl_hook_enable = 0;

static void __attribute ((constructor)) curl_hook_init(void) {
  original_curl_easy_perform = dlsym(dlopen("/thirdlib/libcurl.so", RTLD_LAZY), "curl_easy_perform");
  char *p = getenv("MINIMIZE_ALARM_CYCLE");
  curl_hook_enable = p && !strcmp(p, "on");
}

static void Dump(const char *str, void *start, int size) {
  printf("[curl-debug] Dump %s\n", str);
  for(int i = 0; i < size; i+= 16) {
    char buf1[256];
    char buf2[256];
    sprintf(buf1, "%08x : ", start + i);
    for(int j = 0; j < 16; j++) {
      if(i + j >= size) break;
      unsigned char d = ((unsigned char *)start)[i + j];
      sprintf(buf1 + strlen(buf1), "%02x ", d);
      if((d < 0x20) || (d > 0x7f)) d = '.';
      sprintf(buf2 + j, "%c", d);
    }
    printf("%s %s\n", buf1, buf2);
  }
}

CURLcode curl_easy_perform(struct SessionHandle *data) {

  if(!curl_hook_enable) return original_curl_easy_perform(data);

  unsigned int ra = 0;
  asm volatile(
    "ori %0, $31, 0\n"
    : "=r"(ra)
  );

  int method = data->httpreq;
  if(method > HTTPREQ_LAST) method = HTTPREQ_LAST;
  printf("[curl-debug] %s %s ra=0x%08x\n", methods[method], data->url, ra);
  if(data->postfields) {
    if(data->postfieldsize > 0) {
      Dump("[curl-debug] post", data->postfields, data->postfieldsize);
    } else {
      printf("[curl-debug] post : %s\n", data->postfields);
    }
  }

  if(data->url && !strcmp(data->url + strlen(data->url) - strlen(AlarmPath), AlarmPath)) {
    static time_t lastAccess = 0;
    struct timeval now;
    gettimeofday(&now, NULL);
    if(now.tv_sec - lastAccess < 300) {
      printf("[curl-debug] Dismiss short cycle alarms.\n");
      memcpy(data->out, DummyRes, strlen(DummyRes));
      data->httpcode = 200;
      return CURL_OK;
    }
    CURLcode res = original_curl_easy_perform(data);
    printf("[curl-debug] res=%d\n", res);
    if(!res) lastAccess = now.tv_sec;
    return res;
  }

  if(data->url && !strncmp(data->url, DummyHost, strlen(DummyHost))) {
    printf("[curl-debug] skip http-post.\n");
    data->httpcode = 200;
    return CURL_OK;
  }

  CURLcode res = original_curl_easy_perform(data);
  if(data->out) printf("[curl-debug] res : %s\n", data->out);
  printf("[curl-debug] ret: %d\n", res);
  return res;
}
