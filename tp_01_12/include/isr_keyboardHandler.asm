

%include "include/isr_keyboardHandler.mac"

[BITS 64]
;-----------------------------------------------------------
; Handler de Interrupcion de teclado
; Recibe: Nada
; Devuelve: Nada
;------------------------------------------------------------

hlt_txt: db "HLT!!", 00h

variable_ctl_pressed: dq 00h

int9_keyboardHandler:
  push rax

  
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
  cmp al,KEY_Q_PRESS
  je KEY_Q_PRESSED
  cmp al,KEY_W_PRESS
  je KEY_W_PRESSED
  


term_int9: 
  mov al,0x20		;indico al PIC que atendi la interrupcion
  out 0x20,al
  
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
  push rdi
  push rsi
  push rdx
  push rcx
  
  mov edi,hlt_txt
  mov esi,10	; esi	(segundo argumento) char columna
  mov edx,3	; edx	(tercer argumento)  char fila
  mov ecx,111b	; ECX	(cuarto arguemto)   char color
  call Print_64
  
  pop rcx
  pop rdx
  pop rsi
  pop rdi
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

     
  
%define MAX_PRIORITY 20
%define MIN_PRIORITY 1
  
KEY_W_PRESSED:  
  add word [Task_A_disp+dispatcher_task_struct.prioridad_maxTicks],1
  mov ax, [Task_A_disp+dispatcher_task_struct.prioridad_maxTicks]
  cmp rax,MAX_PRIORITY
  ja  _KEY_W_PRESS
  jmp term_int9  
_KEY_W_PRESS:
  mov dword [Task_A_disp+dispatcher_task_struct.prioridad_maxTicks],MAX_PRIORITY
  jmp term_int9 
  
KEY_Q_PRESSED:  
  sub word [Task_A_disp+dispatcher_task_struct.prioridad_maxTicks],1
  mov ax, [Task_A_disp+dispatcher_task_struct.prioridad_maxTicks]
  cmp rax,MIN_PRIORITY
  jl  _KEY_Q_PRESS
  jmp term_int9  
_KEY_Q_PRESS:
  mov word [Task_A_disp+dispatcher_task_struct.prioridad_maxTicks],MIN_PRIORITY
  jmp term_int9    