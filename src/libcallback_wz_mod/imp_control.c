#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

extern int IMP_AI_DisableHpf();
extern int IMP_AI_DisableAgc();
extern int IMP_AI_DisableNs();
extern int IMP_AI_DisableAec();
extern int IMP_AI_EnableHpf();
extern int IMP_AI_EnableAgc();
extern int IMP_AI_EnableNs();
extern int IMP_AI_EnableAec();
extern int IMP_AI_SetVol();
extern int IMP_AI_SetGain();
extern int IMP_AI_SetAlcGain();

extern int IMP_AO_SetVol();
extern int IMP_AO_SetGain();

extern void set_video_max_fps();
extern void set_video_frame_rate();
extern void paracfg_set_user_config_item();
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
extern int IMP_ISP_Tuning_SetDPStrength();
extern int IMP_ISP_Tuning_SetISPHflip();
extern int IMP_ISP_Tuning_SetISPVflip();

extern void CommandResponse(int fd, const char *res);

const char *productv2="/driver/sensor_jxf23.ko";

char *imp_Control(int fd, char *tokenPtr) {

//Audio
int devID = 1;
int chnID = 0;
int AO_devID = 0;
int AO_chnID = 0;
int ai_vol;
int ai_gain;
int alc_gain;
int ao_gain;
int ao_vol;

//Video
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
int dps_val;

//FPS
int encChn = 0;
int encChn1 = 1;
int fps_den = 1;

  char *p = strtok_r(NULL, " \t\r\n", &tokenPtr);
  if(!p) return "Please refer to the documentation for valid imp_control commands.";
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
  } else if(!strcmp(p, "ai_vol")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) ai_vol = atoi(p);
	IMP_AI_SetVol(devID,chnID,ai_vol);
  } else if(!strcmp(p, "ai_gain")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) ai_gain = atoi(p);
	IMP_AI_SetGain(devID,chnID,ai_gain);
  } else if(!strcmp(p, "alc_gain")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) alc_gain = atoi(p);
	IMP_AI_SetAlcGain(devID,chnID,alc_gain);
  } else if(!strcmp(p, "ao_gain")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) ao_gain = atoi(p);
	IMP_AO_SetGain(AO_devID,AO_chnID,ao_gain);
  } else if(!strcmp(p, "ao_vol")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) ao_vol = atoi(p);
	IMP_AO_SetVol(AO_devID,AO_chnID,ao_vol);
  } else if(!strcmp(p, "flip_mirror")) {
	IMP_ISP_EnableTuning();
	if( access( productv2, F_OK ) != -1 ) {
		IMP_ISP_Tuning_SetISPHflip(0);
		IMP_ISP_Tuning_SetISPVflip(0);
	} else {
		IMP_ISP_Tuning_SetHVFLIP(0);
	}
  } else if(!strcmp(p, "flip_vertical")) {
	IMP_ISP_EnableTuning();
 	if( access( productv2, F_OK ) != -1 ) {
		IMP_ISP_Tuning_SetISPVflip(0);
	} else {
		IMP_ISP_Tuning_SetHVFLIP(1);
	}
  } else if(!strcmp(p, "flip_horizontal")) {
	IMP_ISP_EnableTuning();
	if( access( productv2, F_OK ) != -1 ) {
		IMP_ISP_Tuning_SetISPHflip(0);
	} else {
		IMP_ISP_Tuning_SetHVFLIP(2);
	}
  } else if(!strcmp(p, "flip_normal")) {
	IMP_ISP_EnableTuning();
	if( access( productv2, F_OK ) != -1 ) {
		IMP_ISP_Tuning_SetISPHflip(1);
		IMP_ISP_Tuning_SetISPVflip(1);
	} else {
		IMP_ISP_Tuning_SetHVFLIP(3);
	}
  } else if(!strcmp(p, "fps_set")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) fps_val = atoi(p);

	IMP_ISP_EnableTuning();
	IMP_ISP_Tuning_SetSensorFPS(fps_val, fps_den);

	//encoder framerate failed
//	paracfg_set_user_config_item(5,fps_val);

//	set_fs_chn_config_fps(encChn, fps_val);
//	set_fs_chn_config_fps(encChn1, fps_val);

//	set_video_max_fps(fps_val);
//	local_sdk_video_set_fps(fps_val);

//	local_sdk_video_set_gop(encChn, fps_val);

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
	if( access( productv2, F_OK ) != -1 ) {
		return "not supported on v2";
	} else {
		IMP_ISP_EnableTuning();
		IMP_ISP_Tuning_SetAe_IT_MAX(aeitmax_val);
	}

  } else if(!strcmp(p, "tune_dpc_strength")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) dpc_val = atoi(p);
	if( access( productv2, F_OK ) != -1 ) {
		return "not supported on v2";
	} else {
		IMP_ISP_EnableTuning();
		IMP_ISP_Tuning_SetDPC_Strength(dpc_val);
	}

  } else if(!strcmp(p, "tune_drc_strength")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) drc_val = atoi(p);
	if( access( productv2, F_OK ) != -1 ) {
		return "not supported on v2";
	} else {
		IMP_ISP_EnableTuning();
		IMP_ISP_Tuning_SetDRC_Strength(drc_val);
	}

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
	if( access( productv2, F_OK ) != -1 ) {
		return "not supported on v2";
	} else {
		IMP_ISP_EnableTuning();
		IMP_ISP_Tuning_SetBacklightComp(bcomp_val);
	}

  } else if(!strcmp(p, "tune_dps")) {
        p = strtok_r(NULL, " \t\r\n", &tokenPtr);
        if(p) dps_val = atoi(p);
	if( access( productv2, F_OK ) != -1 ) {
		IMP_ISP_EnableTuning();
		IMP_ISP_Tuning_SetDPStrength(dps_val);
	} else {
		return "not supported on v3";
	}
} else {
    return "error";
  }
  return "ok";

}
