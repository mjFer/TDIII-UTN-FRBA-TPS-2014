;***********************************************************
;   UTN-2014-Rutinas de Interrupcion
;***********************************************************
;***********************************************************
;   Author  : Fernandez Marcelo Joaquin
;   Date    : 23th May 2014
;***********************************************************


;defines de teclado
%define KEY_ESC 01h

[BITS 64]




					      ;http://sourceforge.net/p/nasm/mailman/nasm-users/thread/4DFE094A.9020105@computer.org/
%assign i 0
%rep    30

irsMSG_%+i: db "SALTO_EXCEPCION_N_"
irsMSG2_%+i:db 0,0,0,0,0,0,0,0,0,0
int_%+i:
	push rdi
	push rax
	
	mov edi,irsMSG_%+i
	mov esi,10	; esi	(segundo argumento) char columna
	mov edx,3	; edx	(tercer argumento)  char fila
	mov ecx,111b	; ECX	(cuarto arguemto)   char color
	call Print
	
	mov edi,i		;valor de la excepcion
	mov esi,irsMSG2_%+i	;puntero a char
	call my_itoa		;llamo a mi super funcion itoa
	
	mov edi,irsMSG2_%+i
	mov esi,28	; esi	(segundo argumento) char columna
	mov edx,3	; edx	(tercer argumento)  char fila
	mov ecx,111b	; ECX	(cuarto arguemto)   char color
	call Print	;hago que imprima el numero
	
	mov al,20h
	out 20h,al
	pop rax
	pop rdi
	
        iretq
        
%assign i i+1
%endrep


hlt_txt: db "HLT!!", 00h

int9_keyboardHandler:
  push rax
  push rdi
  push rsi
  push rdx
  push rcx
  
  xor rax,rax ;asi limpio el rax que sino da todo mal
  in al,60h
  cmp al,KEY_ESC
  je HL
  

term_int9: 
  mov al,0x20		;indico al PIC que atendi la interrupcion
  out 0x20,al
  
  pop rcx
  pop rdx
  pop rsi
  pop rdi
  pop rax
  iretq			;ojo que iret es de 16bit iretd es de 32 y iretq es de 64
  
HL:
  mov edi,hlt_txt
  mov esi,10	; esi	(segundo argumento) char columna
  mov edx,3	; edx	(tercer argumento)  char fila
  mov ecx,111b	; ECX	(cuarto arguemto)   char color
  call Print
  jmp term_int9

 
  