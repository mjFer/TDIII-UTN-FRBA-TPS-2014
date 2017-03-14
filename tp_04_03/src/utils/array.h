
#ifndef ARRAY_H
#define ARRAY_H

#include <stdlib.h>

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>


typedef struct arrayElement{
 void *data; 
 size_t data_size;
 struct arrayElement *next;
}arrayElement;


//***************************************************************
//		Funcion de Creacion de lista		
//***************************************************************
arrayElement *array_Create( void *data, size_t datasize );
//***************************************************************
//		Funcion de remosion en lista		
//***************************************************************
arrayElement *array_removeAt(arrayElement **arraybase, int index);

//***************************************************************
//		Funcion de lectura de elemento en lista		
//***************************************************************
arrayElement *array_peakAt(arrayElement *arraybase, int index);

//***************************************************************
//		Funcion de agregado al final en lista		
//***************************************************************
short array_AddAtEnd(arrayElement *arraybase, void *data, size_t datasize );

//***************************************************************
//		Funcion de remosion y disposeo		
//***************************************************************
short array_RemoveAndDestroy(arrayElement **arraybase, int index);



#endif
