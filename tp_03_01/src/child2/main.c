#include "globals.h"
#include <pthread.h>

#define BUFFER_SIZE 4

struct t1Args{
    int *iToFill;
    int *iToRead;
    int *readed_frames;
    SampleBaseEntry *buffers;  
}; 
void thread_lecturaSHM(struct t1Args *Args);
void thread_escrituraDSP(struct t1Args *Args);

int main(int argc, char *argv[])
{
  int pid;
  
  struct t1Args _t1Args;
  pthread_t tr1,tr2;

  int iToFill,iToRead,readed_frames;
  SampleBaseEntry buffers[BUFFER_SIZE];
  iToFill = iToRead = readed_frames = 0;
  memset ( &buffers, 0, BUFFER_SIZE * sizeof(SampleBaseEntry) );
  
  pid = getpid();
  printf("[%i] AudioWrite: Running...\n",pid);
  

  /**********************Creo el thread de lectura de la sharedM*************/
  _t1Args.iToFill = &iToFill;
  _t1Args.iToRead = &iToRead;
  _t1Args.readed_frames = &readed_frames;
  _t1Args.buffers = buffers;
  pthread_create (&tr1, NULL, (void*)thread_lecturaSHM,&_t1Args); 
  
  /**********************Creo el thread de escritura a DSP*************/
  pthread_create (&tr2, NULL, (void*)thread_escrituraDSP,&_t1Args); 
  
  while (1) {   
    }

}

union semun {
        int val;                    /* value for SETVAL */
        struct semid_ds *buf;       /* buffer for IPC_STAT, IPC_SET */
        unsigned short int *array;  /* array for GETALL, SETALL */
        struct seminfo *__buf;      /* buffer for IPC_INFO */
    };


//en este thread leo de la shared memory y mando al buffer de escritura
void thread_lecturaSHM(struct t1Args *Args){
 
  SampleBaseEntry *sample;
  
   /*para la shared memory */
  int		shmid, semid;
  char		*shmptr;
  key_t           clave;
  shm_packet *SHP;
  SampleBaseEntry *SBE ;
    
  struct sembuf   SemArg;
  //union semun sem_union;
  
  /*pido memoria compartida */
  clave=ftok(".",101);
          
  shmid=shmget(clave, sizeof(shm_packet),0666);
  shmptr=shmat(shmid,NULL,0);
  SHP = (shm_packet *)shmptr;
  
  /* creo un semaforo de control*/
  semid=semget(clave, 2, IPC_CREAT | 0666);
  
  //printf("[%i] %i %i %i %i\n",getpid(),Args->iToFill,Args->iToRead,Args->readed_frames,Args->buffers);
  *(Args->iToFill) = 0;
  *(Args->iToRead) = 0;
  *(Args->readed_frames) = 0;
  
 
   while (1) {
      SemArg.sem_num = 1;
      SemArg.sem_op=-1;
      SemArg.sem_flg=SEM_UNDO;
      semop(semid, &SemArg, 1 );
	
      //copio al buffer el frame recibido
      SBE = SHP->SBE + SHP->iRead;
      sample = Args->buffers + *(Args->iToFill);
       
      printf("READ:                |SBE_N°%i| ts:%i | ssize_t:%i \n",SHP->iRead,SBE->timestamp,(int)SBE->readed_blocks);
      memcpy( &(sample->_sample),&(SBE->_sample),SBE->readed_blocks);
      sample->readed_blocks = SBE->readed_blocks;
      sample->timestamp = SBE->timestamp;
      
      SHP->iRead++;
      SHP->iRead%=AUDIO_CAPTURE_PACKET_N;
      
      
      (*Args->iToFill)++;
      (*Args->readed_frames)++;
      (*Args->iToFill)%=BUFFER_SIZE;
     

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

  SampleBaseEntry *sample;

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
     // if((*Args->readed_frames)>=BUFFER_SIZE/2){	
	
        sample = Args->buffers + *(Args->iToRead);
       
	  if((*Args->iToRead)!=(*Args->iToFill)){
	    printf("AudioWrite:                  | ts:%i | ssize_t:%i | iToRead: %i\n",sample->timestamp,(int)sample->readed_blocks,(*Args->iToRead));
	    status = write(fd, &(sample->_sample),sample->readed_blocks); /* record some sound */
	    (*Args->iToRead)++;
	  }
	  
	  (*Args->iToRead)%=BUFFER_SIZE;
	  
	  if (status != (int)sample->readed_blocks){
	    perror("wrote wrong number of bytes");
	    printf("    status: %i buffers[iToRead].readed_blocks: %u \n",status,(unsigned int)sample->readed_blocks);
	  }
	//  status = ioctl(fd, SOUND_PCM_SYNC, 0);
	//  if (status == -1)
	//    perror("SOUND_PCM_SYNC ioctl failed");
      //}
  }
  
}
