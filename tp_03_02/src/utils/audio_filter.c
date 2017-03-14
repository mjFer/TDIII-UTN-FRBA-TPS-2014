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
// 
// 
// 
// #define SAMPLE_N 	640		// numero de Samples a procesas
// #define FILTER_SIZE	32
// 
// #define USE_C
// 
// static char coefs[32] = {
//   1,1,1,1,1,1,1,1,1,1
//   1,1,1,1,1,1,1,1,1,1
//   1,1,1,1,1,1,1,1,1,1
//   1,1
// };
// 
// #ifdef USE_C
// void AudioFilter(char low,char mid, char high,char *input,char *output){
//  
//   for ( j = 0; j < SAMPLE_N; j++) {
//       int s = 0; 			// s = accumulator
//       for ( i =0; i <= FILTER_SIZE; i++)
// 	  s += coefs[i] * input[i+j]; 	// x[] = input values
// 					c[] = filter coefficients
//       output[j] = s; 			// y[] = output values
//     } 
// }
// #else
// void AudioFilter(char low,char mid, char high,char *input,char *output){
//  
//   asm(volatile)
//   (
//       ""
//       ""
//       ""
//       ""
//       ""
//   )
// }
// 
// 
// #endif