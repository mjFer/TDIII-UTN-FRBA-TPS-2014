//*****************************************************************************
//ARCHIVO:	static_queue.c
//CREADOR:	Fernandez Marcelo Joaquin
//FECHA:	31/10/14
//OTROS: 	UTN - FRBA - TECNICAS DIGITALES III
//****************************************************************************

#include "static_queue.h"

//*****************************************************************************
//		Funcion de inicializacion de filo
//		
//	Argumentos: 	filo : 		la cola
//			_n_entrys: 	numero de elementos que podra poseer
//			_entry_size:	tamaño de un elemento
//			_semid:		identificador del bloque se semaforos
//			_sem_empty:	cual es el semaforo de empty
//			_sem_full:	cual es el semaforo de full
//****************************************************************************
int filo_init(static_filo_queue *_filo, int _n_entrys, ssize_t _entry_size, 
		    int _semid, int _sem_empty,int _sem_full){
  if(_filo != NULL){
    if(_n_entrys > 0   &&   _n_entrys < MAX_FILO_SIZE){
      _filo->n_entrys = _n_entrys;
    }else{
      perror("filo n_entrys error");
      return -1;
    }
    
    if(_entry_size > 0   &&   _entry_size < MAX_ENTRY_SIZE){
      _filo->entry_size = _entry_size;
    }else{
      perror("filo entry_size error");
      return -1;
    }
    
    _filo->semid = _semid;
    _filo->sem_empty = _sem_empty;
    _filo->sem_full = _sem_full;
    
    _filo->elements = malloc(_entry_size * _n_entrys);
  }else{
    perror("filo error");
    return -1;
  }
  return 0;
}  

//*****************************************************************************
//		Funcion de destruccion de filo
//		
//	Argumentos: 	filo : 		la cola
//****************************************************************************
int filo_dispose(static_filo_queue *_filo){
  if(_filo != NULL){
    free(_filo->elements);
  }else{
    perror("filo error");
    return -1;
  }
  return 0;
}  

//*****************************************************************************
//		Funcion de remosion en lista
//		
//	Argumentos: 	filo : la cola
//			outData puntero a la memoria donde se copia el elemento
//****************************************************************************
int filo_take_smph(static_filo_queue *filo, void *outData){
  void *element;

  if(filo!=NULL){
    /*decremento el semaforo de lugares llenos*/
    filo->SemArg.sem_num = filo->sem_full;
    filo->SemArg.sem_op=-1;
    filo->SemArg.sem_flg=SEM_UNDO;
    semop(filo->semid, &filo->SemArg, 1 );
   
    element = (filo->elements + filo->takeIndex);
    memmove( outData,element,filo->entry_size);
    
    filo->takeIndex++;
    //si takeindex paso el n_entrys lo llevo a cero
    filo->takeIndex%=filo->n_entrys;
    
    /*incremento el semaforo de lugares libres*/
    filo->SemArg.sem_num = filo->sem_empty;
    filo->SemArg.sem_op=1;
    filo->SemArg.sem_flg=SEM_UNDO;
    semop(filo->semid, &filo->SemArg, 1 );
  }else
    return -1;
  
  return 0;
}  

//*****************************************************************************
//		Funcion de Agregado en lista
//		
//	Argumentos: 	filo : la cola
//			inData puntero a la memoria donde se copia el elemento
//****************************************************************************
int filo_addto_smph(static_filo_queue *filo, void *inData){
  void *element;

  if(filo!=NULL){
    /*decremento el semaforo de lugares vacios*/
    filo->SemArg.sem_num = filo->sem_empty;
    filo->SemArg.sem_op=-1;
    filo->SemArg.sem_flg=SEM_UNDO;
    semop(filo->semid, &filo->SemArg, 1 );
   
    element = (filo->elements + filo->fillIndex);
    
    memmove(element, inData,filo->entry_size);
    
    filo->fillIndex++;
    //si takeindex paso el n_entrys lo llevo a cero
    filo->fillIndex%=filo->n_entrys;
    
    /*incremento el semaforo de lugares llenos*/
    filo->SemArg.sem_num = filo->sem_full;
    filo->SemArg.sem_op=1;
    filo->SemArg.sem_flg=SEM_UNDO;
    semop(filo->semid, &filo->SemArg, 1 );
 
  }else
    return -1;
  return 0;
} 

