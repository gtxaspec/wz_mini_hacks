#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int IMP_AI_DisableHpf();
extern int IMP_AI_DisableAgc();
extern int IMP_AI_DisableNs();
extern int IMP_AI_DisableAec();

extern int IMP_AI_EnableHpf();
extern int IMP_AI_EnableAgc();
extern int IMP_AI_EnableNs();
extern int IMP_AI_EnableAec();

extern void set_video_max_fps();

extern void set_fs_chn_config_fps();

extern void local_sdk_video_init();
extern void local_sdk_video_set_fps();
extern void local_sdk_video_set_gop();

extern void IMP_ISP_EnableTuning();

extern void IMP_ISP_Tuning_SetSensorFPS();

extern int IMP_ISP_Tuning_SetHVFLIP();
extern int IMP_ISP_Tuning_SetContrast();
extern int IMP_ISP_Tuning_SetBrightness();
extern int IMP_ISP_Tuning_SetSaturation();
extern int IMP_ISP_Tuning_SetSharpness();
extern int IMP_ISP_Tuning_SetAeComp();
extern int IMP_ISP_Tuning_SetAe_IT_MAX();
extern int IMP_ISP_Tuning_SetDPC_Strength();
extern int IMP_ISP_Tuning_SetDRC_Strength();
extern int IMP_ISP_Tuning_SetHiLightDepress();
extern int IMP_ISP_Tuning_SetTemperStrength();
extern int IMP_ISP_Tuning_SetSinterStrength();
extern int IMP_ISP_Tuning_SetMaxAgain();
extern int IMP_ISP_Tuning_SetMaxDgain();
extern int IMP_ISP_Tuning_SetBacklightComp();

extern void CommandResponse(int fd, const char *res);



char *imp_Control(int fd, char *tokenPtr) {

int devID = 0;
int chnID = 1;
int fps_val;
int con_val;
int bright_val;
int sharp_val;
int satur_val;
int aecomp_val;
int aeitmax_val;
int dpc_val;
int drc_val;
int depress_val;
int temper_val;
int sinter_val;
int bcomp_val;
int again_val;
int dgain_val;

int encChn = 0;
int fps_den = 1;
int frmRateNum = 30;
int frmRateDen = 1;

  char *p = strtok_r(NULL, " \t\r\n", &tokenPtr);
  if(!p) return "error";
  if(!strcmp(p, "agc_off")) {
   IMP_AI_DisableAgc();
  } else if(!strcmp(p, "agc_on")) {
   IMP_AI_EnableAgc();
  } else if(!strcmp(p, "hpf_off")) {
   IMP_AI_DisableHpf();
  } else if(!strcmp(p, "hpf_on")) {
   IMP_AI_EnableHpf();
  } else if(!strcmp(p, "ns_off")) {
   IMP_AI_DisableNs();
  } else if(!strcmp(p, "ns_on")) {
   IMP_AI_EnableNs();
  } else if(!strcmp(p, "aec_off")) {
   IMP_AI_DisableAec(devID, chnID);
  } else if(!strcmp(p, "aec_on")) {
   IMP_AI_EnableAec();
  } else if(!strcmp(p, "flip_mirror")) {
	IMP_ISP_Tuning_SetHVFLIP(0);
  } else if(!strcmp(p, "flip_vertical")) {
	IMP_ISP_Tuning_SetHVFLIP(1);
  } else if(!strcmp(p, "flip_horizontal")) {
	IMP_ISP_Tuning_SetHVFLIP(2);
  } else if(!strcmp(p, "flip_normal")) {
	IMP_ISP_Tuning_SetHVFLIP(3);
  } else if(!strcmp(p, "fps_set")) {
	//encoder framerate failed, broken
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
//	fps_val = 20;
        if(p) fps_val = atoi(p);

//	IMP_ISP_EnableTuning();
//	IMP_ISP_Tuning_SetSensorFPS(fps_val, fps_den);

//	set_fs_chn_config_fps(encChn, fps_val);

	set_video_max_fps(fps_val);
	local_sdk_video_set_fps(fps_val);
	local_sdk_video_set_gop(encChn, fps_val);

//	local_sdk_video_init(fps_val);

  } else if(!strcmp(p, "tune_contrast")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) con_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetContrast(con_val);

  } else if(!strcmp(p, "tune_brightness")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) bright_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetBrightness(bright_val);

  } else if(!strcmp(p, "tune_sharpness")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) sharp_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetSharpness(sharp_val);

  } else if(!strcmp(p, "tune_saturation")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) satur_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetSaturation(satur_val);

  } else if(!strcmp(p, "tune_aecomp")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) aecomp_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetAeComp(aecomp_val);

  } else if(!strcmp(p, "tune_aeitmax")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) aeitmax_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetAe_IT_MAX(aeitmax_val);

  } else if(!strcmp(p, "tune_dpc_strength")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) dpc_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetDPC_Strength(dpc_val);

  } else if(!strcmp(p, "tune_drc_strength")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) drc_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetDRC_Strength(drc_val);

  } else if(!strcmp(p, "tune_hilightdepress")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) depress_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetHiLightDepress(depress_val);

  } else if(!strcmp(p, "tune_temper")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) temper_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetTemperStrength(temper_val);

  } else if(!strcmp(p, "tune_sinter")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) sinter_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetSinterStrength(sinter_val);

  } else if(!strcmp(p, "tune_dgain")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) dgain_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetMaxDgain(dgain_val);

  } else if(!strcmp(p, "tune_again")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) again_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetMaxAgain(again_val);

  } else if(!strcmp(p, "tune_backlightcomp")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) bcomp_val = atoi(p);
	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetBacklightComp(bcomp_val);

} else {
    return "error";
  }
  return "ok";

}
