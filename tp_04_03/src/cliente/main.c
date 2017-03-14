#include "globals.h"
#include <pthread.h>
#include "static_queue.h"

#define STDIN 0

#define BUFFER_SIZE 8



struct t1Args{
    static_fifo_queue *cola_lectura_udp;
    unsigned long readed_frames;
    
    //sistemV
    int clave;
    int	 semid;
    //SampleBaseEntry *buffers;  
}; 


//para las signals
int signals_stat;

//handlers de signals
void sINT_Handler (void);
void sTERM_Handler(void );

void thread_escrituraDSP(struct t1Args *Args);

int Max(int a,int b);

int main(int cant, char *param[])
{
	struct sigaction _sigAction;
	int fdSocket,fdUDP_sock;
	struct sockaddr_in ServerTcp,ClienteTcp,ClienteUDP,ServerUDP;
	struct tcpPacket tcp_p;
	char bufferRecepcion[30];
	int sizeRecepcion;
	socklen_t rs;
	char test[10] = "hola";
	fd_set readfds;
	int var,nbr_fds;
	/*para el thread de lectura*/
	struct t1Args _t1Args;
	pthread_t tr1;
	static_fifo_queue cola_lectura_udp;
	
	//buffer de recepcion
	SampleBaseEntry SBE;
	
	int	 semid;
	key_t  clave;
	clave=ftok(".",112);
	/* creo un semaforo de control*/
	semid=semget(clave, 2, IPC_CREAT | 0666);
	
	if(fifo_init(&cola_lectura_udp, BUFFER_SIZE, sizeof(SampleBaseEntry),semid, 0,1)==-1){
		perror("fallo la creacion del fifo");
	}
	

	if(cant<2){
		printf("Se debe pasar la ip del servidor por argumento\n");
		exit(0);
	}
  
	signals_stat = 0;
	memset (&_sigAction, 0, sizeof(_sigAction));

	//inicializo la signal de control c (SIGINT)
	_sigAction.sa_handler = (void *) sINT_Handler;
	_sigAction.sa_restorer = NULL;
	sigaction (SIGINT, &_sigAction, NULL);

	//inicializo la signal de control c (SIGTERM)
	_sigAction.sa_handler = (void *) sTERM_Handler;
	_sigAction.sa_restorer = NULL;
	sigaction (SIGTERM, &_sigAction, NULL);
  
	/**********************Creo el thread de escritura a DSP*************/
	_t1Args.cola_lectura_udp = &cola_lectura_udp;
	_t1Args.clave = clave;
	_t1Args.semid = semid;
	_t1Args.readed_frames = 0;
	
	pthread_create (&tr1, NULL, (void*)thread_escrituraDSP,&_t1Args); 

	
	
	

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

	printf("[%i] Cliente: Por leer tcpData \n",getpid());
	sizeRecepcion = read(fdSocket,&tcp_p,sizeof(tcp_p));
	if(sizeRecepcion!=sizeof(tcp_p)){
		perror("read:"); 
		close (fdSocket);
		return 0;
	}
	printf("[%i] Cliente: lectura Correcta \n",getpid());
  
	printf("SERVIDOR MESSAGE: %s \n",tcp_p.mensaje_conexion);
  
  
	fdUDP_sock=socket(AF_INET,SOCK_DGRAM,0);
	if(fdUDP_sock==-1){
		perror("socket():"); 
		close (fdSocket);
		close (fdUDP_sock);
		return 0;
	}
	//memset(&ClienteUDP,0,sizeof(ClienteUDP));
	ClienteUDP.sin_family=AF_INET;
	ClienteUDP.sin_port=htons(0);//cualquier puerto disponible
	ClienteUDP.sin_addr.s_addr=htonl(INADDR_ANY);
  
  
	printf("[%i] Cliente: Configurando UDP PORT:%i IP:%s \n",getpid(),tcp_p.Port_UDP,param[1]);
	sizeRecepcion = bind(fdUDP_sock,(struct sockaddr*)&ClienteUDP,sizeof(ClienteUDP));
	if(sizeRecepcion==-1){
		perror("bind():"); 
		close (fdSocket);
		close (fdUDP_sock);
		return 0;
	}
  
	sleep(1);
  
	memset(&ServerUDP,0,sizeof(ServerUDP));
	ServerUDP.sin_family=AF_INET;
	ServerUDP.sin_addr.s_addr = inet_addr(param[1]);
	ServerUDP.sin_port = htons(tcp_p.Port_UDP);

	rs = sizeof(struct sockaddr_in);

	printf("[%i] Cliente: Enviando Dummy Por UDP... \n",getpid());
	sendto(fdUDP_sock,test,strlen(test)+1,0,(struct sockaddr*)&ServerUDP,sizeof(ServerUDP));


	printf("[%i] Cliente: Esperando Packetes Por UDP... \n",getpid());
  
	
	while(1){
    
		// Crear la lista de "file descriptors" que vamos a escuchar
		FD_ZERO(&readfds);

		// Especificamos los sockets
		FD_SET(fdUDP_sock, &readfds);
		FD_SET(fdSocket, &readfds);
		FD_SET(STDIN, &readfds);

		var = Max(fdUDP_sock,fdSocket);
		var = Max(var,STDIN);
		
		// Espera al establecimiento de alguna conexion.
		// El primer parametro es el maximo de los fds especificados en
		// las macros FD_SET + 1.
		nbr_fds = select(var+1, &readfds, NULL, NULL,0);


		if ((nbr_fds<0) && (errno!=EINTR))
		{
			perror("select");
		}
		
		//LLego SIGNAL
		if((nbr_fds<0) && (errno==EINTR)){
			
			//evaluo si es signal de interes
			if(signals_stat ==  SIGINT || signals_stat ==  SIGTERM) 
				break; 
		}

		if(nbr_fds){

			//llego frame por UDP
			if (FD_ISSET(fdUDP_sock,&readfds)){	
				//printf("[%i] Cliente: FRAME POR UDP\n",getpid());
				sizeRecepcion = recvfrom(fdUDP_sock, &SBE, sizeof(SBE), 0, (struct sockaddr*)&ServerUDP, &rs);
				if(sizeRecepcion==0){
					printf("[%i] Cliente: Se desconecto el cliente..........\n",getpid());
					break;
				}
				if(sizeRecepcion!=sizeof(SBE)){
					perror("recvfrom:");
				}
				else{
					if(fifo_addto_smph(&cola_lectura_udp, &SBE)==-1){
						printf("[%i] Cliente: ERROR: AAA",getpid());
						if(errno==EINTR){
							if(signals_stat ==  SIGINT || signals_stat ==  SIGTERM) //evaluo si es signal de interes
								break; 
						}
					}else{
						_t1Args.readed_frames++;
						//printf("Cliente: Capturado           | ts:%i | ssize_t:%i \n",SBE.timestamp,(int)SBE.readed_blocks);
					}	
				}
			}
			//llego frame por tcp
			if(FD_ISSET(fdSocket,&readfds)){
				printf("[%i] Cliente: FRAME POR TCP\n",getpid());
				sizeRecepcion = recv(fdSocket, bufferRecepcion, sizeof(bufferRecepcion), 0);
				if(sizeRecepcion==0){
					printf("[%i] Cliente: Servidor Caido?..Saliendo\n",getpid());
					break;
				}
			}
			//llego frame por STDIN
			if(FD_ISSET(STDIN,&readfds)){
				printf("[%i] Cliente: STDIN!\n",getpid());
				sizeRecepcion = recv(STDIN, bufferRecepcion, sizeof(bufferRecepcion), 0);
				if(strcmp("EXIT",bufferRecepcion)==0)
					break;
			}
		}

	}
  
  
	printf("[%i] Cliente: Cerrando Audio-Speaker... \n",getpid());
	pthread_kill(tr1, SIGINT);
	pthread_join(tr1, NULL);  //espero que termine el thread
	printf("[%i] Cliente: Cerrando Conexiones... \n",getpid());
	close (fdUDP_sock);
	close (fdSocket);
	printf("[%i] Cliente: Removiendo Semaforos... \n",getpid());
	semctl(semid,0,IPC_RMID);
	printf("[%i] Cliente: Liberando Memoria... \n",getpid());
	fifo_dispose(&cola_lectura_udp);
	printf("[%i] Cliente: Finalizando Cliente... \n",getpid());
     

  return 0;  
}


//en este thread escribo a la placa de audio
void thread_escrituraDSP(struct t1Args *Args){
  int fd;       /* sound device file descriptor */
  int arg;      /* argument for ioctl calls */
  int status;   /* return status of system calls */

  SampleBaseEntry sample;
  printf("AudioWrite: RUNNING...\n");
  
  
  printf("[%i] AudioWrite -- opening /dev/dsp... \n",getpid());
  /* abrimos el device de audio */
  fd = open("/dev/dsp", O_WRONLY);
  if (fd < 0) {
    perror("open of /dev/dsp failed");
    exit(1);
  }

  printf("[%i] AudioWrite -- 1/3 setting Sample size... \n",getpid());
  /* set sampling parameters */
  arg = SIZE;      /* sample size */
  status = ioctl(fd, SOUND_PCM_WRITE_BITS, &arg);
  if (status == -1)
    perror("SOUND_PCM_WRITE_BITS ioctl failed");
  if (arg != SIZE)
    perror("unable to set sample size");

  printf("[%i] AudioWrite -- 2/3 setting N_Chanels... \n",getpid());
  arg = CHANNELS;  /* mono or stereo */
  status = ioctl(fd, SOUND_PCM_WRITE_CHANNELS, &arg);
  if (status == -1)
    perror("SOUND_PCM_WRITE_CHANNELS ioctl failed");
  if (arg != CHANNELS)
    perror("unable to set number of channels");

  printf("[%i] AudioWrite -- 3/3 setting SAMPLE RATE... \n",getpid());
  arg = RATE;      /* sampling rate */
  status = ioctl(fd, SOUND_PCM_WRITE_RATE, &arg);
  if (status == -1)
    perror("SOUND_PCM_WRITE_WRITE ioctl failed");

  
  while (1) { 
    //espero a que se haya llenado un poco las colas para arrancar a mandar a la salida
    if(Args->readed_frames>=((BUFFER_SIZE/2) + 4)){
	//TODO hacer que evalue los flags de thread para terminar
        if(fifo_take_smph(Args->cola_lectura_udp, &sample)!=-1){
		printf("AudioWrite:                  | ts:%i | ssize_t:%i \n",sample.timestamp,(int)sample.readed_blocks);
		//FIXME no deberia fallar el desencolado y levantar datos basura por un par de ciclos
		if(sample.readed_blocks == sizeof(sample._sample)){
			status = write(fd, &(sample._sample),sample.readed_blocks); /* record some sound */
		}
		else{
			perror("error al leer de la cola");
		}	
		
		if(signals_stat ==  SIGINT || signals_stat ==  SIGTERM) 
				break; 	

		if (status != (int)sample.readed_blocks){
			perror("numero de bytes escritos a dsp erroneos");
			printf("    status: %i buffers[iToRead].readed_blocks: %u \n",status,(unsigned int)sample.readed_blocks);
		}
	}else{
		if(errno==EINTR){
			//evaluo si es signal de interes
			if(signals_stat ==  SIGINT || signals_stat ==  SIGTERM) 
				break; 	
		}
		
	}
    }
  }
  
  printf("[%i] Cliente: Audio-Speaker END... \n",getpid());
  close(fd);
  
}

void sINT_Handler(void ){
	printf("\nPresionaste Ctl-c.\n");
	signals_stat = SIGINT;
}

void sTERM_Handler(void ){
	printf("\nPresionaste SIGTERM.\n");
	signals_stat = SIGTERM;
}


int Max(int a,int b){
	if(a>b)
		return a;
	else
		return b;
}
