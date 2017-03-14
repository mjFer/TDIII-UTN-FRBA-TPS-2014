// *****************************************************************************
// ARCHIVO:	audio_filter.h
// CREADOR:	Fernandez Marcelo Joaquin
// FECHA:	31/10/14
// OTROS: 	UTN - FRBA - TECNICAS DIGITALES III
// 		http://www.intel.com/content/dam/www/public/us/en/documents/
// 	  		white-papers/fir-filter-sse-instructions-paper.pdf
// 
// 		https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html
// ****************************************************************************

#include "sh_audio.h"
#include <stdint.h>

#include <string.h>

/*------------------------------------ funciones auxiliares ---------------------------------------*/
int16_t SaturatingAdd(int16_t a, int16_t b);
void separateChannels(int16_t* out_ch1,int16_t* out_ch2,int16_t* in_buffer,int buffersize);
void joinChannels(int16_t* out_buffer,int16_t* in_ch1,int16_t* in_ch2,int buffersize);


/*------------------------------------ funcion principal ---------------------------------------*/
void AudioDSP(int16_t *input,int16_t *output);
void AudioFilter(int16_t *input,int16_t *output);


/*------------------------------------ Filtrado en C ---------------------------------------*/
//void AudioFilter(char low,char mid, char high,int16_t *input,int16_t *output);
//void AudioFilter(int16_t *input,int16_t *output);
void C_fir_stereo_16bit(int16_t *output,int16_t *input,int buffersize,int16_t *taps,int tapsSize);
void C_fir_mono_16bit(int16_t *output,int16_t *input,int buffersize,int16_t *taps,int tapsSize);


/*------------------------------------ Filtrado en Assembler ---------------------------------------*/
void SIMD_AudioFilter(int16_t *input,int16_t *output);
void asm_fir_16b(int16_t *output,int16_t *input,int buffersize,int16_t *taps,int tapsSize);
//int asm_fir_filter_16_16(int16_t *buf_out, int16_t *buf_in, int bufsize, int16_t *taps, int filter_len);
