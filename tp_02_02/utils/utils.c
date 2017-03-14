

#include "./utils.h"


 void addChild_entry(arrayElement **BaseArray,pid_t pid){
 childstruct *newChild;
 arrayElement *el;
 newChild =   (childstruct *)malloc(sizeof(childstruct));
 newChild->pid = pid;
 
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




