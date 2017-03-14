;***********************************************************
;   UTN-2014-UTILS
;***********************************************************
;***********************************************************
;   Author  : Fernandez Marcelo Joaquin
;   Date    : 23th May 2014
;***********************************************************



[BITS 32]

%define VID_MEM 0x0     ;ahora el video esta direccionado a la pagina (0x000b8000)

;-----------------------------------------------------------
; Invierte los colores de la pantalla
; Recibe: Nada
; Devuelve: Nada
;------------------------------------------------------------
RutinaInversionPantalla:
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
   cmp byte [ds:edi], VID_MEM
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
  push ecx
  mov esi, VID_MEM			;apuntando a 0 ahora apunta a la zona de video
  mov ecx,2000
llazo:
  mov byte [esi],0x00   ;pongo caracter null
  add esi,2
  loop llazo
  pop ecx
ret

