#include "globals.h"
#include "array.h"
#include "childs.h"



void sINT_Handler(void );
void sTERM_Handler(void );

//para las signals
int signals_stat;

int main(int argc, char *argv[])
{
	struct sigaction _sigAction;
	int fd;       /* sound device file descriptor */
	int arg;      /* argument for ioctl calls */
	int status;   /* return status of system calls */
	/*para la shared memory */
	int	shmid, semid;
	char	*shmptr;
	key_t clave;
	shm_packet *SHP;
	SampleBaseEntry *SBE ;
	int frameN=0;
	
	union semun InitVal;
	
	printf("[%i] AudioCapture: Running...\n",getpid());
	
	signals_stat = 0;
	//inicializo la signal de control c (SIGINT)
	_sigAction.sa_handler = (void *) sINT_Handler;
	_sigAction.sa_restorer = NULL;
	sigaction (SIGINT, &_sigAction, NULL);

	//inicializo la signal de (SIGTERM)
	_sigAction.sa_handler = (void *) sTERM_Handler;
	_sigAction.sa_restorer = NULL;
	sigaction (SIGTERM, &_sigAction, NULL);

	
	/*pido memoria compartida */
	clave=ftok(".",101);
	if (clave == -1)
		perror("ftok fallo\n");
          
	shmid=shmget(clave, sizeof(shm_packet),IPC_CREAT | 0666);
	if (shmid == -1){
		perror("shmget fallo lalala");
		exit(1);
	}
	
	shmptr=shmat(shmid,NULL,0);
	if((long)shmptr == -1){
		perror("shmat:");
		exit(1);
	}
	SHP = (shm_packet *)shmptr;
  
	/* creo un semaforo de control*/
	semid=semget(clave, 4, IPC_CREAT | 0666);
	if (semid == -1){
		perror("semget fallo");
		exit(1);
	}
	
	InitVal.val=0;
	semctl(semid,0,SETVAL,InitVal);	
	InitVal.val = 1;
	semctl(semid,1,SETVAL,InitVal);
	
	
	printf("[%i] AudioCapture -- opening /dev/dsp... \n",getpid());
	/* abrimos el device de audio */
	fd = open("/dev/dsp", O_RDONLY);
	if (fd < 0) {
		perror("open of /dev/dsp failed");
		exit(1);
	}

	printf("[%i] AudioCapture -- 1/3 setting Sample size... \n",getpid());
	/* set sampling parameters */
	arg = SIZE;      /* sample size */
	status = ioctl(fd, SOUND_PCM_WRITE_BITS, &arg);
	if (status == -1)
		perror("SOUND_PCM_WRITE_BITS ioctl failed");
	if (arg != SIZE)
		perror("unable to set sample size");

	printf("[%i] AudioCapture -- 2/3 setting N_Chanels... \n",getpid());
	arg = CHANNELS;  /* mono or stereo */
	status = ioctl(fd, SOUND_PCM_WRITE_CHANNELS, &arg);
	if (status == -1)
		perror("SOUND_PCM_WRITE_CHANNELS ioctl failed");
	if (arg != CHANNELS)
		perror("unable to set number of channels");

	printf("[%i] AudioCapture -- 3/3 setting SAMPLE RATE... \n",getpid());
	arg = RATE;      /* sampling rate */
	status = ioctl(fd, SOUND_PCM_WRITE_RATE, &arg);
	if (status == -1)
		perror("SOUND_PCM_WRITE_WRITE ioctl failed");

	SHP->iCapture =0;
	SHP->iRead = 0;
	frameN = 0;
	while (1) { 
		//TODO CAMBIAR SISTEMA DE SEMAFOROS
		InitVal.val=0;
		semctl(semid,0,SETVAL,InitVal);	
		InitVal.val = 1;
		semctl(semid,1,SETVAL,InitVal);
		
		
		/*aca tengo que tomar una muestra*/
		SBE = SHP->SBE + SHP->iCapture;

		status = read(fd, &(SBE->_sample), sizeof(audio_frame)); /* record some sound */  
		if(status!=-1){
			SBE->readed_blocks = status;
			if (status != sizeof(audio_frame)){
				perror("AudioCapture: read wrong number of bytes");
			}   
			SBE->timestamp = frameN;
			SBE->frameN = frameN;
			printf("READING:    /dev/dsp |SBE_n°%i| ts:%i | ssize_t:%i \n",SHP->iCapture,SBE->timestamp,status);
			frameN++;  
			
			SHP->iCapture++;
			SHP->iCapture%=AUDIO_CAPTURE_PACKET_N;
			
			InitVal.val = 1;
			semctl(semid,0,SETVAL,InitVal);
			InitVal.val=0;
			semctl(semid,1,SETVAL,InitVal);	
		}else{
			if(errno==EINTR){
				if(signals_stat ==  SIGINT || signals_stat ==  SIGTERM){ 
					break; 
				}
			}
		}
		
		if(signals_stat ==  SIGINT || signals_stat ==  SIGTERM){ 
			break; 
		}
		
	}
	
	
	printf("[%i] AudioCapture: Cerrando...\n",getpid());
	semctl(semid,0,IPC_RMID);
	shmdt(shmptr);
	exit(0);
}


void sINT_Handler(void ){
	printf("AudioCapture: Presionaste Ctl-c.\n");
	signals_stat = SIGINT;
}

void sTERM_Handler(void ){
	printf("AudioCapture: Presionaste SIGTERM.\n");
	signals_stat = SIGTERM;
}
