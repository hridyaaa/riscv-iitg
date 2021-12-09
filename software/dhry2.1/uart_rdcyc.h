#include <string.h>
#include <stdarg.h>
#include <stdio.h>

int Begin_clk, End_clk, No_of_clk;

static inline uint64_t rdcyc() {
  uint64_t val;
  asm volatile ("rdcycle %[a] ;\n": [a] "=r" (val) ::);
  return val;
}

volatile uint32_t *uart_tx_add = (uint32_t *)(0x000001f0);

void print_uart(char *fmt, ...)
{
  char *num_string;
  int decimal[32];
  int num,i;
  char *str ;
  
  va_list valist;
  va_start(valist, fmt);
  
  while (*fmt)
  {
	if ( *fmt == 37 ) {
		
		num = va_arg(valist, int);
		fmt++;
		
		if ( *fmt == 'c' ) {
			*uart_tx_add = num;
		
		} else if ( *fmt == 's' ) {
			str = (char *)num;
			while( *str != '\0' ) {
				*uart_tx_add = *str;
				str++;
			}
		} else if ( *fmt == 'x' ) {
			i=0;
			if(num==0){
				decimal[i] = 0;
				i++;
			}
			else {
				while(num!=0){
					decimal[i] = num % 16;
					num = num / 16;
					i++;
				}
			}
			while(i>0){
				if (decimal[i-1]<10) *uart_tx_add = 48 + decimal[i-1];
				else                 *uart_tx_add = 87 + decimal[i-1];
				i--;
			}
		} else {
			i=0;
			if(num==0){
				decimal[i] = 0;
				i++;
			}
			while(num!=0){
				decimal[i] = num % 10;
				num = num / 10;
				i++;
			}
			while(i>0){
				*uart_tx_add = 48 + decimal[i-1];
				i--;
			}
		}
		
	}
	else if (*fmt == 0x0A) {
		*uart_tx_add = 0x0D;
		*uart_tx_add = *fmt;
	}
	else {
		*uart_tx_add = *fmt;
	}
	fmt++;
  }
  
  va_end(valist);
  
}