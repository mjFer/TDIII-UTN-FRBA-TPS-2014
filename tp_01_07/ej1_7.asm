;                               Trabajo Practico 1 - EJ 5                               ; 
;                                                                                       ; 
;  Alumno: Marcelo Joaquin Fernandez                                                    ;  
;  Legajo: 1403734                                                                      ; 
;  Curso: r5055                                                                         ; 
; **************************************************************************************; 


;********************************************************************************
;* Macros																		*
;********************************************************************************

%define PML4_BASE   0xA000			;ubicacion de la Page Map Level 4
%define	PDPT_BASE  	PML4_BASE + 0x1000	;ubicacion de la Page Directory Pointer Table
%define	PD_BASE   	PDPT_BASE + 0x1000	;ubicacion de la Page Directory Table
%define	PT_BASE		PD_BASE + 0x1000	;ubicacion de la Page Table
%define PT_ENTRY_0  PT_BASE + 0x1000    	;primer pagina
%define PT_ENTRY_1  PT_ENTRY_0 + 0x1000 	;segunda pagina
%define	VIDEO_BASE	0x200000
%define BREAKPOINT	xchg bx, bx

;********************************************************************************
;* Macros Video																		*
;********************************************************************************
%define	VIDEO_BLINK 		10000000b	;BLINK
%define	VIDEO_B_C_B 		00010000b	;BACKGROUND COLOR BLUE
%define	VIDEO_B_C_G 		00100000b	;BACKGROUND COLOR GREEN
%define	VIDEO_B_C_R 		01000000b	;BACKGROUND COLOR RED
%define	VIDEO_F_C_R 		00001000b   	;FOREGROUND COLOR RED
%define	VIDEO_F_C_G 		00000100b	;FOREGROUND COLOR GREEN
%define VIDEO_F_C_B 		00000010b	;FOREGROUND COLOR BLUE
%define VIDEO_UNDERLINE 	00000001b	;UNDERLINE

BITS 16 
[ORG KERNEL_MEMORY]

ALIGN 4096
jmp Inicio

gdt:

db 0,0,0,0,0,0,0,0   ;dejar vacio un descriptor


cs_sel_64  equ $-gdt
        db 0xFF         ;Bits 7-0 del limite (no usado en 64 bits).
        db 0xFF         ;Bits 15-8 del limite (no usado en 64 bits).
        db 0            ;Bits 7-0 de la base (no usado en 64 bits).
        db 0            ;Bits 15-8 de la base (no usado en 64 bits).
        db 0            ;Bits 23-16 de la base (no usado en 64 bits).
	db 0x9A		;Byte de derechos de acceso:
			;Bit 7=1: Segmento Presente.
			;Bits 6,5=00: Nivel de Privilegio cero.
			;Bit 4=1: Segmento de codigo o datos.
			;Bit 3=1: Descriptor correspondiente a codigo.
			;Bit 2=0: Segmento no conforme.
			;Bit 1=1: El segmento de codigo se puede leer.
			;Bit 0=0: El segmento no fue accedido.
        db 0xAF         ;Bit 7=1: Granularidad (no usado en 64 bits).
                        ;Bit 6,5=01: Segmento de 64 bits (en modo largo).
                        ;Bit 4=0: No usado.
                        ;Bits 3-0=1111: Bits 19-16 del limite (no usados
                        ;en modo largo). 
        db 0            ;Bits 31-24 de la base (no usado en 64 bits).

cs_sel_32  equ $-gdt
        db 0xFF          ;Bits 7-0 del limite.
        db 0xFF          ;Bits 15-8 del limite.
        db 00h          ;Bits 7-0 de la base.
        db 00h          ;Bits 15-8 de la base.
        db 00h          ;Bits 23-16 de la base.
	db 0x9A		;Byte de derechos de acceso:
			;Bit 7=1: Segmento Presente.
			;Bits 6,5=00: Nivel de Privilegio cero.
			;Bit 4=1: Segmento de codigo o datos.
			;Bit 3=1: Descriptor correspondiente a codigo.
			;Bit 2=0: Segmento no conforme.
			;Bit 1=1: El segmento de codigo se puede leer.
			;Bit 0=0: El segmento no fue accedido.
        db 0xCF         ;Bit 7=1: Granularidad.	
                        ;Bit 6,5=10: Segmento de 32 bits (en modo largo).  (EN LA PRESENTACION ESTA MAL)
                        ;Bit 4=0: No usado.
                        ;Bits 3-0=1111: Bits 19-16 del limite. 
        db 0            ;Bits 31-24 de la base.


ds_sel  equ $-gdt
        db 0FFh         ;Bits 7-0 del limite (no usado en 64 bits).
        db 0FFh         ;Bits 15-8 del limite (no usado en 64 bits).
        db 0            ;Bits 7-0 de la base (no usado en 64 bits).
        db 0            ;Bits 15-8 de la base (no usado en 64 bits).
        db 0            ;Bits 23-16 de la base (no usado en 64 bits).
	db 92h		;Byte de derechos de acceso:
			;Bit 7=1: Segmento Presente.
			;Bits 6,5=00: Nivel de Privilegio cero.
			;Bit 4=1: Segmento de codigo o datos.
			;Bit 3=0: Descriptor correspondiente a datos.
			;Bit 2=0: Offset <= Limite. 
			;Bit 1=1: El segmento de datos se puede escribir.
			;Bit 0=0: El segmento no fue accedido.
        db 0CFh         ;Bit 7=0: Granularidad (no usado en 64 bits).
                        ;Bit 6,5=10: Segmento de 32 bits.
			;Bit 4=0: No usado.
                        ;Bits 3-0=1111: Bits 19-16 del limite (no usados
                        ;en modo largo). 
        db 0            ;Bits 31-24 de la base (no usado en 64 bits).

long_gdt equ $-gdt		;longitud gdt

        
valor_gdtr:     dw long_gdt-1   
	dd gdt
	
	
idt:     times 32 dq 0,0  ;16 bytes por compuerta.

        dw int_0      ;Bits 15-0 del offset.
        dw cs_sel_64    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Eh          ;Compuerta de interrupcion de 64 bits.
        dw 0            ;Bits 31-16 del offset.
        dd 0            ;Bits 63-32 del offset.
        dd 0            ;Reservado.
	
	dw int9_keyboardHandler      ;Bits 15-0 del offset.
        dw cs_sel_64    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Eh          ;Compuerta de interrupcion de 64 bits.
        dw 0            ;Bits 31-16 del offset.
        dd 0            ;Bits 63-32 del offset.
        dd 0            ;Reservado.
        

%assign i 0
%rep    30
	; Compuerta de interrupcion de 16 bytes correspondiente a INT i.
        dw int_%+i      ;Bits 15-0 del offset.
        dw cs_sel_64    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Eh          ;Compuerta de interrupcion de 64 bits.
        dw 0            ;Bits 31-16 del offset.
        dd 0            ;Bits 63-32 del offset.
        dd 0            ;Reservado.
%assign i i+1
%endrep       
        
        

idtsize equ $-idt

idtr:     dw idtsize-1
          dd idt	
	

				
pila: times 100 db 0


texto: db "UTN-2014-TDIII-HelloWorld-MarceloJFernandez", 00h

		
Inicio:


cli
lgdt [valor_gdtr] ;cargo la gdt

;habilito gateA20
call Verificar_Gate_A20

mov eax,cr0
or al,1
mov cr0,eax
jmp cs_sel_32:ModoProt_Legacy


BITS 32
ModoProt_Legacy:
mov ax,ds_sel                ;cargo el descriptor de datos
mov ds,ax					;cargo ds con el segundo descriptor
mov ss,ax					;cargo ss con el descriptor de datos (para la pila)

mov eax,pila + 100 			;seteo la direccion de la pila +100 por que se carga de forma inversa
mov esp,eax

;reprogramo el pic
call Pic_Reprograming
mov AL, 11111101b 		;desabilito todas las interrupciones del PIC1	 ;11111100b  http://www.brokenthorn.com/Resources/OSDevPic.html
out 21h,al
mov AL, 0xFF 		;desabilito todas las interrupciones del PIC2 ??????????????????????????
out 0xA1,al
lidt [idtr]



;Comprueba si PAE esta como spec en el micro
mov eax,1
CPUID
and edx,1000000b
cmp edx,1000000b
jnz NO_PAE


;Comprueba si LME esta como spec en el micro
mov eax,0x80000001
CPUID
and edx,0x20000000		;bit 29  
cmp edx,0x20000000
jnz NO_LME


;INICIO Creacion de paginas
	mov dword [PML4_BASE],PDPT_BASE + 0x11		;si no anda ver que puede estar aca el problema
	mov dword [PML4_BASE + 4], 0
	mov dword [PDPT_BASE],PD_BASE + 0x11
	mov dword [PDPT_BASE + 4], 0
	mov dword [PD_BASE],PT_BASE + 0x11
	mov dword [PD_BASE + 4], 0

	;Aca arrancamos a crear las paginas con un loop
	mov ecx, 512      ;voy a crear 20 paginas
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
;FIN CREACION PAGINAS



mov eax,PML4_BASE
mov cr3,eax

mov eax,cr4					;leo el registro CR4
or eax,00100000b			;or flag de PAE
mov cr4,eax					;Seteo CR4

mov ecx,0x0C0000080      	;seteo para leer EFER de la MSR
rdmsr                  		;pedido de lectura a MSR
or eax, 0x00000100       	;Seteo LME (Long mode enable)
wrmsr              			;seteo en la MSR el registro EFER

mov eax,cr0                 ;seteo el bit de paginacion
or eax,80000000h           
mov cr0,eax


jmp  cs_sel_64:modo_largo    
 

[bits 64]
modo_largo: 
 
 sti
;LLamo a un Clear Screen
call clrScr
;llamo a la rutina de print
mov edi,texto
mov esi,10	; esi	(segundo argumento) char columna
mov edx,2	; edx	(tercer argumento)  char fila
mov ecx,111b	; ECX	(cuarto arguemto)   char color
call Print

;pruebo de escribir en una direccion superior al primer megabyte
mov edi,0x100000		;me posiciono en el primer megabyte
mov word [edi],0xA0BA0;		;escribo basura XD


haceNada:
hlt
jmp haceNada

NO_PAE:         ;aunque es al pedo para el debugging me caeria aca si no tuviese pae
    hlt

NO_LME:         ;aunque es al pedo para el debugging me caeria aca si no tuviese pae
    hlt
    
%include "include/utils.asm"
%include "include/isr.asm"
%include "include/gateA20.asm"
