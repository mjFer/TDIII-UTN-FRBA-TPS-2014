#include "globals.h"
#include "array.h"
#include "childs.h"



#define EXIT_STRING "exit"

//handlers de signals
//void sINT_Handler (void);
void sTERM_Handler(void );
void sUSR1_Handler(void );
void sUSR2_Handler(void );
void chldHandler (void);



int main(int argc, char *argv[])
{
  struct sigaction _sigAction;
  arrayElement *childList;
  childstruct *newChild;

  /*para la shared memory */
  int		shmid, semid;
  char		*shmptr;
  key_t         clave;
   union semun InitVal;

  char in[20];
  char string[20];
  char string2[20];
  childList = NULL;

  
  memset (&_sigAction, 0, sizeof(_sigAction));

  //inicializo la signal de control c (SIGINT)
  //_sigAction.sa_handler = (void *) sINT_Handler;
  //_sigAction.sa_restorer = NULL;
  //sigaction (SIGINT, &_sigAction, NULL);
  
    //inicializo la signal de control c (SIGTERM)
  _sigAction.sa_handler = (void *) sTERM_Handler;
  _sigAction.sa_restorer = NULL;
  sigaction (SIGTERM, &_sigAction, NULL);
  
  //inicializo la signal de SIGUSR1
  _sigAction.sa_handler = (void *) sUSR1_Handler;
  _sigAction.sa_restorer = NULL;
  sigaction (SIGUSR1, &_sigAction, NULL);
  
  //inicializo la signal de SIGUSR2
  _sigAction.sa_handler = (void *) sUSR2_Handler;
  _sigAction.sa_restorer = NULL;
  sigaction (SIGUSR2, &_sigAction, NULL);
  
  //inicializo la child action
  _sigAction.sa_handler = (void *) chldHandler;
  _sigAction.sa_restorer = NULL;
  sigaction (SIGCHLD, &_sigAction, NULL);
  
  
  printf("[%i] Proceso Padre... END para terminar \n",getpid());
  

  
  /*pido memoria compartida */
  clave=ftok(".",101);
  if (clave == -1)
    perror("ftok fallo...");        
  shmid=shmget(clave, sizeof(shm_packet),IPC_CREAT | 0666);
  if (shmid == -1)
    perror("shmget fallo...");
  shmptr=shmat(shmid,NULL,0);
  printf("[%i]  shmid: %i \n",getpid(),shmid);
  
  /* creo 2semaforos semaforo de control*/ 
  semid=semget(clave, 6, IPC_CREAT | 0666);
  InitVal.val = AUDIO_CAPTURE_PACKET_N;
  semctl(semid,0,SETVAL,InitVal);
  InitVal.val=0;
  semctl(semid,1,SETVAL,InitVal);

  //genero el child1
  strcpy(string,CHILD1_ROUTE);
  newChild =   (childstruct *)malloc(sizeof(childstruct));
  newChild->processRoute = string;
  createChild(&childList,newChild);
  
  //genero el child2
  strcpy(string2,CHILD2_ROUTE);
  newChild =   (childstruct *)malloc(sizeof(childstruct));
  newChild->processRoute = string2;
  createChild(&childList,newChild);
  
  do{
     scanf("%s", in);
  }while(strcmp(EXIT_STRING,in)!=0);
  
  //me desligo de la shared memory
  if(shmdt(shmptr)==-1){
   perror("shmdt():"); 
  }
  //if((semctl(a,0,IPC_RMID,0))==-1) {                                // Return semaphore a 
  //         perror("\nCan't RPC_RMID.");                                             
  //         exit(0);                                                                                
 // }
  
  return 0;
}


void sINT_Handler(void ){
  printf("Presionaste Ctl-c...cerrando\n");  
}

void sTERM_Handler(void ){
  printf("Presionaste SIGTERM...se ignora\n");
}

void sUSR1_Handler(void ){
  printf("SIGNAL USR1.... \n ");
}

void sUSR2_Handler(void ){
  printf("sUSR2 \n ");
}

void chldHandler (void){ 
  wait(NULL);
}

