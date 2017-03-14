;***********************************************************
;   UTN-2014-Rutinas de Interrupcion
;***********************************************************
;***********************************************************
;   Author  : Fernandez Marcelo Joaquin
;   Date    : 23th May 2014
;***********************************************************

;http://support.microsoft.com/kb/117389/es ;buena descripcion resumida de fuentes de excepciones


[BITS 64]

%include "include/isr_pageFaultExceptionHandler.asm"
%include "include/isr_keyboardHandler.asm"
%include "include/isr_svc.asm"
%include "include/isr_int0_scheduler.asm"
%include "include/debug_registers.asm"

					      ;http://sourceforge.net/p/nasm/mailman/nasm-users/thread/4DFE094A.9020105@computer.org/
%assign i 2
%rep    46

irsMSG_%+i: db "SALTO_EXCEPCION_N_"
irsMSG2_%+i:db 0,0,0,0,0,0,0,0,0,0
int_%+i:
	push rdi
	push rax
	
	xchg bx,bx
	mov edi,irsMSG_%+i
	mov esi,10	; esi	(segundo argumento) char columna
	mov edx,6	; edx	(tercer argumento)  char fila
	mov ecx,111b	; ECX	(cuarto arguemto)   char color
	call Print_64
	
	mov edi,i		;valor de la excepcion
	mov esi,irsMSG2_%+i	;puntero a char
	call my_itoa		;llamo a mi super funcion itoa
	
	mov edi,irsMSG2_%+i
	mov esi,28	; esi	(segundo argumento) char columna
	mov edx,6	; edx	(tercer argumento)  char fila
	mov ecx,111b	; ECX	(cuarto arguemto)   char color
	call Print_64	;hago que imprima el numero
	
	mov al,20h
	out 20h,al
	pop rax
	pop rdi
	
        iretq
        
%assign i i+1
%endrep



;-----------------------------------------------------------
; Handler de division por cero 
; Recibe: Nada
; Devuelve: Nada
;------------------------------------------------------------
ex0_DIV0Handler:    
    mov al,20h		
    out 20h,al		; Send the EOI to the PIC   
    
   xchg bx,bx
   iretq


  
  
 
G_DF_txt: db "GENERANDO DOBLE FAULT!!        ", 00h
G_GP_txt: db "GENERANDO GENERAL PROTECTION:!!", 00h
G_PG_txt: db "GENERANDO PAGE FAULT!!         ", 00h
GENERAR_DOBLE_FAULT:
  mov edi,G_DF_txt
  mov esi,5	; esi	(segundo argumento) char columna
  mov edx,23	; edx	(tercer argumento)  char fila
  mov ecx,111b	; ECX	(cuarto arguemto)   char color
  call Print_64
 
   ;divido por cero para generar una excepcion de division por cero 
  ;o si esta mal definida que genere una general protection
  mov rax,0x00000001							;preguntar por que exploca y no explotaba
  mov rbx,0x00000000
  div rbx
  
  ret
GENERAR_GENERAL_PROTECTION:
  mov edi,G_GP_txt
  mov esi,5	; esi	(segundo argumento) char columna
  mov edx,23	; edx	(tercer argumento)  char fila
  mov ecx,111b	; ECX	(cuarto arguemto)   char color
  call Print_64
  
  ;escribo en un bit reservado del cr4
  mov rax,0x100000
  mov cr4, rax
  
  ;xchg bx,bx
  ;divido por cero para generar una excepcion de division por cero 
  ;o si esta mal definida que genere una general protection
  ;mov rax,0x00000000							preguntar por que exploca y no explotaba
  ;mov rbx,0x00000000
  ;div rbx
  
  ;salto a una sona no ejecutable
  ;jmp G_DF_txt
  
  ;pruebo de escribir en una direccion superior al primer megabyte 
  ;donde posicione las tablas de paginacion
  ;mov edi,0x100000		;me posiciono en el primer megabyte
  ;mov word [edi],0xA0BA0;		;escribo basura XD
  
  ret
GENERAR_PAGE_FAULT:
  mov edi,G_PG_txt
  mov esi,5	; esi	(segundo argumento) char columna
  mov edx,23	; edx	(tercer argumento)  char fila
  mov ecx,111b	; ECX	(cuarto arguemto)   char color
  call Print_64
  
  ;trato de leer en una zona de memoria que no esta en pagina
  mov  rax,[0x70000000]
  
 ret
 

  



;-----------------------------------------------------------
; Handler de DoubleFault 
; Recibe: Nada
; Devuelve: Nada
;----------------------------------------------------------- 
G_DFH_txt: db "ex8_DoubleFaultHandler!!...HLT!", 00h
ex8_DoubleFaultHandler:
    pop rax
    mov edi,G_DFH_txt
    mov esi,5	; esi	(segundo argumento) char columna
    mov edx,16	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64
    
    hlt
   ; pop rax		;incremento el eip en 3 para que siga con laproxima instruccion
   ; add rax, 11b
   ; push rax
    
iretq

;-----------------------------------------------------------
; Handler de General Protection 
; Recibe: Nada
; Devuelve: Nada
;-----------------------------------------------------------  
G_GPH_txt: db "ex13_GeneralProtectionHandler!!        ", 00h
ex13_GeneralProtectionHandler:
    pop rbx
    mov edi,G_GPH_txt
    mov esi,5	; esi	(segundo argumento) char columna
    mov edx,16	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64
   

    hlt
    
iretq

;-----------------------------------------------------------
; Handler de General Protection 
; Recibe: Nada
; Devuelve: Nada
;-----------------------------------------------------------  


ex7_NMHandler:
  ;bajo el flag de TS
  clts 
  ;restauro los datos a las mmx
  mov rbx,[Current_disp_Task]   
  mov rbx,[rbx + dispatcher_task_struct.current_task_struct]
  mov rbx,[rbx + task_struct.MMX]
  FXRSTOR [rbx]
iretq
