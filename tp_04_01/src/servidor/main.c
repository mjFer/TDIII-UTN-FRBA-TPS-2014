#include "globals.h"
#include "array.h"
#include "childs.h"


#define ACCEPTED_MSG "Conexion Aceptada"



int main(void)
{
    int fdSocket, fdtSocket,clntLen;
    struct sockaddr_in ServerTcp, ClienteTcp;

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
   printf("\nEsperando Conexiones\n");
   fdtSocket=accept(fdSocket,(struct sockaddr*)&ClienteTcp,&clntLen);
   
   send(fdtSocket,ACCEPTED_MSG,strlen(ACCEPTED_MSG)+1,0);
   
    //if(write(fdtSocket,ACCEPTED_MSG,sizeof("ACCEPTED_MSG")+1)!=sizeof("ACCEPTED_MSG")+1)
    //{
    //  perror("Error en write");
    //}
    sleep(10);
    if(close (fdtSocket)==-1);
    {
      perror("Close():");
    }
   
   
  }

  return 0;
}