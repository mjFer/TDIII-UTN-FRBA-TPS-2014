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
	mov	al,KERNEL_SIZE_SECTORS  ; load how many sectors will be read
        mov	cx, 02h			; starting from track 0, sector 2
	mov	dh, 0			; load head = 0
	mov 	dl, 0 			; drive 0 (A:)
	mov	ebx, KERNEL_MEMORY	; load linear destination address at ebx
	shr	ebx,4			; shift right ebx (result at BX will be the segment)
	mov	es,bx			; load destination segment
	mov	bx, 0			; load 0 offset  
int	13h			; read disk

;---------------------------------------------------------------------------         
        
 jc      error                   ; if carry is set, int 13h didn't work
        jmp     (KERNEL_MEMORY>>4):0    ; jmp to the kernel code

error:
   	hlt

    times   510-($-$$)  db 0 ;fill the space till 510 
                             ;with zeroes

    dw 0xAA55                ;boot sector identifier
