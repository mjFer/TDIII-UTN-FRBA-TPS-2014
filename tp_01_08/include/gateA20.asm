
[BITS 16]
Verificar_Gate_A20:

	
	push	ax					;Guardo ax en pila
	push	dx					;Guardo dx en pila
	push	si					;Guardo si en pila
	push	di					;Guardo di en pila

	;Compruebo es el estado del GATE A20

	xor	ax,ax					;Inicializo a 0 el registro
	mov	ds,ax					;
	not	ax					    ;Cargo a ax con 0xFFFF
	mov	es,ax					;
	
	mov	di,0x500				;Cargo offset di 0x500
	mov	si,0x510				;Cargo offset si 0x510
	
	mov	al,[di]				;al contendra el contenido de 0x00500
	push	ax					;Lo guardo...
	
	mov	al,[es:si]				;al ahora tendra el contenido de 0xFFFF0 + 0x0510 0x100500
	push	ax					   
	
	mov	ax,0xFF00				;cargo el valor de comparacion 0xFF00 en ax
	mov	[ds:di],al				;0x00 va a 0x500
	mov	[es:si],ah				;0xFF va a 0x100500
	cmp	byte[ds:di],0xFF		;Comparo el contenido, si A20 esta activada entonces en la posicion esta 0x00, sino esta 0xFF
	
	pop	ax					
	mov	byte[es:si],al			;Recupero lo que habia antes
	pop	ax					
	mov	byte[ds:di],al			;Recupero lo que habia antes
	jne	Verificar_Gate_A20_Exit				
	call	Encender_Gate_A20				

Verificar_Gate_A20_Exit:

	

	pop	di					
	pop	si					
	pop	dx					
	pop	ax					
	ret						


Encender_Gate_A20:

	;Salvaguardo los registros que utilizo en la pila

	push	ax					

	;Habilito el pin GATE A20

	call	KB_WAIT_INPUT			

	mov	al,0xAD					;deshabilitar teclado
	out	0x64,al			
	call	KB_WAIT_INPUT			;buffer input esta vacio?
	
	mov	al,0xD0					;leer la configuracion del puerto
	out	0x64,al			
	call	KB_WAIT_OUTPUT			;Espero a que el output este lleno
	
	in	al,0x60					;Leo puerto de salida
	push	ax					;Guardo la configuracion en el stack
	call	KB_WAIT_INPUT			;espero a que buffer input esta vacio
	
	mov	al,0xD1					;guardo en AL el comando para escribir la configuracion del puerto de salida
	out	0x64,al					;Envio al 8042
	call	KB_WAIT_INPUT			;espero a que buffer input esta vacio

	pop	ax					;Recupero configuracion del output port del 8042.
	or	al,0x02					;habilito GATE A20 con el bit #1
	out	0x60,al					;Lo envio al puerto de teclado 
	call	KB_WAIT_INPUT			;espero a que buffer input esta vacio
	
	mov	al,0xAE					;muevo en AL el codigo de habilitación del teclado
	out	0x64,al			;Envio al 8042
	call	KB_WAIT_INPUT			;espero a que buffer input esta vacio

	

	pop	ax					
	ret						
	
	
KB_WAIT_INPUT:

	in	al,0x64			;HAgo Lectura el estado del 8042
	test	al,2					;Verifico que el buffer de entrada este vacio
	jnz	KB_WAIT_INPUT			;Si no lo esta espero a que lo este
	ret						;Retorno cuando el buffer de entrada esta vacio

KB_WAIT_OUTPUT:

	in	al,0x64							;HAgo Lectura el estado del 8042
	test	al,1					;Verifico que el buffer de salida este lleno
	jz	KB_WAIT_OUTPUT			;Si no lo esta espero a que lo este
	ret	