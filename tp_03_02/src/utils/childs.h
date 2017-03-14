
#ifndef CHILDS_H
#define CHILDS_H

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include "array.h"

typedef struct childstruct{
  pid_t pid; 
  char* processRoute;
}childstruct;


//***************************************************************
//		Agregado de entrada de Child a la lista		
//***************************************************************
void addChild_entry(arrayElement **BaseArray,childstruct *newChild);

//***************************************************************
//		Eliminacion de entrada de Child		
//***************************************************************
void DeleteChildEntry(arrayElement **BaseArray,pid_t pid);

//***************************************************************
//		Creamos el child con la estructura pasada
//***************************************************************
void createChild(arrayElement **ChildInfoArrayBase,childstruct *newChild);

#endif