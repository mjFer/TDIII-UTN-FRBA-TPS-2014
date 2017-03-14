#include <stdio.h>
#include <unistd.h>

#include <stdlib.h>
#include <signal.h>
#include <string.h>


#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <sys/wait.h> 

#include "./utils/array.h"
#include "./utils/childs.h"

#define TRUE 1
#define FALSE 0
#define EXIT_STRING "exit"
#define MAX_CHILDS 30

//handlers de signals
void sINT_Handler (void);
void sTERM_Handler(void );
void sUSR1_Handler(void );
void sUSR2_Handler(void );
void chldHandler (void);


void Task1(void);
void Task2(void);

void createChilds(arrayElement *);
void destroyChilds(arrayElement *);


 int _pipe[2];

int main(int argc, char *argv[])
{

 
  struct sigaction _sigAction;
  arrayElement *childList;
  childstruct *newChild;

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
    
    pipe(_pipe);
    
    printf("\nProceso Padre - pid: %d\n -- END para terminar \n",getpid());
    

    //genero el child
    newChild =   (childstruct *)malloc(sizeof(childstruct));
    newChild->childFunction = Task2;
    createChild(&childList,newChild);
    
    //corro mi tarea
    Task1();
    printf("[%i] KILL...\n",getpid());
    return 0;
}

void sINT_Handler(void ){
  printf("Presionaste Ctl-c...se ignora\n");
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

void Task1(void){
  int log_fd;
  char cad[20];
  
  // O_CREAT - si no existe lo crea
  // O_RDWR  - read write
  log_fd=open(" /var/log/chldmsg.log",O_RDWR+O_CREAT);
  
  close(_pipe[0]);//mato la salida del pipe total yo escribo

  //printf("[%i] Child1 (Lectura STDIN) -- Termine los procesos con END \n",getpid());
  printf("[%i] Introduce texto: \n",getpid());
  do{ 
   scanf("%s",cad);
   write(log_fd,cad,strlen(cad)+1);//escribo a archivo
   write (_pipe[1],cad,strlen(cad)+1);//escribo en el pipe   
  }while(strcmp(cad,"END")!=0);
  return;
}

void Task2(void){
 char cad[20];
  
  close(0);//cierro el standard input
  close(_pipe[1]);//mato la entrada del pipe total yo leo nomas
  
  printf("[%i] Child2 (Escritura STDIN) PPID: %i \n",getpid(),getppid());
  do{
    read(_pipe[0],&cad,20);
    printf("[%i] TextoIngresado:  %s\n",getpid(),cad);
  }while(strcmp(cad,"END")!=0);
  printf("[%i] KILL...\n",getpid());
  exit(0);
}

