//*****************************************************************************
//ARCHIVO:	static_queue.h
//CREADOR:	Fernandez Marcelo Joaquin
//FECHA:	31/10/14
//OTROS: 	UTN - FRBA - TECNICAS DIGITALES III
//****************************************************************************

#ifndef STATIC_QUEUE
#define STATIC_QUEUE


#include "globals.h"

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/ipc.h>
//#include <sys/shm.h>
#include <sys/sem.h>
#include <semaphore.h>
#include <string.h>



//cantidad maxima permitida en una fifo de elementos
#define MAX_FILO_SIZE 100
//cantidad  maxima de bytes que puede ocupar una entrada
#define MAX_ENTRY_SIZE 100000




typedef struct static_fifo_queue{
  //tamaño de una entrada
  ssize_t entry_size;
  //numero de lugares de la cola
  int n_entrys;
  //puntero a entradas
  void *elements;
  
  //indice al cual tiene que retirar elemento
  int takeIndex;
  //indide al cual tiene que llenar elemento
  int fillIndex;
  
  //int id de los semaforos
  int semid;
  //semaforo de cantidad de lugares libres y completos
  int sem_empty;
  int sem_full;
  
  //USO INTERNO 
  struct sembuf SemArg;
}static_fifo_queue;


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
		    int _semid, int _sem_empty,int _sem_full);

//*****************************************************************************
//		Funcion de destruccion de fifo
//		
//	Argumentos: 	fifo : 		la cola
//****************************************************************************
int fifo_dispose(static_fifo_queue *_fifo);

//*****************************************************************************
//		Funcion de remosion en lista
//		
//	Argumentos: 	fifo : la cola
//			outData puntero a la memoria donde se copia el elemento
//****************************************************************************
int fifo_take_smph(static_fifo_queue *fifo, void *outData);
//*****************************************************************************
//		Funcion de Agregado en lista
//		
//	Argumentos: 	fifo : la cola
//			inData puntero a la memoria donde se copia el elemento
//****************************************************************************
int fifo_addto_smph(static_fifo_queue *fifo, void *inData);

#endif