// *****************************************************************************
// ARCHIVO:	audio_filter.c
// CREADOR:	Fernandez Marcelo Joaquin
// FECHA:	31/10/14
// OTROS: 	UTN - FRBA - TECNICAS DIGITALES III
// 		http://www.intel.com/content/dam/www/public/us/en/documents/
// 	  		white-papers/fir-filter-sse-instructions-paper.pdf
// 
// 		https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html
// ****************************************************************************

#include "audio_filter.h"

#define SAMPLE_N 	RATE * TIEMPO_CAPTURA		// numero de Samples mono a procesar (recordar que 2 char es 1 canal y los 2 siguientes el otro)
#define FILTER_SIZE	32


//#define USE_C_MONO		//ANDA
//#define USE_C_STEREO		//ANDA
#define USE_ASM_MONO

static int16_t coefs_0_Low[32] =  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
static int16_t coefs_0_Mid[32] =  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
static int16_t coefs_0_High[32] = {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
//static int16_t coefs_0_Low[32] = {1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1};
//static int16_t coefs_0_Mid[32] = {1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1};
//static int16_t coefs_0_High[32] = {1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1};


void C_fir_stereo_16bit(int16_t *output,int16_t *input,int buffersize,int16_t *taps,int tapsSize){
	int16_t ch1 = 0; //canal izquierdo
	int16_t ch2 = 0; //canal derecho
	int j,i;

	for ( j = 0; j < buffersize; j++) {
		ch1 = 0; 
		ch2 = 0; 							// chx = accumulator
		for ( i =0; i < tapsSize; i++){
			ch1 = SaturatingAdd(ch1, taps[i] * input[(i+j)*CHANNELS]);	// input[] = input values	
			ch2 = SaturatingAdd(ch2, taps[i] * input[(i+j)*CHANNELS +1] );	//coefs_0_Low[] = filter coefficients
			//ch1 += coefs_0_High[i] * input[(i+j)*CHANNELS]; 	// input[] = input values
			//ch2 += coefs_0_High[i] * input[(i+j)*CHANNELS +1];	//coefs_0_Low[] = filter coefficients
		}	
		output[j*CHANNELS] = ch1; 					// output[] = output values
		output[j*CHANNELS + 1] = ch2; 			
	}
	
	
}

void C_fir_mono_16bit(int16_t *output,int16_t *input,int buffersize,int16_t *taps,int tapsSize){
	int16_t ch1 = 0; //canal
	int j,i;
	
	for ( j = 0; j < buffersize/*SAMPLE_N*/; j++) {
		ch1 = 0; 								// chx = accumulator
		for ( i =0; i < tapsSize; i++){
			ch1 = SaturatingAdd(ch1, taps[i] * input[(i+j)]);	// input[] = input values	
		}	
		output[j] = ch1; 					// output[] = output values
	}
}



#ifdef USE_C_STEREO
void AudioDSP(int16_t *input,int16_t *output){
	int16_t buff[SAMPLE_N*2];
	C_fir_stereo_16bit(output,input,SAMPLE_N,coefs_0_Low,FILTER_SIZE);
	C_fir_stereo_16bit(buff,output,SAMPLE_N,coefs_0_Mid,FILTER_SIZE);
	C_fir_stereo_16bit(output,buff,SAMPLE_N,coefs_0_High,FILTER_SIZE);
}
#endif

#ifdef USE_C_MONO
void AudioDSP(int16_t *input,int16_t *output){	
	int16_t ch1[SAMPLE_N];
	int16_t ch2[SAMPLE_N];
	int16_t ch1_1[SAMPLE_N];
	int16_t ch2_1[SAMPLE_N];

	separateChannels(ch1_1,ch2_1,input,SAMPLE_N);
	/*filtramos un canal*/
	C_fir_mono_16bit(ch1,ch1_1,SAMPLE_N,coefs_0_Low,FILTER_SIZE);
	C_fir_mono_16bit(ch1_1,ch1,SAMPLE_N,coefs_0_Mid,FILTER_SIZE);
	C_fir_mono_16bit(ch1,ch1_1,SAMPLE_N,coefs_0_High,FILTER_SIZE);
	/*filtramos el otro canal*/
	C_fir_mono_16bit(ch2,ch2_1,SAMPLE_N,coefs_0_Low,FILTER_SIZE);
	C_fir_mono_16bit(ch2_1,ch2,SAMPLE_N,coefs_0_Mid,FILTER_SIZE);
	C_fir_mono_16bit(ch2,ch2_1,SAMPLE_N,coefs_0_High,FILTER_SIZE);
	joinChannels(output,ch1,ch2,SAMPLE_N);
}
#endif

#ifdef USE_ASM_MONO
void AudioDSP(int16_t *input,int16_t *output){
		int16_t ch1[SAMPLE_N];
		int16_t ch2[SAMPLE_N];
		int16_t ch1_1[SAMPLE_N];
		int16_t ch2_1[SAMPLE_N];
		//el memcopy esta hasta que funcione el SIMD_AudioFilter()
		//memcpy(output,input,sizeof(audio_frame));
		//SIMD_AudioFilter(input,output);
		
		separateChannels(ch1_1,ch2_1,input,SAMPLE_N);
		/*filtramos un canal*/
 		asm_fir_16b(ch1,ch1_1,SAMPLE_N*2,coefs_0_Low,FILTER_SIZE*2);	//LOS *2 es por que el size lo tengo definido en cantidad 
 		asm_fir_16b(ch1_1,ch1,SAMPLE_N*2,coefs_0_Mid,FILTER_SIZE*2);	//	de elementos y al ser de 16 bits obtengo el tamaño a 
 		asm_fir_16b(ch1,ch1_1,SAMPLE_N*2,coefs_0_High,FILTER_SIZE*2);	//	nivel byte asi
		/*filtramos el otro canal*/
 		asm_fir_16b(ch2,ch2_1,SAMPLE_N*2,coefs_0_Low,FILTER_SIZE*2);
 		asm_fir_16b(ch2_1,ch2,SAMPLE_N*2,coefs_0_Mid,FILTER_SIZE*2);
 		asm_fir_16b(ch2,ch2_1,SAMPLE_N*2,coefs_0_High,FILTER_SIZE*2);
		joinChannels(output,ch1,ch2,SAMPLE_N);
}		
#endif

 //int asm_fir_filter_16_16(int16_t *buf_out, int16_t *buf_in, int bufsize, int16_t *taps, int filter_len);

void separateChannels(int16_t* out_ch1,int16_t* out_ch2,int16_t* in_buffer,int buffersize){
	int j=0;
	int i=0;
	for ( j = 0; j < buffersize; j++) {
		out_ch1[i] = in_buffer[j*CHANNELS];	
		out_ch2[i] = in_buffer[j*CHANNELS +1];	
		i++;
	}
}

void joinChannels(int16_t* out_buffer,int16_t* in_ch1,int16_t* in_ch2,int buffersize){
	int j=0;
	int i=0;
	for ( j = 0; j < buffersize; j++) {
		out_buffer[j*CHANNELS] = in_ch1[i];
		out_buffer[j*CHANNELS + 1] = in_ch2[i];
		i++;
	}
}

//const int SINT32_MIN = 0x80000000;
//const int SINT32_MAX = 0x7FFFFFFF;
 
int16_t SaturatingAdd(int16_t a, int16_t b)
{
	int sum = (int)a + (int)b;
	if (sum <= INT16_MIN) return INT16_MIN;
	if (sum >= INT16_MAX) return INT16_MAX;
	return (int16_t)sum;
}

