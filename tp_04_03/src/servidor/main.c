#include "globals.h"
#include "array.h"
#include "childs.h"
#include <sys/time.h>
#include <pthread.h>

#define ACCEPTED_MSG "Conexion Aceptada"

#include "audio_filter.h"


struct chArgs{
	//sistemV
	int	shmid, semid;
	char	*shmptr;
	key_t clave;
	
	int fdtSocket;
}; 


struct t1Args{
      shm_packet *SHP;
      int semid;
}; 
void thread_FiltradoDSP(struct t1Args *Args);

void childFunc(char *argv[]);


void sINT_Handler(void );
void sTERM_Handler(void );
void chldHandler (void);

//para las signals
int signals_stat;
pid_t chld_pid;


int main(void)
{
	struct sigaction _sigAction;
	pid_t pid;
	int fdSocket, fdtSocket;
	socklen_t clntLen;
	struct sockaddr_in ServerTcp,ClienteTcp;
	char argv[1][30];
	childstruct newChild;
	
	struct t1Args _t1Args;
	pthread_t tr1;

	arrayElement *childList;

	childList = NULL;
	
	union semun InitVal;
	struct chArgs chAr;
	int	shmid, semid;
	char	*shmptr;
	key_t clave;
	//shm_packet *SHP;
	//SampleBaseEntry *SBE ;
	
	
	signals_stat = 0;
	//inicializo la signal de control c (SIGINT)
	_sigAction.sa_handler = (void *) sINT_Handler;
	_sigAction.sa_restorer = NULL;
	sigaction (SIGINT, &_sigAction, NULL);

	//inicializo la signal de control c (SIGTERM)
	_sigAction.sa_handler = (void *) sTERM_Handler;
	_sigAction.sa_restorer = NULL;
	sigaction (SIGTERM, &_sigAction, NULL);
	
	//inicializo la child action
	_sigAction.sa_handler = (void *) chldHandler;
	_sigAction.sa_restorer = NULL;
	sigaction (SIGCHLD, &_sigAction, NULL);
	

	/*pido memoria compartida */
	clave=ftok(".",101);
	if (clave == -1)
		perror("ftok fallo\n");
          
	shmid=shmget(clave, sizeof(shm_packet),IPC_CREAT | 0666);
	if (shmid == -1){
		perror("shmget fallo...");
		exit(1);
	}
	shmptr=shmat(shmid,NULL,0);
	if((long)shmptr == -1){
		perror("shmat:");
		exit(1);
	}
	/* creo un semaforo de control*/
	semid=semget(clave, 4, IPC_CREAT | 0666);
	if (semid == -1){
		perror("semget fallo\n");
		exit(1);
	}
	/* los seteo trabados los 2*/
	InitVal.val = 1;
	semctl(semid,0,SETVAL,InitVal);
	InitVal.val=1;
	semctl(semid,1,SETVAL,InitVal);
	InitVal.val = 1;
	semctl(semid,2,SETVAL,InitVal);
	InitVal.val=1;
	semctl(semid,3,SETVAL,InitVal);
	
	
	printf("[%i] Server: Creando Child de escucha /dev/dsp \n",getpid());
	newChild.childType = CHILD_TYPE_WITH_ROUTE;
	newChild.processRoute = "./audio_listener";
	memcpy(argv,&fdtSocket , sizeof(int) );
	newChild.argv = (char **)&argv;
	createChild(&childList,&newChild); 
	
	
	
	/**********************Creo el thread de Filtrado *************/
	_t1Args.SHP = (shm_packet *)shmptr;
	_t1Args.semid = semid;
	pthread_create (&tr1, NULL, (void*)thread_FiltradoDSP,&_t1Args); 
	

	printf("[%i] Server: On... \n",getpid());
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

		if(fdtSocket!=-1){
			printf("[%i] Server Padre: creando child para %i\n",getpid(),fdtSocket);
			//genero el child
			chAr.shmid = shmid;
			chAr.semid = semid; 
			chAr.shmptr = shmptr; 
			chAr.clave = clave; 
			chAr.fdtSocket = fdtSocket;
			
			newChild.childType = CHILD_TYPE_DEFAULT;
			newChild.childFunction = childFunc;
			memcpy(argv,&fdtSocket , sizeof(int) );
			newChild.argv = (char **)&chAr;
			printf("[%i] || %i ||\n",getpid(),*((int *)argv));
			createChild(&childList,&newChild); 
			close(fdtSocket);
		}else{
			if(errno==EINTR){
				if(signals_stat ==  SIGCHLD) 
					DeleteChildEntry(&childList,chld_pid);
				if(signals_stat ==  SIGINT || signals_stat ==  SIGTERM) 
					break; 
			}
			
		}
	}

	printf("[%i] Server: Cerrando... \n",getpid());
	printf("[%i] Server: Cerrando Hijos... \n",getpid());
	do{
		pid =  GetFirstChildPID(&childList);
		if(pid>0){
			printf("[%i] Server: Cerrando PID:[%i]... \n",getpid(),pid);
			kill(pid,SIGINT);
			DeleteChildEntry(&childList,pid);
		}
	}while(pid>0);	
	
	printf("[%i] Server: Liberando Recursos... \n",getpid());
	semctl(semid,0,IPC_RMID);
	shmdt(shmptr);
	close(fdSocket);
	return 0;
}

void thread_FiltradoDSP(struct t1Args *Args){
	struct sembuf   SemArg;
	union semun InitVal;
		
	int iRead;
	
	shm_packet *SHP;
	SampleBaseEntry *SBE ;
	
	SHP = Args->SHP;
	
	InitVal.val=0;
	semctl(Args->semid,2,SETVAL,InitVal);	
	InitVal.val = 1;
	semctl(Args->semid,3,SETVAL,InitVal);
	
	while(1){
		SemArg.sem_num = 1;
		SemArg.sem_op=0;
		SemArg.sem_flg=SEM_UNDO;
		if(semop(Args->semid, &SemArg, 1 )!=-1){
			
			
			InitVal.val=0;
			semctl(Args->semid,2,SETVAL,InitVal);	
			InitVal.val = 1;
			semctl(Args->semid,3,SETVAL,InitVal);
			
			iRead = SHP->iCapture;
			iRead++;
			iRead%=AUDIO_CAPTURE_PACKET_N;
			//copio al buffer el frame recibido
			SBE = SHP->SBE + iRead;
			
			memcpy(&(SHP->SBE_P.readed_blocks),&(SBE->readed_blocks),sizeof(ssize_t));
			memcpy(&(SHP->SBE_P.timestamp),&(SBE->timestamp),sizeof(int));
			memcpy(&(SHP->SBE_P.frameN),&(SBE->frameN),sizeof(int));
			
			printf("FILTRADOA:            | ts:%i | ssize_t:%i \n",SHP->SBE_P.timestamp,(int)SHP->SBE_P.readed_blocks);
			//Filtrado
			AudioDSP((int16_t *)&(SBE->_sample),(int16_t *)&(SHP->SBE_P._sample));
			
			iRead = memcmp(&(SBE->_sample),&(SHP->SBE_P._sample),(int)SBE->readed_blocks);
			printf("FILTRADO:            | Coinciden?:%i \n",iRead);
			printf("FILTRADOB:            | ts:%i | ssize_t:%i \n",SHP->SBE_P.timestamp,(int)SHP->SBE_P.readed_blocks);
			
			InitVal.val=0;
			semctl(Args->semid,3,SETVAL,InitVal);	
			InitVal.val = 1;
			semctl(Args->semid,2,SETVAL,InitVal);
			
			
		}else{
			if(errno==EINTR){
				//evaluo si es signal de interes
				if(signals_stat ==  SIGINT || signals_stat ==  SIGTERM) 
					break; 	
			}	
		}
		SemArg.sem_num = 0;
		SemArg.sem_op=0;
		SemArg.sem_flg=SEM_UNDO;
		semop(Args->semid, &SemArg, 1 );
	}
	return ;
}

void childFunc(char *argv[]){
	int fdtSocket,var;
	int fdtudpsock;
	struct sockaddr_in ServerUDP,clienteUDP;
	struct tcpPacket tcp_p;
	int  puertoUDP = PORTUDP -1;
	char test[255];
	socklen_t size;
	int last_ts;
	
	/*para el select*/
	struct timeval select_time;
	fd_set readfds;
	int nbr_fds;
	char bufferRecepcion[30];
	int sizeRecepcion;
	
	struct chArgs *chAr;
  
	shm_packet *SHP;
	SampleBaseEntry *SBE ;
	
	struct sembuf   SemArg;
	
	/*para el select*/
	//fd_set readfds;
	//int var,nbr_fds;
	/*******/
	
	chAr = (struct chArgs *)argv;
	SHP = (shm_packet *)chAr->shmptr;
  
	printf("[%i] Server Child: Running...\n",getpid());
	memcpy( &fdtSocket,&(chAr->fdtSocket),   sizeof(int) );//paso el descriptor de socket a travez de argv
  
  
	//AF_INET == internet | SOCK_DGRAM NO orientado a la conexion | 0 UDP
	fdtudpsock=socket(AF_INET,SOCK_DGRAM,0);
	if(fdtudpsock==-1){
		perror("error al crear el socket");
		return;
	}
	//seteamos a cero la estructura
	memset(&ServerUDP,0,sizeof(ServerUDP));
	ServerUDP.sin_family=AF_INET;
	//LocalHost
	ServerUDP.sin_addr.s_addr=htonl(INADDR_ANY);

	do{
		puertoUDP++;
		//Seteamos puerto 
		ServerUDP.sin_port=htons(puertoUDP);

		printf("[%i] Server Child: probando usar puerto: %i...\n",getpid(),puertoUDP);
		//terminamos de establecer conexion
		var = bind(fdtudpsock,(struct sockaddr*)&ServerUDP,sizeof(ServerUDP));
	}while(var == -1);

	strcpy(tcp_p.mensaje_conexion,"Bienvenido...");
	tcp_p.Port_UDP = puertoUDP;
	//enviamos la info de conexion al cliente
	size = send(fdtSocket,&tcp_p,sizeof(tcp_p)+1,0);
	if(size != sizeof(tcp_p)){
		perror("send:"); 
	}
	size=0;

	printf("[%i] Server Child: esperando Recibir del cliente por UDP: %i...\n",getpid(),puertoUDP);



	memset(&clienteUDP,0,sizeof(struct sockaddr_in));
	size =sizeof(struct sockaddr);
	//se llena clienteUDP
	if ( recvfrom(fdtudpsock,test, sizeof(test), 0, (struct sockaddr*) &clienteUDP, &size)== -1)
		perror("Error en recvfrom");
	//printf("[%i] Server Child: ClienteUDP: %i | %i | %i |\n",getpid(),clienteUDP.sin_port,clienteUDP.sin_addr.s_addr, clienteUDP.sin_family); 
	//printf("[%i] Server Child: size: %i \n",getpid(),size);

	printf("[%i] Server Child: Mensaje del cliente: %s...\n",getpid(),test); 


	strcpy(test,"lala");
	select_time.tv_usec = 100;
	select_time.tv_sec = 0;
	
	last_ts = 0;
	
	while(1){
		SemArg.sem_num = 3;//1
		SemArg.sem_op=0;
		SemArg.sem_flg=SEM_UNDO;
		if(semop(chAr->semid, &SemArg, 1 )!=-1){
			//seteo el puntero para escribir por udp
			SBE = &(SHP->SBE_P);
			if(last_ts<SBE->timestamp){
				printf("SEND_UDP:            | ts:%i | ssize_t:%i \n",SBE->timestamp,(int)SBE->readed_blocks);
				//envio frame UDP un Frame
				if (sendto(fdtudpsock,SBE,sizeof(SampleBaseEntry),0,(struct sockaddr*) &clienteUDP, sizeof(clienteUDP)) == -1)
					perror("Error en sendto");
				last_ts= SBE->timestamp;
			}
		}else{
				printf("CECECECEVRVRVRVR");
		}
		SemArg.sem_num = 2;//0
		SemArg.sem_op=0;
		SemArg.sem_flg=SEM_UNDO;
		if(semop(chAr->semid, &SemArg, 1 )==-1){
		
			printf("LALALALALA");
		}
		
		if(signals_stat ==  SIGINT || signals_stat ==  SIGTERM) 
				break; 
		
	// LEER TCP ALIVE
		// Crear la lista de "file descriptors" que vamos a escuchar
		FD_ZERO(&readfds);
		// Especificamos los sockets
		FD_SET(fdtSocket, &readfds);
		var = fdtSocket;
		
		nbr_fds = select(var+1, &readfds, NULL, NULL,&select_time);

		if ((nbr_fds<0) && (errno!=EINTR)){
			perror("select");
		}
		
		//LLego SIGNAL
		if((nbr_fds<0) && (errno==EINTR)){
			//evaluo si es signal de interes
			if(signals_stat ==  SIGINT || signals_stat ==  SIGTERM) 
				break; 
		}

		if(nbr_fds){
			//llego frame por tcp
			if(FD_ISSET(fdtSocket,&readfds)){
				printf("[%i] Cliente: FRAME POR TCP\n",getpid());
				sizeRecepcion = recv(fdtSocket, bufferRecepcion, sizeof(bufferRecepcion), 0);
				if(sizeRecepcion==0){
					printf("[%i] Cliente: Servidor Caido?..Saliendo\n",getpid());
					break;
				}
			}
			
		}
		
		
	}


	if(close (fdtudpsock)==-1){
		perror("Close():");
	}
	if(close (fdtSocket)==-1){
		perror("Close():");
	}

	printf("[%i] Server Child: Terminando...",getpid());
	exit(0);
}



void sINT_Handler(void ){
	printf("\nPresionaste Ctl-c.\n");
	signals_stat = SIGINT;
}

void sTERM_Handler(void ){
	printf("\nPresionaste SIGTERM.\n");
	signals_stat = SIGTERM;
}

void chldHandler (void){ 
	signals_stat = SIGCHLD;
	chld_pid = wait(NULL);
}
