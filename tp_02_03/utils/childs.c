

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
     array_RemoveAndDestroy(*BaseArray,index);
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
	  if(newChild->childFunction !=NULL){
	      (*(newChild->childFunction))();
	  }else{
	    printf(" [%i] - Sin puntero a funcion.\n",getpid());
	  }
	   
	  printf(" [%i] - Terminado.\n",getpid());
	  exit(0);
      }
}
 
	  
  
  




