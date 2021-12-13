#include <stdio.h>
#include <time.h>
#include <memory.h>
#include "uart_rdcyc.h"

int main()
{
	int i;
	long int t_beg = 3, t_end;
	
	for (i=0; i<100; i++);
	// t_beg = rdcyc();
	
	// for (i=0; i<100000000; i++);
	
	// t_end 	= rdcyc();
    // print_uart ("Time taken: %d", (t_end-t_beg)/1); // To know the excution time of the loop.
    print_uart("Hello!\n"); 
    printf("Hello!\n"); 
	// print_uart ("Start Time: %d \n", t_beg );
	// print_uart ("End Time  : %d \n", t_end );
	return 0;
}