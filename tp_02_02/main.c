#include <stdio.h>
#include <unistd.h>

#include <stdlib.h>
#include <signal.h>
#include <string.h>

#include "./utils/array.h"
#include "./utils/utils.h"

#define TRUE 1
#define FALSE 0
#define EXIT_STRING "exit"
#define MAX_CHILDS 30

//handlers de signals
void sINT_Handler (void);
void sTERM_Handler(void );
void sUSR1_Handler(void );
void sUSR2_Handler(void );


void createChilds(void );
void destroyChilds(void);
void chldHandler (void);

unsigned char createChildsFlag;
unsigned char destroyChildsFlag;

arrayElement *childList;

int main(int argc, char *argv[])
{
  char var[10];
  int var1;
  //pid_t pid;
  int n_childs;
  struct sigaction _sigAction;

  childList = NULL;
  
    memset (&_sigAction, 0, sizeof(_sigAction));

    //inicializo la signal de control c (SIGINT)
    _sigAction.sa_handler = (void *) sINT_Handler;
    _sigAction.sa_restorer = NULL;
    sigaction (SIGINT, &_sigAction, NULL);
    
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
    
    printf("\nProceso Padre - pid: %d\n --para terminar el proceso genere una SIGUSR2 e ingrese '0'.\n",getpid());
    do{
      if(createChildsFlag){
	createChilds();
	createChildsFlag = FALSE;
	printf("\nTermine de crearChilds");
      }
      if(destroyChildsFlag){
	destroyChilds();
	destroyChildsFlag = FALSE;
	printf("\nTermine de destruirChilds");
      }
    }while(1);
}

void sINT_Handler(void ){
  printf("\nPresionaste Ctl-c...se ignora");
}

void sTERM_Handler(void ){
  printf("\nPresionaste SIGTERM...se ignora");
}

void sUSR1_Handler(void ){
  printf("\n SIGNAL USR1.... ");
  createChildsFlag = TRUE;
}

void sUSR2_Handler(void ){
  printf("\n sUSR2 ");
  destroyChildsFlag = TRUE;
}

void chldHandler (void){ 
  wait();
}

void createChilds(){
  pid_t _pid=0;
  int n_childs=0;
  int ac =0;

  printf("Ingrese el numero de childs a crear: ");
  scanf("%i",&n_childs);
  
  //creo los childs que me pidieron
  while(ac < n_childs){
      _pid=fork();
      if (_pid>0){
	  ac++;
	  addChild_entry( &childList, _pid);
	printf(" [%i] -- Entrada de child %i indexada \n",getpid(),_pid);
      }
      else{
	  printf(" [%i] - Child running \n",getpid());
	  while(1){
	   sleep(10); 
	  };
	  printf(" [%i] - Terminado.\n",getpid());
	  exit;
      }
  }
  ac =0;
  printf(" [%i] - fin - createChild().\n",getpid());
	  
  return;
}

void destroyChilds(){
  pid_t pid;
  arrayElement *arEl;
  childstruct *child;

  printf("\n Listado de Childs: "); 
  
  if(childList!=NULL){
    arEl = childList;
    do{
      child = (childstruct *)(arEl->data);
      printf(" %i, ",child->pid);
      arEl = arEl->next;
    }while(arEl != NULL);
  }
  
  printf("\n Ingrese PID del hijo a destruir o '0' para matar todos los procesos: ");
  scanf("%i",&pid);
  
  if(pid>0){
    printf("[i] Destruyo a PID: %i \n",getpid(),child->pid);
    kill(pid, SIGINT);	//mato al hijo
    DeleteChildEntry(&childList,pid);
  }else{
     if(childList!=NULL){
       arEl = childList;
	do{
	  child = (childstruct *)(arEl->data);
	  arEl = arEl->next;
	  
	  //mato a cada hijo
	  printf("[%i] Destruyo a PID: %i \n",getpid(),child->pid);
	  kill(child->pid, SIGKILL);	//mato al hijo
	  DeleteChildEntry(&childList,child->pid);
	}while(arEl != NULL);
     }
    //terminados los hijos salgo
    exit(0);
  
  }
  
}