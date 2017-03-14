;***********************************************************
;   UTN-2014-UTILS
;***********************************************************
;***********************************************************
;   Author  : Fernandez Marcelo Joaquin
;   Date    : 23th May 2014
;***********************************************************



[BITS 32]


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



%define VID_MEM 0x000b8000     ;ahora el video esta direccionado a la pagina (0x000b8000)

;-----------------------------------------------------------
; Invierte los colores de la pantalla
; Recibe: Nada
; Devuelve: Nada
;------------------------------------------------------------
RutinaInversionPantalla_32:
;  xchg bx, bx
  push ecx
  mov esi, VID_MEM			;Memoria de video esi es un puntero a datos (ds)
  mov ecx,2000
  mov al,[esi]
lazo:
  mov edi,[esi +1]
  xor edi,01110111b
  mov [esi +1],edi
  add esi,2
  loop lazo
  pop ecx
ret

;-----------------------------------------------------------
; Print en Pantalla de un string
; Recibe: (char string_ptr, char columna, char fila, char color);
; Devuelve: Nada
; void print (char string_ptr, char columna, char fila, char color);
; edi 	(primer argumento)  char string_ptr
; esi	(segundo argumento) char columna
; edx	(tercer argumento)  char fila
; ECX	(cuarto arguemto)   char color
;------------------------------------------------------------
Print_32:
 ; xchg bx,bx
  push ebx
  mov eax,edx		;muevo a al el contenido de esi o sea la fila
  mov ebx,160
  mul bl		;multiplico por el largo de 80caracteres de 2 bytes (uso bl por que si uso bx usa ax y deposita parte alta en dx)
  mov edx,eax		;resguardo el calculo  
  mov eax,esi		;muevo el numero de columna
  mov ebx,2
  mul bl		;multiplico por 2 para el numero de bytes por char TODO:ACA ESTA FALLANDO ME ESTA MODIFICANDO DX
  add eax,edx		;le sumo el contenido de r9
  add eax, VID_MEM
  mov esi,eax		;dejo en esi la posicion a partir de la cual arranco a dibujar
_lazo:
   mov al,[ds:edi]
   mov [ds:esi],al
   inc esi
   mov [ds:esi],ecx
   inc esi
   inc edi
   cmp byte [ds:edi], 0
   jne _lazo
   pop ebx
ret


;-----------------------------------------------------------
; Limpia la pantalla con un color definido
; Recibe: (char color);
; Devuelve: Nada
; void print ( char color);
; edi 	(primer argumento)  char color
;------------------------------------------------------------
clrScr_32:
;  xchg bx, bx
  push ecx
  push esi
  mov esi, VID_MEM			;apuntando a 0 ahora apunta a la zona de video
  mov ecx,2000
llazo:
  mov byte [esi],0x00   ;pongo caracter null
  add esi,2
  loop llazo
  pop esi
  pop ecx
ret


;-----------------------------------------------------------
; ITOA
; Devuelve: Nada
; void my_itoa (int valor, char* ptr);
; edi 	(primer argumento)  int valor
; esi	(segundo argumento) char* ptr
;------------------------------------------------------------
my_itoa:
  push ecx
  
  mov eax,edi ; pongo en rax el valor a dividir
  mov ecx,10  ;divisor
  xor edx,edx
itoa_loop: 
  div ecx    ;eax = eax/ecx + edx | edx = resto
  add dl, 0x30
  mov byte [esi],dl
  inc esi
  cmp eax,0	     ;si eax es cero salgo
  jz itoa_salir
  jmp itoa_loop
 
itoa_salir:
  pop ecx
  ret
  



Program_8254:
       mov al,00110100b                ;PROGRAMACION DEL TIMER TICK
       out 43h,al
       mov ax,11932
       out 40h,al
       mov al,ah
       out 40h,al
       ret       

;------------------------------------------------------------------------------  
Pic_Reprograming:
; Inicialización PIC #1
   mov al,11h	;ICW1: IRQs activas por flanco, Modo cascada, ICW4 Si.
   out 20h,al
   mov al,32	;ICW2: INT base para el PIC N#1 Tipo IRQ0_Base_interrupt
   out 21h,al
   mov al,04h	;ICW3: PIC N#1 Master, tiene un Slave conectado a IRQ2 (0000 0100b)
   out 21h,al
   mov al,01h	;ICW4: Modo No Buffered, Fin de Interrupción Normal, procesador 8086
   out 21h,al
   ; Antes de inicializar el PIC #2, deshabilitamos las Interrupciones del PIC #1
   mov al,0FFh	;OCW1: Set o Clear el IMR
   out 21h,al

; Inicialización PIC #2
   mov al,11h	;ICW1: IRQs activas por flanco, Modo cascada, ICW4 Si.
   out 0A0h,al
   mov al,40	;ICW2: INT base para el PIC N#1 Tipo IRQ0_Base_interrupt + 8h.
   out 0A1h,al
   mov al,02h	;ICW3: PIC N#2 Slave, IRQ2 es la línea que envía al Master (010b)
   out 0A1h,al
   mov al,01h	;ICW4: Modo No Buffered, Fin de Interrupción Normal, procesador 8086
   out 0A1h,al
ret

