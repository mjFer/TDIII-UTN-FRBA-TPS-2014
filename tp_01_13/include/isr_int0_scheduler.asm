




[BITS 64]
;-----------------------------------------------------------
; Handler de Interrupcion de timer - Scheduler
; Recibe: Nada
; Devuelve: Nada
;------------------------------------------------------------
OLD_disp_Task   dq TaskIdle_disp;
Current_disp_Task dq TaskIdle_disp;

int0_TimerHandler:
;    xchg bx,bx
    push rax
    push rbx
    mov al,20h		
    out 20h,al		; Send the EOI to the PIC
    
     mov rbx,[Current_disp_Task]   
     ;incremento el contador de ms
     mov rax,[rbx + dispatcher_task_struct.totalTicks]
     inc rax
     mov [rbx + dispatcher_task_struct.totalTicks],rax
test_status: 
     ;empiezo con el scheduller
     mov ax,[rbx + dispatcher_task_struct.currentTicks]
     ;xchg bx,bx
     inc ax
     mov [rbx + dispatcher_task_struct.currentTicks],ax
     cmp ax,[rbx + dispatcher_task_struct.prioridad_maxTicks]
     jne int0_TH_endirq

     ;debo cambiar de tarea
     mov word[rbx + dispatcher_task_struct.currentTicks],0	;para mi aca deberia ir dword pero me pisa maxTicks
     mov qword[OLD_disp_Task],rbx 
Ts:
     mov rbx,[Current_disp_Task]  
     mov qword rax,[rbx + dispatcher_task_struct.next] 
     mov qword[Current_disp_Task],rax   
     
     ;veo si no esta Ready
     mov ax, [rax + dispatcher_task_struct.state]
     cmp ax,TASK_READY
     je Ts	;tengo que saltear este 
     
     jmp SwitchTo  
    
int0_TH_endirq:
    pop rbx
    pop rax
    iretq

SwitchTo:
   ;**********************LEAVING THE OLD CONTEXT
;   xchg bx,bx
   mov rbx,[OLD_disp_Task]
   mov rax,[rbx + dispatcher_task_struct.current_task_struct]
   mov qword[rax+task_struct.RIP],SwitchCompleted
   mov [rax+task_struct.RSP0],RSP
   mov [rax+task_struct.RSP],RSP
   mov [rax+task_struct.CS],cs
   mov [rax+task_struct.DS],DS
   mov [rax+task_struct.SS],SS
   mov [rax+task_struct.rbx],rbx
   mov [rax+task_struct.rcx],rcx
   mov [rax+task_struct.rdx],rdx
   mov [rax+task_struct.RDI],rdi
   mov [rax+task_struct.RSI],rsi
   
   mov [rax+task_struct.R9],R9
   mov [rax+task_struct.R10],R10
   mov [rax+task_struct.R11],R11
   mov [rax+task_struct.R12],R12
   mov [rax+task_struct.R13],R13
   mov [rax+task_struct.R14],R14
   mov [rax+task_struct.R15],R15
   mov [rax+task_struct.ES],ES
   mov [rax+task_struct.FS],FS
   mov [rax+task_struct.GS],GS
   mov [rax+task_struct.RBP],RBP
   
   pushfq				;pusheo rflags
   pop rbx
   mov [rax+task_struct.RFLAGS],rbx	; mov [TaskIdle+task_struct.RFLAGS],rbx

   ;***********************LOADING THE NEW CONTEXT
;   xchg bx,bx
    mov rbx,[Current_disp_Task]
    mov rax,[rbx + dispatcher_task_struct.current_task_struct]
    mov rsp,[rax+task_struct.RSP0]
    mov rbx,rsp
    ;add rbx,4
    mov [sys_tss+tss_struc.reg_RSP0l],ebx
    mov rbx,0
    mov bx,[rax+task_struct.SS] 
    push rbx
    mov rbx,[rax+task_struct.RSP]
    push rbx
    mov ds,[rax+task_struct.DS]
    mov rbx,[rax+task_struct.RFLAGS]
    push rbx
    mov rbx,0
    mov bx,[rax+task_struct.CS]
    push rbx
    mov rbx,[rax+task_struct.RIP]
    push rbx
    mov rcx,[rax+task_struct.rcx]
    mov rdx,[rax+task_struct.rdx]
    mov rdi,[rax+task_struct.RDI]
    mov rsi,[rax+task_struct.RSI]
    
    mov R9, [rax+task_struct.R9]
    mov R10, [rax+task_struct.R10]
    mov R11, [rax+task_struct.R11]
    mov R12, [rax+task_struct.R12]
    mov R13, [rax+task_struct.R13]
    mov R14, [rax+task_struct.R14]
    mov R15, [rax+task_struct.R15]
    mov ES,  [rax+task_struct.ES]
    mov FS,  [rax+task_struct.FS]
    mov GS,  [rax+task_struct.GS]
    mov RBP, [rax+task_struct.RBP]
       
    mov rbx,0
    mov rbx,[rax+task_struct.CR3]   
    mov cr3,rbx
  
 SwitchSegment:   iretq

        
SwitchCompleted: 
  mov rbx,rsp
  add rbx,0x40
  ;add rbx,71;0x39;add rbx,0x40  ;  add rbx,56 ;0x40;56;0x40;add rbx,56 ;0x40 ;5 offseteados		;64
  mov [sys_tss+tss_struc.reg_RSP0l],ebx

  jmp int0_TH_endirq    
     
     
