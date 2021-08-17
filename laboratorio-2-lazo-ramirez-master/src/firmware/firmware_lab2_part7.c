#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define LED_REGISTERS_MEMORY_ADD_num 0x0FFFFFF0
#define LED_REGISTERS_MEMORY_ADD_flag 0x0FFFFFF4
#define LED_REGISTERS_MEMORY_ADD_fac 0x0FFFFFF8
#define LED_REGISTERS_MEMORY_ADD_ready 0x0FFFFFFC
//#define LOOP_WAIT_LIMIT 100

/*Funcion que escribe i en la direccion de memoria 0x10000000, 
obtenida de la guia del primer laboratorio.*/
static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD)=i;}
static void putuint_num(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_num)=i;}
static void putuint_flag(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_flag)=i;}
static uint32_t getint_fac() {
	uint32_t i;
	i = *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_fac);
	return i;
	}
static uint32_t getint_ready() {
	uint32_t i;
	i = *((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD_ready);
	return i;
	}

void main() {

uint32_t temp=0;
uint32_t a=0;
uint32_t ready=0;

while (1){

	putuint_flag(0);
	putuint_num(5);
	putuint_flag(1);
	while (ready == 0){
		ready = getint_ready();
	}
	temp = getint_fac();
	putuint(temp);
	ready=0;
	
	//=====================================================
	putuint_flag(0);
	putuint_num(7);
	putuint_flag(1);
	while (ready == 0){
		ready = getint_ready();
	}
	temp = getint_fac();
	putuint(temp);
	ready=0;
	
	//=====================================================
	putuint_flag(0);
	putuint_num(10);
	putuint_flag(1);
	while (ready == 0){
		ready = getint_ready();
	}
	temp = getint_fac();
	putuint(temp);
	ready=0;
	
	//=====================================================
	putuint_flag(0);
	putuint_num(12);
	putuint_flag(1);
	while (ready == 0){
		ready = getint_ready();
	}
	temp = getint_fac();
	putuint(temp);
	ready=0;
}
}
