
%include "include/debug_registers.mac"

;***********************************DEBUG REGISTERS ***************************************  

[BITS 64]
  
D0_ON_txt: db  "BP0 - Activado", 00h  
D0_OFF_txt: db "BP0 - Desact  ", 00h 

D1_ON_txt: db  "BP1 - Activado", 00h  
D1_OFF_txt: db "BP1 - Desact  ", 00h 

D2_ON_txt: db  "BP2 - Activado", 00h  
D2_OFF_txt: db "BP2 - Desact  ", 00h 

D3_ON_txt: db  "BP3 - Activado", 00h  
D3_OFF_txt: db "BP3 - Desact  ", 00h 
  
;-----------------------------------------------------------
; init DebugRegister
; Recibe: Nada
; Devuelve: Nada
;------------------------------------------------------------  

Init_Debug_Registers:
  push rax
  xor rax,rax
  mov rax, DEBUG_DR0
  mov dr0, rax
  mov rax, DEBUG_DR1
  mov dr1, rax
  mov rax, DEBUG_DR2
  mov dr2, rax
  mov rax, DEBUG_DR3
  mov dr3, rax
  xor rax,rax 
  or rax,D_LOCAL_EXACT_BP		;todavia no habilito en si los registros
  or rax,D_GLOBAL_EXACT_BP
  mov dr7, rax
  pop rax
  ret

toggle_F5_D0:
;  xchg bx,bx
  push rax
  push rdi
  push rsi
  push rdx
  push rcx
  xor rax,rax
  mov rax,dr7
  xor rax,D_DB0_LOCAL
  xor rax,D_DB0_GLOBAL
  mov dr7,rax
  
  and rax,D_DB0_LOCAL
  cmp rax,D_DB0_LOCAL
  je D0_Activo
  
    mov rdi,D0_OFF_txt
    mov rsi,4	; esi	(segundo argumento) char columna
    mov rdx,24	; edx	(tercer argumento)  char fila
    mov rcx,111b	; ECX	(cuarto arguemto)   char color
    call Print_64
    jmp D0_T_ret
  
  D0_Activo:
    mov rdi,D0_ON_txt
    mov rsi,4	; esi	(segundo argumento) char columna
    mov rdx,24	; edx	(tercer argumento)  char fila
    mov rcx,110b	; ECX	(cuarto arguemto)   char color
    call Print_64
D0_T_ret:
  pop rcx
  pop rdx
  pop rsi
  pop rdi
  pop rax
  ret
 
toggle_F6_D1:
  push rax
  xor rax,rax
  mov rax,dr7
  xor rax,D_DB1_LOCAL
  xor rax,D_DB1_GLOBAL
  mov dr7,rax
  
  and rax,D_DB1_LOCAL
  cmp rax,D_DB1_LOCAL
  je D1_Activo
  
    mov edi,D1_OFF_txt
    mov esi,20	; esi	(segundo argumento) char columna
    mov edx,24	; edx	(tercer argumento)  char fila
    mov ecx,111b	; ECX	(cuarto arguemto)   char color
    call Print_64
    jmp D1_T_ret
  
  D1_Activo:
    mov edi,D1_ON_txt
    mov esi,20	; esi	(segundo argumento) char columna
    mov edx,24	; edx	(tercer argumento)  char fila
    mov ecx,110b	; ECX	(cuarto arguemto)   char color
    call Print_64
D1_T_ret:
  pop rax
  ret
  
toggle_F7_D2:
  push rax
  xor rax,rax
  mov rax,dr7
  xor rax,D_DB2_LOCAL
  xor rax,D_DB2_GLOBAL
  mov dr7,rax
  
  and rax,D_DB2_LOCAL
  cmp rax,D_DB2_LOCAL
  je D2_Activo
  
    mov edi,D2_OFF_txt
    mov esi,40	; esi	(segundo argumento) char columna
    mov edx,24	; edx	(tercer argumento)  char fila
    mov ecx,111b	; ECX	(cuarto arguemto)   char color
    call Print_64
    jmp D2_T_ret
  
  D2_Activo:
    mov edi,D2_ON_txt
    mov esi,40	; esi	(segundo argumento) char columna
    mov edx,24	; edx	(tercer argumento)  char fila
    mov ecx,110b	; ECX	(cuarto arguemto)   char color
    call Print_64
D2_T_ret:
  pop rax
  ret
  
toggle_F8_D3:
  push rax
  xor rax,rax
  mov rax,dr7
  xor rax,D_DB3_LOCAL
  xor rax,D_DB3_GLOBAL
  mov dr7,rax
  
  and rax,D_DB3_LOCAL
  cmp rax,D_DB3_LOCAL
  je D3_Activo
  
    mov edi,D3_OFF_txt
    mov esi,60	; esi	(segundo argumento) char columna
    mov edx,24	; edx	(tercer argumento)  char fila
    mov ecx,111b	; ECX	(cuarto arguemto)   char color
    call Print_64
    jmp D3_T_ret
  
  D3_Activo:
    mov edi,D3_ON_txt
    mov esi,60	; esi	(segundo argumento) char columna
    mov edx,24	; edx	(tercer argumento)  char fila
    mov ecx,110b	; ECX	(cuarto arguemto)   char color
    call Print_64
D3_T_ret:
  pop rax
  ret
  
;-----------------------------------------------------------
; Handler de Debug 
; Recibe: Nada
; Devuelve: Nada
;-----------------------------------------------------------  

ex3_BPHandler:
  push rax
  push rbx
  mov rbx,DR6
  xor rax,rax
  mov DR6,rax
  
  xchg bx,bx 
 
  mov qword rax, [rsp + 0x20] ;modifico la info del eflags sin popear
  or rax,EFLAGS_RF
  mov qword[rsp +0x20],rax
  
  pop rbx
  pop rax
  iretq

  
  
  
;***********************************************************************************************