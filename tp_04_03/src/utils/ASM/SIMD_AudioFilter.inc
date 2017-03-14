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

;********************************************************************************
;* Registros para pasaje de parametros en modo 64				*
;********************************************************************************
%define p1iq 		rdi
%define p1id 		edi
%define p1iw 		di
%define p1ib 		dil
%define p2iq 		rsi
%define p2id 		esi
%define p2iw 		si
%define p2ib 		sil
%define p3iq 		rdx
%define p3id 		edx
%define p3iw 		dx
%define p3ib 		dl
%define p4iq 		rcx
%define p4id 		ecx
%define p4iw 		cx
%define p4ib 		cl
%define p5iq 		r8
%define p5id 		r8d
%define p5iw 		r8w
%define p5ib 		r8b
%define p6iq 		r9
%define p6id 		r9d
%define p6iw 		r9w
%define p6ib 		r9b
%define p1f			xmm0
%define p2f			xmm1
%define p3f			xmm2
%define p4f			xmm3
%define p5f			xmm4
%define p6f			xmm5
%define p7f			xmm6
%define p8f			xmm7




;********************************************************************************
;* Dependencias externas y globales												*
;********************************************************************************
GLOBAL	SIMD_AudioFilter
GLOBAL  asm_fir_16b
