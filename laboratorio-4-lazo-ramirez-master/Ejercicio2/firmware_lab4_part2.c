#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LED_REGISTERS_MEMORY_ADD_y 0x20000000
#define LED_REGISTERS_MEMORY_ADD_z 0x30000000
#define LOOP_WAIT_LIMIT 2000000

//uint32_t global_counter = 0;

static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}


static uint32_t getinty() {
	uint32_t i;
	i = *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_y);
	return i;
	}
	
static uint32_t getintz() {
	uint32_t i;
	i = *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_z);
	return i;
	}



void main() {
	
	uint32_t counter = 0;
	uint32_t z = 0, y = 0, temp = 0;

	while (1) {
		counter = 0;
		
		y = getinty();
		z = getintz();
		temp = (y << 16) | (0x0000FFFF & z);
		
		putuint(temp);
		while (counter < LOOP_WAIT_LIMIT) {
			counter++;
		}
	}
}
