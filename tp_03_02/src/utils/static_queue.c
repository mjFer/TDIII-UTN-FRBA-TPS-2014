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
  union semun InitVal;
  
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
    
    _filo->takeIndex=0;
    _filo->fillIndex=0;
    
    _filo->semid = _semid;
    _filo->sem_empty = _sem_empty;
    _filo->sem_full = _sem_full;
    
     InitVal.val = _n_entrys;
     semctl(_filo->semid,_sem_empty   ,SETVAL,InitVal);
     InitVal.val=0;
     semctl(_filo->semid,_sem_full ,SETVAL,InitVal);
     

    
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
    memcpy( outData,element,filo->entry_size);
    
    filo->takeIndex++;
    //si takeindex paso el n_entrys lo llevo a cero
    filo->takeIndex%=filo->n_entrys;
    
    /*incremento el semaforo de lugares libres*/
    filo->SemArg.sem_num = filo->sem_empty;
    filo->SemArg.sem_op=1;
    filo->SemArg.sem_flg=SEM_UNDO;
    semop(filo->semid, &filo->SemArg, 1 );
  }else{
    perror("fallo");
    return -1;
  }
  
  return 0;
}  

//*****************************************************************************
//		Funcion de Agregado en lista
//		
//	Argumentos: 	filo : la cola
//			inData puntero a la memoria donde se copia el elemento
//****************************************************************************
int filo_addto_smph(static_filo_queue *filo, void *inData){
 struct sembuf SemArg;
  void *element;
  //int v1,v2;
  printf("filo: ez:%i | en°:%u | ti:%i | fi:%i | semid:%i | sem_full:%i | sem_empty:%i \n",(int)filo->entry_size,filo->n_entrys,filo->takeIndex,filo->fillIndex,filo->semid,filo->sem_empty,filo->sem_full);
  //v1 =  semctl ( filo->semid, filo->sem_empty, GETVAL, NULL );
  //v2 =  semctl ( filo->semid, filo->sem_full, GETVAL, NULL );
  //printf("filo: empty_smph:%i sem_full:%i \n",v1,v2); 
  if(filo!=NULL){
    /*decremento el semaforo de lugares vacios*/
    SemArg.sem_num = filo->sem_empty;
    SemArg.sem_op=-1;
    SemArg.sem_flg=SEM_UNDO;
    semop(filo->semid, &SemArg, 1 );
   
    element = (filo->elements + filo->fillIndex);
    
    memcpy(element, inData,filo->entry_size);
    
    filo->fillIndex++;
    //si takeindex paso el n_entrys lo llevo a cero
    filo->fillIndex%=filo->n_entrys;
    
    /*incremento el semaforo de lugares llenos*/
    SemArg.sem_num = filo->sem_full;
    SemArg.sem_op=1;
    SemArg.sem_flg=SEM_UNDO;
    semop(filo->semid, &SemArg, 1 );
 
  }else{
    perror("fallo");
    return -1;
  }
  return 0;
} 

