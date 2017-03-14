;                               Trabajo Practico 1 - EJ 4                               ; 
;                                                                                       ; 
;  Alumno: Marcelo Joaquin Fernandez                                                    ;  
;  Legajo: 1403734                                                                      ; 
;  Curso: r5055                                                                         ; 
; **************************************************************************************; 


;********************************************************************************
;* Macros																		*
;********************************************************************************
%define	PDPT_BASE  	0xA000				;ubicacion de la Page Directory Pointer Table
%define	PD_BASE   	PDPT_BASE + 0x1000	;ubicacion de la Page Directory Table
%define	PT_BASE		PD_BASE + 0x1000	;ubicacion de la Page Table
%define PT_ENTRY_0  PT_BASE + 0x1000    ;primer pagina
%define PT_ENTRY_1  PT_ENTRY_0 + 0x1000 ;segunda pagina
%define	VIDEO_BASE	0x200000
%define BREAKPOINT	xchg bx, bx

;********************************************************************************
;* Macros Video																		*
;********************************************************************************
%define	VIDEO_BLINK 		10000000b	;BLINK
%define	VIDEO_B_C_B 		00010000b	;BACKGROUND COLOR BLUE
%define	VIDEO_B_C_G 		00100000b	;BACKGROUND COLOR GREEN
%define	VIDEO_B_C_R 		01000000b	;BACKGROUND COLOR RED
%define	VIDEO_F_C_R 		00001000b   ;FOREGROUND COLOR RED
%define	VIDEO_F_C_G 		00000100b	;FOREGROUND COLOR GREEN
%define VIDEO_F_C_B 		00000010b	;FOREGROUND COLOR BLUE
%define VIDEO_UNDERLINE 	00000001b	;UNDERLINE

BITS 16 
[ORG KERNEL_MEMORY]

ALIGN 4096
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
texto_ok: db "...Funciono", 00h
texto_PAE: db "Tablas Dinamicas y PAE (MSW CPUID)", 00h
		
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
;Comprueba si pae esta como spec en el micro
mov eax,1
CPUID
and edx,1000000b
cmp edx,1000000b
jnz NO_PAE

xchg bx,bx

mov dword [PDPT_BASE],PD_BASE + 0x11
mov dword [PDPT_BASE + 4], 0
mov dword [PD_BASE],PT_BASE + 0x11
mov dword [PD_BASE + 4], 0

;Aca arrancamos a crear las paginas con un loop
    mov ecx, 20      ;voy a crear 20 paginas
    mov eax, 01000h + 0x01
    mov edi, PT_BASE + 8
pageloop:
    mov dword [edi],eax
    mov dword [edi + 4],0
    add edi, 8
    add eax, 1000h
    loop pageloop
    

mov dword [PT_BASE],0b8000h + 0x01
mov dword [PT_BASE + 4], 0

xchg bx,bx

mov eax,PDPT_BASE
mov cr3,eax
mov eax,cr4					;leo el registro CR4
or eax,00100000b			;or flag de PAE
mov cr4,eax					;Seteo CR4

mov eax,cr0                 ;seteo el bit de paginacion
or eax,80000000h           
mov cr0,eax
xor eax,eax                 ;XXXXXXXXXXXXXXXXX que es esto??

;LLamo a un Clear Screen
call clrScr
;llamo a la rutina de print
mov edi,texto
mov esi,10	; esi	(segundo argumento) char columna
mov edx,2	; edx	(tercer argumento)  char fila
mov ecx,111b	; ECX	(cuarto arguemto)   char color
call Print

;llamo a la rutina de print
mov edi,texto_PAE
mov esi,10	; esi	(segundo argumento) char columna
mov edx,3	; edx	(tercer argumento)  char fila
mov ecx,111b	; ECX	(cuarto arguemto)   char color
call Print

;llamo a la rutina de print
mov edi,texto_ok
mov esi,10	; esi	(segundo argumento) char columna
mov edx,4	; edx	(tercer argumento)  char fila
mov ecx,VIDEO_F_C_R | VIDEO_BLINK	; ECX	(cuarto arguemto)   char color
call Print

hlt

NO_PAE:         ;aunque es al pedo para el debugging me caeria aca si no tuviese pae
    hlt


%include "include/utils.asm"
