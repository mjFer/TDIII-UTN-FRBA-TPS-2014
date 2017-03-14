

%include "include/isr_pageFaultExceptionHandler.mac"

[BITS 64]
;-----------------------------------------------------------
; Handler de PageFault
; Recibe: Nada
; Devuelve: Nada
;----------------------------------------------------------- 

G_PFH_txt: db "ex14_PageFaultProtectionHandler!!        ", 00h
G_PFH_Ppci: db "....Pagina presente con privilegios incorrectos..HLT!  ", 00h
G_PFH_mll: db  "....Memoria llena..HLT!  ", 00h
G_PFH_1gll: db "....Excedo 1G lineal ..HLT!  ", 00h
G_PFH_usll: db "....Tarea trata de acceder a memoria no paginada ..HLT!  ", 00h
var_base_page_phy_dir: dq BASE_PAGES,0
var_last_created_page_phy_dir: dq BASE_PAGES,0
var_n_page_created dq 0,0

ex14_PageFaultProtectionHandler:
    pop rbx
    push rax
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    push r10
    push r11
    
    mov edi,G_PFH_txt
    mov esi,5	; esi	(segundo argumento) char columna
    mov edx,16	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64

   ; xchg bx,bx
    mov r15,cr2
    mov rdi, rbx
    and rdi,0x01
    cmp rdi,0x01
    je  error_pagina_presente ; si se da esto basicamente tratamos de escibir en read only, o con privilegio incorrectos
			      ;o una pagina mal creada (seteamos bit reservado)
			      
    mov r15,cr2
    mov rdi, rbx
    and rdi,0x04
    cmp rdi,0x04
    je  error_user_task ; con privilegio cpl 3 tratamos de acceder a no presente
    
    ;en el siguiente codigo estimo que no se va a querer superar la direccion de memoria lineal
    ;	0x000040000000 o sea la PML4E es la 0, la PDPTE es la 0, la pdt es la 0 con multiples entradas de pt
    ; y luego multiples paginas para cada pt  
    ;tamañy en bytes de una pt (2^9bits * 8 bytes) = 4096 => 0x1000
    
    ;mov eax,cr2
    mov rax,cr2
    ;TODO: evaluar que requerimos otra PML4e o PDPTE
    
    ;evaluo si supero el giga que mi manejador permite manejar de direccion lineal
    cmp rax,0x3FFFFFFF 
    jg 	error_excedo_memoria_paginable	;si excedo salto
    
    mov r8,rax
    and r8,0x3FE00000	;enmascaro lo que no es PDE
    sar r8,0x12            ;21 - 3 debo dezplazar 20 para quedarme con el offset de pde pero con 
    ;en r8 tengo el offset de pde
    
    mov r9,rax
    and r9,0x1FF000	;enmascaro lo que no es PTE
    sar r9,0x09		;12 -3
    ;en r9 queda el offset de la pagina preparado (PTE)
    
    ;me quedo en r10 el offset puro (Page-directory-offset) y lo dezplazo en el size de las pt 0x1000
    
    ;en r10 me debo quedar con la PTx endonde esta la PDE
    mov r10,rax
    and r10,0x3FE00000	;enmascaro lo que no es PDE
    sar r10,0x09	; 21 - 12 (equivale a quedarme con el offser de Page-firectory offset y multiplicarlo por 0x1000
			; que es lo que ucupa cada pt 
    add r10,PT_BASE	;sumandole el PT_BASE ubico esta page table
    
    ;configuro la PDE
    add r8,PDT_BASE 	;
    mov  [r8], r10 ;aca debo colocar la page table PT_BASE + 0x11 dword
    or byte  [r8], 0x15;los RPL o privilegios DPL 3       
    mov dword [r8 + 4 ], 0 ;dword
							;TODO: me ubico sobre la PTE y verifico que apunte a una direccion de pagina, si no creo la pagina
    
    ;en r11 tengo la direccion fisica de la pte
    mov r11,r10
    add r11,r9
    
    ;configuro la direccion de la pagina
    mov qword rax,[var_last_created_page_phy_dir]
    mov qword [r11], rax ;coloco la direccion fisica de la pagina
    
    
    mov rdi, rbx
    and rdi,00000100b
    cmp rdi,00000100b
    je priv_user   
    or byte  [r11], 0x11;los RPL o privilegios DPL 0   
    jmp end_pte
priv_user:
    or byte  [r11], 0x15;los RPL o privilegios DPL 3    
end_pte:    
    mov dword [r11 + 4 ], 0
    
    ;incremento las variables de paginas
    add rax,0x1000
    mov [var_last_created_page_phy_dir],rax
    
    mov rax,[var_n_page_created]
    inc rax
    mov [var_n_page_created],rax
    
     
    ;verifico si me pase de la ram existente para crear paginas
    mov qword rax,[var_n_page_created]
    sal rax,12
    cmp qword rax,FISICAL_AVAIABLE_MEMORY
    jnb error_memoria_llena
    
    ;popeo y salgo
    pop r11
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
;    pop rax		;incremento el eip en 9 para que siga con laproxima instruccion
;    add rax, 1000b
;    push rax  
    ;xchg bx,bx

iretq


error_pagina_presente:
    mov edi,G_PFH_Ppci
    mov esi,5	; esi	(segundo argumento) char columna
    mov edx,17	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64

    hlt
    
error_memoria_llena:
    mov edi,G_PFH_mll
    mov esi,5	; esi	(segundo argumento) char columna
    mov edx,17	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64

    hlt
    
error_excedo_memoria_paginable: 
    mov edi,G_PFH_1gll
    mov esi,5	; esi	(segundo argumento) char columna
    mov edx,17	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64

    hlt

error_user_task:
    mov edi,G_PFH_usll
    mov esi,5	; esi	(segundo argumento) char columna
    mov edx,17	; edx	(tercer argumento)  char fila
    mov ecx,100b	; ECX	(cuarto arguemto)   char color
    call Print_64

    hlt