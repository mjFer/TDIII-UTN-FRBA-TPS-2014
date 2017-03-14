#include "globals.h"

int main(int argc, char *argv[])
{
  int fd;       /* sound device file descriptor */
  int arg;      /* argument for ioctl calls */
  int status;   /* return status of system calls */
  /*para la shared memory */
  int	shmid, semid;
  char	*shmptr;
  key_t clave;
  shm_packet *SHP;
  SampleBaseEntry *SBE ;
  struct sembuf   SemArg;
  int frameN=0;
  //struct timeval tv1;
  
  printf("[%i] AudioCapture: Running...\n",getpid());
  
  /*pido memoria compartida */
  clave=ftok(".",101);
  if (clave == -1)
    perror("ftok fallo\n");
          
  shmid=shmget(clave, sizeof(shm_packet),0666);
  if (shmid == -1)
    perror("shmget fallo...");
  shmptr=shmat(shmid,NULL,0);
  SHP = (shm_packet *)shmptr;
  
  /* creo un semaforo de control*/
  semid=semget(clave, 2, IPC_CREAT | 0666);
  if (semid == -1)
    perror("shmget fallo\n");
  
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
    /*decremento el semaforo de lugares libres para capturar muestras*/
    SemArg.sem_num = 0;
    SemArg.sem_op=-1;
    SemArg.sem_flg=SEM_UNDO;
    semop(semid, &SemArg, 1 );
    
    /*aca tengo que tomar una muestra*/
    SBE = SHP->SBE + SHP->iCapture;

    status = read(fd, &(SBE->_sample), sizeof(audio_frame)); /* record some sound */  
    SBE->readed_blocks = status;
    if (status != sizeof(audio_frame)){
      perror("read wrong number of bytes");
    }   
    SBE->timestamp = frameN;
    SBE->frameN = frameN;
    printf("READING:    /dev/dsp |SBE_n°%i| ts:%i | ssize_t:%i \n",SHP->iCapture,SBE->timestamp,status);
    frameN++;  
     
    SHP->iCapture++;
    SHP->iCapture%=AUDIO_CAPTURE_PACKET_N;
    
    
    
    /*incremento el semaforo de muestras tomadas*/
    SemArg.sem_num = 1;
    SemArg.sem_op=1;
    SemArg.sem_flg=SEM_UNDO;
    semop(semid, &SemArg, 1 );
  }
}
