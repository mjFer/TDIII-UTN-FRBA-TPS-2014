;***********************************************************
;   UTN-2014-Rutinas de Interrupcion
;***********************************************************
;***********************************************************
;   Author  : Fernandez Marcelo Joaquin
;   Date    : 23th May 2014
;***********************************************************


[BITS 64]

;defines de teclado
%define KEY_ESC 01h

%define KEY_F5 0xbf
%define KEY_F6 0xc0
%define KEY_F7 0xc1
%define KEY_F8 0xc2

%define KEY_CTL_PRESS 0x1D
%define KEY_CTL_RELEASE 0x9D

%define KEY_1_PRESS 0x02
%define KEY_2_PRESS 0x03
%define KEY_3_PRESS 0x04






					      ;http://sourceforge.net/p/nasm/mailman/nasm-users/thread/4DFE094A.9020105@computer.org/
%assign i 0
%rep    30

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
; Handler de Interrupcion de teclado
; Recibe: Nada
; Devuelve: Nada
;------------------------------------------------------------

hlt_txt: db "HLT!!", 00h

variable_ctl_pressed: dq 00h

int9_keyboardHandler:
  push rax
  push rdi
  push rsi
  push rdx
  push rcx
  
  xor rax,rax ;asi limpio el rax que sino da todo mal
  in al,60h
  cmp al,KEY_ESC
  je KEY_ESC_PRESS
  cmp al,KEY_F5
  je KEY_F5_PRESS
  cmp al,KEY_F6
  je KEY_F6_PRESS
  cmp al,KEY_F7
  je KEY_F7_PRESS
  cmp al,KEY_F8
  je KEY_F8_PRESS
  cmp al,KEY_CTL_PRESS
  je KEY_CTL_PRESSED
  cmp al,KEY_CTL_RELEASE
  je KEY_CTL_RELEASED
  cmp al,KEY_1_PRESS
  je KEY_1_PRESSED
  cmp al,KEY_2_PRESS
  je KEY_2_PRESSED
  cmp al,KEY_3_PRESS
  je KEY_3_PRESSED

term_int9: 
  mov al,0x20		;indico al PIC que atendi la interrupcion
  out 0x20,al
  
  pop rcx
  pop rdx
  pop rsi
  pop rdi
  pop rax
  iretq			;ojo que iret es de 16bit iretd es de 32 y iretq es de 64
  

KEY_CTL_PRESSED:
  mov rax,0x00000001
  mov [variable_ctl_pressed],rax
  jmp term_int9
KEY_CTL_RELEASED:
  mov rax,0x00000000
  mov [variable_ctl_pressed],rax
  jmp term_int9
  
KEY_1_PRESSED:
  xor rax,rax
  mov rax,[variable_ctl_pressed]
  cmp rax,00
  je term_int9
  call GENERAR_DOBLE_FAULT
  jmp term_int9
KEY_2_PRESSED:
  xor rax,rax
  mov rax,[variable_ctl_pressed]
  cmp rax,00
  je term_int9
  call GENERAR_GENERAL_PROTECTION
  jmp term_int9
KEY_3_PRESSED:
  xor rax,rax
  mov rax,[variable_ctl_pressed]
  cmp rax,00
  je term_int9
  call GENERAR_PAGE_FAULT
  jmp term_int9
  
  
KEY_ESC_PRESS:
  mov edi,hlt_txt
  mov esi,10	; esi	(segundo argumento) char columna
  mov edx,3	; edx	(tercer argumento)  char fila
  mov ecx,111b	; ECX	(cuarto arguemto)   char color
  call Print_64
  jmp term_int9
  
KEY_F5_PRESS:
  call toggle_F5_D0
  jmp term_int9
  
KEY_F6_PRESS:
  call toggle_F6_D1
  jmp term_int9
  
KEY_F7_PRESS:
  call toggle_F7_D2
  jmp term_int9

KEY_F8_PRESS:
  call toggle_F8_D3
  jmp term_int9  
 
 
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
  mov  rax,[0x300000]
  
 ret
 
%include "include/debug_registers.asm"
  
  
;-----------------------------------------------------------
; Handler de division por cero 
; Recibe: Nada
; Devuelve: Nada
;-----------------------------------------------------------  
ex0_ceroHandler:

  xchg bx,bx
  
  ;trato de leer en una zona de memoria que no esta en pagina
  mov  rax,[0x300000]
  

iretq

  
;-----------------------------------------------------------
; Handler de Debug 
; Recibe: Nada
; Devuelve: Nada
;-----------------------------------------------------------  
ex3_BPHandler:


iretq

;-----------------------------------------------------------
; Handler de DoubleFault 
; Recibe: Nada
; Devuelve: Nada
;----------------------------------------------------------- 
G_DFH_txt: db "ex8_DoubleFaultHandler!!        ", 00h
ex8_DoubleFaultHandler:
    pop rax
    mov edi,G_DFH_txt
    mov esi,5	; esi	(segundo argumento) char columna
    mov edx,7	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64
    
    pop rax		;incremento el eip en 3 para que siga con laproxima instruccion
    add rax, 11b
    push rax
    
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
    mov edx,6	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64
   

    pop rax		;incremento el eip en 3 para qsue siga con laproxima instruccion
    add rax, 11b
    push rax
    
iretq

;-----------------------------------------------------------
; Handler de PageFault
; Recibe: Nada
; Devuelve: Nada
;----------------------------------------------------------- 
G_PFH_txt: db "ex14_PageFaultProtectionHandler!!        ", 00h
ex14_PageFaultProtectionHandler:
    pop rbx
    mov edi,G_PFH_txt
    mov esi,5	; esi	(segundo argumento) char columna
    mov edx,8	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64

    pop rax		;incremento el eip en 9 para que siga con laproxima instruccion
    add rax, 1000b
    push rax
    
iretq

