#include <string.h>
#include <stdarg.h>
#include <stdio.h>

int Begin_clk, End_clk, No_of_clk;

static inline uint64_t rdcyc() {
  uint64_t val;
  asm volatile ("rdcycle %[a] ;\n": [a] "=r" (val) ::);
  return val;
}

volatile uint32_t *uart_tx_add = (uint32_t *)(0x0002fff0);

void print_uart(char *fmt, ...)
{
  char *num_string;
  int decimal[32];
  int num,i;
  
  va_list valist;
  va_start(valist, fmt);
  
  while (*fmt)
  {
	if ( *fmt == 37) {
		num = va_arg(valist, int);
		i=0;
		while(num!=0){
			decimal[i] = num % 10;
			num = num / 10;
			i++;
		}
		while(i>0){
			*uart_tx_add = 48 + decimal[i-1];
			i--;
		}
		fmt++;
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