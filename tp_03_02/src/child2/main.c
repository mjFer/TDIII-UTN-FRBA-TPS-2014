#include "globals.h"
#include <pthread.h>

#include "static_queue.h"

#define BUFFER_SIZE 4

struct t1Args{
    static_filo_queue *cola_lectura_shm;
    static_filo_queue *cola_PostProcessing;
    unsigned long readed_frames;
    
    //sistemV
    int clave;
    int	 semid;
    //SampleBaseEntry *buffers;  
}; 
void thread_lecturaSHM(struct t1Args *Args);
void thread_escrituraDSP(struct t1Args *Args);

int main(int argc, char *argv[])
{
  int pid;
  
  int	 semid;
  key_t  clave;
   
  struct t1Args _t1Args;
  pthread_t tr1,tr2;

  static_filo_queue cola_lectura_shm,cola_PostProcessing;
  
  /*pido memoria compartida */
  clave=ftok(".",101);
  /* creo un semaforo de control*/
  semid=semget(clave, 6, IPC_CREAT | 0666);
  
  if(filo_init(&cola_lectura_shm, BUFFER_SIZE, sizeof(SampleBaseEntry),semid, 2,3)==-1){
    perror("fallo la creacion del filo");
  }
  
  if(filo_init(&cola_PostProcessing, BUFFER_SIZE, sizeof(SampleBaseEntry),semid, 4,5)==-1){
    perror("fallo la creacion del filo");
  }
  printf(" AudioWrite: Colas Inicializadas...\n");
  
  //int iToFill,iToRead,
  //int readed_frames;
  //SampleBaseEntry buffers[BUFFER_SIZE];
  //iToFill = iToRead = readed_frames = 0;
  //memset ( &buffers, 0, BUFFER_SIZE * sizeof(SampleBaseEntry) );
  
  pid = getpid();
  printf("[%i] AudioWrite: Running...\n",pid);
  

  /**********************Creo el thread de lectura de la sharedM*************/
  _t1Args.cola_lectura_shm = &cola_lectura_shm;
  _t1Args.cola_PostProcessing = &cola_PostProcessing;
  _t1Args.clave = clave;
  _t1Args.semid = semid;
  
  pthread_create (&tr1, NULL, (void*)thread_lecturaSHM,&_t1Args); 
  
  /**********************Creo el thread de escritura a DSP*************/
  pthread_create (&tr2, NULL, (void*)thread_escrituraDSP,&_t1Args); 
  
  while (1) { 
    //por ahora para que no joda
    sleep(10);
    
  }

}


//en este thread leo de la shared memory y mando al buffer de escritura
void thread_lecturaSHM(struct t1Args *Args){
  
   /*para la shared memory */
  int		shmid, semid;
  char		*shmptr;
  key_t           clave;
  shm_packet *SHP;
  SampleBaseEntry *SBE ;
  struct sembuf   SemArg;
    
  //union semun sem_union;
  printf(" AudioWrite: TH1 RUNNING...\n");
  clave = Args->clave;
          
  shmid=shmget(clave, sizeof(shm_packet),0666);
  shmptr=shmat(shmid,NULL,0);
  SHP = (shm_packet *)shmptr;
  
  /* creo un semaforo de control*/
  semid=Args->semid;
  
  //printf("[%i] %i %i %i %i\n",getpid(),Args->iToFill,Args->iToRead,Args->readed_frames,Args->buffers);
  
  Args->readed_frames = 0;
   while (1) {
      SemArg.sem_num = 1;
      SemArg.sem_op=-1;
      SemArg.sem_flg=SEM_UNDO;
      semop(semid, &SemArg, 1 );
	
      //copio al buffer el frame recibido
      SBE = SHP->SBE + SHP->iRead;
      printf("READ:                |SBE_N°%i| ts:%i | ssize_t:%i \n",SHP->iRead,SBE->timestamp,(int)SBE->readed_blocks);
      filo_addto_smph(Args->cola_lectura_shm, SBE);
      
      SHP->iRead++;
      SHP->iRead%=AUDIO_CAPTURE_PACKET_N;
      Args->readed_frames++;
      
      SemArg.sem_num = 0;
      SemArg.sem_op=1;
      SemArg.sem_flg=SEM_UNDO;
      semop(semid, &SemArg, 1 );
   }
}

//en este thread escribo a la placa de audio
void thread_escrituraDSP(struct t1Args *Args){
  int fd;       /* sound device file descriptor */
  int arg;      /* argument for ioctl calls */
  int status;   /* return status of system calls */

  SampleBaseEntry sample;
  printf("AudioWrite: TH2 RUNNING...\n");
  
  
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
    if(Args->readed_frames>=(BUFFER_SIZE/2)){
        filo_take_smph(Args->cola_lectura_shm, &sample);
       
	printf("AudioWrite:                  | ts:%i | ssize_t:%i \n",sample.timestamp,(int)sample.readed_blocks);
	status = write(fd, &(sample._sample),sample.readed_blocks); /* record some sound */

	  
	if (status != (int)sample.readed_blocks){
	  perror("wrote wrong number of bytes");
	  printf("    status: %i buffers[iToRead].readed_blocks: %u \n",status,(unsigned int)sample.readed_blocks);
	}
    }
  }
  
}
