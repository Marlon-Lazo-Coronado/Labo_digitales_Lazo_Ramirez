#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LED_REGISTERS_MEMORY_ADD1 0x0FFFFFF0
#define LED_REGISTERS_MEMORY_ADD2 0x0FFFFFF4
#define LED_REGISTERS_MEMORY_ADD3 0x0FFFFFF8
//#define LOOP_WAIT_LIMIT 100

/*Funcion que escribe i en la direccion de memoria 0x10000000, 
obtenida de la guia del primer laboratorio.*/
static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD)=i;}
static void putuint1(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD1)=i;}
static void putuint2(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD2)=i;}
static uint32_t getint() {
	uint32_t i;
	i = *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD3);
	return i;
	}

void main() {
uint32_t temp=0;

uint32_t a=0;
uint32_t b=0;
while (1){

	for (int i=0; i<=15; i++){
		putuint1(i);
		a++;
		for (int j=0; j<=15; j++){
			putuint2(j);
			b++;
			temp = getint();
			putuint(temp);
		}
	}
	
}
}
