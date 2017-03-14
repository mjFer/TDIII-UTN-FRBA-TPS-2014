#ifndef GLOBALS_H
#define GLOBALS_H

#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <stdio.h>
#include <linux/soundcard.h>


#include <signal.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/wait.h> 

#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <semaphore.h>

#include "sh_audio.h"

#define TRUE 1
#define FALSE 0

/*rutas a los ejecutables*/
#define CHILD1_ROUTE "./child1"
#define CHILD2_ROUTE "./child2"


union semun
{
 int val;
 struct semid_ds *buf;
 unsigned short int *array;
 struct seminfo *__buf;
 };

#endif
