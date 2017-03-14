

%include "include/PagingInit.mac"


[BITS 16] 
;********************************************************************************************************
;Generacion de paginas para el mappeo de los 4 primeros megas de memoria en identity mapping
;
;
;********************************************************************************************************
RealModePageInit:


  ;INICIO Creacion de paginas
					      ;notar que estoy en modo real por lo que las direcciones salen de la suma de DUP:_PML4_BASE 
	  xor eax,eax
	  mov eax, DUP
	  mov ds, eax
	  mov dword [DS:_PML4_BASE],PDPT_BASE + 0x17;0x11		
	  mov dword [DS:_PML4_BASE + 4], 0
	  mov dword [DS:_PDPT_BASE],PDT_BASE + 0x17;0x11
	  mov dword [DS:_PDPT_BASE + 4], 0
	 
	  mov dword [DS:_PDT_BASE],PT_BASE + 0x17;0x11
	  mov dword [DS:_PDT_BASE + 4], 0
	 
	  mov dword [DS:_PDT_BASE + 8],PT_BASE + 0x1000 + 0x17;0x11
	  mov dword [DS:_PDT_BASE + 12], 0

	  ;Aca arrancamos a crear las paginas con un loop
	  mov ecx, 1024      ;creo 1024 entradas, (2 pt) 512 por pt
	  mov eax, 01000h + 0x07;0x01  ;0x07 para W
	  mov edi, _PT_BASE + 8
  pageloop:
	  mov dword [DS:edi],eax
	  mov dword [DS:edi + 4],0
	  add edi, 8
	  add eax, 1000h
	  loop pageloop
	  
      
      mov dword [DS:_PT_BASE + 0x40 ],0x8000 + 1
      mov dword [DS:_PT_BASE + 4], 0	    
      
      mov dword [DS:_PT_BASE + 0x48 ],0x9000 + 1
      mov dword [DS:_PT_BASE + 4], 0	
	  
	  
      ;pagina de usuario para las tareas en 0xA000
      ;mov dword [DS:_PT_BASE + 0x50 ],USER_PAGE + 7;0x07	;x50 es la 0xa000
      ;mov dword [DS:_PT_BASE + 4], 0	  
      
      ;pagina de usuario para las tareas en 0xA000
      ;mov dword [DS:_PT_BASE + 0x58 ],0xb000 + 5;0x07	;x50 es la 0xa000
      ;mov dword [DS:_PT_BASE + 4], 0	  
      
      ;en la 0x0000 pagino la b8000 de video
      mov dword [DS:_PT_BASE],0b8000h + 0x01
      mov dword [DS:_PT_BASE + 4], 0
  ;FIN CREACION PAGINAS
      xor eax,eax
      mov ds, eax
      
      
  mov eax, DUP
  shl eax,4
  add eax,_PML4_BASE
  mov cr3,eax
  xor eax,eax
  
  ret
  
[bits 64] 
  
;********************************************************************************************************
;Inicializacion de tablas para la Tarea A
;********************************************************************************************************
Task_A_PagingInit:

  xor eax,eax
  
  mov dword [PML4_BASE_TA],PDPT_BASE_TA + 0x17	
  mov dword [PML4_BASE_TA + 4], 0
  mov dword [PDPT_BASE_TA],PDT_BASE_TA + 0x17
  mov dword [PDPT_BASE_TA + 4], 0
  
  mov dword [PDT_BASE_TA],PT_BASE_TA + 0x17
  mov dword [PDT_BASE_TA + 4], 0
  
  mov dword [PDT_BASE_TA + 8],PT_BASE_TA + 0x1000 + 0x17
  mov dword [PDT_BASE_TA + 12], 0

  ;*********************Paginas visibles para la task en prioridad kernel*********************/
  
  ;en la 0x0000 pagino la b8000 de video
  mov dword [PT_BASE_TA],0b8000h + 0x01
  mov dword [PT_BASE_TA + 4], 0  
  
  mov dword [PT_BASE_TA + 0x40 ],0x8000 + 1
  mov dword [PT_BASE_TA + 0x44], 0	    
  
  mov dword [PT_BASE_TA + 0x48 ],0x9000 + 1
  mov dword [PT_BASE_TA + 0x4C], 0	
  
  mov dword [PT_BASE_TA + 0x50 ],0xA000 + 1
  mov dword [PT_BASE_TA + 0x54], 0	
  
  mov dword [PT_BASE_TA + 0x58 ],0xB000 + 1
  mov dword [PT_BASE_TA + 0x5C], 0
  
  ;**********************Paginas de usuario de la task***************************************/
      
  ;pagina de usuario para la tarea
  mov dword [PT_BASE_TA + 0x60 ],0xC000 + 0x17;0x07	;a la zona de memoria de la tarea le doy RPL user
  mov dword [PT_BASE_TA + 0x64], 0	  
  
  ret  
  
  
;********************************************************************************************************
;Inicializacion de tablas para la Tarea B
;********************************************************************************************************
Task_B_PagingInit:

  xor eax,eax
  
  mov dword [PML4_BASE_TB],PDPT_BASE_TB + 0x17	
  mov dword [PML4_BASE_TB + 4], 0
  mov dword [PDPT_BASE_TB],PDT_BASE_TB + 0x17
  mov dword [PDPT_BASE_TB + 4], 0
  
  mov dword [PDT_BASE_TB],PT_BASE_TB + 0x17
  mov dword [PDT_BASE_TB + 4], 0
  
  mov dword [PDT_BASE_TB + 8],PT_BASE_TB + 0x1000 + 0x17
  mov dword [PDT_BASE_TB + 12], 0

  ;*********************Paginas visibles para la task en prioridad kernel*********************/
  
  ;en la 0x0000 pagino la b8000 de video
  mov dword [PT_BASE_TB],0b8000h + 0x01
  mov dword [PT_BASE_TB + 4], 0  
  
  mov dword [PT_BASE_TB + 0x40 ],0x8000 + 1
  mov dword [PT_BASE_TB + 0x44], 0	    
  
  mov dword [PT_BASE_TB + 0x48 ],0x9000 + 1
  mov dword [PT_BASE_TB + 0x4C], 0	
  
  mov dword [PT_BASE_TB + 0x50 ],0xA000 + 1
  mov dword [PT_BASE_TB + 0x54], 0	
  
  mov dword [PT_BASE_TB + 0x58 ],0xB000 + 1
  mov dword [PT_BASE_TB + 0x5C], 0
  
  ;**********************Paginas de usuario de la task***************************************/
      
  ;pagina de usuario para la tarea
  mov dword [PT_BASE_TB + 0x68 ],0xD000 + 0x17;0x07	;a la zona de memoria de la tarea le doy RPL user
  mov dword [PT_BASE_TB + 0x6C], 0	  
  
  ret  
  
;********************************************************************************************************
;Inicializacion de tablas para la Tarea C
;********************************************************************************************************
Task_C_PagingInit:

  xor eax,eax
  
  mov dword [PML4_BASE_TC],PDPT_BASE_TC + 0x17	
  mov dword [PML4_BASE_TC + 4], 0
  mov dword [PDPT_BASE_TC],PDT_BASE_TC + 0x17
  mov dword [PDPT_BASE_TC + 4], 0
  
  mov dword [PDT_BASE_TC],PT_BASE_TC + 0x17
  mov dword [PDT_BASE_TC + 4], 0
  
  mov dword [PDT_BASE_TC + 8],PT_BASE_TC + 0x1000 + 0x17
  mov dword [PDT_BASE_TC + 12], 0

  ;*********************Paginas visibles para la task en prioridad kernel*********************/
  
  ;en la 0x0000 pagino la b8000 de video
  mov dword [PT_BASE_TC],0b8000h + 0x01
  mov dword [PT_BASE_TC + 4], 0  
  
  mov dword [PT_BASE_TC + 0x40 ],0x8000 + 1
  mov dword [PT_BASE_TC + 0x44], 0	    
  
  mov dword [PT_BASE_TC + 0x48 ],0x9000 + 1
  mov dword [PT_BASE_TC + 0x4C], 0	
  
  mov dword [PT_BASE_TC + 0x50 ],0xA000 + 1
  mov dword [PT_BASE_TC + 0x54], 0	
  
  mov dword [PT_BASE_TC + 0x58 ],0xB000 + 1
  mov dword [PT_BASE_TC + 0x5C], 0
  
  ;**********************Paginas de usuario de la task***************************************/
      
  ;pagina de usuario para la tarea
  mov dword [PT_BASE_TC + 0x70 ],0xE000 + 0x17;0x07	;a la zona de memoria de la tarea le doy RPL user
  mov dword [PT_BASE_TC + 0x74], 0	  
  
  ret    

;********************************************************************************************************
;Inicializacion de tablas para la Tarea C
;********************************************************************************************************
Task_D_PagingInit:

  xor eax,eax
  
  mov dword [PML4_BASE_TD],PDPT_BASE_TD + 0x17	
  mov dword [PML4_BASE_TD + 4], 0
  mov dword [PDPT_BASE_TD],PDT_BASE_TD + 0x17
  mov dword [PDPT_BASE_TD + 4], 0
  
  mov dword [PDT_BASE_TD],PT_BASE_TD + 0x17
  mov dword [PDT_BASE_TD + 4], 0
  
  mov dword [PDT_BASE_TD + 8],PT_BASE_TD + 0x1000 + 0x17
  mov dword [PDT_BASE_TD + 12], 0

  ;*********************Paginas visibles para la task en prioridad kernel*********************/
  
  ;en la 0x0000 pagino la b8000 de video
  mov dword [PT_BASE_TD],0b8000h + 0x01
  mov dword [PT_BASE_TD + 4], 0  
  
  mov dword [PT_BASE_TD + 0x40 ],0x8000 + 1
  mov dword [PT_BASE_TD + 0x44], 0	    
  
  mov dword [PT_BASE_TD + 0x48 ],0x9000 + 1
  mov dword [PT_BASE_TD + 0x4C], 0	
  
  mov dword [PT_BASE_TD + 0x50 ],0xA000 + 1
  mov dword [PT_BASE_TD + 0x54], 0	
  
  mov dword [PT_BASE_TD + 0x58 ],0xB000 + 1
  mov dword [PT_BASE_TD + 0x5C], 0
  
  ;**********************Paginas de usuario de la task***************************************/
      
  ;pagina de usuario para la tarea
  mov dword [PT_BASE_TD + 0x78 ],0xF000 + 0x17;0x07	;a la zona de memoria de la tarea le doy RPL user
  mov dword [PT_BASE_TD + 0x7C], 0	  
  
  ret    
  