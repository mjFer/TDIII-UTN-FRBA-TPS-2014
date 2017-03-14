;***********************************************************
;   UTN-2014-Rutinas de Interrupcion
;***********************************************************
;***********************************************************
;   Author  : Fernandez Marcelo Joaquin
;   Date    : 23th May 2014
;***********************************************************



[BITS 64]




					      ;http://sourceforge.net/p/nasm/mailman/nasm-users/thread/4DFE094A.9020105@computer.org/
%assign i 0
%rep    30

irsMSG_%+i: db "SALTO_EXCEPCION_N_"
irsMSG2_%+i:db 0,0,0,0,0,0,0,0,0,0
int_%+i:
	push rdi
	
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
	
	;pop rdi
        hlt		;por enunciado me pide que haltee
        ;iret
        ret
%assign i i+1
%endrep