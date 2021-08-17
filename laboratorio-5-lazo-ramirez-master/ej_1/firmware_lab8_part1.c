#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LED_REGISTERS_MEMORY_ADD_1 0x20000000
#define LOOP_WAIT_LIMIT 60000

static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}

static uint32_t getdisable() {
	uint32_t i;
	i = *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_1);
	return i;
}


void main() {
	uint32_t number_to_display = 8;
	uint32_t counter = 0;
	uint32_t disable = 0;

	while (1) {
		counter = 0;
		disable = getdisable();
		putuint(number_to_display);
		if(number_to_display == 8){
			number_to_display = 0;
		} else {
			if(disable == 0){
				number_to_display++;
			} else {
				number_to_display = number_to_display;
			}
		}
		while (counter < LOOP_WAIT_LIMIT) {
			counter++;
		}
	}
}
