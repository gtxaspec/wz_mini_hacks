#include <stdio.h>

static void __attribute ((constructor)) setStdoutLineBuffer(void) {
  setvbuf(stdout, NULL, _IOLBF, 0);
}
