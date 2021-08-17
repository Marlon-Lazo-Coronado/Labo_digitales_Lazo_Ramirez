#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

#define LED_REGISTERS_MEMORY_ADD_0 0x10000000
#define LED_REGISTERS_MEMORY_ADD_1 0x10000004
#define LED_REGISTERS_MEMORY_ADD_2 0x10000008
#define LED_REGISTERS_MEMORY_ADD_3 0xFFFFFFF8
#define LOOP_WAIT_LIMIT 100

static void putuint0(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_0) = i;
}

static void putuint1(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_1) = i;
}

static void putuint2(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_2) = i;
}

static uint32_t getint() {
	uint32_t i;
	i = *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_3);
	return i;
}

void main() {
	uint32_t num_0_0 = 1;
	uint32_t num_0_1 = 2; 
	uint32_t num_0_2 = 6; 

	uint32_t num_1_0 = 2;
	uint32_t num_1_1 = 3; 
	uint32_t num_1_2 = 4; 

	uint32_t counter = 1;
	uint32_t counter_0 = 0;
	uint32_t temp = 0;

	while(1)
	{
		if(counter == 1){
			putuint1(num_0_0);
			putuint2(num_1_0);
		}
		else if(counter == 2){
			putuint1(num_0_1);
			putuint2(num_1_1);
		}
		else if(counter == 3){
			putuint1(num_0_2);
			putuint2(num_1_2);
			counter = 0;
		}
		counter++;
		temp = getint();
		putuint0(temp);
	}
}
