

#include "./childs.h"



 void addChild_entry(arrayElement **BaseArray,childstruct *newChild){
 arrayElement *el;
 //newChild =   (childstruct *)malloc(sizeof(childstruct));
 //newChild->pid = pid;
 
 if(*BaseArray !=NULL){
	array_AddAtEnd(*BaseArray, newChild, sizeof(childstruct));
  }else{
	el = array_Create(newChild,sizeof(childstruct));
	*BaseArray = el;
 }	
}

void DeleteChildEntry(arrayElement **BaseArray,pid_t pid){
	int index = 0;
	
	arrayElement * element = (*BaseArray);
	do{
		if(((childstruct *)element->data)->pid == pid){
			array_RemoveAndDestroy(BaseArray,index);
			return;
		}
		index++;
		element = element->next;
	}while(element !=NULL);

}


void createChild(arrayElement **ChildInfoArrayBase,childstruct *newChild){
  pid_t _pid=0;
  
      _pid=fork();
      if (_pid>0){
	newChild->pid = _pid;
	addChild_entry( ChildInfoArrayBase, newChild);
	printf(" [%i] -- Entrada de child %i indexada \n",getpid(),_pid);
	return;
      }
      else{
	  printf(" [%i] - Child running \n",getpid());
	  if(newChild->childType == CHILD_TYPE_DEFAULT){
	   if(newChild->childFunction !=NULL){
	       (*(newChild->childFunction))(newChild->argv);
	    }else{
	      printf(" [%i] - Sin puntero a funcion.\n",getpid());
	    }
	  }
	  else if(newChild->childType == CHILD_TYPE_WITH_ROUTE){
	    if(newChild->processRoute !=NULL){
		execlp(newChild->processRoute, newChild->processRoute, newChild->argv,NULL);
	    }else{
	      printf(" [%i] - Sin ruta para ejecutar.\n",getpid());
	    }
	  }
	   
	  printf(" [%i] - Terminado.\n",getpid());
	  exit(0);
      }
}
 
	  
childstruct* GetFirstChild(arrayElement **BaseArray){
  arrayElement * element = (*BaseArray);
  if(element!=NULL)
	return (childstruct *)element->data;
  return NULL;
} 
  
pid_t GetFirstChildPID(arrayElement **BaseArray){
  arrayElement * element = (*BaseArray);
  if(element!=NULL){
	return ((childstruct *)element->data)->pid;
  }
  return -1;
} 



