#ifndef GLOBALS_H
#define GLOBALS_H


#include <unistd.h>
#include <stdlib.h>

#include <fcntl.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <linux/soundcard.h>

#include<string.h>
#include<netinet/in.h>
#include<arpa/inet.h>
#include<sys/types.h>
#include<sys/socket.h>

#include <signal.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/wait.h> 

#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <semaphore.h>

#include <errno.h>

#include "sh_audio.h"

#define TRUE 1
#define FALSE 0


#define PORTTCP 8145
#define PORTCLI 4555
#define PORTUDP 10000


union semun
{
 int val;
 struct semid_ds *buf;
 unsigned short int *array;
 struct seminfo *__buf;
 };
 
 
struct tcpPacket{
    char mensaje_conexion[20];
    uint32_t Port_UDP; 
};

#endif
