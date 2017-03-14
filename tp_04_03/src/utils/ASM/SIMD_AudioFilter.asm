;################################################################################
;#	Ti­tulo: FILTRO AUDIO SIMD						#
;#										#
;#	Version:		1.0			Fecha: 	01/11/2014	#
;#	Autor: 			M.J. Fernandez					#
;#	------------------------------------------------------------------------#
;#	Descripcion:								#
;#		Ver LEEME							#
;#		Definiciones auxiliares para las librerias			#
;#										#
;#	------------------------------------------------------------------------#
;################################################################################	

USE64
;********************************************************************************
;* Dependencias externas
;********************************************************************************
%include 	"./src/utils/ASM/SIMD_AudioFilter.inc"


;********************************************************************************
;* Funciones									*
;********************************************************************************
;--------------------------------------------------------------------------------
; Por Ahora es un dummy
; Recibe: Nada 
;	
; Devuelve: Nada
;--------------------------------------------------------------------------------
SIMD_AudioFilter:
	ret


	
;--------------------------------------------------------------------------------
; Por Ahora es un dummy
; Recibe: 
;	rdi [out]: puntero al buffer de salida
;	rsi [in]:  puntero albuffer de entrada			puntero
;	rdx [in]: size del buffer de entrada
;	rcx [in]:  puntero a los coeficientes
;	r8 [in]: size del buffer de coeficientes
;	
; Devuelve: Nada
;--------------------------------------------------------------------------------
asm_fir_16b:
	xor rax, rax

	loop1:
		pxor xmm0, xmm0 ;128 bytes 	
		xor r9, r9 ;contador		

		mov r10, rsi
		add r10, rax

		loop2:
			movups xmm1, [r10+r9] 	;Muevo 128 bits, 16 bytes, 128/16 = 8 samples
			pmaddwd xmm1, [rcx+r9]	;multiplicacion de w(16bits) xmm1 con [rcx + offset] y guardo en bloques de dw(32bit) 
							;PMADDWD (with 128-bit operands)
							;DEST[31:0] = (DEST[15:0] * SRC[15:0]) + (DEST[31:16] * SRC[31:16]);
							;DEST[63:32] = (DEST[47:32] * SRC[47:32]) + (DEST[63:48] * SRC[63:48]);
							;DEST[95:64] = (DEST[79:64] * SRC[79:64]) + (DEST[95:80] * SRC[95:80]);
							;DEST[127:96] = (DEST[111:96] * SRC[111:96]) + (DEST[127:112] * SRC[127:112]);
			paddd xmm0, xmm1 	;Sumo de a 32 xmm1 con xmm0 --> guardo en xmm0
							;PADDD (with 128-bit operands)
							;DEST[31:0] = DEST[31:0] + SRC[31:0];
							;DEST[63:32] = DEST[63:32] + SRC[63:32];
							;DEST[95:64] = DEST[95:64] + SRC[95:64];
							;DEST[127:96] = DEST[127:96] + SRC[127:96];
			add r9, 16 		;Analice 8 elementos => me muevo 16 bytes (128 bits) para adelante
			cmp r9, r8 		;Veo si analice todaas las taps
			jnz loop2

		pxor xmm1, xmm1 ;128 bytes
		;En xmm0 tengo 4 doublewords con la suma parcial del FIR (tengo que sumar esos 4)
		phaddd xmm0, xmm1 		;Sumo de a grupos xmm0 = D3,D2,D1,D0 xmm1= 0,0,0,0 --> xmm0= 0,0,D3+D2,D1+D0 
							;PHADDD (with 128-bit operands)
							;xmm0[31-0] = xmm0[63-32] + xmm0[31-0];
							;xmm0[63-32] = xmm0[127-96] + xmm0[95-64];
							;xmm0[95-64] = xmm1/m128[63-32] + xmm1/m128[31-0];
							;xmm0[127-96] = xmm1/m128[127-96] + xmm1/m128[95-64];
		phaddd xmm0, xmm1 		;repito lo anterior y me queda xmm0 = 0,0,0,D1+D0
		;psrad xmm0, 15			;Se corre 15 para que quede una word (comprimimos)
		movd [rdi+rax], xmm0 		;Lo guardo en la salida
		add rax, 0x2
		sub rdx, 0x2
		cmp rdx, 0
		jnz loop1
	ret
