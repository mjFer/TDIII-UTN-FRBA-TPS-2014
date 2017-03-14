#include "globals.h"




int main(int cant, char *param[])
{
  int fdSocket;
  struct sockaddr_in ServerTcp,ClienteTcp;
  char buff[50];

  
  if(cant<2){
   printf("Se debe pasar la ip del servidor por argumento\n");
   exit(0);
  }

  //AF_INET == internet | SOCK_STREAM orientado a la conexion | 0 TCP
  fdSocket=socket(AF_INET,SOCK_STREAM,0);
  //seteamos a cero la estructura
  memset(&ClienteTcp,0,sizeof(ClienteTcp));
  
  ServerTcp.sin_family=AF_INET;
  //Seteamos puerto PORT_TCP
  ServerTcp.sin_port=htons(PORTTCP);
  //le pase la ip por parametro
  ServerTcp.sin_addr.s_addr=inet_addr(param[1]);
  
  ClienteTcp.sin_family=AF_INET;
  ClienteTcp.sin_port=htons(PORTCLI);
  ClienteTcp.sin_addr.s_addr=htonl(INADDR_ANY);
  
  bind(fdSocket,(struct sockaddr*)&ClienteTcp,sizeof(ClienteTcp));
  
  connect(fdSocket,(struct sockaddr*)&ServerTcp,sizeof(ServerTcp));
  
  read(fdSocket,buff,50);
     
  printf("MENSAJE RECIBIDO:[%s]\n",buff);
  close (fdSocket);
  printf("\nConexion Finalizada\n");
     

  return 0;  
}