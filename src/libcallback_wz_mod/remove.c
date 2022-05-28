#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

static int (*original_remove)(const char *pathname);
static const char *HookPath = "/media/mmc/time_lapse/.setup";
extern char TimeLapsePath[256];

static void __attribute ((constructor)) remove_hook_init(void) {

  original_remove = dlsym(dlopen ("/lib/libc.so.0", RTLD_LAZY), "remove");
}

int remove(const char *pathname) {

  if(!strncmp(pathname, HookPath, strlen(HookPath))) printf("[webhook] time_lapse_finish %s\n", TimeLapsePath);
  return original_remove(pathname);
}


