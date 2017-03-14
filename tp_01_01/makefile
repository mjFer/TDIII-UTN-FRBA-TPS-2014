.PHONY : clean

KERNEL_MEMORY=0x8000
KERNEL_SIZE_SECTORS=1

BOOTLOADER_DEFINES=-DKERNEL_SIZE_SECTORS=$(KERNEL_SIZE_SECTORS) -DKERNEL_MEMORY=$(KERNEL_MEMORY)

bootdisk: kernel.bin 
	dd if=/dev/zero of=mydisk count=$(KERNEL_SIZE_SECTORS)	
	dd if=kernel.bin of=mydisk conv=notrunc

kernel.bin: ej1-1.asm
	nasm -f bin  $(BOOTLOADER_DEFINES) ej1-1.asm  -l ej1-1.lst -o $@

clean:
	rm -f  kernel.bin disk *.lst
