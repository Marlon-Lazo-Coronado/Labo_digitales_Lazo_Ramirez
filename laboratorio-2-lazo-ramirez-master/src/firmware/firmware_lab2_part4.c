#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

#define LED_REGISTERS_MEMORY_ADD_0 0x10000000
#define LED_REGISTERS_MEMORY_ADD_1 0x1000000C
#define LED_REGISTERS_MEMORY_ADD_2 0x10000010
#define LED_REGISTERS_MEMORY_ADD_3 0xFFFFFFF8

#define LED_REGISTERS_MEMORY_ADD_4 0xFFFFFFF0
#define LED_REGISTERS_MEMORY_ADD_5 0xFFFFFFFC
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

static void putuint3(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_5) = i;
}

static uint32_t getuint0() {
	uint32_t i;
	i = *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_3);
	return i;
}

static uint32_t getuint1() {
	uint32_t i;
	i = *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_4);
	return i;
}

void main() {
	uint32_t num_0_0 = 120;
	uint32_t num_0_1 = 19; 
	uint32_t num_0_2 = 3628800; 
	uint32_t num_0_3 = 39916800;

	uint32_t num_1_0 = 2;
	uint32_t num_1_1 = 17; 
	uint32_t num_1_2 = 11; 
	uint32_t num_1_3 = 12; 
	uint32_t num_1_4 = 3628800;

	uint32_t counter = 1;
	uint32_t counter_0 = 0;
	uint32_t temp = 0;
	uint32_t temp_1 = 0;

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
		}
		else if(counter == 4){
			putuint1(num_0_3);
			putuint2(num_1_3);
		}
		else if(counter == 5){
			putuint1(num_0_3);
			putuint2(num_1_4);
			counter = 0;
		}
		counter++;
		temp = getuint0();
		putuint0(temp);

		temp_1 = getuint1();
		putuint3(temp_1);
	}
}
