;***********************************************************
;   UTN-2014-UTILS
;***********************************************************
;***********************************************************
;   Author  : Fernandez Marcelo Joaquin
;   Date    : 23th May 2014
;***********************************************************



[BITS 32]



;-----------------------------------------------------------
; Invierte los colores de la pantalla
; Recibe: Nada
; Devuelve: Nada
;------------------------------------------------------------
RutinaInversionPantalla:
;  xchg bx, bx
  mov esi, 0x000b8000			;Memoria de video esi es un puntero a datos (ds)
  mov cx,2000
  mov al,[ds:esi]
lazo:
  mov edi,[ds:esi +1]
  xor edi,01110111b
  mov [ds:esi +1],edi
  add esi,2
  loop lazo
ret

%define VID_MEM 0x000b8000
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
Print:
 ; xchg bx,bx
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
   cmp byte [ds:edi], 0x0
   jne _lazo
ret


;-----------------------------------------------------------
; Limpia la pantalla con un color definido
; Recibe: (char color);
; Devuelve: Nada
; void print ( char color);
; edi 	(primer argumento)  char color
;------------------------------------------------------------
clrScr:
;  xchg bx, bx
  mov esi, 0x000b8000			;Memoria de video esi es un puntero a datos (ds)
  mov cx,2000
  mov al,[ds:esi]
llazo:
  mov byte [ds:esi],0x00   ;pongo caracter null
  mov [ds:esi +1],edi
  add esi,2
  loop llazo
ret

