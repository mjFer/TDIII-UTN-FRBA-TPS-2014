;                               Trabajo Practico 1 - EJ 1                               ; 
;                                                                                       ; 
;  Alumno: Marcelo Joaquin Fernandez                                                    ;  
;  Legajo: 1403734                                                                      ; 
;  Curso: r5055                                                                         ; 
; **************************************************************************************; 

BITS 16 
org 0x7C00
		
Inicio:

  mov eax,cr0  ;aca levanto el flag de modo protegido
  or al,1
  mov cr0,eax

;BITS 32

xchg bx, bx		;magic breakPoint
WaitLoop:
    in     al, 60h     ; Leo el buffer de entrada
    cmp al,0x01	       ; Hago la comparacion con el "esc"
    jne WaitLoop       ; si no es igual (flag Z no seteado) vuelvo a loop

hlt

times 510- ($-$$) db 0
db 0x55
db 0xAA



