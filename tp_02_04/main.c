#include <stdio.h> 
#include <stdlib.h> 
#include <pthread.h> 

#include <unistd.h>

//para el open
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define TRUE 1
#define FALSE 0

#define SEARCH_N_1 30
#define SEARCH_N_2 100
#define ARRAY_SIZE 500
#define NUM_MAX 1000

void Thread1(void *attr);
void Thread2(void *attr);

typedef struct atr{
 int  *listaNumeros;
 int numero_Deseado;
}atr;

 pthread_t thd1;
 pthread_t thd2;

int main(int argc, char *argv[])
{
    int numeros[ARRAY_SIZE];
    int i=0;
    int r_fd;
    int buff;
    printf("[%i] Proceso: starting... \n",getpid());
    
    //genero la lista de numeros random
    r_fd=open("/dev/random",O_RDONLY);
    for(i=0;i<ARRAY_SIZE;i++){
      
       read(r_fd, &buff, 1);
       numeros[i] = buff%NUM_MAX;  
       printf("[%i]%i - ",i,numeros[i]);
    }
   
   //numeros[SEARCH_N_1] = SEARCH_N_1;
   //numeros[10] = SEARCH_N_2;
   
   
    printf("\n[%i] Proceso: lista Creada... \n",getpid());
    printf("[%i] Proceso: Creo thread1... \n",getpid());
    //creo el thread0
    atr atr1 = {numeros,SEARCH_N_1};
    pthread_create (&thd1, NULL, (void*)Thread1,&atr1);  
    //creo el thread1
    printf("[%i] Proceso: Creo thread2... \n",getpid());
    atr atr2 = {numeros,SEARCH_N_2};
    pthread_create (&thd2, NULL, (void*)Thread2,&atr2);  
   
    pthread_join(thd1,NULL);
    pthread_join(thd2,NULL);
    printf("\nProceso Principal - pid: %d\n",getpid());
    
    return 0;
}



void Thread1(void *attr){
  atr* _atr = (atr *)attr;
  int i;
 
 printf("[%i] Proceso: Thread1 Running... \n",getpid());
 for(i=0;i<ARRAY_SIZE;i++){
       if((_atr->listaNumeros)[i] == _atr->numero_Deseado){
	printf("\nThread1: Found %i at %i. \n",_atr->numero_Deseado,i);
        pthread_cancel(thd2);
	pthread_exit(NULL); 
      }
       
    }
 
  printf("\nThread1: %i NOT FOUND!. \n",_atr->numero_Deseado);
  pthread_exit(NULL); 
}

void Thread2(void *attr){
  atr* _atr = (atr *)attr;
  int i;
 
   printf("[%i] Proceso: Thread2 Running... \n",getpid());
 for(i=ARRAY_SIZE;i>0;i--){
       if((_atr->listaNumeros)[i] == _atr->numero_Deseado){
	printf("\nThread1: Found %i at %i. \n",_atr->numero_Deseado,i);
        pthread_cancel(thd1);
	pthread_exit(NULL); 
      }
       
  }
 
  printf("\nThread1: %i NOT FOUND!. \n",_atr->numero_Deseado);
  pthread_exit(NULL); 
}

