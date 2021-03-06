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
%include "include/isr_svc.mac"



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
	dw ex0_DIV0Handler;  ;Bits 15-0 del offset.
        dw 0;cs_sel_64_Kernel  ;Selector del segmento de codigo.
        db 0                 ;Cantidad de palabras que ocupan los parametros.
        db 8Eh;			
        dw 0x0000            ;Bits 31-16 del offset.
        dd 0x00000000        ;Bits 63-32 del offset.
        dd 0x00000000        ;Reservado.
	
	;Debug
	dw ex3_BPHandler      	;Bits 15-0 del offset.
        dw cs_sel_64_Kernel    	;Selector del segmento de codigo.
        db 0            	;Cantidad de palabras que ocupan los parametros.
        db 8Eh;8Fh          	;Compuerta de interrupcion de 64 bits.
        dw 0            	;Bits 31-16 del offset.
        dd 0            	;Bits 63-32 del offset.
        dd 0   
        
	times 2 dq 0,0  ;16 bytes por compuerta.			
	
         ;Reservado.
	
	times 3 dq 0,0
	
	dw ex7_NMHandler;       ;Bits 15-0 del offset.
        dw cs_sel_64_Kernel     ;Selector del segmento de codigo.
        db 0            	;Cantidad de palabras que ocupan los parametros.
        db 8Eh			
        dw 0x0000       	;Bits 31-16 del offset.
        dd 0x00000000   	;Bits 63-32 del offset.
        dd 0x00000000   	;Reservado.
	
	dw ex8_DoubleFaultHandler      ;Bits 15-0 del offset.
        dw cs_sel_64_Kernel    ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 8Eh          ;Compuerta de interrupcion de 64 bits.
        dw 0            ;Bits 31-16 del offset.
        dd 0            ;Bits 63-32 del offset.
        dd 0            ;Reservado.
	times 4 dq 0,0
	;gp fault
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
at task_struct.RIP,           dq Tarea_Malloc
at task_struct.RDI,           dq 24
at task_struct.RSP,           dq pila_TaskA_L3+STACK_SIZE
at task_struct.CR3,           dq PML4_BASE_TA
at task_struct.RFLAGS,        dq 202h
at task_struct.MMX,           dq 0
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
at task_struct.MMX,           dq 0
at task_struct.SS0,           dw ds_sel_Kernel
at task_struct.CS,            dw cs_sel_64_App+3
at task_struct.DS,            dw ds_sel_App+3
at task_struct.SS,            dw ds_sel_App+3
at task_struct.RSI,           dq 0
iend

Task_C: istruc task_struct
at task_struct.RSP0,          dq pila_TaskC_L0+STACK_SIZE
at task_struct.RIP,           dq Tarea_C
at task_struct.RDI,           dq 360
at task_struct.RSP,           dq pila_TaskC_L3+STACK_SIZE
at task_struct.CR3,           dq PML4_BASE_TC
at task_struct.RFLAGS,        dq 202h
at task_struct.MMX,           dq 0
at task_struct.SS0,           dw ds_sel_Kernel
at task_struct.CS,            dw cs_sel_64_App+3
at task_struct.DS,            dw ds_sel_App+3
at task_struct.SS,            dw ds_sel_App+3
at task_struct.RSI,           dq 0
iend

Task_D: istruc task_struct
at task_struct.RSP0,          dq pila_TaskD_L0+STACK_SIZE
at task_struct.RIP,           dq Tarea_D
at task_struct.RDI,           dq 360
at task_struct.RSP,           dq pila_TaskD_L3+STACK_SIZE
at task_struct.CR3,           dq PML4_BASE_TD
at task_struct.RFLAGS,        dq 202h
at task_struct.MMX,           dq 0
at task_struct.SS0,           dw ds_sel_Kernel
at task_struct.CS,            dw cs_sel_64_App+3
at task_struct.DS,            dw ds_sel_App+3
at task_struct.SS,            dw ds_sel_App+3
at task_struct.RSI,           dq 0
iend

Task_E: istruc task_struct
at task_struct.RSP0,          dq pila_TaskE_L0+STACK_SIZE
at task_struct.RIP,           dq Tarea_E
at task_struct.RDI,           dq 360
at task_struct.RSP,           dq pila_TaskE_L3+STACK_SIZE
at task_struct.CR3,           dq PML4_BASE_TE
at task_struct.RFLAGS,        dq 202h
at task_struct.MMX,           dq SIMD_R_TaskE
at task_struct.SS0,           dw ds_sel_Kernel
at task_struct.CS,            dw cs_sel_64_App+3
at task_struct.DS,            dw ds_sel_App+3
at task_struct.SS,            dw ds_sel_App+3
at task_struct.RSI,           dq 0
iend

Task_F: istruc task_struct
at task_struct.RSP0,          dq pila_TaskF_L0+STACK_SIZE
at task_struct.RIP,           dq Tarea_F
at task_struct.RDI,           dq 360
at task_struct.RSP,           dq pila_TaskF_L3+STACK_SIZE
at task_struct.CR3,           dq PML4_BASE_TF
at task_struct.RFLAGS,        dq 202h
at task_struct.MMX,           dq SIMD_R_TaskF
at task_struct.SS0,           dw ds_sel_Kernel
at task_struct.CS,            dw cs_sel_64_App+3
at task_struct.DS,            dw ds_sel_App+3
at task_struct.SS,            dw ds_sel_App+3
at task_struct.RSI,           dq 0

iend
	
;*********************Se instancian las estructuras de las tareas para el dispatcher *********************************
;TODO: en un futuro estaria bueno que esta estructura se genere dinamicamente permitiendo crear y destruir N tareas	
TaskIdle_disp: istruc dispatcher_task_struct       	
at dispatcher_task_struct.currentTicks,   	dw 0		;ticks actuales
at dispatcher_task_struct.prioridad_maxTicks,    dw 1		;ticks para el cambio de contexto
at dispatcher_task_struct.prioridad_orgTicks,    dw 1 		;ticks para el cambio de contexto valor por defecto
at dispatcher_task_struct.totalTicks ,    	dq 0		;ticks totales de la aplicacion
at dispatcher_task_struct.sleepMS,		dq 0
at dispatcher_task_struct.id_task,		dw 0x0000		;id de la tarea
at dispatcher_task_struct.state,		dw TASK_RUNNING	
at dispatcher_task_struct.current_task_struct,	dq TaskIdle
at dispatcher_task_struct.next,			dq Task_A_disp
iend	
	
Task_A_disp: istruc dispatcher_task_struct       	
at dispatcher_task_struct.currentTicks,  	dw 0		;ticks actuales
at dispatcher_task_struct.prioridad_maxTicks,    dw 20		;ticks para el cambio de contexto
at dispatcher_task_struct.prioridad_orgTicks,    dw 20 		;ticks para el cambio de contexto valor por defecto
at dispatcher_task_struct.totalTicks,     	dq 0		;ticks totales de la aplicacion
at dispatcher_task_struct.sleepMS,		dq 0
at dispatcher_task_struct.id_task,		dw 0x0001	;id de la tarea
at dispatcher_task_struct.state,		dw TASK_RUNNING	
at dispatcher_task_struct.current_task_struct,	dq Task_A
at dispatcher_task_struct.next,			dq Task_B_disp
iend	

Task_B_disp: istruc dispatcher_task_struct       	
at dispatcher_task_struct.currentTicks,   	dw 0		;ticks actuales
at dispatcher_task_struct.prioridad_maxTicks,    dw 20		;ticks para el cambio de contexto
at dispatcher_task_struct.prioridad_orgTicks,    dw 20 		;ticks para el cambio de contexto valor por defecto
at dispatcher_task_struct.totalTicks,     	dq 0		;ticks totales de la aplicacion
at dispatcher_task_struct.sleepMS,		dq 0
at dispatcher_task_struct.id_task,		dw 0x0002	;id de la tarea
at dispatcher_task_struct.state,		dw TASK_RUNNING	
at dispatcher_task_struct.current_task_struct,	dq Task_B
at dispatcher_task_struct.next,			dq Task_C_disp
iend	


Task_C_disp: istruc dispatcher_task_struct       	
at dispatcher_task_struct.currentTicks,   	dw 0		;ticks actuales
at dispatcher_task_struct.prioridad_maxTicks,    dw 20		;ticks para el cambio de contexto
at dispatcher_task_struct.prioridad_orgTicks,    dw 20 		;ticks para el cambio de contexto valor por defecto
at dispatcher_task_struct.totalTicks,     	dq 0		;ticks totales de la aplicacion
at dispatcher_task_struct.sleepMS,		dq 0
at dispatcher_task_struct.id_task,		dw 0x0003	;id de la tarea
at dispatcher_task_struct.state,		dw TASK_RUNNING	
at dispatcher_task_struct.current_task_struct,	dq Task_C
at dispatcher_task_struct.next,			dq Task_D_disp;Task_D_disp
iend	
	
Task_D_disp: istruc dispatcher_task_struct       	
at dispatcher_task_struct.currentTicks,   	dw 0		;ticks actuales
at dispatcher_task_struct.prioridad_maxTicks,    dw 20		;ticks para el cambio de contexto
at dispatcher_task_struct.prioridad_orgTicks,    dw 20 		;ticks para el cambio de contexto valor por defecto
at dispatcher_task_struct.totalTicks,     	dq 0		;ticks totales de la aplicacion
at dispatcher_task_struct.sleepMS,		dq 0
at dispatcher_task_struct.id_task,		dw 0x0004	;id de la tarea
at dispatcher_task_struct.state,		dw TASK_RUNNING	
at dispatcher_task_struct.current_task_struct,	dq Task_D
at dispatcher_task_struct.next,			dq Task_E_disp
iend	

Task_E_disp: istruc dispatcher_task_struct       	
at dispatcher_task_struct.currentTicks,   	dw 0		;ticks actuales
at dispatcher_task_struct.prioridad_maxTicks,    dw 20		;ticks para el cambio de contexto
at dispatcher_task_struct.prioridad_orgTicks,    dw 20 		;ticks para el cambio de contexto valor por defecto
at dispatcher_task_struct.totalTicks,     	dq 0		;ticks totales de la aplicacion
at dispatcher_task_struct.sleepMS,		dq 0
at dispatcher_task_struct.id_task,		dw 0x0005	;id de la tarea
at dispatcher_task_struct.state,		dw TASK_RUNNING	
at dispatcher_task_struct.current_task_struct,	dq Task_E
at dispatcher_task_struct.next,			dq Task_F_disp
iend	
	
Task_F_disp: istruc dispatcher_task_struct       	
at dispatcher_task_struct.currentTicks,   	dw 0		;ticks actuales
at dispatcher_task_struct.prioridad_maxTicks,    dw 20		;ticks para el cambio de contexto
at dispatcher_task_struct.prioridad_orgTicks,    dw 20 		;ticks para el cambio de contexto valor por defecto
at dispatcher_task_struct.totalTicks,     	dq 0		;ticks totales de la aplicacion
at dispatcher_task_struct.sleepMS,		dq 0
at dispatcher_task_struct.id_task,		dw 0x0006	;id de la tarea
at dispatcher_task_struct.state,		dw TASK_RUNNING	
at dispatcher_task_struct.current_task_struct,	dq Task_F
at dispatcher_task_struct.next,			dq TaskIdle_disp
iend	
	
	
;********************************PILAS de nivel 0***********************************************************				
;ALIGN 4096
ALIGN 16
pila_ini_L0: times STACK_SIZE db 0               
ALIGN 16
pila_TaskA_L0: times STACK_SIZE db 0
ALIGN 16
pila_TaskB_L0: times STACK_SIZE db 0
ALIGN 16
pila_TaskC_L0: times STACK_SIZE db 0
ALIGN 16
pila_TaskD_L0: times STACK_SIZE db 0
ALIGN 16
pila_TaskE_L0: times STACK_SIZE db 0
ALIGN 16
pila_TaskF_L0: times STACK_SIZE db 0 

;********************************MMX Tasks E y F de nivel 0***********************************************
ALIGN 16
SIMD_R_TaskE: times 512 db 0
ALIGN 16
SIMD_R_TaskF: times 512 db 0 


;******************************** Algunos datos***********************************************************			

texto: db "UTN-2014-TDIII------ Marcelo J Fernandez", 00h ;
txt_pae_av: db "..CPUID - PAE : Available", 00h
txt_lme_av: db "..CPUID - LME : Available", 00h
txt_pae_nav: db "..CPUID - PAE : Not Available!!", 00h
txt_lme_nav: db "..CPUID - LME : Not Available!!", 00h

txt_MMX_av: db "..CPUID - MMX : Available", 00h
txt_MMX_nav: db "..CPUID - MMX : Not Available!!", 00h

txt_FXSR_av: db "..CPUID - FXSR : FXSAVE, FXRESTOR, CR4 bit 9 Available", 00h
txt_FXSR_nav: db "..CPUID - FXSR : FXSAVE, FXRESTOR, CR4 bit 9 Not Available!!", 00h

txt_DE_av: db  "..CPUID - Debug Extensions : Available", 00h
txt_DE_nav: db "..CPUID - Debug Extensions : Not Available!!", 00h

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
  mov eax,CPUID_EAX_1
  CPUID
  and edx,CPUID_PAE_A
  cmp edx,CPUID_PAE_A
  jnz NO_PAE

  ;llamo a la rutina de print
  mov edi,txt_pae_av
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,1	; edx	(tercer argumento)  char fila
  mov ecx,010b	; ECX	(cuarto arguemto)   char color
  call Print_16


  ;****************Seteo PAE********************************
  mov eax,cr4			;leo el registro CR4
  or eax,CR4_PAE		;or flag de PAE
  mov cr4,eax			;Seteo CR4


  call RealModePageInit
      
      
  mov eax, DUP
  shl eax,4
  add eax,_PML4_BASE
  mov cr3,eax
  xor eax,eax


  
  ;reprogramo el pic
  call Pic_Reprograming
  mov AL, 11111100b 		;desabilito todas las interrupciones del PIC1 excepto Timer (bit 0) y teclado (bit 1)  http://www.brokenthorn.com/Resources/OSDevPic.html
  out 21h,al
  mov AL, 0xFF 		;desabilito todas las interrupciones del PIC2 
  out 0xA1,al
  
  ;programo el timer para interrumpir cada 1ms aprox
  call Timer_Repr
  
  
  lidt [idtr]


  ;Comprueba si LME esta como spec en el micro
  mov eax,CPUID_EAX_81
  CPUID
  and edx,CPUID_LME_BIT		;bit 29  
  cmp edx,CPUID_LME_BIT
  jnz NO_LME


  mov edi,txt_lme_av
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,2	; edx	(tercer argumento)  char fila
  mov ecx,010b	; ECX	(cuarto arguemto)   char color
  call Print_16


  mov ecx,MSR_EFER      	;seteo para leer EFER de la MSR
  rdmsr                  		;pedido de lectura a MSR
  or eax, EFER_LME_BIT       	;Seteo LME (Long mode enable)
  wrmsr              		;seteo en la MSR el registro EFER

  
  ;Ver Manual intel 2.8 V3a y 9.12 V3a para ver bien secuencia de cambio de modos
  mov eax,cr0                 ;seteo el bit de paginacion y de modo protegido
  or eax, CR0_PE | CR0_PG	;80000001h   
  mov cr0,eax 
  jmp  cs_sel_64_Kernel:modo_largo    
  
  
  [bits 64]
modo_largo: 
  mov rsp,pila_ini_L0 + STACK_SIZE 			;seteo la direccion de la pila +100 por que se carga de forma inversa
  mov ax,ds_sel_Kernel                ;cargo el descriptor de datos
  mov ds,ax					;cargo ds con el segundo descriptor
  mov ss,ax					;cargo ss con el descriptor de datos (para la pila)
  mov es,ax
  
  ;cargo la tss
  mov ax,tss_ini
  ltr ax

  ;llamo a la creacion de esquema de paginacion para cada tarea
  ;TODO:Armar una unica funcion que genere el esquema de paginacion y devuelva por rax la base de PML4 para cr3 
  call Task_A_PagingInit
  call Task_B_PagingInit
  call Task_C_PagingInit
  call Task_D_PagingInit
  call Task_E_PagingInit
  call Task_F_PagingInit
  
  
  ;verifico soporte de Debug Extensions
  mov eax,CPUID_EAX_1		;quiero leer feautures
  CPUID
  test edx,CPUID_DE_BIT	
  jz	NO_DE		
  mov edi,txt_DE_av
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,5	; edx	(tercer argumento)  char fila
  mov ecx,010b	; ECX	(cuarto arguemto)   char color
  call Print_64 
  
  ;inicializo debug registers
  call Init_Debug_Registers
  
  
  ;verifico existencia de SIMD
  mov eax,CPUID_EAX_1		;quiero leer feautures
  CPUID
  test edx,CPUID_MMX_BIT	; Is IA MMX technology bit (Bit 23 of EDX) set?
  jz	NO_MMX			; NOT MMX_Technology_Found
  mov edi,txt_MMX_av
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,3	; edx	(tercer argumento)  char fila
  mov ecx,010b	; ECX	(cuarto arguemto)   char color
  call Print_64
  
  ;verifico soporte de fxsave, fxrestor
  mov eax,CPUID_EAX_1		;quiero leer feautures
  CPUID
  test edx,CPUID_FXRS_BIT	
  jz	NO_FXSR		
  mov edi,txt_FXSR_av
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,4	; edx	(tercer argumento)  char fila
  mov ecx,010b	; ECX	(cuarto arguemto)   char color
  call Print_64
  
  ;llamo a la inicializacion de SIMD
  call SIMD_Init
  
  sti		

mainLoop:	
	  ;la semilla del rand va a ser rax que va a ir tomando numeros random
	  ;mov rax,r11
	  ;mov qword rbx,0 
	  ;int 80		;con rbx en 0 llamo a la funcion random
	  ;mov rax,0x25000000
	  
	  ;call canonise1Mega
	  ;add rax,0x400000	;hago que siempre este por encima de los 2 megas asi no me jode con los descriptores de sistema
	  ;and rax,0x000000000FFFFFFF ; lo limito a 256megas de ram    0x000000003FFFFFFF  
	  ;mov  rbx,[rax]	;uso la direccion
	  ;inc r11

        hlt
        jmp mainLoop

Tj_txt: db "TASK: ID_00 - P_00 - MS_0000000000000000", 00h

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

NO_MMX:         ;aunque es al pedo para el debugging me caeria aca si no tuviese pae
    ;llamo a la rutina de print
  mov edi,txt_MMX_nav
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,3	; edx	(tercer argumento)  char fila
  mov ecx,100b	; ECX	(cuarto arguemto)   char color
  call Print_64
  hlt
  jmp NO_MMX  
  
NO_FXSR:         ;aunque es al pedo para el debugging me caeria aca si no tuviese pae
    ;llamo a la rutina de print
  mov edi,txt_FXSR_nav
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,4	; edx	(tercer argumento)  char fila
  mov ecx,100b	; ECX	(cuarto arguemto)   char color
  call Print_64
  hlt
  jmp NO_FXSR    

NO_DE:         ;aunque es al pedo para el debugging me caeria aca si no tuviese pae
    ;llamo a la rutina de print
  mov edi,txt_DE_nav
  mov esi,2	; esi	(segundo argumento) char columna
  mov edx,5	; edx	(tercer argumento)  char fila
  mov ecx,100b	; ECX	(cuarto arguemto)   char color
  call Print_64
  hlt
  jmp NO_DE     
 
%include "include/gateA20.asm"
%include "include/utils_32.asm" 
 

%include "include/PagingInit.asm"
%include "include/isr.asm"
%include "include/utils_64.asm"


;-------------------------------------------------------------------------------------
ALIGN 4096

ALIGN 16
pila_TaskA_L3: times STACK_SIZE db 0


TMM_txt: db "TASK: ID_00 - P_00 - MS_0000000000000000", 00h
TM_txt: db "00/00/00 ", 00h   
vartm_txt: db "  ", 00h   

Tarea_Malloc:
	mov qword rbx,S_JIFFIES
 	int 80		;llamo a servicio de sistema (jiffes)
 	
 	mov edi, eax
 	mov esi, TMM_txt + 24
 	mov edx, 16 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80	
 	
 	mov qword rbx,S_T_ID
 	int 80		;llamo a servicio de sistema (get id)
 	
 	
 	mov edi, eax
 	mov esi, TMM_txt + 9
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80
 	
 	mov qword rbx,S_T_PR
 	int 80		;llamo a servicio de sistema (get privilege)
 	
 	mov edi, eax
 	mov esi, TMM_txt + 16
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80
 	
 	mov edi,TMM_txt
 	mov esi,2	; esi	(segundo argumento) char columna
 	mov edx,8	; edx	(tercer argumento)  char fila
 	mov ecx,111b	; ECX	(cuarto arguemto)   char color
 	mov qword rbx,S_PRINT 
 	int 80		;llamo a servicio de sistema (imprimir en pantalla)


    ;pido los dia
	mov qword rbx,S_RTC_DAY ;voy a pedir  dia al sistema
	int 80	
	
	mov edi, eax
	mov esi, vartm_txt
	mov edx, 2 ;(numero de digitos que me interesan)
	mov qword rbx,S_BCDTOA ;llamo a conversion BCDtoa 
	int 80	
 
	mov byte al,[vartm_txt]
	mov byte [TM_txt],al
	mov byte al,[vartm_txt + 1]
	mov byte [TM_txt+1],al
 
  ;pido los mes
	mov qword rbx,S_RTC_MNTH ;voy a pedir el mes al sistema
	int 80	
 
	mov edi, eax
	mov esi, vartm_txt
	mov edx, 2 ;(numero de digitos que me interesan)
	mov qword rbx,S_BCDTOA ;llamo a conversion BCDtoa 
	int 80	
 	
	mov byte al,[vartm_txt]
	mov byte [TM_txt+3],al
	mov byte al,[vartm_txt + 1]
	mov byte [TM_txt+4],al
	
 ;pido la año
	mov qword rbx,S_RTC_YR ;voy a pedir el año al sistema
	int 80	
	
	mov edi, eax
	mov esi, vartm_txt
	mov edx, 2 ;(numero de digitos que me interesan)
	mov qword rbx,S_BCDTOA ;llamo a conversion BCDtoa 
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

	mov qword rbx,S_PRINT 
	int 80		;llamo a servicio de sistema (imprimir en pantalla)
	 	  
 jmp Tarea_Malloc

;------------------------------------------------------------------------------------- 
ALIGN 4096
ALIGN 16
pila_TaskB_L3: times STACK_SIZE db 0


TBB_txt: db "TASK: ID_00 - P_00 - MS_0000000000000000", 00h
TB_txt: db "24:00:00", 00h  
var_txt: db "  ", 00h


Tarea_B:
	mov qword rbx,S_JIFFIES
 	int 80		;llamo a servicio de sistema (jiffes)
 	
 	mov edi, eax
 	mov esi, TBB_txt + 24
 	mov edx, 16 ;(numero de digitos que me interesan)
 	mov qword rbx,2 ;llamo a conversion itoa
 	int 80	
 	
 	mov qword rbx,S_T_ID
 	int 80		;llamo a servicio de sistema (get id)
 	
 	
 	mov edi, eax
 	mov esi, TBB_txt + 9
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80
 	
 	mov qword rbx,S_T_PR
 	int 80		;llamo a servicio de sistema (get id)
 	
 	mov edi, eax
 	mov esi, TBB_txt + 16
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80
 	
 	mov edi,TBB_txt
 	mov esi,2	; esi	(segundo argumento) char columna
 	mov edx,9	; edx	(tercer argumento)  char fila
 	mov ecx,111b	; ECX	(cuarto arguemto)   char color
 	mov qword rbx,S_PRINT 
 	int 80		;llamo a servicio de sistema (imprimir en pantalla)


    ;pido los segundos
	mov qword rbx,S_RTC_SEC ;voy a pedir los segundos al sistema
	int 80	
	
	mov edi, eax
	mov esi, var_txt
	mov edx, 2 ;(numero de digitos que me interesan)
	mov qword rbx,S_BCDTOA ;llamo a conversion BCDtoa 
	int 80	
	
	mov byte al,[var_txt]
	mov byte [TB_txt+6],al
	mov byte al,[var_txt + 1]
	mov byte [TB_txt+7],al

 ;pido los minutos
	mov qword rbx,S_RTC_MIN 
	int 80	

	mov edi, eax
	mov esi, var_txt
	mov edx, 2 ;(numero de digitos que me interesan)
	mov qword rbx,S_BCDTOA ;llamo a conversion BCDtoa 
	int 80	
	
	mov byte al,[var_txt]
	mov byte [TB_txt+3],al
	mov byte al,[var_txt + 1]
	mov byte [TB_txt+4],al
	
 ;pido la hora
	mov qword rbx,S_RTC_HR 
	int 80	
	
	mov edi, eax
	mov esi, var_txt
	mov edx, 2 ;(numero de digitos que me interesan)
	mov qword rbx,S_BCDTOA ;llamo a conversion BCDtoa 
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

	mov qword rbx,S_PRINT 
	int 80		;llamo a servicio de sistema (imprimir en pantalla)
		
 jmp Tarea_B

 

 
 
 
;-------------------------------------------------------------------------------------
ALIGN 4096
ALIGN 16
pila_TaskC_L3: times STACK_SIZE db 0

Tc_txt: db "TASK: ID_00 - P_00 - MS_0000000000000000", 00h    

Tarea_C:
 	mov qword rbx,S_JIFFIES
 	int 80		;llamo a servicio de sistema (jiffes)
 	
 	mov edi, eax
 	mov esi, Tc_txt + 24
 	mov edx, 16 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80	
 	
 	mov qword rbx,S_T_ID
 	int 80		;llamo a servicio de sistema (get id)
 	
 	
 	mov edi, eax
 	mov esi, Tc_txt + 9
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80
 	
 	mov qword rbx,S_T_PR
 	int 80		;llamo a servicio de sistema (get priority)
 	
 	mov edi, eax
 	mov esi, Tc_txt + 16
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80
 	
 	mov edi,Tc_txt
 	mov esi,2	; esi	(segundo argumento) char columna
 	mov edx,10	; edx	(tercer argumento)  char fila
 	mov ecx,111b	; ECX	(cuarto arguemto)   char color
 	mov qword rbx,S_PRINT 
 	int 80		;llamo a servicio de sistema (imprimir en pantalla)
	
 jmp Tarea_C
 
 
;------------------------------------------------------------------------------------- 
ALIGN 4096
ALIGN 16
pila_TaskD_L3: times STACK_SIZE db 0

TD_txt: db "TASK: ID_00 - P_00 - MS_0000000000000000", 00h  

Tarea_D:
	mov edi,5000	;duermo 5 segundos esta tarea
	mov qword rbx,S_MSLEEP
	int 80		

Tarea_D_Cont:	
 	mov qword rbx,S_JIFFIES
 	int 80		;llamo a servicio de sistema (jiffes)

 	mov edi, eax
 	mov esi, TD_txt + 24
 	mov edx, 16 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80	
 	
 	mov qword rbx,S_T_ID
 	int 80		;llamo a servicio de sistema (get id)
 	
 	mov edi, eax
 	mov esi, TD_txt + 9
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80
 	
 	mov qword rbx,S_T_PR
 	int 80		;llamo a servicio de sistema (get id)
 	
 	mov edi, eax
 	mov esi, TD_txt + 16
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80
 	
 	mov edi,TD_txt
 	mov esi,2	; esi	(segundo argumento) char columna
 	mov edx,11	; edx	(tercer argumento)  char fila
 	mov ecx,111b	; ECX	(cuarto arguemto)   char color
 	mov qword rbx,S_PRINT 
 	int 80		;llamo a servicio de sistema (imprimir en pantalla)

 jmp Tarea_D_Cont
 
 
 ;------------------------------------------------------------------------------------- 
ALIGN 4096
ALIGN 16
pila_TaskE_L3: times STACK_SIZE db 0

TE_txt: db "TASK: ID_00 - P_00 - MS_0000000000000000 | SIMD", 00h  

op1_e dw 0x0003,0x00f0,0x0122,0xa655
op2_e dw 0x0003,0x00f0,0x0122,0xa655

Tarea_E:
	
 	mov qword rbx,S_JIFFIES
 	int 80		;llamo a servicio de sistema (jiffes)

 	mov edi, eax
 	mov esi, TE_txt + 24
 	mov edx, 16 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80	
 	
 	mov qword rbx,S_T_ID
 	int 80		;llamo a servicio de sistema (get id)
 	
 	mov edi, eax
 	mov esi, TE_txt + 9
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80
 	
 	mov qword rbx,S_T_PR
 	int 80		;llamo a servicio de sistema (get id)
 	
 	mov edi, eax
 	mov esi, TE_txt + 16
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80
 	
 	mov edi,TE_txt
 	mov esi,2	; esi	(segundo argumento) char columna
 	mov edx,12	; edx	(tercer argumento)  char fila
 	mov ecx,111b	; ECX	(cuarto arguemto)   char color
 	mov qword rbx,S_PRINT 
 	int 80		;llamo a servicio de sistema (imprimir en pantalla)
 	
 	movq mm0,QWORD [op1_e]

 jmp Tarea_E
 
 
 ;------------------------------------------------------------------------------------- 
ALIGN 4096
ALIGN 16
pila_TaskF_L3: times STACK_SIZE db 0

TF_txt: db "TASK: ID_00 - P_00 - MS_0000000000000000 | SIMD", 00h  
op1_f dw 0x0003,0x00f0,0x0122,0xa655
op2_f dw 0x0003,0x00f0,0x0122,0xa655

Tarea_F:
	
 	mov qword rbx,S_JIFFIES
 	int 80		;llamo a servicio de sistema (jiffes)

 	mov edi, eax
 	mov esi, TF_txt + 24
 	mov edx, 16 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80	
 	
 	mov qword rbx,S_T_ID
 	int 80		;llamo a servicio de sistema (get id)
 	
 	mov edi, eax
 	mov esi, TF_txt + 9
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80
 	
 	mov qword rbx,S_T_PR
 	int 80		;llamo a servicio de sistema (get id)
 	
 	mov edi, eax
 	mov esi, TF_txt + 16
 	mov edx, 2 ;(numero de digitos que me interesan)
 	mov qword rbx,S_ITOA ;llamo a conversion itoa
 	int 80
 	
 	mov edi,TF_txt
 	mov esi,2	; esi	(segundo argumento) char columna
 	mov edx,13	; edx	(tercer argumento)  char fila
 	mov ecx,111b	; ECX	(cuarto arguemto)   char color
 	mov qword rbx,S_PRINT 
 	int 80		;llamo a servicio de sistema (imprimir en pantalla)
 	
 	
 	
 	movq mm1,QWORD [op2_f]		

 jmp Tarea_F