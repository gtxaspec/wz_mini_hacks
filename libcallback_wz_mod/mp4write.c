#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

static int (*original_mp4write_start_handler)(void *handler, char *file, void *config);

static int mp4WriteEnable = 0;

char *mp4Write(int fd, char *tokenPtr) {

  char *p = strtok_r(NULL, " \t\r\n", &tokenPtr);
  if(!p) return mp4WriteEnable ? "on" : "off";
  if(!strcmp(p, "on")) {
    mp4WriteEnable = 1;
    fprintf(stderr, "[command] mp4write on\n", p);
    return "ok";
  }
  if(!strcmp(p, "off")) {
    mp4WriteEnable = 0;
    fprintf(stderr, "[command] mp4write off\n", p);
    return "ok";
  }
  return "error in mp4write.c";
}

int mp4write_start_handler(void *handler, char *file, void *config) {

if(mp4WriteEnable) {

struct stat st = {0};

  if(!strncmp(file, "/tmp/", 5)) {
    char buf[64];
    strncpy(buf, file + 5, 30);
    if (stat("/media/mmc/record/tmp", &st) == -1) {
      mkdir("/media/mmc/record/tmp", 0700);
    }
    strcpy(file, "/media/mmc/record/tmp/");
    strcat(file, buf);
  }
}
  return (original_mp4write_start_handler)(handler, file, config);
}
static void __attribute ((constructor)) mp4write_init(void) {

  original_mp4write_start_handler = dlsym(dlopen("/system/lib/libmp4rw.so", RTLD_LAZY), "mp4write_start_handler");
}
