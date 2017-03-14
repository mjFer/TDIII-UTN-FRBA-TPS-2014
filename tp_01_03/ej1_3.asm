;                               Trabajo Practico 1 - EJ 2                               ; 
;                                                                                       ; 
;  Alumno: Marcelo Joaquin Fernandez                                                    ;  
;  Legajo: 1403734                                                                      ; 
;  Curso: r5055                                                                         ; 
; **************************************************************************************; 


BITS 16 
[ORG KERNEL_MEMORY]


jmp Inicio

GDT:

db 0,0,0,0,0,0,0,0   ;dejar vacio un descriptor


;DESCRIPTOR DE CODIGO FLAT (toda la memoria)
dw 0xFFFF	;limite en uno
dw 0x0000	;parte baja de la base en cero
db 0x00		;base 16:23
db 10011000b   ;presente,DPL(x2),sist(cod/dato),tipo(x4)(execute only)
db 11001111b   ;granularidad(limite en mult de 4 pag), D/B, L,                 ;AVL(disponible), (16:19 del limite)
db 0x00		;base

;DESCRIPTOR IGUAL QUE EL ANTERIOR PERO DE DATO
dw 0xFFFF	;limite en uno
dw 0x0000	;parte baja de la base en cero
db 0x00		;base 16:23
db 10010010b   ;presente,DPL(x2),sist(cod/dato),tipo(x4)(read/write)
db 11001111b   ;granularidad(limite en mult de 4 pag), D/B, L,                 ;AVL(disponible), (16:19 del limite)
db 0x00		;base


valor_gdtr:     dw $-GDT
		dd GDT


pila: times 100 db 0

texto: db "UTN-2014-TDIII-HelloWorld-MarceloJFernandez", 00h
		
Inicio:
lgdt [valor_gdtr] ;cargo la gdt

cli
mov eax,cr0
or al,1
mov cr0,eax
jmp 08:ModoProt


BITS 32
ModoProt:
mov ax,10h                  ;cargo el descriptor de datos
mov ds,ax					;cargo ds con el segundo descriptor
mov ss,ax					;cargo ss con el descriptor de datos (para la pila)
mov eax,pila + 100 			;seteo la direccion de la pila +100 por que se carga de forma inversa
mov esp,eax

xchg bx,bx
mov eax,page_directory_base
mov cr3,eax
mov eax,cr0                 ;seteo el bit de paginacion
or eax,80000000h           
mov cr0,eax
xor eax,eax                 ;XXXXXXXXXXXXXXXXX que es esto??

;xchg bx,bx
;seteo los parametros y llamo al clrScr con color negro
;mov edi,111b	; ECX	(cuarto arguemto)   char color
call clrScr

xchg bx,bx
;llamo a la rutina de inversion de pantalla
call RutinaInversionPantalla

;llamo a la rutina de print
mov edi,texto
mov esi,10	; esi	(segundo argumento) char columna
mov edx,2	; edx	(tercer argumento)  char fila
mov ecx,111b	; ECX	(cuarto arguemto)   char color

;xchg bx,bx
call Print

; void print (char string_ptr, char columna, char fila, char color);
; edi 	(primer argumento)  char string_ptr
; esi	(segundo argumento) char columna
; edx	(tercer argumento)  char fila
; ECX	(cuarto arguemto)   char color



hlt

%include "include/utils.asm"


ALIGN 4096
page_directory_base:
pd_entry_0      equ ($-page_directory_base)/4
        dd      (page_table_base)  + 11h

ALIGN 4096
        page_table_base:
        pt_entry_0      equ ($-page_table_base)/4
        dd       0b8000h + 11h

times 7 dd 0 
        pt_entry_1      equ ($-page_table_base)/4
        dd       08000h + 11h



