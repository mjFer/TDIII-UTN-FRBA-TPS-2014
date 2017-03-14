//http://blockyourid.com/~gbpprorg/guerrilla.net/reference/dsp/prog_dsp.htm

//*************************************************
//si /dev/dsp no se encuentra es que no tiene compatibilidad
// instalar oss-compat:  
//                  apt-get install oss-compat
//luego cargar el modulo snd-pcm-oss:
//		    modprobe snd-pcm-oss


#ifndef SH_ARRAY_H
#define SH_ARRAY_H

#define RATE 44100   /* the sampling rate */
#define SIZE 16      /* sample size: 8 or 16 bits */
#define CHANNELS 2  /* 1 = mono 2 = stereo */

//#define SAMPLE_LENGTH (2048*4)
//#define FRAME_SIZE (SAMPLE_LENGTH*SIZE*CHANNELS/8)

#define TIEMPO_CAPTURA 1/10

#define FRAME_SIZE (RATE *CHANNELS * SIZE /8 * TIEMPO_CAPTURA )

#define AUDIO_CAPTURE_PACKET_N 4

typedef struct audio_frame { unsigned char x[FRAME_SIZE]; } audio_frame;

typedef struct sampleBaseEntry{
  ssize_t readed_blocks;
 //aca agregar otras variables para la shared memory
 audio_frame _sample;
 int timestamp;
 int frameN;
}SampleBaseEntry;

typedef struct shm_packet{
  int iCapture;
  int iRead;
  SampleBaseEntry SBE[AUDIO_CAPTURE_PACKET_N];
}shm_packet;


#endif