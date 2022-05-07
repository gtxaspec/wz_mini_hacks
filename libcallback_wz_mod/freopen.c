#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

static FILE * (*original_freopen)(const char *pathname, const char *mode, FILE *stream);

static void __attribute ((constructor)) freopen_hook_init(void) {

  original_freopen = dlsym(dlopen ("/lib/libc.so.0", RTLD_LAZY), "freopen");
}

FILE *freopen(const char *pathname, const char *mode, FILE *stream) {

  if(stream == stdout) return stdout;
  return original_freopen(pathname, mode, stream);
}


