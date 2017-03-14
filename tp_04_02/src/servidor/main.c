#include "globals.h"
#include "array.h"
#include "childs.h"


#define ACCEPTED_MSG "Conexion Aceptada"

void childFunc(char *argv[]);

int main(void)
{
  int fdSocket, fdtSocket,clntLen;
  struct sockaddr_in ServerTcp, ClienteTcp;
  char argv[1][30];
  childstruct newChild;
  
  arrayElement *childList;
  
  childList = NULL;

  printf("[%i] Server On... END para terminar \n",getpid());
  
  //AF_INET == internet | SOCK_STREAM orientado a la conexion | 0 TCP
  fdSocket=socket(AF_INET,SOCK_STREAM,0);
  //seteamos a cero la estructura
  memset(&ServerTcp,0,sizeof(ServerTcp));
  ServerTcp.sin_family=AF_INET;
  //Seteamos puerto PORT_TCP
  ServerTcp.sin_port=htons(PORTTCP);
  //LocalHost
  ServerTcp.sin_addr.s_addr=htonl(INADDR_ANY);
  //terminamos de establecer conexion
  bind(fdSocket,(struct sockaddr*)&ServerTcp,sizeof(ServerTcp));
  //permitimos la escucha
  listen(fdSocket,5);
  
  clntLen=sizeof(ClienteTcp);
  while (1)
  {
   printf("Esperando Conexiones\n");
   fdtSocket=accept(fdSocket,(struct sockaddr*)&ClienteTcp,&clntLen);
   
   
    printf("[%i] Server Padre: creando child para %i\n",getpid(),fdtSocket);
    //genero el child
    newChild.childType = CHILD_TYPE_DEFAULT;
    newChild.childFunction = childFunc;
    memcpy(argv,&fdtSocket , sizeof(int) );
    newChild.argv = (char **)&argv;
    printf("[%i] || %i ||\n",getpid(),*((int *)argv));
    createChild(&childList,&newChild); 
   
  }

  return 0;
}

void childFunc(char *argv[]){
  int fdtSocket;
  printf("[%i] Server Child: Running...\n",getpid());
  memcpy( &fdtSocket,argv,   sizeof(int) );
  
  send(fdtSocket,ACCEPTED_MSG,strlen(ACCEPTED_MSG)+1,0);
   
  sleep(10);
  if(close (fdtSocket)==-1){
    perror("Close():");
  }
  
  printf("[%i] Server Child: Terminando...",getpid());
  exit(0);
}
