//*****************************************************************************
//ARCHIVO:	static_queue.c
//CREADOR:	Fernandez Marcelo Joaquin
//FECHA:	31/10/14
//OTROS: 	UTN - FRBA - TECNICAS DIGITALES III
//****************************************************************************

#include "static_queue.h"

//*****************************************************************************
//		Funcion de inicializacion de fifo
//		
//	Argumentos: 	fifo : 		la cola
//			_n_entrys: 	numero de elementos que podra poseer
//			_entry_size:	tamaño de un elemento
//			_semid:		identificador del bloque se semaforos
//			_sem_empty:	cual es el semaforo de empty
//			_sem_full:	cual es el semaforo de full
//****************************************************************************
int fifo_init(static_fifo_queue *_fifo, int _n_entrys, ssize_t _entry_size, 
		    int _semid, int _sem_empty,int _sem_full){
  union semun InitVal;
  
  if(_fifo != NULL){
    if(_n_entrys > 0   &&   _n_entrys < MAX_FILO_SIZE){
      _fifo->n_entrys = _n_entrys;
    }else{
      perror("fifo n_entrys error");
      return -1;
    }
    
    if(_entry_size > 0   &&   _entry_size < MAX_ENTRY_SIZE){
      _fifo->entry_size = _entry_size;
    }else{
      perror("fifo entry_size error");
      return -1;
    }
    
    _fifo->takeIndex=0;
    _fifo->fillIndex=0;
    
    _fifo->semid = _semid;
    _fifo->sem_empty = _sem_empty;
    _fifo->sem_full = _sem_full;
    
     InitVal.val = _n_entrys;
     semctl(_fifo->semid,_sem_empty   ,SETVAL,InitVal);
     InitVal.val=0;
     semctl(_fifo->semid,_sem_full ,SETVAL,InitVal);
     

    
    _fifo->elements = malloc(_entry_size * _n_entrys);
  }else{
    perror("fifo error");
    return -1;
  }
  return 0;
}  

//*****************************************************************************
//		Funcion de destruccion de fifo
//		
//	Argumentos: 	fifo : 		la cola
//****************************************************************************
int fifo_dispose(static_fifo_queue *_fifo){
  if(_fifo != NULL){
    free(_fifo->elements);
  }else{
    perror("fifo error");
    return -1;
  }
  return 0;
}  

//*****************************************************************************
//		Funcion de remosion en lista
//		
//	Argumentos: 	fifo : la cola
//			outData puntero a la memoria donde se copia el elemento
//****************************************************************************
int fifo_take_smph(static_fifo_queue *fifo, void *outData){
	void *element;

	if(fifo!=NULL){
		/*decremento el semaforo de lugares llenos*/
		fifo->SemArg.sem_num = fifo->sem_full;
		fifo->SemArg.sem_op=-1;
		fifo->SemArg.sem_flg=SEM_UNDO;
		if(semop(fifo->semid, &fifo->SemArg, 1 )!=-1){
			//element = (fifo->elements + fifo->takeIndex);
			element = (fifo->elements + fifo->takeIndex * (fifo->entry_size));
			
			//printf("queuettttt:                  | ts:%i | ssize_t:%i \n",((SampleBaseEntry *)element)->timestamp,((SampleBaseEntry *)element)->readed_blocks);
			memcpy( outData,element,fifo->entry_size);
			
			fifo->takeIndex++;
			//si takeindex paso el n_entrys lo llevo a cero
			fifo->takeIndex%=fifo->n_entrys;
		}else{
			perror("fallo D");
			return -1;
		}
	
		/*incremento el semaforo de lugares libres*/
		fifo->SemArg.sem_num = fifo->sem_empty;
		fifo->SemArg.sem_op=1;
		fifo->SemArg.sem_flg=SEM_UNDO;
		semop(fifo->semid, &fifo->SemArg, 1 );
	}else{
		perror("fallo C");
		return -1;
	}
	//printf("fifo: ez:%i | en°:%u | ti:%i | fi:%i | semid:%i | sem_full:%i | sem_empty:%i \n",(int)fifo->entry_size,fifo->n_entrys,fifo->takeIndex,fifo->fillIndex,fifo->semid,fifo->sem_empty,fifo->sem_full);
	
	return 0;
}  

//*****************************************************************************
//		Funcion de Agregado en lista
//		
//	Argumentos: 	fifo : la cola
//			inData puntero a la memoria donde se copia el elemento
//****************************************************************************
int fifo_addto_smph(static_fifo_queue *fifo, void *inData){
	struct sembuf SemArg;

	void *element;
	//int v1,v2;
	//printf("fifo: ez:%i | en°:%u | ti:%i | fi:%i | semid:%i | sem_full:%i | sem_empty:%i \n",(int)fifo->entry_size,fifo->n_entrys,fifo->takeIndex,fifo->fillIndex,fifo->semid,fifo->sem_empty,fifo->sem_full);
	//v1 =  semctl ( fifo->semid, fifo->sem_empty, GETVAL, NULL );
	//v2 =  semctl ( fifo->semid, fifo->sem_full, GETVAL, NULL );
	//printf("fifo: empty_smph:%i sem_full:%i \n",v1,v2); 
	if(fifo!=NULL){
		/*decremento el semaforo de lugares vacios*/
		SemArg.sem_num = fifo->sem_empty;
		SemArg.sem_op=-1;
		SemArg.sem_flg=SEM_UNDO;
		if(semop(fifo->semid, &SemArg, 1 )!=-1)
		{
			element = (fifo->elements + fifo->fillIndex * (fifo->entry_size));
			//element = (fifo->elements + fifo->fillIndex);
			
			memcpy(element, inData,fifo->entry_size);
			
			fifo->fillIndex++;
			//si takeindex paso el n_entrys lo llevo a cero
			fifo->fillIndex%=fifo->n_entrys;
		}else{
			perror("fallo A");
			return -1;
		}
		
		/*incremento el semaforo de lugares llenos*/
		SemArg.sem_num = fifo->sem_full;
		SemArg.sem_op=1;
		SemArg.sem_flg=SEM_UNDO;
		semop(fifo->semid, &SemArg, 1 );
	
	}else{
		perror("fallo B");
		return -1;
	}
	return 0;
} 

