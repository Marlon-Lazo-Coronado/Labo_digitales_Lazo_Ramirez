#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#define LED_REGISTERS_MEMORY_ADD 0x10000000
//#define LOOP_WAIT_LIMIT 100

/*Funcion que escribe i en la direccion de memoria 0x10000000, 
obtenida de la guia del primer laboratorio.*/
static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;}

void main() {
uint32_t swich=2, a=5, temp=a, sum = 1;

while (1){

	//Factorial del primer numero
	while (a >= 2){
	temp = a - 1;
	sum = sum * (a * temp);
	a = temp-1;
	}
	//printf("%" PRIu32 "\n",sum);
	putuint(sum);
	
	sum = 1;
	
	if (swich == 1){
		a=5;
	}
	if (swich == 2) {
		a=7;
	}
	if (swich == 3) {
		a=10;
	}
	if (swich == 4) {
		a=12;
		swich = 0;
	}
	swich = swich +1;
}
}
