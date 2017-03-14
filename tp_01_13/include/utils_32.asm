;***********************************************************
;   UTN-2014-UTILS
;***********************************************************
;***********************************************************
;   Author  : Fernandez Marcelo Joaquin
;   Date    : 23th May 2014
;***********************************************************

%include "include/utils.mac"

[BITS 16]
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
Print_16:
  push ds
  mov eax,edx		;muevo a al el contenido de esi o sea la fila
  mov ebx,160
  mul bl		;multiplico por el largo de 80caracteres de 2 bytes (uso bl por que si uso bx usa ax y deposita parte alta en dx)
  mov edx,eax		;resguardo el calculo  
  mov eax,esi		;muevo el numero de columna
  mov ebx,2
  mul bl		;multiplico por 2 para el numero de bytes por char TODO:ACA ESTA FALLANDO ME ESTA MODIFICANDO DX
  add eax,edx		;le sumo el contenido de r9
  add eax, VID_MEM_OFF
  mov esi,eax		;dejo en esi la posicion a partir de la cual arranco a dibujar
  
  mov eax, VID_MEM_SEG
  mov ds, ax
  xor eax,eax
  mov es,ax
_lazo_16:
   mov al,[es:edi]
   mov [ds:esi],al
   inc esi
   mov [ds:esi],ecx
   inc esi
   inc edi
   cmp byte [es:edi], 0
   jne _lazo_16
   pop ds
ret


;-----------------------------------------------------------
; Limpia la pantalla con un color definido
; Recibe: (char color);
; Devuelve: Nada
; void print ( char color);
; edi 	(primer argumento)  char color
;------------------------------------------------------------
clrScr_16:
  push ds
  mov esi, VID_MEM_OFF			;zona de video dezplazado
  mov eax, VID_MEM_SEG
  mov ds, ax
  mov ecx,2000
llazo_16:
  mov byte [ds:esi],0x00   ;pongo caracter null
  add esi,2
  loop llazo_16
  pop ds
ret


;-----------------------------------------------------------
; Reprograma al PIT para interrumpir cada 1ms
; Recibe: Nada;
; Devuelve: Nada
;------------------------------------------------------------
Timer_Repr:
       mov al,00110100b         ; B0 =   0   - cuenta en binario  
				; B1-3 = 010 - MODO 2 : Pulsos continuos
				; B4-5 = 11  - leer escribir el byte menos sig, luego el mas
				; B6-7 = 00  - canal 0              
       out 43h,al		;muevo al PIT (programmable interval timmer) el comando
       
       mov ax,1193		; 1.1931816666Mhz * 1ms = 1193 cuentas
       out 40h,al
       mov al,ah
       out 40h,al
       ret

[BITS 32]

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
   mov al,[edi]
   mov [esi],al
   inc esi
   mov [esi],ecx
   inc esi
   inc edi
   cmp byte [edi], 0
   jne _lazo
ret


;-----------------------------------------------------------
; Limpia la pantalla con un color definido
; Recibe: (char color);
; Devuelve: Nada
; void print ( char color);
; edi 	(primer argumento)  char color
;------------------------------------------------------------
clrScr_32:
  xchg bx,bx
  mov esi, VID_MEM			;apuntando a 0 ahora apunta a la zona de video
  mov ecx,2000
llazo:
  mov byte [esi],0x00   ;pongo caracter null
  add esi,2
  loop llazo
ret


;-----------------------------------------------------------
; ITOA
; Devuelve: Nada
; void my_itoa (int valor, char* ptr);
; edi 	(primer argumento)  int valor
; esi	(segundo argumento) char* ptr
; rdx	(tercer argumento) int numero de digitos a convertir
;------------------------------------------------------------
my_itoa:
  push ecx
  push eax
  push edx
  push ebx
  
  ;desplazo el puntero en la cantidad de char que voy a llenar  
  add esi,edx
  sub esi,0x01
  mov ebx,edx
   
  mov eax,edi ; pongo en rax el valor a dividir
  mov ecx,10  ;divisor
itoa_loop: 
  xor edx,edx
  div ecx    ;eax = eax/ecx + edx | edx = resto
  add dl, 0x30
  mov byte [esi],dl
  sub esi, 0x01
  sub ebx,0x01
  cmp ebx,0	     ;si eax es cero salgo
  jz itoa_salir
  jmp itoa_loop
 
itoa_salir:
  pop ebx
  pop edx
  pop eax
  pop ecx
  ret
  
;-----------------------------------------------------------
; BCD
; Devuelve: Nada
; void my_BCDtoa (int valor, char* ptr);
; edi 	(primer argumento)  int valor
; esi	(segundo argumento) char* ptr
; rdx	(tercer argumento) int numero de digitos a convertir
;------------------------------------------------------------
my_BCDtoa:
  push ecx
  push eax
  push edx
  
  ;desplazo el puntero en la cantidad de char que voy a llenar  
  add esi,edx
  sub esi,0x01
  mov ecx,edx

   ;arranco a dividir
  mov eax,edi ; pongo en rax el valor a dividir
my_BCDtoa_loop: 
  xor edx,edx
  mov dl,al
  and dl,0x0F
  add dl, 0x30
  mov byte [esi],dl
  sub esi, 0x01		;dezplazo el puntero a char para atras
  sub ecx,0x01
  sar eax,4
  cmp ecx,0	     ;si eax es cero salgo
  jz my_BCDtoa_salir
  jmp my_BCDtoa_loop
 
my_BCDtoa_salir:
  pop edx
  pop eax
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




