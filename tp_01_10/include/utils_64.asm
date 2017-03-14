;***********************************************************
;   UTN-2014-UTILS
;***********************************************************
;***********************************************************
;   Author  : Fernandez Marcelo Joaquin
;   Date    : 23th May 2014
;***********************************************************



[BITS 64]


%define VID_MEM_64 0x0     ;ahora el video esta direccionado a la pagina (0x000b8000)

;-----------------------------------------------------------
; Invierte los colores de la pantalla
; Recibe: Nada
; Devuelve: Nada
;------------------------------------------------------------
RutinaInversionPantalla_64:
;  xchg bx, bx
  push rcx
  mov esi, VID_MEM_64			;Memoria de video esi es un puntero a datos (ds)
  mov ecx,2000
  mov al,[esi]
lazo_1:
  mov edi,[esi +1]
  xor edi,01110111b
  mov [esi +1],edi
  add esi,2
  loop lazo_1
  pop rcx
ret

;-----------------------------------------------------------
; Print en Pantalla de un string
; Recibe: (char string_ptr, char columna, char fila, char color);
; Devuelve: Nada
; void print (char string_ptr, char columna, char fila, char color);
; edi 	(primer argumento)  char string_ptr
; esi	(segundo argumento) char columna
; edx	(tercer argumento)  char fila
; ECX	(cuarto arguemto)   char color
;------------------------------------------------------------
Print_64:
 ; xchg bx,bx
  push rbx
  mov eax,edx		;muevo a al el contenido de esi o sea la fila
  mov ebx,160
  mul bl		;multiplico por el largo de 80caracteres de 2 bytes (uso bl por que si uso bx usa ax y deposita parte alta en dx)
  mov edx,eax		;resguardo el calculo  
  mov eax,esi		;muevo el numero de columna
  mov ebx,2
  mul bl		;multiplico por 2 para el numero de bytes por char TODO:ACA ESTA FALLANDO ME ESTA MODIFICANDO DX
  add eax,edx		;le sumo el contenido de r9
  add eax, VID_MEM_64
  mov esi,eax		;dejo en esi la posicion a partir de la cual arranco a dibujar
_lazo_1:
   mov al,[ds:edi]
   mov [ds:esi],al
   inc esi
   mov [ds:esi],ecx
   inc esi
   inc edi
   cmp byte [ds:edi], 0
   jne _lazo_1
   pop rbx
ret


;-----------------------------------------------------------
; Limpia la pantalla con un color definido
; Recibe: (char color);
; Devuelve: Nada
; void print ( char color);
; edi 	(primer argumento)  char color
;------------------------------------------------------------
clrScr_64:
;  xchg bx, bx
  push rcx
  push rsi
  mov esi, VID_MEM_64			;apuntando a 0 ahora apunta a la zona de video
  mov ecx,2000
llazo_1:
  mov byte [esi],0x00   ;pongo caracter null
  add esi,2
  loop llazo_1
  pop rsi
  pop rcx
ret



;--------------------------------------------------------------------------------
;|	Título: Generador de numeros aleatorios					|
;|	Versión:		1.0			Fecha: 	16/07/2009	|
;|	Autor: 			D.GARCIA		Modelo:	IA-64 (64 bits) |
;|	------------------------------------------------------------------------|
;|	Descripción:								|
;|		Generador de numeros aleatorios de 64 bits			|
;|		X(n+1) = A * X(n) + C						|
;|	------------------------------------------------------------------------|
;|	Recibe:									|
;|		RAX = Semilla o cero para default				|
;|	Retorna:								|
;|		RAX = Numero pseudoaleatorio					|
;|	------------------------------------------------------------------------|
;|	Revisiones:								|
;|		1.0 | 15/02/2010 | D.GARCIA | Original				|
;--------------------------------------------------------------------------------
Rand:
	push 	rbx

	cmp		rax, 0				; Si es cero uso la semilla preestablecida
	jnz		DefaultSeed			; Si no es cero lo uso como semilla
	mov 	rax, [X0_RND]				; Cargo semilla preestablecida
DefaultSeed:	
	mov		rbx, [A_RND]
	mul		rbx
	add		rax, [C_RND]
	mov		[X0_RND], rax

	pop		rbx
	ret

ALIGN 8
X0_RND		dq	2B17351BFB31357Eh		; Semilla	
A_RND		dq 	6EFF46AB66A98E9Ah		; Coeficiente A
C_RND		dq	3D717FCCDCF08F5Ah		; COeficiente C
	

;-----------------------------------------------------------
; canonisado de un numero (despues del bit 47 mantiene el ultimo bit hasta 64)
; Recibe: rax =numero;
; Devuelve: rax = numero canonisado
;------------------------------------------------------------
canonise:
  push rbx
  mov rbx,rax
  and qword rbx,	0x0000800000000000	;enmascaro todo menos el bit47
  cmp qword rbx,	0x0000800000000000
  je canonise_seteo_a_uno
  and rax,		0x0000FFFFFFFFFFFF	;como el bit 47 era cero hago cero todo lo posterior
  jmp canonise_fin
canonise_seteo_a_uno:
  or  rax,		0xFFFF000000000000	;como el bit 47 era uno hago uno todo lo posterior
canonise_fin:
    pop rbx
  ret

;-----------------------------------------------------------
; canonisado de un numero (despues del bit 29 mantiene el ultimo bit hasta 64)
; Recibe: rax =numero;
; Devuelve: rax = numero canonisado
;------------------------------------------------------------
canonise1Mega:
  push rbx
  mov rbx,rax
  and qword rbx,	0x0000000040000000	;enmascaro todo menos el bit47
  cmp qword rbx,	0x0000000040000000
  je canonise1Mega_seteo_a_uno
  and rax,		0x000000007FFFFFFF	;como el bit 47 era cero hago cero todo lo posterior
  jmp canonise1Mega_fin
canonise1Mega_seteo_a_uno:
  or  rax,		0xFFFFFFFF90000000	;como el bit 47 era uno hago uno todo lo posterior
canonise1Mega_fin:
    pop rbx
  ret
