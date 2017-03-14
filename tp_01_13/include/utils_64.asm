;***********************************************************
;   UTN-2014-UTILS
;***********************************************************
;***********************************************************
;   Author  : Fernandez Marcelo Joaquin
;   Date    : 23th May 2014
;***********************************************************

%include "include/utils.mac"

[BITS 64]
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
  push rax
  
  mov rax,rdx		;muevo a al el contenido de esi o sea la fila
  xor rbx,rbx
  mov rbx,160
  mul bl		;multiplico por el largo de 80caracteres de 2 bytes (uso bl por que si uso bx usa ax y deposita parte alta en dx)
  mov rdx,rax		;resguardo el calculo  
  mov rax,rsi		;muevo el numero de columna
  xor rbx,rbx
  mov rbx,2
  mul bl		;multiplico por 2 para el numero de bytes por char TODO:ACA ESTA FALLANDO ME ESTA MODIFICANDO DX
  add rax,rdx		;le sumo el contenido de r9
  add rax, VID_MEM_64
  mov rsi,rax		;dejo en esi la posicion a partir de la cual arranco a dibujar
_lazo_1:
   mov rax,[rdi]
   mov [rsi],al
   inc rsi
   
   mov rax,[rsi]
   and al, 00000000b
   or al,cl	
   
   mov [rsi],al
   inc rsi
   inc rdi
   cmp byte [rdi], 0
   jne _lazo_1
   
   pop rax
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
  push rcx
  mov rbx,rax
  mov qword rcx,0x0000800000000000
  and qword rbx,rcx			;enmascaro todo menos el bit47
  cmp qword rbx,rcx
  je canonise_seteo_a_uno
  mov qword rcx,0x0000FFFFFFFFFFFF
  and rax,rcx	;como el bit 47 era cero hago cero todo lo posterior
  jmp canonise_fin
canonise_seteo_a_uno:
  mov qword rcx,0xFFFF000000000000
  or  rax,rcx	;como el bit 47 era uno hago uno todo lo posterior
canonise_fin:
    pop rcx
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

  
;-----------------------------------------------------------
; Lectura Registro CMOS 
; Recibe: rax = Address;
; Devuelve: rax = Lectura
; Autor: Marcelo J Fernandez 
;------------------------------------------------------------
ReadFromCMOS:     
	out 0x70,al     ;Copy address to CMOS register
	;some kind of real delay here is probably best 
	in al,0x71      ;Fetch 1 byte to al
	ret
  
;-----------------------------------------------------------
; Escritura Registro CMOS 
; Recibe: rax = Address;
; Devuelve: rax = Valor a escribir
; Autor: Marcelo J Fernandez
;------------------------------------------------------------
WriteToCMOS:     
	out 0x70,al    ;Copy address to CMOS register
	;some kind of real delay here is probably best 
	out 0x71,al      ; Fetch 1 byte to al
	ret  
	
;-----------------------------------------------------------
; Leer RTC 
; Devuelve: en los strings reservados
; Autor: Marcelo J Fernandez
; bibliografia de estudio http://wiki.osdev.org/CMOS#Getting_Current_Date_and_Time_from_RTC
;------------------------------------------------------------	
%define RTC_STATUS_R_A 0x0A
%define RTC_STATUS_R_B 0x0B

%define RTC_SECONDS_R  0x00
%define RTC_MINUTES_R  0x02
%define RTC_HOURS_R 0x04
%define RTC_WEEKDAY_R 0x06
%define RTC_DAY_OF_MONTH_R 0x07
%define RTC_MONTH_R 0x08
%define RTC_YEAR_R 0x09
	

RTC_WaitUntilUpdate:
  mov rax, RTC_STATUS_R_A
  call ReadFromCMOS
  and rax,0x80
  cmp rax,0x80
  je RTC_WaitUntilUpdate		;todavia esta updateando el RTC
  ret
	
RTC_Get_Seconds:
  call RTC_WaitUntilUpdate 
  mov rax, RTC_SECONDS_R
  call ReadFromCMOS 
  ret
	
		
RTC_Get_Minutes:
  call RTC_WaitUntilUpdate 
  mov rax, RTC_MINUTES_R
  call ReadFromCMOS
  ret
  
RTC_Get_Hours:
  call RTC_WaitUntilUpdate 
  mov rax, RTC_HOURS_R
  call ReadFromCMOS
  ret
  
RTC_Get_Day:
  call RTC_WaitUntilUpdate 
  mov rax, RTC_DAY_OF_MONTH_R
  call ReadFromCMOS
  ret
  
RTC_Get_Month:
  call RTC_WaitUntilUpdate 
  mov rax, RTC_MONTH_R
  call ReadFromCMOS
  ret
  
RTC_Get_Year:
  call RTC_WaitUntilUpdate 
  mov rax, RTC_YEAR_R
  call ReadFromCMOS
  ret
	
;-----------------------------------------------------------
; Funcion jiffies (devuelve los ms de la tarea actual)
; Devuelve: los ms
; Autor: Marcelo J Fernandez
;------------------------------------------------------------	
jiffies:
    push rbx
     mov rbx,[Current_disp_Task]   
     mov rax,[rbx + dispatcher_task_struct.totalTicks]
    pop rbx
    ret
    
    
;-----------------------------------------------------------
; Funcion Get id 
; Devuelve: los ms
; Autor: Marcelo J Fernandez
;------------------------------------------------------------	   
get_Task_ID:		;task id
    push rbx
     mov rbx,[Current_disp_Task]   
     mov ax,[rbx + dispatcher_task_struct.id_task]
    pop rbx
	ret
;-----------------------------------------------------------
; Funcion get priority
; Devuelve: los ms
; Autor: Marcelo J Fernandez
;------------------------------------------------------------	
get_Task_Priority:		;task priority
    push rbx
     mov rbx,[Current_disp_Task]   
     mov ax,[rbx + dispatcher_task_struct.prioridad_maxTicks]
    pop rbx
        ret
    
    