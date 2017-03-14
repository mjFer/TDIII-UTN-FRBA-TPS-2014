/********************************************************/
/* ALUMNO: Marcelo J. Fernandez 			
 * LEGAJO: 140.373.4 					
 * CURSO:  TDIII   					
 * Aclaraciones rm tdiii_pipe si quedo creada		
 * 		echo "mensaje" > tdiii_pipe para mandar 
 * 			msg
/********************************************************/
#include <stdio.h>
#include <unistd.h>

#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>                 
              
#include <sys/types.h>             
#include <sys/poll.h>                           

#define TIMEOUT_MS 0
#define N_FD 2

#define BUFFER_SIZE 128

int main () {                                                          
  char buffer[BUFFER_SIZE];                                                    
  int i = 0, result, nread;                                            
  struct pollfd pollfds[N_FD];                                              

  if (mknod("./tdiii_pipe",S_IFIFO | 0666,0) <0)
  {
    perror ("Error en mknod");
    exit (1);
  }
  
  /* Initialize pollfds; we're looking at input from /dev/scmd*/       
  
  pollfds[0].fd = open("./tdiii_pipe",O_RDONLY);      
  pollfds[1].fd = 0;	//standard input

  if ( pollfds[0].fd  < 0 ) {                                          
    printf(" Error al abrir ./tdiii_pipe \n");                            
    return 1;                                                          
  }                                                                    
  pollfds[0].events = POLLIN;      /* Wait for input */    
  pollfds[1].events = POLLIN;      /* Wait for input */         

  while (1) {                                                          
      result = poll (pollfds, N_FD, TIMEOUT_MS);                            
      switch (result) {                                                
	case 0:/*time out*/                                                                                                
	  break;                                                       
	case -1:                                                       
	  printf ("poll error \n");                                    
	  return -1;                                                  

	  default: 
	    for(i=0;i<N_FD;i++){
	      if (pollfds[i].revents & POLLIN) {                           
		  nread = read (pollfds[i].fd, buffer, BUFFER_SIZE);         
		  if (nread > 0) {                                        
		      buffer[nread] = 0;                                   
		      if(i==0) printf ("[PIPE]: %s", buffer);
		      if(i==1) printf ("[KEYB]: %s", buffer);
		    }                                                      
		}                   
	    }
	}                                                              
    }                                                                  
  close(pollfds[0].fd);                                                           
  return 0;                                                            
}    



//void sINT_Handler(void ){
//  printf("\nPresionaste Ctl-c. Saliendo");
//}