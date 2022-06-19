#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>

static uint32_t (*real_local_sdk_video_set_fps)(int encChn);

int local_sdk_video_set_fps(int encChn) {

        fprintf(stderr, "[command] [night_drop.c] local_sdk_video_set_fps called with fps value: %d\n", encChn);

        const char *nd_enable="/opt/wz_mini/tmp/.nd";
        const char *product_T31="/opt/wz_mini/tmp/.T31";
        const char *product_T20="/opt/wz_mini/tmp/.T20";

        if( access( nd_enable, F_OK ) != -1 ) {
                printf("[command] [night_drop.c] Night Drop Enabled\n");
        if( encChn == 15 && access( product_T31, F_OK ) != -1 ) {
                printf("[command] [night_drop.c] T31 detected\n");
                fprintf(stderr, "[command] [night_drop.c] Night Time Requested FPS Drop Value: %d\n", encChn);
                printf("[command] [night_drop.c] Night FPS Drop Stopped\n");
        } else if ( encChn >= 15 && access( product_T20, F_OK ) != -1 ) {
                printf("[command] [night_drop.c] T20 detected\n");
                fprintf(stderr, "[command] [night_drop.c] Night Time Requested FPS Drop Value: %d\n", encChn);
                printf("[command] [night_drop.c] Night FPS Drop Stopped\n");
        } else {
                fprintf(stderr, "[command] [night_drop.c] Requested FPS Value: %d\n", encChn);
                fprintf(stderr, "[command] [night_drop.c] Calling local_sdk_video_set_fps to: %d\n", encChn);
                real_local_sdk_video_set_fps(encChn);
        }
	//If nd is disabled, pass all requests along
	} else {
	        printf("[command] [night_drop.c] Night Drop not enabled\n");
                fprintf(stderr, "[command] [night_drop.c] Requested FPS Value: %d\n", encChn);
                fprintf(stderr, "[command] [night_drop.c] Calling local_sdk_video_set_fps to: %d\n", encChn);
                real_local_sdk_video_set_fps(encChn);
	}
}


static void __attribute ((constructor)) night_drop_init(void) {
  real_local_sdk_video_set_fps = dlsym(dlopen("/system/lib/liblocalsdk.so", RTLD_LAZY), "local_sdk_video_set_fps");
}
