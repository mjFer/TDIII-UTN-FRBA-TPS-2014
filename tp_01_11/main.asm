;                               Trabajo Practico 1 - EJ 5                               ; 
;                                                                                       ; 
;  Alumno: Marcelo Joaquin Fernandez                                                    ;  
;  Legajo: 1403734                                                                      ; 
;  Curso: r5055                                                                         ; 
; **************************************************************************************; 


;********************************************************************************
;* Macros																		*
;********************************************************************************

; 0x1F9ffff0 		maxima direccion de memoria lineal accesible y direccionable si PML4_BASE = 0x0x100000, 
;			fuera de esto me crea la pt correspondiente fuera de los 2 megas de identity mapping y explota
; 0x3E300000 		maxima direccion de memoria lineal accesible y direccionable si PML4_BASE = 0xA000, 
;			fuera de esto me crea la pt correspondiente fuera de los 2 megas de identity mapping y explota

%define DUP   	0xFFFF;
%define _PML4_BASE   	0x0010;
%define	_PDPT_BASE  	_PML4_BASE + 0x1000	;ubicacion de la Page Directory Pointer Table
%define	_PDT_BASE   	_PDPT_BASE + 0x1000	;ubicacion de la Page Directory Table
%define	_PT_BASE	_PDT_BASE + 0x1000	;ubicacion de la Page Table

%define PML4_BASE   	0x100000 ; en el primer mega de memoria			0xA000 ubicacion de la Page Map Level 4
%define	PDPT_BASE  	PML4_BASE + 0x1000	;ubicacion de la Page Directory Pointer Table
%define	PDT_BASE   	PDPT_BASE + 0x1000	;ubicacion de la Page Directory Table
%define	PT_BASE		PDT_BASE + 0x1000	;ubicacion de la Page Table

%define	USER_PAGE	0xA000	;ubicacion zona usuario


%define	VIDEO_BASE	0x200000
%define BREAKPOINT	xchg bx, bx

%define BASE_PAGES PT_BASE + 0x200000		;obseteo las paginas por encima de 512 pt para poder administrar 512 megas de ram 



BITS 16 
[ORG KERNEL_MEMORY]

ALIGN 4096
jmp Inicio

gdt:

db 0,0,0,0,0,0,0,0   ;dejar vacio un descriptor


cs_sel_64_Kernel  equ $-gdt
        db 0xFF         ;Bits 7-0 del limite (no usado en 64 bits).
        db 0xFF         ;Bits 15-8 del limite (no usado en 64 bits).
        db 0x00         ;Bits 7-0 de la base (no usado en 64 bits).
        db 0x00         ;Bits 15-8 de la base (no usado en 64 bits).
        db 0x00         ;Bits 23-16 de la base (no usado en 64 bits).
      
	db 0x9A		;Byte de derechos de acceso:
			 ;15 Bit 7=1: Segmento Presente.			P ( Present)
			 ;Bits 6,5=00: Nivel de Privilegio cero.		(DPL)
			 ;Bit 4=1: Segmento de codigo o datos.			S ( 0 system; 1 code or data)
			 ;Bit 3=1: Descriptor correspondiente a codigo.		(Type)
			 ;Bit 2=0: Segmento no conforme.			(Type)
			 ;Bit 1=1: El segmento de codigo se puede leer.		(Type)
			 ;Bit 0=0: El segmento no fue accedido.			(Type)
			    
        db 0xAF         ;Bit 7=1: Granularidad (no usado en 64 bits).
                        ;Bit 6,5=01: Segmento de 64 bits (en modo largo).
                        ;Bit 4=0: No usado.
                        ;Bits 3-0=1111: Bits 19-16 del limite (no usados
                        ;en modo largo). 
        db 0x00         ;Bits 31-24 de la base (no usado en 64 bits).
        
cs_sel_64_App  equ $-gdt
        db 0xFF         ;Bits 7-0 del limite (no usado en 64 bits).
        db 0xFF         ;Bits 15-8 del limite (no usado en 64 bits).
        db 0x00         ;Bits 7-0 de la base (no usado en 64 bits).
        db 0x00         ;Bits 15-8 de la base (no usado en 64 bits).
        db 0x00         ;Bits 23-16 de la base (no usado en 64 bits).
     
	db 0xFA		;Byte de derechos de acceso:
			 ;15 Bit 7=1: Segmento Presente.			P ( Present)
			 ;Bits 6,5=00: Nivel de Privilegio cero.		(DPL)
			 ;Bit 4=1: Segmento de codigo o datos.			S ( 0 system; 1 code or data)
			 ;Bit 3=1: Descriptor correspondiente a codigo.		(Type)
			 ;Bit 2=0: Segmento no conforme.			(Type)
			 ;Bit 1=1: El segmento de codigo se puede leer.		(Type)
			 ;Bit 0=0: El segmento no fue accedido.			(Type)
			    
        db 0xAF         ;Bit 7=1: Granularidad (no usado en 64 bits).
                        ;Bit 6,5=01: Segmento de 64 bits (en modo largo).
                        ;Bit 4=0: No usado.
                        ;Bits 3-0=1111: Bits 19-16 del limite (no usados
                        ;en modo largo). 
        db 0x00         ;Bits 31-24 de la base (no usado en 64 bits).


ds_sel_Kernel  equ $-gdt
        db 0xFF         ;Bits 7-0 del limite (no usado en 64 bits).
        db 0xFF         ;Bits 15-8 del limite (no usado en 64 bits).
        db 0x00         ;Bits 7-0 de la base (no usado en 64 bits).
        db 0x00         ;Bits 15-8 de la base (no usado en 64 bits).
        db 0x00         ;Bits 23-16 de la base (no usado en 64 bits).
	db 0x92		;Byte de derechos de acceso:
			;Bit 7=1: Segmento Presente.
			;Bits 6,5=00: Nivel de Privilegio cero.
			;Bit 4=1: Segmento de codigo o datos.
			;Bit 3=0: Descriptor correspondiente a datos.
			;Bit 2=0: Offset <= Limite. 
			;Bit 1=1: El segmento de datos se puede escribir.
			;Bit 0=0: El segmento no fue accedido.
        db 0xCF         ;Bit 7=0: Granularidad (no usado en 64 bits).
                        ;Bit 6,5=10: Segmento de 32 bits.
			;Bit 4=0: No usado.
                        ;Bits 3-0=1111: Bits 19-16 del limite (no usados
                        ;en modo largo). 
        db 0x00         ;Bits 31-24 de la base (no usado en 64 bits).

ds_sel_App  equ $-gdt
        db 0xFF         ;Bits 7-0 del limite (no usado en 64 bits).
        db 0xFF         ;Bits 15-8 del limite (no usado en 64 bits).
        db 0x00         ;Bits 7-0 de la base (no usado en 64 bits).
        db 0x00         ;Bits 15-8 de la base (no usado en 64 bits).
        db 0x00         ;Bits 23-16 de la base (no usado en 64 bits).
	db 0xF2		;Byte de derechos de acceso:
			;Bit 7=1: Segmento Presente.
			;Bits 6,5=00: Nivel de Privilegio cero.
			;Bit 4=1: Segmento de codigo o datos.
			;Bit 3=0: Descriptor correspondiente a datos.
			;Bit 2=0: Offset <= Limite. 
			;Bit 1=1: El segmento de datos se puede escribir.
			;Bit 0=0: El segmento no fue accedido.
        db 0xCF         ;Bit 7=0: Granularidad (no usado en 64 bits).
                        ;Bit 6,5=10: Segmento de 32 bits.
			;Bit 4=0: No usado.
                        ;Bits 3-0=1111: Bits 19-16 del limite (no usados
                        ;en modo largo). 
        db 0x00         ;Bits 31-24 de la base (no usado en 64 bits).        

tss_ini         equ     $-gdt   ;tss de la tarea inicial (idle) DPL=0 
tss0:           
		dw      0x0067
                dw      sys_tss
                db      0x00
                db      10001001b
                db      0x00
                db      0x00
                dq      0x0000000000000000        
          
        
long_gdt equ $-gdt		;longitud gdt

        
valor_gdtr:     dw long_gdt-1   
	dd gdt
	
	
     

;***************************DECLARACION DE ESTRUCTURA PARA TAREA Y TSS*******************/

struc tss_struc                ;TSS (Definicion de tipo)
             resd 1
.reg_RSP0l   resd 1
.reg_RSP0u   resd 1
.reg_RSP1l   resd 1
.reg_RSP1u   resd 1
.reg_RSP2l   resd 1
.reg_RSP2u   resd 1
             resd 1
             resd 1
.reg_IST1l   resd 1
.reg_IST1u   resd 1
.reg_IST2l   resd 1
.reg_IST2u   resd 1
.reg_IST3l   resd 1
.reg_IST3u   resd 1
.reg_IST4l   resd 1
.reg_IST4u   resd 1
.reg_IST5l   resd 1
.reg_IST5u   resd 1
.reg_IST6l   resd 1
.reg_IST6u   resd 1
.reg_IST7l   resd 1
.reg_IST7u   resd 1
             resd 1
             resd 1
.reg_IOMAP   resw 1
.IOMAP       resd 1
endstruc

struc task_struct       ;Estructura de tarea del scheduller (Definicion de tipo)
.rax        resq 1
.rbx        resq 1
.rcx        resq 1
.rdx        resq 1
.RSP0       resq 1
.RIP        resq 1
.RDI        resq 1
.RSP        resq 1
.CR3        resq 1
.RFLAGS     resq 1
.SS0        resw 1
.CS         resw 1
.DS         resw 1
.SS         resw 1

;.RBP	resq 1
;.RSI	resq 1
;.R9	resq 1
;.R10	resq 1
;.R11	resq 1
;.R12	resq 1	
;.R13	resq 1
;.R14	resq 1
;.R15	resq 1

;.ES	resw 1
;.FS	resw 1
;.GS	resw 1


endstruc

struc dispatcher_task_struct       	;Estructura de tarea del dispatcher (Definicion de tipo)
.currentTicks   	resd 1		;ticks actuales
.prioridad_maxTicks     resd 1		;ticks para el cambio de contexto
.prioridad_orgTicks     resd 1		;ticks para el cambio de contexto valor por defecto
.totalTicks     	resq 1		;ticks totales de la aplicacion
.id_task		resw 1		;id de la tarea

endstruc


;****************Completo INICIALIZO LAS TSS's*****************************************
sys_tss:  istruc tss_struc                     ; Instanciamos TSS Sup
  at tss_struc.reg_RSP0l,        dd pila_ini_L0+0e0h
  at tss_struc.reg_RSP0u,        dd 0 
  at tss_struc.reg_IOMAP,       dw 104
  at tss_struc.IOMAP,           dd 0ffffffffh
 iend

;**************************IDT EXCEPCIONES**********************************
idt:  
	;dq 0,0
	dw 0x0000;  ex0_ceroHandler      ;Bits 15-0 del offset.
        dw cs_sel_64_Kernel    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Dh          ;MAL DESCRIPTO A PROPOSITO XD
        dw 0x0000       ;Bits 31-16 del offset.
        dd 0x00000000   ;Bits 63-32 del offset.
        dd 0x00000000   ;Reservado.
	
	
	times 2 dq 0,0  ;16 bytes por compuerta.
	
	;breakpoint
	dw ex3_BPHandler      ;Bits 15-0 del offset.
        dw cs_sel_64_Kernel    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Eh          ;Compuerta de interrupcion de 64 bits.
        dw 0            ;Bits 31-16 del offset.
        dd 0            ;Bits 63-32 del offset.
        dd 0            ;Reservado.
	
	times 4 dq 0,0
	dw ex8_DoubleFaultHandler      ;Bits 15-0 del offset.
        dw cs_sel_64_Kernel    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Eh          ;Compuerta de interrupcion de 64 bits.
        dw 0            ;Bits 31-16 del offset.
        dd 0            ;Bits 63-32 del offset.
        dd 0            ;Reservado.
	times 4 dq 0,0
	;gp foult
	dw ex13_GeneralProtectionHandler      ;Bits 15-0 del offset.
        dw cs_sel_64_Kernel    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Eh          ;Compuerta de interrupcion de 64 bits.
        dw 0            ;Bits 31-16 del offset.
        dd 0            ;Bits 63-32 del offset.
        dd 0            ;Reservado.
	;pf
	dw ex14_PageFaultProtectionHandler      ;Bits 15-0 del offset.
        dw cs_sel_64_Kernel    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Eh          ;Compuerta de interrupcion de 64 bits.
        dw 0            ;Bits 31-16 del offset.
        dd 0            ;Bits 63-32 del offset.
        dd 0            ;Reservado.
	times 17 dq 0,0
	
;****************************INTERRUPCIONES**************************************
        dw int0_TimerHandler      ;Bits 15-0 del offset.
        dw cs_sel_64_Kernel    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Eh          ;Compuerta de interrupcion de 64 bits.
        dw 0            ;Bits 31-16 del offset.
        dd 0            ;Bits 63-32 del offset.
        dd 0            ;Reservado.
	
	dw int9_keyboardHandler      ;Bits 15-0 del offset.
        dw cs_sel_64_Kernel    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Eh          ;Compuerta de interrupcion de 64 bits.
        dw 0            ;Bits 31-16 del offset.
        dd 0            ;Bits 63-32 del offset.
        dd 0            ;Reservado.
        
        

%assign i 0
%rep    15;30	;48 lo que deberia ser hasta la int 80
	; Compuerta de interrupcion de 16 bytes correspondiente a INT i.
        dw int_%+i      ;Bits 15-0 del offset.tá desactivado.
        dw cs_sel_64_Kernel    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Eh          ;Compuerta de interrupcion de 64 bits.
        dw 0            ;Bits 31-16 del offset.
        dd 0            ;Bits 63-32 del offset.
        dd 0            ;Reservado.
%assign i i+1
%endrep     

      times 31 dq 0,0  ;16 bytes por compuerta.   times 18 dq 0,0    TODO CAMBIAR EESTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
         
       dw Int80Han		; Descriptor de la int 80 (Servicios Generales de sistema)
       dw cs_sel_64_Kernel
       db 0x00
       db 11101110b	;	P = 1 DPL = 11
    ;   db 0x00
    ;   db 0x00
       dw 0x0000            ;Bits 31-16 del offset.
       dd 0x00000000            ;Bits 63-32 del offset.
       dd 0x00000000            ;Reservado.

idtsize equ $-idt
idtr:     dw idtsize-1
          dd idt	
	

;*********************Se instancian las estructuras de las tareas*********************************
TaskIdle: istruc task_struct
  at task_struct.CR3,           dq PML4_BASE
  at task_struct.SS,            dw ds_sel_Kernel
iend

TaskMalloc: istruc task_struct
at task_struct.RSP0,          dq pila_TaskMalloc_L0+0e0h
at task_struct.RIP,           dq Tarea_Malloc
at task_struct.RDI,           dq 24
at task_struct.RSP,           dq pila_TaskMalloc_L3+0e0h
at task_struct.CR3,           dq PML4_BASE
at task_struct.RFLAGS,        dq 202h
at task_struct.SS0,           dw ds_sel_Kernel
at task_struct.CS,            dw cs_sel_64_App+3
at task_struct.DS,            dw ds_sel_App+3
at task_struct.SS,            dw ds_sel_App+3
iend
	

Task_B: istruc task_struct
at task_struct.RSP0,          dq pila_TaskB_L0+0e0h
at task_struct.RIP,           dq Tarea_B
at task_struct.RDI,           dq 360
at task_struct.RSP,           dq pila_TaskB_L3+0e0h
at task_struct.CR3,           dq PML4_BASE
at task_struct.RFLAGS,        dq 202h
at task_struct.SS0,           dw ds_sel_Kernel
at task_struct.CS,            dw cs_sel_64_App+3
at task_struct.DS,            dw ds_sel_App+3
at task_struct.SS,            dw ds_sel_App+3
iend
	
	
;********************************PILAS de nivel 0***********************************************************				
ALIGN 8
pila_ini_L0: times 100h db 0               
ALIGN 8
pila_TaskMalloc_L0: times 100h db 0
ALIGN 8
pila_TaskB_L0: times 100h db 0

;******************************** Algunos datos***********************************************************			

texto: db "UTN-2014-TDIII------ Marcelo J Fernandez", 00h ;
txt_pae_av: db "..CPUID - PAE : Available", 00h
txt_lme_av: db "..CPUID - LME : Available", 00h
txt_pae_nav: db "..CPUID - PAE : Not Available!!", 00h
txt_lme_nav: db "..CPUID - LME : Not Available!!", 00h


Inicio:
  
  cli
  
  ;LLamo a un Clear Screen
  call clrScr_16

  ;xchg bx,bx
  ;llamo a la rutina de print 
  mov edi,texto
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,0	; edx	(tercer argumento)  char fila
  mov ecx,111b	; ECX	(cuarto arguemto)   char color
  call Print_16
  
  
  lgdt [valor_gdtr] ;cargo la gdt
  ;****************Compruebo PAE**************************** 
  mov eax,1
  CPUID
  and edx,1000000b
  cmp edx,1000000b
  jnz NO_PAE

  ;llamo a la rutina de print
  mov edi,txt_pae_av
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,1	; edx	(tercer argumento)  char fila
  mov ecx,010b	; ECX	(cuarto arguemto)   char color
  call Print_16


  ;****************Seteo PAE********************************
  mov eax,cr4			;leo el registro CR4
  or eax,00100000b		;or flag de PAE
  mov cr4,eax			;Seteo CR4


  ;INICIO Creacion de paginas
					      ;notar que estoy en modo real por lo que las direcciones salen de la suma de DUP:_PML4_BASE 
	  xor eax,eax
	  mov eax, DUP
	  mov ds, eax
	  mov dword [DS:_PML4_BASE],PDPT_BASE + 0x15;0x11		;si no anda ver que puede estar aca el problema
	  mov dword [DS:_PML4_BASE + 4], 0
	  mov dword [DS:_PDPT_BASE],PDT_BASE + 0x15;0x11
	  mov dword [DS:_PDPT_BASE + 4], 0
	 
	  mov dword [DS:_PDT_BASE],PT_BASE + 0x15;0x11
	  mov dword [DS:_PDT_BASE + 4], 0
	 
	  mov dword [DS:_PDT_BASE + 8],PT_BASE + 0x1000 + 0x15;0x11
	  mov dword [DS:_PDT_BASE + 12], 0

	  ;Aca arrancamos a crear las paginas con un loop
	  mov ecx, 1024      ;creo 1024 entradas, (2 pt) 512 por pt
	  mov eax, 01000h + 0x07;0x01
	  mov edi, _PT_BASE + 8
  pageloop:
	  mov dword [DS:edi],eax
	  mov dword [DS:edi + 4],0
	  add edi, 8
	  add eax, 1000h
	  loop pageloop
	  
      
      mov dword [DS:_PT_BASE + 0x40 ],0x8000 + 1
      mov dword [DS:_PT_BASE + 4], 0	    
      
      mov dword [DS:_PT_BASE + 0x48 ],0x9000 + 1
      mov dword [DS:_PT_BASE + 4], 0	
	  
	  
      ;pagina de usuario para las tareas en 0xA000
      ;mov dword [DS:_PT_BASE + 0x50 ],USER_PAGE + 7;0x07	;x50 es la 0xa000
      ;mov dword [DS:_PT_BASE + 4], 0	  
      
      ;pagina de usuario para las tareas en 0xA000
      ;mov dword [DS:_PT_BASE + 0x58 ],0xb000 + 5;0x07	;x50 es la 0xa000
      ;mov dword [DS:_PT_BASE + 4], 0	  
      
      ;en la 0x0000 pagino la b8000 de video
      mov dword [DS:_PT_BASE],0b8000h + 0x01
      mov dword [DS:_PT_BASE + 4], 0
  ;FIN CREACION PAGINAS
      xor eax,eax
      mov ds, eax
      
      
  mov eax, DUP
  shl eax,4
  add eax,_PML4_BASE
  mov cr3,eax
  xor eax,eax


  
  ;reprogramo el pic
  call Pic_Reprograming
  mov AL, 11111100b 		;desabilito todas las interrupciones del PIC1	 ;11111100b  http://www.brokenthorn.com/Resources/OSDevPic.html
  out 21h,al
  mov AL, 0xFF 		;desabilito todas las interrupciones del PIC2 
  out 0xA1,al
  
  ;programo el timer para interrumpir cada 1ms aprox
  call Timer_Repr
  
  lidt [idtr]


  ;Comprueba si LME esta como spec en el micro
  mov eax,0x80000001
  CPUID
  and edx,0x20000000		;bit 29  
  cmp edx,0x20000000
  jnz NO_LME

  ;print
  mov edi,txt_lme_av
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,2	; edx	(tercer argumento)  char fila
  mov ecx,010b	; ECX	(cuarto arguemto)   char color
  call Print_16


  mov ecx,0x0C0000080      	;seteo para leer EFER de la MSR
  rdmsr                  		;pedido de lectura a MSR
  or eax, 0x00000100       	;Seteo LME (Long mode enable)
  wrmsr              		;seteo en la MSR el registro EFER


  
  
  ;Ver Manual intel 2.8 V3a y 9.12 V3a para ver bien secuencia de cambio de modos
  mov eax,cr0                 ;seteo el bit de paginacion y de modo protegido
  or eax,80000001h           
  mov cr0,eax 
  jmp  cs_sel_64_Kernel:modo_largo    
  
  
  [bits 64]
modo_largo: 
  mov rsp,pila_ini_L0 + 100 			;seteo la direccion de la pila +100 por que se carga de forma inversa
  mov ax,ds_sel_Kernel                ;cargo el descriptor de datos
  mov ds,ax					;cargo ds con el segundo descriptor
  mov ss,ax					;cargo ss con el descriptor de datos (para la pila)
  mov es,ax
  
  ;xor ax,ax
  ;mov ss,ax
  mov ax,tss_ini
  ltr ax

  sti		


;***********************Cargo el contexto de la tarea
    mov rsp,[TaskMalloc+task_struct.RSP0]
    mov rbx,rsp
    mov [sys_tss+tss_struc.reg_RSP0l],ebx
    mov rbx,0
    mov bx,[TaskMalloc+task_struct.SS] 
    push rbx
    mov rbx,[TaskMalloc+task_struct.RSP]
    push rbx
    mov ds,[TaskMalloc+task_struct.DS]
    mov rbx,[TaskMalloc+task_struct.RFLAGS]
    push rbx
    mov rbx,0
    mov bx,[TaskMalloc+task_struct.CS]
    push rbx
    mov rbx,[TaskMalloc+task_struct.RIP]
    push rbx
    mov rcx,[TaskMalloc+task_struct.rcx]
    mov rdx,[TaskMalloc+task_struct.rdx]
    mov rdi,[TaskMalloc+task_struct.RDI]
    mov rbx,0000
    mov rbx,[TaskMalloc+task_struct.CR3]   
    mov cr3,rbx
    iretq
    
        
mainLoop:                         ;Tarea idle del sistema		
        hlt
        jmp mainLoop




[bits 16]

NO_PAE:         ;aunque es al pedo para el debugging me caeria aca si no tuviese pae
  ;llamo a la rutina de print
  mov edi,txt_pae_nav
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,2	; edx	(tercer argumento)  char fila
  mov ecx,100b	; ECX	(cuarto arguemto)   char color
  call Print_16
  hlt
  jmp NO_PAE

NO_LME:         ;aunque es al pedo para el debugging me caeria aca si no tuviese pae
    ;llamo a la rutina de print
  mov edi,txt_lme_nav
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,2	; edx	(tercer argumento)  char fila
  mov ecx,100b	; ECX	(cuarto arguemto)   char color
  call Print_16
  hlt
  jmp NO_LME
    

%include "include/isr.asm"
%include "include/gateA20.asm"

%include "include/utils_32.asm"
%include "include/utils_64.asm"




ALIGN 4096

ALIGN 8
pila_TaskMalloc_L3: times 100h db 0

TM_txt: db "TASK: MALLOC!!! ", 00h        
        
Tarea_Malloc:

	mov edi,TM_txt
	mov esi,2	; esi	(segundo argumento) char columna
	mov edx,10	; edx	(tercer argumento)  char fila
	mov ecx,111b	; ECX	(cuarto arguemto)   char color
	
	mov qword rbx,1 
	int 80		;llamo a servicio de sistema (imprimir en pantalla)

	
	
_Tarea_Malloc:
	  ;la semilla del rand va a ser rax que va a ir tomando numeros random
	  mov rax,r11
	  mov qword rbx,0 
	  int 80		;con rbx en 0 llamo a la funcion random
	      
	  and rax,0x000000003FFFFFFF  	;pido hasta lineales de 1g de long	0x000000000FFFFFFF ; lo limito a 256megas de ram    0x000000003FFFFFFF  
	  cmp qword rax,0x30C000	;hago que siempre este por encima de los 2 megas asi no me jode con los descriptores de sistema
	  jl cont
	  
	  mov  rbx,[rax]	;uso la direccion

cont:	  
	  inc r11
	 	  
 jmp _Tarea_Malloc

 
ALIGN 4096

ALIGN 8
pila_TaskB_L3: times 100h db 0

TB_txt: db "TASK: B!!! ", 00h  
test_txt: db "000000000", 00h


Tarea_B:
      ;imprimo que esta corriendo la tarea X
	mov edi,TB_txt
	mov esi,2	; esi	(segundo argumento) char columna
	mov edx,11	; edx	(tercer argumento)  char fila
	mov ecx,111b	; ECX	(cuarto arguemto)   char color
	
	mov qword rbx,1 
	int 80		;llamo a servicio de sistema (imprimir en pantalla)
	
	
	
    ;pido los segundos
	;mov qword rbx,10 ;voy a pedir los segundos al sistema
	;int 80	
	
	;xchg bx,bx
	
	;mov edi, eax
	;mov esi, test_txt
	;mov qword rbx,2 ;llamo a conversion itoa
	;int 80	
	
	;mov edi,test_txt
	;mov esi,10	; esi	(segundo argumento) char columna
	;mov edx,15	; edx	(tercer argumento)  char fila
	;mov ecx,111b	; ECX	(cuarto arguemto)   char color
	
	;mov qword rbx,1 
	;int 80		;llamo a servicio de sistema (imprimir en pantalla)
	
	

 jmp Tarea_B
