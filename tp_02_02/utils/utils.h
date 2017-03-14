
#ifndef UTILS_H
#define UTILS_H

#include <unistd.h>
#include <sys/types.h>
#include "array.h"

typedef struct childstruct{
  pid_t pid; 
}childstruct;


//***************************************************************
//		Agregado de entrada de Child a la lista		
//***************************************************************
void addChild_entry(arrayElement **BaseArray,pid_t pid);

//***************************************************************
//		Eliminacion de entrada de Child		
//***************************************************************
void DeleteChildEntry(arrayElement **BaseArray,pid_t pid);

#endif