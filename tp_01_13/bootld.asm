;***********************************************************
;   UTN-TD3-BOOTLOADER
;***********************************************************
;   Assembler: 
;           nasm
;   To assemble bootable disk: 
;           make bootdisk
;   To assemble bootloader code:
;	    make bootloader
;***********************************************************
;   Author  : Sebastián Viviani
;   Date    : 13th May 2009
;***********************************************************
[ORG 0x7C00];BIOS loads bootsector here

%ifndef KERNEL_MEMORY
	%error "Kernel start address not defined"
	;kernel_memory must be 16 byte aligned
%endif	

%ifndef KERNEL_SIZE_SECTORS
	%error "Kernel size (in sectors) not defined"
%endif	

[BITS 16]   ;for real mode; 16-bit instructions
	cli		                       ;clear interrupts
;-----------------------------------------------------------
; INITIALIZATION PROCEDURES
        
	mov	ah, 02h			; load int 13h function (read sector)
	;mov	al,KERNEL_SIZE_SECTORS  ; load how many sectors will be read
	mov al, 17
        mov	cx, 02h			; starting from track 0, sector 2
	mov	dh, 0			; load head = 0
	mov 	dl, 0 			; drive 0 (A:)
	mov	ebx, KERNEL_MEMORY	; load linear destination address at ebx
	shr	ebx,4			; shift right ebx (result at BX will be the segment)
	mov	es,bx			; load destination segment
	mov	bx, 0			; load 0 offset  
	int	13h			; read disk
	
;---------------------------------------------------------------------------         
        mov     ah, 02h                 ; load int 13h function (read sector)
        mov     al,18                   ; load how many sectors will be read
        mov     cl, 1h                 ; starting from sector 1
        mov     ch, 0h                  ; starting from track 0
        mov     dh, 1                   ; load head = 1
        mov     dl, 0                   ; drive 0 (A:)
        mov     ebx, KERNEL_MEMORY+8704      ; load linear destination address at ebx
        shr     ebx,4                   ; shift right ebx (result at BX will be the segment)
        mov     es,bx                   ; load destination segment
        mov     bx, 0                   ; load 0 offset  
        int     13h                     ; read disk
;---------------------------------------------------------------------------         
        mov     ah, 02h                 ; load int 13h function (read sector)
        mov     al,18                   ; load how many sectors will be read
        mov     cl, 1h                 ; starting from sector 1
        mov     ch, 1h                  ; starting from track 1
        mov     dh, 0                   ; load head = 0
        mov     dl, 0                   ; drive 0 (A:)
        mov     ebx, KERNEL_MEMORY+17920      ; load linear destination address at ebx
        shr     ebx,4                   ; shift right ebx (result at BX will be the segment)
        mov     es,bx                   ; load destination segment
        mov     bx, 0                   ; load 0 offset  
        int     13h                     ; read disk
;---------------------------------------------------------------------------         
        mov     ah, 02h                 ; load int 13h function (read sector)
        mov     al,10                   ; load how many sectors will be read
        mov     cl, 1h                 ; starting from sector 1
        mov     ch, 1h                  ; starting from track 1
        mov     dh, 1                   ; load head = 1
        mov     dl, 0                   ; drive 0 (A:)
        mov     ebx, KERNEL_MEMORY+27136      ; load linear destination address at ebx
        shr     ebx,4                   ; shift right ebx (result at BX will be the segment)
        mov     es,bx                   ; load destination segment
        mov     bx, 0                   ; load 0 offset  
        int     13h                     ; read disk
        
;---------------------------------------------------------------------------         
        mov     ah, 02h                 ; load int 13h function (read sector)
        mov     al,7                   ; load how many sectors will be read
        mov     cl, 12                 ; starting from sector 1
        mov     ch, 1h                  ; starting from track 1
        mov     dh, 1                   ; load head = 1
        mov     dl, 0                   ; drive 0 (A:)
        mov     ebx, KERNEL_MEMORY+32768      ; load linear destination address at ebx
        shr     ebx,4                   ; shift right ebx (result at BX will be the segment)
        mov     es,bx                   ; load destination segment
        mov     bx, 0                   ; load 0 offset  
        int     13h                     ; read disk
        
    ;---------------------------------------------------------------------------         
        mov     ah, 02h                 ; load int 13h function (read sector)
        mov     al,18                  ; load how many sectors will be read
        mov     cl, 1                 ; starting from sector 1
        mov     ch, 2h                  ; starting from track 2
        mov     dh, 0                   ; load head = 1
        mov     dl, 0                   ; drive 0 (A:)
        mov     ebx, KERNEL_MEMORY+36352      ; load linear destination address at ebx
        shr     ebx,4                   ; shift right ebx (result at BX will be the segment)
        mov     es,bx                   ; load destination segment
        mov     bx, 0                   ; load 0 offset  
        int     13h                     ; read disk
        


;---------------------------------------------------------------------------         
        
 jc      error                   ; if carry is set, int 13h didn't work
        jmp     (KERNEL_MEMORY>>4):0    ; jmp to the kernel code

error:
   	hlt
;***********************************************************
; For the file to be identified as a valid boot sector,
; the file must be of size 512 bytes, and the word at 510
;' must be 0xAA55.
    times   510-($-$$)  db 0 ;fill the space till 510 
                             ;with zeroes

    dw 0xAA55                ;boot sector identifier
