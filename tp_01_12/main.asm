;                               Trabajo Practico 1 - EJ 5                               ; 
;                                                                                       ; 
;  Alumno: Marcelo Joaquin Fernandez                                                    ;  
;  Legajo: 1403734                                                                      ; 
;  Curso: r5055                                                                         ; 
; **************************************************************************************; 

;********************************************************************************
;* Includes
;********************************************************************************


%include "include/PagingInit.mac"
%include "global.mac"




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
	
	
     



;****************Completo INICIALIZO LAS TSS's*****************************************
sys_tss:  istruc tss_struc                     ; Instanciamos TSS Sup
  at tss_struc.reg_RSP0l,        dd pila_ini_L0+STACK_SIZE
  at tss_struc.reg_RSP0u,        dd 0 
  at tss_struc.reg_IOMAP,       dw 104
  at tss_struc.IOMAP,           dd 0ffffffffh
 iend

;**************************IDT EXCEPCIONES**********************************
idt:  
	;dq 0,0
	dw ex0_DIV0Handler;  ex0_ceroHandler      ;Bits 15-0 del offset.
        dw cs_sel_64_Kernel    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Eh;			q8Dh          ;MAL DESCRIPTO A PROPOSITO XD
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
        
        

%assign i 2;
%rep    46;30	;48 lo que deberia ser hasta la int 80
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

      ;times 31 dq 0,0  ;16 bytes por compuerta.   times 18 dq 0,0    TODO CAMBIAR EESTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
         
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

Task_A: istruc task_struct
at task_struct.RSP0,          dq pila_TaskA_L0+STACK_SIZE
at task_struct.RIP,           dq Tarea_A
at task_struct.RDI,           dq 24
at task_struct.RSP,           dq pila_TaskA_L3+STACK_SIZE
at task_struct.CR3,           dq PML4_BASE_TA
at task_struct.RFLAGS,        dq 202h
at task_struct.SS0,           dw ds_sel_Kernel
at task_struct.CS,            dw cs_sel_64_App+3
at task_struct.DS,            dw ds_sel_App+3
at task_struct.SS,            dw ds_sel_App+3
at task_struct.RSI,           dq 0
iend
	

Task_B: istruc task_struct
at task_struct.RSP0,          dq pila_TaskB_L0+STACK_SIZE
at task_struct.RIP,           dq Tarea_B
at task_struct.RDI,           dq 360
at task_struct.RSP,           dq pila_TaskB_L3+STACK_SIZE
at task_struct.CR3,           dq PML4_BASE_TB
at task_struct.RFLAGS,        dq 202h
at task_struct.SS0,           dw ds_sel_Kernel
at task_struct.CS,            dw cs_sel_64_App+3
at task_struct.DS,            dw ds_sel_App+3
at task_struct.SS,            dw ds_sel_App+3
at task_struct.RSI,           dq 0
iend

;*********************Se instancian las estructuras de las tareas para el dispatcher *********************************
	
TaskIdle_disp: istruc dispatcher_task_struct       	
at dispatcher_task_struct.currentTicks,   	dw 0		;ticks actuales
at dispatcher_task_struct.prioridad_maxTicks,    dw 1		;ticks para el cambio de contexto
at dispatcher_task_struct.prioridad_orgTicks,    dw 1 		;ticks para el cambio de contexto valor por defecto
at dispatcher_task_struct.totalTicks ,    	dq 0		;ticks totales de la aplicacion
at dispatcher_task_struct.id_task,		dw 0x0000		;id de la tarea
at dispatcher_task_struct.state,		dw TASK_RUNNING	
at dispatcher_task_struct.current_task_struct,	dq TaskIdle
at dispatcher_task_struct.next,			dq Task_A_disp
iend	
	
Task_A_disp: istruc dispatcher_task_struct       	
at dispatcher_task_struct.currentTicks,  	dw 0		;ticks actuales
at dispatcher_task_struct.prioridad_maxTicks,    dw 1		;ticks para el cambio de contexto
at dispatcher_task_struct.prioridad_orgTicks,    dw 1 		;ticks para el cambio de contexto valor por defecto
at dispatcher_task_struct.totalTicks,     	dq 0		;ticks totales de la aplicacion
at dispatcher_task_struct.id_task,		dw 0x0001	;id de la tarea
at dispatcher_task_struct.state,		dw TASK_RUNNING	
at dispatcher_task_struct.current_task_struct,	dq Task_A
at dispatcher_task_struct.next,			dq Task_B_disp
iend	

Task_B_disp: istruc dispatcher_task_struct       	
at dispatcher_task_struct.currentTicks,   	dw 0		;ticks actuales
at dispatcher_task_struct.prioridad_maxTicks,    dw 1		;ticks para el cambio de contexto
at dispatcher_task_struct.prioridad_orgTicks,    dw 1 		;ticks para el cambio de contexto valor por defecto
at dispatcher_task_struct.totalTicks,     	dq 0		;ticks totales de la aplicacion
at dispatcher_task_struct.id_task,		dw 0x0002	;id de la tarea
at dispatcher_task_struct.state,		dw TASK_RUNNING	
at dispatcher_task_struct.current_task_struct,	dq Task_B
at dispatcher_task_struct.next,			dq TaskIdle_disp
iend	

	
	
;********************************PILAS de nivel 0***********************************************************				
;ALIGN 4096
ALIGN 16
pila_ini_L0: times 100h db 0               
ALIGN 16
pila_TaskA_L0: times 100h db 0
ALIGN 16
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


  call RealModePageInit
      
      
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

  
  call Task_A_PagingInit
  call Task_B_PagingInit
  
  sti		

        
mainLoop:                         ;Tarea idle del sistema		
       mov r14,1
      
;       	mov edi,TI_txt
; 	mov esi,2	; esi	(segundo argumento) char columna
; 	mov edx,9	; edx	(tercer argumento)  char fila
; 	mov ecx,111b	; ECX	(cuarto arguemto)   char color
	
; 	mov qword rbx,1 
; 	int 80		;llamo a servicio de sistema (imprimir en pantalla)
      
      
        hlt
        jmp mainLoop

TI_txt: db "TASK - IDLE:  ", 00h 


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
 
%include "include/gateA20.asm"
%include "include/utils_32.asm" 
 

%include "include/PagingInit.asm"
%include "include/isr.asm"
%include "include/utils_64.asm"


;-------------------------------------------------------------------------------------
ALIGN 4096

ALIGN 16
pila_TaskA_L3: times 100h db 0


TMM_txt: db "TASK: ID_00 - P_00 - MS_0000000000000000", 00h
TM_txt: db "00/00/00 ", 00h   
vartm_txt: db "  ", 00h   

Tarea_A:
	mov qword rbx,3
 	int 80		;llamo a servicio de sistema (jiffes)
 	
 	mov edi, eax
 	mov esi, TMM_txt + 24
 	mov edx, 16 ;(numero de digitos que me interesan)
 	mov qword rbx,2 ;llamo a conversion itoa
 	int 80	
 	
 	mov qword rbx,6
 	int 80		;llamo a servicio de sistema (get id)
 	
 	
 	mov edi, eax
 	mov esi, TMM_txt + 9
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,2 ;llamo a conversion itoa
 	int 80
 	
 	mov qword rbx,7
 	int 80		;llamo a servicio de sistema (get id)
 	
 	mov edi, eax
 	mov esi, TMM_txt + 16
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,2 ;llamo a conversion itoa
 	int 80
 	
 	mov edi,TMM_txt
 	mov esi,2	; esi	(segundo argumento) char columna
 	mov edx,8	; edx	(tercer argumento)  char fila
 	mov ecx,111b	; ECX	(cuarto arguemto)   char color
 	mov qword rbx,1 
 	int 80		;llamo a servicio de sistema (imprimir en pantalla)


    ;pido los dia
	mov qword rbx,13 ;voy a pedir  dia al sistema
	int 80	
	
	mov edi, eax
	mov esi, vartm_txt
	mov edx, 2 ;(numero de digitos que me interesan)
	mov qword rbx,5 ;llamo a conversion BCDtoa 
	int 80	
 
	mov byte al,[vartm_txt]
	mov byte [TM_txt],al
	mov byte al,[vartm_txt + 1]
	mov byte [TM_txt+1],al
 
  ;pido los mes
	mov qword rbx,14 ;voy a pedir el mes al sistema
	int 80	
 
	mov edi, eax
	mov esi, vartm_txt
	mov edx, 2 ;(numero de digitos que me interesan)
	mov qword rbx,5 ;llamo a conversion BCDtoa 
	int 80	
 	
	mov byte al,[vartm_txt]
	mov byte [TM_txt+3],al
	mov byte al,[vartm_txt + 1]
	mov byte [TM_txt+4],al
	
 ;pido la año
	mov qword rbx,15 ;voy a pedir el año al sistema
	int 80	
	
	mov edi, eax
	mov esi, vartm_txt
	mov edx, 2 ;(numero de digitos que me interesan)
	mov qword rbx,5 ;llamo a conversion BCDtoa 
	int 80	
		
	mov byte al,[vartm_txt]
	mov byte [TM_txt+6],al
	mov byte al,[vartm_txt + 1]
	mov byte [TM_txt+7],al	
 
  ;imprimo la hora
	mov edi,TM_txt
	mov esi,70	; esi	(segundo argumento) char columna
	mov edx,0	; edx	(tercer argumento)  char fila
	mov ecx,111b	; ECX	(cuarto arguemto)   char color

	mov qword rbx,1 
	int 80		;llamo a servicio de sistema (imprimir en pantalla)
	 	  
 jmp Tarea_A

;------------------------------------------------------------------------------------- 
ALIGN 4096
ALIGN 16
pila_TaskB_L3: times 100h db 0


TBB_txt: db "TASK: ID_00 - P_00 - MS_0000000000000000", 00h
TB_txt: db "24:00:00", 00h  
var_txt: db "  ", 00h


Tarea_B:
 	mov qword rbx,3
 	int 80		;llamo a servicio de sistema (jiffes)
 	
 	mov edi, eax
 	mov esi, TBB_txt + 24
 	mov edx, 16 ;(numero de digitos que me interesan)
 	mov qword rbx,2 ;llamo a conversion itoa
 	int 80	
 	
 	mov qword rbx,6
 	int 80		;llamo a servicio de sistema (get id)
 	
 	
 	mov edi, eax
 	mov esi, TBB_txt + 9
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,2 ;llamo a conversion itoa
 	int 80
 	
 	mov qword rbx,7
 	int 80		;llamo a servicio de sistema (get id)
 	
 	mov edi, eax
 	mov esi, TBB_txt + 16
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,2 ;llamo a conversion itoa
 	int 80
 	
 	mov edi,TBB_txt
 	mov esi,2	; esi	(segundo argumento) char columna
 	mov edx,9	; edx	(tercer argumento)  char fila
 	mov ecx,111b	; ECX	(cuarto arguemto)   char color
 	mov qword rbx,1 
 	int 80		;llamo a servicio de sistema (imprimir en pantalla)


    ;pido los segundos
	mov qword rbx,10 ;voy a pedir los segundos al sistema
	int 80	
	
	mov edi, eax
	mov esi, var_txt
	mov edx, 2 ;(numero de digitos que me interesan)
	mov qword rbx,5 ;llamo a conversion BCDtoa 
	int 80	
	
	mov byte al,[var_txt]
	mov byte [TB_txt+6],al
	mov byte al,[var_txt + 1]
	mov byte [TB_txt+7],al

 ;pido los minutos
	mov qword rbx,11 ;voy a pedir los segundos al sistema
	int 80	

	mov edi, eax
	mov esi, var_txt
	mov edx, 2 ;(numero de digitos que me interesan)
	mov qword rbx,5 ;llamo a conversion BCDtoa 
	int 80	
	
	mov byte al,[var_txt]
	mov byte [TB_txt+3],al
	mov byte al,[var_txt + 1]
	mov byte [TB_txt+4],al
	
 ;pido la hora
	mov qword rbx,12 ;voy a pedir los segundos al sistema
	int 80	
	
	mov edi, eax
	mov esi, var_txt
	mov edx, 2 ;(numero de digitos que me interesan)
	mov qword rbx,5 ;llamo a conversion BCDtoa 
	int 80	
	
	mov byte al,[var_txt]
	mov byte [TB_txt+0],al
	mov byte al,[var_txt + 1]
	mov byte [TB_txt+1],al	
 
  ;imprimo la hora
	mov edi,TB_txt
	mov esi,70	; esi	(segundo argumento) char columna
	mov edx,1	; edx	(tercer argumento)  char fila
	mov ecx,111b	; ECX	(cuarto arguemto)   char color

	mov qword rbx,1 
	int 80		;llamo a servicio de sistema (imprimir en pantalla)
		
 jmp Tarea_B
 

