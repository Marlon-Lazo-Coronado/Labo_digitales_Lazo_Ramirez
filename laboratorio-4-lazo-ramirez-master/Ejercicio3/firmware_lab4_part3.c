#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define IRQ_REGISTERS_MEMORY_ADD 0x10000004

#define LED_REGISTERS_MEMORY_ADD_y 0x20000000
#define LED_REGISTERS_MEMORY_ADD_z 0x30000000

#define LED_REGISTERS_MEMORY_ADD_interrupt 0x1000000C

#define LOOP_WAIT_LIMIT 2000000

uint32_t global_counter = 0;

static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}

static void putuint2(uint32_t i) {
	*((volatile uint32_t *)IRQ_REGISTERS_MEMORY_ADD) = i;
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

static uint32_t getINT() {
	uint32_t i;
	i = *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_interrupt);
	return i;
}



uint32_t *irq(uint32_t *regs, uint32_t irqs) {
    global_counter = 1;
    putuint2(global_counter);
    return regs;
}


void main() {
	uint32_t number_to_display = 0;
	uint32_t counter = 0;
	uint32_t z = 0, y = 0, temp = 0;
	uint32_t INT1 = 0;

	while (1) {
		counter = 0;
		y = getinty();
		z = getintz();

		INT1 = getINT();
		
		
		if(INT1 == 1){
			putuint(0);
		} else{
			temp = (y << 16) | (0x0000FFFF & z);
			putuint(temp);
		}
		
		while (counter < LOOP_WAIT_LIMIT) {
			counter++;
		}
	}
}
