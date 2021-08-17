#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LED_REGISTERS_MEMORY_ADD1 0x0FFFFFF0
#define LED_REGISTERS_MEMORY_ADD2 0x0FFFFFF4
#define LED_REGISTERS_MEMORY_ADD3 0x0FFFFFF8
#define LED_REGISTERS_MEMORY_ADD4 0x0FFFFFFC
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
static uint32_t getint2() {
	uint32_t i;
	i = *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD4);
	return i;
	}
	
static uint32_t counter() {
	uint32_t temp;
	temp = getint();
	uint32_t cont = 0;
	
	while (temp){ 
        temp &= (temp-1); 
        cont++; 
    	} 
    	 
    	uint32_t temp2;
    	temp2 = getint2();
    	while (temp2){ 
        temp2 &= (temp2-1); 
        cont++; 
    	} 
    	return cont; 
}
	

void main() {
uint32_t temp=0;

while (1){

	/////////////////////////////////////////////
	putuint1(25);
	temp = counter();
	putuint(temp);
		
	putuint2(7);	
	temp = counter();
	putuint(temp);
	///////////////////////////////////////////////	
	putuint1(635);
	temp = counter();
	putuint(temp);
		
	putuint2(1023);	
	temp = counter();
	putuint(temp);
	/////////////////////////////////////////////////
	putuint1(2157297371);
	temp = counter();
	putuint(temp);
		
	putuint2(562);	
	temp = counter();
	putuint(temp);
	////////////////////////////////////////////////
	putuint1(9813723);
	temp = counter();
	putuint(temp);
		
	putuint2(4036341403);	
	temp = counter();
	putuint(temp);
	////////////////////////////////////////////////
	putuint1(3628800);
	temp = counter();
	putuint(temp);	
		
	putuint2(1);	
	temp = counter();
	putuint(temp);
	///////////////////////////////////////////////
	putuint1(4068839099);
	temp = counter();
	putuint(temp);
	
	putuint1(0);
	temp =counter();
	putuint(temp);
}
}
