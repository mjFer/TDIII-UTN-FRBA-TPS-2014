;***********************************************************
;   UTN-2014-Rutinas de Interrupcion
;***********************************************************
;***********************************************************
;   Author  : Fernandez Marcelo Joaquin
;   Date    : 23th May 2014
;***********************************************************

;http://support.microsoft.com/kb/117389/es ;buena descripcion resumida de fuentes de excepciones


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
%rep    15

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
%define FISICAL_AVAIABLE_MEMORY 0x8000000  ;equivale a 128megas de ram
;%%define FISICAL_AVAIABLE_MEMORY 0x4000000  ;equivale a 128megas de ram

G_PFH_txt: db "ex14_PageFaultProtectionHandler!!        ", 00h
G_PFH_Ppci: db "....Pagina presente con privilegios incorrectos..HLT!  ", 00h
G_PFH_mll: db "....Memoria llena..HLT!  ", 00h

var_base_page_phy_dir: dq BASE_PAGES,0
var_last_created_page_phy_dir: dq BASE_PAGES,0
var_n_page_created dq 0,0

ex14_PageFaultProtectionHandler:
    pop rbx
    
 ;   xchg bx,bx
    
    push rax
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    push r10
    push r11
    
    mov edi,G_PFH_txt
    mov esi,5	; esi	(segundo argumento) char columna
    mov edx,8	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64

 ;   xchg bx,bx
    mov rdi, rbx
    and rdi,0x01
    cmp rdi,0x01
    je  error_pagina_presente ; si se da esto basicamente tratamos de escibir en read only, o con privilegio incorrectos
			      ;o una pagina mal creada (seteamos bit reservado)
    
    ;en el siguiente codigo estimo que no se va a querer superar la direccion de memoria lineal
    ;	0x000040000000 o sea la PML4E es la 0, la PDPTE es la 0, la pdt es la 0 con multiples entradas de pt
    ; y luego multiples paginas para cada pt  
    ;tamañy en bytes de una pt (2^9bits * 8 bytes) = 4096 => 0x1000
    
    ;mov eax,cr2
    mov rax,cr2
    ;TODO: evaluar que requerimos otra PML4e o PDPTE
    
    and rax,0x3FFFFFFF ;mato cualquier cosa superior
    
    mov r8,rax
    and r8,0x3FE00000	;enmascaro lo que no es PDE
    sar r8,0x12            ;21 - 3 debo dezplazar 20 para quedarme con el offset de pde pero con 
    ;en r8 tengo el offset de pde
    
    mov r9,rax
    and r9,0x1FF000	;enmascaro lo que no es PTE
    sar r9,0x09		;12 -3
    ;en r9 queda el offset de la pagina preparado (PTE)
    
    ;me quedo en r10 el offset puro (Page-directory-offset) y lo dezplazo en el size de las pt 0x1000
    
    ;en r10 me debo quedar con la PTx endonde esta la PDE
    mov r10,rax
    and r10,0x3FE00000	;enmascaro lo que no es PDE
    sar r10,0x09	; 21 - 12 (equivale a quedarme con el offser de Page-firectory offset y multiplicarlo por 0x1000
			; que es lo que ucupa cada pt 
    add r10,PT_BASE	;sumandole el PT_BASE ubico esta page table
    
    ;configuro la PDE
    add r8,PDT_BASE 	;
    mov  [r8], r10 ;aca debo colocar la page table PT_BASE + 0x11 dword
    or byte  [r8], 0x15;los RPL o privilegios DPL 3       
    mov dword [r8 + 4 ], 0 ;dword
							;TODO: me ubico sobre la PTE y verifico que apunte a una direccion de pagina, si no creo la pagina
    
    ;en r11 tengo la direccion fisica de la pte
    mov r11,r10
    add r11,r9
    
    ;configuro la direccion de la pagina
    mov qword rax,[var_last_created_page_phy_dir]
    mov qword [r11], rax ;coloco la direccion fisica de la pagina
    
    
    mov rdi, rbx
    and rdi,00000100b
    cmp rdi,00000100b
    je priv_user   
    or byte  [r11], 0x11;los RPL o privilegios DPL 0   
    jmp end_pte
priv_user:
    or byte  [r11], 0x15;los RPL o privilegios DPL 3    
end_pte:    
    mov dword [r11 + 4 ], 0
    
    ;incremento las variables de paginas
    add rax,0x1000
    mov [var_last_created_page_phy_dir],rax
    
    mov rax,[var_n_page_created]
    inc rax
    mov [var_n_page_created],rax
    
     
    ;verifico si me pase de la ram existente para crear paginas
    mov qword rax,[var_n_page_created]
    sal rax,12
    cmp qword rax,FISICAL_AVAIABLE_MEMORY
    jnb error_memoria_llena
    
    ;popeo y salgo
    pop r11
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
;    pop rax		;incremento el eip en 9 para que siga con laproxima instruccion
;    add rax, 1000b
;    push rax  
    ;xchg bx,bx

iretq


error_pagina_presente:
    mov edi,G_PFH_Ppci
    mov esi,5	; esi	(segundo argumento) char columna
    mov edx,9	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64

    hlt
    
error_memoria_llena:
    mov edi,G_PFH_mll
    mov esi,5	; esi	(segundo argumento) char columna
    mov edx,9	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64

    hlt
    
    
;-----------------------------------------------------------
; Handler de ServiceCall
; Recibe: por Rbx el servicio a llamar
; Devuelve: Nada
;----------------------------------------------------------- 
Int80Han:
 cmp ebx,0  ;Servicio "Random" ebx=0
 je Rand_call
 jmp finInt80
 
 Rand_call: call Rand
 
finInt80:
 iretq

