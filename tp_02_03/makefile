


.PHONY : clean


ejercicio: main.c childs.o array.o
	gcc -Wall -g -o $@ $^
	
	
	
childs.o: ./utils/childs.c
	gcc -Wall -g -c  $<
	
array.o: ./utils/array.c
	gcc -Wall -g -c  $<
	

clean:
	rm *.o ejercicio  	
	
edit:
	sudo kate *.asm *.c *.h makefile
