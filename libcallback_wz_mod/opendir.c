#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <sys/types.h>
#include <dirent.h>

static DIR * (*original_opendir)(const char *pathname);
static const char *HookPath = "/media/mmc/time_lapse/time_Task_";
static const char *MediaPath = "/media/mmc/";
char TimeLapsePath[256];

static void __attribute ((constructor)) opendir_hook_init(void) {

  original_opendir = dlsym(dlopen ("/lib/libc.so.0", RTLD_LAZY), "opendir");
}

DIR *opendir(const char *pathname) {

  if(!strncmp(pathname, HookPath, strlen(HookPath))) {
    strncpy(TimeLapsePath, pathname + strlen(MediaPath), 255);
    printf("[webhook] time_lapse_event %s\n", TimeLapsePath);
  }
  return original_opendir(pathname);
}
