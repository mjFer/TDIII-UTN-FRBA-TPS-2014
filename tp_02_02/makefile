


.PHONY : clean


ejercicio: main.c utils.o array.o
	gcc -g -o $@ $^
	
	
	
utils.o: ./utils/utils.c
	gcc -g -c  $<
	
array.o: ./utils/array.c
	gcc -g -c  $<
	

clean:
	rm *.o ejercicio  	
	
edit:
	sudo kate *.asm *.c *.h makefile
