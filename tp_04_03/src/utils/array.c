

#include "array.h"


//***************************************************************
//		Funcion de remosion en lista
//		
//***************************************************************
arrayElement *array_removeAt(arrayElement **arraybase, int index){
	arrayElement *element;
	arrayElement *ant_element = NULL;
	
	if(index>0) ant_element = array_peakAt(*arraybase,index-1);
	element = array_peakAt(*arraybase, index);
	if(element!=NULL){
	
		if(ant_element!= NULL){
			ant_element->next = element->next;
		}else{ //es el indice 0
			
			if(element == *arraybase){
				*arraybase = element->next;
			}else{
				//reportar error 
			}
		}  
		return element;
	}
	return NULL;
}  



//***************************************************************
//		Funcion de lectura de elemento en lista
//		
//***************************************************************
arrayElement *array_peakAt(arrayElement *arraybase, int index){
  arrayElement *element;
  int i=0;
  
  if(arraybase!=NULL){
    element = arraybase;
    while(i<index){
      if(element->next ==NULL)
	return NULL;
      element = element->next;
      i++;
    }
    
    return element;
  }
  return NULL;
}  


//***************************************************************
//		Funcion de creaccion de array
//		
//***************************************************************
arrayElement *array_Create( void *data, size_t datasize ){

  arrayElement *newelement;

  newelement =  (arrayElement *)malloc(sizeof(arrayElement));
  newelement->data = data;
  newelement->data_size = datasize;  
  newelement->next = NULL;
  return newelement;
}  

//***************************************************************
//		Funcion de agregado al final en lista
//		
//***************************************************************
short array_AddAtEnd(arrayElement *arraybase, void *data, size_t datasize ){
  arrayElement *element;
  arrayElement *newelement;  
  
  if(arraybase!=NULL){
    element = arraybase;
    while(element->next !=NULL){     
      element = element->next;
    }
    
    newelement =  (arrayElement *)malloc(sizeof(arraybase));
    newelement->data = data;
    newelement->data_size = datasize;
    element->next = newelement;
    newelement->next = NULL;
  }
  return -1;
}  


//***************************************************************
//		Funcion de remosion y disposeo
//		
//***************************************************************
short array_RemoveAndDestroy(arrayElement **arraybase, int index){
	arrayElement *element;
	
	
	element = array_removeAt(arraybase, index);
	
	if(element!=NULL){
		//TODO: VER
		//if(element->data!=NULL)
		//	free(element->data);
		free(element);
		return 0;
	} 
	return -1;
}  