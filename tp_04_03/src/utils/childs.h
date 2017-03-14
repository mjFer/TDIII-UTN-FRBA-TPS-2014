
#ifndef CHILDS_H
#define CHILDS_H

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include "array.h"

#define CHILD_TYPE_WITH_ROUTE 2
#define CHILD_TYPE_DEFAULT 1

typedef struct childstruct{
  pid_t pid; 
  unsigned int childType;
  char* processRoute; //si es de tipo CHILD_TYPE_WITH_ROUTE aca va la ruta
  void (*childFunction)(char**); //si es de tipo CHILD_TYPE_DEFAULT aca va la ruta
  char **argv; //argumentos para pasarle al proceso
  
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


//***************************************************************
//		Creamos el child con la estructura pasada
//***************************************************************
childstruct* GetFirstChild(arrayElement **BaseArray);
  
//***************************************************************
//		Creamos el child con la estructura pasada
//***************************************************************
pid_t GetFirstChildPID(arrayElement **BaseArray);



#endif