#include <stdio.h>
#include <unistd.h>

#include <stdlib.h>
#include <signal.h>
#include <string.h>


#define DEFAULT_CHILDS 4

void chldHandler (void);

int alive_childs;

int main(int argc, char *argv[])
{
  int var1;
  pid_t pid;
  int n_childs;
  
  struct sigaction chldAction;
  alive_childs=0;
  if(argc > 1){
    n_childs = atoi(argv[1]);
  }else
  {
    n_childs = DEFAULT_CHILDS;
  }  

  printf("\nProceso Padre - pid: %d\n",getpid());
  
  


    memset (&chldAction, 0, sizeof(chldAction));
    chldAction.sa_handler = (void *) chldHandler;
    chldAction.sa_restorer = NULL;
    sigaction (SIGCHLD, &chldAction, NULL);
    for(;;){
      while(alive_childs < n_childs){
	  pid=fork();

	  if (pid>0){
	      alive_childs++;
	  
	  }
	  else{
	      printf("\nProceso Hijo - pid: %d\n",getpid());
	      var1 = rand() % 100;
	      sleep(var1);
	      printf("\nProceso Hijo Finalizado\n");
	      return(0);
	  }
      }
  }
}


void chldHandler (void)
{
  
  alive_childs--;
  wait();
}